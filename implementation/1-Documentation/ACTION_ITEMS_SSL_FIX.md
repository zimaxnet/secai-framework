# SSL Proxy Certificate - Action Items

## Immediate Actions (Today)

### ✅ 1. Complete Current Assessment Using Workaround
```powershell
cd C:\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts
.\04_identity_and_privileged_NO_AD.ps1
```
**Status:** Ready to execute  
**Time:** ~10 minutes  
**Result:** RBAC data collected, Azure AD queries skipped

### ✅ 2. Continue with Remaining Scripts
Scripts 05-09 are NOT affected by SSL issues. Continue normally:
```powershell
.\05_network_security.ps1
.\06_data_protection.ps1
.\07_logging_threat_detection.ps1
.\08_backup_recovery.ps1
.\09_posture_vulnerability.ps1
```

### ✅ 3. Note Limitation in Assessment Report
**Add to Report:**
> "Azure AD application and service principal data could not be collected 
> due to corporate SSL proxy configuration. RBAC role assignments were 
> successfully collected. Assessment completeness: ~95%."

---

## Short-term Actions (Next 2 Weeks)

### 📧 1. Submit IT Request for Certificate

**Email Template:**

```
To: IT Security / Network Team
Subject: Request for Corporate SSL Proxy Certificate - Azure CLI Configuration

Hello,

We are conducting Azure security assessments using Azure CLI and need to 
configure certificate trust for the corporate SSL-inspecting proxy.

REQUEST:
- Corporate SSL proxy root certificate (PEM or CER format)
- Any intermediate certificates used for HTTPS inspection
- Installation instructions if available

PURPOSE:
- Azure CLI authentication to Microsoft Graph API (graph.microsoft.com)
- Automated Azure Active Directory data collection for security assessments

BUSINESS JUSTIFICATION:
- Required for compliance and security assessments
- Enables automated, repeatable quarterly assessments
- Reduces manual effort by 4-6 hours per assessment
- Supports SOC 2, ISO 27001, and NIST compliance requirements

TECHNICAL DETAILS:
- Current error: "Certificate verify failed: Missing Authority Key Identifier"
- Affected endpoint: graph.microsoft.com (Microsoft Graph API)
- Unaffected: management.azure.com (Azure Resource Manager)

Please provide the certificate files and any guidance for Azure CLI configuration.

Thank you,
[Your Name]
[Your Title]
```

**Expected Response Time:** 1-5 business days

---

### 🔧 2. Test Certificate Configuration (After Received)

**Step 1: Install Certificate**
```powershell
# Import to Windows Trusted Root CA store (run as Administrator)
certutil -addstore "Root" "C:\path\to\corporate-root-ca.cer"
```

**Step 2: Restart PowerShell Session**
```powershell
# Close and reopen PowerShell to pick up new certificate
```

**Step 3: Test Connection**
```powershell
# Test Graph API access
az rest --method GET --url "https://graph.microsoft.com/v1.0/applications?`$top=1"
```

**Step 4: Validate**
```powershell
cd C:\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts

# Run diagnostics
.\00_diagnostics.ps1

# If successful, run full identity script
.\04_identity_and_privileged.ps1
```

---

### 📊 3. Supplement Current Assessment (Optional)

If Azure AD data is critical for this assessment, collect manually:

**Option A: Azure Portal Export**
1. Navigate to: Azure AD → App registrations
2. Click: Download → CSV
3. Navigate to: Azure AD → Enterprise applications  
4. Click: Download → CSV
5. Save files to: `Azure_Assessment_Kit\out\manual\`

**Option B: PowerShell Graph SDK (Alternative)**
```powershell
# Install Microsoft Graph PowerShell SDK
Install-Module Microsoft.Graph -Scope CurrentUser

# Connect (uses browser auth, bypasses proxy issues)
Connect-MgGraph -Scopes "Application.Read.All","ServicePrincipal.Read.All"

# Export applications
Get-MgApplication -All | ConvertTo-Json -Depth 10 | Out-File "tenant_applications.json"

