# Container App Principal (API + Frontend)
resource "azurerm_container_app" "main" {
  name                         = "ca-${var.project_name}-${var.environment}"
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = var.resource_group_name
  revision_mode               = "Single"

  secret {
    name  = "mongodb-connection-string"
    value = var.mongodb_connection_string
  }

  secret {
    name  = "storage-account-key"
    value = var.storage_account_key
  }

  secret {
    name  = "application-insights-key"
    value = var.application_insights_key
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    # Container principal - LibreChat (API + Frontend)
    container {
      name   = "librechat"
      image  = var.app_image
      cpu    = var.app_cpu
      memory = var.app_memory

      env {
        name  = "HOST"
        value = "0.0.0.0"
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      env {
        name        = "MONGO_URI"
        secret_name = "mongodb-connection-string"
      }

      env {
        name  = "AZURE_STORAGE_ACCOUNT_NAME"
        value = var.storage_account_name
      }

      env {
        name        = "AZURE_STORAGE_ACCOUNT_KEY"
        secret_name = "storage-account-key"
      }

      env {
        name        = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "application-insights-key"
      }

      env {
        name  = "FILE_STRATEGY"
        value = "azure"
      }

      env {
        name  = "MEILI_HOST"
        value = "http://localhost:7700"
      }

      env {
        name  = "RAG_API_URL"
        value = "http://localhost:8000"
      }

      env {
        name  = "AZURE_CONTAINER_NAME"
        value = "files"
      }

      env {
        name  = "AZURE_STORAGE_PUBLIC_ACCESS"
        value = "false"
      }
    }

    # MeiliSearch sidecar
    container {
      name   = "meilisearch"
      image  = var.meilisearch_image
      cpu    = var.meilisearch_cpu
      memory = var.meilisearch_memory

      env {
        name  = "MEILI_HOST"
        value = "http://localhost:7700"
      }

      env {
        name  = "MEILI_NO_ANALYTICS"
        value = "true"
      }

      volume_mounts {
        name = "meili-data"
        path = "/meili_data"
      }
    }

    # RAG API sidecar
    container {
      name   = "rag-api"
      image  = var.rag_api_image
      cpu    = var.rag_api_cpu
      memory = var.rag_api_memory

      env {
        name  = "RAG_PORT"
        value = "8000"
      }
    }

    volume {
      name         = "meili-data"
      storage_type = "EmptyDir"
    }
  }

  ingress {
    allow_insecure_connections = false
    external_enabled          = true
    target_port               = 3080

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  tags = var.tags
}