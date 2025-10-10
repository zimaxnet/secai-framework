---
layout: default
title: Azure AI Foundry Integration
parent: Getting Started
nav_order: 3
---

# Azure AI Foundry Integration with Cursor
{: .no_toc }

Step-by-step guide for connecting Cursor IDE to Azure AI Foundry (Azure OpenAI) endpoints.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

This guide demonstrates how to configure Cursor IDE to use Azure OpenAI services via Azure AI Foundry, ensuring all AI processing remains within your Azure tenant.

### Why Azure AI Foundry?

| Benefit | Description |
|---------|-------------|
| **Data Sovereignty** | All data stays within your Azure tenant and region |
| **Compliance** | SOC 2, ISO 27001, HIPAA, FedRAMP certified |
| **Audit Trail** | Complete logging via Azure Monitor |
| **Network Isolation** | Private endpoints keep traffic on Azure backbone |
| **Enterprise Control** | RBAC, Conditional Access, and Key Vault integration |

---

## Deploy Azure OpenAI Service

### Create Azure OpenAI Resource

```bash
# Create Azure OpenAI account
az cognitiveservices account create \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --kind OpenAI \
  --sku S0 \
  --location eastus2 \
  --custom-domain aoai-cursor-prod \
  --public-network-access Disabled \
  --identity-type SystemAssigned

# Get resource ID for later use
AOAI_RESOURCE_ID=$(az cognitiveservices account show \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --query id -o tsv)

echo "Azure OpenAI Resource ID: $AOAI_RESOURCE_ID"
```

### Deploy AI Models

```bash
# Deploy GPT-4 Turbo (recommended for code generation)
az cognitiveservices account deployment create \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --deployment-name gpt-4-turbo \
  --model-name gpt-4 \
  --model-version turbo-2024-04-09 \
  --model-format OpenAI \
  --sku-capacity 50 \
  --sku-name Standard

# Deploy GPT-4o (optional, for faster responses)
az cognitiveservices account deployment create \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --deployment-name gpt-4o \
  --model-name gpt-4o \
  --model-version 2024-05-13 \
  --model-format OpenAI \
  --sku-capacity 30 \
  --sku-name Standard

# Verify deployments
az cognitiveservices account deployment list \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --output table
```

### Retrieve API Credentials

```bash
# Get the endpoint URL
AOAI_ENDPOINT=$(az cognitiveservices account show \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --query properties.endpoint -o tsv)

echo "Azure OpenAI Endpoint: $AOAI_ENDPOINT"

# Get API Key (key1)
AOAI_API_KEY=$(az cognitiveservices account keys list \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --query key1 -o tsv)

# IMPORTANT: Store in Key Vault immediately
az keyvault secret set \
  --vault-name kv-cursor-secrets \
  --name aoai-api-key \
  --value "$AOAI_API_KEY" \
  --description "Azure OpenAI API Key for Cursor integration"

echo "API Key stored in Key Vault: kv-cursor-secrets/aoai-api-key"
```

{: .security }
**CRITICAL**: Never store API keys in code, configuration files, or Cursor settings. Always retrieve from Key Vault.

---

## Configure Private Endpoint (Recommended)

### Create Private Endpoint for Azure OpenAI

```bash
# Create private endpoint
az network private-endpoint create \
  --name pe-aoai-cursor \
  --resource-group rg-cursor-ai-research \
  --vnet-name vnet-cursor-ai \
  --subnet snet-cursor-private-endpoints \
  --private-connection-resource-id $AOAI_RESOURCE_ID \
  --group-id account \
  --connection-name cursor-aoai-connection \
  --location eastus2

# Create DNS zone group
az network private-endpoint dns-zone-group create \
  --resource-group rg-cursor-ai-research \
  --endpoint-name pe-aoai-cursor \
  --name cursor-aoai-dns-zone-group \
  --private-dns-zone privatelink.openai.azure.com \
  --zone-name privatelink.openai.azure.com

# Verify private endpoint
az network private-endpoint show \
  --name pe-aoai-cursor \
  --resource-group rg-cursor-ai-research \
  --query 'privateLinkServiceConnections[0].privateLinkServiceConnectionState.status' -o tsv
# Expected output: Approved
```

