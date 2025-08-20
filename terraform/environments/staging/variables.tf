variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
  default     = "rg-sachat-staging"
}

variable "location" {
  description = "Região do Azure"
  type        = string
  default     = "East US"
}

variable "domain_name" {
  description = "Nome do domínio para staging"
  type        = string
  default     = "staging.chat2.superagentes.ai"
}

variable "environment" {
  description = "Ambiente (staging)"
  type        = string
  default     = "staging"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "sachat"
}

# Configurações específicas do staging
variable "enable_high_availability" {
  description = "Habilitar alta disponibilidade (desabilitado em staging)"
  type        = bool
  default     = false
}

variable "min_replicas" {
  description = "Número mínimo de réplicas para staging"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Número máximo de réplicas para staging"
  type        = number
  default     = 2
}


variable "compute_tier" {
  description = "Tier de computação para o cluster MongoDB em staging"
  type        = string
  default     = "M25"  # Menor tier para staging
}

variable "application_insights_daily_cap_gb" {
  description = "Limite diário do Application Insights em GB"
  type        = number
  default     = 0.05  # 50MB para staging
}