variable "subscription_id" {
  description = "Subscription ID where the test hub is created (use the same subscription as the spoke for a single-subscription test)."
  type        = string
}

variable "location" {
  description = "Azure region for the test hub."
  type        = string
  default     = "uaenorth"
}

variable "prefix" {
  description = "Short naming prefix (lowercase, alphanumeric)."
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment short name (e.g. dev, test)."
  type        = string
  default     = "dev"
}

variable "hub_address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)
  default     = ["10.100.0.0/22"]
}

variable "firewall_subnet_prefix" {
  description = "Prefix for AzureFirewallSubnet (minimum /26)."
  type        = string
  default     = "10.100.0.0/26"
}

variable "firewall_sku_tier" {
  description = "Azure Firewall tier (Standard is required for FQDN network rules / DNS proxy)."
  type        = string
  default     = "Standard"
}

variable "private_dns_zone_names" {
  description = "Private DNS zones to create in the hub for the spoke private endpoints."
  type        = list(string)
  default = [
    "privatelink.azurecr.io",
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
  ]
}

variable "tags" {
  description = "Tags applied to all hub resources."
  type        = map(string)
  default = {
    workload   = "aks-landing-zone-testhub"
    managed-by = "terraform"
  }
}
