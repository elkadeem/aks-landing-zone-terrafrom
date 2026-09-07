variable "spoke_subscription_id" {
  description = "Subscription ID of the spoke (application landing zone) subscription where state storage is created."
  type        = string
}

variable "location" {
  description = "Azure region for the state storage account."
  type        = string
  default     = "uaenorth"
}

variable "prefix" {
  description = "Short workload/naming prefix (lowercase, alphanumeric)."
  type        = string
  default     = "example"

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.prefix))
    error_message = "prefix must be 2-10 lowercase alphanumeric characters."
  }
}

variable "environment" {
  description = "Environment short name (e.g. dev, prod)."
  type        = string
  default     = "dev"
}

variable "state_container_name" {
  description = "Blob container name that will hold the Terraform state files."
  type        = string
  default     = "tfstate"
}

variable "tags" {
  description = "Tags applied to all bootstrap resources."
  type        = map(string)
  default = {
    workload   = "aks-landing-zone"
    managed-by = "terraform"
  }
}
