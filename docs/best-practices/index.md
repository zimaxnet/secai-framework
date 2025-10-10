---
layout: default
title: Best Practices
nav_order: 8
has_children: true
permalink: /best-practices/
---

# Best Practices
{: .no_toc }

Enterprise best practices for Cursor IDE administration and Azure AI Foundry integration.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Development Workflow

### Daily Development with Cursor

**Morning Routine**:
```bash
# 1. Verify Azure authentication
az account show --query '[name,user.name]' -o table

# 2. Retrieve API key from Key Vault (if needed)
export AZURE_OPENAI_KEY=$(az keyvault secret show \
  --vault-name kv-cursor-secrets \
  --name aoai-api-key \
  --query value -o tsv)

# 3. Launch Cursor
open -a Cursor  # macOS
# or
cursor          # Linux/Windows
```

**During Development**:
- ✅ Use AI for code completion and generation
- ✅ Review AI suggestions before accepting
- ✅ Use `.cursorignore` to protect sensitive files
- ❌ Never paste secrets into AI chat
- ❌ Never commit `.env` files

**End of Day**:
- Clear API key from environment variables
- Review any new files created by AI
- Ensure no secrets accidentally committed

---

## Audit Logging Best Practices

### Log Retention Strategy

| Log Type | Retention | Reason |
|----------|-----------|--------|
| Cursor Activity | 730 days | Compliance requirement |
| Azure OpenAI API | 730 days | Security analysis |
| Key Vault Access | 2,555 days (7 years) | Regulatory requirement |
| Entra ID Sign-ins | 730 days | Access review |
| NSG Flow Logs | 90 days | Network forensics |

### Log Analysis Queries

**Query 1: Top AI Users**
```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where TimeGenerated > ago(30d)
| summarize 
    RequestCount = count(),
    TotalTokens = sum(toint(properties_s.total_tokens)),
    Cost = sum(toint(properties_s.total_tokens)) * 0.00001
  by identity_s
| order by Cost desc
| take 10
```

**Query 2: Unusual Activity Detection**
```kusto
// Detect AI usage outside business hours
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where TimeGenerated > ago(7d)
| extend Hour = datetime_part("hour", TimeGenerated)
| where Hour < 6 or Hour > 20  // Outside 6 AM - 8 PM
| summarize Count = count() by identity_s, bin(TimeGenerated, 1d)
| where Count > 10
```

**Query 3: Failed Authentication Attempts**
```kusto
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES"
| where ResultType != "Success"
| where httpStatusCode_d in (401, 403)
| summarize FailedAttempts = count() by 
    callerIpAddress_s,
    identity_s
| where FailedAttempts > 5
| order by FailedAttempts desc
```

---

## Cost Management Best Practices

### Budget Allocation

Recommended budget breakdown for 50-developer team:

```
Total Monthly Budget: $1,000

Breakdown:
├── Azure OpenAI (GPT-4 Turbo)    $600  (60%)
├── Azure OpenAI (GPT-4o)         $200  (20%)
├── Key Vault                     $5    (0.5%)
├── Log Analytics                 $150  (15%)
├── Network (Private Endpoints)   $25   (2.5%)
└── Contingency                   $20   (2%)
```

### Cost Optimization Techniques

**1. Right-Size Model Selection**
```json
// Use cheaper models for simple tasks
{
  "cursor.ai.modelMapping": {
    "completion": "gpt-4o",           // Fast, cheaper
    "generation": "gpt-4-turbo",      // Balanced
    "review": "gpt-4",                // Best quality
    "documentation": "gpt-3.5-turbo"  // Cheapest
  }
}
```

**2. Implement Caching**
```json
{
  "cursor.ai.cache.enabled": true,
  "cursor.ai.cache.ttl": 3600,      // 1 hour
  "cursor.ai.cache.maxSize": 100,   // Cache 100 completions
  "cursor.ai.cache.strategy": "lru" // Least recently used
}
```

**3. Set Quota Limits**
```bash
# Limit tokens per minute per deployment
az cognitiveservices account deployment update \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --deployment-name gpt-4-turbo \
  --sku capacity=50  # 50K tokens/minute max

# Create alerts before hitting limits
az monitor metrics alert create \
  --name alert-approaching-quota \
  --condition "total TokenUsage > 45000" \
  --window-size 1m
```

**4. Monitor and Chargeback**
```bash
# Generate cost report by team
az costmanagement query \
  --type Usage \
  --dataset-filter "{\"and\":[{\"dimension\":{\"name\":\"ResourceGroup\",\"operator\":\"In\",\"values\":[\"rg-cursor-ai-research\"]}}]}" \
  --dataset-grouping name="ResourceId" type="Dimension" \
  --timeframe MonthToDate \
  --output table
```

---

## Incident Response Procedures

### Incident Classification

| Severity | Example | Response Time |
|----------|---------|--------------|
| **Critical** | Secret exposed publicly | 15 minutes |
| **High** | Unauthorized Key Vault access | 1 hour |
| **Medium** | Privacy Mode disabled | 4 hours |
| **Low** | Cost budget exceeded | 24 hours |

### Incident Response Playbook

