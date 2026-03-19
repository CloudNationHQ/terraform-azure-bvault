resource "azurerm_data_protection_backup_policy_blob_storage" "this" {
  for_each = var.config.blob_storages

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                               = var.vault_id
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
    for policy_key, policy in var.config.blob_storages : {
      for instance_key, instance in policy.instances :
      "${policy_key}.${instance_key}" => merge(instance, { policy_key = policy_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  vault_id                        = var.vault_id
  location                        = var.location
  backup_policy_id                = azurerm_data_protection_backup_policy_blob_storage.this[each.value.policy_key].id
  storage_account_id              = each.value.storage_account_id
  storage_account_container_names = each.value.storage_account_container_names
}

resource "azurerm_data_protection_backup_policy_disk" "this" {
  for_each = var.config.disks

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                        = var.vault_id
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
    for policy_key, policy in var.config.disks : {
      for instance_key, instance in policy.instances :
      "${policy_key}.${instance_key}" => merge(instance, { policy_key = policy_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  vault_id                     = var.vault_id
  location                     = var.location
  backup_policy_id             = azurerm_data_protection_backup_policy_disk.this[each.value.policy_key].id
  disk_id                      = each.value.disk_id
  snapshot_resource_group_name = each.value.snapshot_resource_group_name
  snapshot_subscription_id     = each.value.snapshot_subscription_id
}

resource "azurerm_data_protection_backup_policy_postgresql" "this" {
  for_each = var.config.postgresqls

  name = coalesce(
    each.value.name, each.key
  )

  vault_name                      = var.vault_name
  resource_group_name             = var.resource_group_name
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
    for policy_key, policy in var.config.postgresqls : {
      for instance_key, instance in policy.instances :
      "${policy_key}.${instance_key}" => merge(instance, { policy_key = policy_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  vault_id                                = var.vault_id
  location                                = var.location
  backup_policy_id                        = azurerm_data_protection_backup_policy_postgresql.this[each.value.policy_key].id
  database_id                             = each.value.database_id
  database_credential_key_vault_secret_id = each.value.database_credential_key_vault_secret_id
}

resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "this" {
  for_each = var.config.postgresql_flexible_servers

  name = coalesce(
    each.value.name, each.key
  )

  vault_id                        = var.vault_id
  backup_repeating_time_intervals = each.value.backup_repeating_time_intervals
  time_zone                       = each.value.time_zone

  dynamic "default_retention_rule" {
    for_each = each.value.default_retention_rule != null ? [each.value.default_retention_rule] : []

    content {
      dynamic "life_cycle" {
        for_each = default_retention_rule.value.life_cycle

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

      dynamic "life_cycle" {
        for_each = retention_rule.value.life_cycle

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
    for policy_key, policy in var.config.postgresql_flexible_servers : {
      for instance_key, instance in policy.instances :
      "${policy_key}.${instance_key}" => merge(instance, { policy_key = policy_key })
    }
  ]...)

  name = coalesce(
    each.value.name, element(split(".", each.key), 1)
  )

  vault_id         = var.vault_id
  location         = var.location
  server_id        = each.value.server_id
  backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.this[each.value.policy_key].id
}
