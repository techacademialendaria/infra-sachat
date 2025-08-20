resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "main" {
  name                     = "st${substr(var.project_name, 0, 4)}${substr(var.environment, 0, 4)}${random_string.storage_suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"

  # Security configurations - relaxed for deployment
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true # Allow during deployment
  shared_access_key_enabled       = true # Needed for containers

  # Customer-managed encryption
  identity {
    type = "SystemAssigned"
  }

  # Network rules - relaxed for deployment
  network_rules {
    default_action = "Allow" # Temporary for deployment
    bypass         = ["AzureServices"]
  }

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["DELETE", "GET", "HEAD", "MERGE", "POST", "OPTIONS", "PUT", "PATCH"]
      allowed_origins    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }

    # Enable soft delete
    delete_retention_policy {
      days = 7
    }

    # Enable versioning
    versioning_enabled = true
  }

  tags = var.tags
}

# TODO: Re-enable after initial deployment
# Private endpoint for storage account
# resource "azurerm_private_endpoint" "storage" {
#   name                = "pe-${azurerm_storage_account.main.name}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   subnet_id           = var.subnet_id

#   private_service_connection {
#     name                           = "psc-${azurerm_storage_account.main.name}"
#     private_connection_resource_id = azurerm_storage_account.main.id
#     is_manual_connection           = false
#     subresource_names              = ["blob"]
#   }

#   tags = var.tags
# }

# TODO: Re-enable after initial deployment
# Customer-managed encryption for storage account
# resource "azurerm_storage_account_customer_managed_key" "main" {
#   storage_account_id = azurerm_storage_account.main.id
#   key_vault_id       = var.key_vault_id
#   key_name           = var.storage_encryption_key_name

#   depends_on = [azurerm_storage_account.main]
# }

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "avatars" {
  name                  = "avatars"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "files" {
  name                  = "files"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}