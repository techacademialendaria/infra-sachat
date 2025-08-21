# ⚡ SUPERCHAT - QUICK START TERRAFORM

## 🎯 MIGRAÇÃO: Docker Compose → Azure Container Apps

### **✅ ESTRUTURA CRIADA**
- [x] **MIGRATION_CONTEXT.md** - Memória permanente da migração
- [x] **5 Módulos Terraform** - cosmosdb, postgresql, storage, container-apps, container-registry
- [x] **Ambiente Produção** - terraform/environments/prod/ completo
- [x] **Container Registry** - Auto-build das imagens do legendschat
- [x] **GitHub Actions CI/CD** - Deploy automático cross-repo
- [x] **Infracost** - Monitoramento de custos integrado
- [x] **Documentação Secrets** - GITHUB_SECRETS_SETUP.md

---

## 🚀 COMANDOS PARA EXECUTAR AGORA

### **1. Verificar Azure**
```bash
az account show --output table
```

### **2. Configurar Variáveis**
```bash
export RESOURCE_GROUP="rg-superchat-prod"
export LOCATION="eastus"
export APP_NAME="superchat"
```

### **3. Configurar Secrets GitHub**
```bash
# OBRIGATÓRIO: Ler e configurar secrets
cat GITHUB_SECRETS_SETUP.md

# Configurar Service Principal Azure
az ad sp create-for-rbac --name "superchat-terraform" --role "Contributor" --sdk-auth

# Adicionar todos os secrets nos repositórios GitHub
# infra-sachat: AZURE_*, INFRACOST_*, POSTGRESQL_*, CROSS_REPO_TOKEN
# legendschat: AZURE_CREDENTIALS, AZURE_*
```

### **4. Instalar Infracost**
```bash
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
infracost auth login
```

### **5. Deploy Terraform**
```bash
cd /home/ubuntu/sa/infra-sachat/terraform/environments/prod

# Inicializar
terraform init

# Verificar custos ANTES do deploy
infracost breakdown --path .

# Planejar (revisar recursos)
terraform plan

# 🔥 APLICAR INFRAESTRUTURA
terraform apply
```

---

## 📊 ESTIMATIVAS DE CUSTO

### **Cenários baseados no uso atual:**
- **Migração direta**: ~$35-50/mês
- **Uso baixo**: ~$50-80/mês  
- **Uso alto (2000 usuários)**: ~$120-150/mês

### **Scale-to-Zero:**
- **CosmosDB Serverless**: $0 quando sem uso
- **Container Apps**: Free tier 180k vCPU-seconds/mês

---

## 🎯 PRÓXIMOS PASSOS APÓS DEPLOY

### **1. Outputs do Terraform**
O deploy vai retornar:
- **Connection strings** para MongoDB e Storage
- **URLs** das aplicações
- **Instruções** para migração de dados

### **2. Migração de Dados**
```bash
# MongoDB: 4.1MB de dados
docker exec chat-mongodb mongodump --host localhost:27017 --db LibreChat --out /tmp/backup

# Arquivos: 352K total
az storage blob upload-batch --destination images --source ./images
az storage blob upload-batch --destination uploads --source ./uploads
```

### **3. Atualizar .env**
Substituir variáveis locais por Azure:
- `MONGO_URI` → CosmosDB connection string
- `AZURE_STORAGE_CONNECTION_STRING` → Azure Storage
- `fileStrategy=azure`

### **4. DNS Update**
Apontar `chat.superagentes.ai` para novo frontend URL

---

## 🛠️ ARQUIVOS IMPORTANTES

### **Principais:**
- `MIGRATION_CONTEXT.md` - **SEMPRE consultar antes de qualquer ação**
- `terraform/environments/prod/main.tf` - Configuração principal
- `terraform/environments/prod/terraform.tfvars` - Valores customizáveis

### **Monitoramento:**
- `terraform/infracost.yml` - Configuração de custos
- `terraform/environments/prod/usage.yml` - Patterns de uso

---

## ⚠️ LEMBRETE CRÍTICO

### **Antes de executar:**
1. **Ler MIGRATION_CONTEXT.md** - Contexto completo
2. **Verificar custos** com Infracost
3. **Manter VM atual** rodando até validação completa

### **Rollback Plan:**
- VM atual permanece ativa
- DNS switch em 5 minutos
- Dados permanecem intactos localmente

---

## 🔥 EXECUTE AGORA

```bash
# Ir para o diretório
cd /home/ubuntu/sa/infra-sachat/terraform/environments/prod

# Verificar Azure
az account show

# Inicializar Terraform
terraform init

# Ver custos estimados
infracost breakdown --path .

# 🚀 DEPLOY!
terraform plan
terraform apply
```

**📖 Para contexto completo: [MIGRATION_CONTEXT.md](MIGRATION_CONTEXT.md)**
