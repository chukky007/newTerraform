# Resource-1: Azure resource group
resource "azurerm_resource_group" "chuka-1" {
  name = "chuka-1"
  location = "uksouth"
}

# Resource-2: Random string
resource "random_string" "myrandom" {
  length     = 16
  special    = false
  upper      = false
}

# resource-3: Azure storage account
resource "azurerm_storage_account" "chusa" {
  name = "chusa${random_string.myrandom.id}"
  resource_group_name = azurerm_resource_group.chuka-1.name
  location = azurerm_resource_group.chuka-1.location
  account_tier = "standard"
  account_replication_type = "GRS"

  tags = {
    environment = "development"
  }
}