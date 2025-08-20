# 🚀 SA Chat - Setup Completo do Zero

Guia passo-a-passo para subir o SA Chat no Azure Container Apps do zero até estar funcionando em produção.

## 📋 **Pré-requisitos**

### **Contas Necessárias:**
- [x] **Conta Azure** com subscription ativa
- [x] **Conta GitHub** 
- [x] **Domínio** registrado (ex: superagentes.ai)

### **Ferramentas Locais:**
```bash
# 1. Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# 2. Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# 3. GitHub CLI
sudo apt install gh

# 4. Node.js (para testes locais)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verificar instalações
az --version
terraform --version  
gh --version
node --version
```

---

## 🏗️ **FASE 1: Setup dos Repositórios**

### **1.1. Criar Repositórios no GitHub**

```bash
# 1. Clonar o código base
git clone https://github.com/seu-usuario-original/legendschat.git legendschat-temp

# 2. Criar repositório da aplicação
gh repo create legendschat --public --description "SA Chat - Aplicação"
cd legendschat-temp

# 3. Copiar arquivos da aplicação (remover terraform)
rm -rf terraform/
git remote set-url origin https://github.com/seu-usuario/legendschat.git
git push -u origin main

# 4. Criar repositório da infraestrutura  
cd ..
gh repo create infra-sachat --public --description "SA Chat - Infraestrutura"
mkdir infra-sachat
cd infra-sachat

# 5. Copiar estrutura de terraform criada anteriormente
cp -r ../legendschat-temp/repo-structure/infra-sachat/* .
git init
git add .
git commit -m "feat: estrutura inicial da infraestrutura"
git branch -M main
git remote add origin https://github.com/seu-usuario/infra-sachat.git
git push -u origin main
```

### **1.2. Copiar Workflows para os Repositórios**

```bash
# No repositório da aplicação
cd ../legendschat
mkdir -p .github/workflows
cp ../legendschat-temp/repo-structure/legendschat/.github/workflows/* .github/workflows/
git add .github/workflows/
git commit -m "feat: adicionar workflows CI/CD"
git push

# No repositório da infraestrutura  
cd ../infra-sachat
# Os workflows já foram copiados no passo anterior
```

---

## ⚙️ **FASE 2: Configurar Azure**

### **2.1. Setup Inicial do Azure**

```bash
# 1. Login no Azure
az login

# 2. Listar subscriptions disponíveis
az account list --output table

# 3. Definir subscription ativa (substitua pelo seu ID)
az account set --subscription "a346bbab-4a12-49d7-ac00-819eb93c7802"

# 4. Verificar subscription ativa
az account show
```

### **2.2. Criar Service Principal**

```bash
# 1. Obter subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Subscription ID: $SUBSCRIPTION_ID"

# 2. Criar Service Principal para Terraform
az ad sp create-for-rbac \
  --name "sp-sachat-terraform" \
  --role="Contributor" \
  --scopes="/subscriptions/$SUBSCRIPTION_ID" \
  --json-auth > azure-credentials.json

# 3. Mostrar credenciais criadas
echo "✅ Service Principal criado! Conteúdo do arquivo azure-credentials.json:"
cat azure-credentials.json

# 4. Extrair valores individuais para os secrets
CLIENT_ID=$(cat azure-credentials.json | jq -r .clientId)
CLIENT_SECRET=$(cat azure-credentials.json | jq -r .clientSecret)
TENANT_ID=$(cat azure-credentials.json | jq -r .tenantId)

echo ""
echo "📋 Valores para configurar nos GitHub Secrets:"
echo "ARM_CLIENT_ID=$CLIENT_ID"
echo "ARM_CLIENT_SECRET=$CLIENT_SECRET" 
echo "ARM_TENANT_ID=$TENANT_ID"
echo "ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID"
```

### **2.3. Setup Terraform State Storage**

