# SecAI Framework: Secure Enterprise Execution Guide

**Version:** 1.0  
**Date:** October 18, 2025  
**Purpose:** Complete operational procedures for executing SecAI assessments in secure customer environments

---

## 🔐 CRITICAL SECURITY PRINCIPLE

**⚠️ NEVER commit customer data to the public GitHub repository!**

The SecAI Framework repository contains:
- ✅ **Scripts and tools** (public, shareable)
- ✅ **Documentation** (public, shareable)
- ✅ **Validation modules** (public, shareable)

Customer data stays:
- ❌ **Local only** (never committed)
- ❌ **Customer's environment** (never leaves their tenant)
- ❌ **Encrypted at rest** (on your assessment workstation)

---

## 📋 Complete Assessment Workflow

### Phase 0: Pre-Assessment Setup

**In Secure Customer Environment:**

```bash
# 1. On your assessment workstation (customer network or VPN)
cd /secure/customer-assessments/
mkdir customer-name-$(date +%Y%m%d)
cd customer-name-$(date +%Y%m%d)

# 2. Clone the PUBLIC SecAI Framework
git clone https://github.com/zimaxnet/secai-framework.git
cd secai-framework

# 3. IMMEDIATELY create a local data directory (NOT tracked by git)
mkdir -p local-customer-data/
echo "local-customer-data/" >> .git/info/exclude  # Local ignore, not .gitignore

# 4. Verify customer data won't be committed
git status  # Should NOT show local-customer-data/
```

**Directory Structure After Setup:**
```
/secure/customer-assessments/customer-name-20251018/
└── secai-framework/                    (public repo - safe to pull updates)
    ├── implementation/                 (public scripts)
    ├── workspace/                      (public validation modules)
    ├── docs/                          (public documentation)
    └── local-customer-data/           (EXCLUDED from git - customer data)
        ├── collected/                 (raw JSON from D1)
        ├── transformed/               (CSV from transformation)
        ├── validation-results/        (D3 compliance reports)
        └── interviews/                (D2 interview notes)
```

---

## 🎯 Phase 1: Dimension 1 - Data Collection (COMPLETED)

**Status:** ✅ You've already done this!

**What you collected:**
```
local-customer-data/collected/
├── {sub-id}_az_network_vnets.json
├── {sub-id}_az_network_nsgs.json
├── {sub-id}_az_firewalls.json
├── {sub-id}_load_balancers.json
├── {sub-id}_az_rbac_assignments.json
├── {sub-id}_az_keyvaults.json
├── {sub-id}_diagnostic_settings.json
├── {sub-id}_backup_vaults.json
└── [800+ additional JSON files]
```

**Next:** Transform this data for analysis

---

## 🔄 Phase 1.5: Data Transformation

**Purpose:** Convert JSON to CSV for easier analysis and validation

**Execute:**
```bash
cd secai-framework
cd implementation/2-Scripts/Transformation

# Point scripts to your local customer data
# Edit each script to update paths:
# INPUT_DIR = "../../../local-customer-data/collected/"
# OUTPUT_DIR = "../../../local-customer-data/transformed/"

# Run transformation scripts
python 11_transform_security.py
python 12_transform_inventory.py
python 13_transform_rbac.py
python 14_transform_network.py
python 15_transform_data_protection.py
python 16_transform_logging.py
python 17_transform_policies.py

# Verify CSV files created
ls -lh ../../../local-customer-data/transformed/
```

**Output:**
```
local-customer-data/transformed/
├── network_security_summary.csv
├── rbac_assignments.csv
├── keyvault_summary.csv
├── diagnostic_settings_summary.csv
├── backup_summary.csv
└── [additional CSV files]
```

---

## ✅ Phase 2: Dimension 3 - Best Practices Assessment

**Purpose:** Validate collected data against 5 compliance frameworks

### Step 1: Prepare Validation Environment

