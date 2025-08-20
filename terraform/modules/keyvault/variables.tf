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

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "ID da subnet para private endpoint"
  type        = string
}
