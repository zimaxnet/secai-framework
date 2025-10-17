# 🔧 Azure CLI Setup Guide - Constrained Environment

**Date**: October 13, 2025  
**Purpose**: Azure CLI configuration for read-only customer environment  
**Audience**: Security Architect with limited Azure access

---

## 🎯 Overview

This guide covers Azure CLI setup for a **constrained customer environment** where:
- You have **read-only** portal access initially
- **No Cloud Shell** access
- **Enterprise security** controls are paramount
- **Local Azure CLI** is your primary tool (once provisioned)

---

## 📋 Pre-Installation Checklist

### Before Requesting Azure CLI

- [ ] Documented business justification for CLI access
- [ ] Identified specific security tasks requiring CLI
- [ ] Confirmed customer security policies allow local CLI
- [ ] Prepared to use Azure AD authentication with MFA
- [ ] Reviewed customer's acceptable use policies

### Information to Gather

```markdown
Customer Tenant Information:
- Tenant ID: [Request from customer]
- Tenant domain: [e.g., customer.onmicrosoft.com]
- Subscription IDs: [List of subscriptions you'll access]
- Authentication method: [Azure AD interactive, service principal, etc.]
- MFA requirements: [Yes/No, method]

Your Account Information:
- Azure AD account: [your-email@customer.com]
- Assigned roles: [Reader, Security Reader, etc.]
- Conditional access policies: [Any restrictions?]
- Allowed IP ranges: [If IP restrictions exist]
```

---

## 🚀 Installation Process

### Step 1: Request Installation

Use the template from `CUSTOMER_ENVIRONMENT_CONTEXT.md` to submit IT ticket.

**Key points in request**:
- Business justification (security architecture work)
- Security benefits of local CLI vs Cloud Shell
- Authentication method (Azure AD with MFA)
- Read-only access requirements
- Audit logging compliance

### Step 2: Wait for Approval

**Typical Timeline**:
- Security review: 1-3 days
- IT approval: 1-3 days  
- Installation scheduling: 1-2 days
- Configuration: 1 day

**During wait time**:
- Continue manual portal-based assessment
- Prepare CLI scripts for when access is granted
- Document findings that will benefit from automation
- Build relationship with customer security team

### Step 3: Installation Options

**Option A: IT-Managed Installation** (Most Likely)
```bash
# IT will install via:
# - SCCM/Intune deployment
# - Package manager (chocolatey, brew, apt)
# - Direct installer with admin rights

# You may need to request which version:
# Recommend: Latest stable (2.50.0+)
```

**Option B: Self-Service Installation** (If Allowed)
```bash
# Windows (PowerShell as Admin)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# macOS (Homebrew)
brew update && brew install azure-cli

# Linux (Ubuntu/Debian)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

---

## 🔐 Initial Configuration

### Step 1: Verify Installation

```bash
# Check version
az version

# Should show:
# {
#   "azure-cli": "2.x.x",
#   "azure-cli-core": "2.x.x",
#   ...
# }

# Check login status (should be "Not logged in" initially)
az account show
```

### Step 2: First Login

```bash
# Login to customer tenant
az login --tenant <CUSTOMER-TENANT-ID>

# Browser will open for authentication
# Use your customer Azure AD account
# Complete MFA if required

# Verify successful login
az account show

# Should display:
# {
#   "environmentName": "AzureCloud",
#   "id": "<subscription-id>",
#   "isDefault": true,
#   "name": "<subscription-name>",
#   "state": "Enabled",
#   "tenantId": "<customer-tenant-id>",
#   "user": {
#     "name": "your-email@customer.com",
#     "type": "user"
#   }
# }
```

### Step 3: Set Default Subscription

```bash
# List available subscriptions
az account list --output table

# Set default subscription for your work
az account set --subscription "<subscription-id-or-name>"

# Verify
az account show --output table
```

### Step 4: Verify Permissions

```bash
# Test read access
az resource list --output table

# If you see resources: ✅ Read access confirmed
# If you get permission error: Need to request access

# Test write access (should fail with read-only)
az group create --name test-rg --location eastus
# Expected: Authorization error (you have Reader role)

