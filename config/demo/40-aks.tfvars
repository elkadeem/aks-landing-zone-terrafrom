spoke_subscription_id = "00000000-0000-0000-0000-000000000000"
location              = "swedencentral"
prefix                = "example"
environment           = "demo"

state_resource_group_name  = "rg-example-demo-tfstate"
state_storage_account_name = "stexampledemotf12345"
state_container_name       = "tfstate"

kubernetes_version    = null
private_dns_zone_mode = "system"

# Keep the API server strictly private; access requires connectivity to the VNet.
enable_private_cluster_public_fqdn = false

# Entra group object IDs granted cluster-admin. Leave empty to use the group
# created by 05-entra-groups (wired automatically), or add extra admin groups here.
admin_group_object_ids = []

system_node_vm_size = "Standard_D2ds_v5"
user_node_vm_size   = "Standard_D2ds_v5"

# Optional node-pool scaling (defaults shown):
# system_node_min = 2
# system_node_max = 3
# user_node_min   = 2
# user_node_max   = 5
