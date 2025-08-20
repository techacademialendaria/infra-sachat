output "storage_account_name" {
  description = "Nome da Storage Account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "ID da Storage Account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_key" {
  description = "Chave da Storage Account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "storage_account_connection_string" {
  description = "String de conexão da Storage Account"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "blob_endpoint" {
  description = "Endpoint do Blob Storage"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}