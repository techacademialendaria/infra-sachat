# 📦 CONTAINER REGISTRY MODULE - VARIABLES

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

variable "sku" {
  description = "SKU do Container Registry"
  type        = string
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU deve ser Basic, Standard ou Premium."
  }
}

variable "admin_enabled" {
  description = "Habilitar admin user"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Dias de retenção para imagens antigas"
  type        = number
  default     = 30
}

variable "trust_policy_enabled" {
  description = "Habilitar trust policy"
  type        = bool
  default     = false
}

# Network Rules
variable "network_rule_set" {
  description = "Regras de network access"
  type = object({
    default_action = string
    ip_rules = list(object({
      action   = string
      ip_range = string
    }))
  })
  default = null
}

# Webhooks para CI/CD
variable "webhooks" {
  description = "Webhooks para notificar CI/CD"
  type = list(object({
    name           = string
    service_uri    = string
    actions        = list(string)
    status         = string
    scope          = string
    custom_headers = map(string)
  }))
  default = []
}

# GitHub Integration
variable "github_org" {
  description = "Organização GitHub (ex: seu-usuario)"
  type        = string
  default     = "superagentes"  # Ajustar conforme necessário
}

variable "source_repo" {
  description = "Repositório source (legendschat)"
  type        = string
  default     = "legendschat"
}

variable "source_branch" {
  description = "Branch para trigger builds"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub Personal Access Token para acessar repo"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}
