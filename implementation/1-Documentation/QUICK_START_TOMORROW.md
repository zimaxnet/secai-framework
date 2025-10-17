# Quick Start Guide - October 16, 2025

**Status:** Resume Assessment - 4 Scripts Remaining  
**Estimated Time:** 3-4 hours  
**PIM Required:** Yes (8-hour window)

---

## ⏰ Before You Start

### 1. Request PIM Access FIRST
- Log into Azure Portal
- Request Privileged Identity Management (PIM) access
- **Duration:** 8 hours (max allowed)
- **Wait for approval** before proceeding
- ⏱️ This gives you 8 hours; you'll need ~3-4 hours

---

## 🚀 Quick Start Commands

### ⚠️ IMPORTANT: Update Path if Transferred to SharePoint

**If you transferred to SharePoint**, use that path instead of OneDrive path.

### Open PowerShell and Run These Commands:

```powershell
# Step 1: Navigate to workspace
# UPDATE THIS PATH based on where you transferred the workspace
cd "C:\Users\[YourUsername]\[SharePointPath]\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts"

# Or if still on OneDrive:
# cd "C:\Users\[YourUsername]\OneDrive\Customer-Security-Architecture\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts"

# Step 2: Login to Azure (required - session expired overnight)
.\00_login.ps1

# Step 3: Enable SSL bypass (required for corporate proxy)
$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = "1"

# Step 4: Run remaining scripts (copy all and paste)
.\06_data_protection.ps1
.\07_logging_threat_detection.ps1
.\08_backup_recovery.ps1
.\09_posture_vulnerability.ps1

# Step 5: Clean up SSL bypass
Remove-Item Env:\AZURE_CLI_DISABLE_CONNECTION_VERIFICATION

# Step 6: Run evidence counter
python 10_evidence_counter.py

# Done!
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ASSESSMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Check the out/ folder for all collected data"
Write-Host "Review evidence_counts.csv for summary"
```

---

## ⏱️ Expected Timeline

| Script | Time | Status |
|--------|------|--------|
| 06_data_protection.ps1 | 1-2 hours | ⏳ |
| 07_logging_threat_detection.ps1 | 30-45 min | ⏳ |
| 08_backup_recovery.ps1 | 30-45 min | ⏳ |
| 09_posture_vulnerability.ps1 | 30-45 min | ⏳ |
| 10_evidence_counter.py | < 1 min | ⏳ |
| **TOTAL** | **~3-4 hours** | |

---

## ✅ What's Already Done

- ✅ 34 subscriptions scoped
- ✅ 5,088 resources inventoried
- ✅ 436 policies collected
- ✅ 6,269 RBAC assignments
- ✅ Network security configs
- ✅ ~300+ JSON files saved

---

## 📍 Where Everything Is

**Scripts to Run:** `Azure_Assessment_Kit/scripts/`  
**Collected Data:** `Azure_Assessment_Kit/out/`  
**Status Report:** `Azure_Assessment_Status_Report_Oct15_2025.html`  
**Excel Framework:** `Azure_Framework_2025.xlsx`

---

## 🔍 During Execution - What You'll See

Each script shows:
- `[X/34] Processing: Subscription Name`
- Color-coded status (Green/Yellow/Red)
- Real-time counts
- Summary at the end

**This is normal:**
- Lots of SSL warnings (they're filtered out automatically)
- Some scripts take longer (be patient)
- Progress counter shows you're not stuck

---

## ⚠️ If Something Goes Wrong

### PIM Expires During Script
- Script will fail with permissions error
- Data already collected is saved
- Re-request PIM access
- Re-run the failed script
- Continue with remaining scripts

### Script Fails
- Check error message
- Most errors are non-critical (yellow warnings)
- Script continues with next subscription
- Red errors are noted in summary

### SSL Errors Again
- Make sure you ran: `$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = "1"`
- Check if it's set: `$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION`
- Should show: `1`

---

## 📊 After Completion

### Verify Success
```powershell
# Count JSON files (should be ~850+)
(Get-ChildItem ..\out\*.json).Count

# Check evidence summary
Get-Content ..\out\evidence_counts.csv | Select-Object -First 10

# Verify last script outputs
Get-ChildItem ..\out\*_secure_score.json | Measure-Object
```

### Expected Results
- ✅ ~850+ JSON files in `out/` folder
- ✅ `evidence_counts.csv` created
- ✅ All 9 scripts show "SUCCESS" in their summaries
- ✅ 34 files per data type (one per subscription)

---

## 📝 Next Steps (After Scripts Complete)

1. **Review Data Quality**
   - Open a few JSON files
   - Check for valid data
   - Note any gaps

2. **Share Status Report**
   - `Azure_Assessment_Status_Report_Oct15_2025.html`
   - Email to teams

3. **Plan Data Transformation**
   - JSON → CSV for Excel
   - Python scripts (see status report)
   - Map to Azure_Framework_2025.xlsx

4. **Document Findings**
   - Create findings list
   - Note any anomalies
   - Prepare recommendations

---

## 🎯 Success Checklist

```
□ PIM access requested and approved
□ Logged into Azure (00_login.ps1)
□ SSL bypass enabled
□ Script 06 complete
□ Script 07 complete
□ Script 08 complete
□ Script 09 complete
□ Evidence counter run
□ ~850+ JSON files in out/
□ evidence_counts.csv generated
□ Data quality spot-checked
```

---

## 📞 Need Help?

**Review These Files:**
- `EXECUTION_GUIDE.md` - Detailed instructions
- `SSL_PROXY_ISSUE_REPORT.md` - SSL troubleshooting
- `Azure_Assessment_Status_Report_Oct15_2025.html` - Full status

**Offshore Team Review:** Complete (check email)

---

## 🚦 GO / NO-GO Checklist

Before starting, verify:

✅ PIM Access: APPROVED  
✅ PowerShell: OPEN  
✅ OneDrive: SYNCED  
✅ Network: CONNECTED  
✅ Time Available: 4+ hours  

**All Green?** → **START!**

---

**Good luck! You've got this! 🎉**

The workspace is organized, scripts are ready, and you're 56% done already!

