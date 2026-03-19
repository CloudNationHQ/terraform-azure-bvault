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
      location = "westeurope"
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 4.0"

  storage = {
    name                = module.naming.storage_account.name_unique
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
      storage = {
        role_definition_name = "Storage Account Backup Contributor"
        scope                = module.storage.account.id
      }
    }
  }
}

module "policies" {
  source = "../../modules/policies"

  vault_id            = module.backup_vault.data_protection_backup_vault.id
  vault_name          = module.backup_vault.data_protection_backup_vault.name
  resource_group_name = module.rg.groups.demo.name
  location            = module.rg.groups.demo.location

  config = {
    blob_storages = {
      retention = {
        operational_default_retention_duration = "P30D"

        instances = {
          storage = {
            storage_account_id = module.storage.account.id
          }
        }
      }
    }
  }

  depends_on = [module.backup_vault]
}
