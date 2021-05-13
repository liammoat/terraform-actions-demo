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
    key                  = "05-vm-deploy.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Define local variables
locals {
  prefix = "hello-network"

  tags = {
    owner = "terraform"
    demo  = "05-vm-deploy"
  }
}

# Create a resource group
resource "azurerm_resource_group" "default" {
  name     = "${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

# Reference state from hello-network deployment
data "terraform_remote_state" "hello_network" {
  backend = "azurerm"

  config = {
    resource_group_name  = "lm-devops-rg"
    storage_account_name = "lmdevopssa"
    container_name       = "terraform-actions-demo"
    key                  = "01-hello-network.tfstate"
  }
}

# Create a network interface
resource "azurerm_network_interface" "default" {
  name                = "${local.prefix}-nic"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.hello_network.outputs.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a Linux VM resource
resource "azurerm_linux_virtual_machine" "default" {
  name                = "${local.prefix}-vm"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = var.admin_password
  
  network_interface_ids = [
    azurerm_network_interface.default.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}