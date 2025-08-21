# 📦 STORAGE MODULE - OUTPUTS

output "account_name" {
  description = "Nome da Storage Account"
  value       = azurerm_storage_account.main.name
}

output "account_id" {
  description = "ID da Storage Account"
  value       = azurerm_storage_account.main.id
}

output "primary_blob_endpoint" {
  description = "Endpoint principal do blob storage"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "connection_string" {
  description = "Connection string para usar no .env (substitui AZURE_STORAGE_CONNECTION_STRING)"
  value       = azurerm_storage_account.main.primary_connection_string
  sensitive   = true
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "Secondary access key"
  value       = azurerm_storage_account.main.secondary_access_key
  sensitive   = true
}

output "container_names" {
  description = "Nomes dos containers criados"
  value       = [for container in azurerm_storage_container.containers : container.name]
}

output "container_urls" {
  description = "URLs dos containers"
  value = {
    for name, container in azurerm_storage_container.containers :
    name => "${azurerm_storage_account.main.primary_blob_endpoint}${container.name}/"
  }
}

# SAS URLs para acesso direto (temporário)
output "container_sas_urls" {
  description = "URLs com SAS para acesso direto"
  value = {
    for name, sas in data.azurerm_storage_account_blob_container_sas.app_sas :
    name => "${azurerm_storage_account.main.primary_blob_endpoint}${name}/${sas.sas}"
  }
  sensitive = true
}

# Para migration scripts
output "migration_info" {
  description = "Informações para migração dos volumes locais"
  value = {
    original_volumes = {
      images  = "./images (308K)"
      uploads = "./uploads (44K)"
      logs    = "./logs (580K)"
    }
    azure_containers = [for container in azurerm_storage_container.containers : container.name]
    migration_commands = {
      images = "az storage blob upload-batch --destination images --source ./images --account-name ${azurerm_storage_account.main.name}"
      uploads = "az storage blob upload-batch --destination uploads --source ./uploads --account-name ${azurerm_storage_account.main.name}"
      logs = "az storage blob upload-batch --destination logs --source ./logs --account-name ${azurerm_storage_account.main.name}"
    }
    total_size_estimate = "~1GB (352K atual + buffer)"
  }
}

# Para .env file update
output "env_variables" {
  description = "Variáveis para atualizar no .env"
  value = {
    AZURE_STORAGE_CONNECTION_STRING = azurerm_storage_account.main.primary_connection_string
    AZURE_CONTAINER_NAME           = "files"  # Mantém compatibilidade
    fileStrategy                   = "azure"
  }
  sensitive = true
}

# Container details
output "containers_detail" {
  description = "Detalhes dos containers criados"
  value = {
    for name, container in azurerm_storage_container.containers :
    name => {
      name         = container.name
      url          = "${azurerm_storage_account.main.primary_blob_endpoint}${container.name}/"
      access_type  = container.container_access_type
      replaces     = "./${name}"
    }
  }
}

# Cost optimization info
output "cost_optimization" {
  description = "Informações de otimização de custos"
  value = {
    lifecycle_management_enabled = var.enable_lifecycle_management
    access_tier                 = azurerm_storage_account.main.access_tier
    replication_type           = azurerm_storage_account.main.account_replication_type
    estimated_monthly_cost     = "~$1-5/mês para 1GB (baseado no uso atual)"
  }
}
