# 🚀 CONTAINER APPS MODULE - VARIABLES

variable "resource_group_name" {
  description = "Nome do resource group"
  type        = string
}

variable "location" {
  description = "Localização do Azure"
  type        = string
}

variable "app_name" {
  description = "Nome da aplicação (prefixo)"
  type        = string
}

variable "log_retention_days" {
  description = "Dias de retenção dos logs"
  type        = number
  default     = 30
}

# Container Registry Configuration
variable "container_registry_id" {
  description = "ID do Container Registry"
  type        = string
}

variable "container_registry_login_server" {
  description = "Login server do Container Registry"
  type        = string
}

# Connection Strings (de outros módulos)
variable "mongodb_connection_string" {
  description = "Connection string do CosmosDB (substitui MONGO_URI)"
  type        = string
  sensitive   = true
}

variable "postgresql_connection_string" {
  description = "Connection string do PostgreSQL"
  type        = string
  sensitive   = true
}

variable "postgresql_host" {
  description = "Host do PostgreSQL (para DB_HOST)"
  type        = string
}

variable "storage_connection_string" {
  description = "Connection string do Azure Storage"
  type        = string
  sensitive   = true
}

# API Configuration (equivalente ao LibreChat-API)
variable "api_config" {
  description = "Configuração da API (substitui LibreChat-API container)"
  type = object({
    name          = string
    image         = string
    target_port   = number
    min_replicas  = number
    max_replicas  = number
    cpu           = number
    memory        = string
    env_vars      = map(string)
  })

  default = {
    name          = "librechat-api"
    image         = "superchatregistry.azurecr.io/librechat-api:latest"
    target_port   = 3080
    min_replicas  = 2
    max_replicas  = 10
    cpu           = 1.0
    memory        = "2Gi"
    env_vars = {
      HOST                = "0.0.0.0"
      NODE_ENV           = "production"
      RAG_PORT           = "8000"
      fileStrategy       = "azure"
    }
  }
}

# Frontend Configuration (equivalente ao LibreChat-NGINX)
variable "frontend_config" {
  description = "Configuração do Frontend (substitui LibreChat-NGINX container)"
  type = object({
    name          = string
    image         = string
    target_port   = number
    min_replicas  = number
    max_replicas  = number
    cpu           = number
    memory        = string
    nginx_config  = bool
  })

  default = {
    name          = "librechat-frontend"
    image         = "superchatregistry.azurecr.io/librechat-frontend:latest"
    target_port   = 80
    min_replicas  = 1
    max_replicas  = 5
    cpu           = 0.25
    memory        = "0.5Gi"
    nginx_config  = true
  }
}

# Meilisearch Configuration (equivalente ao chat-meilisearch)
variable "meilisearch_config" {
  description = "Configuração do Meilisearch (substitui chat-meilisearch container)"
  type = object({
    name          = string
    image         = string
    target_port   = number
    min_replicas  = number
    max_replicas  = number
    cpu           = number
    memory        = string
    env_vars      = map(string)
  })

  default = {
    name          = "meilisearch"
    image         = "getmeili/meilisearch:v1.12.3"  # Mesma versão do docker-compose
    target_port   = 7700
    min_replicas  = 1
    max_replicas  = 3
    cpu           = 0.5
    memory        = "1Gi"
    env_vars = {
      MEILI_NO_ANALYTICS = "true"
      MEILI_HOST        = "http://meilisearch:7700"
    }
  }
}

# RAG API Configuration (equivalente ao rag_api)
variable "rag_api_config" {
  description = "Configuração da RAG API (substitui rag_api container)"
  type = object({
    name          = string
    image         = string
    target_port   = number
    min_replicas  = number
    max_replicas  = number
    cpu           = number
    memory        = string
    env_vars      = map(string)
  })

  default = {
    name          = "rag-api"
    image         = "ghcr.io/danny-avila/librechat-rag-api-dev-lite:latest"  # Mesma imagem
    target_port   = 8000
    min_replicas  = 1
    max_replicas  = 5
    cpu           = 0.5
    memory        = "1Gi"
    env_vars = {
      RAG_PORT = "8000"
    }
  }
}

# Custom Domain Configuration (equivalente ao SSL do docker-compose)
variable "custom_domain" {
  description = "Configuração de domínio customizado (substitui SSL do NGINX)"
  type = object({
    domain_name    = string
    certificate_id = string
  })
  default = null
}

variable "tags" {
  description = "Tags para recursos"
  type        = map(string)
  default     = {}
}
