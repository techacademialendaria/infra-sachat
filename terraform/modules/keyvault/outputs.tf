output "key_vault_id" {
  description = "ID do Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI do Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "cosmosdb_key_id" {
  description = "ID da chave de encriptação do CosmosDB"
  value       = azurerm_key_vault_key.cosmosdb.id
}

output "storage_encryption_key_name" {
  description = "Nome da chave de encriptação do storage"
  value       = azurerm_key_vault_key.storage.name
}

output "storage_encryption_key_id" {
  description = "ID da chave de encriptação do storage"
  value       = azurerm_key_vault_key.storage.id
}
