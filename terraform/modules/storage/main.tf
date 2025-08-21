# 📦 AZURE STORAGE MODULE - SUBSTITUI VOLUMES LOCAIS
# Containers para ./images, ./uploads, ./logs

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13.0"
    }
  }
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                = "${var.app_name}files"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Configuração otimizada para arquivos da aplicação
  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"
  access_tier              = var.access_tier

  # Security settings
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  
  # Blob properties
  blob_properties {
    # CORS para acesso web
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"]
      allowed_origins    = var.allowed_origins
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }

    # Versionamento de blobs (opcional)
    versioning_enabled = var.versioning_enabled
    
    # Soft delete
    delete_retention_policy {
      days = var.soft_delete_retention_days
    }
  }

  # Network rules (opcional)
  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      ip_rules                  = network_rules.value.ip_rules
      virtual_network_subnet_ids = network_rules.value.virtual_network_subnet_ids
      bypass                    = network_rules.value.bypass
    }
  }

  tags = var.tags
}

# Containers que substituem os volumes locais
resource "azurerm_storage_container" "containers" {
  for_each = toset(var.containers)
  
  name                  = each.value
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = var.container_access_type

  metadata = {
    purpose        = "librechat-migration"
    replaces       = "./${each.value}"  # Volume local substituído
    original_size  = each.value == "images" ? "308K" : each.value == "uploads" ? "44K" : "580K"
  }
}

# Lifecycle management para economizar custos
resource "azurerm_storage_management_policy" "lifecycle" {
  count = var.enable_lifecycle_management ? 1 : 0
  
  storage_account_id = azurerm_storage_account.main.id

  rule {
    name    = "lifecycle-rule"
    enabled = true

    filters {
      blob_types = ["blockBlob"]
    }

    actions {
      base_blob {
        # Mover para cool storage após 30 dias
        tier_to_cool_after_days_since_modification_greater_than = 30
        
        # Mover para archive após 90 dias
        tier_to_archive_after_days_since_modification_greater_than = 90
        
        # Deletar após 365 dias (para logs)
        delete_after_days_since_modification_greater_than = 365
      }

      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}

# Shared Access Signature para acesso da aplicação
data "azurerm_storage_account_blob_container_sas" "app_sas" {
  for_each = toset(var.containers)
  
  connection_string = azurerm_storage_account.main.primary_connection_string
  container_name    = azurerm_storage_container.containers[each.value].name
  https_only        = true

  start  = timestamp()
  expiry = timeadd(timestamp(), "8760h")  # 1 ano

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

# Connection string secret (se Key Vault disponível)
resource "azurerm_key_vault_secret" "connection_string" {
  count = var.key_vault_id != null ? 1 : 0
  
  name         = "${var.app_name}-storage-connection"
  value        = azurerm_storage_account.main.primary_connection_string
  key_vault_id = var.key_vault_id
  
  tags = var.tags
}

# Diagnóstico e logs
resource "azurerm_monitor_diagnostic_setting" "storage" {
  count = var.log_analytics_workspace_id != null ? 1 : 0
  
  name                       = "${var.app_name}-storage-diagnostics"
  target_resource_id         = "${azurerm_storage_account.main.id}/blobServices/default/"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "StorageRead"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "StorageWrite"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "StorageDelete"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "Transaction"

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
