variable "spoke_subscription_id" {
  description = "Subscription ID of the spoke (application landing zone) subscription."
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster."
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

# ---- Remote state (00-bootstrap storage) ----

variable "state_resource_group_name" {
  description = "Resource group of the Terraform state storage account."
  type        = string
}

variable "state_storage_account_name" {
  description = "Name of the Terraform state storage account."
  type        = string
}

variable "state_container_name" {
  description = "Blob container holding the state files."
  type        = string
  default     = "tfstate"
}

# ---- Cluster settings ----

variable "kubernetes_version" {
  description = "Kubernetes version (major.minor). Null lets AKS pick the default GA version."
  type        = string
  default     = null
}

variable "private_dns_zone_mode" {
  description = "Private DNS zone for the API server: 'system' (AKS-managed) or 'none', or a BYO zone resource ID."
  type        = string
  default     = "system"
}

variable "enable_private_cluster_public_fqdn" {
  description = "Also expose a public FQDN for the private cluster (handy for CI reaching the API server). Keep false for strict private."
  type        = bool
  default     = false
}

variable "admin_group_object_ids" {
  description = "Entra group object IDs granted cluster-admin via Azure RBAC for Kubernetes."
  type        = list(string)
  default     = []
}

# ---- Networking (overlay) ----

variable "pod_cidr" {
  description = "Overlay pod CIDR (not routable in the VNet)."
  type        = string
  default     = "10.244.0.0/16"
}

variable "service_cidr" {
  description = "Kubernetes service CIDR (must not overlap the VNet)."
  type        = string
  default     = "10.245.0.0/24"
}

variable "dns_service_ip" {
  description = "Cluster DNS service IP (within service_cidr)."
  type        = string
  default     = "10.245.0.10"
}

# ---- Node pools ----

variable "system_node_vm_size" {
  description = "VM size for the system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "system_node_min" {
  description = "System pool minimum node count."
  type        = number
  default     = 2
}

variable "system_node_max" {
  description = "System pool maximum node count."
  type        = number
  default     = 3
}

variable "user_node_vm_size" {
  description = "VM size for the user (workload) node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "user_node_min" {
  description = "User pool minimum node count."
  type        = number
  default     = 2
}

variable "user_node_max" {
  description = "User pool maximum node count."
  type        = number
  default     = 5
}

variable "availability_zones" {
  description = "Availability zones for the node pools."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "tags" {
  description = "Tags applied to the AKS resources."
  type        = map(string)
  default = {
    workload   = "aks-landing-zone"
    managed-by = "terraform"
  }
}
