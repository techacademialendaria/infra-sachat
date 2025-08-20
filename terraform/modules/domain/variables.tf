variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Região do Azure"
  type        = string
}

variable "domain_name" {
  description = "Nome do domínio"
  type        = string
}

variable "container_app_fqdn" {
  description = "FQDN do Container App"
  type        = string
}

variable "create_dns_zone" {
  description = "Criar zona DNS no Azure (só para production normalmente)"
  type        = bool
  default     = false
}

variable "create_www_record" {
  description = "Criar registro www CNAME"
  type        = bool
  default     = false
}

variable "domain_verification_code" {
  description = "Código de verificação do domínio (fornecido pelo Azure após criar custom domain)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}