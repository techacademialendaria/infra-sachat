# 🚀 SUPERCHAT - OUTPUTS DE PRODUÇÃO
# Informações importantes após o deploy

# Resource Group
output "resource_group_name" {
  description = "Nome do Resource Group criado"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Localização do Resource Group"
  value       = azurerm_resource_group.main.location
}

# CosmosDB (substitui MongoDB local)
output "cosmosdb_endpoint" {
  description = "Endpoint do CosmosDB (substitui mongodb://127.0.0.1:27017)"
  value       = module.cosmosdb.endpoint
}

output "cosmosdb_connection_string" {
  description = "Connection string do CosmosDB para usar no .env"
  value       = module.cosmosdb.connection_string
  sensitive   = true
}

output "cosmosdb_database_name" {
  description = "Nome do database (deve ser LibreChat)"
  value       = module.cosmosdb.database_name
}

# PostgreSQL (substitui container vectordb)
output "postgresql_fqdn" {
  description = "FQDN do PostgreSQL (substitui vectordb:5432)"
  value       = module.postgresql.fqdn
}

output "postgresql_connection_string" {
  description = "Connection string do PostgreSQL para RAG API"
  value       = module.postgresql.connection_string
  sensitive   = true
}

output "postgresql_database_name" {
  description = "Nome do database PostgreSQL (deve ser mydatabase)"
  value       = module.postgresql.database_name
}

# Azure Storage (substitui volumes locais)
output "storage_account_name" {
  description = "Nome da Storage Account (substitui volumes locais)"
  value       = module.storage.account_name
}

output "storage_connection_string" {
  description = "Connection string do Azure Storage para o .env"
  value       = module.storage.connection_string
  sensitive   = true
}

output "storage_containers" {
  description = "Containers criados (substitui ./images, ./uploads, ./logs)"
  value       = module.storage.container_names
}

# Container Apps URLs
output "frontend_url" {
  description = "URL do frontend (será usado para DNS)"
  value       = module.container_apps.frontend_url
}

output "api_url" {
  description = "URL da API interna"
  value       = module.container_apps.api_url
}

output "meilisearch_url" {
  description = "URL do Meilisearch interno (substitui http://meilisearch:7700)"
  value       = module.container_apps.meilisearch_url
}

output "rag_api_url" {
  description = "URL da RAG API interna (substitui http://rag_api:8000)"
  value       = module.container_apps.rag_api_url
}

# Container Registry
output "container_registry_login_server" {
  description = "Login server do Container Registry"
  value       = "${var.app_name}registry.azurecr.io"
}

# Environment Configuration
output "container_apps_environment_name" {
  description = "Nome do Container Apps Environment"
  value       = module.container_apps.environment_name
}

# Migration Information
output "migration_summary" {
  description = "Resumo da migração realizada"
  value = {
    original_structure = "docker-compose.yml com volumes locais"
    migrated_to        = "Azure Container Apps com Azure Storage"
    original_ram       = "1.1GB total (API: 411MB, MongoDB: 322MB, RAG: 208MB, Meilisearch: 109MB)"
    original_data      = "4.1MB MongoDB + 352K arquivos locais"
    azure_scaling      = "2-23 replicas total conforme demanda"
    cost_estimate      = "$35-150/mês conforme uso"
  }
}

# Next Steps
output "next_steps" {
  description = "Próximos passos para finalizar a migração"
  value = {
    step_1 = "Atualizar DNS para apontar para ${module.container_apps.frontend_url}"
    step_2 = "Migrar dados: MongoDB local → CosmosDB"
    step_3 = "Migrar arquivos: volumes locais → Azure Storage"
    step_4 = "Atualizar .env com novas connection strings"
    step_5 = "Testar aplicação completa"
  }
}

# Environment Variables (para o novo .env)
output "new_env_variables" {
  description = "Variáveis para atualizar o .env após migração"
  value = {
    MONGO_URI                       = module.cosmosdb.connection_string
    AZURE_STORAGE_CONNECTION_STRING = module.storage.connection_string
    AZURE_CONTAINER_NAME            = "files"
    DB_HOST                         = module.postgresql.fqdn
    MEILI_HOST                      = module.container_apps.meilisearch_url
    RAG_API_URL                     = module.container_apps.rag_api_url
    fileStrategy                    = "azure"
  }
  sensitive = true
}

# Cost Management
output "cost_monitoring" {
  description = "Informações para monitoramento de custos"
  value = {
    budget_limit      = "${var.budget_limit} USD/mês"
    infracost_enabled = var.infracost_config.enabled
    cost_tags         = var.default_tags
    scale_to_zero     = "CosmosDB Serverless + Container Apps auto-scaling"
  }
}
