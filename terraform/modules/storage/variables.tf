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
  default     = "GRS" # Geographic redundancy for compliance
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

variable "key_vault_id" {
  description = "ID do Key Vault para customer-managed encryption"
  type        = string
}

variable "storage_encryption_key_name" {
  description = "Nome da chave de encriptação do storage no Key Vault"
  type        = string
  default     = "storage-encryption-key"
}