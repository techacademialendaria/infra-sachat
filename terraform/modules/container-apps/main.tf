# 🚀 CONTAINER APPS MODULE - SUBSTITUI DOCKER COMPOSE
# 4 aplicações: API, Frontend, Meilisearch, RAG API 

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13.0"
    }
  }
}

# Container Apps Environment (usa Log Analytics do Application Insights)
resource "azurerm_container_app_environment" "main" {
  name                       = "${var.app_name}-env"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = var.log_analytics_workspace_id

  tags = var.tags
}

# User Assigned Identity para Container Registry access
resource "azurerm_user_assigned_identity" "container_apps" {
  name                = "${var.app_name}-container-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Role assignment para acessar Container Registry
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.container_apps.principal_id
}

# 1. MEILISEARCH APP (equivalente ao chat-meilisearch)
resource "azurerm_container_app" "meilisearch" {
  name                         = "meilisearch"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps.id]
  }

  registry {
    server   = var.container_registry_login_server
    identity = azurerm_user_assigned_identity.container_apps.id
  }

  template {
    min_replicas = var.meilisearch_config.min_replicas
    max_replicas = var.meilisearch_config.max_replicas

    container {
      name   = "meilisearch"
      image  = var.meilisearch_config.image
      cpu    = var.meilisearch_config.cpu
      memory = var.meilisearch_config.memory

      # Environment variables equivalentes ao docker-compose
      dynamic "env" {
        for_each = var.meilisearch_config.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      # Health probes - sintaxe correta para provider 4.13+
      liveness_probe {
        transport = "HTTP"
        port      = var.meilisearch_config.target_port
        path      = "/health"
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.meilisearch_config.target_port
        path      = "/health"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = false  # Internal only
    target_port               = var.meilisearch_config.target_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}

# 2. RAG API APP (equivalente ao rag_api)
resource "azurerm_container_app" "rag_api" {
  name                         = "rag-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps.id]
  }

  registry {
    server   = var.container_registry_login_server
    identity = azurerm_user_assigned_identity.container_apps.id
  }

  template {
    min_replicas = var.rag_api_config.min_replicas
    max_replicas = var.rag_api_config.max_replicas

    container {
      name   = "rag-api"
      image  = var.rag_api_config.image
      cpu    = var.rag_api_config.cpu
      memory = var.rag_api_config.memory

      # Environment variables equivalentes ao docker-compose
      dynamic "env" {
        for_each = var.rag_api_config.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      # Connection string do PostgreSQL (substitui DB_HOST=vectordb)
      env {
        name  = "DB_HOST"
        value = var.postgresql_host
      }

      # Health probes - sintaxe correta para provider 4.13+
      liveness_probe {
        transport = "HTTP"
        port      = var.rag_api_config.target_port
        path      = "/health"
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.rag_api_config.target_port
        path      = "/health"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = false  # Internal only
    target_port               = var.rag_api_config.target_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags

  depends_on = [azurerm_container_app.meilisearch]
}

# 3. LIBRECHAT API APP (equivalente ao LibreChat-API)
resource "azurerm_container_app" "api" {
  name                         = "librechat-api"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps.id]
  }

  registry {
    server   = var.container_registry_login_server
    identity = azurerm_user_assigned_identity.container_apps.id
  }

  template {
    min_replicas = var.api_config.min_replicas
    max_replicas = var.api_config.max_replicas

    container {
      name   = "librechat-api"
      image  = var.api_config.image
      cpu    = var.api_config.cpu
      memory = var.api_config.memory

      # Environment variables equivalentes ao docker-compose
      dynamic "env" {
        for_each = var.api_config.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      # Connection strings (substitui volumes e network internos)
      env {
        name  = "MONGO_URI"
        value = var.mongodb_connection_string
      }

      env {
        name  = "AZURE_STORAGE_CONNECTION_STRING"
        value = var.storage_connection_string
      }

      env {
        name  = "MEILI_HOST"
        value = "https://${azurerm_container_app.meilisearch.latest_revision_fqdn}"
      }

      env {
        name  = "RAG_API_URL"
        value = "https://${azurerm_container_app.rag_api.latest_revision_fqdn}"
      }

      # Application Insights para monitoramento
      dynamic "env" {
        for_each = var.application_insights_connection_string != null ? [1] : []
        content {
          name  = "APPLICATIONINSIGHTS_CONNECTION_STRING"
          value = var.application_insights_connection_string
        }
      }

      # Health probes - sintaxe correta para provider 4.13+
      liveness_probe {
        transport = "HTTP"
        port      = var.api_config.target_port
        path      = "/api/health"
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.api_config.target_port
        path      = "/api/health"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = false  # Internal only (Frontend vai proxy)
    target_port               = var.api_config.target_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_container_app.meilisearch,
    azurerm_container_app.rag_api
  ]
}

# 4. FRONTEND APP (equivalente ao LibreChat-NGINX)
resource "azurerm_container_app" "frontend" {
  name                         = "librechat-frontend"
  container_app_environment_id = azurerm_container_app_environment.main.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.container_apps.id]
  }

  registry {
    server   = var.container_registry_login_server
    identity = azurerm_user_assigned_identity.container_apps.id
  }

  template {
    min_replicas = var.frontend_config.min_replicas
    max_replicas = var.frontend_config.max_replicas

    container {
      name   = "librechat-frontend"
      image  = var.frontend_config.image
      cpu    = var.frontend_config.cpu
      memory = var.frontend_config.memory

      # Environment variables para NGINX
      env {
        name  = "API_URL"
        value = "https://${azurerm_container_app.api.latest_revision_fqdn}"
      }

      # Health probes - sintaxe correta para provider 4.13+
      liveness_probe {
        transport = "HTTP"
        port      = var.frontend_config.target_port
        path      = "/"
      }

      readiness_probe {
        transport = "HTTP"
        port      = var.frontend_config.target_port
        path      = "/"
      }
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = true   # EXTERNAL - será o ponto de entrada
    target_port               = var.frontend_config.target_port

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    # NOTA: custom_domain foi removido pois é gerenciado automaticamente pelo Azure
    # Para domínios personalizados, usar o recurso azurerm_container_app_custom_domain separadamente
  }

  tags = var.tags

  depends_on = [azurerm_container_app.api]
}
