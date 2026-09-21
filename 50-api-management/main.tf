locals {
  tags = merge(var.tags, { environment = var.environment })
  name = "${var.prefix}-${var.environment}"
}

resource "azurerm_resource_group" "apim" {
  name     = "rg-${local.name}-apim"
  location = var.location
  tags     = local.tags
}

resource "azurerm_network_security_group" "apim" {
  name                = "nsg-${local.name}-apim"
  location            = var.location
  resource_group_name = var.hub_network_resource_group_name
  tags                = local.tags

  security_rule {
    name                       = "AllowAzureKeyVaultOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "AzureKeyVault"
  }
}

resource "azurerm_subnet" "apim" {
  name                 = "snet-apim"
  resource_group_name  = var.hub_network_resource_group_name
  virtual_network_name = var.hub_virtual_network_name
  address_prefixes     = [var.apim_subnet_prefix]

  delegation {
    name = "apim-vnet-integration"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "apim" {
  subnet_id                 = azurerm_subnet.apim.id
  network_security_group_id = azurerm_network_security_group.apim.id
}

resource "azurerm_api_management" "apim" {
  name                = var.apim_name
  location            = azurerm_resource_group.apim.location
  resource_group_name = azurerm_resource_group.apim.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "StandardV2_${var.apim_capacity}"
  tags                = local.tags

  public_network_access_enabled = true
  virtual_network_type          = "External"

  identity {
    type = "SystemAssigned"
  }

  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }

  depends_on = [azurerm_subnet_network_security_group_association.apim]
}
