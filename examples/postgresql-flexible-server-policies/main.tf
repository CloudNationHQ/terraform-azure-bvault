module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.26"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "swedencentral"
    }
  }
}

module "postgresql" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 5.0"

  instance = {
    name                = module.naming.postgresql_flexible_server.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "backup_vault" {
  source  = "cloudnationhq/bvault/azure"
  version = "~> 2.0"

  config = {
    name                = module.naming.data_protection_backup_vault.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    datastore_type      = "VaultStore"
    redundancy          = "LocallyRedundant"
    soft_delete         = "Off"

    identity = {
      type = "SystemAssigned"
    }

    role_assignments = {
      backup = {
        role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
        scope                = module.postgresql.server.id
      }
      reader = {
        role_definition_name = "Reader"
        scope                = module.rg.groups.demo.id
      }
    }

    policies = local.policies
  }
}
