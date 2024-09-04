provider "azurerm" {
  features {}
}

# Reference to Existing Azure resource group
data "azurerm_resource_group" "demo-test-lab-uks-rg-1" {
  name = "demo-test-lab-uks-rg-1"
}

# Virtual Network
resource "azurerm_virtual_network" "aks_new_vnet" {
  name = "aks-new-vnet"
  address_space = [ "10.1.0.0/16" ]
  location = data.azurerm_resource_group.demo-test-lab-uks-rg-1.location
  resource_group_name = data.azurerm_resource_group.demo-test-lab-uks-rg-1.name
}

# Subnet
resource "azurerm_subnet" "aks_new_subnet" {
  name = "aks-new-subnet"
  resource_group_name = data.azurerm_resource_group.demo-test-lab-uks-rg-1.name
  virtual_network_name = azurerm_virtual_network.aks_new_vnet.name
  address_prefixes = [ "10.1.0.0/24" ]

  # Required for AKS
#   delegation {
#     name = "aks-delegation"
#     service_delegation {
#       name = "Microsoft.ContainerService/managedClusters"
#       actions = [ 
#         "Microsoft.Network/virtualNetworks/subnets/join/action"
#        ]
#     }
#   }
}

# Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks_identity" {
  name = "aks-identity"
  resource_group_name = data.azurerm_resource_group.demo-test-lab-uks-rg-1.name
  location = data.azurerm_resource_group.demo-test-lab-uks-rg-1.location
}

# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "aks_log_analytics" {
  name = "aks-log-analytics"
  location = data.azurerm_resource_group.demo-test-lab-uks-rg-1.location
  resource_group_name = data.azurerm_resource_group.demo-test-lab-uks-rg-1.name
  sku = "PerGB2018"
  retention_in_days = 30
}

# AKS cluster
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name = "aks-cluster"
  location = data.azurerm_resource_group.demo-test-lab-uks-rg-1.location
  resource_group_name = data.azurerm_resource_group.demo-test-lab-uks-rg-1.name
  dns_prefix = "akscluster"

  default_node_pool {
    name = "default"
    node_count = 3
    vm_size = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks_new_subnet.id
  }

  identity {
    type = "UserAssigned"
    identity_ids = [ azurerm_user_assigned_identity.aks_identity.id ]
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
    outbound_type = "loadBalancer"
  }
  
  azure_active_directory_role_based_access_control {
    admin_group_object_ids = [ "74e06b24-3114-4d29-91ba-1535050839fb" ]
  }

  kubernetes_version = "1.29.0"
  node_resource_group = "aks-nodes-rg"
}

# Output the AKS Cluster Name
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

# Output Managed Identity
output "aks_managed_id" {
  value = azurerm_user_assigned_identity.aks_identity.id
}



# # Managed Identity for AKS
# resource "azurerm_log_analytics_workspace" "aks_log_analytics" {
#   name = "aks-log-analytics"
#   location = data.azurerm_resource_group.demo-test-lab-uks-rg-1.location
#   resource_group_name = data.azurerm_resource_group.demo-test-lab-uks-rg-1.name
#   sku = "perGB2018"
#   retention_in_days = 30
# }

# # AKS Cluster
# resource "azurerm_kubernetes_cluster" "chuka_cluster-1" {
#   name = "chuka-cluster-1"
#   location = data.azurerm_resource_group.demo-test-lab-uks-rg-1.location
#   resource_group_name = data.azurerm_resource_group.demo-test-lab-uks-rg-1.name
#   dns_prefix = "chukacluster"

#   default_node_pool {
#     name = "chukapool"
#     node_count = 3
#     vm_size = "Standard_DS2_v2"
#     vnet_subnet_id = azurerm_subnet.aks_subnet.id
#   }
# }

