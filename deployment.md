# Deployment Guide

How to deploy the AKS landing zone — locally, via GitHub Actions, or via Azure Pipelines.

## 1. Prerequisites

- **Terraform** `>= 1.11` and **Azure CLI** (`az login`).
- Azure RBAC to create resources in the **spoke** and **hub** subscriptions.
- **Directory** permission (e.g. *Groups Administrator*) to create the Entra ID groups (stack `05`).
- Existing hub: Azure Firewall + firewall **policy** (with **DNS Proxy enabled**), hub VNet, and the
  Private DNS zones for ACR / Blob / Key Vault.

## 2. One-time bootstrap (state backend)

The remote state storage account is created by `00-bootstrap` using **local** state. Run it once,
manually, before any pipeline:

```bash
cd 00-bootstrap
terraform init
terraform apply
terraform output          # note storage_account_name + resource_group_name
```

Record the outputs — they become the backend config for every other stack.

## 3. Configure variables

Each stack reads a var-file per environment from `config/<environment>/<stack>.tfvars`.
Edit the files under `config/dev/` (or create `config/<env>/`) and fill in your subscription IDs,
hub resource IDs, firewall policy ID, state storage account name, etc.

> These files contain resource IDs (not secrets). Real `*.tfvars` outside `config/` are git-ignored.

## 4. Deploy order

All stacks are applied in this order (bootstrap first, then the rest):

```
00-bootstrap → 05-entra-groups → 10-network → 20-firewall-rules → 30-supporting-services → 40-aks
```

### Option A — Local / script

```bash
# after editing deploy.azcli variables
bash deploy.azcli
```

Or manually per stack:

```bash
BACKEND=(-backend-config="resource_group_name=<state-rg>"
         -backend-config="storage_account_name=<state-sa>"
         -backend-config="container_name=tfstate")

for STACK in 05-entra-groups 10-network 20-firewall-rules 30-supporting-services 40-aks; do
  terraform -chdir="$STACK" init "${BACKEND[@]}"
  terraform -chdir="$STACK" apply -var-file="config/dev/$STACK.tfvars"
done
```

### Option B — GitHub Actions (`.github/workflows/deploy.yml`)

1. Create an Entra app / managed identity with **federated credentials** for this repo and grant it
   RBAC on both subscriptions (+ *Groups Administrator* in the directory).
2. Repository **secrets**: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`.
3. Repository **variables**: `TFSTATE_RG`, `TFSTATE_SA`, `TFSTATE_CONTAINER`.
4. Run the **Deploy AKS Landing Zone** workflow (`workflow_dispatch`) choosing `plan` or `apply`, or
   push to `main` (defaults to `plan`).

Auth uses OIDC (`ARM_USE_OIDC`) and Azure AD backend auth (`ARM_USE_AZUREAD`) — no client secrets.

### Option C — Azure Pipelines (`azure-pipelines.yml`)

1. Create an **Azure service connection** with **workload identity federation**, named
   `sc-aks-landing-zone`, scoped to the spoke subscription (with the hub RBAC + directory role).
2. Create a **variable group** `aks-landing-zone` with `TFSTATE_RG`, `TFSTATE_SA`,
   `TFSTATE_CONTAINER`, `ENVIRONMENT`.
3. Run the pipeline and pick the `action` parameter (`plan` or `apply`).

## 5. Connect to the cluster

Members of the admins/developers groups (both have the *Cluster User* role):

```bash
az aks get-credentials --resource-group rg-<prefix>-<env>-aks --name aks-<prefix>-<env>
kubectl get nodes
```

The cluster is private — run from a host with network line-of-sight to the API server, or use
`az aks command invoke`.

## 6. Teardown

Destroy in reverse order (keep `00-bootstrap` last if you still need the state):

```bash
for STACK in 40-aks 30-supporting-services 20-firewall-rules 10-network 05-entra-groups; do
  terraform -chdir="$STACK" destroy -var-file="config/dev/$STACK.tfvars"
done
```
