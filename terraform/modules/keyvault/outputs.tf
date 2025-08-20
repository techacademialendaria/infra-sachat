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
