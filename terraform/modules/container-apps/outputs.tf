# 🚀 CONTAINER APPS MODULE - OUTPUTS

# Environment
output "environment_id" {
  description = "ID do Container Apps Environment"
  value       = azurerm_container_app_environment.main.id
}

output "environment_name" {
  description = "Nome do Container Apps Environment"
  value       = azurerm_container_app_environment.main.name
}

output "log_analytics_workspace_id" {
  description = "ID do Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

# Frontend (público - substitui NGINX)
output "frontend_url" {
  description = "URL pública do frontend (substitui chat.superagentes.ai)"
  value       = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
}

output "frontend_fqdn" {
  description = "FQDN do frontend"
  value       = azurerm_container_app.frontend.latest_revision_fqdn
}

# API (interno - substitui LibreChat-API)
output "api_url" {
  description = "URL interna da API (substitui http://api:3080)"
  value       = "https://${azurerm_container_app.api.latest_revision_fqdn}"
}

output "api_fqdn" {
  description = "FQDN da API"
  value       = azurerm_container_app.api.latest_revision_fqdn
}

# Meilisearch (interno - substitui chat-meilisearch)
output "meilisearch_url" {
  description = "URL interna do Meilisearch (substitui http://meilisearch:7700)"
  value       = "https://${azurerm_container_app.meilisearch.latest_revision_fqdn}"
}

output "meilisearch_fqdn" {
  description = "FQDN do Meilisearch"
  value       = azurerm_container_app.meilisearch.latest_revision_fqdn
}

# RAG API (interno - substitui rag_api)
output "rag_api_url" {
  description = "URL interna da RAG API (substitui http://rag_api:8000)"
  value       = "https://${azurerm_container_app.rag_api.latest_revision_fqdn}"
}

output "rag_api_fqdn" {
  description = "FQDN da RAG API"
  value       = azurerm_container_app.rag_api.latest_revision_fqdn
}

# Container App IDs
output "container_app_ids" {
  description = "IDs de todas as Container Apps"
  value = {
    frontend    = azurerm_container_app.frontend.id
    api         = azurerm_container_app.api.id
    meilisearch = azurerm_container_app.meilisearch.id
    rag_api     = azurerm_container_app.rag_api.id
  }
}

# Identity
output "identity_client_id" {
  description = "Client ID da User Assigned Identity"
  value       = azurerm_user_assigned_identity.container_apps.client_id
}

output "identity_principal_id" {
  description = "Principal ID da User Assigned Identity"
  value       = azurerm_user_assigned_identity.container_apps.principal_id
}

# Migration Information
output "migration_comparison" {
  description = "Comparação docker-compose vs Container Apps"
  value = {
    docker_compose = {
      LibreChat_API    = "container LibreChat-API (porta 3080)"
      LibreChat_NGINX  = "container LibreChat-NGINX (portas 80/443)"
      chat_mongodb     = "container chat-mongodb (porta 27017)"
      chat_meilisearch = "container chat-meilisearch (porta 7700)"
      vectordb         = "container vectordb (PostgreSQL)"
      rag_api          = "container rag_api (porta 8000)"
    }
    container_apps = {
      librechat_api    = "https://${azurerm_container_app.api.latest_revision_fqdn}"
      librechat_frontend = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
      cosmosdb         = "CosmosDB Serverless (MongoDB API)"
      meilisearch      = "https://${azurerm_container_app.meilisearch.latest_revision_fqdn}"
      postgresql       = "PostgreSQL Flexible Server"
      rag_api          = "https://${azurerm_container_app.rag_api.latest_revision_fqdn}"
    }
  }
}

# Environment Variables for Local Testing
output "internal_urls" {
  description = "URLs internas para substituir no .env"
  value = {
    MEILI_HOST     = "https://${azurerm_container_app.meilisearch.latest_revision_fqdn}"
    RAG_API_URL    = "https://${azurerm_container_app.rag_api.latest_revision_fqdn}"
    API_URL        = "https://${azurerm_container_app.api.latest_revision_fqdn}"
    FRONTEND_URL   = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
  }
}

# Scaling Information
output "scaling_info" {
  description = "Informações de scaling atual"
  value = {
    api = {
      min_replicas = var.api_config.min_replicas
      max_replicas = var.api_config.max_replicas
      current_url  = "https://${azurerm_container_app.api.latest_revision_fqdn}"
    }
    frontend = {
      min_replicas = var.frontend_config.min_replicas
      max_replicas = var.frontend_config.max_replicas
      current_url  = "https://${azurerm_container_app.frontend.latest_revision_fqdn}"
    }
    meilisearch = {
      min_replicas = var.meilisearch_config.min_replicas
      max_replicas = var.meilisearch_config.max_replicas
      current_url  = "https://${azurerm_container_app.meilisearch.latest_revision_fqdn}"
    }
    rag_api = {
      min_replicas = var.rag_api_config.min_replicas
      max_replicas = var.rag_api_config.max_replicas
      current_url  = "https://${azurerm_container_app.rag_api.latest_revision_fqdn}"
    }
    total_min_replicas = var.api_config.min_replicas + var.frontend_config.min_replicas + var.meilisearch_config.min_replicas + var.rag_api_config.min_replicas
    total_max_replicas = var.api_config.max_replicas + var.frontend_config.max_replicas + var.meilisearch_config.max_replicas + var.rag_api_config.max_replicas
  }
}
