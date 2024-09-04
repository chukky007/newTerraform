# Specify the Azure provider
provider "azurerm" {
  features {}
  use_cli = true  # If you're using Azure CLI for authentication
}

# Reference the existing Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = "demo-test-lab-uks-rg-1"  # Replace with your existing resource group name
}

# Create a Virtual Network in the existing Resource Group
resource "azurerm_virtual_network" "vnet" {
  name                = "chukaVnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

# Create a Subnet in the existing Resource Group
resource "azurerm_subnet" "subnet" {
  name                 = "chukaSubnet"
  resource_group_name  = data.azurerm_resource_group.existing_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Public IP for the Load Balancer
resource "azurerm_public_ip" "lb_public_ip" {
  name                = "chukaLbPublicIP"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a Load Balancer
resource "azurerm_lb" "lb" {
  name                = "chukaLoadBalancer"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

# Create Backend Address Pool for Load Balancer
resource "azurerm_lb_backend_address_pool" "lb_backend_pool" {
  name            = "chukaBackEndPool"
  loadbalancer_id = azurerm_lb.lb.id
}

# Create Health Probe for Load Balancer
resource "azurerm_lb_probe" "lb_probe" {
  name            = "chukaHealthProbe"
  loadbalancer_id = azurerm_lb.lb.id
  protocol        = "Tcp"
  port            = 80
}

# Create Load Balancer Rule to Distribute Traffic
resource "azurerm_lb_rule" "lb_rule" {
  name                           = "chukaLbRule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb_backend_pool.id]
  probe_id                       = azurerm_lb_probe.lb_probe.id
}

# Create Public IP for each VM
resource "azurerm_public_ip" "vm_public_ip" {
  count               = 2  # Change this to the number of VMs you want
  name                = "chukaVmPublicIP${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  allocation_method   = "Static"  # Static IP allocation for Standard SKU
  sku                 = "Standard"  # Standard SKU
}

# Create Network Interfaces for VMs
resource "azurerm_network_interface" "nic" {
  count               = 2  # Change this to the number of VMs you want
  name                = "chukaNIC${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip[count.index].id
  }
}

# Associate Network Interface with Load Balancer Backend Pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_association" {
  count                  = 2  # Match the number of VMs
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "internal"  # This matches the IP configuration name in the NIC
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend_pool.id
}

# Create Windows Virtual Machines
resource "azurerm_windows_virtual_machine" "vm" {
  count               = 2  # Change this to the number of VMs you want
  name                = "chukaVM${count.index}"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  size                = "Standard_DS1_v2"

  admin_username = "chukwuka"
  admin_password = "P@ssword1234!"

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}
