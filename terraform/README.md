# 🚀 TERRAFORM SUPERCHAT - MIGRAÇÃO AZURE

## 📋 OVERVIEW

Infraestrutura como código para migrar **LibreChat de Docker Compose local para Azure Container Apps**.

### **Migração:**
- **DE**: Docker volumes locais (`./images`, `./uploads`, `./logs`) + MongoDB local
- **PARA**: Azure Storage + CosmosDB Serverless + Container Apps

---

## 📁 ESTRUTURA

```
terraform/
├── environments/prod/          # Configuração de produção
│   ├── main.tf                # Recursos principais
│   ├── variables.tf           # Variáveis configuráveis
│   ├── terraform.tfvars       # Valores das variáveis
│   ├── outputs.tf             # Outputs importantes
│   └── usage.yml              # Patterns de uso (Infracost)
├── modules/                   # Módulos reutilizáveis (serão criados)
│   ├── cosmosdb/             # CosmosDB Serverless
│   ├── postgresql/           # PostgreSQL Flexible
│   ├── container-apps/       # Container Apps + Environment
│   ├── storage/              # Azure Storage Account
│   └── networking/           # Networking + DNS
├── infracost.yml             # Configuração Infracost
└── README.md                 # Este arquivo
```

---

## 🎯 RECURSOS CRIADOS

### **1. CosmosDB Serverless** (substitui MongoDB local)
- **MongoDB API** compatível
- **Scale-to-zero** - $0 quando sem uso
- **Database**: `LibreChat` (mesmo nome atual)
- **Collections**: `conversations`, `users`, `messages`

### **2. PostgreSQL Flexible** (substitui container vectordb)
- **B1ms**: 1 vCore, 2GB RAM
- **pgvector** habilitado
- **Database**: `mydatabase` (mesmo nome atual)

### **3. Azure Storage** (substitui volumes locais)
- **Containers**: `images`, `uploads`, `logs`
- **Substitui**: `./images` (308K), `./uploads` (44K), `./logs` (580K)

### **4. Container Apps** (4 aplicações)
- **API**: 2-10 replicas (substitui LibreChat-API)
- **Frontend**: 1-5 replicas (substitui LibreChat-NGINX)
- **Meilisearch**: 1-3 replicas (v1.12.3)
- **RAG API**: 1-5 replicas

---

## 🛠️ COMO USAR

### **1. Pré-requisitos**
```bash
# Azure CLI
az --version
az login

# Terraform
terraform version  # >= 1.9.0

# Infracost (opcional)
infracost --version
```

### **2. Deploy**
```bash
cd /home/ubuntu/sa/infra-sachat/terraform/environments/prod

# Inicializar Terraform
terraform init

# Verificar custos (opcional)
infracost breakdown --path .

# Planejar deploy
terraform plan

# Aplicar infraestrutura
terraform apply
```

### **3. Outputs Importantes**
Após o deploy, você receberá:
- **Connection strings** para atualizar `.env`
- **URLs** das aplicações
- **Informações** para migração de dados

---

## 💰 MONITORAMENTO DE CUSTOS

### **Infracost Integration**
```bash
# Instalar Infracost
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Configurar
infracost auth login

# Verificar custos
cd environments/prod
infracost breakdown --path .

# Comparar cenários
infracost diff --path .
```

### **Estimativas de Custo**
- **Uso Atual**: ~$35/mês (baseado em 1.1GB RAM total)
- **Uso Baixo**: ~$50/mês
- **Uso Alto (2000 usuários)**: ~$150/mês

---

## 📊 CONFIGURAÇÃO BASEADA NO USO ATUAL

### **Dados Atuais** (do docker-compose):
- **RAM Total**: 1.1GB (API: 411MB, MongoDB: 322MB, RAG: 208MB, Meilisearch: 109MB)
- **MongoDB**: 4.1MB de dados
- **Arquivos**: 308K images + 44K uploads + 580K logs

### **Configuração Azure**:
- **API**: 2GB RAM (buffer para crescimento)
- **CosmosDB**: Serverless (paga por request)
- **Storage**: Standard LRS (custo-benefício)
- **PostgreSQL**: B1ms (equivalente ao container atual)

---

## 🔄 MIGRAÇÃO DE DADOS

### **1. MongoDB → CosmosDB**
```bash
# Export atual
docker exec chat-mongodb mongodump --host localhost:27017 --db LibreChat --out /tmp/backup

# Import para CosmosDB
mongorestore --uri "COSMOSDB_CONNECTION_STRING" --db LibreChat --dir ./backup/LibreChat
```

### **2. Volumes → Azure Storage**
```bash
# Upload arquivos
az storage blob upload-batch --destination images --source ./images --account-name superchatfiles
az storage blob upload-batch --destination uploads --source ./uploads --account-name superchatfiles
```

### **3. Atualizar .env**
Use os outputs do Terraform para atualizar:
- `MONGO_URI`
- `AZURE_STORAGE_CONNECTION_STRING`
- `DB_HOST`
- `fileStrategy=azure`

---

## 🚨 TROUBLESHOOTING

### **Problemas Comuns**:
1. **Provider não registrado**: `az provider register --namespace Microsoft.App`
2. **Região indisponível**: Verificar `az account list-locations`
3. **Quotas excedidas**: Verificar limites da subscription

### **Logs e Debug**:
```bash
# Logs do Terraform
export TF_LOG=DEBUG

# Logs dos Container Apps
az containerapp logs show --name superchat-api --resource-group rg-superchat-production

# Status dos recursos
az resource list --resource-group rg-superchat-production --output table
```

---

## ✅ PRÓXIMOS PASSOS

1. **Criar módulos Terraform** (cosmosdb, postgresql, etc.)
2. **Testar deploy** em ambiente de desenvolvimento
3. **Migrar dados** MongoDB + arquivos
4. **Configurar DNS** para novo endpoint
5. **Monitorar custos** com Infracost

---

**📖 Para mais detalhes, consulte o [MIGRATION_CONTEXT.md](../MIGRATION_CONTEXT.md)**
