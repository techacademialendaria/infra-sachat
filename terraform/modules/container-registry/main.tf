# 📦 AZURE CONTAINER REGISTRY MODULE
# Para otimizar builds e evitar rebuild toda vez

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.13.0"
    }
  }
}

# Container Registry Principal
resource "azurerm_container_registry" "main" {
  name                = "${var.app_name}registry"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Network access rules
  dynamic "network_rule_set" {
    for_each = var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }

  # Retention policy para economizar espaço
  retention_policy_in_days = var.retention_days
  trust_policy_enabled     = var.trust_policy_enabled
  
  # Webhook para notificar CI/CD
  dynamic "webhook" {
    for_each = var.webhooks
    content {
      name         = webhook.value.name
      service_uri  = webhook.value.service_uri
      actions      = webhook.value.actions
      status       = webhook.value.status
      scope        = webhook.value.scope
      custom_headers = webhook.value.custom_headers
    }
  }

  tags = var.tags
}

# Service Principal para GitHub Actions
resource "azurerm_user_assigned_identity" "registry" {
  name                = "${var.app_name}-registry-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  tags = var.tags
}

# Role assignment para push/pull
resource "azurerm_role_assignment" "registry_push" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.registry.principal_id
}

resource "azurerm_role_assignment" "registry_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.registry.principal_id
}

# Tarefas de build automáticas (substitui GitHub Actions locais)
resource "azurerm_container_registry_task" "api_build" {
  name                  = "build-librechat-api"
  container_registry_id = azurerm_container_registry.main.id
  
  platform {
    os           = "Linux"
    architecture = "amd64"
  }

  docker_step {
    dockerfile_path      = "Dockerfile.multi"
    context_path         = "https://github.com/${var.github_org}/${var.source_repo}.git"
    context_access_token = var.github_token
    target               = "api-build"
    image_names          = ["librechat-api:{{.Run.ID}}", "librechat-api:latest"]
    cache_enabled        = true
  }

  # Trigger no push do branch main
  source_trigger {
    name           = "main-trigger"
    events         = ["commit"]
    repository_url = "https://github.com/${var.github_org}/${var.source_repo}.git"
    source_type    = "Github"
    branch         = var.source_branch
    
    authentication {
      token      = var.github_token
      token_type = "PAT"
    }
  }

  tags = var.tags
}

# Task para Meilisearch (pull da imagem oficial)
resource "azurerm_container_registry_task" "meilisearch_import" {
  name                  = "import-meilisearch"
  container_registry_id = azurerm_container_registry.main.id
  
  platform {
    os           = "Linux" 
    architecture = "amd64"
  }

  docker_step {
    dockerfile_path = "Dockerfile.meilisearch"
    context_path    = "."
    image_names     = ["meilisearch:v1.12.3", "meilisearch:latest"]
    cache_enabled   = true
  }

  tags = var.tags
}

# Task para RAG API (pull da imagem oficial)  
resource "azurerm_container_registry_task" "rag_api_import" {
  name                  = "import-rag-api"
  container_registry_id = azurerm_container_registry.main.id
  
  platform {
    os           = "Linux"
    architecture = "amd64" 
  }

  docker_step {
    dockerfile_path = "Dockerfile.rag"
    context_path    = "."
    image_names     = ["rag-api:latest"]
    cache_enabled   = true
  }

  tags = var.tags
}

# Dockerfile temporários para imports
resource "local_file" "meilisearch_dockerfile" {
  filename = "${path.module}/Dockerfile.meilisearch"
  content  = <<-EOT
FROM getmeili/meilisearch:v1.12.3
LABEL maintainer="superchat-migration"
EOT
}

resource "local_file" "rag_dockerfile" {
  filename = "${path.module}/Dockerfile.rag"
  content  = <<-EOT
FROM ghcr.io/danny-avila/librechat-rag-api-dev-lite:latest
LABEL maintainer="superchat-migration"
EOT
}
