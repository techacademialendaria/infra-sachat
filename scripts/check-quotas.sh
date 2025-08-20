#!/bin/bash

# Script para verificar quotas antes do deploy
set -e

REGION=${1:-eastus}

echo "🔍 Verificando quotas para região: $REGION"
echo "============================================="

# 1. Verificar quotas de VM/vCPUs
echo "1️⃣ Quotas de Computação:"
az vm list-usage --location $REGION --query "[?contains(name.value, 'cores')]" --output table

echo ""
echo "2️⃣ Verificando Storage Accounts:"
STORAGE_COUNT=$(az storage account list --query "length([?location=='$REGION'])")
echo "Storage Accounts na região: $STORAGE_COUNT/250"

echo ""
echo "3️⃣ Verificando Resource Groups:"
RG_COUNT=$(az group list --query "length([?location=='$REGION'])")
echo "Resource Groups na região: $RG_COUNT"

echo ""
echo "4️⃣ Testando criação de recursos (dry-run):"

# Testar se podemos criar um CosmosDB (apenas verificação)
echo "CosmosDB disponível: $(az cosmosdb list-locations --query "[?contains(name, '$REGION')]" --output tsv | wc -l > 0 && echo 'SIM' || echo 'NÃO')"

# Testar Container Apps
echo "Container Apps disponível: $(az provider show --namespace Microsoft.App --query "resourceTypes[?resourceType=='managedEnvironments'].locations[]" --output tsv | grep -i $REGION | wc -l > 0 && echo 'SIM' || echo 'NÃO')"

echo ""
echo "5️⃣ Estimativa de recursos necessários:"
echo "- vCPUs necessários: ~4-6 cores"
echo "- Storage Accounts: 1"
echo "- Key Vaults: 1"
echo "- CosmosDB: 1"
echo "- Container Apps Environment: 1"

echo ""
if [ $(az vm list-usage --location $REGION --query "[?name.value=='cores'].limit" --output tsv) -gt 10 ]; then
    echo "✅ Região $REGION parece adequada para deploy"
else
    echo "⚠️ Região $REGION pode ter limitações"
fi
