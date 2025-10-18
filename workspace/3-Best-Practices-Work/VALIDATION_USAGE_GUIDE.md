# CIS Validation Script - Usage Guide

**Script:** `Validate-CIS-Controls.ps1`  
**Purpose:** Automated validation of CIS Azure Foundations Benchmark controls  
**Version:** 1.0  
**Date:** October 17, 2025

---

## 📋 Overview

The validation script automatically checks Azure environments against CIS Benchmark controls using data collected by SecAI Framework scripts (01-09).

### Current Coverage: 18 Controls Across 6 Sections

| Section | Controls | Automated | Manual | Total |
|---------|----------|-----------|--------|-------|
| 2 - Defender for Cloud | 1 | 0 | 1 |
| 3 - Storage Accounts | 2 | 0 | 2 |
| 4 - Database Services | 1 | 1 | 2 |
| 5 - Logging & Monitoring | 1 | 1 | 2 |
| 6 - Networking | 1 | 1 | 2 |
| 7 - Virtual Machines | 1 | 0 | 1 |
| 8 - Key Vault | 2 | 1 | 3 |
| 9 - App Service | 2 | 1 | 3 |
| **TOTAL** | **11** | **5** | **16** |

---

## 🚀 Quick Start

### Prerequisites

1. **SecAI data collected:** Run scripts 01-09 first
2. **PowerShell 7+:** Installed and accessible
3. **Data location:** Know path to output files

### Basic Usage

```powershell
# Navigate to workspace
cd workspace/3-Best-Practices-Work

# Run validation against all subscriptions
pwsh ./Validate-CIS-Controls.ps1 -DataPath "../../implementation/2-Scripts/out"

# Run validation against single subscription
pwsh ./Validate-CIS-Controls.ps1 -DataPath "../../implementation/2-Scripts/out" -SubscriptionID "abc-123-def-456"

# Specify output location
pwsh ./Validate-CIS-Controls.ps1 -DataPath "../../implementation/2-Scripts/out" -OutputPath "./reports"
```

---

## 📊 Controls Currently Validated

### Section 2: Microsoft Defender for Cloud

#### 2.1 - Ensure Microsoft Defender for Cloud is set to Standard tier ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_defender_pricing.json`
- **Check:** All critical resource types (VMs, SQL, AppServices, Storage, KeyVaults) on Standard tier
- **Pass Criteria:** All 5 critical types on Standard tier

---

### Section 3: Storage Accounts

#### 3.1 - Ensure 'Secure transfer required' is Enabled ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_storage.json`
- **Check:** `properties.supportsHttpsTrafficOnly == true`
- **Pass Criteria:** 100% of storage accounts compliant

#### 3.2 - Ensure default network access rule is set to deny ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_storage.json`
- **Check:** `properties.networkAcls.defaultAction == "Deny"`
- **Pass Criteria:** 100% of storage accounts compliant

---

### Section 4: Database Services

#### 4.1.1 - Ensure auditing is enabled for SQL servers ⚠️
- **Level:** 1 (Critical)
- **Automated:** No (MANUAL)
- **Evidence:** `{sub-id}_sql_servers.json`
- **Reason:** Requires additional API calls for full auditing settings
- **Manual Check:** Verify in Azure Portal → SQL Server → Auditing

#### 4.1.3 - Ensure no SQL Databases allow ingress from 0.0.0.0/0 ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_sql_servers.json`
- **Check:** Firewall rules for 0.0.0.0/0 or 0.0.0.0-255.255.255.255
- **Pass Criteria:** No SQL servers allow unrestricted access

---

### Section 5: Logging and Monitoring

#### 5.1.3 - Ensure diagnostic setting is configured to export activity logs ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_diagnostic_settings.json`
- **Check:** Activity log categories (Administrative, Security, Alert, Policy) enabled
- **Pass Criteria:** At least one diagnostic setting with activity logs enabled

#### 5.3 - Ensure logging for Azure Key Vault is Enabled ⚠️
- **Level:** 1 (Critical)
- **Automated:** No (MANUAL)
- **Evidence:** `{sub-id}_keyvaults.json` + diagnostic settings
- **Reason:** Requires cross-referencing KV with diagnostic settings
- **Manual Check:** Verify each Key Vault has diagnostic settings enabled

