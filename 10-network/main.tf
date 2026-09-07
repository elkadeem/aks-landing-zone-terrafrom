locals {
  tags = merge(var.tags, { environment = var.environment })
  name = "${var.prefix}-${var.environment}"
}

resource "azurerm_resource_group" "network" {
  name     = "rg-${local.name}-spoke-network"
  location = var.location
  tags     = local.tags
}

# ---------------------------------------------------------------------------
# Network security groups (one per subnet). Baseline rules only; default NSG
# rules already deny inbound internet. Add custom rules as workloads require.
# ---------------------------------------------------------------------------
module "nsg_aks" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${local.name}-aks"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

module "nsg_data" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${local.name}-data"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

module "nsg_pe" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${local.name}-pe"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

module "nsg_appgw" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.5.1"

  name                = "nsg-${local.name}-appgw"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags
}

# ---------------------------------------------------------------------------
# Route table: force AKS egress through the hub Azure Firewall (outbound type
# userDefinedRouting on the cluster relies on this default route).
# ---------------------------------------------------------------------------
module "route_table_aks" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.5.0"

  name                = "rt-${local.name}-aks"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  tags                = local.tags

  routes = {
    default_to_firewall = {
      name                   = "default-to-hub-firewall"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.hub_firewall_private_ip
    }
  }
}

# ---------------------------------------------------------------------------
# Spoke virtual network + subnets.
# ---------------------------------------------------------------------------
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.19.0"

  name          = "vnet-${local.name}-spoke"
  location      = azurerm_resource_group.network.location
  parent_id     = azurerm_resource_group.network.id
  address_space = var.vnet_address_space
  tags          = local.tags

  subnets = {
    aks = {
      name             = "snet-aks"
      address_prefixes = var.subnet_prefixes.aks
      network_security_group = {
        id = module.nsg_aks.resource_id
      }
      route_table = {
        id = module.route_table_aks.resource_id
      }
    }
    data = {
      name             = "snet-data"
      address_prefixes = var.subnet_prefixes.data
      network_security_group = {
        id = module.nsg_data.resource_id
      }
    }
    privateendpoints = {
      name             = "snet-private-endpoints"
      address_prefixes = var.subnet_prefixes.privateendpoints
      network_security_group = {
        id = module.nsg_pe.resource_id
      }
    }
    appgw = {
      name             = "snet-appgw"
      address_prefixes = var.subnet_prefixes.appgw
      network_security_group = {
        id = module.nsg_appgw.resource_id
      }
    }
  }
}

# ---------------------------------------------------------------------------
# VNet peering (both directions, cross-subscription).
# ---------------------------------------------------------------------------
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "peer-${local.name}-spoke-to-hub"
  resource_group_name          = azurerm_resource_group.network.name
  virtual_network_name         = module.vnet.name
  remote_virtual_network_id    = var.hub_virtual_network_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider                     = azurerm.hub
  name                         = "peer-hub-to-${local.name}-spoke"
  resource_group_name          = var.hub_network_resource_group_name
  virtual_network_name         = var.hub_virtual_network_name
  remote_virtual_network_id    = module.vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.use_remote_gateways
  use_remote_gateways          = false
}

# ---------------------------------------------------------------------------
# Link existing hub Private DNS zones to the spoke VNet so private endpoints
# resolve to private IPs from inside the spoke. Links are created in the hub
# subscription where the zones live.
# ---------------------------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each = var.hub_private_dns_zones
  provider = azurerm.hub

  name                  = "link-${local.name}-${each.key}"
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = module.vnet.resource_id
  registration_enabled  = false
  tags                  = local.tags
}
