# Output Data Folder

## ⚠️ IMPORTANT: Customer Data Protection

This folder is for **generated output data** from SecAI Framework assessment scripts.

**All files in this folder contain customer-specific data and should NEVER be committed to version control or shared publicly.**

---

## What Goes Here

After running the SecAI Framework collection scripts (01-09), this folder will contain:

### Foundation Files (4 files)
- `scope.json` - All subscriptions in scope
- `subscriptions.json` - Subscription details
- `management_groups.json` - Management group hierarchy
- `mg_sub_map.json` - MG to subscription mappings

### Per-Subscription Files (~850 files for 34 subscriptions)
- `{subscription-id}_rgs.json` - Resource groups
- `{subscription-id}_resources.json` - All resources
- `{subscription-id}_vnets.json` - Virtual networks
- `{subscription-id}_nsgs.json` - Network security groups
- `{subscription-id}_az_firewalls.json` - Azure Firewalls
- `{subscription-id}_load_balancers.json` - Load Balancers
- `{subscription-id}_storage.json` - Storage accounts
- `{subscription-id}_keyvaults.json` - Key Vaults
- ... and many more

### Summary Files (1 file)
- `evidence_counts.csv` - Evidence collection summary

---

## Data Protection Rules

### ❌ DO NOT:
- Commit any JSON or CSV files from this folder to git
- Share these files publicly
- Include in presentations or documentation
- Copy to unsecured locations
- Email or upload to public sites

### ✅ DO:
- Keep files in secure customer SharePoint/OneDrive
- Delete files after assessment is complete and archived
- Use .gitignore to prevent accidental commits
- Sanitize any examples before sharing

---

## Sanitization

If you need to create example files for documentation:

1. Replace customer names with generic placeholders:
   - Customer name → "Customer" or "Organization"
   - Specific company → "Enterprise"
   
2. Replace subscription names:
   - `SUB-CUSTOMER-PROD-...` → `SUB-EXAMPLE-PROD-...`
   
3. Replace management group names:
   - `MG-CUSTOMER-PROD-...` → `MG-EXAMPLE-PROD-...`

4. Anonymize subscription IDs:
   - Real GUID → Generic example GUID
   
5. Remove any:
   - Real resource names
   - IP addresses
   - Domain names
   - Tenant IDs

---

## Expected Behavior

### After Framework Installation
This folder should be **EMPTY** or contain only this README.

### After Running Assessment
This folder will contain **800+ files** with customer-specific configuration data.

### After Archiving Assessment
Move all files to secure archive location and **DELETE from this folder**.

---

## .gitignore Protection

A `.gitignore` file should be present to prevent accidental commits:

```gitignore
# Ignore all data files
*.json
*.csv

# Keep README
!README.md
```

---

## Data Lifecycle

```
1. Framework Installation
   └─> Output/ is empty ✅

2. Run Assessment Scripts
   └─> Output/ contains 800+ customer files ⚠️

3. Generate Reports
   └─> Use data from Output/ 📊

4. Archive Results
   └─> Copy to secure archive 📦

5. Clean Up
   └─> Delete all files from Output/ 🗑️
   └─> Output/ is empty again ✅
```

---

## Security Reminder

**This is a SANITIZED framework workspace.**

All customer-specific data must remain in the **secure customer environment** (SharePoint/OneDrive/Citrix).

The SecAI Framework itself should contain **NO customer data** - only scripts, templates, and documentation.

---

## Need Help?

See documentation:
- `../1-Documentation/README.md` - Framework overview
- `../1-Documentation/FRAMEWORK_OVERVIEW.md` - Complete methodology
- `../1-Documentation/EXECUTION_GUIDE.md` - Execution instructions

---

**Status:** 🟢 Sanitized (No customer data present)  
**Expected Files:** 0 (empty folder)  
**After Assessment:** 800+ files (customer-specific)  
**Protection:** .gitignore configured

