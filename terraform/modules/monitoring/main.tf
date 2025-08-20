resource "azurerm_application_insights" "main" {
  name                                  = "appi-${var.project_name}-${var.environment}"
  location                              = var.location
  resource_group_name                   = var.resource_group_name
  application_type                      = "web"
  daily_data_cap_in_gb                  = var.daily_data_cap_gb
  daily_data_cap_notifications_disabled = false
  retention_in_days                     = var.retention_days

  tags = var.tags
}