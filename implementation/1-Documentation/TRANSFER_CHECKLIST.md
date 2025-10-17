# SharePoint Transfer - Quick Checklist

**Before you leave today:** Transfer workspace to SharePoint

---

## ✅ Quick Steps

### 1. Open Both Locations

**Source (OneDrive/Mac):**
```
/Users/derek/Library/CloudStorage/OneDrive-zimaxnet/Customer-Security-Architecture/CustomerEnv-Workspace
```

**Destination (Windows SharePoint):**
```
C:\Users\[YourName]\[CompanyName]\SharePoint\[SiteName]\
```

---

### 2. Copy Entire Folder

**Use File Explorer (Windows):**
1. Open source location
2. Right-click `CustomerEnv-Workspace` folder
3. Copy
4. Navigate to SharePoint location
5. Paste
6. **Wait for sync to complete** (10-30 minutes)

**OR use PowerShell:**
```powershell
# Simple copy command
Copy-Item -Path "[SOURCE]\CustomerEnv-Workspace" `
          -Destination "[SHAREPOINT]\CustomerEnv-Workspace" `
          -Recurse -Force
```

---

### 3. Verify Transfer

```powershell
cd "[SharePoint Path]\CustomerEnv-Workspace\Azure_Assessment_Kit"

# Check critical items
Test-Path "out\scope.json"              # Should be True
Test-Path "scripts\06_data_protection.ps1"  # Should be True
Test-Path "..\Azure_Framework_2025.xlsx"    # Should be True

# Count files
(Get-ChildItem out\*.json).Count        # Should be ~300+
(Get-ChildItem scripts\*.ps1).Count     # Should be 10
```

---

### 4. Merge Out Folder (If Separate)

**If your out folder is in a different location:**

```powershell
# Copy out folder contents to SharePoint location
Copy-Item -Path "[OldOutLocation]\*" `
          -Destination "[SharePoint]\CustomerEnv-Workspace\Azure_Assessment_Kit\out" `
          -Recurse -Force
```

**If out folder is already inside Azure_Assessment_Kit:**
- ✅ Already copied! No merge needed.

---

### 5. Update Tomorrow's Path

**Tomorrow morning, use SharePoint path:**

```powershell
cd "C:\Users\[YourName]\[SharePoint]\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts"
.\00_login.ps1
```

---

## 📊 What Should Be Transferred

```
CustomerEnv-Workspace/
├── Azure_Framework_2025.xlsx                    ← Excel file
├── Azure_Assessment_Status_Report_Oct15_2025.html  ← Report
├── QUICK_START_TOMORROW.md                     ← Tomorrow's guide
├── Azure_Assessment_Kit/
│   ├── out/                                     ← ~300+ JSON files
│   ├── scripts/                                 ← 10 .ps1 files
│   └── *.md                                     ← Documentation
└── Other project files
```

---

## ⚠️ Important

- [ ] **Don't interrupt transfer** - Let it complete fully
- [ ] **Verify file counts match** after transfer
- [ ] **Test opening a file** from SharePoint location
- [ ] **Update path** in tomorrow's commands
- [ ] **Keep OneDrive version** as backup until project done

---

## 🆘 If Transfer Fails

**See detailed guide:** `SHAREPOINT_TRANSFER_GUIDE.md`

**Quick troubleshooting:**
- Make sure SharePoint is synced
- Check disk space
- Restart SharePoint sync client
- Try smaller batches if needed

---

## ✅ Done!

Once verified, you're ready to go home.

**Tomorrow:** Start from SharePoint location, everything will work the same!

---

**Total Time:** 15-30 minutes (mostly waiting for sync)