```bash
cd secai-framework/workspace/3-Best-Practices-Work

# Review available validation modules
ls -1 *.psm1
# Framework-MCSB.psm1      (Microsoft Cloud Security Benchmark)
# Framework-CISv8.psm1     (CIS Controls v8)
# Framework-NIST.psm1      (NIST SP 800-53)
# Framework-PCIDSS.psm1    (PCI-DSS v3.2.1)
# Framework-CCM.psm1       (CSA Cloud Controls Matrix)
# Common-Functions.psm1    (Shared functions)

# Review master orchestrator
cat Validate-All-Frameworks.ps1
```

### Step 2: Configure Validation Script

**Edit `Validate-All-Frameworks.ps1`:**

```powershell
# Update these paths to point to YOUR local customer data
param(
    [string]$DataPath = "../../../local-customer-data/collected",
    [string]$ReportPath = "../../../local-customer-data/validation-results"
)
```

### Step 3: Execute Multi-Framework Validation

```powershell
# Run validation against all frameworks
pwsh ./Validate-All-Frameworks.ps1 `
    -DataPath "../../../local-customer-data/collected" `
    -ReportPath "../../../local-customer-data/validation-results"

# This will:
# 1. Load collected JSON files
# 2. Run 40+ compliance checks across 5 frameworks
# 3. Generate compliance scores
# 4. Create gap reports
# 5. Export to CSV
```

### Step 4: Review Validation Results

**Generated Reports:**
```
local-customer-data/validation-results/
├── Multi_Framework_Validation_Detailed_20251018.csv     (All controls)
├── Multi_Framework_Validation_Summary_20251018.csv      (Scores by framework)
├── Multi_Framework_Validation_Failed_20251018.csv       (Gap analysis)
└── Multi_Framework_Validation_Executive_20251018.txt    (Executive summary)
```

**Review Executive Summary:**
```powershell
cat ../../../local-customer-data/validation-results/Multi_Framework_Validation_Executive_*
```

**Expected Output:**
```
=== MULTI-FRAMEWORK COMPLIANCE VALIDATION SUMMARY ===
Date: 2025-10-18
Subscriptions Assessed: 34

FRAMEWORK SCORES:
- MCSB (Microsoft Cloud Security Benchmark): 78% (7/9 controls passed)
- CIS Controls v8: 83% (5/6 controls passed)
- NIST SP 800-53: 70% (7/10 controls passed)
- PCI-DSS v3.2.1: 75% (3/4 controls passed)
- CSA CCM: 67% (4/6 controls passed)

OVERALL COMPLIANCE: 75% (26/35 controls passed)

TOP GAPS IDENTIFIED:
1. Network segmentation (3 frameworks flagged)
2. Encryption at rest (2 frameworks flagged)
3. Logging retention (2 frameworks flagged)

CRITICAL FINDINGS:
- 5 subscriptions missing diagnostic settings
- 12 NSGs with overly permissive rules
- 3 Key Vaults without soft delete enabled
```

### Step 5: Analyze Gap Details

```powershell
# Review failed controls in detail
Import-Csv ../../../local-customer-data/validation-results/Multi_Framework_Validation_Failed_*.csv | 
    Format-Table Framework, ControlID, ControlName, Reason

# Export gaps by subscription
Import-Csv ../../../local-customer-data/validation-results/Multi_Framework_Validation_Failed_*.csv | 
    Group-Object SubscriptionID | 
    ForEach-Object {
        $_ | Select-Object Name, Count | 
        Export-Csv "../../../local-customer-data/validation-results/gaps_by_subscription.csv" -Append
    }
```

---

## 🎤 Phase 3: Dimension 2 - Process Assessment

**Purpose:** Use D3 findings to focus interviews on critical operational gaps

### Step 1: Review D3 Findings to Identify Focus Areas

**Analyze validation results to determine interview priorities:**