# Export service principals
Get-MgServicePrincipal -All | ConvertTo-Json -Depth 10 | Out-File "tenant_service_principals.json"
```

---

## Long-term Actions (Next Quarter)

### 📚 1. Document Process
Create internal wiki/documentation:
- SSL proxy certificate configuration for Azure CLI
- Troubleshooting guide for certificate issues
- Onboarding checklist for new team members

### 🔄 2. Establish Regular Assessment Schedule
- **Quarterly:** Full security assessment (scripts 00-09)
- **Monthly:** Compliance spot-checks (scripts 03, 09)
- **As-needed:** Incident investigation (targeted scripts)

### 🤝 3. IT Partnership
- Establish point of contact for certificate updates
- Get notified when proxy certificates change
- Include in certificate renewal process

---

## ROI Summary

### One-Time Investment
- **IT Request & Response:** 1-2 hours
- **Certificate Installation:** 30 minutes  
- **Testing & Validation:** 15 minutes
- **Documentation:** 1 hour
- **TOTAL:** ~3 hours

### Recurring Benefit (Per Assessment)
- **Automated AD data collection:** 2-3 hours saved
- **No manual correlation:** 1-2 hours saved
- **Reduced errors:** Better data quality
- **TOTAL:** 4-6 hours saved per assessment

### Annual Benefit (4 Quarterly Assessments)
- **Time Saved:** 16-24 hours per year
- **Break-even:** After first assessment
- **Net Benefit:** 13-21 hours saved in Year 1

---

## Escalation Path

If IT request is denied or delayed:

### Escalation Level 1: Manager Approval
**Escalate to:** Your direct manager  
**Talking Points:**
- Required for compliance assessments
- Industry standard practice
- Read-only data collection only
- Reduces operational costs

### Escalation Level 2: Business Justification
**Escalate to:** IT Security Manager  
**Provide:**
- This document
- SSL_PROXY_ISSUE_REPORT.md
- Compliance framework requirements (SOC 2, ISO 27001)
- Cost-benefit analysis

### Escalation Level 3: Alternative Solutions
**Options if certificate not approved:**
1. Use temporary SSL bypass for trusted network only
2. Manual Azure Portal exports (higher cost)
3. Request exception for assessment workstation
4. Use Azure Cloud Shell (no proxy, but different limitations)

---

## Success Criteria

### Short-term (This Assessment - Week 1)
- ✅ RBAC data collected for 34 subscriptions
- ✅ Scripts 05-09 completed successfully
- ✅ Assessment report delivered with noted limitation
- ✅ IT certificate request submitted

### Medium-term (Certificate Config - Week 2-3)
- ✅ Corporate certificate received from IT
- ✅ Certificate installed and validated
- ✅ Azure AD data collection successful
- ✅ Process documented for team

### Long-term (Future Assessments - Ongoing)
- ✅ 100% automated data collection
- ✅ Zero manual exports required
- ✅ Quarterly assessments < 2 hours runtime
- ✅ Repeatable, documented process

---

## Key Contacts

**Internal:**
- **Assessment Lead:** [Your Name]
- **Manager:** [Manager Name]
- **Compliance Team:** [Contact]

**IT Department:**
- **IT Security:** [To be identified]
- **Network Team:** [To be identified]
- **Certificate Authority Admin:** [To be identified]

---

## Timeline

| Week | Actions | Owner | Status |
|------|---------|-------|--------|
| Week 1 | Run workaround script, complete assessment | Assessment Team | ⏭️ In Progress |
| Week 1 | Submit IT certificate request | Assessment Team | 📋 Pending |
| Week 2-3 | Receive certificate from IT | IT Security | ⏸️ Waiting |
| Week 3 | Install & test certificate | Assessment Team | ⏸️ Waiting |
| Week 4 | Re-run script, collect AD data | Assessment Team | ⏸️ Waiting |
| Week 4 | Supplement current report | Assessment Team | ⏸️ Waiting |
| Ongoing | Document process for team | Assessment Team | ⏸️ Waiting |

---

## Quick Reference Commands

**Run Workaround (Today):**
```powershell
cd C:\CustomerEnv-Workspace\Azure_Assessment_Kit\scripts
.\04_identity_and_privileged_NO_AD.ps1
```

**Test After Certificate Install:**
```powershell
az rest --method GET --url "https://graph.microsoft.com/v1.0/applications?`$top=1"
```

**Run Full Script (After Fix):**
```powershell
.\04_identity_and_privileged.ps1
```

**Emergency Bypass (Trusted Network Only):**
```powershell
$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = "1"
.\04_identity_and_privileged.ps1
```

---

## Related Documents

- **`SSL_PROXY_ISSUE_REPORT.md`** - Full technical report and analysis
- **`EXECUTION_GUIDE.md`** - Assessment execution instructions
- **`PERMISSION_REQUEST_TEMPLATE.md`** - Permission request templates
- **`POWERSHELL_README.md`** - PowerShell scripts documentation

---

**Last Updated:** October 15, 2025  
**Next Review:** After certificate configuration completion

