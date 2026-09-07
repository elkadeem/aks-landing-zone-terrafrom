output "ip_group_id" {
  description = "Resource ID of the AKS egress IP Group. Update its CIDRs to change allowed sources."
  value       = azurerm_ip_group.aks_egress.id
}

output "rule_collection_group_id" {
  description = "Resource ID of the AKS egress rule collection group added to the hub firewall policy."
  value       = azurerm_firewall_policy_rule_collection_group.aks_egress.id
}
