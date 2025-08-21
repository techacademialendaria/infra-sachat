# 📦 STORAGE MODULE - VARIABLES

variable "resource_group_name" {
  description = "Nome do resource group"
  type        = string
}

variable "location" {
  description = "Localização do Azure"
  type        = string
}

variable "app_name" {
  description = "Nome da aplicação (prefixo)"
  type        = string
}

variable "containers" {
  description = "Containers para criar (substituem volumes locais)"
  type        = list(string)
  default     = ["images", "uploads", "logs"]
}

variable "account_tier" {
  description = "Tier da storage account"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier deve ser Standard ou Premium."
  }
}

variable "replication_type" {
  description = "Tipo de replicação"
  type        = string
  default     = "LRS"  # Local Redundant Storage (mais barato)
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Replication type deve ser válido."
  }
}

variable "access_tier" {
  description = "Tier de acesso (Hot/Cool)"
  type        = string
  default     = "Hot"
  
  validation {
    condition     = contains(["Hot", "Cool"], var.access_tier)
    error_message = "Access tier deve ser Hot ou Cool."
  }
}

variable "container_access_type" {
  description = "Nível de acesso dos containers"
  type        = string
  default     = "private"
  
  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type deve ser private, blob ou container."
  }
}

# CORS Configuration
variable "allowed_origins" {
  description = "Origens permitidas para CORS"
  type        = list(string)
  default     = ["https://chat.superagentes.ai", "https://*.azurecontainerapps.io"]
}

# Lifecycle Management
variable "enable_lifecycle_management" {
  description = "Habilitar gerenciamento de lifecycle (economia de custos)"
  type        = bool
  default     = true
}

variable "versioning_enabled" {
  description = "Habilitar versionamento de blobs"
  type        = bool
  default     = false  # Economia de custos
}

variable "soft_delete_retention_days" {
  description = "Dias de retenção para soft delete"
  type        = number
  default     = 7
  
  validation {
    condition     = var.soft_delete_retention_days >= 1 && var.soft_delete_retention_days <= 365
    error_message = "Soft delete retention deve estar entre 1 e 365 dias."
  }
}

# Network Configuration
variable "network_rules" {
  description = "Regras de rede para a storage account"
  type = object({
    default_action             = string
    ip_rules                  = list(string)
    virtual_network_subnet_ids = list(string)
    bypass                    = list(string)
  })
  default = null
}

variable "key_vault_id" {
  description = "ID do Key Vault para armazenar connection string"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "ID do Log Analytics workspace para diagnósticos"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}
