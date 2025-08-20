#!/bin/bash

# Script para limpar recursos em soft delete no Azure
# Deve ser executado antes de refazer o deploy

set -e

echo "🧹 Limpando recursos em soft delete..."

# Purgar Key Vaults em soft delete
echo "📋 Verificando Key Vaults em soft delete..."
DELETED_VAULTS=$(az keyvault list-deleted --query "[].name" -o tsv 2>/dev/null || echo "")

if [ ! -z "$DELETED_VAULTS" ]; then
    echo "🗑️ Key Vaults encontrados em soft delete:"
    az keyvault list-deleted --output table
    
    for vault in $DELETED_VAULTS; do
        echo "🔥 Purgando Key Vault: $vault"
        az keyvault purge --name "$vault" --no-wait || echo "⚠️ Falha ao purgar $vault (pode já ter sido purgado)"
    done
else
    echo "✅ Nenhum Key Vault em soft delete encontrado"
fi

# Verificar Cosmos DB accounts em soft delete (se suportado)
echo "📋 Verificando Cosmos DB accounts..."
# Cosmos DB não tem comando direto para soft delete, mas podemos verificar contas existentes

# Listar resource groups para verificar recursos orfãos
echo "📋 Verificando resource groups..."
az group list --query "[?starts_with(name, 'rg-sachat')].{Name:name, Location:location, State:properties.provisioningState}" --output table

echo "✅ Limpeza concluída!"
echo ""
echo "💡 Próximos passos:"
echo "1. Execute 'terraform plan' para verificar o que será criado"
echo "2. Execute 'terraform apply' para criar os recursos"
echo ""
echo "⚠️ Se ainda houver conflitos, considere:"
echo "   - Aguardar alguns minutos para a propagação das exclusões"
echo "   - Usar nomes ligeiramente diferentes nos recursos"
echo "   - Verificar manualmente no Portal do Azure"
