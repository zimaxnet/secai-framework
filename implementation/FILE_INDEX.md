# SecAI Framework - File Index

**Complete directory and file listing**  
**Last Updated:** October 17, 2025

---

## Directory Structure

```
SecAI-Framework/
├── README.md                          # Framework overview and main documentation
├── QUICK_START.md                     # 15-minute quick start guide
├── FILE_INDEX.md                      # This file
│
├── 1-Documentation/                   # All framework documentation (consolidated)
│   ├── FRAMEWORK_OVERVIEW.md          # Complete framework architecture and methodology
│   ├── CONFIGURATION_ASSESSMENT.md    # Dimension 1: Technical configuration guide
│   ├── PROCESS_ASSESSMENT.md          # Dimension 2: Operational process guide
│   ├── BEST_PRACTICES_ASSESSMENT.md   # Dimension 3: Industry standards alignment
│   ├── EXECUTION_GUIDE.md             # Detailed step-by-step execution
│   ├── SSL_PROXY_ISSUE_REPORT.md      # Troubleshooting SSL issues
│   ├── PERMISSION_REQUEST_TEMPLATE.md # Template for requesting Azure permissions
│   ├── QUICK_REFERENCE_PERMISSIONS.md # Quick permissions reference
│   ├── README_WORKSPACE_STATUS.md     # Workspace setup and status
│   ├── EXCEL_IMPORT_GUIDE.html        # Guide for importing data into Excel
│   ├── ACTION_ITEMS_SSL_FIX.md        # SSL fix action items
│   ├── [Other legacy documentation]   # Additional docs from previous iterations
│   └── SCRIPT_REVIEW.md               # Technical review of all scripts
│
├── 2-Scripts/                         # All automation scripts (organized by function)
│   ├── Collection/                    # PowerShell data collection scripts
│   │   ├── 00_diagnostics.ps1         # Azure permissions diagnostics
│   │   ├── 00_login.ps1               # Azure authentication
│   │   ├── 01_scope_discovery.ps1     # Discover management groups & subscriptions
│   │   ├── 02_inventory.ps1           # Inventory all resources
│   │   ├── 03_policies_and_defender.ps1  # Azure Policy and Defender for Cloud
│   │   ├── 04_identity_and_privileged_NO_AD_BYPASS_SSL.ps1  # RBAC, Identity (SSL bypass)
│   │   ├── 05_network_security.ps1    # Network configs (VNets, NSGs, Firewalls, LBs)
│   │   ├── 06_data_protection.ps1     # Storage, Key Vaults, SQL
│   │   ├── 07_logging_threat_detection.ps1  # Logging, Sentinel
│   │   ├── 08_backup_recovery.ps1     # Backup vaults and policies
│   │   ├── 09_posture_vulnerability.ps1  # Secure Score, assessments
│   │   ├── 10_evidence_counter.py     # Count and summarize collected evidence
│   │   ├── FIXES_APPLIED.md           # Script bug fixes log
│   │   └── POWERSHELL_README.md       # PowerShell usage guide
│   │
│   ├── Transformation/                # Python data transformation scripts
│   │   ├── 11_transform_security.py   # Transform security data to CSV
│   │   ├── 12_transform_inventory.py  # Transform inventory data to CSV
│   │   ├── 13_transform_rbac.py       # Transform RBAC data to CSV
│   │   ├── 14_transform_network.py    # Transform network data to CSV
│   │   ├── 15_transform_data_protection.py  # Transform data protection to CSV
│   │   ├── 16_transform_logging.py    # Transform logging data to CSV
│   │   └── 17_transform_policies.py   # Transform policy data to CSV
│   │
│   └── Analysis/                      # Python analysis and risk assessment scripts
│       ├── 18_analyze_top_risks.py    # Identify and prioritize top security risks
│       └── 19_analyze_subscription_comparison.py  # Compare configs across subscriptions
│
├── 3-Data/                            # All data files (input and output)
│   ├── Input/                         # Customer-specific input data (placeholder)
│   │   └── [Customer data stays in secure environment]
│   │
│   └── Output/                        # Generated data files from scripts
│       ├── scope.json                 # Subscriptions and management groups
│       ├── subscriptions.json         # Subscription details
│       ├── management_groups.json     # Management group hierarchy
│       ├── mg_sub_map.json            # MG to subscription mapping
│       ├── evidence_counts.csv        # Evidence summary
│       ├── {subscription}_rgs.json    # Resource groups per subscription (34 files)
│       ├── {subscription}_resources.json  # Resources per subscription (34 files)
│       ├── {subscription}_policy_assignments.json  # Policy assignments (34 files)
│       ├── {subscription}_role_assignments.json  # RBAC assignments (34 files)
│       ├── {subscription}_vnets.json  # Virtual networks (34 files)
│       ├── {subscription}_nsgs.json   # Network security groups (34 files)
│       ├── {subscription}_az_firewalls.json  # Azure Firewalls (34 files)
│       ├── {subscription}_load_balancers.json  # Load Balancers (34 files) ← NEW in v2.0
│       ├── {subscription}_private_endpoints.json  # Private Endpoints (34 files)
│       ├── {subscription}_storage.json  # Storage accounts (34 files)
│       ├── {subscription}_keyvaults.json  # Key Vaults (34 files)
│       ├── {subscription}_sql_servers.json  # SQL Servers (34 files)
│       ├── {subscription}_sql_dbs.json  # SQL Databases (34 files)
│       ├── {subscription}_la_workspaces.json  # Log Analytics (34 files)
│       ├── {subscription}_backup_policies.json  # Backup policies (34 files)
│       ├── {subscription}_secure_score.json  # Secure Score (34 files)
│       └── [800+ total JSON files]
│
├── 4-Templates/                       # Assessment templates and frameworks
│   ├── Azure_Framework_2025.xlsx      # Master assessment workbook (12 security domains)
│   ├── assessment_matrix.csv          # Assessment questions matrix
│   └── excel_sheet_names.txt          # Excel sheet naming reference
│
├── 5-Reports/                         # Generated reports and dashboards
│   ├── EXECUTIVE_SUMMARY_REPORT.html  # Executive-level summary
│   ├── SECURITY_TEAM_ACTION_DASHBOARD.html  # Security team action items
│   ├── NETWORK_TEAM_FINDINGS.html     # Network security findings
│   └── IDENTITY_TEAM_RBAC_REVIEW.html  # Identity and RBAC review
│
└── Archive/                           # Historical and archived materials
    ├── archive/                       # Original project files from earlier iterations
    │   ├── Business_Justification.md
    │   ├── Technical_Addendum.md
    │   ├── Governance_SOP_Playbook.md
    │   ├── COMPLETE_VENDOR_ANALYSIS.md
    │   ├── IMPLEMENTATION_SUMMARY.md
    │   └── [Other historical docs]
    │
    ├── TRANSFER_TO_CITRIX/            # Citrix transfer package (legacy)
    ├── Assessment-Archive-Oct15-2025/ # Old assessment files from Oct 15
    └── Old-Workspace-Files/           # Deprecated workspace materials
```