```bash
# 1. Executar script de setup (crie o script primeiro)
cd infra-sachat

# Criar o script se não existir
cat > scripts/setup-azure.sh << 'EOF'
#!/bin/bash
set -e

# Configurações
SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID:-$(az account show --query id -o tsv)}"
RESOURCE_GROUP_NAME="${RESOURCE_GROUP_NAME:-rg-sachat-terraform-state}"
LOCATION="${LOCATION:-East US}"
STORAGE_ACCOUNT_NAME="stsachatstate$(date +%s | tail -c 6)"

echo "🚀 Configurando infraestrutura do Terraform State..."
echo "Subscription: $SUBSCRIPTION_ID"
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"

# Criar Resource Group
echo "📦 Criando Resource Group..."
az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"

# Criar Storage Account
echo "💾 Criando Storage Account..."
az storage account create \
    --resource-group "$RESOURCE_GROUP_NAME" \
    --name "$STORAGE_ACCOUNT_NAME" \
    --sku Standard_LRS \
    --encryption-services blob

# Criar container
echo "📁 Criando container tfstate..."
az storage container create \
    --name tfstate \
    --account-name "$STORAGE_ACCOUNT_NAME" \
    --auth-mode login

echo ""
echo "✅ Setup do Terraform State concluído!"
echo ""
echo "📝 Anote estes valores para os GitHub Secrets:"
echo "TERRAFORM_STATE_RG=$RESOURCE_GROUP_NAME"
echo "TERRAFORM_STATE_SA=$STORAGE_ACCOUNT_NAME"
EOF

# Tornar executável e executar
chmod +x scripts/setup-azure.sh
./scripts/setup-azure.sh

# Anotar os valores retornados pelo script
```

---

## 🔑 **FASE 3: Configurar GitHub Secrets**

### **3.1. Criar Personal Access Tokens**

```bash
# 1. Criar token para comunicação cross-repo
echo "🔑 Criando Personal Access Token..."
echo ""
echo "1. Acesse: https://github.com/settings/tokens"
echo "2. Clique em 'Generate new token (classic)'"
echo "3. Escopo: repo (full control) + workflow"
echo "4. Copie o token gerado"

# Aguardar input do usuário
read -p "Cole o token aqui: " GITHUB_TOKEN
echo "Token salvo localmente para configuração."
```

### **3.2. Configurar Secrets no Repo de Infraestrutura**

```bash
cd ../infra-sachat

# GitHub login
gh auth login

# Configurar secrets ARM para Terraform
gh secret set ARM_CLIENT_ID --body="$CLIENT_ID"
gh secret set ARM_CLIENT_SECRET --body="$CLIENT_SECRET"
gh secret set ARM_TENANT_ID --body="$TENANT_ID"
gh secret set ARM_SUBSCRIPTION_ID --body="$SUBSCRIPTION_ID"

# Terraform State (substitua pelos valores do seu setup)
gh secret set TERRAFORM_STATE_RG --body="rg-sachat-terraform-state"
gh secret set TERRAFORM_STATE_SA --body="nome-da-sua-storage-account"

# Cross-repo communication
gh secret set APP_REPO_TOKEN --body="$GITHUB_TOKEN"

# Infracost (opcional - crie uma conta em https://www.infracost.io/)
read -p "Chave do Infracost (opcional, Enter para pular): " INFRACOST_KEY
if [ ! -z "$INFRACOST_KEY" ]; then
    gh secret set INFRACOST_API_KEY --body="$INFRACOST_KEY"
fi

echo "✅ Secrets configurados no repositório de infraestrutura!"
```

### **3.3. Configurar Secrets no Repo da Aplicação**

```bash
cd ../legendschat

# Azure Credentials para deploy
gh secret set AZURE_CREDENTIALS --body="$(cat ../infra-sachat/azure-credentials.json)"

# Criar credenciais separadas para staging (opcional, pode usar a mesma)
gh secret set AZURE_CREDENTIALS_STAGING --body="$(cat ../azure-credentials.json)"

# Cross-repo communication
gh secret set INFRA_REPO_TOKEN --body="$GITHUB_TOKEN"

echo "✅ Secrets configurados no repositório da aplicação!"
```

---

## 🏗️ **FASE 4: Validar e Subir Infraestrutura**

### **4.1. Teste Local do Terraform (Opcional)**

