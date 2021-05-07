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
    key                  = "02-pr-workflow.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Define local variables
locals {
  prefix = "pr-workflow"

  tags = {
    owner = "terraform"
    demo  = "02-pr-workflow"
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
