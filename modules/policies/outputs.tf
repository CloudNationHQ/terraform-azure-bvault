output "blob_storages" {
  description = "contains all exported attributes of the blob storage backup policies"
  value       = azurerm_data_protection_backup_policy_blob_storage.this
}

output "instance_blob_storages" {
  description = "contains all exported attributes of the blob storage backup instances"
  value       = azurerm_data_protection_backup_instance_blob_storage.this
}

output "disks" {
  description = "contains all exported attributes of the disk backup policies"
  value       = azurerm_data_protection_backup_policy_disk.this
}

output "instance_disks" {
  description = "contains all exported attributes of the disk backup instances"
  value       = azurerm_data_protection_backup_instance_disk.this
}

output "postgresqls" {
  description = "contains all exported attributes of the postgresql backup policies"
  value       = azurerm_data_protection_backup_policy_postgresql.this
}

output "instance_postgresqls" {
  description = "contains all exported attributes of the postgresql backup instances"
  value       = azurerm_data_protection_backup_instance_postgresql.this
}

output "postgresql_flexible_servers" {
  description = "contains all exported attributes of the postgresql flexible server backup policies"
  value       = azurerm_data_protection_backup_policy_postgresql_flexible_server.this
}

output "instance_postgresql_flexible_servers" {
  description = "contains all exported attributes of the postgresql flexible server backup instances"
  value       = azurerm_data_protection_backup_instance_postgresql_flexible_server.this
}
