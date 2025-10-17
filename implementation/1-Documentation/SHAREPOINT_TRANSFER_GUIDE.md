# SharePoint Transfer & Merge Guide

**Date:** October 15, 2025  
**Purpose:** Transfer workspace to SharePoint and merge out folder  
**Status:** Ready for transfer

---

## 📋 Pre-Transfer Checklist

### ✅ Verify Data Integrity Before Transfer

```powershell
# Check current workspace location
cd "/Users/derek/Library/CloudStorage/OneDrive-zimaxnet/Customer-Security-Architecture/CustomerEnv-Workspace"
pwd

# Count files in out folder
Get-ChildItem -Path "Azure_Assessment_Kit/out" -Recurse | Measure-Object | Select-Object Count

# Verify key files exist
Test-Path "Azure_Framework_2025.xlsx"
Test-Path "Azure_Assessment_Status_Report_Oct15_2025.html"
Test-Path "Azure_Assessment_Kit/scripts/06_data_protection.ps1"
```

---

## 📦 Step 1: Prepare for Transfer

### Create Transfer Package Checklist

**Critical Files to Transfer:**
- ✅ `Azure_Framework_2025.xlsx` - Target spreadsheet
- ✅ `Azure_Assessment_Status_Report_Oct15_2025.html` - Status report
- ✅ `QUICK_START_TOMORROW.md` - Tomorrow's guide
- ✅ `TODAYS_WORK_SUMMARY.md` - Today's summary
- ✅ `Azure_Assessment_Kit/` - Entire folder including:
  - `scripts/` - All PowerShell scripts
  - `out/` - All collected JSON data (~300+ files)
  - Documentation files (.md)
  - Archive folder

### Optional Files (Can Archive):
- `archive/` - Old project files (already archived)
- `TRANSFER_TO_CITRIX/` - Citrix transfer docs (not needed for assessment)
- Old deployment files (deploy.sh, etc.)

---

## 🔄 Step 2: Copy Workspace to SharePoint

### Option A: Using File Explorer (Recommended for Windows)

1. **Open Source Location:**
   ```
   C:\Users\[YourName]\OneDrive\Customer-Security-Architecture\CustomerEnv-Workspace
   ```

2. **Open SharePoint in File Explorer:**
   - Open File Explorer
   - Navigate to SharePoint site (should appear in Quick Access)
   - Or: Open SharePoint in browser → Click "Sync" to add to File Explorer
   - Navigate to target folder

3. **Copy Entire Workspace:**
   - Select `CustomerEnv-Workspace` folder
   - Right-click → Copy
   - Navigate to SharePoint location
   - Right-click → Paste
   - **Wait for sync to complete** (may take 10-30 minutes depending on size)

4. **Verify Transfer:**
   - Check file count matches
   - Open a few files to verify content
   - Check Azure_Assessment_Kit/out folder has ~300+ JSON files

### Option B: Using PowerShell (More Control)

```powershell
# Define source and destination
$source = "C:\Users\[YourName]\OneDrive\Customer-Security-Architecture\CustomerEnv-Workspace"
$destination = "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\CustomerEnv-Workspace"

# Create destination folder if doesn't exist
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Path $destination -Force
}

# Copy with progress
Copy-Item -Path "$source\*" -Destination $destination -Recurse -Force -Verbose

# Verify copy
Write-Host "Source file count:"
(Get-ChildItem -Path $source -Recurse -File).Count
Write-Host "Destination file count:"
(Get-ChildItem -Path $destination -Recurse -File).Count
```

### Option C: Using Robocopy (Fastest for Large Datasets)

