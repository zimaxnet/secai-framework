# 🤖 Safe Copilot Usage in Secure Environments

**Purpose**: Guidelines for using GitHub Copilot safely in customer environments  
**Critical**: Follow these rules to protect customer data

---

## 🔒 Core Security Principle

**NEVER share customer-specific data with any AI tool, including Copilot.**

Even with enterprise security controls, use abstraction and generic examples.

---

## ✅ Safe Copilot Usage

### What You CAN Ask

**Architecture & Design Patterns**
```
✅ "What are Azure security best practices for multi-tier applications?"
✅ "Show me a zero-trust network architecture pattern for Azure"
✅ "How should I implement least privilege RBAC in Azure?"
✅ "What are common patterns for Azure Key Vault integration?"
✅ "Design a secure CI/CD pipeline for Azure"
```

**Security Analysis**
```
✅ "How do I audit Azure NSG rules for security issues?"
✅ "What are indicators of overprivileged service principals?"
✅ "Show me a security assessment checklist for Azure"
✅ "What should I look for in Azure Security Center recommendations?"
✅ "How to identify publicly exposed Azure resources?"
```

**Compliance & Governance**
```
✅ "Map CIS Azure Foundations controls to Azure Policy"
✅ "What are NIST 800-53 requirements for cloud logging?"
✅ "Show me ISO 27001 compliant Azure configurations"
✅ "How do I document compliance evidence for SOC 2?"
✅ "Create an Azure Policy for encryption enforcement"
```

**Scripting & Automation**
```
✅ "Write an Azure CLI script to audit RBAC assignments"
✅ "Create a PowerShell script to check NSG rules for wide-open access"
✅ "Generate a script to inventory all Azure resources"
✅ "Write a function to check Key Vault soft delete status"
✅ "Create a compliance checking automation script"
```

**Code Review**
```
✅ "Review this ARM template for security issues"
✅ "Check this Terraform code for Azure best practices"
✅ "Analyze this PowerShell script for security vulnerabilities"
✅ "Review this Azure Policy definition for completeness"
```

**Documentation**
```
✅ "Create a template for security assessment reports"
✅ "Generate a risk register template"
✅ "Write an executive summary template for security findings"
✅ "Create a runbook for incident response"
```

---

## ❌ NEVER Share With Copilot

### Customer-Specific Identifiers

**NEVER include**:
```
❌ Subscription IDs: "12345678-1234-1234-1234-123456789012"
❌ Tenant IDs: "abcdef01-2345-6789-abcd-ef0123456789"
❌ Resource names: "kv-prod-customer-secrets-001"
❌ Customer domain: "customer.onmicrosoft.com"
❌ Email addresses: "admin@customer.com"
❌ Server names: "sql-prod-customer-001.database.windows.net"
❌ Storage URLs: "https://sacustomerprod001.blob.core.windows.net"
❌ IP addresses: "10.50.100.25"
```

### Credentials & Secrets

**NEVER include**:
```
❌ Passwords (obviously!)
❌ API keys
❌ Connection strings
❌ Service principal secrets
❌ SAS tokens
❌ Access keys
❌ Certificates
❌ Private keys
```

### Sensitive Data

**NEVER include**:
```
❌ Customer names or identities
❌ PII (Personally Identifiable Information)
❌ Financial data
❌ Health information
❌ Proprietary business logic
❌ Internal network architecture specifics
❌ Vulnerability details with context that identifies customer
```

### Configuration Details

**NEVER include**:
```
❌ Complete ARM templates with customer resource names
❌ Terraform with customer-specific values
❌ Network diagrams with customer IP ranges
❌ Firewall rules with customer-specific IPs
❌ Complete logs with customer data
```

---

## 🎯 Use Abstraction Techniques

### Example 1: Key Vault Access

**❌ BAD - Customer-Specific**:
```
"How do I access Key Vault kv-prod-acme-secrets-001 with service 
principal sp-prod-app-001? The vault is in subscription 
12345678-1234-1234-1234-123456789012."
```

**✅ GOOD - Generic**:
```
"How do I configure a service principal to access Azure Key Vault 
using RBAC? Show me the required role assignments and code example."
```

