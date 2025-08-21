# 🚀 SUPERCHAT - TERRAFORM MAIN CONFIGURATION
# Migração fiel do docker-compose.yml para Azure Container Apps
# Baseado em: /home/ubuntu/sa/legendschat/deploy-compose.yml

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Resource Group Principal
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Módulo Container Registry (para otimizar builds)
module "container_registry" {
  source = "../../modules/container-registry"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  app_name          = var.app_name
  
  # GitHub integration para auto-build
  github_org     = var.github_org
  source_repo    = var.source_repo
  source_branch  = var.source_branch
  github_token   = var.github_token
  
  # Configurações de performance
  sku            = "Standard"  # Para melhor performance de build
  retention_days = 30          # Manter imagens por 30 dias
  
  tags = local.common_tags
}

# Módulo CosmosDB (equivalente ao MongoDB)
module "cosmosdb" {
  source = "../../modules/cosmosdb"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  app_name          = var.app_name
  
  # Configurações equivalentes ao MongoDB do docker-compose
  database_name     = "LibreChat"  # Mesmo nome usado no docker-compose
  collections = [
    "conversations",
    "users", 
    "messages"
  ]
  
  tags = local.common_tags
}

# Módulo PostgreSQL (equivalente ao vectordb)
module "postgresql" {
  source = "../../modules/postgresql"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  app_name          = var.app_name
  
  # Configurações equivalentes ao vectordb do docker-compose
  database_name    = "mydatabase"  # Mesmo nome do docker-compose
  admin_user       = "myuser"      # Mesmo user do docker-compose
  admin_password   = var.postgresql_admin_password
  
  # Configuração pgvector (equivalente a ankane/pgvector:latest)
  enable_pgvector = true
  
  tags = local.common_tags
}

# Módulo Storage (Azure Blob - SUBSTITUI volumes locais)
module "storage" {
  source = "../../modules/storage"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  app_name          = var.app_name
  
  # Containers para substituir volumes locais do docker-compose
  containers = [
    "images",   # Substitui ./images (volume local)
    "uploads",  # Substitui ./uploads (volume local)  
    "logs"      # Substitui ./logs (volume local)
  ]
  
  tags = local.common_tags
}

# Módulo Application Insights (monitoramento e logs)
module "application_insights" {
  source = "../../modules/application-insights"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  app_name          = var.app_name
  
  # Configuração para 100MB/dia (3GB/mês - dentro do free tier)
  daily_quota_gb       = 0.1  # 100MB por dia
  log_retention_days   = 30   # 30 dias de retenção
  sampling_percentage  = 100  # 100% sampling para desenvolvimento
  
  # Alertas e monitoramento
  enable_alerts = true
  admin_emails  = var.admin_emails
  
  # Dashboard personalizado
  create_dashboard = true
  
  tags = local.common_tags
}

# Módulo Container Apps (toda a aplicação)
module "container_apps" {
  source = "../../modules/container-apps"
  
  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  app_name          = var.app_name
  
  # Container Registry
  container_registry_id           = module.container_registry.id
  container_registry_login_server = module.container_registry.login_server
  
  # Connection strings dos databases
  mongodb_connection_string    = module.cosmosdb.connection_string
  postgresql_connection_string = module.postgresql.connection_string
  postgresql_host              = module.postgresql.host
  storage_connection_string    = module.storage.connection_string
  
  # Application Insights (monitoramento)
  log_analytics_workspace_id   = module.application_insights.log_analytics_workspace_id
  application_insights_connection_string = module.application_insights.application_insights_connection_string
  
  # Configurações específicas para cada container (baseado no docker-compose)
  api_config = {
    name          = "librechat-api"
    image         = module.container_registry.api_image_url  # URL do registry
    target_port   = 3080
    min_replicas  = 2
    max_replicas  = 10
    cpu           = 1.0
    memory        = "2Gi"
    
    # Environment variables equivalentes ao docker-compose
    env_vars = {
      HOST                = "0.0.0.0"
      NODE_ENV           = "production"
      RAG_PORT           = "8000"
      fileStrategy       = "azure"  # Mudança de volumes locais para Azure Storage
    }
  }
  
  frontend_config = {
    name          = "librechat-frontend"
    image         = "${module.container_registry.login_server}/librechat-frontend:latest"
    target_port   = 80
    min_replicas  = 1
    max_replicas  = 5
    cpu           = 0.25
    memory        = "0.5Gi"
    
    # NGINX configuration (equivalente ao nginx:1.27.0-alpine)
    nginx_config  = true
  }
  
  meilisearch_config = {
    name          = "meilisearch"
    image         = module.container_registry.meilisearch_image_url  # Do registry
    target_port   = 7700
    min_replicas  = 1
    max_replicas  = 3
    cpu           = 0.5
    memory        = "1Gi"
    
    # Environment variables equivalentes ao docker-compose
    env_vars = {
      MEILI_HOST        = "http://meilisearch:7700"
      MEILI_NO_ANALYTICS = "true"
    }
  }
  
  rag_api_config = {
    name          = "rag-api"
    image         = module.container_registry.rag_api_image_url  # Do registry
    target_port   = 8000
    min_replicas  = 1
    max_replicas  = 5
    cpu           = 0.5
    memory        = "1Gi"
    
    # Environment variables equivalentes ao docker-compose  
    env_vars = {
      RAG_PORT  = "8000"
    }
  }
  
  # Domain configuration (equivalente ao SSL atual)
  custom_domain = var.domain_config.enable_ssl ? {
    domain_name    = var.domain_config.domain_name
    certificate_id = null  # Será configurado manualmente
  } : null
  
  tags = local.common_tags
  
  depends_on = [
    module.container_registry,
    module.cosmosdb,
    module.postgresql,
    module.storage,
    module.application_insights
  ]
}

# Locals para tags e configurações
locals {
  common_tags = {
    Environment   = "production"
    Project      = "superchat"
    ManagedBy    = "terraform"
    MigratedFrom = "docker-compose-local"
    StorageType  = "local-to-azure"
    CostCenter   = "librechat-migration"
  }
}
