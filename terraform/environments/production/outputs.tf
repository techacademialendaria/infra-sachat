output "resource_group_name" {
  description = "Nome do Resource Group"
  value       = azurerm_resource_group.main.name
}

output "app_url" {
  description = "URL da aplicação"
  value       = module.container_apps.app_url
}

output "app_fqdn" {
  description = "FQDN da aplicação"
  value       = module.container_apps.app_fqdn
}

output "container_app_name" {
  description = "Nome do Container App"
  value       = module.container_apps.container_app_name
}

output "storage_account_name" {
  description = "Nome da Storage Account"
  value       = module.storage.storage_account_name
}

output "mongodb_endpoint" {
  description = "Endpoint do MongoDB"
  value       = module.database.endpoint
}

output "mongodb_connection_string" {
  description = "String de conexão do MongoDB"
  value       = module.database.connection_string
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "String de conexão do Application Insights"
  value       = module.monitoring.application_insights_connection_string
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID do Log Analytics Workspace"
  value       = module.network.log_analytics_workspace_id
}

output "dns_zone_name_servers" {
  description = "Name servers da zona DNS"
  value       = module.domain.dns_zone_name_servers
}

output "backup_vault_name" {
  description = "Nome do Recovery Services Vault"
  value       = var.enable_backup ? module.backup.recovery_vault_name : ""
}