spoke_subscription_id = "00000000-0000-0000-0000-000000000000"
location              = "uaenorth"
prefix                = "example"
environment           = "dev"

public_network_access_enabled = false

state_resource_group_name  = "rg-example-dev-tfstate"
state_storage_account_name = "st<...>"
state_container_name       = "tfstate"

hub_private_dns_zone_ids = {
  acr      = "/subscriptions/1111.../resourceGroups/rg-hub-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
  blob     = "/subscriptions/1111.../resourceGroups/rg-hub-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  keyvault = "/subscriptions/1111.../resourceGroups/rg-hub-dns/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
}