### Test Private Endpoint Resolution

```bash
# Test DNS resolution
nslookup aoai-cursor-prod.openai.azure.com

# Should return private IP (10.0.1.x range)
# If returns public IP, check DNS zone link

# Test connectivity
curl -I https://aoai-cursor-prod.openai.azure.com/
# Expected: HTTP/1.1 401 (Unauthorized, but proves connectivity)
```

---

## Configure Diagnostic Logging

### Enable Comprehensive Logging

```bash
# Get Log Analytics Workspace ID
LAW_ID=$(az monitor log-analytics workspace show \
  --resource-group rg-cursor-ai-research \
  --workspace-name law-cursor-audit \
  --query id -o tsv)

# Enable diagnostic settings for Azure OpenAI
az monitor diagnostic-settings create \
  --name aoai-cursor-diagnostics \
  --resource $AOAI_RESOURCE_ID \
  --workspace $LAW_ID \
  --logs '[
    {
      "category": "Audit",
      "enabled": true,
      "retentionPolicy": {
        "enabled": true,
        "days": 730
      }
    },
    {
      "category": "RequestResponse",
      "enabled": true,
      "retentionPolicy": {
        "enabled": true,
        "days": 730
      }
    }
  ]' \
  --metrics '[
    {
      "category": "AllMetrics",
      "enabled": true,
      "retentionPolicy": {
        "enabled": true,
        "days": 730
      }
    }
  ]'

echo "Diagnostic logging enabled for Azure OpenAI"
```

### Create Log Analytics Queries

```kusto
// Query 1: Monitor API usage by deployment
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where ResourceType == "ACCOUNTS"
| where OperationName == "Create_ChatCompletion"
| summarize 
    RequestCount = count(),
    TotalTokens = sum(toint(properties_s.total_tokens)),
    AvgTokens = avg(toint(properties_s.total_tokens))
  by bin(TimeGenerated, 1h), deployment_s
| order by TimeGenerated desc

// Query 2: Detect unauthorized access attempts
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where ResultType != "Success"
| where httpStatusCode_d in (401, 403)
| project 
    TimeGenerated,
    OperationName,
    httpStatusCode_d,
    callerIpAddress_s,
    userAgent_s
| order by TimeGenerated desc

// Query 3: Track cost by user (requires user tracking in requests)
AzureDiagnostics
| where OperationName == "Create_ChatCompletion"
| extend tokens = toint(properties_s.total_tokens)
| extend cost = tokens * 0.00001  // Approximate cost per token
| summarize 
    TotalCost = sum(cost),
    TotalRequests = count()
  by identity_s
| order by TotalCost desc
```

---

## Configure Cursor to Use Azure OpenAI

### Method 1: Environment Variables (Recommended)

```bash
# macOS/Linux: Add to ~/.zshrc or ~/.bashrc
export AZURE_OPENAI_ENDPOINT="https://aoai-cursor-prod.openai.azure.com/"
export AZURE_OPENAI_DEPLOYMENT="gpt-4-turbo"
export AZURE_OPENAI_API_VERSION="2024-05-01-preview"

# Retrieve API key from Key Vault (don't export!)
# Instead, use Azure CLI authentication or retrieve on-demand

# Windows PowerShell: Add to $PROFILE
$env:AZURE_OPENAI_ENDPOINT = "https://aoai-cursor-prod.openai.azure.com/"
$env:AZURE_OPENAI_DEPLOYMENT = "gpt-4-turbo"
$env:AZURE_OPENAI_API_VERSION = "2024-05-01-preview"
```

### Method 2: Cursor Configuration File

Edit `~/.cursor/settings.json`:

```json
{
  "cursor.privacyMode": true,
  "cursor.telemetry.disable": true,
  
  "cursor.ai.provider": "azure-openai",
  "cursor.ai.azure.endpoint": "${AZURE_OPENAI_ENDPOINT}",
  "cursor.ai.azure.deployment": "${AZURE_OPENAI_DEPLOYMENT}",
  "cursor.ai.azure.apiVersion": "2024-05-01-preview",
  
  "cursor.ai.authentication": "api-key",
  "cursor.ai.apiKey": "${AZURE_OPENAI_API_KEY}",
  
  "cursor.ai.fallbackToDefault": false,
  "cursor.ai.timeout": 30000,
  "cursor.ai.maxRetries": 3
}
```