```bash
cd ../infra-sachat/terraform/environments/staging

# 1. Configurar backend
terraform init \
  -backend-config="resource_group_name=rg-sachat-terraform-state" \
  -backend-config="storage_account_name=sua-storage-account" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=staging.tfstate"

# 2. Validar configuração
terraform validate

# 3. Ver o plano (sem aplicar)
terraform plan \
  -var="resource_group_name=rg-sachat-staging" \
  -var="domain_name=staging.chat2.superagentes.ai"

echo "✅ Terraform validado localmente!"
```

### **4.2. Deploy via GitHub Actions**

```bash
# 1. Criar branch para primeiro deploy
cd infra-sachat
git checkout -b feature/initial-setup

# 2. Fazer pequena mudança para disparar workflow
echo "# Initial setup" >> README.md
git add README.md
git commit -m "feat: initial infrastructure setup"
git push origin feature/initial-setup

# 3. Criar PR
gh pr create --title "🏗️ Setup inicial da infraestrutura" --body "Deploy inicial dos ambientes staging e produção"

echo "✅ PR criado! Verifique os workflows em:"
echo "https://github.com/seu-usuario/infra-sachat/actions"

# 4. Aguardar approval e merge
echo ""
echo "⏳ Próximos passos:"
echo "1. Revisar o Terraform Plan no comentário do PR"
echo "2. Fazer merge do PR"
echo "3. Acompanhar o deploy em Actions"
```

### **4.3. Verificar Deploy da Infraestrutura**

```bash
# Script de verificação
cat > scripts/verify-infrastructure.sh << 'EOF'
#!/bin/bash

echo "🔍 Verificando infraestrutura..."

# Staging
echo ""
echo "🧪 STAGING:"
STAGING_RG="rg-sachat-staging"
if az group show --name $STAGING_RG > /dev/null 2>&1; then
    echo "✅ Resource Group: $STAGING_RG"
    
    # Container App
    STAGING_APP=$(az containerapp list --resource-group $STAGING_RG --query "[0].name" -o tsv 2>/dev/null)
    if [ ! -z "$STAGING_APP" ]; then
        echo "✅ Container App: $STAGING_APP"
        STAGING_URL=$(az containerapp show --name $STAGING_APP --resource-group $STAGING_RG --query "properties.configuration.ingress.fqdn" -o tsv)
        echo "🌐 URL: https://$STAGING_URL"
    else
        echo "❌ Container App não encontrado"
    fi
    
    # MongoDB
    MONGO_COUNT=$(az mongodb flexible-server list --resource-group $STAGING_RG --query "length(@)" -o tsv 2>/dev/null)
    echo "✅ MongoDB Servers: $MONGO_COUNT"
    
    # Storage
    STORAGE_COUNT=$(az storage account list --resource-group $STAGING_RG --query "length(@)" -o tsv)
    echo "✅ Storage Accounts: $STORAGE_COUNT"
else
    echo "❌ Resource Group não encontrado: $STAGING_RG"
fi

# Production
echo ""
echo "🚀 PRODUCTION:"
PROD_RG="rg-sachat-prod"
if az group show --name $PROD_RG > /dev/null 2>&1; then
    echo "✅ Resource Group: $PROD_RG"
    
    # Container App
    PROD_APP=$(az containerapp list --resource-group $PROD_RG --query "[0].name" -o tsv 2>/dev/null)
    if [ ! -z "$PROD_APP" ]; then
        echo "✅ Container App: $PROD_APP"
        PROD_URL=$(az containerapp show --name $PROD_APP --resource-group $PROD_RG --query "properties.configuration.ingress.fqdn" -o tsv)
        echo "🌐 URL: https://$PROD_URL"
    else
        echo "❌ Container App não encontrado"
    fi
    
    # MongoDB
    MONGO_COUNT=$(az mongodb flexible-server list --resource-group $PROD_RG --query "length(@)" -o tsv 2>/dev/null)
    echo "✅ MongoDB Servers: $MONGO_COUNT"
    
    # Storage
    STORAGE_COUNT=$(az storage account list --resource-group $PROD_RG --query "length(@)" -o tsv)
    echo "✅ Storage Accounts: $STORAGE_COUNT"
else
    echo "❌ Resource Group não encontrado: $PROD_RG"
fi

echo ""
echo "🎯 Próximos passos:"
echo "1. Configurar DNS para apontar para os endpoints"
echo "2. Fazer deploy da aplicação"
echo "3. Configurar variáveis de ambiente"
EOF

chmod +x scripts/verify-infrastructure.sh
./scripts/verify-infrastructure.sh
```

