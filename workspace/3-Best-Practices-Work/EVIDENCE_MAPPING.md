# SecAI Framework - Evidence Collection Mapping

**Purpose:** Comprehensive mapping of what evidence is collected by each script  
**Date:** October 17, 2025  
**Status:** Reference Document for Control Mapping

---

## Collection Scripts Overview

The SecAI Framework includes 10 collection scripts (00-09) plus an evidence counter (10):

| Script | Name | Primary Focus | Output Files |
|--------|------|---------------|--------------|
| 00 | diagnostics.ps1 | Environment check | Diagnostic info |
| 00 | login.ps1 | Azure authentication | Login validation |
| 01 | scope_discovery.ps1 | Subscription discovery | scope.json, subscriptions.json, MG data |
| 02 | inventory.ps1 | Resource inventory | Per-sub: rgs, resources, counts |
| 03 | policies_and_defender.ps1 | Policy & security posture | Policy definitions, assignments, Defender |
| 04 | identity_and_privileged | RBAC & identity | Role assignments, PIM |
| 05 | network_security.ps1 | Network configuration | VNets, NSGs, firewalls, load balancers |
| 06 | data_protection.ps1 | Data security | Storage, Key Vaults, SQL encryption |
| 07 | logging_threat_detection.ps1 | Monitoring & SIEM | Log Analytics, diagnostic settings, Sentinel |
| 08 | backup_recovery.ps1 | Backup & DR | Recovery vaults, backup policies |
| 09 | posture_vulnerability.ps1 | Security posture | Secure Score, assessments, vulnerabilities |
| 10 | evidence_counter.py | Evidence summary | evidence_counts.csv |

---

## Script 01: Scope Discovery

### Evidence Collected

**Tenant-Level:**
- `subscriptions.json` - All subscriptions in tenant
- `management_groups.json` - Management group hierarchy
- `mg_sub_map.json` - MG to subscription mappings

**Per-Subscription:**
- `{sub-id}` entry in scope.json with:
  - Subscription ID
  - Display name
  - State (Enabled/Disabled/etc.)
  - Tenant ID

### Use Cases for Compliance:
- Asset inventory requirements (ISO 27001 A.8)
- Scope definition for assessments
- Tenant structure validation

---

## Script 02: Resource Inventory

### Evidence Collected

**Per-Subscription Files:**
- `{sub-id}_rgs.json` - All resource groups
  - Resource group name
  - Location
  - Tags
  - Properties

- `{sub-id}_resources.json` - All resources
  - Resource ID
  - Name
  - Type
  - Location
  - Tags
  - Properties

- `{sub-id}_resource_counts.json` - Resource type counts
  - Type
  - Count

### Key Evidence For:
- Asset management (CIS, ISO 27001 A.8)
- Resource naming conventions
- Tag compliance
- Location/region compliance
- Resource type inventory

---

## Script 03: Policies and Defender for Cloud

### Evidence Collected

**Tenant-Level:**
- `tenant_policy_definitions.json` - All custom policy definitions
- `tenant_policy_set_definitions.json` - Policy initiatives

**Per-Subscription:**
- `{sub-id}_policy_assignments.json` - Assigned policies
  - Policy name
  - Scope
  - Parameters
  - Enforcement mode

- `{sub-id}_defender_pricing.json` - Defender for Cloud pricing tiers
  - Resource type (VMs, Storage, SQL, etc.)
  - Pricing tier (Free/Standard)

- `{sub-id}_defender_settings.json` - Defender settings
  - Auto-provisioning
  - Integration settings

### Key Evidence For:
- CIS 2.x - Defender for Cloud requirements
- Policy enforcement validation
- Governance and compliance posture
- Regulatory compliance (policy-driven controls)

---

## Script 04: Identity and Privileged Access

### Evidence Collected

**Per-Subscription:**
- `{sub-id}_rbac_assignments.json` - All role assignments
  - Principal ID
  - Principal type (User/Group/Service Principal)
  - Role definition
  - Scope
  - Condition (if any)

- `{sub-id}_role_definitions.json` - Custom role definitions

**Tenant-Level (if accessible):**
- Conditional Access policies
- PIM (Privileged Identity Management) settings
- Azure AD users and groups (limited)

### Key Evidence For:
- CIS 1.x - Identity and Access Management
- RBAC least privilege validation (CIS 1.23)
- Privileged access controls
- ISO 27001 A.9 - Access Control
- NIST PR.AC - Access Control

---

## Script 05: Network Security

### Evidence Collected

**Per-Subscription:**
- `{sub-id}_vnets.json` - Virtual Networks
  - Name, location
  - Address spaces
  - Subnets
  - Peerings
  - DDoS protection
  
- `{sub-id}_nsgs.json` - Network Security Groups
  - Name, location
  - Security rules (inbound/outbound)
  - Associated subnets/NICs

- `{sub-id}_az_firewalls.json` - Azure Firewalls
  - Name, location
  - SKU
  - Firewall policy
  - IP configurations
  
