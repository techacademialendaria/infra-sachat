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


variable "compute_tier" {
  description = "Tier de computação para o cluster MongoDB"
  type        = string
  default     = "M30"
}

variable "enable_high_availability" {
  description = "Habilitar alta disponibilidade"
  type        = bool
  default     = false
}


variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}