---

### Example 2: Network Security

**❌ BAD - Customer-Specific**:
```
"We have NSG allowing 0.0.0.0/0 to 10.50.100.0/24 on port 3389. 
How do I fix this for our production environment?"
```

**✅ GOOD - Generic**:
```
"How do I identify and remediate overly permissive NSG rules that 
allow RDP from any source? Show me Azure CLI commands to audit this."
```

---

### Example 3: RBAC Analysis

**❌ BAD - Customer-Specific**:
```
"User john.doe@acmecorp.com has Owner role on subscription 
'Acme-Production'. Should he have this access?"
```

**✅ GOOD - Generic**:
```
"What are best practices for granting Owner role in Azure? 
How do I audit subscription-level Owner assignments for security?"
```

---

### Example 4: Storage Security

**❌ BAD - Customer-Specific**:
```
"Storage account sacmeprod001 has public blob access enabled and 
contains customer PII. How do I secure it?"
```

**✅ GOOD - Generic**:
```
"How do I audit Azure storage accounts for public access and disable 
it securely? What's the impact of disabling public blob access?"
```

---

### Example 5: Compliance

**❌ BAD - Customer-Specific**:
```
"Acme Corp needs SOC 2 compliance. Here's our current Azure setup: 
[detailed customer environment]. What's missing?"
```

**✅ GOOD - Generic**:
```
"What Azure controls are required for SOC 2 compliance? 
Show me a checklist and Azure Policy examples for SOC 2."
```

---

## 🛡️ Sanitization Techniques

### Before Sharing Code/Config with Copilot

**Replace specifics with placeholders**:

