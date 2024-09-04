# Create a resource group in uksouth region - Uses default provider
resource "azurerm_resource_group" "chuka-terraform" {
  name = "chuka-terraform"
  location = "UKsouth"
}

# Create resource group in West Europe region - uses "provider2 - West Europe" provider
resource "azurerm_resource_group" "chuka-terraform-2" {
  name = "chuka-terraform-2"
  location = "WestEurope"
  provider = azurerm.provider2-westEuope
}