- `{sub-id}_load_balancers.json` - Load Balancers
  - Name, location
  - SKU
  - Frontend IPs
  - Backend pools
  - Rules

- `{sub-id}_private_endpoints.json` - Private Endpoints
- `{sub-id}_public_ips.json` - Public IP addresses
- `{sub-id}_app_gws.json` - Application Gateways
- `{sub-id}_network_watchers.json` - Network Watchers

### Key Evidence For:
- CIS 6.x - Networking
- Network segmentation validation
- NSG rule analysis (deny by default)
- Firewall deployment validation
- Private endpoint usage (PaaS security)
- ISO 27001 A.13 - Communications Security
- NIST PR.AC-5 - Network segregation

---

## Script 06: Data Protection

### Evidence Collected

**Per-Subscription:**
- `{sub-id}_storage.json` - Storage Accounts
  - Name, location
  - SKU (replication)
  - Encryption settings
  - Network rules
  - Soft delete enabled
  - Versioning
  - Public access
  
- `{sub-id}_keyvaults.json` - Key Vaults
  - Name, location
  - SKU
  - Access policies / RBAC mode
  - Soft delete enabled
  - Purge protection enabled
  - Network rules
  - Private endpoint

- `{sub-id}_sql_servers.json` - SQL Servers
  - Name, location
  - Admin account
  - Azure AD admin
  - TDE enabled
  - Auditing settings

- `{sub-id}_sql_databases.json` - SQL Databases
  - Name
  - Edition/SKU
  - Encryption
  - Backup settings

- `{sub-id}_cosmos_accounts.json` - Cosmos DB accounts
- `{sub-id}_data_factories.json` - Data Factories

### Key Evidence For:
- CIS 3.x - Storage Accounts
- CIS 4.x - Database Services
- CIS 8.x - Key Vault
- Storage encryption validation (at rest)
- TDE for SQL databases
- Soft delete and purge protection
- ISO 27001 A.10 - Cryptography
- NIST PR.DS-1 - Data at rest protection

---

## Script 07: Logging and Threat Detection

### Evidence Collected

**Per-Subscription:**
- `{sub-id}_log_analytics.json` - Log Analytics Workspaces
  - Name, location
  - Retention days
  - Data sources
  
- `{sub-id}_diagnostic_settings.json` - Resource diagnostic settings
  - Resource ID
  - Log categories enabled
  - Metrics enabled
  - Destination (Log Analytics, Storage, EventHub)

- `{sub-id}_activity_log.json` - Activity log configuration
  - Retention settings
  - Export settings

- `{sub-id}_sentinel.json` - Microsoft Sentinel
  - Workspace connection
  - Data connectors
  - Analytics rules
  - Incidents

- `{sub-id}_log_profiles.json` - Log profiles

### Key Evidence For:
- CIS 5.x - Logging and Monitoring
- Activity log retention ≥ 365 days (CIS 5.1.1)
- Diagnostic settings on all resources
- Centralized logging validation
- SIEM integration (Sentinel)
- ISO 27001 A.12.4 - Logging and monitoring
- NIST DE.CM - Security continuous monitoring

---

## Script 08: Backup and Recovery

### Evidence Collected

**Per-Subscription:**
- `{sub-id}_recovery_vaults.json` - Recovery Services Vaults
  - Name, location
  - Backup policies
  - Soft delete enabled
  - Cross-region restore

- `{sub-id}_backup_policies.json` - Backup policies
  - Policy name
  - Backup frequency
  - Retention settings

- `{sub-id}_backup_items.json` - Protected items
  - Resource ID
  - Backup policy
  - Last backup
  - Protection status

- `{sub-id}_backup_jobs.json` - Recent backup jobs
  - Job status
  - Duration
  - Errors

### Key Evidence For:
- Backup configuration validation
- Backup policy alignment to RPO/RTO
- Backup coverage assessment
- ISO 27001 A.12.3 - Information backup
- ISO 27001 A.17 - Business continuity
- NIST PR.IP-4 - Backup of information

---

## Script 09: Security Posture and Vulnerability Management

### Evidence Collected

**Per-Subscription:**
- `{sub-id}_secure_score.json` - Microsoft Secure Score
  - Current score
  - Max score
  - Score percentage

- `{sub-id}_assessments.json` - Security assessments
  - Assessment name
  - Status (Healthy/Unhealthy)
  - Severity
  - Remediation description

- `{sub-id}_recommendations.json` - Security recommendations
  - Recommendation
  - Severity
  - Affected resources
  - Remediation steps

- `{sub-id}_alerts.json` - Security alerts
  - Alert name
  - Severity
  - Status
  - Affected resources

### Key Evidence For:
- Overall security posture
- Vulnerability identification
- Remediation tracking
- Compliance score (Defender for Cloud)
- NIST ID.RA - Risk Assessment
- NIST PR.IP-12 - Vulnerability management plan

---

## Script 10: Evidence Counter

### Evidence Collected