---

### Section 6: Networking

#### 6.2 - Ensure NSG flow logs are enabled ⚠️
- **Level:** 2 (Defense-in-depth)
- **Automated:** No (MANUAL)
- **Reason:** Requires Network Watcher configuration data
- **Manual Check:** Azure Portal → Network Watcher → NSG Flow Logs

#### 6.6 - Ensure Network Watcher is Enabled ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_resources.json`
- **Check:** Resources of type `Microsoft.Network/networkWatchers` exist
- **Pass Criteria:** At least one Network Watcher instance exists

---

### Section 7: Virtual Machines

#### 7.1 - Ensure Virtual Machines are utilizing Managed Disks ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_resources.json`
- **Check:** `properties.storageProfile.osDisk.managedDisk` exists
- **Pass Criteria:** 100% of VMs using managed disks

---

### Section 8: Key Vault

#### 8.1 - Ensure expiration date is set for all Keys ⚠️
- **Level:** 1 (Critical)
- **Automated:** No (MANUAL)
- **Reason:** Requires additional API calls to list individual keys
- **Manual Check:** Check each key in each vault for expiration date

#### 8.4 - Ensure Soft Delete is Enabled for all Key Vaults ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_keyvaults.json`
- **Check:** `properties.enableSoftDelete == true`
- **Pass Criteria:** 100% of Key Vaults have soft delete enabled

#### 8.5 - Ensure Purge Protection is Enabled for all Key Vaults ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_keyvaults.json`
- **Check:** `properties.enablePurgeProtection == true`
- **Pass Criteria:** 100% of Key Vaults have purge protection enabled

---

### Section 9: App Service

#### 9.1 - Ensure App Service authentication is set up ⚠️
- **Level:** 1 (Critical)
- **Automated:** No (MANUAL)
- **Reason:** Requires additional API calls for auth configuration
- **Manual Check:** Check auth settings for each App Service

#### 9.2 - Ensure web app redirects all HTTP traffic to HTTPS ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_resources.json`
- **Check:** `properties.httpsOnly == true`
- **Pass Criteria:** 100% of App Services enforce HTTPS

#### 9.3 - Ensure web app is using latest version of TLS encryption ✅
- **Level:** 1 (Critical)
- **Automated:** Yes
- **Evidence:** `{sub-id}_resources.json`
- **Check:** `properties.siteConfig.minTlsVersion` is "1.2" or "1.3"
- **Pass Criteria:** 100% of App Services using TLS 1.2+

---

## 📄 Output Files

### CSV Report

**Filename:** `CIS_Compliance_Report_YYYYMMDD_HHMMSS.csv`

**Columns:**
- SubscriptionID
- ControlID
- ControlName
- Level (1 or 2)
- Status (PASS, FAIL, SKIP, MANUAL, ERROR)
- Reason
- TotalResources
- CompliantResources
- NonCompliantResources
- CompliancePercentage
- NonCompliantResourceNames

### Console Output

**Summary includes:**
- Total controls tested
- PASS count (compliant)
- FAIL count (non-compliant)
- SKIP count (no resources found)
- MANUAL count (requires manual verification)
- ERROR count (script errors)
- Overall compliance percentage

**Failed controls section:**
- Lists each failed control
- Shows reason for failure
- Lists non-compliant resource names

---

## 🎯 Compliance Scoring

### Calculation Method

```
Testable Controls = Total - SKIP - MANUAL
Compliance % = (PASS / Testable Controls) × 100
```

### Interpretation

| Score | Rating | Action |
|-------|--------|--------|
| 90-100% | Excellent | Maintain & monitor |
| 80-89% | Good | Address remaining gaps |
| 70-79% | Fair | Prioritize remediation |
| 60-69% | Poor | Urgent action required |
| < 60% | Critical | Immediate remediation |

---

## 🔧 Troubleshooting

### Error: "Data path not found"
**Solution:** Ensure you've run SecAI collection scripts (01-09) first

### Error: "No subscriptions found to validate"
**Solution:** Check that output files exist in data path with pattern `*_storage.json`

