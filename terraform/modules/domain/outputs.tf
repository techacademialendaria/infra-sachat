output "dns_zone_name_servers" {
  description = "Name servers da zona DNS"
  value       = var.create_dns_zone ? azurerm_dns_zone.main[0].name_servers : []
}

output "dns_zone_name" {
  description = "Nome da zona DNS"
  value       = var.create_dns_zone ? azurerm_dns_zone.main[0].name : ""
}

output "domain_verification_txt" {
  description = "Valor TXT para verificação do domínio"
  value       = var.create_dns_zone ? [for record in azurerm_dns_txt_record.domain_verification[0].record : record.value][0] : ""
}