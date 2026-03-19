variable "config" {
  type = object({
    blob_storages = optional(map(object({
      name                                   = optional(string)
      backup_repeating_time_intervals        = optional(list(string))
      operational_default_retention_duration = optional(string)
      time_zone                              = optional(string)
      vault_default_retention_duration       = optional(string)
      retention_rule = optional(map(object({
        name     = optional(string)
        priority = number
        criteria = object({
          absolute_criteria      = optional(string)
          days_of_month          = optional(set(number))
          days_of_week           = optional(set(string))
          months_of_year         = optional(set(string))
          scheduled_backup_times = optional(set(string))
          weeks_of_month         = optional(set(string))
        })
        life_cycle = object({
          data_store_type = string
          duration        = string
        })
      })))
      instances = optional(map(object({
        name                            = optional(string)
        storage_account_id              = string
        storage_account_container_names = optional(list(string))
      })), {})
    })), {})
    disks = optional(map(object({
      name                            = optional(string)
      backup_repeating_time_intervals = list(string)
      default_retention_duration      = string
      time_zone                       = optional(string)
      retention_rule = optional(map(object({
        name     = optional(string)
        duration = string
        priority = number
        criteria = object({
          absolute_criteria = optional(string)
        })
      })))
      instances = optional(map(object({
        name                         = optional(string)
        disk_id                      = string
        snapshot_resource_group_name = string
        snapshot_subscription_id     = optional(string)
      })), {})
    })), {})
    postgresqls = optional(map(object({
      name                            = optional(string)
      backup_repeating_time_intervals = list(string)
      default_retention_duration      = string
      time_zone                       = optional(string)
      retention_rule = optional(map(object({
        name     = optional(string)
        duration = string
        priority = number
        criteria = object({
          absolute_criteria      = optional(string)
          days_of_week           = optional(set(string))
          months_of_year         = optional(set(string))
          scheduled_backup_times = optional(set(string))
          weeks_of_month         = optional(set(string))
        })
      })))
      instances = optional(map(object({
        name                                    = optional(string)
        database_id                             = string
        database_credential_key_vault_secret_id = optional(string)
      })), {})
    })), {})
    postgresql_flexible_servers = optional(map(object({
      name                            = optional(string)
      backup_repeating_time_intervals = list(string)
      time_zone                       = optional(string)
      default_retention_rule = object({
        life_cycle = map(object({
          data_store_type = string
          duration        = string
        }))
      })
      retention_rule = optional(map(object({
        name     = optional(string)
        priority = number
        criteria = object({
          absolute_criteria      = optional(string)
          days_of_week           = optional(set(string))
          months_of_year         = optional(set(string))
          scheduled_backup_times = optional(set(string))
          weeks_of_month         = optional(set(string))
        })
        life_cycle = map(object({
          data_store_type = string
          duration        = string
        }))
      })))
      instances = optional(map(object({
        name      = optional(string)
        server_id = string
      })), {})
    })), {})
  })
}

variable "vault_id" {
  type = string
}

variable "vault_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}
