# 🐘 POSTGRESQL MODULE - VARIABLES

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

variable "admin_user" {
  description = "Username do admin (deve ser 'myuser' para compatibilidade)"
  type        = string
  default     = "myuser"
}

variable "admin_password" {
  description = "Password do admin PostgreSQL"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.admin_password) >= 8
    error_message = "Password deve ter pelo menos 8 caracteres."
  }
}

variable "database_name" {
  description = "Nome do database (deve ser 'mydatabase' para compatibilidade)"
  type        = string
  default     = "mydatabase"
}

variable "postgresql_version" {
  description = "Versão do PostgreSQL"
  type        = string
  default     = "14"
  
  validation {
    condition     = contains(["11", "12", "13", "14", "15"], var.postgresql_version)
    error_message = "Versão PostgreSQL deve ser suportada."
  }
}

variable "sku_name" {
  description = "SKU do servidor (equivalente ao container vectordb)"
  type        = string
  default     = "B_Standard_B1ms"  # 1 vCore, 2GB - equivalente ao container
  
  validation {
    condition = can(regex("^(B_Standard_B[124]ms|GP_Standard_D[248]s_v3|MO_Standard_E[248]s_v3)$", var.sku_name))
    error_message = "SKU deve ser válido para PostgreSQL Flexible Server."
  }
}

variable "storage_mb" {
  description = "Storage em MB"
  type        = number
  default     = 32768  # 32GB para vetores
  
  validation {
    condition     = var.storage_mb >= 20480 && var.storage_mb <= 16777216
    error_message = "Storage deve estar entre 20GB e 16TB."
  }
}

variable "storage_tier" {
  description = "Tier do storage"
  type        = string
  default     = "P6"  # Performance tier para 32GB
}

variable "backup_retention_days" {
  description = "Dias de retenção do backup"
  type        = number
  default     = 7
  
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention deve estar entre 7 e 35 dias."
  }
}

variable "enable_pgvector" {
  description = "Habilitar extensão pgvector (equivalente ao ankane/pgvector:latest)"
  type        = bool
  default     = true
}

variable "high_availability_enabled" {
  description = "Habilitar high availability (custo adicional)"
  type        = bool
  default     = false  # Economia para projeto inicial
}

# Network Configuration
variable "delegated_subnet_id" {
  description = "ID da subnet delegada (para VNet integration)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "ID da DNS zone privada"
  type        = string
  default     = null
}

variable "public_access_enabled" {
  description = "Habilitar acesso público"
  type        = bool
  default     = true  # Para facilitar migração inicial
}

variable "allow_azure_services" {
  description = "Permitir acesso dos serviços Azure"
  type        = bool
  default     = true
}

variable "allowed_ip_ranges" {
  description = "Ranges de IP permitidos"
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = null
}

variable "key_vault_id" {
  description = "ID do Key Vault para armazenar connection string"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}