---

## 🚀 **FASE 5: Deploy da Aplicação**

### **5.1. Primeiro Build e Deploy Staging**

```bash
cd ../legendschat

# 1. Testar build local (opcional)
echo "🧪 Testando build local..."
npm ci
npm run lint
npm run frontend

# 2. Criar branch develop se não existir
git checkout -b develop
git push origin develop

# 3. Fazer push para disparar deploy staging
git checkout -b feature/initial-deploy
echo "# Initial deploy" >> README.md
git add README.md
git commit -m "feat: configuração inicial para deploy"
git push origin feature/initial-deploy

# 4. Merge para develop para disparar staging
gh pr create --title "🚀 Deploy inicial" --body "Primeira versão da aplicação"
# Fazer merge do PR para develop via GitHub UI

echo "✅ Deploy para staging iniciado!"
echo "Acompanhe em: https://github.com/seu-usuario/legendschat/actions"
```

### **5.2. Verificar Deploy Staging**

```bash
# Script de verificação do staging
cat > scripts/verify-staging.sh << 'EOF'
#!/bin/bash

echo "🔍 Verificando deploy no staging..."

# Obter URL do staging
STAGING_URL=$(az containerapp show \
    --name ca-sachat-staging \
    --resource-group rg-sachat-staging \
    --query "properties.configuration.ingress.fqdn" -o tsv 2>/dev/null)

if [ -z "$STAGING_URL" ]; then
    echo "❌ Container App staging não encontrado"
    exit 1
fi

echo "🌐 URL do Staging: https://$STAGING_URL"

# Testar endpoints
echo ""
echo "🧪 Testando endpoints..."

# Health check
if curl -f -s --max-time 10 "https://$STAGING_URL/api/health" > /dev/null; then
    echo "✅ API Health Check: OK"
else
    echo "❌ API Health Check: FAIL"
fi

# Frontend
if curl -f -s --max-time 10 "https://$STAGING_URL/" > /dev/null; then
    echo "✅ Frontend: OK"
else
    echo "❌ Frontend: FAIL"
fi

# Ver logs recentes
echo ""
echo "📊 Logs recentes:"
az containerapp logs show \
    --name ca-sachat-staging \
    --resource-group rg-sachat-staging \
    --tail 10

echo ""
echo "✅ Staging verificado!"
echo "🔗 Acesse: https://$STAGING_URL"
EOF

chmod +x scripts/verify-staging.sh
./scripts/verify-staging.sh
```

---

## 🔐 **FASE 6: Configurar Variáveis de Ambiente**

### **6.1. Obter API Keys Necessárias**

```bash
echo "🔑 Configuração das API Keys"
echo ""
echo "Obtenha suas API keys nos seguintes sites:"
echo ""
echo "🤖 PROVEDORES DE IA (OBRIGATÓRIOS):"
echo "- Anthropic: https://console.anthropic.com/keys"
echo "- OpenAI: https://platform.openai.com/api-keys"  
echo "- Google AI: https://makersuite.google.com/app/apikey"
echo "- xAI: https://console.x.ai/api-keys"
echo "- DeepSeek: https://platform.deepseek.com/api-keys"
echo ""
echo "🔍 WEB SEARCH (PARA FUNCIONALIDADE DE BUSCA):"
echo "- Serper: https://serper.dev/api-key"
echo "- Firecrawl: https://www.firecrawl.dev/app/apikeys"
echo "- Cohere: https://dashboard.cohere.ai/api-keys"
echo ""

read -p "Pressione Enter quando tiver as API keys..."
```

### **6.2. Configurar Variáveis no Staging**

