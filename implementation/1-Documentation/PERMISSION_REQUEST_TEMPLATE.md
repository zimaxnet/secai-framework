# Azure Assessment Permissions Request

## ServiceNow Request Template

---

**Subject:** Azure RBAC Permissions Request - Security Assessment and Evidence Gathering

**Priority:** Normal

**Category:** Access Request

**Description:**

I am conducting a comprehensive Azure security assessment and evidence gathering exercise for compliance and governance purposes. I currently have access to view subscriptions and management groups in the Azure Portal, but lack the necessary API-level permissions required for automated evidence collection.

**Current Issue:**
- Can view management groups in the Azure Portal
- Cannot list management group hierarchy or subscription mappings via Azure CLI/API
- Do not have access to Azure Resource Graph queries

**Permissions Requested:**

### 1. Management Group Reader Role
**Role:** `Management Group Reader`  
**Scope:** Root Management Group (to inherit across all child MGs)  
**Specific Scope Path:** `/providers/Microsoft.Management/managementGroups/{root-mg-id}`  
**Justification:** Required to programmatically list management groups and view which subscriptions belong to each management group for organizational hierarchy documentation.

**PowerShell Command for Administrator:**
```powershell
az role assignment create \
  --assignee {my-email@domain.com} \
  --role "Management Group Reader" \
  --scope /providers/Microsoft.Management/managementGroups/{root-mg-id}
```

### 2. Azure Resource Graph Reader Access
**Permission:** Query access to Azure Resource Graph  
**Justification:** Required to query resource relationships, subscription-to-management-group mappings, and aggregate resource inventory data across multiple subscriptions efficiently.

**Note:** This is typically included when the user has Reader role on subscriptions, but may require the `Microsoft.ResourceGraph/resources/read` permission to be explicitly granted.

**PowerShell Command for Administrator:**
```powershell
# Usually inherited with Reader role, but can be explicitly granted:
az role assignment create \
  --assignee {my-email@domain.com} \
  --role "Reader" \
  --scope /subscriptions/{subscription-id}
```

### 3. Confirm Reader Access on All In-Scope Subscriptions
**Role:** `Reader`  
**Scope:** All subscriptions within the tenant that are in scope for assessment  
**Justification:** Read-only access to inventory resources, configurations, and settings for security assessment and evidence gathering. No write or modify permissions requested.

---

**Assessment Scope:**
The assessment will gather evidence across the following areas:
- Subscription and Management Group hierarchy
- Resource inventory (VMs, storage, networks, databases)
- Azure Policy assignments and compliance status
- Microsoft Defender for Cloud security posture
- Identity and access management configurations
- Network security settings (NSGs, firewalls, private endpoints)
- Data protection configurations (encryption, backups)
- Logging and monitoring configurations
- Compliance and vulnerability assessment data

**Security Considerations:**
- All requested permissions are **read-only** - no write, modify, or delete permissions requested
- Permissions follow principle of least privilege
- Access required for time-bound assessment project
- Evidence will be collected using official Azure CLI tools
- All data will be handled per organizational data classification policies

**Duration:**
[Specify timeframe - e.g., "Required for 30 days during assessment period" or "Ongoing for continuous compliance monitoring"]

**Business Justification:**
Security and compliance assessment to ensure Azure environment meets organizational security standards, identify potential risks, and generate evidence for audit and governance requirements.

---

## Alternative: Temporary Elevated Access

If permanent role assignment is not preferred, please consider:

**Option:** Azure AD Privileged Identity Management (PIM) eligible assignment  
**Duration:** Time-bound activation (e.g., 8 hours per day during assessment period)  
**Justification:** Allows just-in-time access with approval workflow and audit trail

---

## Contact Information

**Requestor:** [Your Name]  
**Email:** [Your Email]  
**Department:** [Your Department]  
**Manager Approval:** [Manager Name/Email if required]

---

## For Approver Reference

### Verification Commands (After Permissions Granted)

To verify permissions have been correctly applied:

```powershell
# Check management group access
az account management-group list

# Check specific MG details
az account management-group show --name {mg-name}

# Test Resource Graph query
az graph query -q "resourcecontainers | where type == 'microsoft.resources/subscriptions' | limit 1"

# List role assignments
az role assignment list --assignee {email} --all
```

### Security Impact Assessment
- **Risk Level:** Low (read-only access)
- **Data Exposure:** Configuration data only, no customer/business data access
- **Audit Trail:** All Azure CLI commands are logged in Azure Activity Log
- **Compliance:** Aligns with least privilege access principles

---

## Additional Notes

These permissions are the **minimum required** to complete automated evidence gathering. Current manual workarounds (portal screenshots, manual documentation) are time-intensive and error-prone. Programmatic access enables:
- Consistent, repeatable evidence collection
- Reduced human error
- Complete audit trail
- Faster assessment completion
- Better documentation quality

Thank you for your consideration of this request.

