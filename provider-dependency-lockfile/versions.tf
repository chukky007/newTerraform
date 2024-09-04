# Terraform Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        # version = ">= 2.0"
        version = "1.44.0"
    }
    random = {
        source = "hashicorp/azurerm"
        version = ">= 3.0"
    }
  }
}

provider "azurerm" {
#   features {}
}