hub_subscription_id = "11111111-1111-1111-1111-111111111111"
location            = "uaenorth"
prefix              = "example"
environment         = "dev"

apim_name      = "apim-example-dev"
publisher_name = "EXAMPLE"

# Replace this address before deploying.
publisher_email = "api-admin@example.com"
apim_capacity   = 1

hub_virtual_network_name        = "vnet-hub"
hub_network_resource_group_name = "rg-hub-network"

# Replace with an unused /24 from the hub VNet address space.
apim_subnet_prefix = "10.0.1.0/24"
