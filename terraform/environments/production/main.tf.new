# Production Environment Configuration
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"

  backend "azurerm" {
    # Configuração será definida nos workflows
    # key será: production.tfstate
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Local variables for production
locals {
  environment = "production"
  tags = {
    Environment = "production"
    Project     = "SA Chat"
    ManagedBy   = "terraform"
    Repository  = "legendschat-infrastructure"
  }
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

# Use modules from parent directory
module "network" {
  source = "../../modules/network"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = var.project_name
  environment        = local.environment
  tags              = local.tags
}

module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = var.project_name
  environment        = local.environment
  subnet_id          = module.network.subnet_id
  tags              = local.tags
}

module "storage" {
  source = "../../modules/storage"

  resource_group_name            = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  project_name                  = var.project_name
  environment                   = local.environment
  subnet_id                     = module.network.subnet_id
  key_vault_id                  = module.keyvault.key_vault_id
  storage_encryption_key_name   = module.keyvault.storage_encryption_key_name
  tags                         = local.tags
}

module "database" {
  source = "../../modules/database"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = var.project_name
  environment        = local.environment
  tags              = local.tags
  
  # Production specific configurations
  compute_tier      = var.compute_tier
  enable_high_availability = var.enable_high_availability
}

module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location           = azurerm_resource_group.main.location
  project_name       = var.project_name
  environment        = local.environment
  tags              = local.tags
  
  # Production specific configurations
  daily_data_cap_gb = var.application_insights_daily_cap_gb
}

module "backup" {
  source = "../../modules/backup"

  resource_group_name   = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location
  project_name         = var.project_name
  environment          = local.environment
  storage_account_id   = module.storage.storage_account_id
  tags                = local.tags
  
  # Production backup configurations
  enable_storage_backup    = var.enable_storage_backup
  daily_retention_days     = var.backup_daily_retention_days
  weekly_retention_weeks   = var.backup_weekly_retention_weeks
  monthly_retention_months = var.backup_monthly_retention_months
}

module "container_apps" {
  source = "../../modules/container_apps"

  resource_group_name           = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  container_app_environment_id = module.network.container_app_environment_id
  storage_account_name         = module.storage.storage_account_name
  storage_account_key          = module.storage.storage_account_key
  mongodb_connection_string    = module.database.connection_string
  application_insights_key     = module.monitoring.application_insights_connection_string
  project_name                 = var.project_name
  environment                  = local.environment
  tags                        = local.tags
  
  # Production specific configurations
  min_replicas = var.min_replicas
  max_replicas = var.max_replicas
}

module "domain" {
  source = "../../modules/domain"

  resource_group_name     = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  domain_name            = var.domain_name
  container_app_fqdn     = module.container_apps.app_fqdn
  tags                  = local.tags
  
  # Production creates DNS zone for custom domain
  create_dns_zone = true
}
