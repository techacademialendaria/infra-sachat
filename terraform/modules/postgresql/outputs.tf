# 🐘 POSTGRESQL MODULE - OUTPUTS

output "id" {
  description = "ID do PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "name" {
  description = "Nome do PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "fqdn" {
  description = "FQDN do servidor (substitui vectordb:5432)"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "database_name" {
  description = "Nome do database criado"
  value       = azurerm_postgresql_flexible_server_database.rag_database.name
}

output "admin_user" {
  description = "Username do admin"
  value       = azurerm_postgresql_flexible_server.main.administrator_login
}

output "connection_string" {
  description = "Connection string para RAG API (substitui DB_HOST=vectordb)"
  value       = "postgresql://${azurerm_postgresql_flexible_server.main.administrator_login}:${var.admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.rag_database.name}"
  sensitive   = true
}

output "host" {
  description = "Host para usar como DB_HOST na RAG API"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "port" {
  description = "Porta PostgreSQL"
  value       = 5432
}

# Para migration e configuração
output "migration_info" {
  description = "Informações para migração do vectordb container"
  value = {
    original_container    = "vectordb"
    original_connection   = "postgresql://myuser:mypassword@vectordb:5432/mydatabase"
    new_host             = azurerm_postgresql_flexible_server.main.fqdn
    new_connection       = "postgresql://${azurerm_postgresql_flexible_server.main.administrator_login}:${var.admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.rag_database.name}"
    pgvector_enabled     = var.enable_pgvector
  }
  sensitive = true
}

# Para .env file update
output "env_variables" {
  description = "Variáveis para atualizar no .env (RAG API)"
  value = {
    DB_HOST              = azurerm_postgresql_flexible_server.main.fqdn
    DB_PORT              = "5432"
    DB_NAME              = azurerm_postgresql_flexible_server_database.rag_database.name
    DB_USER              = azurerm_postgresql_flexible_server.main.administrator_login
    DB_PASSWORD          = var.admin_password
    POSTGRES_DB          = azurerm_postgresql_flexible_server_database.rag_database.name
    POSTGRES_USER        = azurerm_postgresql_flexible_server.main.administrator_login
    POSTGRES_PASSWORD    = var.admin_password
  }
  sensitive = true
}

# Server details
output "server_version" {
  description = "Versão do PostgreSQL"
  value       = azurerm_postgresql_flexible_server.main.version
}

output "sku_name" {
  description = "SKU do servidor"
  value       = azurerm_postgresql_flexible_server.main.sku_name
}

output "storage_mb" {
  description = "Storage configurado em MB"
  value       = azurerm_postgresql_flexible_server.main.storage_mb
}
