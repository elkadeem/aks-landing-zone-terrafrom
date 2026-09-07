output "resource_group_name" {
  description = "Resource group holding the AKS cluster."
  value       = azurerm_resource_group.aks.name
}

output "aks_cluster_id" {
  description = "Resource ID of the AKS managed cluster."
  value       = module.aks.resource_id
}

output "aks_cluster_name" {
  description = "Name of the AKS managed cluster."
  value       = module.aks.name
}

output "node_resource_group" {
  description = "Auto-managed node resource group (MC_*) for the cluster."
  value       = "rg-${local.name}-aks-nodes"
}
