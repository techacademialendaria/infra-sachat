# 📊 APPLICATION INSIGHTS MODULE - MONITORAMENTO CONTAINER APPS
# Para logs, métricas e performance monitoring

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13.0"
    }
  }
}

# Log Analytics Workspace (base para Application Insights)
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.app_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.daily_quota_gb  # 100MB = 0.1GB por dia

  tags = var.tags
}

# Application Insights para monitoramento das aplicações
resource "azurerm_application_insights" "main" {
  name                = "${var.app_name}-insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"

  # Configurações de performance
  sampling_percentage = var.sampling_percentage
  disable_ip_masking  = var.disable_ip_masking

  tags = var.tags
}

# Action Group para alertas (opcional)
resource "azurerm_monitor_action_group" "main" {
  count = var.enable_alerts ? 1 : 0
  
  name                = "${var.app_name}-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "superchat"

  # Webhook para notificações (pode ser Teams, Slack, etc)
  dynamic "webhook_receiver" {
    for_each = var.webhook_receivers
    content {
      name        = webhook_receiver.value.name
      service_uri = webhook_receiver.value.service_uri
    }
  }

  # Email notifications
  dynamic "email_receiver" {
    for_each = var.email_receivers
    content {
      name          = email_receiver.value.name
      email_address = email_receiver.value.email_address
    }
  }

  tags = var.tags
}

# Metric Alerts para Container Apps
resource "azurerm_monitor_metric_alert" "cpu_high" {
  count = var.enable_alerts ? 1 : 0
  
  name                = "${var.app_name}-cpu-high"
  resource_group_name = var.resource_group_name
  scopes              = var.container_app_ids
  description         = "CPU usage is too high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80  # 80% CPU
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  frequency   = "PT5M"   # Check every 5 minutes
  window_size = "PT15M"  # 15 minute window

  tags = var.tags
}

# Metric Alert para Memory
resource "azurerm_monitor_metric_alert" "memory_high" {
  count = var.enable_alerts ? 1 : 0
  
  name                = "${var.app_name}-memory-high"
  resource_group_name = var.resource_group_name
  scopes              = var.container_app_ids
  description         = "Memory usage is too high"
  severity            = 2

  criteria {
    metric_namespace = "Microsoft.App/containerApps"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 90  # 90% Memory
  }

  action {
    action_group_id = azurerm_monitor_action_group.main[0].id
  }

  frequency   = "PT5M"
  window_size = "PT15M"

  tags = var.tags
}

# Availability Test para frontend
resource "azurerm_application_insights_web_test" "frontend" {
  count = var.frontend_url != null ? 1 : 0
  
  name                    = "${var.app_name}-frontend-availability"
  location                = var.location
  resource_group_name     = var.resource_group_name
  application_insights_id = azurerm_application_insights.main.id
  kind                    = "ping"
  frequency               = 300  # 5 minutes
  timeout                 = 60
  enabled                 = true
  geo_locations           = ["us-east-1", "eu-west-1"]  # Test from multiple locations

  configuration = <<XML
<WebTest Name="${var.app_name}-frontend-test" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="60" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Version="1.1" Url="${var.frontend_url}" ThinkTime="0" Timeout="60" ParseDependentRequests="False" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML

  tags = var.tags
}

# Smart Detection Rules (detecção automática de problemas)
resource "azurerm_application_insights_smart_detection_rule" "failure_anomalies" {
  name                    = "Failure Anomalies - ${var.app_name}"
  application_insights_id = azurerm_application_insights.main.id
  enabled                 = true
  send_emails_to_subscription_owners = false
  
  # Enviar emails para admins específicos
  additional_email_recipients = var.admin_emails
}

# Workbook para dashboard customizado
resource "azurerm_application_insights_workbook" "main" {
  count = var.create_dashboard ? 1 : 0
  
  name                = "${var.app_name}-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "SuperChat Monitoring Dashboard"
  
  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 1
        content = {
          json = "# SuperChat Monitoring Dashboard\n\nMonitoramento completo das Container Apps"
        }
      },
      {
        type = 3
        content = {
          json = {
            version = "KqlItem/1.0"
            query = "requests | summarize count() by bin(timestamp, 5m) | render timechart"
            size = 0
            title = "Requests por minuto"
          }
        }
      }
    ]
  })

  tags = var.tags
}
