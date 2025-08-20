output "application_insights_instrumentation_key" {
  description = "Chave de instrumentação do Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "String de conexão do Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "application_insights_app_id" {
  description = "App ID do Application Insights"
  value       = azurerm_application_insights.main.app_id
}