```powershell
# Identify top operational concerns from D3 gaps
$failedControls = Import-Csv ../../../local-customer-data/validation-results/Multi_Framework_Validation_Failed_*.csv

# Group by control family
$controlFamilies = $failedControls | Group-Object {
    if ($_.ControlID -like "MCSB-NS*") { "Network Security" }
    elseif ($_.ControlID -like "*LOG*") { "Logging & Monitoring" }
    elseif ($_.ControlID -like "*IAM*" -or $_.ControlID -like "*AC*") { "Access Control" }
    elseif ($_.ControlID -like "*EKM*" -or $_.ControlID -like "*DP*") { "Data Protection" }
    elseif ($_.ControlID -like "*BCR*" -or $_.ControlID -like "*CP*") { "Backup & Recovery" }
    else { "Other" }
} | Sort-Object Count -Descending

$controlFamilies | Format-Table Name, Count
```

**Example Output:**
```
Name                 Count
----                 -----
Network Security     12
Logging & Monitoring 8
Access Control       6
Data Protection      5
Backup & Recovery    3
```

**Translation to Dimension 2 Focus:**
- Network Security gaps → Interview Network Operations team
- Logging gaps → Interview Security Monitoring team
- Access Control gaps → Interview IAM/Access Provisioning team

### Step 2: Select Interview Templates

**Based on D3 findings, select appropriate templates:**

```bash
cd secai-framework/workspace/2-Process-Assessment-Work

# Available templates:
ls -1 INTERVIEW_TEMPLATE_*.md
# INTERVIEW_TEMPLATE_Change_Management.md
# [Create additional templates for other domains]

# Copy templates to local customer data
cp INTERVIEW_TEMPLATE_*.md ../../../local-customer-data/interviews/
```

### Step 3: Customize Interview Questions Based on D3 Gaps

**Example: Network Security Issues Found in D3**

If D3 validation found:
- 12 NSGs with overly permissive rules (0.0.0.0/0 allowed)
- 5 subscriptions without Azure Firewall
- 3 VNets without Network Watcher enabled

**Customize interview questions:**

```markdown
## Network Security Management Interview

### Section: Firewall Rule Management

**D3 Finding:** 12 NSGs contain rules allowing 0.0.0.0/0 (any source)

**Interview Questions:**
1. What is your process for approving firewall rule changes?
   - [ ] Change request required?
   - [ ] Security review required?
   - [ ] Approval authority defined?

2. How are overly permissive rules (0.0.0.0/0) detected and remediated?
   - Current process: ___________
   - Frequency: ___________
   - Responsible team: ___________

3. Is there a policy against allowing traffic from any source (0.0.0.0/0)?
   - [ ] Yes - documented policy exists
   - [ ] No - no formal policy
   - If yes, why are 12 NSGs non-compliant?

### Section: Network Architecture

**D3 Finding:** 5 subscriptions without Azure Firewall deployed

4. What is the approved network architecture pattern?
   - [ ] Hub-spoke with centralized firewall
   - [ ] Distributed firewalls per subscription
   - [ ] NVA (third-party firewall)
   - [ ] Other: ___________

5. For subscriptions without Azure Firewall, what compensating controls exist?
   - NSGs only?
   - Third-party firewall?
   - Accepted risk?
```

### Step 4: Conduct Interviews

**Schedule interviews with key personnel:**

```
Interview Schedule:

Week 1:
- Monday: Network Operations Manager (Network Security focus)
- Tuesday: Security Monitoring Lead (Logging & Monitoring focus)
- Wednesday: IAM Team Lead (Access Control focus)

Week 2:
- Monday: Change Management Process Owner
- Tuesday: Backup & DR Team Lead
- Wednesday: Cloud Governance Team

Week 3:
- Monday: DevOps Team Lead (CI/CD security)
- Tuesday: Compliance Officer
- Wednesday: CISO / Security Leadership (Strategic overview)
```

