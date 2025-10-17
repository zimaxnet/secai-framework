# Azure Assessment Kit - Execution Guide

## All Scripts Enhanced and Ready! ✅

All assessment scripts have been enhanced with:
- Progress indicators (`[X/34] Processing...`)
- Color-coded status messages
- Proper error handling
- JSON validation
- Summary statistics
- Critical bug fixes

---

## Execution Order

Run the scripts in this exact order:

### ✅ Phase 1: Setup & Authentication (Already Complete)

```powershell
cd C:\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts

# Optional: Check your permissions
.\00_diagnostics.ps1

# Login to Azure
.\00_login.ps1
```

---

### ✅ Phase 2: Foundation (Already Complete)

```powershell
# Discover scope (management groups & subscriptions)
.\01_scope_discovery.ps1
# ✓ COMPLETE - 34 subscriptions found

# Inventory all resources
.\02_inventory.ps1
# ✓ COMPLETE - 856 resource groups, 5,088 resources
```

---

### ⏭️ Phase 3: Security Assessment (Ready to Execute)

Execute these in order. Each script processes all 34 subscriptions.

#### Script 03: Policies and Defender for Cloud
```powershell
.\03_policies_and_defender.ps1
```
**Estimated Time:** ~15 minutes  
**Collects:**
- Tenant policy definitions
- Policy assignments per subscription
- Policy set definitions (initiatives)
- Defender for Cloud pricing tiers
- Regulatory compliance standards

---

#### Script 04: Identity and Privileged Access
```powershell
.\04_identity_and_privileged.ps1
```
**Estimated Time:** ~10-15 minutes  
**Collects:**
- Azure AD applications (tenant-wide)
- Service principals (tenant-wide)
- RBAC role assignments per subscription

**Note:** Tenant-wide AD queries may take several minutes for large environments.

---

#### Script 05: Network Security
```powershell
.\05_network_security.ps1
```
**Estimated Time:** ~20 minutes  
**Collects:**
- Virtual Networks (VNets)
- Network Security Groups (NSGs)
- Application Security Groups (ASGs)
- Route Tables
- Azure Firewalls
- Private Endpoints

---

#### Script 06: Data Protection
```powershell
.\06_data_protection.ps1
```
**Estimated Time:** ~10-15 minutes  
**Collects:**
- Storage Accounts
- Key Vaults
- SQL Servers
- SQL Databases (queried per server - FIXED)

**Note:** This script includes the critical fix for SQL database enumeration.

---

#### Script 07: Logging and Threat Detection
```powershell
.\07_logging_threat_detection.ps1
```
**Estimated Time:** ~10 minutes  
**Collects:**
- Log Analytics Workspaces
- Subscription diagnostic settings
- Microsoft Sentinel detection

---

#### Script 08: Backup and Recovery
```powershell
.\08_backup_recovery.ps1
```
**Estimated Time:** ~10 minutes  
**Collects:**
- Recovery Services Vaults
- Backup Policies (queried per vault - FIXED)

**Note:** This script includes the critical fix for backup policy enumeration.

---

#### Script 09: Security Posture and Vulnerability
```powershell
.\09_posture_vulnerability.ps1
```
**Estimated Time:** ~10 minutes  
**Collects:**
- Secure Scores from Defender for Cloud
- Security Assessments
- Unhealthy assessment counts

---

### ⏭️ Phase 4: Evidence Summary (Optional)

#### Script 10: Evidence Counter
```powershell
# Run Python evidence counter
python 10_evidence_counter.py

# OR use PowerShell to view results
Get-Content ..\out\evidence_counts.csv
```
**Estimated Time:** < 1 minute  
**Creates:** CSV summary of all collected evidence

---

## Total Estimated Runtime

| Phase | Scripts | Time |
|-------|---------|------|
| Phase 1 | Setup | 2 min |
| Phase 2 | Foundation | ✓ Complete |
| Phase 3 | Security (03-09) | ~85-95 min |
| Phase 4 | Summary | 1 min |
| **TOTAL** | | **~90 minutes** |

---

## Run All Remaining Scripts (Automated)

If you want to run all Phase 3 scripts in sequence without interaction:

```powershell
# Run all security assessment scripts
$scripts = @(
    "03_policies_and_defender.ps1",
    "04_identity_and_privileged.ps1",
    "05_network_security.ps1",
    "06_data_protection.ps1",
    "07_logging_threat_detection.ps1",
    "08_backup_recovery.ps1",
    "09_posture_vulnerability.ps1"
)

$startTime = Get-Date

foreach ($script in $scripts) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "EXECUTING: $script" -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host ""
    
    & ".\$script"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WARNING: Script $script completed with errors" -ForegroundColor Yellow
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ALL SCRIPTS COMPLETE!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total execution time: $($duration.ToString('hh\:mm\:ss'))" -ForegroundColor White
Write-Host ""
```

