output "resource_group_name" {
  description = "Resource group containing API Management."
  value       = azurerm_resource_group.apim.name
}

output "apim_id" {
  description = "Resource ID of the API Management service."
  value       = azurerm_api_management.apim.id
}

output "apim_name" {
  description = "Name of the API Management service."
  value       = azurerm_api_management.apim.name
}

output "gateway_url" {
  description = "Public API Management gateway URL."
  value       = azurerm_api_management.apim.gateway_url
}

output "principal_id" {
  description = "Principal ID of the API Management system-assigned managed identity."
  value       = azurerm_api_management.apim.identity[0].principal_id
}

output "subnet_id" {
  description = "Resource ID of the dedicated APIM integration subnet in the hub VNet."
  value       = azurerm_subnet.apim.id
}
