---
layout: default
title: Security Policies
nav_order: 4
has_children: true
permalink: /security-policies/
---

# Security Policies & SOPs
{: .no_toc }

Standard Operating Procedures and security policy templates for Cursor IDE administration.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

This section provides reusable security policy templates and Standard Operating Procedures (SOPs) for administering Cursor IDE in enterprise environments. All templates are designed to be customized for your organization's specific requirements.

### Policy Framework

Our security policies are organized into five categories:

| Category | Purpose | Policies |
|----------|---------|----------|
| **Access Control** | Who can use Cursor and access AI resources | Authentication, Authorization, RBAC |
| **Data Protection** | How to protect sensitive data | Secrets Management, Data Classification |
| **Operational Security** | Day-to-day secure operations | Team Guidelines, Incident Response |
| **Compliance** | Meeting regulatory requirements | Audit Logging, Evidence Collection |
| **Configuration Management** | Secure Cursor configuration | .cursorignore, Privacy Mode, Extensions |

---

## Core Security Policies

### POL-001: Cursor Enterprise Privacy Policy

**Policy Statement**:
All Cursor IDE installations must operate in Privacy Mode with telemetry disabled to prevent enterprise code from being transmitted to external servers.

**Requirements**:
- Privacy Mode enabled on all installations
- Telemetry collection disabled
- Regular validation of privacy settings
- MDM enforcement for managed devices

**Validation**:
```bash
# Automated check
grep -q '"cursor.privacyMode": true' ~/.cursor/settings.json && echo "PASS" || echo "FAIL"
```

