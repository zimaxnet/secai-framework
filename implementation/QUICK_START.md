# SecAI Framework - Quick Start Guide

**Get started in 15 minutes**

---

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] **Azure CLI** installed (`az --version` to verify)
- [ ] **PowerShell 5.1+** or **PowerShell Core 7+** (`$PSVersionTable` to check)
- [ ] **Python 3.8+** (`python --version` to check)
- [ ] **Azure Permissions:**
  - Reader role at tenant root (or all subscriptions)
  - Policy Reader at management groups/subscriptions
  - PIM access approved (8-hour window)
- [ ] **Network Access:** Corporate network or VPN connected

---

## Quick Start (5 Steps)

### Step 1: Authenticate (2 minutes)

```powershell
cd SecAI-Framework/2-Scripts/Collection
.\00_login.ps1
```

**Expected Output:** Browser opens, you sign in, see "You have logged in successfully"

**If SSL Proxy Issues:**
```powershell
$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = "1"
```

---

### Step 2: Discover Scope (5 minutes)

```powershell
.\01_scope_discovery.ps1
```

**Expected Output:**
```
====================================
Scope Discovery Complete!
====================================
Management Groups: 12
Total Subscriptions: 34
Enabled Subscriptions: 34
Output: ../3-Data/Output/scope.json
```

---

### Step 3: Run Collection Scripts (3-4 hours)

**Option A: Run Individually**
```powershell
.\02_inventory.ps1                              # 30-45 min
.\03_policies_and_defender.ps1                  # 15-20 min
.\04_identity_and_privileged_NO_AD_BYPASS_SSL.ps1  # 15-20 min
.\05_network_security.ps1                       # 1-2 hours
.\06_data_protection.ps1                        # 30-45 min
.\07_logging_threat_detection.ps1              # 20-30 min
.\08_backup_recovery.ps1                        # 20-30 min
.\09_posture_vulnerability.ps1                  # 20-30 min
```

**Option B: Run All at Once**
```powershell
# Copy this script
$scripts = @(
    "02_inventory.ps1",
    "03_policies_and_defender.ps1",
    "04_identity_and_privileged_NO_AD_BYPASS_SSL.ps1",
    "05_network_security.ps1",
    "06_data_protection.ps1",
    "07_logging_threat_detection.ps1",
    "08_backup_recovery.ps1",
    "09_posture_vulnerability.ps1"
)

foreach ($script in $scripts) {
    Write-Host "`n========== RUNNING: $script ==========" -ForegroundColor Cyan
    & ".\$script"
}
```

**Progress Indicators:**
- `[5/34] Processing: Subscription Name` - Shows current progress
- Green = Success
- Yellow = Warnings (non-critical)
- Red = Errors (investigate)
- Gray = Skipped/Info

---

### Step 4: Count Evidence (1 minute)

```powershell
cd ..
python Collection/10_evidence_counter.py
```

**Expected Output:**
```
Evidence collection complete!
Total files: 850+
See: 3-Data/Output/evidence_counts.csv
```

---

### Step 5: Review Initial Reports (5 minutes)

```powershell
# Open your reports folder
cd ../5-Reports

