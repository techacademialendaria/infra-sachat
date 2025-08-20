#!/bin/bash

# Script para verificar se é seguro executar Terraform
# Verifica locks, processos e status do GitHub Actions

set -e

ENVIRONMENT=${1:-staging}
PROJECT_NAME=${2:-sachat}

echo "🔍 Verificando segurança para executar Terraform"
echo "Environment: $ENVIRONMENT"
echo "============================================="

# 1. Verificar se há processos terraform locais rodando
echo "1️⃣ Verificando processos Terraform locais..."
TERRAFORM_PROCESSES=$(ps aux | grep -v grep | grep terraform | grep -v terraform-ls | grep -v check-terraform-safety || true)

if [ ! -z "$TERRAFORM_PROCESSES" ]; then
    echo "⚠️ PROCESSOS TERRAFORM DETECTADOS:"
    echo "$TERRAFORM_PROCESSES"
    echo ""
    echo "❌ NÃO É SEGURO executar terraform agora!"
    echo "💡 Termine os processos acima primeiro."
    exit 1
else
    echo "✅ Nenhum processo terraform local rodando"
fi

# 2. Verificar locks no state
echo ""
echo "2️⃣ Verificando locks no Terraform state..."
cd "terraform/environments/$ENVIRONMENT" 2>/dev/null || {
    echo "❌ Diretório terraform/environments/$ENVIRONMENT não encontrado"
    exit 1
}

# Tentar um comando rápido para verificar lock
echo "Testando terraform plan..."
PLAN_OUTPUT=$(timeout 30s terraform plan -detailed-exitcode -no-color 2>&1 || true)

if echo "$PLAN_OUTPUT" | grep -q "state blob is already locked"; then
    echo "❌ Terraform state está BLOQUEADO"
    
    # Extrair info do lock
    LOCK_INFO=$(echo "$PLAN_OUTPUT" | grep -A 10 "Lock Info:" || echo "Lock info não disponível")
    echo "$LOCK_INFO"
    LOCK_STATUS="LOCKED"
elif echo "$PLAN_OUTPUT" | grep -q "Error:"; then
    echo "⚠️ Outro erro no Terraform:"
    echo "$PLAN_OUTPUT" | grep -A 5 "Error:" | head -10
    LOCK_STATUS="ERROR"
elif echo "$PLAN_OUTPUT" | grep -q "No changes\|Plan:"; then
    echo "✅ Terraform state acessível (sem locks)"
    LOCK_STATUS="FREE"
else
    echo "⚠️ Status do Terraform indefinido"
    echo "Output (primeiras linhas):"
    echo "$PLAN_OUTPUT" | head -5
    LOCK_STATUS="UNKNOWN"
fi

# 3. Verificar GitHub Actions (se gh cli estiver disponível)
echo ""
echo "3️⃣ Verificando GitHub Actions..."
if command -v gh >/dev/null 2>&1; then
    # Verificar workflows rodando
    RUNNING_WORKFLOWS=$(gh run list --repo techacademialendaria/infra-sachat --status in_progress --limit 5 --json status,conclusion,displayTitle 2>/dev/null || echo "[]")
    
    if [ "$RUNNING_WORKFLOWS" = "[]" ] || [ -z "$RUNNING_WORKFLOWS" ]; then
        echo "✅ Nenhum workflow rodando no GitHub Actions"
        GH_STATUS="FREE"
    else
        echo "⚠️ WORKFLOWS RODANDO no GitHub Actions:"
        echo "$RUNNING_WORKFLOWS" | jq -r '.[] | "- \(.displayTitle) (\(.status))"' 2>/dev/null || echo "$RUNNING_WORKFLOWS"
        GH_STATUS="RUNNING"
    fi
else
    echo "⚠️ GitHub CLI não disponível - não foi possível verificar Actions"
    GH_STATUS="UNKNOWN"
fi

# 4. Verificar última execução local vs remota
echo ""
echo "4️⃣ Verificando histórico de execuções..."
if [ -f ".terraform/terraform.tfstate" ]; then
    echo "✅ Terraform inicializado localmente"
else
    echo "⚠️ Terraform não inicializado neste diretório"
fi

# 5. Resumo e recomendação
echo ""
echo "📊 RESUMO DA VERIFICAÇÃO:"
echo "========================"
echo "Processos locais: ✅ Limpo"
echo "Terraform lock: $LOCK_STATUS"
echo "GitHub Actions: $GH_STATUS"
echo ""

# Decisão final
if [ "$LOCK_STATUS" = "FREE" ] && [ "$GH_STATUS" != "RUNNING" ]; then
    echo "🟢 SEGURO PARA EXECUTAR!"
    echo ""
    echo "💡 Comandos seguros agora:"
    echo "  terraform plan"
    echo "  terraform validate"
    echo "  terraform refresh"
    echo ""
    echo "⚠️ Evite terraform apply se Actions puder executar logo"
    exit 0
    
elif [ "$LOCK_STATUS" = "LOCKED" ]; then
    echo "🔴 NÃO SEGURO - State bloqueado!"
    echo ""
    echo "💡 Soluções:"
    echo "  # Se você travou o lock:"
    echo "  terraform force-unlock <LOCK_ID>"
    echo ""
    echo "  # Se Actions está rodando:"
    echo "  Aguarde finalizar ou cancele o workflow"
    exit 1
    
elif [ "$GH_STATUS" = "RUNNING" ]; then
    echo "🟡 CUIDADO - Actions rodando!"
    echo ""
    echo "💡 Recomendações:"
    echo "  - Aguarde Actions finalizar"
    echo "  - Ou cancele o workflow se necessário"
    echo "  - Comandos de leitura (plan) são geralmente seguros"
    exit 1
    
else
    echo "🟡 VERIFICAÇÃO INCOMPLETA"
    echo ""
    echo "💡 Execute manualmente:"
    echo "  terraform plan  # Para testar lock"
    echo "  gh run list     # Para verificar Actions"
    exit 1
fi
