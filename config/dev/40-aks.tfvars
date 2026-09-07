spoke_subscription_id = "00000000-0000-0000-0000-000000000000"
location              = "uaenorth"
prefix                = "example"
environment           = "dev"

state_resource_group_name  = "rg-example-dev-tfstate"
state_storage_account_name = "st<...>"
state_container_name       = "tfstate"

kubernetes_version                 = null
private_dns_zone_mode              = "system"
enable_private_cluster_public_fqdn = false
admin_group_object_ids             = []

system_node_vm_size = "Standard_D4s_v5"
user_node_vm_size   = "Standard_D4s_v5"
