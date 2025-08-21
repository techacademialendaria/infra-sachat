# 🔑 CONFIGURAÇÃO DE SECRETS GITHUB

## 📋 SECRETS NECESSÁRIOS

### **🏗️ Para INFRA-SACHAT (repositório de infraestrutura):**

#### **Azure Service Principal:**
```bash
# 1. Criar Service Principal
az ad sp create-for-rbac \
  --name "superchat-terraform" \
  --role "Contributor" \
  --scopes /subscriptions/$(az account show --query id -o tsv) \
  --sdk-auth

# Output será usado nos secrets abaixo
```

#### **Secrets do GitHub (infra-sachat):**
- `ARM_CLIENT_ID` - App ID do Service Principal
- `ARM_CLIENT_SECRET` - Password do Service Principal  
- `ARM_SUBSCRIPTION_ID` - ID da subscription Azure
- `ARM_TENANT_ID` - Tenant ID do Azure
- `INFRACOST_API_KEY` - API key do Infracost
- `POSTGRESQL_ADMIN_PASSWORD` - Password do PostgreSQL (gerar seguro)
- `GITHUB_TOKEN` - GitHub token (gerado automaticamente)

### **🚀 Para LEGENDSCHAT (repositório da aplicação):**

#### **Secrets do GitHub (legendschat):**
- `AZURE_CREDENTIALS` - JSON completo do Service Principal (formato azure/login)

---

## 🛠️ COMO CONFIGURAR

### **1. Service Principal Azure:**
```bash
# Login no Azure
az login

# Criar Service Principal (executar UMA VEZ)
SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "superchat-terraform" \
  --role "Contributor" \
  --scopes /subscriptions/$(az account show --query id -o tsv) \
  --sdk-auth)

echo "📋 SECRETS PARA GITHUB (infra-sachat):" 
echo "ARM_CLIENT_ID: $(echo $SP_OUTPUT | jq -r '.clientId')"
echo "ARM_CLIENT_SECRET: $(echo $SP_OUTPUT | jq -r '.clientSecret')"
echo "ARM_SUBSCRIPTION_ID: $(echo $SP_OUTPUT | jq -r '.subscriptionId')"
echo "ARM_TENANT_ID: $(echo $SP_OUTPUT | jq -r '.tenantId')"

echo ""
echo "📋 AZURE_CREDENTIALS PARA GITHUB (legendschat):"
echo "$SP_OUTPUT"

echo ""
echo "✅ Adicionar estes valores nos secrets dos repositórios GitHub!"
echo "🚨 NUNCA commitar estes valores no código!"
```

### **2. Infracost API Key:**
```bash
# Instalar Infracost
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Fazer login e obter API key
infracost auth login

# API key será mostrada, usar como INFRACOST_API_KEY
```

### **3. PostgreSQL Password:**
```bash
# Gerar password seguro
openssl rand -base64 32

# Usar como POSTGRESQL_ADMIN_PASSWORD
```

### **4. Cross-Repo Token:**
```bash
# Ir para: https://github.com/settings/tokens
# Criar Personal Access Token com scopes:
# - repo (full access)
# - workflow
# - admin:repo_hook

# Usar como CROSS_REPO_TOKEN
```

---

## 📁 CONFIGURAR SECRETS NO GITHUB

### **Repositório infra-sachat:**
```
Settings → Secrets and variables → Actions → New repository secret

ARM_CLIENT_ID: <client_id_do_service_principal>
ARM_CLIENT_SECRET: <client_secret_do_service_principal>
ARM_SUBSCRIPTION_ID: <subscription_id>
ARM_TENANT_ID: <tenant_id>
INFRACOST_API_KEY: <infracost_api_key>
POSTGRESQL_ADMIN_PASSWORD: <postgres_password_seguro>
```

### **Repositório legendschat:**
```
Settings → Secrets and variables → Actions → New repository secret

AZURE_CREDENTIALS: <json_completo_do_service_principal>
```

---

## 🔐 VARIÁVEIS DE AMBIENTE LOCAIS

### **Para desenvolvimento local:**
```bash
# Exportar variáveis diretamente no terminal (mais seguro)
export TF_VAR_github_token="ghp_SEU_GITHUB_TOKEN"
export TF_VAR_postgresql_admin_password="SUA_SENHA_POSTGRES_SEGURA"
export ARM_CLIENT_ID="client_id_do_service_principal"
export ARM_CLIENT_SECRET="client_secret_do_service_principal"
export ARM_SUBSCRIPTION_ID="id_da_subscription"
export ARM_TENANT_ID="tenant_id"

# Verificar se variáveis foram definidas
echo "Verificando variáveis:"
echo "✅ GitHub Token: ${TF_VAR_github_token:0:10}..."
echo "✅ Client ID: ${ARM_CLIENT_ID:0:10}..."

# Executar Terraform
cd terraform/environments/prod
terraform init
terraform plan
```

### **Ou criar script temporário:**
```bash
# Criar script .env-local (está no .gitignore - não será commitado)
cat > .env-local << 'EOF'
#!/bin/bash
export TF_VAR_github_token="SEU_TOKEN_AQUI"
export TF_VAR_postgresql_admin_password="SUA_SENHA_AQUI"
export ARM_CLIENT_ID="SEU_CLIENT_ID"
export ARM_CLIENT_SECRET="SEU_CLIENT_SECRET"
export ARM_SUBSCRIPTION_ID="SEU_SUBSCRIPTION_ID"
export ARM_TENANT_ID="SEU_TENANT_ID"
echo "✅ Variáveis Azure carregadas!"
EOF

# Tornar executável e carregar
chmod +x .env-local
source .env-local

# Executar Terraform
cd terraform/environments/prod
terraform apply
```

---

## ✅ VERIFICAR CONFIGURAÇÃO

### **Testar Azure CLI:**
```bash
# Login
az login

# Verificar subscription
az account show

# Testar permissões
az group list
```

### **Testar Service Principal:**
```bash
# Login com Service Principal
az login --service-principal \
  --username $ARM_CLIENT_ID \
  --password $ARM_CLIENT_SECRET \
  --tenant $ARM_TENANT_ID

# Verificar acesso
az account show
```

### **Testar Terraform:**
```bash
cd terraform/environments/prod

# Verificar variáveis
terraform console
> var.github_token
> var.postgresql_admin_password

# Sair com Ctrl+D
```

---

## 🚨 SEGURANÇA

### **Boas práticas:**
1. **Nunca** commitar secrets nos arquivos
2. **Rotacionar** tokens periodicamente (90 dias)
3. **Usar** princípio do menor privilégio
4. **Monitorar** logs de acesso
5. **Revogar** tokens não utilizados

### **Permissions mínimas Service Principal:**
- `Contributor` na subscription (para criar recursos)
- `AcrPush` no Container Registry (para push de imagens)
- `User Access Administrator` (para role assignments)

---

## 🛠️ TROUBLESHOOTING

### **Erro de autenticação:**
```bash
# Verificar variáveis
echo $ARM_CLIENT_ID
echo $ARM_TENANT_ID

# Re-criar Service Principal se necessário
az ad sp delete --id $ARM_CLIENT_ID
# Criar novamente...
```

### **Erro de permissões:**
```bash
# Verificar roles
az role assignment list --assignee $ARM_CLIENT_ID

# Adicionar role se necessário
az role assignment create \
  --assignee $ARM_CLIENT_ID \
  --role "Contributor" \
  --scope /subscriptions/$ARM_SUBSCRIPTION_ID
```

---

**📖 Configurar todos os secrets antes de executar `terraform apply`!**
