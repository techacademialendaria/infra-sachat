output "container_app_environment_id" {
  description = "ID do Container App Environment"
  value       = azurerm_container_app_environment.main.id
}

output "log_analytics_workspace_id" {
  description = "ID do Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}