```cmd
robocopy "C:\Users\[YourName]\OneDrive\Customer-Security-Architecture\CustomerEnv-Workspace" ^
         "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\CustomerEnv-Workspace" ^
         /E /MT:8 /R:3 /W:5 /LOG:transfer_log.txt /TEE

REM Flags explained:
REM /E - Copy subdirectories including empty ones
REM /MT:8 - Multi-threaded copy (8 threads)
REM /R:3 - Retry 3 times on failure
REM /W:5 - Wait 5 seconds between retries
REM /LOG - Create log file
REM /TEE - Output to console and log file
```

---

## 🔀 Step 3: Merge Out Folder (If Separate)

### Scenario A: Out Folder is in Different Location

If your `out` folder is currently separate from `Azure_Assessment_Kit`:

```powershell
# Define locations
$outFolderSource = "C:\Path\To\Separate\out"
$assessmentKitDest = "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\CustomerEnv-Workspace\Azure_Assessment_Kit"

# Check if out folder exists in destination
if (Test-Path "$assessmentKitDest\out") {
    Write-Host "Out folder already exists in destination"
    Write-Host "Files will be merged (newer files will overwrite)"
    
    # Merge files
    Copy-Item -Path "$outFolderSource\*" -Destination "$assessmentKitDest\out" -Recurse -Force
} else {
    # Create out folder and copy
    New-Item -ItemType Directory -Path "$assessmentKitDest\out" -Force
    Copy-Item -Path "$outFolderSource\*" -Destination "$assessmentKitDest\out" -Recurse -Force
}

# Verify merge
Write-Host "Total files in out folder:"
(Get-ChildItem -Path "$assessmentKitDest\out" -Recurse -File).Count
```

### Scenario B: Out Folder Already in Azure_Assessment_Kit

If the `out` folder is already inside `Azure_Assessment_Kit`, it will copy automatically with the workspace. **No merge needed!**

Just verify after transfer:

```powershell
# Verify out folder location
$outPath = "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\CustomerEnv-Workspace\Azure_Assessment_Kit\out"

# Check it exists and has files
Test-Path $outPath
Get-ChildItem $outPath | Measure-Object | Select-Object Count
```

---

## ✅ Step 4: Verify Transfer & Merge

### Complete Verification Checklist

```powershell
# Set SharePoint workspace path
$spWorkspace = "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\CustomerEnv-Workspace"

# 1. Check critical files
Write-Host "=== Checking Critical Files ===" -ForegroundColor Cyan
Test-Path "$spWorkspace\Azure_Framework_2025.xlsx"
Test-Path "$spWorkspace\Azure_Assessment_Status_Report_Oct15_2025.html"
Test-Path "$spWorkspace\QUICK_START_TOMORROW.md"

# 2. Check scripts folder
Write-Host "=== Checking Scripts ===" -ForegroundColor Cyan
$scripts = Get-ChildItem "$spWorkspace\Azure_Assessment_Kit\scripts\*.ps1"
Write-Host "PowerShell scripts found: $($scripts.Count)"
# Should show 10 scripts (00-09)

# 3. Check out folder
Write-Host "=== Checking Out Folder ===" -ForegroundColor Cyan
$outFiles = Get-ChildItem "$spWorkspace\Azure_Assessment_Kit\out\*.json" -Recurse
Write-Host "JSON files in out folder: $($outFiles.Count)"
# Should show ~300+ files

# 4. Verify key data files
Write-Host "=== Checking Key Data Files ===" -ForegroundColor Cyan
Test-Path "$spWorkspace\Azure_Assessment_Kit\out\scope.json"
Test-Path "$spWorkspace\Azure_Assessment_Kit\out\subscriptions.json"
Test-Path "$spWorkspace\Azure_Assessment_Kit\out\management_groups.json"

# 5. Check documentation
Write-Host "=== Checking Documentation ===" -ForegroundColor Cyan
$docs = Get-ChildItem "$spWorkspace\Azure_Assessment_Kit\*.md"
Write-Host "Documentation files: $($docs.Count)"

Write-Host ""
Write-Host "=== Transfer Verification Complete ===" -ForegroundColor Green
```

---

## 📊 Expected File Counts

