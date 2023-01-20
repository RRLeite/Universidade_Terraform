
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

//Criando um resource group - o "Exemple é o nome do RG dentro do Terraform"
resource "azurerm_resource_group" "RG" {
  name     = "rg-UniversidadeTerraform"
  location = "East US"
}

// Crianddo a VNET - Example é o nome do recurso no terraforms, o Name é o nome do recurso que irá para o azure

resource "azurerm_virtual_network" "VNET" {
  name                = "vnet-universidadeterraform"
  address_space       = ["10.240.0.0/16"]
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
}

// Criando a Subnet - Não esquecer de botar o tipo do recurso, exemplo RG ou VNET

resource "azurerm_subnet" "SNET" {
  name                 = "snet-universidadeterraform"
  resource_group_name  = azurerm_resource_group.RG.name
  virtual_network_name = azurerm_virtual_network.VNET.name
  address_prefixes     = ["10.240.2.0/24"]
}

//Criando a NIC

resource "azurerm_network_interface" "NIC" {
  name                = "nic-universidadeterraform"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SNET.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "@#$%!"
}

resource "azurerm_linux_virtual_machine" "VM01" {
  name                = "vm01-universidadeterraform"
  resource_group_name = azurerm_resource_group.RG.name
  location            = azurerm_resource_group.RG.location
  admin_username = "adminuser"
  computer_name = "UniversidadeTerraform"
  admin_password = random_password.password.result
  size                = "Standard_B2s"
  network_interface_ids = [
    azurerm_network_interface.NIC.id,
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