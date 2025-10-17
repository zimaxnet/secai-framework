# Quick Reference - Azure Permissions for Assessment

## What You Need to Request

### 1️⃣ Management Group Reader
**Why:** To see which subscriptions belong to which management groups  
**Role Name:** `Management Group Reader`  
**Where:** At the root/top-level Management Group  
**Impact:** Read-only, no write access

### 2️⃣ Resource Graph Access
**Why:** To query and aggregate data across subscriptions efficiently  
**Permission:** Usually included with Reader role, but may need explicit grant  
**Impact:** Read-only queries, no data modification

### 3️⃣ Reader on Subscriptions (confirm you have this)
**Why:** To view resources and configurations  
**Role Name:** `Reader`  
**Where:** All 35 subscriptions in scope  
**Impact:** Read-only, no write access

---

## Information to Provide in Your Request

**Your Details:**
- Your email address
- Your current tenant: `11514d53-14fb-44c6-9d8f-447443bff746`
- Number of subscriptions: 35

**Root Management Group ID (find this):**
To find your root MG ID, have your admin run:
```powershell
az account management-group list --query "[?displayName=='Tenant Root Group' || properties.tenantId!=null].name" -o tsv
```
Or look in Azure Portal → Management Groups → (top-level group)

---

## For Your Azure Administrator

### Commands to Grant Access

**Step 1: Grant Management Group Reader**
```powershell
# Replace [your-email] and [root-mg-id] with actual values
az role assignment create \
  --assignee [your-email@domain.com] \
  --role "Management Group Reader" \
  --scope /providers/Microsoft.Management/managementGroups/[root-mg-id]
```

**Step 2: Verify Resource Graph Access**
```powershell
# Check if user already has this (usually comes with Reader role)
az role assignment list --assignee [your-email@domain.com] --all --query "[?roleDefinitionName=='Reader']"
```

**Step 3: Verify Reader on Subscriptions**
```powershell
# List all subscriptions where user has Reader or higher
az role assignment list --assignee [your-email@domain.com] --all --query "[?roleDefinitionName=='Reader' || roleDefinitionName=='Contributor' || roleDefinitionName=='Owner'].{Role:roleDefinitionName, Scope:scope}"
```

### Validation After Granting
```powershell
# Test MG access
az account management-group list

# Test MG subscription mapping
az account management-group show --name [any-mg-name] --expand

# Test Resource Graph
az graph query -q "resourcecontainers | where type == 'microsoft.resources/subscriptions' | limit 1"
```

---

## Security Notes

✅ **What These Permissions DO:**
- Allow viewing management group structure
- Allow listing which subscriptions are in which MGs
- Allow querying resource metadata and configurations
- Enable automated, consistent evidence gathering

❌ **What These Permissions DO NOT Allow:**
- Creating, modifying, or deleting any resources
- Changing configurations or settings
- Accessing application data or customer data
- Modifying security policies or rules
- Any write operations whatsoever

📊 **Audit Trail:**
- All Azure CLI commands are logged in Azure Activity Log
- All API calls are tracked and auditable
- Resource Graph queries are logged
- Full transparency for security teams

---

## Alternative Options

If your organization is hesitant about permanent permissions:

### Option A: Time-Limited Assignment
Request permissions with automatic expiration (e.g., 30 days)

### Option B: PIM (Privileged Identity Management)
Request "eligible" assignment that requires approval each time you activate
- Just-in-time access
- Time-bound activation (e.g., 4-8 hours)
- Approval workflow
- Full audit trail

### Option C: Shared Service Account
Use a dedicated service account with these permissions
- You connect to Azure using the service account
- Service account is monitored/audited
- Can be revoked centrally

---

## Key Talking Points

When discussing with your manager or security team:

1. **Principle of Least Privilege:** Only requesting read access, nothing more
2. **Current State:** Can see MGs in portal, but need API access for automation
3. **Time Savings:** Manual evidence gathering for 35 subscriptions is not scalable
4. **Consistency:** Automated collection eliminates human error
5. **Compliance:** Many frameworks require documented evidence of configurations
6. **Industry Standard:** Read-only assessment access is standard practice for security audits

---

## Expected Timeline

After submitting request:
1. **Initial Review:** 1-2 business days
2. **Security Review:** 2-3 business days (if required)
3. **Manager Approval:** 1-2 business days (if required)
4. **Implementation:** < 1 day (running the Azure CLI commands takes minutes)
5. **Validation:** You can test immediately after implementation

**Total: Typically 5-10 business days**

---

## Files Created for Your Request

1. **SERVICENOW_REQUEST_SHORT.txt** - Copy/paste this into ServiceNow ticket
2. **PERMISSION_REQUEST_TEMPLATE.md** - Full detailed version if needed
3. **This file** - Quick reference for you and your admin

---

## Need Help?

If your request is denied or you need to provide additional justification:
- Emphasize read-only nature
- Offer time-limited or PIM alternative
- Propose pilot/trial period (e.g., 30 days)
- Offer to provide daily/weekly activity reports
- Reference compliance requirements (SOC2, ISO, NIST, etc.)

