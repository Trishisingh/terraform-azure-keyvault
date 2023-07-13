
data "azurerm_subnet" "pe_subnet" {
  name                 = "subnet2"
  virtual_network_name = "network2"
  resource_group_name  = "spoke1-rg"
}
