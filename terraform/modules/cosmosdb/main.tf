# 🌐 COSMOSDB MODULE - SUBSTITUI MONGODB LOCAL
# Serverless scale-to-zero baseado no uso atual: 4.1MB

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13.0"
    }
  }
}

# CosmosDB Account com MongoDB API
resource "azurerm_cosmosdb_account" "main" {
  name                = "${var.app_name}-cosmosdb"
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  # Serverless mode (scale-to-zero)
  capabilities {
    name = "EnableMongo"
  }
  
  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = var.consistency_level
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }

  # Backup configuration
  backup {
    type                = "Periodic"
    interval_in_minutes = 240
    retention_in_hours  = 720  # 30 dias
    storage_redundancy  = "Local"
  }

  # Network configuration (pode restringir por IP)
  ip_range_filter = var.allowed_ips != null ? toset(var.allowed_ips) : null

  automatic_failover_enabled = var.enable_automatic_failover
  multiple_write_locations_enabled = false

  # Free tier (se disponível)
  free_tier_enabled = var.enable_free_tier

  tags = var.tags
}

# Database LibreChat (mesmo nome do docker-compose)
resource "azurerm_cosmosdb_mongo_database" "librechat" {
  name                = var.database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  
  # Serverless (sem throughput provisioned)
  # throughput = null  # Automático para serverless
}

# Collections baseadas na aplicação atual
resource "azurerm_cosmosdb_mongo_collection" "collections" {
  for_each = toset(var.collections)
  
  name                = each.value
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  database_name       = azurerm_cosmosdb_mongo_database.librechat.name

  # Indexes básicos para performance
  index {
    keys   = ["_id"]
    unique = true
  }

  # Index para busca por user (padrão do LibreChat)
  dynamic "index" {
    for_each = contains(["conversations", "messages"], each.value) ? [1] : []
    content {
      keys   = ["user"]
      unique = false
    }
  }

  # Index para timestamp (para ordenação)
  dynamic "index" {
    for_each = contains(["conversations", "messages"], each.value) ? [1] : []
    content {
      keys   = ["createdAt"]
      unique = false
    }
  }

  # Serverless collection (sem throughput)
  # throughput = null
}

# Connection string secret no Key Vault (se configurado)
resource "azurerm_key_vault_secret" "connection_string" {
  count = var.key_vault_id != null ? 1 : 0
  
  name         = "${var.app_name}-cosmosdb-connection"
  value        = azurerm_cosmosdb_account.main.connection_strings[0]
  key_vault_id = var.key_vault_id
  
  tags = var.tags
}
