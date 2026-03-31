locals {
  naming = {
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["key_vault_secret", "key_vault_certificate", "managed_disk"]
}
