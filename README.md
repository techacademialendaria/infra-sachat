# 🏗️ SA Chat Infrastructure

Repositório de infraestrutura do SA Chat usando Terraform para Azure Container Apps.

## 📋 Estrutura Modular

```
terraform/
├── environments/           # Ambientes específicos
│   ├── staging/           # Ambiente de teste
│   │   ├── main.tf       # Resources usando modules
│   │   ├── variables.tf  # Variáveis específicas staging
│   │   └── outputs.tf    # Outputs do ambiente
│   └── production/        # Ambiente de produção
│       ├── main.tf       # Resources usando modules
│       ├── variables.tf  # Variáveis específicas produção
│       └── outputs.tf    # Outputs do ambiente
└── modules/               # Módulos reutilizáveis
    ├── network/          # Container App Environment + Log Analytics
    ├── storage/          # Azure Blob Storage + Containers
    ├── database/         # MongoDB Flexible Server + Firewall
    ├── monitoring/       # Application Insights
    ├── container_apps/   # Container App + Sidecars
    ├── domain/           # DNS Zone + Records (opcional)
    └── backup/           # Recovery Services Vault (produção)
```

## 🚀 Quick Start

### 1. Setup Inicial
```bash
# Clone do repositório
git clone https://github.com/seu-usuario/legendschat-infrastructure.git
cd legendschat-infrastructure

# Setup Azure
./scripts/setup-azure.sh
```

### 2. Deploy Staging
```bash
cd terraform/environments/staging

# Inicializar Terraform
terraform init \
  -backend-config="resource_group_name=rg-sachat-terraform-state" \
  -backend-config="storage_account_name=sua-storage-account" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=staging.tfstate"

# Deploy
terraform plan
terraform apply
```

### 3. Deploy Production
```bash
cd terraform/environments/production

# Inicializar Terraform  
terraform init \
  -backend-config="resource_group_name=rg-sachat-terraform-state" \
  -backend-config="storage_account_name=sua-storage-account" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=production.tfstate"

# Deploy
terraform plan
terraform apply
```

## 🔧 Configurações por Ambiente

### Staging
- **Container Apps**: 1-2 réplicas
- **MongoDB**: Standard_B1ms (1 vCore, 2GB, 16GB storage)
- **Application Insights**: 50MB/dia
- **DNS**: staging.chat2.superagentes.ai
- **Alta disponibilidade**: Desabilitada

### Production
- **Container Apps**: 2-10 réplicas (autoscaling)
- **MongoDB**: Standard_D2s_v3 (2 vCore, 8GB, 128GB storage)
- **Application Insights**: 100MB/dia
- **DNS**: chat2.superagentes.ai
- **Alta disponibilidade**: Habilitada
- **Backup**: Habilitado

## 💰 Custos Estimados

| Ambiente | Custo Mensal |
|----------|--------------|
| Staging | $25-35 |
| Production | $47-80 |

## 🔄 Workflows Automáticos

### Pull Requests
- **Terraform Plan** para ambientes afetados
- **Infracost** com estimativa de custos
- **Security Scan** com tfsec + Checkov
- **Comentário automático** no PR com resultados

### Merge para Main
- **Terraform Apply** automático
- **Notificação** para repositório da aplicação
- **Outputs** salvos como environment variables

## 📊 Monitoramento

### Logs
```bash
# Ver logs de deploy
gh run list --workflow=terraform-apply.yml

# Ver último workflow
gh run view --log
```

### Status dos Recursos
```bash
# Staging
az group show --name rg-sachat-staging
az containerapp list --resource-group rg-sachat-staging

# Production
az group show --name rg-sachat-prod  
az containerapp list --resource-group rg-sachat-prod
```

## 🛠️ Comandos Úteis

### Terraform
```bash
# Verificar estado
terraform show

# Ver outputs
terraform output

# Refresh estado
terraform refresh

# Importar recurso existente
terraform import azurerm_resource_group.example /subscriptions/xxx/resourceGroups/example
```

### Azure CLI
```bash
# Listar recursos por ambiente
az resource list --tag Environment=staging --output table
az resource list --tag Environment=production --output table

# Ver custos
az consumption usage list --start-date 2024-01-01 --end-date 2024-01-31
```

## 🔒 Segurança

### Secrets Necessários
- `ARM_CLIENT_ID` - Service Principal App ID
- `ARM_CLIENT_SECRET` - Service Principal Password
- `ARM_TENANT_ID` - Azure Tenant ID
- `ARM_SUBSCRIPTION_ID` - Azure Subscription ID
- `TERRAFORM_STATE_RG` - Resource Group do Terraform State
- `TERRAFORM_STATE_SA` - Storage Account do Terraform State

### Security Scans
- **tfsec**: Scan de segurança do Terraform
- **Checkov**: Policy as Code
- **Infracost**: Estimativa de custos

## 🚨 Troubleshooting

### Problemas Comuns

| Problema | Solução |
|----------|---------|
| Terraform init falha | Verificar backend config e permissions |
| Plan falha por timeout | Aumentar timeout ou verificar conectividade |
| Apply falha por quota | Verificar limites da subscription |
| Resource já existe | Fazer import ou usar different name |

### Recovery
```bash
# Backup do estado
terraform state pull > backup.tfstate

# Recuperar de backup
terraform state push backup.tfstate

# Unlock estado travado
terraform force-unlock LOCK_ID
```

## 📞 Suporte

- **Issues**: https://github.com/seu-usuario/legendschat-infrastructure/issues
- **Documentação**: [Multi-Repo Guide](../docs/MULTI_REPO_DEPLOYMENT_GUIDE.md)
- **App Repository**: https://github.com/seu-usuario/legendschat

## 🔄 Relacionamento com App Repo

Este repositório trabalha em conjunto com o [legendschat](https://github.com/seu-usuario/legendschat):

- **App deployt → Notifica infra** sobre nova versão
- **Infra apply → Notifica app** sobre mudanças de infraestrutura
- **Cross-repo triggers** para sincronização automática

Veja o [guia completo](../docs/MULTI_REPO_DEPLOYMENT_GUIDE.md) para detalhes do fluxo.