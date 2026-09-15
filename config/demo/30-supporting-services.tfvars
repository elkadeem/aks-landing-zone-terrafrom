spoke_subscription_id = "00000000-0000-0000-0000-000000000000"
location              = "swedencentral"
prefix                = "example"
environment           = "demo"

# Testing: allow public network access to ACR / Storage / Key Vault so you can push
# images and read secrets from your machine. Private endpoints are still created.
# Set back to false for production.
public_network_access_enabled = false

state_resource_group_name  = "rg-example-demo-tfstate"
state_storage_account_name = "stexampledemotf12345"
state_container_name       = "tfstate"

hub_private_dns_zone_ids = {
  acr      = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-example-demo-hub/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
  blob     = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-example-demo-hub/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  keyvault = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-example-demo-hub/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
}
