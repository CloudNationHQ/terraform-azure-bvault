# Backup Vault

This terraform module simplifies the creation and management of azure data protection backup vaults, providing customizable options for backup policies, backup instances, and role-based access control, all managed through code.

## Features

Supports blob storage, disk, postgresql, and postgresql flexible server backup policies.

Enables backup instances with nested policy associations.

Utilization of terratest for robust validation.

Offers configurable retention rules and lifecycle management for backup policies.

Includes support for managed identity and role-based access control.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_data_protection_backup_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/data_protection_backup_vault) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: n/a

Type:

```hcl
object({
    name                         = string
    resource_group_name          = optional(string)
    location                     = optional(string)
    tags                         = optional(map(string))
    cross_region_restore_enabled = optional(bool)
    datastore_type               = optional(string, "VaultStore")
    immutability                 = optional(string)
    redundancy                   = string
    retention_duration_in_days   = optional(number)
    soft_delete                  = optional(string)
    identity = optional(object({
      identity_ids = optional(set(string))
      type         = string
    }))
    role_assignments = optional(map(object({
      role_definition_name                   = optional(string)
      role_definition_id                     = optional(string)
      scope                                  = string
      principal_id                           = optional(string)
      principal_type                         = optional(string)
      name                                   = optional(string)
      description                            = optional(string)
      condition                              = optional(string)
      condition_version                      = optional(string)
      delegated_managed_identity_resource_id = optional(string)
      skip_service_principal_aad_check       = optional(bool)
    })), {})
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_data_protection_backup_vault"></a> [data\_protection\_backup\_vault](#output\_data\_protection\_backup\_vault)

Description: contains all exported attributes of the data protection backup vault
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-bvault/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-bvault" />
</a>

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/terraform-azure-bvault/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/backup/backup-vault-overview)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/dataprotection/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/dataprotection)
