# 🧠 CONTEXTO DE MIGRAÇÃO SUPERCHAT - MEMÓRIA PERMANENTE

## 🎯 OBJETIVO PRINCIPAL
**Migrar LibreChat de Docker Compose local para Azure Container Apps com Terraform IaC**

- **Nome do Projeto**: `superchat`
- **Budget**: $150/mês para 2000 usuários simultâneos
- **Estrutura Atual**: Docker Compose (deploy-compose.yml)
- **Estrutura Final**: Azure Container Apps (scale-to-zero)
- **IaC**: Terraform + Infracost

---

## 📊 ARQUITETURA ATUAL (Docker Compose)

### Serviços em Produção:
```yaml
✅ LibreChat-API (api):     Container Node.js - porta 3080
✅ LibreChat-NGINX (client): NGINX + SSL - portas 80/443  
✅ chat-mongodb:            MongoDB - porta 27017
✅ chat-meilisearch:        Meilisearch v1.12.3 - porta 7700
✅ vectordb:                PostgreSQL + pgvector
✅ rag_api:                 RAG API - porta 8000
```

### Configurações Críticas:
- **Domínio**: `chat.superagentes.ai` (SSL Let's Encrypt ativo)
- **Storage Atual**: Volumes locais Docker - `./images`, `./uploads`, `./logs`, `./data-node`, `./meili_data_v1.12`
- **Azure Storage**: 🚨 NÃO CONFIGURADO - será criado do zero na migração
- **Internal Network**: mongodb:27017, meilisearch:7700, rag_api:8000

---

## 🚀 ARQUITETURA FINAL (Azure)

### Container Apps (equivalência 1:1):
```
LibreChat-API    → superchat-api      (2-10 replicas)
LibreChat-NGINX  → superchat-frontend (1-5 replicas) 
chat-mongodb     → CosmosDB Serverless MongoDB API
chat-meilisearch → superchat-meilisearch (1-3 replicas)
vectordb         → PostgreSQL Flexible B1ms
rag_api          → superchat-rag-api (1-5 replicas)
```

### Recursos Azure:
- **Resource Group**: `rg-superchat-prod` (será criado)
- **Container Registry**: `superchatregistry.azurecr.io` (será criado)
- **Storage Account**: `superchatfiles` (será criado - para substituir volumes locais)
- **CosmosDB**: `superchat-cosmosdb` (será criado - ServerLess, MongoDB API)
- **PostgreSQL**: `superchat-postgresql` (será criado - pgvector, B1ms)
- **Container Apps Environment**: `superchat-env` (será criado)

---

## 📁 ESTRUTURA TERRAFORM

```
/infra-sachat/terraform/
├── environments/prod/         # Configuração de produção
│   ├── main.tf               # Configuração principal
│   ├── variables.tf          # Variáveis do ambiente
│   ├── terraform.tfvars      # Valores das variáveis
│   └── outputs.tf            # Outputs importantes
├── modules/                  # Módulos reutilizáveis
│   ├── cosmosdb/            # CosmosDB Serverless
│   ├── postgresql/          # PostgreSQL Flexible
│   ├── container-apps/      # Container Apps + Environment
│   ├── storage/             # Azure Storage Account
│   └── networking/          # Networking + DNS
├── infracost.yml            # Configuração Infracost
└── .terraform-version       # Versão Terraform
```

---

## ⚡ DADOS DA APLICAÇÃO ATUAL

### Uso de Recursos (baseado em logs):
- **Total RAM**: 1.1GB (API: 411MB, MongoDB: 322MB, RAG: 208MB, Meilisearch: 109MB)
- **MongoDB**: 4.1MB de dados (volumes locais)
- **Arquivos Locais**: 308K images + 44K uploads (volumes Docker)
- **Logs**: 580K (dispensáveis na migração)

### Custos Escaláveis:
- **Uso ATUAL**: ~$10/mês 
- **Uso BAIXO**: ~$35/mês (free tier Container Apps)
- **Uso ALTO**: ~$120/mês (2000 usuários simultâneos)

---

## 🏗️ STATUS ATUAL DA MIGRAÇÃO

### ✅ CONCLUÍDO:
- [x] Azure CLI configurado
- [x] Subscription ativa (Microsoft Azure Sponsorship)
- [x] Variáveis definidas (APP_NAME=superchat)
- [x] Análise do docker-compose.yml
- [x] Análise da estrutura atual

### ✅ CONCLUÍDO:
- [x] Criação dos módulos Terraform (5 módulos completos)
- [x] Configuração Infracost integrada
- [x] Setup do ambiente de produção
- [x] Container Registry com auto-build
- [x] GitHub Actions CI/CD cross-repo
- [x] Documentação de secrets e credenciais
- [x] **Segurança**: GitHub Secrets (sem arquivos de credenciais)
- [x] **.gitignore**: Proteção contra commit de secrets
- [x] **GitHub Actions**: Atualizadas para versões 2025 (v4, v2)
- [x] **Terraform Formatting**: Corrigido fmt em todos os arquivos
- [x] **Application Insights**: Módulo criado (100MB/dia, alertas, dashboard)
- [x] **Terraform Validation**: Corrigidos erros Azure provider 4.13+

### 📋 PRÓXIMOS PASSOS:
1. **Configurar Secrets GitHub** (GITHUB_SECRETS_SETUP.md)
2. **Executar Terraform Apply** (criar infraestrutura Azure)
3. **Testar Container Apps** (verificar se todas aplicações sobem)
4. **Data Migration**: MongoDB local → CosmosDB + volumes locais → Azure Storage  
5. **DNS Switch**: Apontar chat.superagentes.ai para novo frontend
6. **Monitoring**: Configurar alertas e dashboards
7. **Performance Test**: Validar com carga real

---

## 📄 CONFIGURAÇÃO ATUAL (.env)

### **Storage Configuration:**
```bash
# Azure Storage - NÃO CONFIGURADO (será criado na migração)
AZURE_STORAGE_CONNECTION_STRING=    # ← VAZIO!
AZURE_CONTAINER_NAME=files          # ← Apenas placeholder

# MongoDB Local - ATIVO
MONGO_URI=mongodb://127.0.0.1:27017/SA Chat
```

### **Providers Ativos:**
- **OpenAI**: `sk-proj-***` (configurado)
- **Anthropic**: `sk-ant-api03-***` (configurado)
- **Google**: `AIzaSyBtITN74***` (configurado)
- **DeepSeek**: `sk-3a4f1fd2534***` (configurado)
- **XAI**: `xai-Jd3xWxpZrGY8***` (configurado)

### **Serviços Externos:**
- **Meilisearch**: Local (porta 7700)
- **PostgreSQL**: Container vectordb
- **Volumes**: Todos locais Docker

### **Domínio e SSL:**
- **Domain**: `chat.superagentes.ai`
- **SSL**: Let's Encrypt (via NGINX)

---

## 🛠️ COMANDOS ESSENCIAIS

### Terraform:
```bash
cd /home/ubuntu/sa/infra-sachat/terraform/environments/prod
terraform init
terraform plan
terraform apply
```

### Docker Atual:
```bash
cd /home/ubuntu/sa/legendschat
docker compose -f ./deploy-compose.yml up -d --build
```

### Azure:
```bash
export RESOURCE_GROUP="rg-superchat-prod"
export LOCATION="eastus"
export APP_NAME="superchat"
```

---

## 🔥 PRINCÍPIOS DA MIGRAÇÃO

### 1. **Fidelidade ao Original**
- Manter TODAS as funcionalidades atuais
- Zero downtime na transição
- Mesmo domínio e SSL

### 2. **Scale-to-Zero**
- CosmosDB Serverless (paga por request)
- Container Apps auto-scaling
- $0 quando sem uso

### 3. **Infrastructure as Code**
- Terraform para tudo
- Infracost para custos
- Versionamento completo

### 4. **Preparação para CI/CD**
- GitHub Actions ready
- Container Registry integrado
- Rollback automático

---

## 🚨 LEMBRETE CRÍTICO

**SEMPRE consultar este arquivo antes de qualquer ação!**

- **Estrutura atual**: docker-compose.yml é a fonte da verdade
- **Objetivo**: Azure Container Apps com mesma funcionalidade
- **Metodologia**: Terraform + Infracost
- **Budget**: $150/mês máximo

---

## 🚨 MIGRAÇÃO COMPLETA - DO ZERO

### **ORIGEM (Local):**
- Docker Compose com volumes locais
- MongoDB local (./data-node)
- Arquivos locais (./images, ./uploads, ./logs)
- PostgreSQL local (vectordb container)
- **Azure Storage**: NÃO CONFIGURADO

### **DESTINO (Azure):**
- CosmosDB Serverless (MongoDB API)
- Azure Storage Account (blob containers)  
- PostgreSQL Flexible Server (pgvector)
- Container Apps (4 aplicações)
- **Migração**: Volumes locais → Azure Storage

---

## 🛠️ ÚLTIMOS 3 PROBLEMAS E SOLUÇÕES (REGRA #4)

### **❌ PROBLEMA 1: Application Insights Alerts Require Container Apps IDs**
- **Erro**: `scopes` requires 1 item minimum, but config has only 0 declared
- **✅ Solução**: Adicionada condição `length(var.container_app_ids) > 0` nos alertas e inicializado com lista vazia

### **❌ PROBLEMA 2: PostgreSQL High Availability Mode Invalid**
- **Erro**: expected `high_availability.mode` to be one of ["ZoneRedundant" "SameZone"], got Disabled
- **✅ Solução**: Usado `dynamic` block para só criar high_availability quando habilitado

### **❌ PROBLEMA 3: Storage Account Name Deprecated + Smart Detection Rule Names**
- **Erro**: `storage_account_name` deprecated + invalid smart detection rule name + workbook UUID required
- **✅ Solução**: Usados `storage_account_id`, nome predefinido "Failure Anomalies", UUID válido para workbook

---

*Última atualização: 2025-01-27 - Todos os erros de validação corrigidos*
*Status: ✅ Terraform VALIDADO - Pronto para `terraform apply`*
