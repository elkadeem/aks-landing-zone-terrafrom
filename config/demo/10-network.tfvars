spoke_subscription_id = "00000000-0000-0000-0000-000000000000"
hub_subscription_id   = "11111111-1111-1111-1111-111111111111"
location              = "swedencentral"
prefix                = "example"
environment           = "demo"

hub_virtual_network_id          = "/subscriptions/11111111-1111-1111-1111-111111111111/resourceGroups/rg-example-demo-hub/providers/Microsoft.Network/virtualNetworks/vnet-example-demo-hub"
hub_virtual_network_name        = "vnet-example-demo-hub"
hub_network_resource_group_name = "rg-example-demo-hub"
hub_firewall_private_ip         = "10.100.0.4"

hub_private_dns_zones = {
  acr      = { name = "privatelink.azurecr.io", resource_group_name = "rg-example-demo-hub" }
  blob     = { name = "privatelink.blob.core.windows.net", resource_group_name = "rg-example-demo-hub" }
  keyvault = { name = "privatelink.vaultcore.azure.net", resource_group_name = "rg-example-demo-hub" }
}
