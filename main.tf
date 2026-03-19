data "azurerm_client_config" "current" {}

resource "azurerm_data_protection_backup_vault" "this" {
  resource_group_name = coalesce(
    lookup(
      var.config, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.config, "location", null
    ), var.location
  )

  tags = coalesce(
    var.config.tags, var.tags
  )

  cross_region_restore_enabled = var.config.cross_region_restore_enabled
  datastore_type               = var.config.datastore_type
  immutability                 = var.config.immutability
  name                         = var.config.name
  redundancy                   = var.config.redundancy
  retention_duration_in_days   = var.config.retention_duration_in_days
  soft_delete                  = var.config.soft_delete

  dynamic "identity" {
    for_each = var.config.identity != null ? [var.config.identity] : []

    content {
      identity_ids = identity.value.identity_ids
      type         = identity.value.type
    }
  }
}

resource "azurerm_role_assignment" "this" {
  for_each = var.config.role_assignments

  scope                                  = each.value.scope
  role_definition_name                   = each.value.role_definition_name
  role_definition_id                     = each.value.role_definition_id
  name                                   = each.value.name
  description                            = each.value.description
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
  principal_type                         = each.value.principal_type

  principal_id = coalesce(
    each.value.principal_id,
    try(
      azurerm_data_protection_backup_vault.this.identity[0].principal_id, null
    ), data.azurerm_client_config.current.object_id
  )
}
