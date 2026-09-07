variable "spoke_subscription_id" {
  description = "Subscription ID of the spoke (application landing zone) subscription."
  type        = string
}

variable "hub_subscription_id" {
  description = "Subscription ID of the hub / Azure landing zone subscription (holds the firewall policy and IP Group)."
  type        = string
}

variable "location" {
  description = "Azure region of the hub firewall / IP Group (assumed same region as the spoke)."
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

variable "firewall_policy_id" {
  description = "Resource ID of the EXISTING hub Azure Firewall Policy to attach the AKS rule collection group to."
  type        = string
}

variable "ip_group_resource_group_name" {
  description = "Resource group in the hub subscription where the IP Group is created (typically the hub network resource group)."
  type        = string
}

variable "aks_egress_source_cidrs" {
  description = "Source CIDRs allowed to egress through the firewall (the AKS node subnet, and any additional spokes). Update the IP Group here without touching the rules."
  type        = list(string)
  default     = ["10.116.12.0/24"]
}

variable "rule_collection_group_priority" {
  description = "Priority of the AKS rule collection group within the firewall policy (must be unique across groups)."
  type        = number
  default     = 500
}

variable "tags" {
  description = "Tags applied to the IP Group."
  type        = map(string)
  default = {
    workload   = "aks-landing-zone"
    managed-by = "terraform"
  }
}
