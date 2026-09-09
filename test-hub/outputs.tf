output "hub_network_resource_group_name" {
  description = "Feeds 10-network var.hub_network_resource_group_name and 20-firewall-rules var.ip_group_resource_group_name."
  value       = azurerm_resource_group.hub.name
}

output "hub_virtual_network_id" {
  description = "Feeds 10-network var.hub_virtual_network_id."
  value       = azurerm_virtual_network.hub.id
}

output "hub_virtual_network_name" {
  description = "Feeds 10-network var.hub_virtual_network_name."
  value       = azurerm_virtual_network.hub.name
}

output "hub_firewall_private_ip" {
  description = "Feeds 10-network var.hub_firewall_private_ip (UDR next hop)."
  value       = azurerm_firewall.hub.ip_configuration[0].private_ip_address
}

output "firewall_policy_id" {
  description = "Feeds 20-firewall-rules var.firewall_policy_id."
  value       = azurerm_firewall_policy.hub.id
}

output "hub_private_dns_zones" {
  description = "Feeds 10-network var.hub_private_dns_zones."
  value = {
    acr      = { name = "privatelink.azurecr.io", resource_group_name = azurerm_resource_group.hub.name }
    blob     = { name = "privatelink.blob.core.windows.net", resource_group_name = azurerm_resource_group.hub.name }
    keyvault = { name = "privatelink.vaultcore.azure.net", resource_group_name = azurerm_resource_group.hub.name }
  }
}

output "hub_private_dns_zone_ids" {
  description = "Feeds 30-supporting-services var.hub_private_dns_zone_ids."
  value = {
    acr      = azurerm_private_dns_zone.this["privatelink.azurecr.io"].id
    blob     = azurerm_private_dns_zone.this["privatelink.blob.core.windows.net"].id
    keyvault = azurerm_private_dns_zone.this["privatelink.vaultcore.azure.net"].id
  }
}
