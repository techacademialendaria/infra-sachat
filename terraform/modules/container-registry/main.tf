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

  # Retention policy para economizar espaço (configurado via policy)
  # Note: retention_policy_in_days não é mais argumento direto no azurerm 4.13+
  trust_policy_enabled = var.trust_policy_enabled
  
  # Webhooks não são mais configurados aqui no azurerm 4.13+
  # Serão configurados via azurerm_container_registry_webhook resource se necessário

  tags = var.tags
}

# Service Principal para GitHub Actions (simplificado - configurar manualmente)
# Comentado para evitar problemas de permissão 403
# resource "azurerm_user_assigned_identity" "registry" {
#   name                = "${var.app_name}-registry-identity"
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   
#   tags = var.tags
# }

# Role assignments comentados para evitar erro 403 AuthorizationFailed
# Configurar manualmente via Azure CLI após deployment:
# az role assignment create --assignee <principal-id> --role "AcrPush" --scope <registry-id>
# az role assignment create --assignee <principal-id> --role "AcrPull" --scope <registry-id>

# resource "azurerm_role_assignment" "registry_push" {
#   scope                = azurerm_container_registry.main.id
#   role_definition_name = "AcrPush"
#   principal_id         = azurerm_user_assigned_identity.registry.principal_id
# }
# 
# resource "azurerm_role_assignment" "registry_pull" {
#   scope                = azurerm_container_registry.main.id
#   role_definition_name = "AcrPull"
#   principal_id         = azurerm_user_assigned_identity.registry.principal_id
# }

# Container Registry Tasks são complexos no Azure provider 4.13+
# Usando GitHub Actions para builds (mais simples e confiável)
# Tasks serão configuradas via portal Azure ou Azure CLI se necessário
