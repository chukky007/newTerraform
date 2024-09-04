# Terraform Settings Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = ">= 2.0" # Optional but recommended in production
    }
  }
}

# Configure the Microsoft Provider
provider "azurerm" {
  features {}
  use_cli = true
}

# Create Resource Group
resource "azurerm_resource_group" "demo-test-lab-uks-rg-1" {
  location = "uksouth"
  name = "demo-test-lab-uks-rg-1"

  tags = {
    environment = "test"
    seqNum = 1
    costCode = "DAR-379"
    priority = 4
    runningPattern = "alwaysOn"
    release = "1"
    releaseUrl = ""
    platform = "terraform"
    infoUrl = ""
    owners = jsonencode({
        businessOwner = "coraekwuotu@sis.tv"
        technicalOwner = "coraekwuotu@sis.tv"
    })
    operatingTimes = "offTime"
  }
}