<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)

## Resources

The following resources are used by this module:

- [azurerm_data_protection_backup_instance_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_blob_storage) (resource)
- [azurerm_data_protection_backup_instance_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_disk) (resource)
- [azurerm_data_protection_backup_instance_postgresql.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql) (resource)
- [azurerm_data_protection_backup_instance_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_instance_postgresql_flexible_server) (resource)
- [azurerm_data_protection_backup_policy_blob_storage.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_blob_storage) (resource)
- [azurerm_data_protection_backup_policy_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_disk) (resource)
- [azurerm_data_protection_backup_policy_postgresql.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_postgresql) (resource)
- [azurerm_data_protection_backup_policy_postgresql_flexible_server.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_policy_postgresql_flexible_server) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: n/a

Type:

```hcl
object({
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
```

### <a name="input_location"></a> [location](#input\_location)

Description: n/a

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: n/a

Type: `string`

### <a name="input_vault_id"></a> [vault\_id](#input\_vault\_id)

Description: n/a

Type: `string`

### <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name)

Description: n/a

Type: `string`

## Optional Inputs

No optional inputs.

## Outputs

The following outputs are exported:

### <a name="output_blob_storages"></a> [blob\_storages](#output\_blob\_storages)

Description: contains all exported attributes of the blob storage backup policies

### <a name="output_disks"></a> [disks](#output\_disks)

Description: contains all exported attributes of the disk backup policies

### <a name="output_instance_blob_storages"></a> [instance\_blob\_storages](#output\_instance\_blob\_storages)

Description: contains all exported attributes of the blob storage backup instances

### <a name="output_instance_disks"></a> [instance\_disks](#output\_instance\_disks)

Description: contains all exported attributes of the disk backup instances

### <a name="output_instance_postgresql_flexible_servers"></a> [instance\_postgresql\_flexible\_servers](#output\_instance\_postgresql\_flexible\_servers)

Description: contains all exported attributes of the postgresql flexible server backup instances

### <a name="output_instance_postgresqls"></a> [instance\_postgresqls](#output\_instance\_postgresqls)

Description: contains all exported attributes of the postgresql backup instances

### <a name="output_postgresql_flexible_servers"></a> [postgresql\_flexible\_servers](#output\_postgresql\_flexible\_servers)

Description: contains all exported attributes of the postgresql flexible server backup policies

### <a name="output_postgresqls"></a> [postgresqls](#output\_postgresqls)

Description: contains all exported attributes of the postgresql backup policies
<!-- END_TF_DOCS -->