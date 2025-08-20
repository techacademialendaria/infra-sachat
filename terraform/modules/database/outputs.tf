output "connection_string" {
  description = "String de conexão do MongoDB"
  value       = "mongodb://${azurerm_cosmosdb_account.main.name}:${azurerm_cosmosdb_account.main.primary_key}@${azurerm_cosmosdb_account.main.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.librechat.name}?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@${azurerm_cosmosdb_account.main.name}@"
  sensitive   = true
}

output "server_name" {
  description = "Nome do servidor MongoDB"
  value       = azurerm_cosmosdb_account.main.name
}

output "endpoint" {
  description = "Endpoint do MongoDB"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "primary_key" {
  description = "Chave primária"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "database_name" {
  description = "Nome da database"
  value       = azurerm_cosmosdb_mongo_database.librechat.name
}