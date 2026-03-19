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
      location = "northeurope"
    }
  }
}

module "postgresql" {
  source  = "cloudnationhq/psql/azure"
  version = "~> 5.0"

  instance = {
    name                = module.naming.postgresql_server.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

module "backup_vault" {
  source = "../../"

  config = {
    name                = module.naming.data_protection_backup_vault.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    redundancy          = "LocallyRedundant"

    identity = {
      type = "SystemAssigned"
    }

    role_assignments = {
      psql = {
        role_definition_name = "PostgreSQL Flexible Server Long Term Retention Backup Role"
        scope                = module.postgresql.server.id
      }
      reader = {
        role_definition_name = "Reader"
        scope                = module.rg.groups.demo.id
      }
    }
  }
}

module "policies" {
  source = "../../modules/policies"

  vault_name          = module.backup_vault.data_protection_backup_vault.name
  vault_id            = module.backup_vault.data_protection_backup_vault.id
  resource_group_name = module.rg.groups.demo.name
  location            = module.rg.groups.demo.location

  config = {
    postgresql_flexible_servers = {
      retention = {
        backup_repeating_time_intervals = ["R/2024-01-01T02:00:00+00:00/P1W"]

        default_retention_rule = {
          life_cycle = {
            vault = {
              data_store_type = "VaultStore"
              duration        = "P4M"
            }
          }
        }

        instances = {
          psql = {
            server_id = module.postgresql.server.id
          }
        }
      }
    }
  }

  depends_on = [module.backup_vault]
}