# Check your RBAC assignments
az role assignment list --assignee <your-email@customer.com> --output table
```

---

## ⚙️ Essential Configuration

### Set Output Format Default

```bash
# Set default output to table for readability
az config set core.output=table

# Or set to JSON for scripting
az config set core.output=json

# Or YAML for readability
az config set core.output=yaml
```

### Configure Command Logging

```bash
# Enable logging (important for audit trail)
az config set core.enable_log_file=true

# Set log directory
az config set core.log_dir=~/.azure/logs

# View current config
az config get
```

### Set Up Auto-Complete (Optional)

```bash
# Bash
echo "source /etc/bash_completion.d/azure-cli" >> ~/.bashrc
source ~/.bashrc

# Zsh  
echo "source /usr/local/etc/bash_completion.d/az" >> ~/.zshrc
source ~/.zshrc

# PowerShell
# Auto-complete built-in, nothing needed
```

---

## 🛡️ Security Best Practices

### Authentication Security

```bash
# ALWAYS use Azure AD authentication (never service principals unless required)
az login --tenant <CUSTOMER-TENANT-ID>

# Enable persistent login (stores refresh tokens securely)
# This is SAFE - uses OS credential manager
az config set core.login_experience=devicecode  # If browser issues

# NEVER store credentials in:
# - Environment variables
# - Scripts
# - Configuration files
# - AI chat prompts
```

### Session Management

```bash
# Check current session
az account show

# Logout when done (especially on shared machines)
az logout

# Clear cached credentials (if needed)
az account clear

# Re-login with explicit tenant
az login --tenant <CUSTOMER-TENANT-ID>
```

### Audit Your Usage

```bash
# Your CLI actions are logged to Azure AD audit logs
# Customer security team can review your activity

# You should maintain your own log:
# Option 1: Enable CLI logging (see configuration above)
# Option 2: Maintain a work log

# Example work log:
echo "$(date): Ran resource inventory command" >> ~/work-log.txt
az resource list --output table | tee -a ~/work-log.txt
```

---

## 📊 Essential Commands for Security Architect

### Resource Inventory

```bash
# List all resources
az resource list --output table

# List by resource group
az resource list --resource-group <rg-name> --output table

# List specific resource type
az resource list --resource-type "Microsoft.Compute/virtualMachines" --output table

# Export to file
az resource list --output json > resource_inventory.json
```

### Security Assessment

```bash
# Security Center recommendations
az security assessment list --output table

# Security alerts
az security alert list --output table

# Security contacts
az security contact list --output table

# Secure score
az security secure-scores list --output table

# Security policies
az policy assignment list --output table
```

### RBAC Analysis

```bash
# List all role assignments
az role assignment list --all --output table

# Role assignments for specific user
az role assignment list --assignee <user@domain.com> --output table

# Role assignments for specific resource
az role assignment list --resource-group <rg-name> --output table

# List all role definitions
az role definition list --output table

# Custom role definitions
az role definition list --custom-role-only true --output table
```

### Key Vault Audit

```bash
# List all Key Vaults
az keyvault list --output table

# Show specific Key Vault
az keyvault show --name <keyvault-name> --output table

# List secrets (names only, not values)
az keyvault secret list --vault-name <keyvault-name> --output table

# Show access policies
az keyvault show --name <keyvault-name> --query properties.accessPolicies

# List RBAC assignments for Key Vault
az role assignment list --scope /subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.KeyVault/vaults/<vault-name>
```

### Network Security

```bash
# List NSGs
az network nsg list --output table

# Show NSG rules
az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name> --output table

# List Virtual Networks
az network vnet list --output table

# Show VNet details
az network vnet show --name <vnet-name> --resource-group <rg-name>

# List public IPs
az network public-ip list --output table

# Azure Firewall
az network firewall list --output table
```

### Compliance & Policy

```bash
# List policy assignments
az policy assignment list --output table

# Show compliance state
az policy state list --output table

# List policy definitions
az policy definition list --output table

# Compliance summary
az policy state summarize --output table
```

### Logging & Monitoring

```bash
# List Log Analytics workspaces
az monitor log-analytics workspace list --output table

# List diagnostic settings
az monitor diagnostic-settings list --resource <resource-id> --output table

