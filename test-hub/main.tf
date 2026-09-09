locals {
  tags = merge(var.tags, { environment = var.environment })
  name = "${var.prefix}-${var.environment}"
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-${local.name}-hub"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${local.name}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_address_space
  tags                = local.tags
}

# Subnet name must be exactly "AzureFirewallSubnet".
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_prefix]
}

resource "azurerm_public_ip" "firewall" {
  name                = "pip-${local.name}-afw"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# DNS proxy is enabled so the firewall can resolve FQDN-based network rules
# (e.g. the ntp.ubuntu.com rule in 20-firewall-rules).
resource "azurerm_firewall_policy" "hub" {
  name                = "afwp-${local.name}-hub"
  resource_group_name = azurerm_resource_group.hub.name
  location            = azurerm_resource_group.hub.location
  sku                 = var.firewall_sku_tier
  tags                = local.tags

  dns {
    proxy_enabled = true
  }
}

resource "azurerm_firewall" "hub" {
  name                = "afw-${local.name}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.firewall_sku_tier
  firewall_policy_id  = azurerm_firewall_policy.hub.id
  tags                = local.tags

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# Private DNS zones for the spoke private endpoints (linked to the spoke VNet
# by the 10-network stack).
resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.private_dns_zone_names)
  name                = each.value
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.tags
}