**Related SOPs**: [SOP-001: Privacy Mode Enforcement](#sop-001-privacy-mode-enforcement)

---

### POL-002: Secrets Management Policy

**Policy Statement**:
No secrets, credentials, API keys, or tokens shall be stored in code, configuration files, or entered into AI chat interfaces. All secrets must be stored in Azure Key Vault.

**Requirements**:
- All API keys stored in Key Vault
- Monthly key rotation mandatory
- No secrets in git repositories
- Automated secret scanning enabled

**Prohibited Actions**:
❌ Pasting API keys into Cursor chat  
❌ Hardcoding credentials in code  
❌ Committing `.env` files to git  
❌ Sharing secrets via Slack/Teams  

**Approved Methods**:
✅ Retrieve secrets from Key Vault using Azure CLI  
✅ Use Entra ID authentication (no keys)  
✅ Reference secrets via environment variables  
✅ Use managed identities where possible  

**Incident Response**:
If secret exposed:
1. T+0: Revoke exposed secret in Key Vault
2. T+15min: Generate and deploy new secret
3. T+1hr: Complete incident report
4. T+24hr: Security review with team

**Related SOPs**: [SOP-002: Secret Management Procedures](#sop-002-secret-management-procedures)

---

### POL-003: Azure AI Foundry Integration Policy

**Policy Statement**:
All AI processing must occur within the organization's Azure tenant using Azure AI Foundry (Azure OpenAI). Use of public AI services (OpenAI, Anthropic, etc.) is prohibited for enterprise code.

**Requirements**:
- Cursor configured to use Azure OpenAI endpoints only
- Private endpoints enabled (no public internet)
- All API calls logged to Azure Monitor
- Cost monitoring and alerts configured

**Configuration Enforcement**:
```json
{
  "cursor.ai.provider": "azure-openai",
  "cursor.ai.fallbackToDefault": false,
  "cursor.ai.blockPublicModels": true
}
```

**Related SOPs**: [Azure AI Foundry Integration Guide](/getting-started/azure-ai-foundry-integration/)

---

### POL-004: Extension Security Policy

**Policy Statement**:
Only pre-approved extensions may be installed in Cursor IDE. All extensions must undergo security review before approval.

**Approval Process**:
1. Developer requests extension via IT portal
2. Security team reviews:
   - Publisher reputation
   - Source code (if available)
   - Permissions requested
   - Network access requirements
   - Last updated date
3. If approved, add to organization allowlist
4. MDM pushes allowlist to all devices

**Approved Extensions** (Example):
```
ms-azuretools.vscode-azurefunctions
ms-azuretools.vscode-bicep
ms-vscode.azurecli
ms-vscode.powershell
redhat.vscode-yaml
esbenp.prettier-vscode
```

**Related SOPs**: [SOP-004: Extension Approval Process](#sop-004-extension-approval-process)

---

### POL-005: Audit & Monitoring Policy

**Policy Statement**:
All Cursor usage, Azure OpenAI API calls, and Key Vault access must be logged and retained for a minimum of 2 years.

**Logging Requirements**:

| Log Type | Source | Destination | Retention |
|----------|--------|-------------|-----------|
| Cursor Activity | Cursor Enterprise | Azure Monitor | 2 years |
| API Calls | Azure OpenAI | Log Analytics | 2 years |
| Secret Access | Key Vault | Log Analytics | 7 years |
| Authentication | Entra ID | Entra ID Logs | 2 years |
| Network Traffic | NSG Flow Logs | Storage Account | 90 days |

**Monitoring Requirements**:
- Real-time alerts for unauthorized access
- Daily review of anomalous activity
- Monthly security metrics reporting
- Quarterly access reviews

**Related SOPs**: [SOP-005: Security Monitoring Procedures](#sop-005-security-monitoring-procedures)

---

## Standard Operating Procedures (SOPs)

### SOP-001: Privacy Mode Enforcement

**Purpose**: Ensure Cursor Privacy Mode is enabled and persistent across all installations.

**Scope**: All developers using Cursor IDE

**Procedure**:

1. **Initial Setup** (IT Admin):
   ```bash
   # Deploy privacy-enforced Cursor configuration
   cat > /tmp/cursor-settings.json <<EOF
   {
     "cursor.privacyMode": true,
     "cursor.telemetry.disable": true,
     "cursor.analytics.disable": true
   }
   EOF
   
   # Copy to user directories
   for user in /Users/*; do
     mkdir -p "$user/.cursor"
     cp /tmp/cursor-settings.json "$user/.cursor/settings.json"
     chown $(basename "$user"):staff "$user/.cursor/settings.json"
   done
   ```

2. **User Validation** (Developer):
   - Open Cursor: `Cmd/Ctrl + ,`
   - Navigate to: Features → Privacy Mode
   - Verify toggle is ON and greyed out (MDM enforced)

3. **Automated Monitoring** (Security Team):
   ```bash
   # Weekly scan of all devices
   #!/bin/bash
   for host in $(cat /path/to/host-list.txt); do
     ssh "$host" 'grep -q "cursor.privacyMode.*true" ~/.cursor/settings.json' \
       && echo "$host: COMPLIANT" \
       || echo "$host: NON-COMPLIANT"
   done
   ```

**Validation Frequency**: Weekly automated scan, monthly manual audit

**Incident Response**: If Privacy Mode found disabled, immediately revoke Cursor license and investigate.

---

### SOP-002: Secret Management Procedures

**Purpose**: Define proper procedures for storing, retrieving, and rotating secrets.

**Scope**: All team members with Key Vault access

**Procedure**:

**Storing Secrets**:
```bash
# Step 1: Authenticate to Azure
az login

# Step 2: Store secret in Key Vault
az keyvault secret set \
  --vault-name kv-cursor-secrets \
  --name my-secret-name \
  --value "secret-value" \
  --description "Description of secret purpose" \
  --expires "$(date -u -d '+90 days' '+%Y-%m-%dT%H:%M:%SZ')"

# Step 3: Verify storage
az keyvault secret show \
  --vault-name kv-cursor-secrets \
  --name my-secret-name \
  --query '[name,attributes.expires]' -o table

# Step 4: Document in team wiki
# Record: secret name, purpose, owner, expiration date
```

**Retrieving Secrets**:
```bash
# Option 1: Azure CLI (for scripts)
SECRET_VALUE=$(az keyvault secret show \
  --vault-name kv-cursor-secrets \
  --name my-secret-name \
  --query value -o tsv)

# Option 2: Environment variable (for Cursor)
export MY_SECRET=$(az keyvault secret show \
  --vault-name kv-cursor-secrets \
  --name my-secret-name \
  --query value -o tsv)
```

**Rotating Secrets**:
```bash
# Monthly rotation (automated via Azure Automation or GitHub Actions)
#!/bin/bash
VAULT_NAME="kv-cursor-secrets"
SECRET_NAME="aoai-api-key"

# Generate new secret (example for Azure OpenAI)
NEW_KEY=$(az cognitiveservices account keys regenerate \
  --name aoai-cursor-prod \
  --resource-group rg-cursor-ai-research \
  --key-name key2 \
  --query key2 -o tsv)

# Store new key with version
az keyvault secret set \
  --vault-name $VAULT_NAME \
  --name $SECRET_NAME \
  --value "$NEW_KEY" \
  --tags "rotated=$(date +%Y-%m-%d)"

# Verify applications are using new key before rotating key1
```

**Prohibited Actions**:
- ❌ Storing secrets in code
- ❌ Sending secrets via email/chat
- ❌ Hardcoding in Cursor settings
- ❌ Saving in browser password managers

---

### SOP-003: Incident Response for Secret Exposure

**Purpose**: Define immediate response actions when secrets are exposed.

**Scope**: All team members

**Procedure**:

**Phase 1: Immediate Response (T+0 to T+15 minutes)**

1. **Identify Scope**:
   - What secret was exposed? (API key, password, certificate)
   - Where was it exposed? (git commit, chat, screenshot)
   - Who has access to the exposure? (public, internal, specific users)

2. **Contain**:
   ```bash
   # Immediately revoke the exposed secret
   az keyvault secret set-attributes \
     --vault-name kv-cursor-secrets \
     --name exposed-secret-name \
     --enabled false
   
   # Or regenerate for Azure services
   az cognitiveservices account keys regenerate \
     --name aoai-cursor-prod \
     --resource-group rg-cursor-ai-research \
     --key-name key1
   ```

3. **Notify**:
   - Alert security team immediately
   - Post to incident response channel
   - Page on-call security engineer if after hours

**Phase 2: Remediation (T+15 to T+60 minutes)**

4. **Generate New Secret**:
   ```bash
   # Generate and store new secret
   az keyvault secret set \
     --vault-name kv-cursor-secrets \
     --name exposed-secret-name \
     --value "NEW_SECRET_VALUE"
   ```

5. **Update All Consumers**:
   - Identify all applications using the secret
   - Update configurations/environment variables
   - Restart affected services
   - Verify services operational

6. **Remove Exposure**:
   - If in git: Rewrite history or force rotate
   - If in chat: Delete message
   - If in screenshot: Request deletion

**Phase 3: Investigation (T+1 to T+24 hours)**

7. **Root Cause Analysis**:
   - How was the secret exposed?
   - What process failed?
   - Who was involved?

8. **Documentation**:
   - Complete incident report template
   - Document timeline of events
   - List all actions taken
   - Recommend preventive measures

9. **Prevention**:
   - Update security training
   - Implement additional controls
   - Add automated detection

**Incident Report Template**:
```markdown
# Security Incident Report: Secret Exposure

**Incident ID**: INC-2025-XXX
**Date**: 2025-XX-XX
**Severity**: Critical / High / Medium / Low

## Summary
[One paragraph description]

## Timeline
- T+0: [Initial detection]
- T+X: [Actions taken]

## Impact
- Exposed secret: [name]
- Potential access: [scope]
- Systems affected: [list]

## Response Actions
1. [Action 1]
2. [Action 2]

## Root Cause
[Analysis]

## Prevention Measures
1. [Measure 1]
2. [Measure 2]

## Lessons Learned
[Key takeaways]
```

---

### SOP-004: Extension Approval Process

**Purpose**: Define security review process for Cursor extensions.

**Scope**: Security team, IT administrators

**Procedure**:

**Step 1: Extension Request** (Developer):
```markdown
Extension Request Form:
- Extension Name: [name]
- Publisher: [publisher]
- Marketplace URL: [URL]
- Business Justification: [why needed]
- Alternative Considered: [what else was evaluated]
```

**Step 2: Security Review** (Security Team):

```bash
# Security Review Checklist

## 1. Publisher Verification
- [ ] Publisher is verified (check badge)
- [ ] Publisher has other popular extensions
- [ ] Publisher has good reputation (search for security issues)

## 2. Extension Analysis
- [ ] Review marketplace page
- [ ] Check ratings and reviews
- [ ] Review changelog for recent activity
- [ ] Last updated within 6 months

## 3. Permissions Review
- [ ] List all permissions requested
- [ ] Verify permissions match functionality
- [ ] No unnecessary network access
- [ ] No file system access outside workspace

## 4. Source Code Review (if available)
- [ ] Source code on GitHub
- [ ] Review for malicious code
- [ ] Check dependencies
- [ ] Automated vulnerability scan

## 5. Testing
- [ ] Install in test environment
- [ ] Monitor network traffic
- [ ] Review telemetry behavior
- [ ] Verify functionality

## Decision
- [ ] APPROVED - Add to allowlist
- [ ] REJECTED - Notify requestor with reason
- [ ] NEEDS MORE INFO - Request additional details
```

**Step 3: Allowlist Update** (IT Admin):
```json
// Update organization allowlist
{
  "cursor.extensions.allowed": [
    "existing-extension-1",
    "existing-extension-2",
    "newly-approved-extension-id"
  ]
}

// Push to all devices via MDM
```

**Step 4: Communication** (Security Team):
- Notify requestor of decision
- If approved, provide installation instructions
- If rejected, suggest alternatives

---

### SOP-005: Security Monitoring Procedures

**Purpose**: Define daily/weekly/monthly security monitoring activities.

**Scope**: Security operations team

**Daily Monitoring**:
```bash
# Run daily security checks

# 1. Check for unauthorized Key Vault access attempts
az monitor activity-log list \
  --resource-group rg-cursor-ai-research \
  --start-time "$(date -u -d '24 hours ago' '+%Y-%m-%dT%H:%M:%SZ')" \
  --query "[?contains(resourceId, 'KeyVault')  && contains(authorization.action, 'read') && properties.statusCode != '200']" \
  -o table

# 2. Check Azure OpenAI error rate
# Query Log Analytics workspace
curl -X POST "https://api.loganalytics.io/v1/workspaces/{workspace-id}/query" \
  -H "Authorization: Bearer $(az account get-access-token --query accessToken -o tsv)" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "AzureDiagnostics | where ResourceProvider == \"MICROSOFT.COGNITIVESERVICES\" | where ResultType != \"Success\" | summarize count() by bin(TimeGenerated, 1h) | where count_ > 10"
  }'

# 3. Check for Privacy Mode violations
# Scan managed devices for Privacy Mode status
```

**Weekly Monitoring**:
- Review cost trends (unexpected spikes?)
- Audit new Cursor installations
- Review extension installation requests
- Check for new security CVEs in extensions

**Monthly Monitoring**:
- Full access review (Entra ID, Key Vault, Azure OpenAI)
- Key rotation verification
- Compliance report generation
- Security metrics dashboard review

---

## Policy Templates

### Template 1: Acceptable Use Policy

[Download Template](/assets/downloads/cursor-aup-template.docx)

Key sections:
- Authorized use of Cursor IDE
- Prohibited activities
- Data classification guidelines
- Consequence of policy violations

### Template 2: Data Classification Policy

| Classification | Examples | Cursor Usage |
|----------------|----------|--------------|
| **Public** | Open source code, documentation | ✅ AI assistance allowed |
| **Internal** | Internal tools, non-sensitive code | ✅ AI assistance allowed with review |
| **Confidential** | Customer data, trade secrets | ⚠️ AI assistance with strict controls |
| **Restricted** | Credentials, PII, PHI | ❌ NO AI assistance, manual only |

---

## Next Steps

Explore detailed policy documentation:

- [Secrets Management](secrets-management.md) - Comprehensive secret management guide
- [Team Guidelines](team-guidelines.md) - Developer-facing security guidelines
- [.cursorignore Best Practices](cursorignore-best-practices.md) - File exclusion patterns
- [Governance Playbook](governance-playbook.md) - Complete governance framework

---

**Last Updated**: October 10, 2025  
**Status**: <span class="badge badge-security">Policy Review Current</span>