---

## File Counts by Category

### Documentation (1-Documentation/)
- **Total:** 20+ markdown and HTML files
- **Core Guides:** 4 (Framework, Configuration, Process, Best Practices)
- **Execution Guides:** 2 (Execution Guide, Quick Start)
- **Troubleshooting:** 3 (SSL, Permissions, Script Review)
- **Status Reports:** 5+ HTML status reports

### Scripts (2-Scripts/)
- **Collection:** 11 PowerShell scripts + 1 Python script
- **Transformation:** 7 Python scripts
- **Analysis:** 2 Python scripts
- **Total:** 21 scripts

### Data Files (3-Data/Output/)
- **Foundation:** 4 files (scope, subscriptions, MGs, mapping)
- **Tenant-Wide:** 3 files (policies, applications, service principals)
- **Per-Subscription:** 25 file types × 34 subscriptions = 850 files
- **Summary:** 1 file (evidence_counts.csv)
- **Total:** 850+ JSON/CSV files

### Templates (4-Templates/)
- **Excel Workbook:** 1 (Azure_Framework_2025.xlsx)
- **Assessment Matrix:** 1 CSV file
- **Reference Files:** 1+ additional files
- **Total:** 3+ files

### Reports (5-Reports/)
- **HTML Dashboards:** 4 files
- **Additional Reports:** As generated by analysis scripts
- **Total:** 4+ files

### Archive (Archive/)
- **Historical Docs:** 15+ files
- **Transfer Packages:** Multiple directories
- **Old Scripts:** 10+ archived versions
- **Total:** 50+ archived files

---

## Key Files for Getting Started

### Must Read (In Order)
1. `README.md` - Start here for framework overview
2. `QUICK_START.md` - 15-minute quick start guide
3. `1-Documentation/FRAMEWORK_OVERVIEW.md` - Complete framework methodology
4. `1-Documentation/EXECUTION_GUIDE.md` - Detailed step-by-step instructions

