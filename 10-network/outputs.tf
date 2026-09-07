output "resource_group_name" {
  description = "Spoke network resource group."
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "Resource ID of the spoke virtual network."
  value       = module.vnet.resource_id
}

output "vnet_name" {
  description = "Name of the spoke virtual network."
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet resource IDs, keyed by role (aks, data, privateendpoints, appgw)."
  value       = { for k, v in module.vnet.subnets : k => v.resource_id }
}
