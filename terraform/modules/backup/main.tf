# Backup adicional para recursos críticos (opcional para produção)

# Recovery Services Vault para backup
resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  storage_mode_type   = "GeoRedundant"
  
  # Managed identity for security compliance
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Backup policy para storage account (files)
resource "azurerm_backup_policy_file_share" "main" {
  name                = "backup-policy-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = "02:00"
  }

  retention_daily {
    count = var.daily_retention_days
  }

  retention_weekly {
    count    = var.weekly_retention_weeks
    weekdays = ["Sunday"]
  }

  retention_monthly {
    count    = var.monthly_retention_months
    weekdays = ["Sunday"]
    weeks    = ["First"]
  }
}

# Backup container para storage account (se habilitado)
resource "azurerm_backup_container_storage_account" "main" {
  count               = var.enable_storage_backup ? 1 : 0
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name
  storage_account_id  = var.storage_account_id
}