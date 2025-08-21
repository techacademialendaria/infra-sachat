# 🚀 SUPERCHAT - VARIÁVEIS DE PRODUÇÃO
# Baseado na configuração atual do docker-compose.yml

variable "resource_group_name" {
  description = "Nome do Resource Group principal"
  type        = string
  default     = "rg-superchat-prod"
}

variable "location" {
  description = "Região Azure para deploy dos recursos"
  type        = string
  default     = "eastus"

  validation {
    condition = contains([
      "eastus", "eastus2", "westus2", "westus3",
      "centralus", "southcentralus", "westcentralus"
    ], var.location)
    error_message = "Location deve ser uma região Azure válida para Container Apps."
  }
}

variable "app_name" {
  description = "Nome da aplicação (usado como prefixo)"
  type        = string
  default     = "superchat"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.app_name))
    error_message = "App name deve ter entre 3-24 caracteres, apenas letras minúsculas e números."
  }
}

variable "environment" {
  description = "Ambiente de deploy"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment deve ser: development, staging ou production."
  }
}

# Configurações de Scaling (baseadas no uso atual de 1.1GB RAM total)
variable "scaling_config" {
  description = "Configurações de auto-scaling para Container Apps"
  type = object({
    api = object({
      min_replicas = number
      max_replicas = number
      cpu          = number
      memory       = string
    })
    frontend = object({
      min_replicas = number
      max_replicas = number
      cpu          = number
      memory       = string
    })
    meilisearch = object({
      min_replicas = number
      max_replicas = number
      cpu          = number
      memory       = string
    })
    rag_api = object({
      min_replicas = number
      max_replicas = number
      cpu          = number
      memory       = string
    })
  })

  default = {
    # API - equivalente ao LibreChat-API (411MB atual)
    api = {
      min_replicas = 2     # Para alta disponibilidade
      max_replicas = 10    # Scale para 2000 usuários
      cpu          = 1.0   # 1 vCPU
      memory       = "2Gi" # 2GB (buffer para crescimento)
    }

    # Frontend - equivalente ao LibreChat-NGINX (leve)
    frontend = {
      min_replicas = 1       # Sempre disponível
      max_replicas = 5       # NGINX escala bem
      cpu          = 0.25    # 0.25 vCPU
      memory       = "0.5Gi" # 512MB
    }

    # Meilisearch - equivalente ao chat-meilisearch (109MB atual)
    meilisearch = {
      min_replicas = 1     # Pode ser 0 em desenvolvimento
      max_replicas = 3     # Busca não precisa de muito scale
      cpu          = 0.5   # 0.5 vCPU
      memory       = "1Gi" # 1GB (compatível com v1.12.3)
    }

    # RAG API - equivalente ao rag_api (208MB atual)
    rag_api = {
      min_replicas = 1     # Pode ser 0 quando sem uso
      max_replicas = 5     # Para processamento de documentos
      cpu          = 0.5   # 0.5 vCPU
      memory       = "1Gi" # 1GB (suficiente para pgvector)
    }
  }
}

# Database Configurations (equivalentes ao docker-compose)
variable "cosmosdb_config" {
  description = "Configurações do CosmosDB (equivalente ao MongoDB)"
  type = object({
    consistency_level         = string
    enable_automatic_failover = bool
    database_name             = string
    collections               = list(string)
  })

  default = {
    consistency_level         = "Session"   # Padrão do MongoDB
    enable_automatic_failover = false       # Economia de custos
    database_name             = "LibreChat" # Mesmo nome do docker-compose
    collections = [
      "conversations", # Conversas dos usuários
      "users",         # Dados dos usuários
      "messages"       # Mensagens das conversas
    ]
  }
}

variable "postgresql_config" {
  description = "Configurações do PostgreSQL (equivalente ao vectordb)"
  type = object({
    version       = string
    sku_name      = string
    storage_mb    = number
    database_name = string
    admin_user    = string
  })

  default = {
    version       = "14"              # Compatível com pgvector
    sku_name      = "B_Standard_B1ms" # 1 vCore, 2GB RAM - ideal para início
    storage_mb    = 32768             # 32GB - suficiente para vetores
    database_name = "mydatabase"      # Mesmo nome do docker-compose
    admin_user    = "myuser"          # Mesmo user do docker-compose
  }
}

# Storage Configuration (Azure Blob - substitui volumes locais)
variable "storage_config" {
  description = "Configurações do Azure Storage (substitui volumes locais)"
  type = object({
    account_tier     = string
    replication_type = string
    containers       = list(string)
  })

  default = {
    account_tier     = "Standard" # Custo-benefício
    replication_type = "LRS"      # Local Redundant (economia)
    containers = [
      "images",  # Substitui ./images (volume local)
      "uploads", # Substitui ./uploads (volume local)  
      "logs"     # Substitui ./logs (volume local)
    ]
  }
}

# Domain Configuration (equivalente ao SSL atual)
variable "domain_config" {
  description = "Configurações de domínio e SSL"
  type = object({
    domain_name = string
    enable_ssl  = bool
  })

  default = {
    domain_name = "chat.superagentes.ai" # Domínio atual
    enable_ssl  = true                   # Manter SSL ativo
  }
}

# Budget and Cost Management
variable "budget_limit" {
  description = "Limite de budget mensal em USD"
  type        = number
  default     = 150 # $150/mês conforme requisito

  validation {
    condition     = var.budget_limit > 0 && var.budget_limit <= 500
    error_message = "Budget deve estar entre $1 e $500 por mês."
  }
}

# Infracost Configuration
variable "infracost_config" {
  description = "Configurações do Infracost para monitoramento"
  type = object({
    currency = string
    enabled  = bool
  })

  default = {
    currency = "USD" # Moeda para cálculos
    enabled  = true  # Sempre ativo
  }
}

# GitHub Integration (para Container Registry auto-build)
variable "github_org" {
  description = "Organização/usuário GitHub"
  type        = string
  default     = "superagentes" # Ajustar conforme necessário
}

variable "source_repo" {
  description = "Repositório source com código LibreChat"
  type        = string
  default     = "legendschat"
}

variable "source_branch" {
  description = "Branch para trigger builds automáticos"
  type        = string
  default     = "main"
}

variable "github_token" {
  description = "GitHub Personal Access Token para acessar repositório"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.github_token) > 0
    error_message = "GitHub token é obrigatório para integração Container Registry."
  }
}

# PostgreSQL Admin Password
variable "postgresql_admin_password" {
  description = "Password do admin PostgreSQL"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.postgresql_admin_password) >= 8
    error_message = "Password deve ter pelo menos 8 caracteres."
  }
}

# Tags padrão
variable "default_tags" {
  description = "Tags padrão para todos os recursos"
  type        = map(string)

  default = {
    Environment  = "production"
    Project      = "superchat"
    ManagedBy    = "terraform"
    MigratedFrom = "docker-compose-local"
    StorageType  = "local-to-azure"
    Owner        = "superagentes"
    CostCenter   = "librechat-migration"
  }
}
