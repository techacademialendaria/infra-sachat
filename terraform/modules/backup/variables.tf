variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Região do Azure"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (staging, production)"
  type        = string
}

variable "storage_account_id" {
  description = "ID da Storage Account para backup"
  type        = string
}

variable "mongodb_server_name" {
  description = "Nome do servidor MongoDB (para referência)"
  type        = string
  default     = ""
}

variable "enable_storage_backup" {
  description = "Habilitar backup da Storage Account"
  type        = bool
  default     = true
}

variable "daily_retention_days" {
  description = "Dias de retenção do backup diário"
  type        = number
  default     = 30
}

variable "weekly_retention_weeks" {
  description = "Semanas de retenção do backup semanal"
  type        = number
  default     = 12
}

variable "monthly_retention_months" {
  description = "Meses de retenção do backup mensal"
  type        = number
  default     = 12
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}