# Query logs (if you have access)
az monitor log-analytics query --workspace <workspace-id> --analytics-query "AzureActivity | take 10"
```

---

## 📝 Creating Security Scripts

### Script Template

```bash
#!/bin/bash
# Azure Security Assessment Script
# Author: Derek Brent Moore, Security Architect
# Date: October 13, 2025
# Purpose: Automated security checks for customer environment

# Set strict error handling
set -euo pipefail

# Configuration
SUBSCRIPTION_ID="<subscription-id>"
OUTPUT_DIR="./security-reports"
DATE=$(date +%Y%m%d_%H%M%S)

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Set subscription
echo "Setting subscription..."
az account set --subscription "$SUBSCRIPTION_ID"

# Resource Inventory
echo "Collecting resource inventory..."
az resource list --output json > "$OUTPUT_DIR/resources_$DATE.json"

# Security Assessment
echo "Running security assessment..."
az security assessment list --output json > "$OUTPUT_DIR/security_assessments_$DATE.json"

# RBAC Analysis
echo "Analyzing RBAC..."
az role assignment list --all --output json > "$OUTPUT_DIR/rbac_assignments_$DATE.json"

# Key Vault Audit
echo "Auditing Key Vaults..."
az keyvault list --output json > "$OUTPUT_DIR/keyvaults_$DATE.json"

# Network Security
echo "Checking network security..."
az network nsg list --output json > "$OUTPUT_DIR/nsgs_$DATE.json"

# Policy Compliance
echo "Checking policy compliance..."
az policy state list --output json > "$OUTPUT_DIR/policy_compliance_$DATE.json"

echo "Security assessment complete. Reports in $OUTPUT_DIR"
```

### Running Scripts Safely

```bash
# Make script executable
chmod +x security-assessment.sh

# Test with dry-run first
# Add --dry-run flag to commands if available

# Run with logging
./security-assessment.sh 2>&1 | tee security-assessment.log

# Review output before sharing
cat security-assessment.log | grep -i "error"

# Sanitize output files before sharing
# Remove any sensitive data, subscription IDs, etc.
```

---

## 🚨 Troubleshooting

### Common Issues

**Issue**: `az: command not found`
```bash
# Solution: Add to PATH
# Windows: Check installer completed successfully
# macOS: Run 'brew link azure-cli'
# Linux: Check /usr/bin/az exists

# Verify installation path
which az  # Should show path to az binary
```

**Issue**: `ERROR: Please run 'az login'`
```bash
# Solution: Login to tenant
az login --tenant <CUSTOMER-TENANT-ID>

# If browser doesn't open:
az login --use-device-code --tenant <CUSTOMER-TENANT-ID>
```

**Issue**: `ERROR: Tenant XYZ was not found`
```bash
# Solution: Verify tenant ID
# Ask customer for correct tenant ID
# Check if you're using tenant domain instead of ID

# Use tenant domain if ID unavailable:
az login --tenant customer.onmicrosoft.com
```

**Issue**: `ERROR: (AuthorizationFailed)`
```bash
# Solution: You don't have required permissions
# Expected for write operations (you have Reader role)
# For read operations, may need to request additional permissions

# Check your current permissions:
az role assignment list --assignee <your-email> --output table
```

**Issue**: `ERROR: The subscription is disabled`
```bash
# Solution: Use a different subscription
# List available subscriptions:
az account list --output table

# Switch to active subscription:
az account set --subscription <active-subscription-id>
```

**Issue**: MFA timeout during long scripts
```bash
# Solution: Refresh token before long operations
az account get-access-token --output none

# Or: Break scripts into smaller chunks
# Or: Use service principal (if customer allows and provides)
```

---

## 📊 Creating Reports

### Weekly Security Report Script

```bash
#!/bin/bash
# Weekly Security Report
# Run every Friday

DATE=$(date +%Y-%m-%d)
REPORT_FILE="security_report_$DATE.md"

cat > $REPORT_FILE << EOF
# Azure Security Report - $DATE

## Environment Summary
Subscription: $(az account show --query name -o tsv)
Total Resources: $(az resource list --query "length(@)")

