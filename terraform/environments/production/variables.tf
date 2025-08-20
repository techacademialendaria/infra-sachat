variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "rg-sachat-prod"
}

variable "location" {
  description = "Região do Azure"
  type        = string
  default     = "East US"
}

variable "domain_name" {
  description = "Nome do domínio para produção"
  type        = string
  default     = "chat2.superagentes.ai"
}

variable "environment" {
  description = "Ambiente (production)"
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "sachat"
}

# Configurações específicas da produção
variable "enable_high_availability" {
  description = "Habilitar alta disponibilidade"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Habilitar backup automático"
  type        = bool
  default     = true
}

variable "min_replicas" {
  description = "Número mínimo de réplicas para produção"
  type        = number
  default     = 2
}

variable "max_replicas" {
  description = "Número máximo de réplicas para produção"
  type        = number
  default     = 10
}


variable "compute_tier" {
  description = "Tier de computação para o cluster MongoDB em produção"
  type        = string
  default     = "M40"  # Tier mais potente para produção
}

variable "application_insights_daily_cap_gb" {
  description = "Limite diário do Application Insights em GB"
  type        = number
  default     = 0.1  # 100MB para produção
}

# Configurações de rede para produção
variable "enable_private_endpoint" {
  description = "Habilitar private endpoints"
  type        = bool
  default     = false  # Pode ser habilitado para máxima segurança
}

variable "allowed_ip_ranges" {
  description = "Faixas de IP permitidas para acesso"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Aberto por padrão, restringir conforme necessário
}

# Configurações de monitoramento
variable "enable_log_analytics" {
  description = "Habilitar Log Analytics"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 30
}