terraform {
  required_version = ">= 1.11, < 2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.81, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Bootstrap uses local state; it creates the remote-state backend itself.
  # After the first apply, run `terraform init -migrate-state` with backend.tf.
}

provider "azurerm" {
  features {}
  subscription_id = var.spoke_subscription_id
}
