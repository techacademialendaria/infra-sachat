# 📦 CONTAINER REGISTRY MODULE - OUTPUTS

output "registry_name" {
  description = "Nome do Container Registry"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "URL do registry (para docker login)"
  value       = azurerm_container_registry.main.login_server
}

output "id" {
  description = "ID do Container Registry"
  value       = azurerm_container_registry.main.id
}

output "admin_username" {
  description = "Username admin (para login)"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "Password admin (para login)"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

# Service Principal info para GitHub Actions
output "identity_client_id" {
  description = "Client ID da identity para GitHub Actions"
  value       = azurerm_user_assigned_identity.registry.client_id
}

output "identity_principal_id" {
  description = "Principal ID da identity"
  value       = azurerm_user_assigned_identity.registry.principal_id
}

output "identity_tenant_id" {
  description = "Tenant ID da identity"
  value       = azurerm_user_assigned_identity.registry.tenant_id
}

# URLs das imagens para Container Apps
output "api_image_url" {
  description = "URL da imagem da API"
  value       = "${azurerm_container_registry.main.login_server}/librechat-api:latest"
}

output "meilisearch_image_url" {
  description = "URL da imagem do Meilisearch"
  value       = "${azurerm_container_registry.main.login_server}/meilisearch:latest"
}

output "rag_api_image_url" {
  description = "URL da imagem da RAG API"
  value       = "${azurerm_container_registry.main.login_server}/rag-api:latest"
}

# Build tasks info - REMOVIDO (usando GitHub Actions)
# output "api_build_task_name" {
#   description = "Nome da task de build da API"
#   value       = azurerm_container_registry_task.api_build.name
# }

# Para usar em GitHub Actions
output "github_actions_config" {
  description = "Configuração para GitHub Actions"
  value = {
    registry_name    = azurerm_container_registry.main.name
    login_server     = azurerm_container_registry.main.login_server
    client_id        = azurerm_user_assigned_identity.registry.client_id
    tenant_id        = azurerm_user_assigned_identity.registry.tenant_id
  }
  sensitive = true
}
