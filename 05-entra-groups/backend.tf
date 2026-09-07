# Remote state for this stack lives in the storage account created by 00-bootstrap.
#   terraform init -backend-config="resource_group_name=<rg>" \
#                  -backend-config="storage_account_name=<sa>" \
#                  -backend-config="container_name=tfstate"
terraform {
  backend "azurerm" {
    key = "05-entra-groups.tfstate"
    # resource_group_name  = "rg-example-dev-tfstate"
    # storage_account_name = "st<...>"
    # container_name       = "tfstate"
    use_azuread_auth = true
  }
}
