resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmos-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  offer_type          = "Standard"
  kind                = "MongoDB"
  
  enable_automatic_failover = var.enable_high_availability
  
  capabilities {
    name = "EnableMongo"
  }
  
  capabilities {
    name = "MongoDBv3.4"
  }
  
  consistency_policy {
    consistency_level = "Session"
  }
  
  geo_location {
    location          = var.location
    failover_priority = 0
  }

  tags = var.tags
}

# Gerar senha aleatória para MongoDB
resource "random_password" "mongodb_password" {
  length  = 32
  special = true
}

# Database MongoDB
resource "azurerm_cosmosdb_mongo_database" "librechat" {
  name                = "LibreChat"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.main.name
  
  throughput = var.compute_tier == "M25" ? 400 : var.compute_tier == "M30" ? 1000 : 4000
}