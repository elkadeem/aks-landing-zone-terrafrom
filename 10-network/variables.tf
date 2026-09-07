variable "spoke_subscription_id" {
  description = "Subscription ID of the spoke (application landing zone) subscription."
  type        = string
}

variable "hub_subscription_id" {
  description = "Subscription ID of the hub / Azure landing zone subscription (firewall, hub VNet, private DNS zones)."
  type        = string
}

variable "location" {
  description = "Azure region for the spoke network."
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

variable "vnet_address_space" {
  description = "Address space for the spoke virtual network."
  type        = list(string)
  default     = ["10.116.12.0/22"]
}

variable "subnet_prefixes" {
  description = "Address prefixes for each spoke subnet."
  type = object({
    aks              = list(string)
    data             = list(string)
    privateendpoints = list(string)
    appgw            = list(string)
  })
  default = {
    aks              = ["10.116.12.0/24"]
    data             = ["10.116.13.0/25"]
    privateendpoints = ["10.116.13.128/25"]
    appgw            = ["10.116.14.0/24"]
  }
}

# ---- Hub / cross-subscription inputs ----

variable "hub_virtual_network_id" {
  description = "Resource ID of the hub virtual network to peer with."
  type        = string
}

variable "hub_virtual_network_name" {
  description = "Name of the hub virtual network (for the hub-side peering)."
  type        = string
}

variable "hub_network_resource_group_name" {
  description = "Resource group of the hub virtual network."
  type        = string
}

variable "hub_firewall_private_ip" {
  description = "Private IP address of the hub Azure Firewall; used as the UDR next hop for AKS egress."
  type        = string
}

variable "hub_private_dns_zones" {
  description = "Map of existing hub Private DNS zones to link to the spoke VNet. Key is arbitrary; value has the zone name and its resource group in the hub subscription."
  type = map(object({
    name                = string
    resource_group_name = string
  }))
  default = {
    acr = {
      name                = "privatelink.azurecr.io"
      resource_group_name = "rg-hub-dns"
    }
    blob = {
      name                = "privatelink.blob.core.windows.net"
      resource_group_name = "rg-hub-dns"
    }
    keyvault = {
      name                = "privatelink.vaultcore.azure.net"
      resource_group_name = "rg-hub-dns"
    }
  }
}

variable "use_remote_gateways" {
  description = "Whether the spoke uses the hub's gateway (set true only if the hub has a VPN/ER gateway configured for transit)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all spoke network resources."
  type        = map(string)
  default = {
    workload   = "aks-landing-zone"
    managed-by = "terraform"
  }
}
