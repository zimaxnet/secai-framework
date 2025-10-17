# Configuration Assessment Guide

**SecAI Framework - Dimension 1**

---

## Overview

Configuration Assessment focuses on **what is deployed** and **how it is technically configured** in the Azure environment. This is the most automated aspect of the SecAI Framework, leveraging Azure CLI, Resource Graph, and PowerShell to collect comprehensive configuration data.

---

## What is Configuration Assessment?

Configuration assessment evaluates the **technical state** of Azure resources:

- Resource types and quantities
- Security settings and controls
- Network architecture and segmentation
- Access policies and RBAC
- Encryption configurations
- Backup and monitoring settings
- Compliance with Azure Policy

**Key Principle:** Configuration assessment is **objective and measurable** - settings either exist or they don't, policies are either assigned or not, encryption is either enabled or disabled.

---

## Collection Scripts

### Script 01: Scope Discovery

**Purpose:** Discover all management groups and subscriptions

**Collects:**
- Management group hierarchy
- All subscriptions in tenant
- Subscription states (Enabled/Disabled)
- Management group to subscription mappings

**Output Files:**
- `management_groups.json`
- `subscriptions.json`
- `mg_sub_map.json`
- `scope.json` (used by all subsequent scripts)

**Key Metrics:**
- Number of management groups
- Number of subscriptions
- Subscription distribution across MGs

---

### Script 02: Inventory

**Purpose:** Inventory all resources across all subscriptions

**Collects:**
- All resource groups per subscription
- All resources per subscription
- Resource type counts
- Resource locations
- Resource tags

**Output Files (per subscription):**
- `{sub}_rgs.json` (resource groups)
- `{sub}_resources.json` (all resources)
- `{sub}_resource_type_counts.json` (summary by type)

**Key Metrics:**
- Total resources across tenant
- Resources per subscription
- Resource types deployed
- Untagged resources

**Example Insights:**
```
Total Subscriptions: 34
Total Resource Groups: 856
Total Resources: 5,088
Most Common Types: Virtual Machines (420), Storage Accounts (380), VNets (150)
```

---

### Script 03: Policies and Defender for Cloud

**Purpose:** Collect Azure Policy and Defender for Cloud configurations

**Collects:**
- Tenant policy definitions
- Policy assignments (all scopes)
- Policy set definitions (initiatives)
- Defender for Cloud pricing tiers
- Regulatory compliance standards

**Output Files:**
- `tenant_policy_definitions.json` (tenant-wide)
- Per subscription:
  - `{sub}_policy_assignments.json`
  - `{sub}_policy_set_definitions.json`
  - `{sub}_defender_pricing.json`
  - `{sub}_regulatory_compliance.json`

**Key Metrics:**
- Policy assignments per subscription
- Defender for Cloud coverage (Free vs Standard)
- Regulatory compliance standards enabled
- Non-compliant resources

**Critical for CSP to MCA:**
- CSP subscriptions typically have 0-10 policy assignments
- MCA subscriptions have ~1,000 policy assignments
- Gap represents migration work required

---

### Script 04: Identity and Privileged Access

**Purpose:** Collect identity and access management data

**Collects:**
- Azure AD applications (tenant-wide)
- Service principals (tenant-wide)
- RBAC role assignments per subscription
- Managed identities

**Output Files:**
- `tenant_applications.json` (tenant-wide)
- `tenant_service_principals.json` (tenant-wide)
- Per subscription:
  - `{sub}_role_assignments.json`

**Key Metrics:**
- Total RBAC assignments across tenant
- Service principals with access
- Users with privileged roles (Owner, Contributor)
- Orphaned role assignments

**Security Insights:**
- Excessive permissions (e.g., Owner at subscription scope)
- Service principals with broad access
- Guest users with privileged roles
- Role assignments without business justification

---

### Script 05: Network Security

**Purpose:** Collect network configurations and security controls

**Collects:**
- Virtual Networks (VNets)
- Network Security Groups (NSGs)
- Application Security Groups (ASGs)
- Route Tables
- Azure Firewalls
- Load Balancers (NEW in v2.0)
- Private Endpoints

**Output Files (per subscription):**
- `{sub}_vnets.json`
- `{sub}_nsgs.json`
- `{sub}_asgs.json`
- `{sub}_route_tables.json`
- `{sub}_az_firewalls.json`
- `{sub}_load_balancers.json`
- `{sub}_private_endpoints.json`

**Key Metrics:**
- VNets per subscription/environment
- NSG rules (allow vs deny)
- Firewall configurations
- Load balancer types and backends
- Private endpoint connections

**Network Architecture Insights:**
- Hub-spoke topology validation
- Network segmentation effectiveness
- Firewall rule complexity
- Edge protection (load balancer + firewall sandwich)
- Private Link adoption

