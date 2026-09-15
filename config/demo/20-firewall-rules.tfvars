spoke_subscription_id = "00000000-0000-0000-0000-000000000000"
hub_subscription_id   = "11111111-1111-1111-1111-111111111111"
location              = "swedencentral"
prefix                = "example"
environment           = "demo"

firewall_policy_id           = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-example-demo-hub/providers/Microsoft.Network/firewallPolicies/afwp-example-demo-hub"
ip_group_resource_group_name = "rg-example-demo-hub"
aks_egress_source_cidrs      = ["10.116.12.0/24"]

# Optional (defaults shown):
# rule_collection_group_priority = 500
# extra_allowed_fqdns            = []
