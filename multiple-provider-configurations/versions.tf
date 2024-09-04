terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 2.0"
    }
  }
}

# Provider for UKSouth (Default Provider)
provider "azurerm" {
  features {}
  use_cli = true
}

# Provider-2 for WestEurope

provider "azurerm" {
  features {
    virtual_machine {
        delete_os_disk_on_deletion = false
    }
  }
  alias = "provider2-westEuope"
}