### For Troubleshooting
1. `1-Documentation/SSL_PROXY_ISSUE_REPORT.md` - SSL certificate issues
2. `1-Documentation/PERMISSION_REQUEST_TEMPLATE.md` - Azure permissions
3. `2-Scripts/Collection/POWERSHELL_README.md` - PowerShell usage
4. `2-Scripts/Collection/SCRIPT_REVIEW.md` - Script technical details

### For Deep Dive
1. `1-Documentation/CONFIGURATION_ASSESSMENT.md` - Configuration dimension details
2. `1-Documentation/PROCESS_ASSESSMENT.md` - Process dimension details
3. `1-Documentation/BEST_PRACTICES_ASSESSMENT.md` - Best practices dimension details

---

## Script Execution Order

### Phase 1: Setup (5 minutes)
1. `00_diagnostics.ps1` (optional)
2. `00_login.ps1` (required)

### Phase 2: Foundation (30 minutes)
3. `01_scope_discovery.ps1`
4. `02_inventory.ps1`

### Phase 3: Security Assessment (3-4 hours)
5. `03_policies_and_defender.ps1`
6. `04_identity_and_privileged_NO_AD_BYPASS_SSL.ps1`
7. `05_network_security.ps1` ← Includes Load Balancers (NEW in v2.0)
8. `06_data_protection.ps1`
9. `07_logging_threat_detection.ps1`
10. `08_backup_recovery.ps1`
11. `09_posture_vulnerability.ps1`

### Phase 4: Evidence Summary (1 minute)
12. `10_evidence_counter.py`

### Phase 5: Transformation (30 minutes)
13. `11_transform_security.py`
14. `12_transform_inventory.py`
15. `13_transform_rbac.py`
16. `14_transform_network.py`
17. `15_transform_data_protection.py`
18. `16_transform_logging.py`
19. `17_transform_policies.py`

### Phase 6: Analysis (20 minutes)
20. `18_analyze_top_risks.py`
21. `19_analyze_subscription_comparison.py`

---

## Data Output Files

### Foundation Files (Created by Scripts 01-02)
- `scope.json` - All subscriptions for assessment
- `subscriptions.json` - Subscription details
- `management_groups.json` - Management group hierarchy
- `mg_sub_map.json` - MG to subscription mappings

### Per-Subscription Files (34 files each)

**Inventory (Script 02):**
- `{sub}_rgs.json` - Resource groups
- `{sub}_resources.json` - All resources
- `{sub}_resource_type_counts.json` - Resource type summary

**Policies & Defender (Script 03):**
- `{sub}_policy_assignments.json` - Policy assignments
- `{sub}_policy_set_definitions.json` - Policy initiatives
- `{sub}_defender_pricing.json` - Defender tiers
- `{sub}_regulatory_compliance.json` - Compliance standards

**Identity & Access (Script 04):**
- `{sub}_role_assignments.json` - RBAC assignments

**Network (Script 05):**
- `{sub}_vnets.json` - Virtual networks
- `{sub}_nsgs.json` - Network security groups
- `{sub}_asgs.json` - Application security groups
- `{sub}_route_tables.json` - Route tables
- `{sub}_az_firewalls.json` - Azure Firewalls
- `{sub}_load_balancers.json` - Load Balancers ← NEW
- `{sub}_private_endpoints.json` - Private endpoints

**Data Protection (Script 06):**
- `{sub}_storage.json` - Storage accounts
- `{sub}_keyvaults.json` - Key Vaults
- `{sub}_sql_servers.json` - SQL Servers
- `{sub}_sql_dbs.json` - SQL Databases

**Logging (Script 07):**
- `{sub}_la_workspaces.json` - Log Analytics Workspaces
- `{sub}_subscription_diag.json` - Diagnostic settings
- `{sub}_sentinel.json` - Sentinel deployments

**Backup (Script 08):**
- `{sub}_recovery_vaults.json` - Recovery Services Vaults
- `{sub}_backup_policies.json` - Backup policies

**Security Posture (Script 09):**
- `{sub}_secure_score.json` - Secure Score
- `{sub}_security_assessments.json` - Security assessments

### Tenant-Wide Files (Single files)
- `tenant_policy_definitions.json` - All policy definitions
- `tenant_applications.json` - Azure AD applications
- `tenant_service_principals.json` - Service principals

### Summary Files
- `evidence_counts.csv` - Evidence collection summary

---

## Reports and Dashboards

