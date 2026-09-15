# Manual Test Walkthrough (two subscriptions)

Deploy the whole template **command-by-command from Windows PowerShell** so you can run each step
yourself and watch what it does. This flow uses **two subscriptions**:

- **Hub subscription** — holds the `test-hub` (VNet + Azure Firewall + policy + Private DNS zones).
- **Spoke subscription** — holds the state backend and all spoke stacks (network, firewall rules,
  supporting services, AKS).

The spoke stacks reach into the hub with an aliased `azurerm.hub` provider, so the identity you sign
in with needs **RBAC in both subscriptions** (plus a directory role such as *Groups Administrator*
for stage `05`).

## 0. Session setup (run once per shell)

```powershell
# work from the repo root
cd D:\Projects\AKS-LandingZone

# stop on the first error so a bad step doesn't cascade
$ErrorActionPreference = 'Stop'

# sign in once — this identity must have rights in BOTH subscriptions
az login

# the two target subscriptions
$spokeSub = '<spoke-subscription-id>'
$hubSub   = '<hub-subscription-id>'
```

> **amd64 note:** the commands below call `terraform` from your PATH. On an ARM64 machine the
> official provider builds may be missing, so make sure the `terraform` on PATH is the **amd64**
> build (e.g. `D:\Tools\terraform\terraform.exe`). Verify with `terraform version` — it should
> report `on windows_amd64`.

## 1. Bootstrap the state backend (spoke subscription, local state)

```powershell
az account set --subscription $spokeSub

terraform "-chdir=00-bootstrap" init
terraform "-chdir=00-bootstrap" apply -var-file="../config/demo/00-bootstrap.tfvars"   # type: yes
```

Capture the backend coordinates it just created:

```powershell
$stateRg = terraform "-chdir=00-bootstrap" output -raw resource_group_name
$stateSa = terraform "-chdir=00-bootstrap" output -raw storage_account_name
$stateRg; $stateSa                          # sanity check

# reusable backend args for every other stack (state always lives in the spoke sub)
$backend = @(
  "-backend-config=resource_group_name=$stateRg",
  "-backend-config=storage_account_name=$stateSa",
  "-backend-config=container_name=tfstate"
)
```

## 2. Deploy the hub in the hub subscription (`test-hub`)

Set `subscription_id = <hub-subscription-id>` in `config/demo/test-hub.tfvars`, then:

```powershell
terraform "-chdir=test-hub" init @backend
terraform "-chdir=test-hub" apply -var-file="../config/demo/test-hub.tfvars"   # type: yes

# read the outputs — you'll paste these into the spoke configs next
terraform "-chdir=test-hub" output
```

The `test-hub` provider targets `subscription_id` from its var-file, so it lands in the hub sub even
though the state file sits in the spoke sub's storage account.

## 3. Wire the hub outputs into the spoke config

Print each value and copy it into the matching var-file:

```powershell
terraform "-chdir=test-hub" output -raw hub_virtual_network_id
terraform "-chdir=test-hub" output -raw hub_virtual_network_name
terraform "-chdir=test-hub" output -raw hub_network_resource_group_name
terraform "-chdir=test-hub" output -raw hub_firewall_private_ip
terraform "-chdir=test-hub" output -raw firewall_policy_id
terraform "-chdir=test-hub" output hub_private_dns_zones       # object → 10-network
terraform "-chdir=test-hub" output hub_private_dns_zone_ids    # object → 30-supporting-services
```

| test-hub output | Config file | Variable |
|---|---|---|
| `hub_virtual_network_id` | `config/demo/10-network.tfvars` | `hub_virtual_network_id` |
| `hub_virtual_network_name` | `config/demo/10-network.tfvars` | `hub_virtual_network_name` |
| `hub_network_resource_group_name` | `config/demo/10-network.tfvars` | `hub_network_resource_group_name` |
| `hub_firewall_private_ip` | `config/demo/10-network.tfvars` | `hub_firewall_private_ip` |
| `hub_private_dns_zones` | `config/demo/10-network.tfvars` | `hub_private_dns_zones` |
| `firewall_policy_id` | `config/demo/20-firewall-rules.tfvars` | `firewall_policy_id` |
| `hub_network_resource_group_name` | `config/demo/20-firewall-rules.tfvars` | `ip_group_resource_group_name` |
| `hub_private_dns_zone_ids` | `config/demo/30-supporting-services.tfvars` | `hub_private_dns_zone_ids` |

Point each subscription variable at the right place (two-subscription test):

```hcl
# config/demo/10-network.tfvars and config/demo/20-firewall-rules.tfvars
spoke_subscription_id = "<spoke-subscription-id>"
hub_subscription_id   = "<hub-subscription-id>"
```

The remaining stacks (`05`, `30`, `40`) run entirely in the spoke subscription, so their
`spoke_subscription_id` is enough.

## 4. Deploy the spoke stacks, one at a time

```powershell
az account set --subscription $spokeSub

terraform "-chdir=05-entra-groups" init @backend
terraform "-chdir=05-entra-groups" apply -var-file="../config/demo/05-entra-groups.tfvars"

terraform "-chdir=10-network" init @backend
terraform "-chdir=10-network" apply -var-file="../config/demo/10-network.tfvars"

terraform "-chdir=20-firewall-rules" init @backend
terraform "-chdir=20-firewall-rules" apply -var-file="../config/demo/20-firewall-rules.tfvars"

terraform "-chdir=30-supporting-services" init @backend
terraform "-chdir=30-supporting-services" apply -var-file="../config/demo/30-supporting-services.tfvars"

terraform "-chdir=40-aks" init @backend
terraform "-chdir=40-aks" apply -var-file="../config/demo/40-aks.tfvars"
```

Tip: swap `apply` for `plan` on any stack first to preview without changing anything.

## 5. Connect to the (private) cluster

```powershell
$aksRg   = terraform "-chdir=40-aks" output -raw resource_group_name
$aksName = terraform "-chdir=40-aks" output -raw aks_cluster_name
az aks get-credentials -g $aksRg -n $aksName
az aks command invoke -g $aksRg -n $aksName --command "kubectl get nodes"
```

## 6. Tear it all down (reverse order)

```powershell
foreach ($s in '40-aks','30-supporting-services','20-firewall-rules','10-network','05-entra-groups') {
  terraform "-chdir=$s" destroy -var-file="../config/demo/$s.tfvars"
}
terraform "-chdir=test-hub" destroy -var-file="../config/demo/test-hub.tfvars"
# 00-bootstrap last (only if you no longer need the remote state)
```

## Notes

- **Quote `"-chdir=$s"`** in PowerShell — unquoted, the variable won't expand.
- The **Azure Firewall is billed hourly** — destroy `test-hub` when you're done.
- Stage `05` needs a directory role (*Groups Administrator*). Without it, skip `05` and remove the
  `admin_group_object_ids` wiring in `40-aks`.
- The signed-in identity needs **Contributor/Owner in both subscriptions**; the hub-side peering,
  DNS links, and firewall-policy rules are created through the `azurerm.hub` provider alias.
