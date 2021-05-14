# Configure Terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "lm-devops-rg"
    storage_account_name = "lmdevopssa"
    container_name       = "terraform-actions-demo"
    key                  = "03-workspaces.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Define local variables
locals {
  prefix = "workspaces"

  tags = {
    owner = "terraform"
    demo  = "03-workspaces"
  }
}

# Create a resource group
resource "azurerm_resource_group" "default" {
  name     = "${local.prefix}-rg-${terraform.workspace}"
  location = var.location
  tags     = local.tags
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "default" {
  name                = "${local.prefix}-vnet-${terraform.workspace}"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_network_security_group" "default" {
  name                = "defaultnsg"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags
}