output "recovery_vault_name" {
  description = "Nome do Recovery Services Vault"
  value       = azurerm_recovery_services_vault.main.name
}

output "recovery_vault_id" {
  description = "ID do Recovery Services Vault"
  value       = azurerm_recovery_services_vault.main.id
}

output "backup_policy_name" {
  description = "Nome da política de backup"
  value       = azurerm_backup_policy_file_share.main.name
}