---

## Output Files

After running all scripts, you'll have these files in `C:\CustomerEnv-Workspace\Azure_Assessment_Kit\out\`:

### Foundation Files (4 files)
- `management_groups.json`
- `subscriptions.json`
- `mg_sub_map.json`
- `scope.json`

### Per-Subscription Files (34 subscriptions × multiple files)

**Inventory (3 files × 34 subs = 102 files)**
- `{sub}_rgs.json`
- `{sub}_resources.json`
- `{sub}_resource_type_counts.json`

**Policies & Defender (4 files × 34 subs = 136 files)**
- `{sub}_policy_assignments.json`
- `{sub}_policy_set_definitions.json`
- `{sub}_defender_pricing.json`
- `{sub}_regulatory_compliance.json`

**Identity & Access (1 file × 34 subs = 34 files)**
- `{sub}_role_assignments.json`

**Network (6 files × 34 subs = 204 files)**
- `{sub}_vnets.json`
- `{sub}_nsgs.json`
- `{sub}_asgs.json`
- `{sub}_route_tables.json`
- `{sub}_az_firewalls.json`
- `{sub}_private_endpoints.json`

**Data Protection (4 files × 34 subs = 136 files)**
- `{sub}_storage.json`
- `{sub}_keyvaults.json`
- `{sub}_sql_servers.json`
- `{sub}_sql_dbs.json`

**Logging (3 files × 34 subs = 102 files)**
- `{sub}_la_workspaces.json`
- `{sub}_subscription_diag.json`
- `{sub}_sentinel.json`

**Backup (2 files × 34 subs = 68 files)**
- `{sub}_recovery_vaults.json`
- `{sub}_backup_policies.json`

**Security Posture (2 files × 34 subs = 68 files)**
- `{sub}_secure_score.json`
- `{sub}_security_assessments.json`

### Tenant-Wide Files (3 files)
- `tenant_policy_definitions.json`
- `tenant_applications.json`
- `tenant_service_principals.json`

### Summary Files (1 file)
- `evidence_counts.csv`

**TOTAL: ~858 files** containing complete Azure security assessment data!

---

## What to Expect

### During Execution:
- Progress counter: `[12/34] Processing: Subscription Name`
- Color-coded status:
  - 🟢 Green: Success
  - 🟡 Yellow: Warnings (non-critical)
  - 🔴 Red: Errors
  - ⚪ Gray: Info/skipped items

### At the End of Each Script:
- Summary showing:
  - Subscriptions processed
  - Any errors encountered
  - Total counts of collected items
  - Output directory location

---

## Troubleshooting

### If a script fails:
1. Check the error message (color-coded in red)
2. Review permissions - run `.\00_diagnostics.ps1`
3. Check if specific Azure features are enabled (Defender, Backup, etc.)
4. Continue with next script - scripts are independent

### Common Issues:

**"Failed to retrieve X"**
- May lack Reader permissions on that subscription
- Feature may not be enabled (e.g., Defender, Sentinel)
- Scripts continue anyway, saving empty arrays

**"Could not parse X"**
- Azure CLI returned unexpected format
- Script saves raw output for manual review
- Not critical - continue execution

**Script appears frozen**
- Scripts now show progress - you'll see `[X/34]` counting up
- Tenant-wide queries (scripts 03, 04) take longest
- Be patient - processing 34 subscriptions takes time

---

## After Completion

1. **Review Summary Outputs**
   - Check the summary at the end of each script
   - Note any subscriptions that had errors
   
2. **Run Evidence Counter**
   - `python 10_evidence_counter.py`
   - Review `evidence_counts.csv`
   
3. **Spot Check Output Files**
   - Open a few JSON files to verify data quality
   - Check file sizes (0 KB = empty/error)
   
4. **Archive Results**
   - Compress the entire `out` folder
   - Store with timestamp: `assessment_2025-10-15.zip`

---

## Permission Issues?

If you're still seeing permission errors for Management Groups:
- Refer to: `PERMISSION_REQUEST_TEMPLATE.md`
- Or use: `SERVICENOW_REQUEST_SHORT.txt`
- Quick ref: `QUICK_REFERENCE_PERMISSIONS.md`

---

## Questions?

Refer to these documents in the scripts folder:
- `POWERSHELL_README.md` - General PowerShell usage
- `SCRIPT_REVIEW.md` - Detailed script analysis
- `FIXES_APPLIED.md` - What was fixed and why

---

## Ready to Execute!

All scripts are enhanced and ready. Start with script 03 and work your way through to 09.

Good luck with your assessment! 🚀

