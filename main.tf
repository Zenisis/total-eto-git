provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kartik" {
  name     = "kartik-resources"
  location = "West Europe"
}

resource "azurerm_virtual_network" "kartik" {
  name                = "kartik-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kartik.location
  resource_group_name = azurerm_resource_group.kartik.name
}

resource "azurerm_subnet" "kartik" {
  name                 = "internal-subnet"
  resource_group_name  = azurerm_resource_group.kartik.name
  virtual_network_name = azurerm_virtual_network.kartik.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "kartik-nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.kartik.location
  resource_group_name = azurerm_resource_group.kartik.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kartik.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_public_ip" "ip" {
  name                = "example-ip"
  location            = azurerm_resource_group.kartik.location
  resource_group_name = azurerm_resource_group.kartik.name
  allocation_method   = "Dynamic"
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.kartik.name
  location            = azurerm_resource_group.kartik.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.kartik-nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-21h2-pro"
    version   = "latest"
  }
}