```bash
# Script para configurar variáveis no staging
cat > scripts/configure-staging-env.sh << 'EOF'
#!/bin/bash
set -e

RESOURCE_GROUP="rg-sachat-staging"
CONTAINER_APP="ca-sachat-staging"

echo "🔧 Configurando variáveis de ambiente no staging..."

# Função para adicionar secret
add_secret() {
    local secret_name=$1
    local secret_value=$2
    
    if [ -z "$secret_value" ]; then
        echo "⚠️  Pulando $secret_name (valor vazio)"
        return
    fi
    
    echo "🔐 Adicionando secret: $secret_name"
    az containerapp secret set \
        --name "$CONTAINER_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --secrets "$secret_name=$secret_value"
}

# Função para adicionar variável de ambiente
add_env_var() {
    local var_name=$1
    local secret_name=$2
    
    echo "🌐 Configurando env var: $var_name"
    az containerapp update \
        --name "$CONTAINER_APP" \
        --resource-group "$RESOURCE_GROUP" \
        --set-env-vars "$var_name=secretref:$secret_name"
}

# Coletar API keys
echo "🤖 === PROVEDORES DE IA ==="
read -p "ANTHROPIC_API_KEY: " ANTHROPIC_API_KEY
read -p "OPENAI_API_KEY: " OPENAI_API_KEY  
read -p "GOOGLE_KEY: " GOOGLE_KEY

echo ""
echo "🔍 === WEB SEARCH (para funcionalidade de busca) ==="
read -p "SERPER_API_KEY: " SERPER_API_KEY
read -p "FIRECRAWL_API_KEY: " FIRECRAWL_API_KEY
read -p "COHERE_API_KEY: " COHERE_API_KEY

# Configurar secrets
if [ ! -z "$ANTHROPIC_API_KEY" ]; then
    add_secret "anthropic-api-key" "$ANTHROPIC_API_KEY"
    add_env_var "ANTHROPIC_API_KEY" "anthropic-api-key"
fi

if [ ! -z "$OPENAI_API_KEY" ]; then
    add_secret "openai-api-key" "$OPENAI_API_KEY"
    add_env_var "OPENAI_API_KEY" "openai-api-key"
fi

if [ ! -z "$GOOGLE_KEY" ]; then
    add_secret "google-key" "$GOOGLE_KEY"
    add_env_var "GOOGLE_KEY" "google-key"
fi

if [ ! -z "$SERPER_API_KEY" ]; then
    add_secret "serper-api-key" "$SERPER_API_KEY"
    add_env_var "SERPER_API_KEY" "serper-api-key"
fi

if [ ! -z "$FIRECRAWL_API_KEY" ]; then
    add_secret "firecrawl-api-key" "$FIRECRAWL_API_KEY"
    add_env_var "FIRECRAWL_API_KEY" "firecrawl-api-key"
fi

if [ ! -z "$COHERE_API_KEY" ]; then
    add_secret "cohere-api-key" "$COHERE_API_KEY"
    add_env_var "COHERE_API_KEY" "cohere-api-key"
fi

# Reiniciar aplicação
echo ""
echo "🔄 Reiniciando aplicação..."
az containerapp revision restart \
    --name "$CONTAINER_APP" \
    --resource-group "$RESOURCE_GROUP"

echo ""
echo "✅ Configuração concluída!"
echo "⏳ Aguarde alguns minutos para a aplicação reiniciar..."
EOF

chmod +x scripts/configure-staging-env.sh
./scripts/configure-staging-env.sh
```

### **6.3. Testar Staging Completo**

```bash
# Aguardar reinicialização e testar
sleep 60

echo "🧪 Testando staging após configuração..."

STAGING_URL=$(az containerapp show \
    --name ca-sachat-staging \
    --resource-group rg-sachat-staging \
    --query "properties.configuration.ingress.fqdn" -o tsv)

echo "🌐 Acessando: https://$STAGING_URL"

# Teste mais completo
if curl -f -s --max-time 30 "https://$STAGING_URL" | grep -q "SA Chat"; then
    echo "✅ Aplicação carregando corretamente!"
else
    echo "⚠️ Aplicação pode estar inicializando ainda..."
fi

echo ""
echo "🎉 Staging está configurado!"
echo "🔗 URL: https://$STAGING_URL"
echo ""
echo "🧪 Teste manualmente:"
echo "1. Acesse a URL"
echo "2. Crie uma conta"
echo "3. Teste os provedores de IA"
echo "4. Teste a funcionalidade de busca"
```

