terraform {
  required_version = ">= 1.11, < 2.0"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

# Uses the ambient Azure CLI / login context. The identity needs directory
# permissions to create security groups (e.g. Groups Administrator).
provider "azuread" {}