**Scenario: API Key Exposed in GitHub**

```bash
#!/bin/bash
# incident-response-secret-exposure.sh

echo "=== SECRET EXPOSURE INCIDENT RESPONSE ==="
echo "Incident reported at: $(date)"

# Step 1: Identify the exposed secret
read -p "Secret name (from Key Vault): " SECRET_NAME
read -p "Where exposed (e.g., GitHub repo URL): " EXPOSURE_LOCATION

# Step 2: Immediately disable the secret
echo "Step 1: Disabling secret in Key Vault..."
az keyvault secret set-attributes \
  --vault-name kv-cursor-secrets \
  --name $SECRET_NAME \
  --enabled false

echo "✅ Secret disabled"

# Step 3: Regenerate the secret (if Azure OpenAI key)
echo "Step 2: Regenerating API key..."
NEW_KEY=$(az cognitiveservices account keys regenerate \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --key-name key2 \
  --query key2 -o tsv)

# Step 4: Store new secret
echo "Step 3: Storing new secret..."
az keyvault secret set \
  --vault-name kv-cursor-secrets \
  --name $SECRET_NAME \
  --value "$NEW_KEY"

echo "✅ New secret stored"

# Step 5: Notify team
echo "Step 4: Notifying security team..."
# Send to Teams/Slack/Email
curl -X POST "https://hooks.slack.com/services/YOUR/WEBHOOK/URL" \
  -H "Content-Type: application/json" \
  -d "{\"text\":\"🚨 Secret exposure incident: $SECRET_NAME. Old key revoked, new key deployed.\"}"

# Step 6: Document incident
echo "Step 5: Creating incident report..."
cat > "/tmp/incident-$(date +%Y%m%d-%H%M%S).md" <<EOF
# Security Incident Report

**Date**: $(date)
**Type**: Secret Exposure
**Severity**: Critical
**Secret**: $SECRET_NAME
**Location**: $EXPOSURE_LOCATION

## Actions Taken
1. Secret disabled in Key Vault: $(date)
2. New API key generated: $(date)
3. New key stored in Key Vault: $(date)
4. Team notified: $(date)

## Next Steps
- [ ] Review how secret was exposed
- [ ] Update security training
- [ ] Implement preventive controls
- [ ] Complete root cause analysis within 24 hours
EOF

echo "✅ Incident report created"
echo "=== INCIDENT RESPONSE COMPLETE ==="
echo "Total time: \$((SECONDS))s"
```

---

## Security Hardening Checklist

### Pre-Deployment Checklist

- [ ] Azure OpenAI deployed in correct region
- [ ] Private endpoints configured
- [ ] Public network access disabled
- [ ] Key Vault created with premium SKU
- [ ] Soft delete and purge protection enabled
- [ ] RBAC configured (least privilege)
- [ ] Diagnostic logging enabled (730-day retention)
- [ ] Azure Monitor alerts configured
- [ ] Cost budgets and alerts set
- [ ] Security baseline policies applied

### Post-Deployment Checklist

- [ ] Cursor Privacy Mode enabled on all installations
- [ ] Extension allowlist enforced via MDM
- [ ] `.cursorignore` file created in all repositories
- [ ] Team trained on security guidelines
- [ ] Incident response procedures documented
- [ ] Quarterly access review scheduled
- [ ] Monthly key rotation scheduled
- [ ] Security monitoring dashboard created

### Monthly Security Review

- [ ] Review Key Vault access logs (any unauthorized attempts?)
- [ ] Review Azure OpenAI usage patterns (any anomalies?)
- [ ] Verify Privacy Mode status on all devices
- [ ] Check cost trends (any unexpected spikes?)
- [ ] Review new extension requests
- [ ] Update security documentation
- [ ] Rotate API keys (monthly mandatory)
- [ ] Test incident response procedures

### Quarterly Compliance Audit

- [ ] Complete access review (Entra ID, Key Vault, Azure OpenAI)
- [ ] Review and update security policies
- [ ] Verify compliance with frameworks (CIS, NIST, etc.)
- [ ] Generate compliance evidence for auditors
- [ ] Update training materials
- [ ] Review and update .cursorignore patterns
- [ ] Audit MCP server configurations
- [ ] Test backup and recovery procedures

---

## Team Onboarding Process

### New Developer Onboarding Checklist

**Week 1: Accounts & Access**
- [ ] Azure Entra ID account created
- [ ] MFA enabled and verified
- [ ] Conditional Access policies assigned
- [ ] RBAC roles assigned (least privilege)
- [ ] Access to Key Vault approved (if needed)
- [ ] Added to appropriate Azure DevOps/GitHub teams

**Week 1: Tool Installation**
- [ ] Cursor Enterprise installed
- [ ] Privacy Mode enabled and verified
- [ ] SSO configured (Entra ID)
- [ ] Extension allowlist applied
- [ ] `.cursorignore` template provided

**Week 1: Training**
- [ ] Security awareness training completed (4 hours)
- [ ] Cursor usage training (2 hours)
- [ ] Azure AI Foundry overview (1 hour)
- [ ] Quiz passed (>85%)

