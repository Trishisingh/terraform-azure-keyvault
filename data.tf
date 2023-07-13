data "azurerm_private_dns_zone" "kv_pvt_dns" {
  count               = var.enable_private_network ? 1 : 0
  name                = var.private_dns_zone_name
  resource_group_name = var.dns_resource_group_name
}
