# 🌐 COSMOSDB MODULE - VARIABLES

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

variable "database_name" {
  description = "Nome do database (deve ser LibreChat para compatibilidade)"
  type        = string
  default     = "LibreChat"
}

variable "collections" {
  description = "Collections para criar (baseadas na aplicação atual)"
  type        = list(string)
  default     = ["conversations", "users", "messages"]
}

variable "consistency_level" {
  description = "Nível de consistência do CosmosDB"
  type        = string
  default     = "Session"
  
  validation {
    condition = contains([
      "BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"
    ], var.consistency_level)
    error_message = "Consistency level deve ser válido."
  }
}

variable "enable_automatic_failover" {
  description = "Habilitar failover automático (custo adicional)"
  type        = bool
  default     = false  # Economia para projeto inicial
}

variable "enable_free_tier" {
  description = "Habilitar free tier (se disponível na subscription)"
  type        = bool
  default     = true
}

variable "allowed_ips" {
  description = "IPs permitidos para acesso (opcional)"
  type        = list(string)
  default     = null  # Aberto por padrão
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
