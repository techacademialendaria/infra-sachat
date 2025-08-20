output "app_url" {
  description = "URL da aplicação"
  value       = "https://${azurerm_container_app.main.latest_revision_fqdn}"
}

output "app_fqdn" {
  description = "FQDN da aplicação"
  value       = azurerm_container_app.main.latest_revision_fqdn
}

output "container_app_name" {
  description = "Nome do Container App"
  value       = azurerm_container_app.main.name
}

output "container_app_id" {
  description = "ID do Container App"
  value       = azurerm_container_app.main.id
}