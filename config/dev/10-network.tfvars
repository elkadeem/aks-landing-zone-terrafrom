spoke_subscription_id = "00000000-0000-0000-0000-000000000000"
hub_subscription_id   = "11111111-1111-1111-1111-111111111111"
location              = "uaenorth"
prefix                = "example"
environment           = "dev"

hub_virtual_network_id          = "/subscriptions/1111.../resourceGroups/rg-hub-network/providers/Microsoft.Network/virtualNetworks/vnet-hub"
hub_virtual_network_name        = "vnet-hub"
hub_network_resource_group_name = "rg-hub-network"
hub_firewall_private_ip         = "10.0.0.4"

hub_private_dns_zones = {
  acr      = { name = "privatelink.azurecr.io", resource_group_name = "rg-hub-dns" }
  blob     = { name = "privatelink.blob.core.windows.net", resource_group_name = "rg-hub-dns" }
  keyvault = { name = "privatelink.vaultcore.azure.net", resource_group_name = "rg-hub-dns" }
}