# Open the dashboards (use your browser)
# - EXECUTIVE_SUMMARY_REPORT.html
# - SECURITY_TEAM_ACTION_DASHBOARD.html
# - NETWORK_TEAM_FINDINGS.html
# - IDENTITY_TEAM_RBAC_REVIEW.html
```

---

## What You Now Have

After these 5 steps:

✅ **Complete inventory** of all Azure resources  
✅ **800+ JSON files** with configuration data  
✅ **Evidence across 12 security domains**  
✅ **Initial security dashboards**  
✅ **Foundation for full assessment**  

---

## Next Steps

### For Quick Assessment (1-2 days)

1. **Review HTML Dashboards**
   - Identify top risks
   - Note critical findings
   - Share with teams

2. **Populate Excel Workbook**
   - Open `4-Templates/Azure_Framework_2025.xlsx`
   - Import evidence counts
   - Document findings

3. **Create Executive Summary**
   - Top 10 risks
   - Compliance gaps
   - Recommendations

### For Comprehensive Assessment (1-2 weeks)

1. **Run Transformation Scripts** (Day 2)
   ```powershell
   cd 2-Scripts/Transformation
   python 11_transform_security.py
   python 12_transform_inventory.py
   python 13_transform_rbac.py
   python 14_transform_network.py
   python 15_transform_data_protection.py
   python 16_transform_logging.py
   python 17_transform_policies.py
   ```

2. **Run Analysis Scripts** (Day 2)
   ```powershell
   cd ../Analysis
   python 18_analyze_top_risks.py
   python 19_analyze_subscription_comparison.py
   ```

3. **Process Assessment** (Days 3-5)
   - Interview operations teams
   - Review documentation
   - Assess maturity
   - Document findings
   - See: `1-Documentation/PROCESS_ASSESSMENT.md`

4. **Best Practices Assessment** (Days 6-7)
   - Map to CIS, NIST, ISO frameworks
   - Calculate compliance scores
   - Identify gaps
   - Create remediation roadmap
   - See: `1-Documentation/BEST_PRACTICES_ASSESSMENT.md`

5. **Reporting and Presentation** (Days 8-10)
   - Finalize dashboards
   - Complete Excel workbook
   - Create executive presentation
   - Schedule stakeholder meetings

---

## Common Issues & Solutions

### Issue: SSL Certificate Warnings

**Symptom:**
```
WARNING: InsecureRequestWarning: Unverified HTTPS request
```

**Solution:**
```powershell
$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = "1"
```

**Note:** Only for trusted corporate networks

---

### Issue: PIM Access Expired

**Symptom:**
```
ERROR: Insufficient permissions to read subscriptions
```

**Solution:**
1. Request PIM elevation (8-hour window)
2. Re-run `.\00_login.ps1`
3. Continue from where you stopped

---

### Issue: Script Takes Forever

**Symptom:** No output for 10+ minutes

**Solution:** This is normal!
- Scripts show progress: `[X/34] Processing...`
- Network script (05) takes longest (1-2 hours)
- Be patient, check for progress counter

---

### Issue: Management Group Access Denied

**Symptom:**
```
WARNING: 0 subscriptions mapped to management groups
```

**Solution:**
- This is a permission issue (need "Management Group Reader" role)
- Not critical for assessment
- Can continue without MG mapping
- See: `1-Documentation/PERMISSION_REQUEST_TEMPLATE.md`

---

## Time Estimates

| Activity | Time | Can Skip? |
|----------|------|-----------|
| Authentication | 2 min | No |
| Scope discovery | 5 min | No |
| Collection scripts | 3-4 hours | No |
| Evidence counter | 1 min | Yes |
| Transformation | 30 min | Yes (for quick assessment) |
| Analysis | 20 min | Yes (for quick assessment) |
| Process assessment | 2-3 days | Yes (configuration only) |
| Best practices assessment | 2-3 days | Yes (configuration only) |
| **Total (Quick)** | **4-5 hours** | Configuration only |
| **Total (Comprehensive)** | **1-2 weeks** | Full 3-dimensional assessment |

---

## Directory Structure Reference

```
SecAI-Framework/
├── 1-Documentation/          # Read for detailed guidance
│   ├── FRAMEWORK_OVERVIEW.md
│   ├── CONFIGURATION_ASSESSMENT.md
│   ├── PROCESS_ASSESSMENT.md
│   ├── BEST_PRACTICES_ASSESSMENT.md
│   └── [Other docs]
│
├── 2-Scripts/
│   ├── Collection/           # Start here (00-10)
│   ├── Transformation/       # Run after collection (11-17)
│   └── Analysis/             # Run after transformation (18-19)
│
├── 3-Data/
│   ├── Input/                # Customer-specific inputs (if any)
│   └── Output/               # Generated JSON/CSV files
│
├── 4-Templates/
│   └── Azure_Framework_2025.xlsx  # Main assessment workbook
│
└── 5-Reports/                # Generated dashboards and reports
```

---

## Help & Support

### Documentation

- **Overview:** `1-Documentation/FRAMEWORK_OVERVIEW.md`
- **Configuration Guide:** `1-Documentation/CONFIGURATION_ASSESSMENT.md`
- **Process Guide:** `1-Documentation/PROCESS_ASSESSMENT.md`
- **Best Practices Guide:** `1-Documentation/BEST_PRACTICES_ASSESSMENT.md`
- **Detailed Execution:** `1-Documentation/EXECUTION_GUIDE.md`

### Troubleshooting

- **SSL Issues:** `1-Documentation/SSL_PROXY_ISSUE_REPORT.md`
- **Permissions:** `1-Documentation/PERMISSION_REQUEST_TEMPLATE.md`
- **Script Details:** `2-Scripts/Collection/SCRIPT_REVIEW.md`

---

## Success Checklist

After quick start, you should have:

- [x] Authenticated to Azure
- [x] Discovered 34+ subscriptions
- [x] Collected 800+ JSON files
- [x] Generated evidence counts CSV
- [x] Reviewed initial dashboards
- [x] Ready for next phase

---

**You're Ready!** 🚀

For detailed guidance, see `README.md` and `1-Documentation/FRAMEWORK_OVERVIEW.md`

**Questions?** Review documentation in `1-Documentation/` folder

---

**Framework Version:** 2.0  
**Last Updated:** October 17, 2025  
**Status:** Production Ready

