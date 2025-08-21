# 🌐 COSMOSDB MODULE - OUTPUTS

output "id" {
  description = "ID do CosmosDB Account"
  value       = azurerm_cosmosdb_account.main.id
}

output "name" {
  description = "Nome do CosmosDB Account"
  value       = azurerm_cosmosdb_account.main.name
}

output "endpoint" {
  description = "Endpoint do CosmosDB"
  value       = azurerm_cosmosdb_account.main.endpoint
}

output "connection_string" {
  description = "Connection string para usar no .env (substitui MONGO_URI)"
  # Connection string construída manualmente (connection_strings não existe no provider 4.13+)
  value       = "mongodb://${azurerm_cosmosdb_account.main.name}:${azurerm_cosmosdb_account.main.primary_key}@${azurerm_cosmosdb_account.main.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.librechat.name}?ssl=true&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@${azurerm_cosmosdb_account.main.name}@"
  sensitive   = true
}

output "database_name" {
  description = "Nome do database criado"
  value       = azurerm_cosmosdb_mongo_database.librechat.name
}

output "database_id" {
  description = "ID do database"
  value       = azurerm_cosmosdb_mongo_database.librechat.id
}

output "collections" {
  description = "Collections criadas"
  value       = [for collection in azurerm_cosmosdb_mongo_collection.collections : collection.name]
}

output "primary_key" {
  description = "Primary key do CosmosDB"
  value       = azurerm_cosmosdb_account.main.primary_key
  sensitive   = true
}

output "secondary_key" {
  description = "Secondary key do CosmosDB"
  value       = azurerm_cosmosdb_account.main.secondary_key
  sensitive   = true
}

# Para migration scripts
output "migration_info" {
  description = "Informações para migração do MongoDB local"
  value = {
    original_mongo_uri    = "mongodb://127.0.0.1:27017/LibreChat"
    # Connection string construída manualmente
    new_connection_string = "mongodb://${azurerm_cosmosdb_account.main.name}:${azurerm_cosmosdb_account.main.primary_key}@${azurerm_cosmosdb_account.main.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.librechat.name}?ssl=true&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@${azurerm_cosmosdb_account.main.name}@"
    database_name        = azurerm_cosmosdb_mongo_database.librechat.name
    collections          = [for collection in azurerm_cosmosdb_mongo_collection.collections : collection.name]
    migration_command    = "mongorestore --uri 'mongodb://${azurerm_cosmosdb_account.main.name}:${azurerm_cosmosdb_account.main.primary_key}@${azurerm_cosmosdb_account.main.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.librechat.name}?ssl=true&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@${azurerm_cosmosdb_account.main.name}@' --db LibreChat --dir ./mongodb_backup/LibreChat"
  }
  sensitive = true
}

# Para .env file update
output "env_variables" {
  description = "Variáveis para atualizar no .env"
  value = {
    # Connection string construída manualmente
    MONGO_URI = "mongodb://${azurerm_cosmosdb_account.main.name}:${azurerm_cosmosdb_account.main.primary_key}@${azurerm_cosmosdb_account.main.name}.mongo.cosmos.azure.com:10255/${azurerm_cosmosdb_mongo_database.librechat.name}?ssl=true&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@${azurerm_cosmosdb_account.main.name}@"
  }
  sensitive = true
}