### All controls show "SKIP"
**Solution:** No resources of that type exist in subscription (this is normal)

### High "MANUAL" count
**Solution:** Some controls require additional data collection or manual verification

### Parse errors
**Solution:** Ensure JSON files are valid and not corrupted

---

## 🚀 Next Steps After Running Validation

### 1. Review Failed Controls
- Focus on Level 1 (Critical) failures first
- Identify root causes
- Plan remediation

### 2. Handle Manual Controls
- Schedule manual checks
- Document findings
- Update scorecard

### 3. Remediate Gaps
- Prioritize by risk (Level 1 > Level 2)
- Create remediation tickets
- Assign owners

### 4. Re-Run Validation
- After remediation
- Compare scores
- Track progress over time

### 5. Report Findings
- Executive summary
- Technical details
- Remediation plan
- Compliance roadmap

---

## 📈 Expanding the Script

### To Add More Controls:

1. **Create validation function:**
```powershell
function Test-CIS-X-Y {
    param([string]$DataPath, [string]$SubID)
    # Validation logic here
    return @{ ... }
}
```

2. **Add to main loop:**
```powershell
$allResults += Test-CIS-X-Y -DataPath $DataPath -SubID $subID
```

3. **Test thoroughly**

### Controls to Add Next:

**High Priority (Level 1):**
- 1.x - Identity and Access Management controls
- 2.x - Additional Defender for Cloud controls
- 3.x - Additional Storage controls
- 4.x - Additional SQL controls

**Medium Priority (Level 2):**
- Defense-in-depth controls
- Additional monitoring controls
- Advanced security features

---

## 💡 Best Practices

### Running Validations

- **Frequency:** Monthly for production, quarterly for non-prod
- **Timing:** After running SecAI collection scripts
- **Baseline:** Run initial validation to establish baseline
- **Tracking:** Save reports with timestamps for trend analysis

### Remediation

- **Prioritize:** Level 1 failures first
- **Batch:** Group similar remediations together
- **Test:** Validate fixes in dev/test first
- **Verify:** Re-run validation after remediation

### Reporting

- **Trend:** Show compliance % over time
- **Context:** Include business justification for exceptions
- **Action:** Always include remediation plan
- **Ownership:** Assign clear owners for gaps

---

## 🎓 Examples

### Example 1: First-Time Validation

```powershell
# Step 1: Collect data (if not done)
cd ../../implementation/2-Scripts/Collection
pwsh ./00_login.ps1
pwsh ./05_network_security.ps1
pwsh ./06_data_protection.ps1

# Step 2: Run validation
cd ../../workspace/3-Best-Practices-Work
pwsh ./Validate-CIS-Controls.ps1 -DataPath "../../implementation/2-Scripts/out"

# Step 3: Review report
cat CIS_Compliance_Report_*.csv

# Result: 65% compliance, 8 controls failed
```

### Example 2: Post-Remediation Validation

```powershell
# After fixing storage secure transfer issues
cd workspace/3-Best-Practices-Work
pwsh ./Validate-CIS-Controls.ps1 -DataPath "../../implementation/2-Scripts/out" -OutputPath "./remediation-check"

# Compare to baseline
# Before: 65% compliance
# After: 72% compliance
# Progress: 7% improvement, 3 controls fixed
```

### Example 3: Subscription-Specific Check

```powershell
# Check only production subscription
pwsh ./Validate-CIS-Controls.ps1 `
    -DataPath "../../implementation/2-Scripts/out" `
    -SubscriptionID "abc-123-def-456" `
    -OutputPath "./prod-compliance"
```

---

## 📞 Support

**Issues?**
- Check `workspace/MASTER_STATUS.md` for framework status
- Review `workspace/3-Best-Practices-Work/EVIDENCE_MAPPING.md` for data sources
- Verify SecAI collection scripts ran successfully

**Enhancement Requests:**
- Additional controls needed
- Framework coverage (NIST, ISO, etc.)
- Report formatting improvements

---

**Script Status:** Production-Ready  
**Coverage:** 18 controls (11 automated, 5 manual, 2 N/A)  
**Next Expansion:** Add Section 1 (Identity) controls