**During each interview:**
```markdown
# Interview Notes Template

**Date:** [Date]
**Interviewee:** [Name, Title]
**Interviewer:** [Your Name]
**Domain:** [e.g., Network Security]
**Duration:** [e.g., 90 minutes]

## D3 Gaps Discussed:
1. [List specific D3 findings]
2. [...]

## Process Maturity Assessment:

### Change Management (Example)
**Maturity Level:** [1-5]
- 1: Initial (ad-hoc, reactive)
- 2: Managed (some processes defined)
- 3: Defined (documented, standardized)
- 4: Quantitatively Managed (measured, metrics-driven)
- 5: Optimizing (continuous improvement)

**Evidence:**
- [What they said]
- [Documentation reviewed]

**Gaps Identified:**
- [Gap 1]
- [Gap 2]

**Recommendations:**
- [Recommendation 1]
- [Recommendation 2]

## Action Items:
- [ ] [Action 1 - Owner - Due Date]
- [ ] [Action 2 - Owner - Due Date]
```

### Step 5: Score Process Maturity

**After all interviews, create maturity scorecard:**

```
local-customer-data/interviews/Process_Maturity_Scorecard.csv

Domain,Maturity Level,Score,Evidence,Gaps,Priority
Network Security,2,Managed,Some NSG approval process exists,No policy enforcement for 0.0.0.0/0 rules,High
Logging & Monitoring,3,Defined,Log Analytics deployed but retention varies,Inconsistent diagnostic settings,High
Access Control,3,Defined,RBAC used but no regular reviews,No PIM usage for privileged access,Medium
Change Management,2,Managed,Informal change approvals,No documented process or tooling,Medium
Backup & Recovery,4,Quantitatively Managed,Backup policies defined and measured,3 subscriptions missing backups,High
Data Protection,2,Managed,Some encryption used,No consistent Key Vault usage,High
Incident Response,2,Managed,Security alerts exist but no playbooks,No defined escalation,Medium
Compliance Management,2,Managed,Aware of requirements but no tracking,No compliance dashboard,Medium
```

---

## 📊 Phase 4: Reporting & Remediation

### Step 1: Consolidate Findings

**Create master findings document:**

```bash
cd ../../../local-customer-data

# Create consolidated report directory
mkdir -p final-report

# Gather all evidence
cp validation-results/Multi_Framework_Validation_Executive_*.txt final-report/
cp validation-results/Multi_Framework_Validation_Summary_*.csv final-report/
cp interviews/Process_Maturity_Scorecard.csv final-report/
```

### Step 2: Generate Executive Summary

**Template: `local-customer-data/final-report/Executive_Summary.md`**

