# 🐘 POSTGRESQL MODULE - SUBSTITUI CONTAINER VECTORDB
# Flexible Server com pgvector para RAG

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13.0"
    }
  }
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                = "${var.app_name}-postgresql"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Configuração equivalente ao container vectordb
  administrator_login    = var.admin_user
  administrator_password = var.admin_password
  
  # SKU baseado no uso atual (container vectordb)
  sku_name   = var.sku_name
  version    = var.postgresql_version
  
  # Storage configuration
  storage_mb            = var.storage_mb
  storage_tier          = var.storage_tier
  backup_retention_days = var.backup_retention_days
  
  # Network configuration
  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id
  
  # Public access (pode ser desabilitado se usar VNet)
  public_network_access_enabled = var.public_access_enabled
  
  # Configurações de performance
  auto_grow_enabled = true
  
  # High availability (opcional - custo adicional)
  dynamic "high_availability" {
    for_each = var.high_availability_enabled ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }

  # Maintenance window
  maintenance_window {
    day_of_week  = 0    # Domingo
    start_hour   = 2    # 2 AM
    start_minute = 0
  }

  tags = var.tags
}

# Database para RAG (mesmo nome do docker-compose)
resource "azurerm_postgresql_flexible_server_database" "rag_database" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# Configuração pgvector (equivalente ao ankane/pgvector:latest)
resource "azurerm_postgresql_flexible_server_configuration" "pgvector" {
  count     = var.enable_pgvector ? 1 : 0
  name      = "shared_preload_libraries"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "vector"
}

# Extensão pgvector
resource "azurerm_postgresql_flexible_server_configuration" "vector_extension" {
  count     = var.enable_pgvector ? 1 : 0
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = "vector"
}

# Firewall rules para desenvolvimento (pode ser removido em produção)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  count            = var.allow_azure_services ? 1 : 0
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Firewall rules para IPs específicos
resource "azurerm_postgresql_flexible_server_firewall_rule" "allowed_ips" {
  for_each = var.allowed_ip_ranges != null ? var.allowed_ip_ranges : {}
  
  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Connection string secret (se Key Vault disponível)
resource "azurerm_key_vault_secret" "connection_string" {
  count = var.key_vault_id != null ? 1 : 0
  
  name  = "${var.app_name}-postgresql-connection"
  value = "postgresql://${var.admin_user}:${var.admin_password}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/${azurerm_postgresql_flexible_server_database.rag_database.name}"
  key_vault_id = var.key_vault_id
  
  tags = var.tags
}

# SQL para criar extensão pgvector (executado via local-exec)
resource "null_resource" "enable_pgvector" {
  count = var.enable_pgvector ? 1 : 0
  
  depends_on = [
    azurerm_postgresql_flexible_server.main,
    azurerm_postgresql_flexible_server_database.rag_database
  ]

  provisioner "local-exec" {
    command = <<-EOT
      # Aguardar servidor estar pronto
      sleep 60
      
      # Instalar psql se não estiver disponível
      which psql || (
        echo "Installing postgresql-client..."
        sudo apt-get update && sudo apt-get install -y postgresql-client
      )
      
      # Conectar e criar extensão
      PGPASSWORD="${var.admin_password}" psql \
        -h "${azurerm_postgresql_flexible_server.main.fqdn}" \
        -U "${var.admin_user}" \
        -d "${azurerm_postgresql_flexible_server_database.rag_database.name}" \
        -c "CREATE EXTENSION IF NOT EXISTS vector;"
    EOT
  }

  triggers = {
    server_id = azurerm_postgresql_flexible_server.main.id
  }
}