---

### Script 06: Data Protection

**Purpose:** Collect data security and encryption configurations

**Collects:**
- Storage Accounts (encryption, soft delete, etc.)
- Azure Key Vaults (access policies, RBAC, purge protection)
- SQL Servers
- SQL Databases (per server, not per subscription)

**Output Files (per subscription):**
- `{sub}_storage.json`
- `{sub}_keyvaults.json`
- `{sub}_sql_servers.json`
- `{sub}_sql_dbs.json`

**Key Metrics:**
- Storage accounts with encryption at rest
- Key Vaults with purge protection
- SQL databases with TDE (Transparent Data Encryption)
- Soft delete enabled

**Data Protection Insights:**
- Unencrypted storage accounts
- Key Vaults without RBAC
- SQL databases without backup
- Secrets stored insecurely

---

### Script 07: Logging and Threat Detection

**Purpose:** Collect logging and monitoring configurations

**Collects:**
- Log Analytics Workspaces
- Subscription diagnostic settings
- Microsoft Sentinel (if deployed)
- Workspace configurations

**Output Files (per subscription):**
- `{sub}_la_workspaces.json`
- `{sub}_subscription_diag.json`
- `{sub}_sentinel.json`

**Key Metrics:**
- Log Analytics Workspace count
- Subscriptions with diagnostic settings
- Sentinel deployments
- Log retention policies

**Logging Insights:**
- Subscriptions without diagnostic settings
- Inadequate log retention
- Missing security log categories
- No centralized logging

---

### Script 08: Backup and Recovery

**Purpose:** Collect backup configurations

**Collects:**
- Recovery Services Vaults
- Backup Policies (per vault, not per subscription)
- Backup items and protected resources

**Output Files (per subscription):**
- `{sub}_recovery_vaults.json`
- `{sub}_backup_policies.json`

**Key Metrics:**
- Recovery vaults per environment
- Resources with backup configured
- Backup policies and schedules
- Retention policies

**Backup Insights:**
- Resources without backup
- Backup policies not aligned to RPO/RTO
- Missing cross-region backup
- Restore testing gaps

---

### Script 09: Security Posture and Vulnerability

**Purpose:** Collect security assessments and scores

**Collects:**
- Secure Score from Defender for Cloud
- Security Assessments
- Unhealthy resource counts
- Recommendations

**Output Files (per subscription):**
- `{sub}_secure_score.json`
- `{sub}_security_assessments.json`

**Key Metrics:**
- Secure Score per subscription
- Number of unhealthy resources
- Critical/High severity findings
- Top security recommendations

**Posture Insights:**
- Low Secure Score subscriptions
- Most common security findings
- Trend analysis (if historical data available)
- Priority remediation actions

---

## Data Transformation

After collection, raw JSON data is transformed into structured CSV for analysis:

### Transformation Scripts

**11_transform_security.py**
- Aggregates security assessments
- Calculates risk scores
- Identifies critical findings

**12_transform_inventory.py**
- Summarizes resource counts
- Identifies orphaned resources
- Resource tagging analysis

**13_transform_rbac.py**
- RBAC assignment matrix
- Privileged access summary
- Excessive permissions report

**14_transform_network.py**
- Network topology visualization data
- NSG rule analysis
- Firewall and load balancer mapping

**15_transform_data_protection.py**
- Encryption coverage matrix
- Key Vault usage analysis
- SQL security summary

**16_transform_logging.py**
- Logging coverage matrix
- Diagnostic settings gaps
- Sentinel deployment summary

**17_transform_policies.py**
- Policy compliance summary
- Non-compliant resources
- Policy assignment coverage

---

## Analysis

### Analysis Scripts

**18_analyze_top_risks.py**
- Identifies top 10 security risks
- Prioritizes based on severity and exposure
- Maps to security domains
- Generates risk register

**19_analyze_subscription_comparison.py**
- Compares configurations across subscriptions
- Identifies outliers
- Validates consistency
- Highlights drift

---

## Configuration Assessment Deliverables

### 1. Configuration Inventory

Complete inventory of:
- 5,000+ resources
- 34+ subscriptions
- 12 security domains
- 800+ configuration files

### 2. Security Configuration Report

Detailed findings across:
- Network security
- Identity and access
- Data protection
- Logging and monitoring
- Backup and recovery

### 3. Compliance Matrix

Azure Policy compliance:
- Total policies assigned
- Compliant resources
- Non-compliant resources
- Exemptions and exclusions

### 4. Gap Analysis

Comparison of:
- Current state vs. desired state
- CSP vs. MCA configurations
- Environment-to-environment consistency
- Best practice alignment

### 5. Risk Register

Prioritized list of:
- Configuration vulnerabilities
- Security gaps
- Compliance violations
- Remediation recommendations