```markdown
# Azure Security Assessment - Executive Summary

**Customer:** [Customer Name]
**Assessment Date:** October 2025
**Assessed By:** [Your Name]
**Framework Version:** SecAI Framework 2.0

---

## Assessment Scope

- **Subscriptions Assessed:** 34
- **Resources Inventoried:** 5,000+
- **Evidence Files Collected:** 800+
- **Frameworks Validated:** 5 (MCSB, CIS, NIST, PCI-DSS, CCM)
- **Interviews Conducted:** 9 (8 domains + CISO)

---

## Overall Security Posture: 75% Compliant

### Dimension 1: Configuration Assessment ✅
**Status:** Complete
- 800+ evidence files collected
- 12 security domains assessed
- Full Azure estate inventory completed

### Dimension 2: Process Assessment ⚠️
**Status:** Moderate maturity (Average: Level 2.5 of 5)
- 5 domains at Level 2 (Managed)
- 3 domains at Level 3 (Defined)
- 1 domain at Level 4 (Quantitatively Managed)
- 0 domains at Level 5 (Optimizing)

### Dimension 3: Best Practices Assessment ⚠️
**Status:** 75% compliant across 5 frameworks
- MCSB: 78% (7/9 controls)
- CIS v8: 83% (5/6 controls)
- NIST 800-53: 70% (7/10 controls)
- PCI-DSS: 75% (3/4 controls)
- CSA CCM: 67% (4/6 controls)

---

## Top 10 Risks

| # | Risk | Severity | Impacted Subs | Frameworks Flagged |
|---|------|----------|---------------|-------------------|
| 1 | NSGs allowing 0.0.0.0/0 | Critical | 12 | MCSB, CIS, NIST |
| 2 | Missing diagnostic settings | High | 5 | All 5 frameworks |
| 3 | Key Vaults without soft delete | High | 3 | MCSB, PCI-DSS |
| 4 | No PIM for privileged access | High | All | CIS, NIST |
| 5 | Inconsistent log retention | Medium | 8 | NIST, PCI-DSS |
| 6 | Storage without encryption | Medium | 6 | All 5 frameworks |
| 7 | Missing backup policies | Medium | 3 | CIS, NIST |
| 8 | No Azure Firewall | Medium | 5 | MCSB, CIS |
| 9 | Overprivileged RBAC assignments | Medium | 15 | CIS, NIST |
| 10 | Missing tags for classification | Low | 20 | CIS |

---

## Remediation Roadmap

### Phase 1: Critical (0-30 days)
- [ ] Remediate NSGs allowing 0.0.0.0/0 (12 subscriptions)
- [ ] Enable soft delete on Key Vaults (3 subscriptions)
- [ ] Deploy diagnostic settings (5 subscriptions)
- **Effort:** 40 hours | **Cost:** $0 | **Risk Reduction:** 60%

### Phase 2: High Priority (30-90 days)
- [ ] Implement PIM for privileged roles
- [ ] Standardize log retention (2 years minimum)
- [ ] Enable storage encryption at rest
- [ ] Deploy backup policies for missing resources
- **Effort:** 80 hours | **Cost:** $5K | **Risk Reduction:** 30%

### Phase 3: Medium Priority (90-180 days)
- [ ] Deploy Azure Firewall in hub subscriptions
- [ ] Review and optimize RBAC assignments
- [ ] Implement tagging policy
- [ ] Develop formal change management process
- **Effort:** 120 hours | **Cost:** $50K | **Risk Reduction:** 10%

---

## Estimated Cost to Remediate

- **Quick Wins (Phase 1):** $0 (configuration changes only)
- **High Priority (Phase 2):** $5,000 (PIM, logging costs)
- **Medium Priority (Phase 3):** $50,000 (Azure Firewall, tooling)
- **Total:** $55,000

**ROI:** Risk reduction of 100+ findings, improved compliance posture from 75% to 95%+

---

## Recommendations

### Immediate Actions:
1. Assign remediation owners for Phase 1 items
2. Schedule monthly progress reviews
3. Implement Azure Policy for preventive controls
4. Establish compliance dashboard

### Long-Term Strategy:
1. Mature to Level 4 (Quantitatively Managed) across all process domains
2. Achieve 95%+ compliance across all 5 frameworks
3. Implement continuous compliance monitoring
4. Quarterly re-assessment to track progress
```

### Step 3: Create Detailed Remediation Tickets

**For each finding, create actionable tickets:**

```markdown
# Remediation Ticket Template

**Ticket ID:** REM-001
**Title:** Remediate NSGs Allowing 0.0.0.0/0
**Priority:** Critical
**Assigned To:** Network Operations Team

## Background
**D3 Finding:** 12 NSGs contain rules allowing traffic from any source (0.0.0.0/0)
**D2 Finding:** No formal policy against overly permissive rules
**Frameworks Flagged:** MCSB-NS-1, CIS-6.1, NIST-SC-7

## Risk
Allowing 0.0.0.0/0 exposes resources to potential unauthorized access from the internet.

## Remediation Steps
1. Review each NSG rule allowing 0.0.0.0/0
2. Identify legitimate business need
3. Replace with specific source IP ranges or service tags
4. Document exceptions with business justification
5. Implement Azure Policy to prevent future violations

## Affected Resources
- Subscription: sub-12345-dev
  - NSG: nsg-web-tier (Rule: AllowHTTP)
- Subscription: sub-67890-prod
  - NSG: nsg-app-tier (Rule: AllowSSH)
- [List all 12 NSGs]

## Validation
- [ ] Re-run Framework-MCSB.psm1 Test-MCSB-NS-1
- [ ] Re-run Framework-CISv8.psm1 Test-CISv8-6-1
- [ ] Verify controls show "Pass"

## Due Date
30 days from report delivery

## Effort Estimate
8 hours (4 hours review + 4 hours remediation)
```