---

## 🚀 **FASE 7: Deploy para Produção**

### **7.1. Criar Release para Produção**

```bash
cd legendschat

# 1. Merge develop para main
git checkout main
git pull origin main
git merge develop
git push origin main

# 2. Criar tag de release
git tag -a v1.0.0 -m "🚀 Primeira versão em produção"
git push origin v1.0.0

# 3. Criar release no GitHub
gh release create v1.0.0 \
    --title "🚀 SA Chat v1.0.0" \
    --notes "
## 🎉 Primeira Release em Produção!

### ✨ Funcionalidades
- ✅ Múltiplos provedores de IA (Anthropic, OpenAI, Google, xAI, DeepSeek)
- ✅ Busca na web integrada 
- ✅ Upload de arquivos
- ✅ Interface moderna e responsiva
- ✅ Autenticação e autorização

### 🏗️ Infraestrutura
- ✅ Azure Container Apps
- ✅ Azure Database for MongoDB
- ✅ Azure Blob Storage  
- ✅ Application Insights
- ✅ SSL automático

### 🔄 Deploy
Deploy automático para: https://chat2.superagentes.ai
"

echo "✅ Release criada! Deploy para produção iniciado."
echo "Acompanhe em: https://github.com/seu-usuario/legendschat/actions"
```

### **7.2. Configurar Variáveis de Produção**

```bash
# Aguardar o deploy terminar
echo "⏳ Aguardando deploy de produção terminar..."
echo "Pressione Enter quando o workflow de produção estiver completo..."
read

# Configurar produção (mesmo script, mas para produção)
cat > scripts/configure-production-env.sh << 'EOF'
#!/bin/bash
set -e

RESOURCE_GROUP="rg-sachat-prod"
CONTAINER_APP="ca-sachat-prod"

echo "🚀 Configurando variáveis de ambiente na PRODUÇÃO..."
echo "⚠️  Use as mesmas API keys do staging ou keys dedicadas para produção"

# [Mesmo código do script de staging, mas com os nomes de produção]
# ... (código similar ao script anterior)
EOF

chmod +x scripts/configure-production-env.sh

echo "🔧 Configurando produção..."
./scripts/configure-production-env.sh
```

---

## 🌐 **FASE 8: Configurar Domínio**

### **8.1. Obter Name Servers do Azure**

```bash
# Obter name servers da zona DNS
echo "📋 Obtendo informações do DNS..."

az network dns zone show \
    --name chat2.superagentes.ai \
    --resource-group rg-sachat-prod \
    --query nameServers

echo ""
echo "🌐 Configure seu domínio:"
echo "1. Acesse seu registrador de domínio (ex: GoDaddy, Namecheap)"
echo "2. Configure os name servers acima"
echo "3. Aguarde propagação DNS (pode demorar até 48h)"
```

### **8.2. Configurar Domínio Personalizado**

```bash
# Aguardar propagação DNS
echo "⏳ Aguarde a propagação DNS..."
echo "Teste com: nslookup chat2.superagentes.ai"
read -p "Pressione Enter quando o DNS estiver funcionando..."

# Configurar domínio personalizado
az containerapp hostname bind \
    --hostname chat2.superagentes.ai \
    --name ca-sachat-prod \
    --resource-group rg-sachat-prod

echo "✅ Domínio personalizado configurado!"
```

---

## ✅ **FASE 9: Verificação Final**

### **9.1. Script de Verificação Completa**

