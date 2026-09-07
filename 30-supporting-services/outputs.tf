output "resource_group_name" {
  description = "Supporting services resource group."
  value       = azurerm_resource_group.supporting.name
}

output "uami_id" {
  description = "Resource ID of the user-assigned managed identity for AKS."
  value       = module.uami.resource_id
}

output "uami_principal_id" {
  description = "Principal (object) ID of the user-assigned managed identity."
  value       = module.uami.principal_id
}

output "uami_client_id" {
  description = "Client ID of the user-assigned managed identity."
  value       = module.uami.client_id
}

output "acr_id" {
  description = "Resource ID of the Azure Container Registry."
  value       = module.acr.resource_id
}

output "acr_login_server" {
  description = "Login server of the Azure Container Registry."
  value       = module.acr.login_server
}

output "storage_account_id" {
  description = "Resource ID of the storage account."
  value       = module.storage.resource_id
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = module.key_vault.resource_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = module.key_vault.uri
}
