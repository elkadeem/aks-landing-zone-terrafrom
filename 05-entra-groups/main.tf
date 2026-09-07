locals {
  name = "${var.prefix}-${var.environment}"
}

# Cluster administrators (mapped to cluster-admin via AKS Azure RBAC).
resource "azuread_group" "aks_admins" {
  display_name     = "${local.name}-aks-admins"
  description      = "AKS cluster administrators for ${local.name}"
  security_enabled = true
  members          = var.admin_member_object_ids
}

# Developers (granted namespace read/write via AKS Azure RBAC).
resource "azuread_group" "aks_developers" {
  display_name     = "${local.name}-aks-developers"
  description      = "AKS developers for ${local.name}"
  security_enabled = true
  members          = var.developer_member_object_ids
}
