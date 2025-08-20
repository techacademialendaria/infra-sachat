variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Região do Azure"
  type        = string
}

variable "container_app_environment_id" {
  description = "ID do Container App Environment"
  type        = string
}

variable "storage_account_name" {
  description = "Nome da Storage Account"
  type        = string
}

variable "storage_account_key" {
  description = "Chave da Storage Account"
  type        = string
  sensitive   = true
}

variable "mongodb_connection_string" {
  description = "String de conexão do MongoDB"
  type        = string
  sensitive   = true
}

variable "application_insights_key" {
  description = "Chave do Application Insights"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (staging, production)"
  type        = string
}

# Container App Configuration
variable "min_replicas" {
  description = "Número mínimo de réplicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Número máximo de réplicas"
  type        = number
  default     = 5
}

# Main App Container
variable "app_image" {
  description = "Imagem Docker da aplicação"
  type        = string
  default     = "ghcr.io/techacademialendaria/legendschat:latest"
}

variable "app_cpu" {
  description = "CPU para o container da aplicação"
  type        = number
  default     = 1.0
}

variable "app_memory" {
  description = "Memória para o container da aplicação"
  type        = string
  default     = "2Gi"
}

# MeiliSearch Sidecar
variable "meilisearch_image" {
  description = "Imagem do MeiliSearch"
  type        = string
  default     = "getmeili/meilisearch:v1.12.3"
}

variable "meilisearch_cpu" {
  description = "CPU para MeiliSearch"
  type        = number
  default     = 0.5
}

variable "meilisearch_memory" {
  description = "Memória para MeiliSearch"
  type        = string
  default     = "1Gi"
}

# RAG API Sidecar
variable "rag_api_image" {
  description = "Imagem do RAG API"
  type        = string
  default     = "ghcr.io/danny-avila/librechat-rag-api-dev-lite:latest"
}

variable "rag_api_cpu" {
  description = "CPU para RAG API"
  type        = number
  default     = 0.5
}

variable "rag_api_memory" {
  description = "Memória para RAG API"
  type        = string
  default     = "1Gi"
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}