## Security Posture
High Severity Findings: $(az security assessment list --query "[?status.code=='Unhealthy' && properties.metadata.severity=='High'] | length(@)")
Medium Severity Findings: $(az security assessment list --query "[?status.code=='Unhealthy' && properties.metadata.severity=='Medium'] | length(@)")

## RBAC Status
Total Role Assignments: $(az role assignment list --all --query "length(@)")
Owner Assignments: $(az role assignment list --all --query "[?roleDefinitionName=='Owner'] | length(@)")

## Key Vaults
Total Key Vaults: $(az keyvault list --query "length(@)")

## Policy Compliance
Non-Compliant Resources: $(az policy state list --query "[?complianceState=='NonCompliant'] | length(@)")

---
*Generated by Azure CLI on $DATE*
EOF

echo "Report created: $REPORT_FILE"
```

---

## ✅ Post-Installation Checklist

### Verify Setup
- [ ] Azure CLI installed and version confirmed
- [ ] Successfully logged in to customer tenant
- [ ] Default subscription set
- [ ] Permissions verified (read access confirmed)
- [ ] Output format configured
- [ ] Logging enabled
- [ ] Auto-complete configured (optional)

### Security Validation
- [ ] Using Azure AD authentication (no service principals)
- [ ] MFA working correctly
- [ ] Logout procedure tested
- [ ] No credentials stored in scripts
- [ ] Audit logging confirmed active

### Operational Readiness
- [ ] Essential commands tested
- [ ] First security assessment completed
- [ ] Resource inventory generated
- [ ] RBAC analysis completed
- [ ] Reports directory created
- [ ] Scripts saved and version controlled

### Documentation
- [ ] CLI access documented in work log
- [ ] Permissions documented
- [ ] Scripts documented with comments
- [ ] Report templates created
- [ ] Escalation procedures confirmed

---

## 🎯 Next Steps After CLI Setup

### Immediate (Day 1)
1. Run comprehensive resource inventory
2. Execute security assessment scan
3. Generate RBAC matrix
4. Create first weekly report
5. Document findings

### Week 1
1. Establish regular scanning schedule
2. Create automated security scripts
3. Set up report generation
4. Build compliance documentation
5. Identify priority remediation items

### Ongoing
1. Weekly security reports
2. Monthly compliance reviews
3. Quarterly RBAC audits
4. Continuous monitoring
5. Regular script updates

---

## 📞 Getting Help

### Azure CLI Help

```bash
# General help
az --help

# Help for specific command
az security --help
az security assessment --help

# Examples for specific command
az security assessment list --help

# Interactive mode
az interactive
```

### Customer Support Channels

Document your customer's support process:
- IT helpdesk: [Contact info]
- Security team: [Contact info]
- Azure subscription owner: [Contact info]
- Escalation procedure: [Process]

### Microsoft Documentation

- Azure CLI reference: https://learn.microsoft.com/en-us/cli/azure/
- Security commands: https://learn.microsoft.com/en-us/cli/azure/security
- RBAC commands: https://learn.microsoft.com/en-us/cli/azure/role

---

## 🔐 Security Reminders

### Always
- ✅ Use Azure AD authentication with MFA
- ✅ Log out when done
- ✅ Keep CLI version updated
- ✅ Review your activity in audit logs
- ✅ Follow customer security policies

### Never
- ❌ Share credentials or tokens
- ❌ Store secrets in scripts
- ❌ Commit credentials to git
- ❌ Use CLI commands in insecure environments
- ❌ Run untested scripts in production

---

**Status**: 📘 **REFERENCE GUIDE - Use When CLI Is Provisioned**  
**Audience**: 👤 **Derek Brent Moore, Security Architect**  
**Purpose**: 🎯 **Quick setup and operational reference**  
**Next Step**: ⏭️ **Submit IT request, then return to this guide**

---

📅 **Guide Created**: October 13, 2025  
🔧 **Azure CLI Version**: 2.50.0+ recommended  
🔐 **Security Level**: Enterprise, Constrained Environment  
✅ **Ready to Use**: As soon as Azure CLI is provisioned

**Save this guide - you'll need it when CLI access is granted!** 🚀