### HTML Dashboards (5-Reports/)
1. **EXECUTIVE_SUMMARY_REPORT.html**
   - High-level risk summary
   - Key findings across all domains
   - Recommendations for leadership

2. **SECURITY_TEAM_ACTION_DASHBOARD.html**
   - Prioritized action items
   - Security findings by severity
   - Remediation guidance

3. **NETWORK_TEAM_FINDINGS.html**
   - Network security findings
   - Firewall and NSG configurations
   - Segmentation analysis

4. **IDENTITY_TEAM_RBAC_REVIEW.html**
   - RBAC assignment review
   - Excessive permissions
   - Access review requirements

### Excel Workbook (4-Templates/)
**Azure_Framework_2025.xlsx** - 12 security domain worksheets:
1. Identity and Access Management
2. Network Security
3. Data Protection
4. Threat Detection
5. Logging and Monitoring
6. Backup and Recovery
7. Compliance and Governance
8. Vulnerability Management
9. Application Security
10. DevSecOps
11. Incident Response
12. Business Continuity

---

## What's New in Version 2.0

### Enhanced Network Discovery
- ✅ **Load Balancer Collection** added to `05_network_security.ps1`
- Discovers edge firewall architectures (load balancer sandwich)
- Active-active firewall configurations
- Backend pool mappings

### Improved Documentation
- ✅ **Three-Dimensional Assessment** methodology fully documented
- Configuration, Process, and Best Practices guides
- Framework overview with CSP-to-MCA migration focus
- Quick start guide for rapid deployment

### Organized Structure
- ✅ **Centralized Documentation** in `1-Documentation/`
- Scripts organized by function (Collection, Transformation, Analysis)
- Data segregated (Input vs Output)
- Templates and reports in dedicated folders
- Archive for historical materials

---

## Version History

**Version 2.0** (October 17, 2025)
- Added load balancer discovery
- Reorganized entire workspace
- Created comprehensive documentation
- Three-dimensional assessment methodology
- Sanitized for SecAI Framework branding

**Version 1.0** (October 15, 2025)
- Initial Azure Assessment Kit
- 9 collection scripts
- SSL proxy workaround
- Basic reporting

---

## Maintenance Notes

### Regular Updates Needed
- **Evidence Collection:** Run monthly or after major changes
- **Reports:** Regenerate after each assessment
- **Documentation:** Update when processes change
- **Scripts:** Test and update for Azure API changes

### Archive Policy
- Archive assessment results after each engagement
- Keep last 3 assessments readily available
- Store older assessments in long-term archive
- Document any customer-specific modifications

---

## Security and Sanitization

### Customer Data
- ❌ **No customer data** in this framework repository
- ❌ **No subscription IDs** in committed code
- ❌ **No tenant IDs** in documentation
- ✅ All customer data in secure SharePoint/OneDrive
- ✅ Generic examples in documentation

### What's Safe to Share
- ✅ Framework documentation
- ✅ PowerShell and Python scripts
- ✅ Templates and assessment matrix
- ✅ Methodology and guides

### What's NOT Safe to Share
- ❌ Customer-specific data files (3-Data/Output/)
- ❌ Generated reports with customer data
- ❌ Populated Excel workbooks
- ❌ Screenshots with customer identifiers

---

## Support and Contributions

### Documentation Locations
- **Framework Questions:** See `1-Documentation/FRAMEWORK_OVERVIEW.md`
- **Script Issues:** See `2-Scripts/Collection/SCRIPT_REVIEW.md`
- **Execution Help:** See `1-Documentation/EXECUTION_GUIDE.md`
- **Quick Start:** See `QUICK_START.md`

### Feedback and Improvements
- Document any issues in `Archive/` with timestamp
- Update `SCRIPT_REVIEW.md` for script changes
- Keep `FRAMEWORK_OVERVIEW.md` current
- Version control all changes

---

**Framework Version:** 2.0  
**Last Updated:** October 17, 2025  
**Status:** Production Ready  
**Total Files:** 900+ (including data files)

---

## Quick Navigation

| Need | File Location |
|------|---------------|
| Overview | `README.md` |
| Quick Start | `QUICK_START.md` |
| Full Documentation | `1-Documentation/FRAMEWORK_OVERVIEW.md` |
| Run Scripts | `2-Scripts/Collection/` |
| View Data | `3-Data/Output/` |
| Assessment Template | `4-Templates/Azure_Framework_2025.xlsx` |
| View Reports | `5-Reports/` |
| File Index | `FILE_INDEX.md` (this file) |

---

**End of File Index**

