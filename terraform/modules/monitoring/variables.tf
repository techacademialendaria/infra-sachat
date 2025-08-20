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

variable "daily_data_cap_gb" {
  description = "Limite diário em GB para Application Insights"
  type        = number
  default     = 0.1
}

variable "retention_days" {
  description = "Dias de retenção dos dados"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}