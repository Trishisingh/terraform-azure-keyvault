
output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "key_vault_name" {
  value = module.kv_default.key_vault_name
}
