output "admins_group_object_id" {
  description = "Object ID of the AKS admins Entra group."
  value       = azuread_group.aks_admins.object_id
}

output "developers_group_object_id" {
  description = "Object ID of the AKS developers Entra group."
  value       = azuread_group.aks_developers.object_id
}