---

## 🔒 Data Handling & Security

### What Goes Where

**PUBLIC (safe to commit to GitHub):**
- ✅ Scripts (always public)
- ✅ Documentation (always public)
- ✅ Validation modules (always public)
- ✅ Interview templates (generic, no customer data)

**PRIVATE (NEVER commit to GitHub):**
- ❌ Collected JSON files (`local-customer-data/collected/`)
- ❌ Transformed CSV files (`local-customer-data/transformed/`)
- ❌ Validation results (`local-customer-data/validation-results/`)
- ❌ Interview notes (`local-customer-data/interviews/`)
- ❌ Final reports (`local-customer-data/final-report/`)
- ❌ Any customer-specific information

### Data Retention

**After assessment completion:**

```bash
# 1. Create encrypted backup of customer data
cd /secure/customer-assessments/customer-name-20251018
tar -czf customer-name-assessment-data.tar.gz local-customer-data/

# 2. Encrypt with password
gpg --symmetric --cipher-algo AES256 customer-name-assessment-data.tar.gz

# 3. Store encrypted file in secure location
mv customer-name-assessment-data.tar.gz.gpg /secure/archives/

# 4. Securely delete local data after project closure
cd secai-framework
rm -rf local-customer-data/
# Or keep until project closure + retention period
```

### Framework Updates

**To pull latest SecAI Framework updates:**

```bash
cd /secure/customer-assessments/customer-name-20251018/secai-framework

# Check if customer data is safe
git status  # Should show ONLY framework files, not local-customer-data/

# Pull latest updates
git pull origin main

# Customer data remains untouched in local-customer-data/
```

---

## 📞 Support & Questions

**If you encounter issues:**

1. **Framework bugs or feature requests:** Open issue on GitHub
2. **Validation module questions:** Review `workspace/3-Best-Practices-Work/VALIDATION_USAGE_GUIDE.md`
3. **Process template questions:** Review `workspace/2-Process-Assessment-Work/README.md`

**Community:**
- GitHub Discussions: https://github.com/zimaxnet/secai-framework/discussions
- Documentation: https://zimaxnet.github.io/secai-framework

---

## ✅ Checklist: Complete Assessment Workflow

**Pre-Assessment:**
- [ ] Clone SecAI Framework to secure workstation
- [ ] Create `local-customer-data/` directory (excluded from git)
- [ ] Verify customer data won't be committed

**Dimension 1: Configuration (DONE):**
- [✅] Authenticate to Azure (`az login`)
- [✅] Run collection scripts (00-09)
- [✅] Collect 800+ evidence files
- [✅] Run transformation scripts (11-17)

**Dimension 3: Best Practices:**
- [ ] Review validation modules in `workspace/3-Best-Practices-Work/`
- [ ] Configure `Validate-All-Frameworks.ps1` with correct paths
- [ ] Execute multi-framework validation
- [ ] Review executive summary
- [ ] Analyze gap details by framework
- [ ] Identify top risks and priorities

**Dimension 2: Process:**
- [ ] Use D3 findings to identify focus areas
- [ ] Select relevant interview templates
- [ ] Customize questions based on D3 gaps
- [ ] Schedule interviews with 8-9 key personnel
- [ ] Conduct interviews (1.5-2 hours each)
- [ ] Document process maturity scores
- [ ] Create process maturity scorecard

**Reporting:**
- [ ] Generate executive summary
- [ ] Create detailed findings report
- [ ] Develop remediation roadmap with phases
- [ ] Estimate costs and timelines
- [ ] Create actionable tickets for each finding
- [ ] Present to customer stakeholders

**Post-Assessment:**
- [ ] Encrypt and backup all customer data
- [ ] Deliver final reports to customer
- [ ] Schedule 90-day follow-up assessment
- [ ] Securely delete local data (per retention policy)

---

**Last Updated:** October 18, 2025  
**Framework Version:** SecAI 2.0  
**Status:** Production Ready

