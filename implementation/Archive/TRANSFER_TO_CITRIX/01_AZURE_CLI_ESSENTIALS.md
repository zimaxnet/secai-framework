# ⚡ Azure CLI Essentials for Security Architects

**Purpose**: Critical commands for security assessment and compliance  
**Use When**: Azure CLI is installed and configured

---

## 🔧 Initial Setup

### Installation Check
```bash
# Verify installation
az --version

# Should show Azure CLI 2.50.0+
```

### Authentication
```bash
# Login to customer tenant
az login --tenant <customer-tenant-id>

# List available subscriptions
az account list --output table

# Set active subscription
az account set --subscription <subscription-id>

# Verify current context
az account show
```

---

## 🔐 Security Assessment Commands

### Security Center / Defender
```bash
# List all security assessments
az security assessment list --output table

# Get security score
az security secure-score list --output table

# List security alerts
az security alert list --output table

# Get specific assessment details
az security assessment show --name <assessment-id>

# Export security assessments to JSON
az security assessment list > security_assessment.json
```

### Azure Policy Compliance
```bash
# List policy assignments
az policy assignment list --output table

# Check policy compliance state
az policy state list --output table

# Get compliance summary
az policy state summarize

# List non-compliant resources
az policy state list --filter "complianceState eq 'NonCompliant'" --output table

# Export policy state
az policy state list > policy_compliance.json
```

---

## 👥 Identity & Access Management

### RBAC Audit
```bash
# List ALL role assignments
az role assignment list --all --output table

# Role assignments for specific scope
az role assignment list --scope /subscriptions/<sub-id> --output table

# Role assignments for a user
az role assignment list --assignee <user-email> --output table

# List service principals
az ad sp list --all --output table

# Get service principal details
az ad sp show --id <sp-object-id>

# Export RBAC to file
az role assignment list --all > rbac_assignments.json
```

### Identity Analysis
```bash
# List all users
az ad user list --output table

# List all groups
az ad group list --output table

# Get group members
az ad group member list --group <group-name> --output table

# List privileged roles
az role definition list --custom-role-only false --output table | grep "Owner\|Contributor"
```

---

## 🔑 Key Vault Security

### Key Vault Inventory
```bash
# List all Key Vaults
az keyvault list --output table

# Get Key Vault details
az keyvault show --name <vault-name>

# List secrets (names only, not values!)
az keyvault secret list --vault-name <vault-name> --output table

# Check Key Vault access policies
az keyvault show --name <vault-name> --query properties.accessPolicies

# List Key Vault network rules
az keyvault network-rule list --name <vault-name>

# Export Key Vault inventory
az keyvault list > keyvault_inventory.json
```

---

## 🌐 Network Security

### Network Security Groups
```bash
# List all NSGs
az network nsg list --output table

# Get NSG rules
az network nsg rule list --nsg-name <nsg-name> --resource-group <rg-name> --output table

# Show NSG effective rules
az network nic list-effective-nsg --name <nic-name> --resource-group <rg-name>

# Find NSGs with permissive rules (export and grep)
az network nsg list > nsg_inventory.json
```

### Virtual Networks
```bash
# List all VNets
az network vnet list --output table

# Get VNet details
az network vnet show --name <vnet-name> --resource-group <rg-name>

# List subnets
az network vnet subnet list --vnet-name <vnet-name> --resource-group <rg-name> --output table

# Check for service endpoints
az network vnet subnet show --name <subnet-name> --vnet-name <vnet-name> --resource-group <rg-name> --query serviceEndpoints
```

### Public IP Addresses
```bash
# List all public IPs
az network public-ip list --output table

# Find resources with public IPs
az network public-ip list --query "[].{Name:name, IP:ipAddress, Resource:ipConfiguration.id}" --output table
```

---

## 💾 Storage Security

### Storage Account Audit
```bash
# List all storage accounts
az storage account list --output table

# Check storage account encryption
az storage account show --name <storage-name> --query encryption

# Check public access level
az storage account show --name <storage-name> --query allowBlobPublicAccess

# List storage account network rules
az storage account show --name <storage-name> --query networkRuleSet

# Export storage inventory
az storage account list > storage_inventory.json
```

---

## 📊 Resource Inventory

### Complete Resource Listing
```bash
# List all resources
az resource list --output table

# List resources by type
az resource list --resource-type "Microsoft.Compute/virtualMachines" --output table

# List resources by resource group
az resource list --resource-group <rg-name> --output table

# List all resource groups
az group list --output table

# Export complete inventory
az resource list > complete_resource_inventory.json
```

### Tagging Audit
```bash
# List resources without required tags
az resource list --query "[?tags.Environment==null]" --output table

# Show all tags across resources
az tag list --output table
```

---

## 📈 Monitoring & Logging

### Diagnostic Settings
```bash
# List diagnostic settings for a resource
az monitor diagnostic-settings list --resource <resource-id>

# Show diagnostic setting details
az monitor diagnostic-settings show --name <setting-name> --resource <resource-id>
```

### Activity Logs
```bash
# Query activity logs (last 7 days)
az monitor activity-log list --start-time 2025-10-07T00:00:00Z --output table

# Filter by operation
az monitor activity-log list --filters "operationName eq 'Microsoft.Compute/virtualMachines/write'"

# Export activity logs
az monitor activity-log list > activity_logs.json
```

---

## 🔍 Security Scanning Scripts

