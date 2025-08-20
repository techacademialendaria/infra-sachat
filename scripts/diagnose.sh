#!/bin/bash

# Script de diagnóstico para problemas de infraestrutura Azure
# Ajuda a identificar recursos órfãos, conflitos e problemas de state

set -e

ENVIRONMENT=${1:-staging}
PROJECT_NAME=${2:-sachat}

echo "🔍 Diagnóstico de Infraestrutura Azure"
echo "Environment: $ENVIRONMENT"
echo "Project: $PROJECT_NAME"
echo "========================================"

# 1. Verificar recursos em soft delete
echo "🗑️ 1. Recursos em Soft Delete:"
echo "Key Vaults:"
az keyvault list-deleted --output table || echo "Nenhum Key Vault em soft delete"

echo ""
echo "🏗️ 2. Recursos Existentes no Azure:"
RG_NAME="rg-$PROJECT_NAME-$ENVIRONMENT"
echo "Resource Group: $RG_NAME"

if az group show --name "$RG_NAME" >/dev/null 2>&1; then
    echo "✅ Resource Group existe"
    echo "Recursos no RG:"
    az resource list --resource-group "$RG_NAME" --output table
else
    echo "❌ Resource Group não existe"
fi

echo ""
echo "📊 3. Estado do Terraform:"
if [ -d "terraform/environments/$ENVIRONMENT" ]; then
    cd "terraform/environments/$ENVIRONMENT"
    
    echo "Provider locks:"
    if [ -f ".terraform.lock.hcl" ]; then
        echo "✅ Lock file existe"
        grep -A 2 "provider.*azurerm" .terraform.lock.hcl | head -10
    else
        echo "❌ No lock file found"
    fi
    
    echo ""
    echo "Terraform state:"
    if terraform show >/dev/null 2>&1; then
        echo "✅ State acessível"
        terraform state list | head -10
    else
        echo "❌ Problema com state ou não inicializado"
    fi
    
    cd - >/dev/null
else
    echo "❌ Diretório do ambiente não encontrado"
fi

echo ""
echo "🔧 4. Verificações de Conectividade:"
echo "Azure CLI:"
az account show --query "{Name:name, ID:id, TenantId:tenantId}" --output table

echo ""
echo "⚡ 5. Sugestões de Resolução:"
echo "Para 'Provider produced inconsistent result':"
echo "  1. terraform init -upgrade"
echo "  2. terraform refresh"
echo "  3. terraform plan -detailed-exitcode"
echo ""
echo "Para recursos em soft delete:"
echo "  1. Aguardar 7 dias para purga automática"
echo "  2. Ou usar nomes diferentes nos recursos"
echo ""
echo "Para conflitos de state:"
echo "  1. terraform import [recurso] [id]"
echo "  2. terraform state rm [recurso]"
echo "  3. Manual cleanup no Azure + terraform refresh"
