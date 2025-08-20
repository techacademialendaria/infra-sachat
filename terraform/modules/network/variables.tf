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

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}