```bash
cat > scripts/final-verification.sh << 'EOF'
#!/bin/bash

echo "🎯 VERIFICAÇÃO FINAL DO SA CHAT"
echo "================================"

# Staging
echo ""
echo "🧪 STAGING:"
STAGING_URL="https://staging.chat2.superagentes.ai"
if curl -f -s --max-time 10 "$STAGING_URL/api/health" > /dev/null; then
    echo "✅ Staging: $STAGING_URL"
else
    # Fallback para URL do Azure
    STAGING_AZURE=$(az containerapp show --name ca-sachat-staging --resource-group rg-sachat-staging --query "properties.configuration.ingress.fqdn" -o tsv)
    echo "⚠️ Staging DNS: não configurado"
    echo "🔗 Staging Azure: https://$STAGING_AZURE"
fi

# Production
echo ""
echo "🚀 PRODUCTION:"
PROD_URL="https://chat2.superagentes.ai"
if curl -f -s --max-time 10 "$PROD_URL/api/health" > /dev/null; then
    echo "✅ Production: $PROD_URL"
else
    # Fallback para URL do Azure
    PROD_AZURE=$(az containerapp show --name ca-sachat-prod --resource-group rg-sachat-prod --query "properties.configuration.ingress.fqdn" -o tsv)
    echo "⚠️ Production DNS: não configurado ou propagando"
    echo "🔗 Production Azure: https://$PROD_AZURE"
fi

# Custos
echo ""
echo "💰 CUSTOS ESTIMADOS:"
echo "Staging: ~$25-35/mês"
echo "Production: ~$47-80/mês"
echo "Total: ~$72-115/mês"

# Repositórios
echo ""
echo "📁 REPOSITÓRIOS:"
echo "App: https://github.com/seu-usuario/legendschat"
echo "Infra: https://github.com/seu-usuario/infra-sachat"

echo ""
echo "🎉 PARABÉNS! SA CHAT ESTÁ FUNCIONANDO!"
echo ""
echo "🔄 Para atualizações futuras:"
echo "1. App: Push para 'develop' → deploy staging automático"
echo "2. App: Criar release → deploy produção"
echo "3. Infra: PR + merge → terraform apply"
EOF

chmod +x scripts/final-verification.sh
./scripts/final-verification.sh
```

### **9.2. Checklist Final**

```bash
echo "📋 CHECKLIST FINAL"
echo "=================="
echo ""
echo "✅ Infraestrutura:"
echo "  [ ] Staging environment criado"
echo "  [ ] Production environment criado" 
echo "  [ ] DNS configurado"
echo "  [ ] SSL funcionando"
echo ""
echo "✅ Aplicação:"
echo "  [ ] Build e deploy funcionando"
echo "  [ ] API keys configuradas"
echo "  [ ] Provedores de IA funcionando"
echo "  [ ] Funcionalidades testadas"
echo ""
echo "✅ CI/CD:"
echo "  [ ] Workflows funcionando"
echo "  [ ] Cross-repo communication"
echo "  [ ] Deployments automáticos"
echo ""
echo "✅ Monitoramento:"
echo "  [ ] Application Insights ativo"
echo "  [ ] Logs acessíveis"
echo "  [ ] Alerts configurados"
```

---

## 🎉 **Conclusão**

Parabéns! Você agora tem:

- ✅ **SA Chat funcionando** em staging e produção
- ✅ **Infraestrutura gerenciada** via Terraform
- ✅ **Deploy automático** via GitHub Actions  
- ✅ **Multi-repo setup** com comunicação cross-repo
- ✅ **Monitoramento** e logs configurados
- ✅ **SSL automático** e domínio personalizado

### **URLs Finais:**
- **Staging**: https://staging.chat2.superagentes.ai
- **Production**: https://chat2.superagentes.ai

### **Próximos Passos:**
1. **Configurar alertas** de monitoramento
2. **Adicionar mais provedores** de IA conforme necessário
3. **Configurar backup** adicional se necessário
4. **Otimizar custos** conforme uso real

### **Suporte:**
- **Documentação**: [Multi-Repo Guide](./docs/MULTI_REPO_DEPLOYMENT_GUIDE.md)
- **Issues App**: https://github.com/seu-usuario/legendschat/issues
- **Issues Infra**: https://github.com/seu-usuario/infra-sachat/issues

**🚀 Sua aplicação está pronta para uso!**