variable "config" {
  type = object({
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

  validation {
    condition     = var.config.location != null || var.location != null
    error_message = "location must be provided either in the config object or as a separate variable."
  }

  validation {
    condition     = var.config.resource_group_name != null || var.resource_group_name != null
    error_message = "resource group name must be provided either in the config object or as a separate variable."
  }
}

variable "naming" {
  description = "contains naming convention"
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
