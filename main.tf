
# Configure data to access the SPN that has been used to deploy the environment
data "azurerm_client_config" "current" {
}


resource "azurerm_key_vault" "example" {
  count                           = var.create_kv ? 1 : 0
  name                            = var.resource_namer
  location                        = var.resource_group_location
  resource_group_name             = var.resource_group_name
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  enabled_for_template_deployment = var.enabled_for_template_deployment
  enable_rbac_authorization       = var.enable_rbac_authorization
  sku_name                        = var.sku_name
  public_network_access_enabled   = var.public_network_access_enabled

  dynamic "network_acls" {
    for_each = var.create_kv_networkacl == false ? toset([]) : toset([1])
    content {
      bypass                     = var.network_acls_bypass
      default_action             = var.network_acl_default_action
      ip_rules                   = var.network_acls_ip_rules
      virtual_network_subnet_ids = var.virtual_network_subnet_ids
    }


  }


  tags = var.resource_tags
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}


resource "azurerm_key_vault_access_policy" "contributors_access_policy" {
  count = length(var.contributor_object_ids)

  key_vault_id = azurerm_key_vault.example.0.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.contributor_object_ids[count.index]

  key_permissions = [
    "Get",
    "List",
    "Delete",
    "Create",
    "Update",
    "Import",
    "Backup",
    "Recover",
    "Restore"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Delete",
    "Set",
    "Backup",
    "Recover",
    "Restore"
  ]

  certificate_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Backup",
    "Recover",
    "Restore"
  ]

  storage_permissions = []
}

resource "azurerm_key_vault_access_policy" "reader_access_policy" {
  count = length(var.reader_object_ids)

  key_vault_id = azurerm_key_vault.example.0.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = var.reader_object_ids[count.index]

  key_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]

  certificate_permissions = [
    "Get",
    "GetIssuers",
    "List",
    "ListIssuers"
  ]
}

resource "azurerm_private_endpoint" "pe" {
  count               = var.enable_private_network ? 1 : 0
  name                = "${azurerm_key_vault.example[0].name}-kv-pe"
  resource_group_name = var.pe_resource_group_name
  location            = var.pe_resource_group_location
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${azurerm_key_vault.example[0].name}-kv-pe"
    is_manual_connection           = var.is_manual_connection
    private_connection_resource_id = azurerm_key_vault.example[0].id
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = azurerm_key_vault.example.0.name
    private_dns_zone_ids = [data.azurerm_private_dns_zone.kv_pvt_dns[0].id]
  }
}
