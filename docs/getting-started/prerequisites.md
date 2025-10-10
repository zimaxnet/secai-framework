---
layout: default
title: Prerequisites
parent: Getting Started
nav_order: 1
---

# Prerequisites for Cursor + Azure AI Foundry Setup
{: .no_toc }

Detailed guide for preparing your Azure environment before integrating Cursor IDE with Azure AI Foundry.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Azure Subscription Requirements

### Subscription Access

You need an Azure subscription with:

- **Role**: Owner or Contributor + User Access Administrator
- **Subscription Type**: Pay-As-You-Go, Enterprise Agreement, or Azure in CSP
- **Spending Limit**: Sufficient budget for Azure OpenAI usage
- **Quota**: Azure OpenAI service quota approved for your subscription

### Checking Your Current Access

```bash
# Login to Azure CLI
az login

# List your subscriptions
az account list --output table

# Check your role assignments
az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --output table

# Verify Azure OpenAI is available in your subscription
az provider show --namespace Microsoft.CognitiveServices --query "resourceTypes[?resourceType=='accounts'].locations" -o table
```

### Requesting Azure OpenAI Access

{: .important }
Azure OpenAI requires application and approval. This process can take 1-3 business days.

**Application Process:**
1. Navigate to [Azure OpenAI Access Request Form](https://aka.ms/oai/access)
2. Complete the form with:
   - Business justification (use template below)
   - Use case description
   - Expected usage volume
   - Data residency requirements
3. Wait for approval email
4. Verify access in Azure Portal

**Template Business Justification:**
```
We are implementing secure AI-accelerated development workflows for our 
enterprise development team. We require Azure OpenAI services to provide 
AI code completion capabilities via Cursor IDE while maintaining data 
sovereignty within our Azure tenant. Expected usage: 50-100 developers, 
~1M tokens/day. Data residency: [Your Region]. Compliance requirements: 
SOC 2, ISO 27001.
```

---

## Azure Entra ID (Azure AD) Setup

### Tenant Requirements

- Active Azure Entra ID tenant
- Ability to create app registrations
- Conditional Access policies support (Premium P1 or P2)
- MFA enabled for all administrative accounts

### User Preparation

```bash
# Verify your Entra ID tenant
az ad signed-in-user show --query '[userPrincipalName,id,displayName]' -o table

# Check if MFA is enabled
az ad user show --id $(az ad signed-in-user show --query id -o tsv) --query 'accountEnabled' -o tsv

# List assigned licenses (for Conditional Access capabilities)
az ad user get-member-groups --id $(az ad signed-in-user show --query id -o tsv) --output table
```

### Service Principal Creation (Optional)

If you want to use service principal authentication instead of API keys:

```bash
# Create service principal for Cursor access
az ad sp create-for-rbac \
  --name "cursor-ai-access" \
  --role "Cognitive Services User" \
  --scopes /subscriptions/{subscription-id}/resourceGroups/{resource-group}

# Output will include:
# - appId (Application ID)
# - password (Client Secret) - store in Key Vault immediately
# - tenant (Tenant ID)

# Store the client secret in Key Vault
az keyvault secret set \
  --vault-name kv-cursor-secrets \
  --name cursor-sp-secret \
  --value "{password-from-above}"
```

---

## Network Planning

### VNet Architecture

If using private endpoints (recommended), plan your network topology:

```
Virtual Network: vnet-cursor-ai
  ├── Subnet: snet-cursor-private-endpoints (10.0.1.0/24)
  │   ├── Azure OpenAI Private Endpoint
  │   └── Key Vault Private Endpoint
  ├── Subnet: snet-workstations (10.0.2.0/24)
  │   └── Developer workstations (if using Azure VDI)
  └── Subnet: snet-devtest (10.0.3.0/24)
      └── Testing environments
```

### Creating the Network

```bash
# Create resource group
az group create \
  --name rg-cursor-ai-research \
  --location eastus2 \
  --tags Environment=Production Project=Cursor-Research

# Create virtual network
az network vnet create \
  --resource-group rg-cursor-ai-research \
  --name vnet-cursor-ai \
  --address-prefix 10.0.0.0/16 \
  --location eastus2

# Create private endpoint subnet (disable private endpoint network policies)
az network vnet subnet create \
  --resource-group rg-cursor-ai-research \
  --vnet-name vnet-cursor-ai \
  --name snet-cursor-private-endpoints \
  --address-prefixes 10.0.1.0/24 \
  --disable-private-endpoint-network-policies true
```

### DNS Configuration

For private endpoints, configure Azure Private DNS:

```bash
# Create Private DNS Zone for Azure OpenAI
az network private-dns zone create \
  --resource-group rg-cursor-ai-research \
  --name privatelink.openai.azure.com

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group rg-cursor-ai-research \
  --zone-name privatelink.openai.azure.com \
  --name cursor-ai-dns-link \
  --virtual-network vnet-cursor-ai \
  --registration-enabled false

# Create Private DNS Zone for Key Vault
az network private-dns zone create \
  --resource-group rg-cursor-ai-research \
  --name privatelink.vaultcore.azure.net

# Link Key Vault DNS zone to VNet
az network private-dns link vnet create \
  --resource-group rg-cursor-ai-research \
  --zone-name privatelink.vaultcore.azure.net \
  --name cursor-kv-dns-link \
  --virtual-network vnet-cursor-ai \
  --registration-enabled false
```

---

## Azure Key Vault Deployment

### Creating Key Vault

```bash
# Create Key Vault with premium SKU (for HSM support)
az keyvault create \
  --name kv-cursor-secrets \
  --resource-group rg-cursor-ai-research \
  --location eastus2 \
  --sku premium \
  --enabled-for-deployment false \
  --enabled-for-disk-encryption false \
  --enabled-for-template-deployment false \
  --enable-soft-delete true \
  --soft-delete-retention-days 90 \
  --enable-purge-protection true \
  --enable-rbac-authorization true \
  --public-network-access Disabled

# Assign yourself Key Vault Administrator role
az role assignment create \
  --role "Key Vault Administrator" \
  --assignee $(az ad signed-in-user show --query id -o tsv) \
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-cursor-ai-research/providers/Microsoft.KeyVault/vaults/kv-cursor-secrets
```

### Creating Private Endpoint for Key Vault

```bash
# Create private endpoint for Key Vault
az network private-endpoint create \
  --name pe-keyvault-cursor \
  --resource-group rg-cursor-ai-research \
  --vnet-name vnet-cursor-ai \
  --subnet snet-cursor-private-endpoints \
  --private-connection-resource-id /subscriptions/{subscription-id}/resourceGroups/rg-cursor-ai-research/providers/Microsoft.KeyVault/vaults/kv-cursor-secrets \
  --group-id vault \
  --connection-name cursor-kv-connection \
  --location eastus2

# Create DNS record
az network private-endpoint dns-zone-group create \
  --resource-group rg-cursor-ai-research \
  --endpoint-name pe-keyvault-cursor \
  --name cursor-kv-dns-zone-group \
  --private-dns-zone privatelink.vaultcore.azure.net \
  --zone-name privatelink.vaultcore.azure.net
```

---

## Monitoring & Logging Setup

### Log Analytics Workspace

```bash
# Create Log Analytics Workspace
az monitor log-analytics workspace create \
  --resource-group rg-cursor-ai-research \
  --workspace-name law-cursor-audit \
  --location eastus2 \
  --retention-time 730 \
  --sku PerGB2018

# Get workspace ID for later use
az monitor log-analytics workspace show \
  --resource-group rg-cursor-ai-research \
  --workspace-name law-cursor-audit \
  --query customerId -o tsv
```

### Azure Monitor Alerts

```bash
# Create action group for security alerts
az monitor action-group create \
  --name ag-cursor-security-team \
  --resource-group rg-cursor-ai-research \
  --short-name CursorSec \
  --email-receiver name=SecurityTeam email=security@yourcompany.com

# Create alert for unauthorized Key Vault access attempts
az monitor metrics alert create \
  --name alert-kv-unauthorized-access \
  --resource-group rg-cursor-ai-research \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-cursor-ai-research/providers/Microsoft.KeyVault/vaults/kv-cursor-secrets \
  --condition "total UnauthorizedRequests > 0" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action ag-cursor-security-team \
  --description "Alert when unauthorized access to Key Vault is attempted" \
  --severity 2
```

---

## Cost Management

### Budget Setup

```bash
# Create budget for Azure OpenAI costs
az consumption budget create \
  --budget-name cursor-ai-monthly-budget \
  --category Cost \
  --amount 5000 \
  --time-grain Monthly \
  --start-date $(date +%Y-%m-01) \
  --end-date 2026-12-31 \
  --resource-group rg-cursor-ai-research

# Note: Use Azure Portal for email notifications configuration
```

### Cost Estimation

| Resource | SKU | Estimated Monthly Cost |
|----------|-----|----------------------|
| Azure OpenAI (GPT-4 Turbo) | S0 | $2,000-$5,000 (50 devs) |
| Key Vault Premium | Premium | $1.50 + operations |
| Log Analytics | Pay-as-you-go | $50-$200 (2GB/day) |
| VNet & Private Endpoints | Standard | $20-$30/endpoint |
| **Total** | | **$2,100-$5,300/month** |

{: .note }
Costs vary significantly based on actual usage. Monitor daily for the first 2 weeks to establish baseline.

---

## Security Baseline Configuration

### Azure Policy Assignment

```bash
# Assign built-in Azure Policy for Key Vault security
az policy assignment create \
  --name cursor-kv-security-baseline \
  --display-name "Key Vault Security Baseline for Cursor" \
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-cursor-ai-research \
  --policy /providers/Microsoft.Authorization/policySetDefinitions/azure-keyvault-security-baseline

# Assign Azure Policy for Azure OpenAI monitoring
az policy assignment create \
  --name cursor-aoai-diagnostic-settings \
  --display-name "Enforce diagnostic settings for Azure OpenAI" \
  --scope /subscriptions/{subscription-id}/resourceGroups/rg-cursor-ai-research \
  --policy /providers/Microsoft.Authorization/policyDefinitions/diagnostic-settings-policyDef
```

### Microsoft Defender for Cloud

```bash
# Enable Defender for Azure OpenAI (Cognitive Services)
az security pricing create \
  --name CognitiveServices \
  --tier Standard

# Enable Defender for Key Vault
az security pricing create \
  --name KeyVaults \
  --tier Standard
```

---

## Prerequisites Validation Checklist

Before proceeding to Cursor setup, verify:

- [ ] Azure subscription accessible with appropriate roles
- [ ] Azure OpenAI access approved and available
- [ ] Resource group created (`rg-cursor-ai-research`)
- [ ] Virtual network created (if using private endpoints)
- [ ] Private DNS zones configured
- [ ] Azure Key Vault deployed with RBAC
- [ ] Key Vault private endpoint created (if applicable)
- [ ] Log Analytics Workspace created
- [ ] Azure Monitor alerts configured
- [ ] Budget and cost management configured
- [ ] Azure Policy baseline assigned
- [ ] Microsoft Defender enabled for resources
- [ ] Service principal created (if using SP auth)

---

## Next Steps

With prerequisites complete, proceed to:

**→ [Cursor IDE Setup](cursor-setup.md)** - Install and configure Cursor Enterprise

---

## Troubleshooting Prerequisites

### Issue: Azure OpenAI Not Available

**Symptoms**: Can't create Azure OpenAI resource in subscription

**Solutions**:
1. Verify your application was approved: Check approval email
2. Try different region: Use [region availability checker](https://learn.microsoft.com/azure/ai-services/openai/concepts/models)
3. Check quotas: `az cognitiveservices account list-usage`

### Issue: Key Vault Access Denied

**Symptoms**: Can't create or access secrets in Key Vault

**Solutions**:
1. Verify RBAC role: Should have "Key Vault Administrator" or "Key Vault Secrets Officer"
2. Check network access: If using private endpoints, must be on VNet or use VPN
3. Verify Entra ID authentication: `az account show`

### Issue: Private Endpoint DNS Not Resolving

**Symptoms**: Can't connect to Key Vault or Azure OpenAI via private endpoint

**Solutions**:
1. Verify DNS zone is linked to VNet
2. Check private DNS zone has correct A record
3. Test DNS resolution: `nslookup kv-cursor-secrets.vault.azure.net`
4. Flush DNS cache on workstation

---

**Last Updated**: October 10, 2025  
**Validation Status**: <span class="badge badge-security">Security Reviewed</span>