{: .warning }
Do NOT hardcode API keys in configuration files. Use environment variables or Key Vault integration.

### Method 3: Azure Entra ID Authentication (Most Secure)

Configure Cursor to use Azure Entra ID instead of API keys:

```bash
# Assign yourself Cognitive Services User role
az role assignment create \
  --role "Cognitive Services User" \
  --assignee $(az ad signed-in-user show --query id -o tsv) \
  --scope $AOAI_RESOURCE_ID

# Login to Azure CLI (Cursor will use this token)
az login

# Configure Cursor to use Entra ID auth
cat > ~/.cursor/settings.json <<EOF
{
  "cursor.ai.provider": "azure-openai",
  "cursor.ai.azure.endpoint": "$AOAI_ENDPOINT",
  "cursor.ai.azure.deployment": "gpt-4-turbo",
  "cursor.ai.authentication": "azure-cli",
  "cursor.ai.azure.tenantId": "$(az account show --query tenantId -o tsv)"
}
EOF
```

---

## Secure API Key Management

### Using Azure Key Vault with Azure CLI

Create a helper script to retrieve API keys:

```bash
#!/bin/bash
# get-aoai-key.sh

KEYVAULT_NAME="kv-cursor-secrets"
SECRET_NAME="aoai-api-key"

# Retrieve API key from Key Vault
API_KEY=$(az keyvault secret show \
  --vault-name $KEYVAULT_NAME \
  --name $SECRET_NAME \
  --query value -o tsv)

# Use in Cursor (pass as environment variable)
export AZURE_OPENAI_API_KEY="$API_KEY"

# Launch Cursor with environment variable
/Applications/Cursor.app/Contents/MacOS/Cursor
```

### API Key Rotation

```bash
# Rotate API keys monthly (automated script)
#!/bin/bash
# rotate-aoai-key.sh

RESOURCE_GROUP="rg-cursor-ai-research"
ACCOUNT_NAME="aoai-cursor-prod"
KEYVAULT_NAME="kv-cursor-secrets"

# Regenerate key2 (while key1 is still active)
NEW_KEY=$(az cognitiveservices account keys regenerate \
  --name $ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --key-name key2 \
  --query key2 -o tsv)

# Update Key Vault with new key
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name aoai-api-key-new \
  --value "$NEW_KEY"

echo "New API key stored. Test before swapping keys."

# After testing, swap keys:
# 1. Update applications to use key2
# 2. Regenerate key1
# 3. Update Key Vault to use key1 again
```

---

## Testing the Integration

### Test 1: Basic Connectivity

```bash
# Test Azure OpenAI API directly
curl -X POST "$AZURE_OPENAI_ENDPOINT/openai/deployments/gpt-4-turbo/chat/completions?api-version=2024-05-01-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: $AZURE_OPENAI_API_KEY" \
  -d '{
    "messages": [
      {
        "role": "system",
        "content": "You are a helpful assistant."
      },
      {
        "role": "user",
        "content": "Say \"Hello from Azure!\""
      }
    ],
    "max_tokens": 50
  }'

# Expected response includes:
# "choices": [{"message": {"content": "Hello from Azure!"}}]
```

### Test 2: Cursor AI Completion

1. Open Cursor IDE
2. Create new file: `test.py`
3. Type comment: `# Function to calculate fibonacci`
4. Press `Tab` to trigger AI completion
5. Verify completion appears
6. Check Azure Monitor logs to confirm request

### Test 3: Verify Data Sovereignty

```bash
# Monitor network traffic while using Cursor
sudo tcpdump -i any -n -A 'host aoai-cursor-prod.openai.azure.com' -w /tmp/cursor-azure-traffic.pcap &

# Use Cursor for 5 minutes...

# Stop capture
sudo pkill tcpdump

# Analyze - all traffic should be to Azure endpoints ONLY
tcpdump -r /tmp/cursor-azure-traffic.pcap -n | grep -v 'aoai-cursor-prod.openai.azure.com'
# Should return no results (or only DNS queries)
```

---

