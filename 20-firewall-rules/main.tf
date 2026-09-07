locals {
  tags = merge(var.tags, { environment = var.environment })
  name = "${var.prefix}-${var.environment}"

  # AKS-required application (FQDN) endpoints.
  # Source: https://learn.microsoft.com/azure/aks/outbound-rules-control-egress
  aks_required_fqdns = [
    "*.hcp.${var.location}.azmk8s.io", # node <-> API server (konnectivity)
    "mcr.microsoft.com",
    "*.data.mcr.microsoft.com",
    "mcr-0001.mcr-msedge.net",
    "management.azure.com",
    "login.microsoftonline.com",
    "packages.microsoft.com",
    "acs-mirror.azureedge.net",
    "packages.aks.azure.com",
    "vault.azure.net", # Key Vault CSI driver
  ]

  # Container registries / image pulls.
  registry_fqdns = [
    "*.azurecr.io",
    "*.blob.core.windows.net", # image layers / managed disk internals
    "*.gcr.io",
    "*.docker.io",
    "quay.io",
    "*.quay.io",
    "*.cloudfront.net",
    "production.cloudflare.docker.com",
    "ghcr.io",
    "pkg-containers.githubusercontent.com",
  ]

  # Monitoring, Policy, Defender, cluster extensions.
  observability_fqdns = [
    "data.policy.core.windows.net",
    "store.policy.core.windows.net",
    "*.ods.opinsights.azure.com",
    "*.oms.opinsights.azure.com",
    "*.monitoring.azure.com",
    "dc.services.visualstudio.com",
    "global.handler.control.monitor.azure.com",
    "*.ingest.monitor.azure.com",
    "*.metrics.ingest.monitor.azure.com",
    "*.handler.control.monitor.azure.com",
    "*.dp.kubernetesconfiguration.azure.com",
    "arcmktplaceprod.azurecr.io",
    "*.data.azurecr.io",
    "*.ingestion.msftcloudes.com",
    "*.microsoftmetrics.com",
    "marketplaceapi.microsoft.com",
    "*.cloud.defender.microsoft.com",
    "*.in.applicationinsights.azure.com",
  ]

  # Optional but commonly needed tooling endpoints, plus caller-supplied extras.
  extra_tools_fqdns = concat([
    "grafana.net",
    "grafana.com",
    "github.com",
    "raw.githubusercontent.com",
    "charts.bitnami.com",
    "*.letsencrypt.org",
    "usage.projectcalico.org",
  ], var.extra_allowed_fqdns)
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

  # ----------------------- Application (FQDN) rules -----------------------
  application_rule_collection {
    name     = "aks-egress-application"
    priority = 200
    action   = "Allow"

    rule {
      name = "aks-fqdn-tag"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups      = [azurerm_ip_group.aks_egress.id]
      destination_fqdn_tags = ["AzureKubernetesService"]
    }

    rule {
      name = "aks-required"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups  = [azurerm_ip_group.aks_egress.id]
      destination_fqdns = local.aks_required_fqdns
    }

    rule {
      name = "registries"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups  = [azurerm_ip_group.aks_egress.id]
      destination_fqdns = local.registry_fqdns
    }

    rule {
      name = "observability"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups  = [azurerm_ip_group.aks_egress.id]
      destination_fqdns = local.observability_fqdns
    }

    rule {
      name = "extra-tools"
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups  = [azurerm_ip_group.aks_egress.id]
      destination_fqdns = local.extra_tools_fqdns
    }
  }

  application_rule_collection {
    name     = "aks-os-updates"
    priority = 210
    action   = "Allow"

    rule {
      name = "ubuntu-updates"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_ip_groups = [azurerm_ip_group.aks_egress.id]
      destination_fqdns = [
        "security.ubuntu.com",
        "azure.archive.ubuntu.com",
        "changelogs.ubuntu.com",
        "snapshot.ubuntu.com",
      ]
    }
  }

  # ----------------------------- Network rules ----------------------------
  network_rule_collection {
    name     = "aks-egress-network"
    priority = 300
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
      name                  = "azure-monitor"
      protocols             = ["TCP"]
      source_ip_groups      = [azurerm_ip_group.aks_egress.id]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }

    # NTP over FQDN avoids allowing UDP 123 to any address.
    # Requires DNS proxy enabled on the Azure Firewall policy.
    rule {
      name              = "ntp"
      protocols         = ["UDP"]
      source_ip_groups  = [azurerm_ip_group.aks_egress.id]
      destination_fqdns = ["ntp.ubuntu.com"]
      destination_ports = ["123"]
    }
  }
}