**Summary File:**
- `evidence_counts.csv` - Summary of all collected evidence
  - Subscription ID
  - Subscription name
  - File counts by type
  - Total evidence files

### Use Case:
- Validate evidence collection completeness
- Quick assessment summary
- Reporting metrics

---

## Evidence to Compliance Framework Mapping

### CIS Azure Foundations Benchmark v2.0

| CIS Section | Required Evidence | Source Scripts |
|-------------|-------------------|----------------|
| 1. Identity and Access Management | RBAC assignments, Conditional Access, MFA | Script 04 |
| 2. Microsoft Defender for Cloud | Defender pricing, settings | Script 03, 09 |
| 3. Storage Accounts | Storage config, encryption, soft delete | Script 06 |
| 4. Database Services | SQL servers, TDE, auditing | Script 06 |
| 5. Logging and Monitoring | Log Analytics, diagnostic settings, retention | Script 07 |
| 6. Networking | VNets, NSGs, firewalls, Network Watcher | Script 05 |
| 7. Virtual Machines | VM inventory, extensions, disk encryption | Script 02, 06 |
| 8. Key Vault | Key Vault config, soft delete, purge protection | Script 06 |
| 9. AppService | App Service config, HTTPS, auth | Script 02 |
| 10. Other Security Considerations | Various security controls | Scripts 02, 03, 09 |

### NIST Cybersecurity Framework

| NIST Function | Required Evidence | Source Scripts |
|---------------|-------------------|----------------|
| Identify (ID) | Asset inventory, risk assessment | Scripts 01, 02, 09 |
| Protect (PR) | Access control, data security, policies | Scripts 03, 04, 05, 06 |
| Detect (DE) | Logging, monitoring, anomalies | Script 07, 09 |
| Respond (RS) | Incident response (process assessment) | Process interviews |
| Recover (RC) | Backup, DR, recovery planning | Script 08 + Process |

### Microsoft Cloud Security Benchmark (MCSB)

| MCSB Domain | Required Evidence | Source Scripts |
|-------------|-------------------|----------------|
| Network Security (NS) | Network config, firewalls, segmentation | Script 05 |
| Identity Management (IM) | Azure AD, RBAC, identity controls | Script 04 |
| Privileged Access (PA) | PIM, privileged roles | Script 04 |
| Data Protection (DP) | Encryption, Key Vault, data security | Script 06 |
| Asset Management (AM) | Resource inventory, tagging | Scripts 01, 02 |
| Logging and Threat Detection (LT) | Log Analytics, Sentinel, monitoring | Script 07 |
| Incident Response (IR) | Security alerts, response (process) | Script 09 + Process |
| Posture and Vulnerability Management (PV) | Secure Score, assessments | Script 09 |
| Endpoint Security (ES) | VM security, antimalware | Scripts 02, 06 |
| Backup and Recovery (BR) | Backup config, policies, testing | Script 08 |
| DevOps Security (DS) | CI/CD security (external) | Not collected |
| Governance and Strategy (GS) | Policies, standards | Script 03 + Process |

### ISO 27001:2013 Controls

| ISO Control | Required Evidence | Source Scripts |
|-------------|-------------------|----------------|
| A.8 Asset Management | Resource inventory, ownership | Scripts 01, 02 |
| A.9 Access Control | RBAC, access policies | Script 04 |
| A.10 Cryptography | Encryption settings, Key Vault | Script 06 |
| A.12.3 Information Backup | Backup config, policies | Script 08 |
| A.12.4 Logging and Monitoring | Log retention, monitoring | Script 07 |
| A.13 Communications Security | Network config, firewalls, NSGs | Script 05 |
| A.17 Business Continuity | Backup, DR planning | Script 08 + Process |
| A.18 Compliance | Policy compliance, audit evidence | All scripts |

---

## Evidence Validation Checklist

For each compliance control, validate:

1. **Evidence Exists:**
   - [ ] Script collects the required data
   - [ ] Output file is generated
   - [ ] Data is not empty

2. **Evidence is Complete:**
   - [ ] All resources in scope are captured
   - [ ] All required properties are present
   - [ ] No collection errors occurred

3. **Evidence is Current:**
   - [ ] Collection date is recent
   - [ ] Data reflects current state
   - [ ] No stale cached data

4. **Evidence Meets Control:**
   - [ ] Data proves control is implemented (or not)
   - [ ] Configuration matches requirement
   - [ ] Gaps are identified

---

## Next Steps

1. **Create Control Mapping Matrix:**
   - Map each CIS control to specific evidence
   - Document which file and property to check
   - Define pass/fail criteria

2. **Build Compliance Scorecard:**
   - Automate status checking from collected JSON
   - Calculate compliance percentage
   - Generate gap report

3. **Develop Validation Scripts:**
   - Script to check if control is met
   - Automated compliance validation
   - Report generation

---

**Document Status:** Complete ✅  
**Next:** Build CIS Control Mapping Matrix  
**Owner:** Security Architecture Team


