#!/bin/bash

# Script para configurar Terraform corretamente após problemas de state lock
# e subscription ID

set -e

ENVIRONMENT=${1:-staging}
PROJECT_NAME=${2:-sachat}

echo "🔧 Configurando Terraform para ambiente: $ENVIRONMENT"
echo "============================================="

# 1. Obter informações da Azure
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
STORAGE_ACCOUNT=$(az storage account list --query "[?contains(name, 'tfstate') || contains(name, '$PROJECT_NAME')].name" -o tsv | head -1)

echo "📊 Informações detectadas:"
echo "Subscription ID: $SUBSCRIPTION_ID"
echo "Storage Account: $STORAGE_ACCOUNT"

if [ -z "$STORAGE_ACCOUNT" ]; then
    echo "❌ Storage account para Terraform state não encontrado!"
    echo "Execute primeiro o script de setup do Azure."
    exit 1
fi

# 2. Navegar para o ambiente
cd "terraform/environments/$ENVIRONMENT"

# 3. Reconfigurar backend (força unlock se necessário)
echo "🔄 Reconfigurando backend..."
terraform init -reconfigure \
    -backend-config="storage_account_name=$STORAGE_ACCOUNT" \
    -backend-config="container_name=tfstate" \
    -backend-config="key=$ENVIRONMENT.tfstate" \
    -backend-config="resource_group_name=rg-$PROJECT_NAME-terraform-state" \
    -force-copy

# 4. Verificar se ainda há lock
echo "🔍 Verificando locks..."
if ! terraform plan -detailed-exitcode -no-color >/dev/null 2>&1; then
    echo "⚠️ Ainda há problemas. Tentando força quebrar lock..."
    # Se necessário, quebrar lock forcado (use com cuidado!)
    # terraform force-unlock <LOCK_ID>
    echo "Execute manualmente se necessário:"
    echo "terraform force-unlock <LOCK_ID>"
fi

echo "✅ Configuração concluída!"
echo ""
echo "💡 Próximos comandos:"
echo "cd terraform/environments/$ENVIRONMENT"
echo "terraform plan"
echo "terraform apply"
