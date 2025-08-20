resource "azurerm_dns_zone" "main" {
  count               = var.create_dns_zone ? 1 : 0
  name                = var.domain_name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Registro CNAME para o domínio apontar para o Container App
resource "azurerm_dns_cname_record" "main" {
  count               = var.create_dns_zone ? 1 : 0
  name                = "@"
  zone_name           = azurerm_dns_zone.main[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.container_app_fqdn

  tags = var.tags
}

# Registro TXT para verificação de domínio (será preenchido manualmente)
resource "azurerm_dns_txt_record" "domain_verification" {
  count               = var.create_dns_zone ? 1 : 0
  name                = "asuid"
  zone_name           = azurerm_dns_zone.main[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300

  record {
    value = var.domain_verification_code != "" ? var.domain_verification_code : "temporary-verification-code"
  }

  tags = var.tags
}

# Registro CNAME para www (opcional)
resource "azurerm_dns_cname_record" "www" {
  count               = var.create_dns_zone && var.create_www_record ? 1 : 0
  name                = "www"
  zone_name           = azurerm_dns_zone.main[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = var.container_app_fqdn

  tags = var.tags
}