### Quick Security Scan
```bash
#!/bin/bash
# save as: quick_security_scan.sh

echo "=== Azure Security Quick Scan ==="
echo ""

echo "1. Security Assessments:"
az security assessment list --query "[?status.code=='Unhealthy']" --output table
echo ""

echo "2. Policy Non-Compliance:"
az policy state list --filter "complianceState eq 'NonCompliant'" --output table
echo ""

echo "3. Public IP Addresses:"
az network public-ip list --output table
echo ""

echo "4. Storage Accounts with Public Access:"
az storage account list --query "[?allowBlobPublicAccess==true]" --output table
echo ""

echo "5. NSGs with Wide-Open Rules:"
az network nsg list --output json | jq '.[] | select(.securityRules[].destinationAddressPrefix=="*")'
echo ""

echo "Scan complete: $(date)"
```

### RBAC Audit Script
```bash
#!/bin/bash
# save as: rbac_audit.sh

echo "=== RBAC Audit ==="
echo ""

echo "1. Owner Role Assignments:"
az role assignment list --all --query "[?roleDefinitionName=='Owner']" --output table
echo ""

echo "2. Contributor Role Assignments:"
az role assignment list --all --query "[?roleDefinitionName=='Contributor']" --output table
echo ""

echo "3. Service Principal Assignments:"
az role assignment list --all --query "[?principalType=='ServicePrincipal']" --output table
echo ""

echo "Audit complete: $(date)"
```

### Compliance Check Script
```bash
#!/bin/bash
# save as: compliance_check.sh

echo "=== Compliance Check ==="
echo ""

echo "1. Policy Compliance Summary:"
az policy state summarize
echo ""

echo "2. Security Score:"
az security secure-score list --output table
echo ""

echo "3. Key Vault Compliance:"
az keyvault list --query "[].{Name:name, SoftDelete:properties.enableSoftDelete, PurgeProtection:properties.enablePurgeProtection}" --output table
echo ""

echo "4. Storage Encryption Status:"
az storage account list --query "[].{Name:name, Encryption:encryption.services.blob.enabled}" --output table
echo ""

echo "Check complete: $(date)"
```

---

## 📁 Export All Data Script

```bash
#!/bin/bash
# save as: export_all_security_data.sh

EXPORT_DIR="azure_security_export_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EXPORT_DIR"

echo "Exporting all security data to: $EXPORT_DIR"

# Security assessments
az security assessment list > "$EXPORT_DIR/security_assessments.json"

# Policy compliance
az policy state list > "$EXPORT_DIR/policy_compliance.json"

# RBAC assignments
az role assignment list --all > "$EXPORT_DIR/rbac_assignments.json"

# Resources
az resource list > "$EXPORT_DIR/resources.json"

# Network security
az network nsg list > "$EXPORT_DIR/nsgs.json"
az network public-ip list > "$EXPORT_DIR/public_ips.json"

# Storage
az storage account list > "$EXPORT_DIR/storage_accounts.json"

# Key Vaults
az keyvault list > "$EXPORT_DIR/keyvaults.json"

# Activity logs (last 7 days)
az monitor activity-log list --start-time $(date -d '7 days ago' +%Y-%m-%dT00:00:00Z) > "$EXPORT_DIR/activity_logs.json"

echo "Export complete!"
echo "Files saved to: $EXPORT_DIR"
```

---

## 🚨 Common Security Findings to Check

### 1. Publicly Accessible Resources
```bash
# Find public storage containers
az storage account list --query "[?allowBlobPublicAccess==true].name"

# Find VMs with public IPs
az vm list-ip-addresses --output table
```

### 2. Weak Access Controls
```bash
# Find overly permissive NSG rules
az network nsg list --output json | jq '.[] | .securityRules[] | select(.sourceAddressPrefix=="*" or .sourceAddressPrefix=="Internet")'

# Find "*" in RBAC scope (broad permissions)
az role assignment list --all --query "[?scope=='/']"
```

### 3. Missing Security Features
```bash
# Key Vaults without soft delete
az keyvault list --query "[?properties.enableSoftDelete==false]"

# Storage without encryption
az storage account list --query "[?encryption.services.blob.enabled==false]"
```

---

## 💡 Pro Tips

1. **Always export to files** - Portal-only access means data can disappear
2. **Use `--output table`** for readability, `--output json` for processing
3. **Query with JQ** - Parse JSON efficiently (`az ... | jq '.[] | select(...)'`)
4. **Script everything** - Repeatability is key for continuous monitoring
5. **Never store credentials** - Use Azure AD auth, no service principal secrets

---

## 📊 Weekly Security Report Template

```bash
#!/bin/bash
# save as: weekly_security_report.sh

REPORT_FILE="weekly_security_report_$(date +%Y%m%d).txt"

{
  echo "========================================"
  echo "Weekly Security Report"
  echo "Generated: $(date)"
  echo "========================================"
  echo ""
  
  echo "1. SECURITY SCORE:"
  az security secure-score list --output table
  echo ""
  
  echo "2. TOP SECURITY ISSUES:"
  az security assessment list --query "[?status.code=='Unhealthy'] | [0:10]" --output table
  echo ""
  
  echo "3. POLICY COMPLIANCE:"
  az policy state summarize
  echo ""
  
  echo "4. NEW RBAC CHANGES (Last 7 days):"
  az monitor activity-log list --filters "operationName eq 'Microsoft.Authorization/roleAssignments/write'" --start-time $(date -d '7 days ago' +%Y-%m-%dT00:00:00Z) --output table
  echo ""
  
  echo "5. PUBLIC RESOURCES:"
  az network public-ip list --output table
  echo ""
  
  echo "========================================"
  echo "End of Report"
  echo "========================================"
} > "$REPORT_FILE"

echo "Report saved to: $REPORT_FILE"
```

---

**Remember**: These commands are read-only focused. Request write permissions only when needed for remediation, with proper justification and approval.

🛡️ **Use responsibly. Audit everything. Security first.**


