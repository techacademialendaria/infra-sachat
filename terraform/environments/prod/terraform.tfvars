# 🚀 SUPERCHAT - CONFIGURAÇÃO DE PRODUÇÃO
# Migração fiel do docker-compose.yml local para Azure Container Apps

# Configurações Básicas
resource_group_name = "rg-superchat-production-210825"
location            = "brazilsouth"
app_name            = "superchat"
environment         = "production"

# Scaling Configuration (baseado no uso atual: 1.1GB RAM total)
scaling_config = {
  # API - equivalente ao LibreChat-API (411MB atual → 2GB Azure)
  api = {
    min_replicas = 2     # Alta disponibilidade
    max_replicas = 10    # Para 2000 usuários
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

  # Meilisearch - equivalente ao chat-meilisearch (109MB atual → 1GB Azure)
  meilisearch = {
    min_replicas = 1     # Sempre disponível para busca
    max_replicas = 3     # Busca não precisa de muito scale
    cpu          = 0.5   # 0.5 vCPU
    memory       = "1Gi" # 1GB (compatível com v1.12.3)
  }

  # RAG API - equivalente ao rag_api (208MB atual → 1GB Azure)
  rag_api = {
    min_replicas = 1     # Pode scale to zero se configurado
    max_replicas = 5     # Para processamento de documentos
    cpu          = 0.5   # 0.5 vCPU
    memory       = "1Gi" # 1GB (suficiente para pgvector)
  }
}

# CosmosDB Configuration (substitui MongoDB local)
cosmosdb_config = {
  consistency_level         = "Session"   # Equivalente ao MongoDB
  enable_automatic_failover = false       # Economia de custos
  database_name             = "LibreChat" # Mesmo nome do .env
  collections = [
    "conversations", # Conversas dos usuários
    "users",         # Dados dos usuários  
    "messages"       # Mensagens das conversas
  ]
}

# PostgreSQL Configuration (substitui container vectordb)
postgresql_config = {
  version       = "14"              # Compatível com pgvector
  sku_name      = "B_Standard_B1ms" # 1 vCore, 2GB RAM (equivalente ao container)
  storage_mb    = 32768             # 32GB para vetores
  database_name = "mydatabase"      # Mesmo nome do docker-compose
  admin_user    = "myuser"          # Mesmo user do docker-compose
}

# Storage Configuration (substitui volumes locais Docker)
storage_config = {
  account_tier     = "Standard" # Custo-benefício
  replication_type = "LRS"      # Local Redundant (economia)
  containers = [
    "images",  # Substitui ./images (308K atual)
    "uploads", # Substitui ./uploads (44K atual)  
    "logs"     # Substitui ./logs (580K atual)
  ]
}

# Domain Configuration (mantém domínio atual)
domain_config = {
  domain_name = "chat.superagentes.ai" # Domínio atual com SSL
  enable_ssl  = true                   # Manter HTTPS
}

# Budget Limit
budget_limit = 150 # $150/mês conforme requisito

# Infracost Configuration
infracost_config = {
  currency = "USD" # Dólar americano
  enabled  = true  # Monitoramento ativo
}

# GitHub Integration (configurar com valores reais)
github_org    = "superagentes"        # Seu usuário/org GitHub
source_repo   = "legendschat"         # Repositório com LibreChat
source_branch = "main"                # Branch para auto-build
github_token  = "SET_VIA_ENVIRONMENT" # Export TF_VAR_github_token=ghp_xxx

# PostgreSQL Admin Password (configurar com valor real)
postgresql_admin_password = "SET_VIA_ENVIRONMENT" # Export TF_VAR_postgresql_admin_password=xxx

# Tags específicas da migração
default_tags = {
  Environment  = "production"
  Project      = "superchat"
  ManagedBy    = "terraform"
  MigratedFrom = "docker-compose-local"
  StorageType  = "local-to-azure-storage"
  Owner        = "superagentes"
  CostCenter   = "librechat-migration"
  Domain       = "chat.superagentes.ai"

  # Informações da aplicação atual
  OriginalRAM   = "1.1GB-total"
  OriginalData  = "4.1MB-mongodb"
  OriginalFiles = "352K-local-files"
}