**Week 2: Validation**
- [ ] Test AI completion in Cursor
- [ ] Verify Azure OpenAI connectivity
- [ ] Complete practice exercises
- [ ] Shadow experienced developer
- [ ] Review security guidelines document

**Ongoing**
- [ ] Quarterly refresher training
- [ ] Monthly security newsletter
- [ ] Ad-hoc security updates as needed

### Onboarding Script

```bash
#!/bin/bash
# onboard-new-developer.sh

DEVELOPER_NAME="$1"
DEVELOPER_EMAIL="$2"

echo "=== Onboarding $DEVELOPER_NAME ==="

# 1. Create Entra ID account (if not exists)
az ad user create \
  --display-name "$DEVELOPER_NAME" \
  --user-principal-name "$DEVELOPER_EMAIL" \
  --password "TemporaryPassword123!" \
  --force-change-password-next-sign-in true

# 2. Assign RBAC roles
USER_ID=$(az ad user show --id "$DEVELOPER_EMAIL" --query id -o tsv)

az role assignment create \
  --role "Cognitive Services User" \
  --assignee $USER_ID \
  --scope /subscriptions/{sub-id}/resourceGroups/rg-cursor-ai-research/providers/Microsoft.CognitiveServices/accounts/aoai-cursor-prod

# 3. Add to security group for Cursor access
az ad group member add \
  --group "Cursor-Users" \
  --member-id $USER_ID

# 4. Send welcome email with setup instructions
cat > /tmp/welcome-email.md <<EOF
Welcome to the team, $DEVELOPER_NAME!

Please complete the following steps:

1. Change your temporary password at first login
2. Set up MFA: https://aka.ms/MFASetup
3. Install Cursor: https://cursor.com/enterprise/download
4. Complete security training: [Internal URL]
5. Review security guidelines: [Internal Wiki]

Questions? Contact: security-team@company.com
EOF

# Send email (configure with your email service)
echo "✅ Welcome email prepared at /tmp/welcome-email.md"
echo "✅ Onboarding complete for $DEVELOPER_NAME"
```

---

## Performance Optimization

### Reduce Latency

**1. Use Closer Azure Regions**
```bash
# Check latency from your location to different regions
for region in eastus westus centralus eastus2 westus2; do
  echo "Testing $region..."
  time curl -I "https://aoai-cursor-$region.openai.azure.com/"
done

# Deploy in region with lowest latency
```

**2. Optimize Context Window**
```json
{
  "cursor.ai.maxContextTokens": 4000,  // Balance cost vs quality
  "cursor.ai.includeRecentFiles": 2,   // Only 2 most recent
  "cursor.ai.excludePatterns": [
    "**/node_modules/**",
    "**/dist/**",
    "**/build/**"
  ]
}
```

**3. Enable Streaming**
```json
{
  "cursor.ai.streaming": true,  // Faster perceived response
  "cursor.ai.streamingDelay": 50  // ms between chunks
}
```

### Improve Code Quality

**1. Use System Prompts**
```json
{
  "cursor.ai.systemPrompt": "You are an expert software engineer focused on writing secure, performant, and maintainable code. Always include error handling, type hints, and docstrings."
}
```

**2. Enable Code Review Mode**
```json
{
  "cursor.ai.reviewMode": {
    "enabled": true,
    "checkSecurity": true,
    "checkPerformance": true,
    "checkMaintainability": true
  }
}
```

**3. Configure Temperature by Task**
```json
{
  "cursor.ai.temperature": {
    "completion": 0.2,      // Deterministic
    "generation": 0.3,      // Slightly creative
    "review": 0.1,          // Very deterministic
    "documentation": 0.4    // More creative
  }
}
```

---

## Disaster Recovery

### Backup Strategy

**What to Backup**:
- [ ] Key Vault secrets (encrypted export)
- [ ] Cursor Enterprise configuration
- [ ] Azure OpenAI deployment configurations
- [ ] Diagnostic settings
- [ ] Azure Monitor alert rules
- [ ] Documentation and runbooks

**Backup Script**:
```bash
#!/bin/bash
# backup-cursor-infra.sh

BACKUP_DIR="/backup/cursor-$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# 1. Export Key Vault secrets
az keyvault secret list \
  --vault-name kv-cursor-secrets \
  --query '[].name' -o tsv | while read secret; do
    az keyvault secret backup \
      --vault-name kv-cursor-secrets \
      --name $secret \
      --file "$BACKUP_DIR/keyvault-$secret.backup"
done

# 2. Export Azure OpenAI configurations
az cognitiveservices account show \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  > "$BACKUP_DIR/aoai-config.json"

# 3. Export diagnostic settings
# 4. Export alert rules
# 5. Encrypt backup directory
# 6. Upload to secure Azure Storage

echo "✅ Backup complete: $BACKUP_DIR"
```

### Recovery Testing

**Quarterly Recovery Test**:
1. Create test Azure subscription
2. Deploy infrastructure from backup
3. Verify Cursor can connect
4. Test API calls to Azure OpenAI
5. Verify audit logging
6. Document any issues

---

**Last Updated**: October 10, 2025  
**Status**: <span class="badge badge-updated">Continuously Updated</span>

