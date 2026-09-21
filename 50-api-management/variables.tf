variable "hub_subscription_id" {
  description = "Subscription ID containing both API Management and the hub virtual network."
  type        = string
}

variable "location" {
  description = "Azure region for API Management. Must match the hub virtual network region."
  type        = string
  default     = "uaenorth"
}

variable "prefix" {
  description = "Short workload/naming prefix (lowercase, alphanumeric)."
  type        = string
  default     = "example"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.prefix))
    error_message = "prefix must contain only lowercase letters and numbers."
  }
}

variable "environment" {
  description = "Environment short name (e.g. dev, prod)."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "apim_name" {
  description = "Globally unique API Management service name."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,48}[a-zA-Z0-9]$", var.apim_name))
    error_message = "apim_name must be 2-50 characters, start with a letter, end with a letter or number, and contain only letters, numbers, and hyphens."
  }
}

variable "publisher_name" {
  description = "Publisher organization name shown by API Management."
  type        = string
}

variable "publisher_email" {
  description = "Publisher email used for API Management notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$", var.publisher_email))
    error_message = "publisher_email must be a valid email address."
  }
}

variable "apim_capacity" {
  description = "Number of Standard v2 capacity units."
  type        = number
  default     = 1

  validation {
    condition     = var.apim_capacity >= 1 && var.apim_capacity <= 10
    error_message = "apim_capacity must be between 1 and 10 for Standard v2."
  }
}

variable "hub_virtual_network_name" {
  description = "Name of the existing hub virtual network."
  type        = string
}

variable "hub_network_resource_group_name" {
  description = "Resource group containing the existing hub virtual network."
  type        = string
}

variable "apim_subnet_prefix" {
  description = "Dedicated subnet CIDR for APIM VNet integration. Use /24 when possible; /27 is the minimum."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.apim_subnet_prefix))
    error_message = "apim_subnet_prefix must be a valid IPv4 CIDR."
  }
}

variable "tags" {
  description = "Tags applied to API Management resources."
  type        = map(string)
  default = {
    workload   = "aks-landing-zone"
    managed-by = "terraform"
  }
}
