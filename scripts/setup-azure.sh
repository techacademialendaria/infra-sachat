#!/bin/bash

# Setup Azure Infrastructure for SA Chat
# Este script cria os recursos iniciais necessários para o Terraform

set -e

echo "🚀 Setting up Azure Infrastructure for SA Chat..."

# Verificar se Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI não encontrado. Instale primeiro: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

# Verificar se está logado
if ! az account show &> /dev/null; then
    echo "🔐 Fazendo login no Azure..."
    az login
fi

# Configurações
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
LOCATION="Brazil South"

# Solicitar informações do usuário
echo "📋 Configuração do projeto:"
read -p "Nome do projeto (ex: sachat): " PROJECT_NAME
read -p "Environment (staging/production): " ENVIRONMENT
read -p "Resource Group da infraestrutura (ex: rg-${PROJECT_NAME}-${ENVIRONMENT}): " RG_NAME

# Criar Resource Group
echo "🏗️ Criando Resource Group: $RG_NAME"
az group create \
    --name "$RG_NAME" \
    --location "$LOCATION" \
    --tags Environment="$ENVIRONMENT" Project="SA Chat" ManagedBy="terraform"

# Criar Storage Account para Terraform State
STORAGE_NAME="${PROJECT_NAME}${ENVIRONMENT}tfstate$(date +%s)"
echo "💾 Criando Storage Account para Terraform State: $STORAGE_NAME"
az storage account create \
    --name "$STORAGE_NAME" \
    --resource-group "$RG_NAME" \
    --location "$LOCATION" \
    --sku Standard_LRS \
    --encryption-services blob

# Criar container para tfstate
echo "📦 Criando container para Terraform State..."
az storage container create \
    --name tfstate \
    --account-name "$STORAGE_NAME"

# Criar Service Principal para Terraform
SP_NAME="sp-${PROJECT_NAME}-terraform"
echo "🔑 Criando Service Principal: $SP_NAME"

SP_OUTPUT=$(az ad sp create-for-rbac \
    --name "$SP_NAME" \
    --role Contributor \
    --scopes "/subscriptions/$SUBSCRIPTION_ID")

CLIENT_ID=$(echo $SP_OUTPUT | jq -r '.appId')
CLIENT_SECRET=$(echo $SP_OUTPUT | jq -r '.password')

echo ""
echo "✅ Setup concluído!"
echo ""
echo "📋 Configurações para GitHub Secrets:"
echo "ARM_CLIENT_ID: $CLIENT_ID"
echo "ARM_CLIENT_SECRET: $CLIENT_SECRET"
echo "ARM_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
echo "ARM_TENANT_ID: $TENANT_ID"
echo "TERRAFORM_STATE_RG: $RG_NAME"
echo "TERRAFORM_STATE_SA: $STORAGE_NAME"
echo ""
echo "🔧 Backend config para Terraform:"
echo "resource_group_name = \"$RG_NAME\""
echo "storage_account_name = \"$STORAGE_NAME\""
echo "container_name = \"tfstate\""
echo "key = \"${ENVIRONMENT}.tfstate\""
echo ""
echo "🚀 Próximos passos:"
echo "1. Adicione os secrets no GitHub repository"
echo "2. Execute 'terraform init' com backend config"
echo "3. Execute 'terraform plan' e 'terraform apply'"