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

resource "azurerm_data_protection_backup_policy_blob_storage" "this" {
  for_each = lookup(
    var.config.policies, "blob_storages", {}
  )

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                               = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals        = each.value.backup_repeating_time_intervals
  operational_default_retention_duration = each.value.operational_default_retention_duration
  time_zone                              = each.value.time_zone
  vault_default_retention_duration       = each.value.vault_default_retention_duration

  dynamic "retention_rule" {
    for_each = each.value.retention_rule != null ? each.value.retention_rule : {}

    content {
      name     = coalesce(retention_rule.value.name, retention_rule.key)
      priority = retention_rule.value.priority

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? [retention_rule.value.criteria] : []

        content {
          absolute_criteria      = criteria.value.absolute_criteria
          days_of_month          = criteria.value.days_of_month
          days_of_week           = criteria.value.days_of_week
          months_of_year         = criteria.value.months_of_year
          scheduled_backup_times = criteria.value.scheduled_backup_times
          weeks_of_month         = criteria.value.weeks_of_month
        }
      }

      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle != null ? [retention_rule.value.life_cycle] : []

        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_blob_storage" "this" {
  for_each = merge([
    for parent_storages_key, parent_storages in lookup(var.config.policies, "blob_storages", {}) : {
      for child_storages_key, child_storages in lookup(parent_storages, "instances", {}) :
      "${parent_storages_key}.${child_storages_key}" => merge(child_storages, { parent_storages_key = parent_storages_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.this[each.value.parent_storages_key].id
  vault_id                        = azurerm_data_protection_backup_vault.this.id
  location                        = azurerm_data_protection_backup_vault.this.location
  storage_account_container_names = each.value.storage_account_container_names
  storage_account_id              = each.value.storage_account_id

  depends_on = [azurerm_role_assignment.this]
}

resource "azurerm_data_protection_backup_policy_disk" "this" {
  for_each = lookup(
    var.config.policies, "disks", {}
  )

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                        = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  default_retention_duration      = each.value.default_retention_duration
  time_zone                       = each.value.time_zone

  dynamic "retention_rule" {
    for_each = each.value.retention_rule != null ? each.value.retention_rule : {}

    content {
      duration = retention_rule.value.duration
      name     = coalesce(retention_rule.value.name, retention_rule.key)
      priority = retention_rule.value.priority

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? [retention_rule.value.criteria] : []

        content {
          absolute_criteria = criteria.value.absolute_criteria
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_disk" "this" {
  for_each = merge([
    for parent_disks_key, parent_disks in lookup(var.config.policies, "disks", {}) : {
      for child_disks_key, child_disks in lookup(parent_disks, "instances", {}) :
      "${parent_disks_key}.${child_disks_key}" => merge(child_disks, { parent_disks_key = parent_disks_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  backup_policy_id             = azurerm_data_protection_backup_policy_disk.this[each.value.parent_disks_key].id
  disk_id                      = each.value.disk_id
  vault_id                     = azurerm_data_protection_backup_vault.this.id
  location                     = azurerm_data_protection_backup_vault.this.location
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  snapshot_subscription_id     = each.value.snapshot_subscription_id

  depends_on = [azurerm_role_assignment.this]
}

resource "azurerm_data_protection_backup_policy_postgresql" "this" {
  for_each = lookup(
    var.config.policies, "postgresqls", {}
  )

  name = coalesce(
    each.value.name, each.key
  )

  vault_name                      = azurerm_data_protection_backup_vault.this.name
  resource_group_name             = azurerm_data_protection_backup_vault.this.resource_group_name
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  default_retention_duration      = each.value.default_retention_duration
  time_zone                       = each.value.time_zone

  dynamic "retention_rule" {
    for_each = each.value.retention_rule != null ? each.value.retention_rule : {}

    content {
      duration = retention_rule.value.duration
      name     = coalesce(retention_rule.value.name, retention_rule.key)
      priority = retention_rule.value.priority

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? [retention_rule.value.criteria] : []

        content {
          absolute_criteria      = criteria.value.absolute_criteria
          days_of_week           = criteria.value.days_of_week
          months_of_year         = criteria.value.months_of_year
          scheduled_backup_times = criteria.value.scheduled_backup_times
          weeks_of_month         = criteria.value.weeks_of_month
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_postgresql" "this" {
  for_each = merge([
    for parent_postgresqls_key, parent_postgresqls in lookup(var.config.policies, "postgresqls", {}) : {
      for child_postgresqls_key, child_postgresqls in lookup(parent_postgresqls, "instances", {}) :
      "${parent_postgresqls_key}.${child_postgresqls_key}" => merge(child_postgresqls, { parent_postgresqls_key = parent_postgresqls_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  backup_policy_id                        = azurerm_data_protection_backup_policy_postgresql.this[each.value.parent_postgresqls_key].id
  vault_id                                = azurerm_data_protection_backup_vault.this.id
  location                                = azurerm_data_protection_backup_vault.this.location
  database_credential_key_vault_secret_id = each.value.database_credential_key_vault_secret_id
  database_id                             = each.value.database_id

  depends_on = [azurerm_role_assignment.this]
}

resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "this" {
  for_each = lookup(
    var.config.policies, "postgresql_flexible_servers", {}
  )

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                        = azurerm_data_protection_backup_vault.this.id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  time_zone                       = each.value.time_zone

  dynamic "default_retention_rule" {
    for_each = each.value.default_retention_rule != null ? [each.value.default_retention_rule] : []

    content {
      dynamic "life_cycle" {
        for_each = default_retention_rule.value.life_cycle != null ? default_retention_rule.value.life_cycle : {}

        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }

  dynamic "retention_rule" {
    for_each = each.value.retention_rule != null ? each.value.retention_rule : {}

    content {
      name = coalesce(
        retention_rule.value.name, retention_rule.key
      )

      priority = retention_rule.value.priority

      dynamic "criteria" {
        for_each = retention_rule.value.criteria != null ? [retention_rule.value.criteria] : []

        content {
          absolute_criteria      = criteria.value.absolute_criteria
          days_of_week           = criteria.value.days_of_week
          months_of_year         = criteria.value.months_of_year
          scheduled_backup_times = criteria.value.scheduled_backup_times
          weeks_of_month         = criteria.value.weeks_of_month
        }
      }

      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle != null ? retention_rule.value.life_cycle : {}

        content {
          data_store_type = life_cycle.value.data_store_type
          duration        = life_cycle.value.duration
        }
      }
    }
  }
}

resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "this" {
  for_each = merge([
    for parent_servers_key, parent_servers in lookup(var.config.policies, "postgresql_flexible_servers", {}) : {
      for child_servers_key, child_servers in lookup(parent_servers, "instances", {}) :
      "${parent_servers_key}.${child_servers_key}" => merge(child_servers, { parent_servers_key = parent_servers_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.this[each.value.parent_servers_key].id
  server_id        = each.value.server_id
  vault_id         = azurerm_data_protection_backup_vault.this.id
  location         = azurerm_data_protection_backup_vault.this.location

  depends_on = [azurerm_role_assignment.this]
}

resource "azurerm_role_assignment" "this" {
  for_each = lookup(
    var.config, "role_assignments", {}
  )

  scope = coalesce(
    each.value.scope, azurerm_data_protection_backup_vault.this.id
  )

  principal_id = coalesce(
    each.value.principal_id, try(azurerm_data_protection_backup_vault.this.identity[0].principal_id, data.azurerm_client_config.current.object_id)
  )

  role_definition_name = each.value.role_definition_name
}
