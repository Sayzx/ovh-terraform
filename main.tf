terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  
  subscription_id = var.subscription_id
}

# ========================================
# INFRASTRUCTURE RÉSEAU
# ========================================

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "rg-main"
  location = var.azure_region
}

# Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-main"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet dans le VNet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-main"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ========================================
# GROUPE DE SÉCURITÉ (Network Security Group)
# ========================================

# Network Security Group pour SSH et HTTP
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Règle NSG pour SSH depuis anywhere (à restreindre en prod)
resource "azurerm_network_security_rule" "ssh" {
  name                        = "AllowSSH"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Règle NSG pour HTTP
resource "azurerm_network_security_rule" "http" {
  name                        = "AllowHTTP"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# ========================================
# INTERFACE RÉSEAU
# ========================================

# Network Interface Card
resource "azurerm_network_interface" "nic" {
  name                = "nic-main"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Association NSG à la NIC
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ========================================
# ADRESSE IP PUBLIQUE
# ========================================

# Public IP
resource "azurerm_public_ip" "pip" {
  name                = "pip-main"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# ========================================
# MACHINE VIRTUELLE
# ========================================

# VM Debian 12 avec 2 vCPU et 2GB RAM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "sayzx-vm-debian"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_B2s" # 2 vCPU, 4 GB RAM

  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "debian"
    offer     = "debian-12"
    sku       = "12"
    version   = "latest"
  }

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  tags = {
    Name = "sayzx-vm-debian"
  }
}

# ========================================
# OUTPUTS
# ========================================

output "instance_public_ip" {
  value       = azurerm_public_ip.pip.ip_address
  description = "IP publique de la VM Azure"
}

output "instance_id" {
  value       = azurerm_linux_virtual_machine.vm.id
  description = "ID de la VM Azure"
}

output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "Nom du Resource Group"
}