**Original (DON'T SHARE)**:
```json
{
  "vaultUri": "https://kv-acme-prod-001.vault.azure.net",
  "tenantId": "12345678-1234-1234-1234-123456789012",
  "clientId": "abcdefgh-1234-5678-90ab-cdefghijklmn"
}
```

**Sanitized (OK TO SHARE)**:
```json
{
  "vaultUri": "https://<keyvault-name>.vault.azure.net",
  "tenantId": "<tenant-id>",
  "clientId": "<client-id>"
}
```

---

### When Sharing Logs

**Original (DON'T SHARE)**:
```
Error accessing https://sacmeprod001.blob.core.windows.net/customer-data
Failed authentication for user john.doe@acmecorp.com
Source IP: 203.0.113.45
```

**Sanitized (OK TO SHARE)**:
```
Error accessing https://<storage-account>.blob.core.windows.net/<container>
Failed authentication for user <username>
Source IP: <ip-address>
```

---

### When Sharing Error Messages

**Original (DON'T SHARE)**:
```
ResourceNotFound: The Resource 'Microsoft.KeyVault/vaults/kv-acme-prod-001' 
under resource group 'rg-acme-production' was not found.
```

**Sanitized (OK TO SHARE)**:
```
ResourceNotFound: The Resource 'Microsoft.KeyVault/vaults/<vault-name>' 
under resource group '<resource-group>' was not found.

[Then ask]: "How do I troubleshoot Azure Key Vault not found errors?"
```

---

## 🎓 Copilot Usage Scenarios

### Scenario 1: Script Development

**Task**: Create script to audit storage accounts

**✅ Safe Approach**:
1. Ask: "Write Azure CLI script to check if storage accounts have public blob access enabled"
2. Get generic script from Copilot
3. Test locally with YOUR customer environment
4. Customize as needed WITHOUT asking Copilot about specifics

**❌ Unsafe Approach**:
1. "Check if sacmeprod001, sacmeprod002, sacmetest001 have public access"

---

### Scenario 2: Troubleshooting

**Task**: Fix Key Vault access issue

**✅ Safe Approach**:
1. Identify the error type (authentication, authorization, network)
2. Ask: "How do I troubleshoot Azure Key Vault authentication errors?"
3. Ask: "What RBAC roles are needed for Key Vault secret access?"
4. Apply solutions to YOUR environment

**❌ Unsafe Approach**:
1. Paste full error with vault name, user email, subscription ID

---

### Scenario 3: Architecture Review

**Task**: Review network security architecture

**✅ Safe Approach**:
1. Draw generic diagram WITHOUT customer names
2. Ask: "Review this Azure network architecture for security best practices"
3. Share ONLY the generic diagram structure
4. Apply recommendations to customer environment

**❌ Unsafe Approach**:
1. Share detailed network diagram with customer IP ranges, resource names, etc.

---

### Scenario 4: Compliance Checking

**Task**: Verify CIS Azure Foundations compliance

**✅ Safe Approach**:
1. Ask: "What are CIS Azure Foundations Benchmark controls for network security?"
2. Ask: "Show me Azure Policy examples for CIS compliance"
3. Run checks in YOUR environment
4. Document findings WITHOUT sharing customer-specific data

**❌ Unsafe Approach**:
1. "Here's our environment: [detailed customer setup]. What CIS controls are we missing?"

---

## 📋 Copilot Usage Checklist

Before asking Copilot anything:

- [ ] Does my question contain customer names?
- [ ] Does it include subscription/tenant IDs?
- [ ] Does it include resource names?
- [ ] Does it include IP addresses or URLs?
- [ ] Does it include credentials or secrets?
- [ ] Does it include PII or sensitive data?
- [ ] Could someone identify the customer from my question?

**If ANY answer is YES, REWRITE using abstraction before asking.**

---

## 🚨 What To Do If You Accidentally Share Sensitive Data

**Immediate Actions**:

1. **Stop the session** - Close Copilot chat immediately
2. **Document the incident** - What was shared, when, which tool
3. **Notify security team** - Follow incident response procedure
4. **Change credentials** - If any credentials were shared
5. **Fill out incident report** - Use incident template

**Prevention**:
- Always pause before hitting Enter
- Review your prompt before submitting
- When in doubt, use more abstraction
- Better to ask generic question than risk exposure

---

## ✅ Enterprise Copilot Features (Your Protection)

Your enterprise Copilot has these protections:

**✅ What's Protected**:
- Code you write is NOT used for training
- Prompts are logged for audit (your security team can review)
- Data retention policies in place
- Compliance with customer requirements
- Enterprise-grade security

**⚠️ But YOU Still Must**:
- Never share customer secrets
- Use abstraction for customer-specific scenarios
- Follow security policies
- Document your usage if required
- Report any concerns

---

## 💡 Pro Tips for Secure Copilot Usage

### 1. Ask Generic, Apply Specific
```
Ask Copilot: "How do I X?" (generic)
Apply answer to: Your customer environment (specific)
```

### 2. Use Hypotheticals
```
"In a hypothetical Azure environment with [generic setup], 
how would I [do security task]?"
```

### 3. Break Down Questions
```
Instead of: "Fix all our security issues: [detailed environment]"
Ask: "What are common Azure NSG security issues?"
Then: "How do I remediate overly permissive NSG rules?"
Then: "Show me script to audit NSG rules"
```

### 4. Use Example.com Pattern
```
Instead of: acmecorp.onmicrosoft.com
Use: example.onmicrosoft.com or <tenant>.onmicrosoft.com
```

### 5. Use RFC 5737 IPs for Examples
```
Instead of: Real customer IPs
Use: 192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24 (documentation IPs)
```

---

## 🎯 Summary: The Golden Rule

**"Would I be comfortable with this prompt being read by:**
- **My customer's CISO?**
- **A compliance auditor?**
- **Someone from a competing organization?"**

**If NO to any of these, use more abstraction!**

---

## 📚 Quick Reference Card

**ALWAYS ASK YOURSELF**:
1. Is this customer-specific? → Use abstraction
2. Does this have identifiers? → Remove them
3. Does this have secrets? → NEVER share
4. Could this identify the customer? → Sanitize
5. Am I unsure? → Err on side of caution

**SAFE PATTERN**:
- Generic question → Copilot helps → Apply to customer

**UNSAFE PATTERN**:
- Customer details → Copilot analyzes → VIOLATION

---

**Remember**: Copilot is a powerful tool, but YOU are responsible for protecting customer data. When in doubt, ask generically!

🛡️ **Smart AI usage = Secure AI usage**





