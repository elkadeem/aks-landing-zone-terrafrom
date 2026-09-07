output "resource_group_name" {
  description = "Resource group holding the Terraform state storage account."
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "Name of the Terraform state storage account. Use this in each stack's backend config."
  value       = azurerm_storage_account.state.name
}

output "state_container_name" {
  description = "Blob container that holds the state files."
  value       = azurerm_storage_container.state.name
}

output "backend_config_hint" {
  description = "Copy these values into each stack's backend block / -backend-config."
  value = {
    resource_group_name  = azurerm_resource_group.state.name
    storage_account_name = azurerm_storage_account.state.name
    container_name       = azurerm_storage_container.state.name
  }
}
