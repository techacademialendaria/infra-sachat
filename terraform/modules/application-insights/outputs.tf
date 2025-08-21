# 📊 APPLICATION INSIGHTS MODULE - OUTPUTS

# Log Analytics Workspace
output "log_analytics_workspace_id" {
  description = "ID do Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_key" {
  description = "Primary shared key do Log Analytics"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "Nome do Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

# Application Insights
output "application_insights_id" {
  description = "ID do Application Insights"
  value       = azurerm_application_insights.main.id
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key para usar nas aplicações"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string para usar nas aplicações"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "application_insights_app_id" {
  description = "App ID do Application Insights"
  value       = azurerm_application_insights.main.app_id
}

# URLs e Endpoints
output "application_insights_portal_url" {
  description = "URL do portal do Application Insights"
  value       = "https://portal.azure.com/#@/resource${azurerm_application_insights.main.id}/overview"
}

output "log_analytics_portal_url" {
  description = "URL do portal do Log Analytics"
  value       = "https://portal.azure.com/#@/resource${azurerm_log_analytics_workspace.main.id}/overview"
}

# Para usar nas Container Apps
output "environment_variables" {
  description = "Variáveis de ambiente para configurar nas Container Apps"
  value = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.main.connection_string
    APPINSIGHTS_INSTRUMENTATIONKEY      = azurerm_application_insights.main.instrumentation_key
    WEBSITE_ENABLE_SYNC_UPDATE_SITE     = "true"
    APPINSIGHTS_PROFILERFEATURE_VERSION = "1.0.0"
  }
  sensitive = true
}

# Configurações de monitoramento
output "monitoring_config" {
  description = "Configurações de monitoramento para referência"
  value = {
    log_retention_days    = var.log_retention_days
    daily_quota_gb       = var.daily_quota_gb
    sampling_percentage  = var.sampling_percentage
    alerts_enabled       = var.enable_alerts
    dashboard_created    = var.create_dashboard
  }
}

# Para troubleshooting
output "kusto_queries" {
  description = "Queries úteis para troubleshooting"
  value = {
    requests_last_hour = "requests | where timestamp > ago(1h) | summarize count() by bin(timestamp, 5m) | render timechart"
    errors_last_hour   = "exceptions | where timestamp > ago(1h) | summarize count() by type"
    performance_last_hour = "requests | where timestamp > ago(1h) | summarize avg(duration) by name"
    traces_last_hour   = "traces | where timestamp > ago(1h) | order by timestamp desc | take 100"
  }
}

# Alertas configurados
output "alerts_configured" {
  description = "Lista de alertas configurados"
  value = var.enable_alerts ? [
    "CPU High (>80%)",
    "Memory High (>90%)",
    "Smart Detection: Failure Anomalies"
  ] : []
}

# Custo estimado
output "cost_estimation" {
  description = "Estimativa de custo baseada na configuração"
  value = {
    log_analytics_gb_month = var.daily_quota_gb * 30
    within_free_tier      = var.daily_quota_gb * 30 <= 5 ? "Yes" : "No"
    estimated_cost_month  = var.daily_quota_gb * 30 <= 5 ? "$0 (Free Tier)" : "$${(var.daily_quota_gb * 30 - 5) * 2.76}/month"
    note                  = "First 5GB/month free, then $2.76/GB"
  }
}
