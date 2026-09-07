locals {
  tags = merge(var.tags, { environment = var.environment })
  name = "${var.prefix}-${var.environment}"
}

# IP Group holding the AKS egress sources. Membership can be updated here
# (var.aks_egress_source_cidrs) without changing any firewall rule.
resource "azurerm_ip_group" "aks_egress" {
  provider            = azurerm.hub
  name                = "ipg-${local.name}-aks-egress"
  location            = var.location
  resource_group_name = var.ip_group_resource_group_name
  cidrs               = var.aks_egress_source_cidrs
  tags                = local.tags
}

# Rule collection group appended to the EXISTING hub firewall policy.
# Covers the AKS-required egress (see:
# https://learn.microsoft.com/azure/aks/outbound-rules-control-egress).
resource "azurerm_firewall_policy_rule_collection_group" "aks_egress" {
  provider           = azurerm.hub
  name               = "rcg-${local.name}-aks-egress"
  firewall_policy_id = var.firewall_policy_id
  priority           = var.rule_collection_group_priority

  application_rule_collection {
    name     = "aks-egress-fqdn"
    priority = 200
    action   = "Allow"

    rule {
      name = "aks-required-fqdn-tag"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_ip_groups      = [azurerm_ip_group.aks_egress.id]
      destination_fqdn_tags = ["AzureKubernetesService"]
    }
  }

  network_rule_collection {
    name     = "aks-egress-network"
    priority = 210
    action   = "Allow"

    rule {
      name                  = "aks-api-udp-tunnel"
      protocols             = ["UDP"]
      source_ip_groups      = [azurerm_ip_group.aks_egress.id]
      destination_addresses = ["AzureCloud.${var.location}"]
      destination_ports     = ["1194"]
    }

    rule {
      name                  = "aks-api-tcp-tunnel"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.aks_egress.id]
      destination_addresses = ["AzureCloud.${var.location}"]
      destination_ports     = ["9000"]
    }

    rule {
      name                  = "dns"
      protocols             = ["UDP", "TCP"]
      source_ip_groups      = [azurerm_ip_group.aks_egress.id]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
    }

    rule {
      name                  = "ntp"
      protocols             = ["UDP"]
      source_ip_groups      = [azurerm_ip_group.aks_egress.id]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
    }
  }
}
