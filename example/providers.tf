terraform {
  backend "azurerm" {
    resource_group_name  = "tfstateresourcegroup"
    storage_account_name = "trishitfstate"
    container_name       = "tfstate"
    key                  = "devlatestnewkv.terraform.tfstate"
  }

}

provider "azurerm" {
  features {}
}
