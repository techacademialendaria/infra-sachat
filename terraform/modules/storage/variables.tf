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

variable "replication_type" {
  description = "Tipo de replicação da storage account"
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}