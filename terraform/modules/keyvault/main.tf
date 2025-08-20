# Get current client configuration
data "azurerm_client_config" "current" {}

# Key Vault for encryption keys
resource "azurerm_key_vault" "main" {
  name                       = "kv-${var.project_name}-${var.environment}-v3"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium" # Premium for HSM support
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  # Network access restrictions - allow Azure services during deployment
  public_network_access_enabled = true

  network_acls {
    default_action = "Allow" # Temporary for deployment
    bypass         = "AzureServices"
  }

  tags = var.tags

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

# Access policy for the current service principal
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Update",
    "Recover",
    "Purge",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Purge",
  ]

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Key for CosmosDB encryption
resource "azurerm_key_vault_key" "cosmosdb" {
  name         = "cosmosdb-encryption-key"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA" # Mudando para RSA standard temporariamente
  key_size     = 2048

  # Set expiration date (1 year from now)
  expiration_date = timeadd(timestamp(), "8760h")

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault_access_policy.terraform]

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# Key for Storage encryption
resource "azurerm_key_vault_key" "storage" {
  name         = "storage-encryption-key"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA" # Mudando para RSA standard temporariamente
  key_size     = 2048

  # Set expiration date (1 year from now)
  expiration_date = timeadd(timestamp(), "8760h")

  key_opts = [
    "decrypt",
    "encrypt",
    "unwrapKey",
    "wrapKey",
  ]

  depends_on = [azurerm_key_vault_access_policy.terraform]

  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

# TODO: Re-enable after initial deployment
# Private endpoint for Key Vault
# resource "azurerm_private_endpoint" "keyvault" {
#   name                = "pe-${azurerm_key_vault.main.name}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id

#   private_service_connection {
#     name                           = "psc-${azurerm_key_vault.main.name}"
#     private_connection_resource_id = azurerm_key_vault.main.id
#     is_manual_connection           = false
#     subresource_names              = ["vault"]
#   }

#   tags = var.tags
# }