---

## Configuration Assessment Questions

For each security domain, configuration assessment answers:

### Identity and Access Management
- ✅ How many RBAC assignments exist?
- ✅ Who has Owner/Contributor roles?
- ✅ Are service principals documented?
- ✅ Is PIM configured?
- ✅ Are managed identities used?

### Network Security
- ✅ How many VNets are deployed?
- ✅ Are NSGs applied to all subnets?
- ✅ Are Azure Firewalls configured?
- ✅ Are load balancers deployed?
- ✅ Are private endpoints used?

### Data Protection
- ✅ Are storage accounts encrypted?
- ✅ Is soft delete enabled?
- ✅ Are Key Vaults secured with RBAC?
- ✅ Is SQL TDE enabled?
- ✅ Is purge protection configured?

### Threat Detection
- ✅ Is Defender for Cloud enabled?
- ✅ Which Defender plans are active?
- ✅ Is Sentinel deployed?
- ✅ Are security alerts configured?

### Logging and Monitoring
- ✅ Are diagnostic settings configured?
- ✅ What is log retention?
- ✅ Are activity logs centralized?
- ✅ Are alerts configured?

### Backup and Recovery
- ✅ Are Recovery Vaults deployed?
- ✅ Which resources are backed up?
- ✅ What are backup schedules?
- ✅ What is retention policy?

### Compliance and Governance
- ✅ How many policies are assigned?
- ✅ What is compliance percentage?
- ✅ Are resources tagged?
- ✅ Are costs managed?

### Vulnerability Management
- ✅ What is the Secure Score?
- ✅ How many unhealthy resources?
- ✅ What are top recommendations?
- ✅ Are vulnerabilities being remediated?

---

## Best Practices for Configuration Assessment

### 1. Collect Frequently

Run collection scripts:
- **Monthly:** For mature environments
- **Weekly:** During active development
- **Daily:** During migration or major changes

### 2. Version Control

Store outputs with timestamps:
```
assessment_2025-10-17/
├── scope.json
├── subscriptions.json
├── {sub}_*.json
└── evidence_counts.csv
```

### 3. Compare Over Time

Track trends:
- Resource growth
- Policy compliance improvements
- Secure Score changes
- Remediation progress

### 4. Automate Collection

Use Azure DevOps or GitHub Actions:
- Scheduled pipeline runs
- Store artifacts
- Trigger on demand
- Alert on significant changes

### 5. Document Exceptions

For non-compliant resources:
- Business justification
- Risk acceptance
- Compensating controls
- Remediation timeline

---

## Common Configuration Findings

### Critical Findings

🔴 **No Network Security Groups on subnets**
- Risk: Unrestricted network traffic
- Impact: Potential lateral movement
- Remediation: Deploy NSGs with deny-by-default

🔴 **Storage accounts without encryption**
- Risk: Data exposure
- Impact: Compliance violation
- Remediation: Enable encryption at rest

🔴 **SQL without TDE**
- Risk: Data breach
- Impact: Regulatory non-compliance
- Remediation: Enable Transparent Data Encryption

### High Findings

🟠 **Excessive Owner role assignments**
- Risk: Privilege escalation
- Impact: Unauthorized changes
- Remediation: Implement least privilege

🟠 **No diagnostic settings on subscriptions**
- Risk: Limited visibility
- Impact: Delayed incident detection
- Remediation: Enable centralized logging

### Medium Findings

🟡 **Resources without tags**
- Risk: Cost tracking issues
- Impact: Lack of accountability
- Remediation: Enforce tagging policy

🟡 **Inconsistent configurations across environments**
- Risk: Configuration drift
- Impact: Unpredictable behavior
- Remediation: Standardize via Azure Policy

---

## Configuration Assessment Success Criteria

✅ **Complete data collection** - All 9 collection scripts executed successfully  
✅ **Zero gaps** - All subscriptions and resources inventoried  
✅ **Data validation** - Spot-check JSON files for accuracy  
✅ **Transformation complete** - All CSV files generated  
✅ **Analysis complete** - Risks identified and prioritized  
✅ **Deliverables ready** - Reports and dashboards generated  

---

## Next Steps

After configuration assessment:

1. **Review findings** with technical teams
2. **Prioritize remediation** based on risk
3. **Create remediation plan** with timelines
4. **Track progress** with follow-up assessments
5. **Proceed to Process Assessment** (Dimension 2)

---

**See Also:**
- `PROCESS_ASSESSMENT.md` - Dimension 2
- `BEST_PRACTICES_ASSESSMENT.md` - Dimension 3
- `EXECUTION_GUIDE.md` - Step-by-step instructions
- `FRAMEWORK_OVERVIEW.md` - Complete framework overview

