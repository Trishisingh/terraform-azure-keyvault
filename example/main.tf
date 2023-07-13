data "azurerm_client_config" "current" {}

module "default_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.25.0"
  namespace  = "${var.name_company}-${var.name_project}"
  stage      = var.stage
  name       = "${lookup(var.location_name_map, var.resource_group_location, "uksouth")}-${var.name_component}"
  attributes = var.attributes
  delimiter  = "-"
  tags       = var.tags
}

##################################################
# ResourceGroups
##################################################

resource "azurerm_resource_group" "default" {
  name     = module.default_label.id
  location = var.resource_group_location
  tags     = var.tags
}

module "kv_default" {
  source                    = "../../azurerm-kv"
    resource_namer             = substr(replace(module.default_label.id, "-", ""), 0, 24)
  resource_group_name        = azurerm_resource_group.default.name
  resource_group_location    = azurerm_resource_group.default.location
  create_kv_networkacl       = false
  enable_rbac_authorization  = false
  resource_tags              = module.default_label.tags
  contributor_object_ids     = concat(var.contributor_object_ids, [data.azurerm_client_config.current.object_id])
  enable_private_network     = true
  pe_subnet_id               = data.azurerm_subnet.pe_subnet.id
  pe_resource_group_name     = data.azurerm_subnet.pe_subnet.resource_group_name
  pe_resource_group_location = "UK South"
 # private_dns_zone_name      = data.azurerm_private_dns_zone.private_dns.name
 # private_dns_zone_ids       = ["${data.azurerm_private_dns_zone.private_dns.id}"]
  dns_resource_group_name = "hub-rg"
}