### After Complete Transfer, You Should Have:

**In Azure_Assessment_Kit/out/:**
- ~300+ JSON files (more after tomorrow's scripts)
- Files like:
  - scope.json
  - subscriptions.json
  - management_groups.json
  - *_rgs.json (34 files)
  - *_resources.json (34 files)
  - *_resource_type_counts.json (34 files)
  - *_policy_assignments.json (34 files)
  - *_role_assignments.json (34 files)
  - *_vnets.json, *_nsgs.json, etc. (34 × 6 files)

**In Azure_Assessment_Kit/scripts/:**
- 10 PowerShell scripts (.ps1)
- 1 Python script (.py)
- 3-4 documentation files (.md)

**In Azure_Assessment_Kit/ (main):**
- 8-10 documentation files (.md, .txt)
- 1 archive folder

**In CustomerEnv-Workspace/ (root):**
- Azure_Framework_2025.xlsx
- Status report (HTML)
- Quick guides (.md)
- Other project files

---

## 🔐 Step 5: Secure Original Data

### After Successful Transfer & Verification:

**Option A: Keep OneDrive as Backup**
```powershell
# Rename OneDrive folder to indicate it's backup
Rename-Item -Path "C:\Users\[YourName]\OneDrive\Customer-Security-Architecture\CustomerEnv-Workspace" `
            -NewName "CustomerEnv-Workspace-BACKUP-Oct15"
```

**Option B: Archive OneDrive Version**
```powershell
# Create archive folder
$archivePath = "C:\Users\[YourName]\OneDrive\Customer-Security-Architecture\ARCHIVE"
New-Item -ItemType Directory -Path $archivePath -Force

# Move to archive
Move-Item -Path "C:\Users\[YourName]\OneDrive\Customer-Security-Architecture\CustomerEnv-Workspace" `
          -Destination "$archivePath\CustomerEnv-Workspace-Oct15-2025"
```

**Option C: Keep Both (Recommended)**
- Leave OneDrive version as-is (backup)
- Work from SharePoint going forward
- Keep until project complete

---

## 🚀 Step 6: Update Working Location for Tomorrow

### Update Your Quick Start for Tomorrow

After transfer, update your working path:

**Old Path (OneDrive):**
```powershell
cd "C:\Users\[YourName]\OneDrive\Customer-Security-Architecture\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts"
```

**New Path (SharePoint):**
```powershell
cd "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts"
```

### Create Shortcut for Easy Access

```powershell
# Create desktop shortcut to SharePoint scripts folder
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Azure_Assessment_Scripts.lnk")
$Shortcut.TargetPath = "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts"
$Shortcut.Save()
```

---

## ⚠️ Important Notes

### During Transfer:

1. **Don't Interrupt Sync**
   - Let SharePoint sync complete fully
   - Watch for sync icon in system tray
   - Don't close File Explorer during copy

2. **Check Disk Space**
   - Workspace is ~500MB-1GB (with all data)
   - Ensure SharePoint has sufficient space
   - Check local disk space for sync

3. **Network Considerations**
   - Transfer may take 10-30 minutes depending on network
   - VPN required if working remotely
   - Don't disconnect during transfer

### After Transfer:

1. **Verify Tomorrow's Scripts Work**
   ```powershell
   # Test from SharePoint location
   cd "[SharePoint Path]\Azure_Assessment_Kit\scripts"
   Get-ChildItem *.ps1
   # Should list all 10 scripts
   ```

2. **Update Bookmarks/Favorites**
   - Update any browser bookmarks
   - Update any documentation references
   - Update team shared links

3. **Inform Team of New Location**
   - Update status report if needed
   - Email team with new SharePoint link
   - Update documentation with correct paths

---

## 🆘 Troubleshooting

### Issue: Files Not Syncing to SharePoint

**Solution:**
- Check SharePoint sync status (system tray icon)
- Restart SharePoint sync client
- Verify SharePoint storage not full
- Check file/folder name length (max 400 characters)
- Ensure no special characters in filenames

### Issue: Out Folder Missing Files After Merge

**Solution:**
```powershell
# Compare file counts
$source = "C:\OriginalPath\out"
$dest = "C:\SharePointPath\out"

$sourceCount = (Get-ChildItem $source -Recurse -File).Count
$destCount = (Get-ChildItem $dest -Recurse -File).Count

Write-Host "Source: $sourceCount files"
Write-Host "Destination: $destCount files"

if ($sourceCount -ne $destCount) {
    Write-Host "File count mismatch! Re-run copy with -Force flag"
}
```

### Issue: Cannot Access SharePoint Location

**Solution:**
- Open SharePoint site in browser
- Click "Sync" button to add to File Explorer
- Wait for initial sync to complete
- Then retry copy operation

---

## 📝 Quick Copy Commands

### All-in-One Copy & Verify Script

```powershell
# === CONFIGURATION ===
$sourceBase = "C:\Users\[YourName]\OneDrive\Customer-Security-Architecture"
$destBase = "C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]"

# === COPY ===
Write-Host "Starting transfer..." -ForegroundColor Yellow
Copy-Item -Path "$sourceBase\CustomerEnv-Workspace" `
          -Destination "$destBase\CustomerEnv-Workspace" `
          -Recurse -Force -Verbose

# === VERIFY ===
Write-Host "`nVerifying transfer..." -ForegroundColor Yellow
$sourceCount = (Get-ChildItem "$sourceBase\CustomerEnv-Workspace" -Recurse -File).Count
$destCount = (Get-ChildItem "$destBase\CustomerEnv-Workspace" -Recurse -File).Count

Write-Host "`nSource files: $sourceCount" -ForegroundColor Cyan
Write-Host "Destination files: $destCount" -ForegroundColor Cyan

if ($sourceCount -eq $destCount) {
    Write-Host "`n✓ Transfer SUCCESSFUL!" -ForegroundColor Green
} else {
    Write-Host "`n⚠ File count mismatch - verify manually" -ForegroundColor Yellow
}

# === CHECK KEY FILES ===
Write-Host "`nChecking critical files..." -ForegroundColor Yellow
$criticalFiles = @(
    "Azure_Framework_2025.xlsx",
    "Azure_Assessment_Status_Report_Oct15_2025.html",
    "Azure_Assessment_Kit\out\scope.json",
    "Azure_Assessment_Kit\scripts\06_data_protection.ps1"
)

foreach ($file in $criticalFiles) {
    $exists = Test-Path "$destBase\CustomerEnv-Workspace\$file"
    if ($exists) {
        Write-Host "  ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file MISSING!" -ForegroundColor Red
    }
}

Write-Host "`nTransfer complete!" -ForegroundColor Cyan
```

---

## ✅ Final Checklist

Before you finish, verify:

```
☐ Entire CustomerEnv-Workspace copied to SharePoint
☐ Azure_Assessment_Kit folder present with all subfolders
☐ Out folder contains ~300+ JSON files
☐ Scripts folder contains 10 .ps1 files
☐ Azure_Framework_2025.xlsx present
☐ Status report HTML file present
☐ Quick start guide present
☐ File counts match between source and destination
☐ Tested opening a few files from SharePoint location
☐ Updated tomorrow's working path
☐ Created shortcut for easy access (optional)
☐ Original OneDrive version secured/backed up
☐ Team informed of new SharePoint location
```

---

## 🎯 Ready for Tomorrow

**New Working Location:**
```
[SharePoint Path]\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts
```

**First Command Tomorrow:**
```powershell
cd "[SharePoint Path]\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts"
.\00_login.ps1
```

---

**Transfer Complete!** 🎉

Your workspace is now safely on SharePoint and ready for tomorrow's continuation.

