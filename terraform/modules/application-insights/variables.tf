# 📊 APPLICATION INSIGHTS MODULE - VARIABLES

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

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 7 && var.log_retention_days <= 730
    error_message = "Log retention deve estar entre 7 e 730 dias."
  }
}

variable "daily_quota_gb" {
  description = "Quota diária de logs em GB (100MB = 0.1GB)"
  type        = number
  default     = 0.1  # 100MB por dia = ~3GB/mês (dentro do free tier)
  
  validation {
    condition     = var.daily_quota_gb >= 0.1 && var.daily_quota_gb <= 100
    error_message = "Daily quota deve estar entre 0.1GB (100MB) e 100GB."
  }
}

variable "sampling_percentage" {
  description = "Porcentagem de sampling para Application Insights"
  type        = number
  default     = 100  # 100% para desenvolvimento, pode reduzir em produção alta escala
  
  validation {
    condition     = var.sampling_percentage >= 0.1 && var.sampling_percentage <= 100
    error_message = "Sampling percentage deve estar entre 0.1 e 100."
  }
}

variable "disable_ip_masking" {
  description = "Desabilitar mascaramento de IP (para debugging)"
  type        = bool
  default     = false  # Por privacidade, manter IPs mascarados
}

# Alertas e Notificações
variable "enable_alerts" {
  description = "Habilitar alertas automáticos"
  type        = bool
  default     = true
}

variable "container_app_ids" {
  description = "IDs das Container Apps para monitoramento"
  type        = list(string)
  default     = []
}

variable "frontend_url" {
  description = "URL do frontend para availability test"
  type        = string
  default     = null
}

variable "webhook_receivers" {
  description = "Webhooks para notificações (Teams, Slack, etc)"
  type = list(object({
    name        = string
    service_uri = string
  }))
  default = []
}

variable "email_receivers" {
  description = "Emails para receber alertas"
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "admin_emails" {
  description = "Emails dos administradores para smart detection"
  type        = list(string)
  default     = []
}

# Dashboard
variable "create_dashboard" {
  description = "Criar dashboard personalizado"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}
