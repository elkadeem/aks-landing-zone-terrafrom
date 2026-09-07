variable "spoke_subscription_id" {
  description = "Subscription ID of the spoke (application landing zone) subscription."
  type        = string
}

variable "location" {
  description = "Azure region for the supporting services."
  type        = string
  default     = "uaenorth"
}

variable "prefix" {
  description = "Short workload/naming prefix (lowercase, alphanumeric)."
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment short name (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "public_network_access_enabled" {
  description = "When true, ACR/Storage/Key Vault also allow public network access (for testing). Private endpoints are created either way. Keep false for production."
  type        = bool
  default     = false
}

# ---- Remote state of the network stack (10-network) ----

variable "state_resource_group_name" {
  description = "Resource group of the Terraform state storage account (from 00-bootstrap)."
  type        = string
}

variable "state_storage_account_name" {
  description = "Name of the Terraform state storage account (from 00-bootstrap)."
  type        = string
}

variable "state_container_name" {
  description = "Blob container holding the state files."
  type        = string
  default     = "tfstate"
}

# ---- Existing hub Private DNS zones (resource IDs) ----

variable "hub_private_dns_zone_ids" {
  description = "Resource IDs of the existing hub Private DNS zones used by the private endpoints."
  type = object({
    acr      = string # privatelink.azurecr.io
    blob     = string # privatelink.blob.core.windows.net
    keyvault = string # privatelink.vaultcore.azure.net
  })
}

variable "tags" {
  description = "Tags applied to all supporting-service resources."
  type        = map(string)
  default = {
    workload   = "aks-landing-zone"
    managed-by = "terraform"
  }
}
