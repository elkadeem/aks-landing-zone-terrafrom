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

variable "admin_member_object_ids" {
  description = "Optional initial members (user/service-principal object IDs) of the AKS admins group."
  type        = list(string)
  default     = []
}

variable "developer_member_object_ids" {
  description = "Optional initial members (user/service-principal object IDs) of the AKS developers group."
  type        = list(string)
  default     = []
}