## Performance Optimization

### Model Selection for Different Use Cases

| Use Case | Recommended Model | TPM Quota | Reason |
|----------|------------------|-----------|--------|
| **Code Completion** | GPT-4 Turbo | 50K | Balance of speed and quality |
| **Code Generation** | GPT-4 Turbo | 50K | High quality, complex logic |
| **Code Review** | GPT-4 | 30K | Best reasoning, thorough analysis |
| **Quick Fixes** | GPT-4o | 80K | Fastest response time |

### Caching Strategy

Configure response caching to reduce costs:

```json
{
  "cursor.ai.cache.enabled": true,
  "cursor.ai.cache.ttl": 3600,  // Cache for 1 hour
  "cursor.ai.cache.maxSize": 100  // Cache last 100 completions
}
```

### Rate Limiting

Prevent quota exhaustion:

```json
{
  "cursor.ai.rateLimit.enabled": true,
  "cursor.ai.rateLimit.requestsPerMinute": 60,
  "cursor.ai.rateLimit.tokensPerMinute": 90000
}
```

---

## Monitoring and Alerts

### Create Azure Monitor Alerts

```bash
# Alert on high token usage
az monitor metrics alert create \
  --name alert-aoai-high-token-usage \
  --resource-group rg-cursor-ai-research \
  --scopes $AOAI_RESOURCE_ID \
  --condition "total TokenUsage > 1000000" \
  --window-size 1h \
  --evaluation-frequency 15m \
  --action ag-cursor-security-team \
  --description "Alert when token usage exceeds 1M per hour"

# Alert on failed requests
az monitor metrics alert create \
  --name alert-aoai-high-error-rate \
  --resource-group rg-cursor-ai-research \
  --scopes $AOAI_RESOURCE_ID \
  --condition "total FailedRequests > 10" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action ag-cursor-security-team \
  --description "Alert on high error rate" \
  --severity 2
```

### Cost Monitoring Dashboard

Create Azure Dashboard with:
- Token usage by deployment
- Cost per day/week/month
- Requests per user (if tracked)
- Error rate trends
- Latency p50/p95/p99

---

## Troubleshooting

### Issue: 401 Unauthorized

**Symptoms**: Cursor can't connect to Azure OpenAI

**Solutions**:
```bash
# Verify API key is valid
az cognitiveservices account keys list \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research

# Check Key Vault secret
az keyvault secret show \
  --vault-name kv-cursor-secrets \
  --name aoai-api-key \
  --query value -o tsv

# Verify endpoint URL format
echo $AZURE_OPENAI_ENDPOINT
# Should end with trailing slash: https://aoai-cursor-prod.openai.azure.com/
```

### Issue: 429 Rate Limit Exceeded

**Symptoms**: "Too many requests" errors

**Solutions**:
```bash
# Check current quotas
az cognitiveservices account deployment show \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --deployment-name gpt-4-turbo \
  --query 'sku'

# Request quota increase
# Navigate to Azure Portal → Azure OpenAI → Quotas → Request Increase
```

### Issue: Slow Response Times

**Symptoms**: Completions taking >5 seconds

**Solutions**:
1. Switch to GPT-4o deployment (faster)
2. Reduce `max_tokens` in requests
3. Check private endpoint latency
4. Use regional Azure OpenAI instance closer to users

---

## Security Validation Checklist

- [ ] Azure OpenAI deployed with private endpoint
- [ ] Public network access disabled
- [ ] API key stored in Key Vault (not in code)
- [ ] Diagnostic logging enabled
- [ ] Azure Monitor alerts configured
- [ ] Cursor configured to use Azure endpoint
- [ ] No connections to Cursor's servers (except license)
- [ ] Network traffic analyzed (only Azure endpoints)
- [ ] Cost alerts configured
- [ ] Key rotation procedure tested

---

## Next Steps

With Azure AI Foundry integration complete, explore:

- [Security Architecture](../security-architecture/) - Understand the complete security model
- [Security Policies](../security-policies/) - Implement governance controls
- [Model Selection Guide](../model-selection/) - Choose the right models for your use case

---

**Last Updated**: October 10, 2025  
**Status**: <span class="badge badge-security">Security Validated</span>

