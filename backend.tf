terraform {
  backend "azurerm" {
    resource_group_name  = "rg-dev"       # Pre-created RG for state files
    storage_account_name = "storacctdev123"     # Pre-created Storage Account
    container_name       = "tfstate"          # Container for state files
    key                  = "prod.terraform.tfstate"  # Dynamically set in pipeline
  }
}