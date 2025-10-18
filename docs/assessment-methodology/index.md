---
layout: default
title: Assessment Methodology
nav_order: 3
has_children: true
permalink: /assessment-methodology/
---

# Three-Dimensional Assessment Methodology

## The SecAI Framework Approach

The SecAI Framework evaluates Azure environments across three critical dimensions:

1. **Configuration Assessment** - Technical settings and deployed resources
2. **Process Assessment** - Operational procedures and governance
3. **Best Practices Assessment** - Alignment with industry frameworks

This methodology was developed through real-world assessment of enterprise Azure environments and is proven effective for:
- CSP to MCA migrations
- Azure Landing Zone validations  
- Compliance audit preparation
- Quarterly security assessments

---

## Dimension 1: Configuration Assessment

### Objective
Systematically collect evidence of deployed resources and security configurations.

### Method
Automated PowerShell + Python scripts executing Azure CLI and Resource Graph queries.

### Coverage: 12 Security Domains

1. **Network Security** - VNets, NSGs, Firewalls, Load Balancers, Private Endpoints
2. **Identity & Access Management** - RBAC, PIM, Azure AD
3. **Privileged Access** - Privileged role assignments, PIM usage
4. **Data Protection** - Encryption, Key Vault, TDE, storage security
5. **Asset Management** - Resource inventory, tagging, classification
6. **Logging & Threat Detection** - Log Analytics, Sentinel, diagnostics
7. **Incident Response** - Processes, playbooks, response capabilities
8. **Posture & Vulnerability** - Secure Score, recommendations
9. **Endpoint Security** - VM security, antimalware, patching
10. **Backup & Recovery** - Recovery vaults, policies, DR
11. **DevOps Security** - CI/CD security, IaC scanning
12. **Governance & Strategy** - Policies, compliance, standards

### Execution
```bash
cd implementation/2-Scripts/Collection
pwsh ./00_login.ps1
pwsh ./01_scope_discovery.ps1
pwsh ./02_inventory.ps1
pwsh ./03_policies_and_defender.ps1
pwsh ./04_identity_and_privileged_NO_AD_BYPASS_SSL.ps1
pwsh ./05_network_security.ps1
pwsh ./06_data_protection.ps1
pwsh ./07_logging_threat_detection.ps1
pwsh ./08_backup_recovery.ps1
pwsh ./09_posture_vulnerability.ps1
python ./10_evidence_counter.py
```

**Output:** 800+ JSON evidence files

**Time:** 3-4 hours automated execution

[View Collection Scripts](https://github.com/zimaxnet/secai-framework/tree/main/implementation/2-Scripts/Collection)

---

## Dimension 2: Process Assessment

### Objective
Evaluate operational maturity and governance effectiveness.

### Method
Structured interviews with technical teams and leadership, documentation review.

### Coverage: 8 Operational Domains

1. **Change Management** - How changes are approved and deployed
2. **Incident Response** - Security event handling and escalation
3. **Access Provisioning** - User onboarding/offboarding processes
4. **Patch Management** - Update deployment and testing
5. **Security Monitoring** - Alert triage and investigation
6. **Backup & Recovery** - DR testing and validation
7. **Compliance Management** - Policy enforcement and audit prep
8. **Vendor Management** - Third-party security oversight

### Maturity Model
5-level scoring: Initial → Managed → Defined → Quantitatively Managed → Optimizing

### Execution
Use structured interview templates with key personnel (2-4 hours per domain).

**Output:**
- Interview transcripts
- Process maturity scores
- Gap analysis by domain

**Time:** 8-16 hours interviews

[View Interview Templates](https://github.com/zimaxnet/secai-framework/tree/main/workspace/2-Process-Assessment-Work)

---

## Dimension 3: Best Practices Assessment

### Objective
Validate alignment with industry security frameworks and compliance standards.

### Method
Automated PowerShell validation modules comparing collected evidence against control requirements.

### Coverage: 5 Compliance Frameworks

1. **Microsoft Cloud Security Benchmark (MCSB)** - Native Azure framework
2. **CIS Controls v8** - Critical security controls
3. **NIST SP 800-53** - Government/enterprise standard
4. **PCI-DSS v3.2.1** - Payment card security
5. **CSA Cloud Controls Matrix (CCM)** - Cloud-specific controls

### Execution
```powershell
cd workspace/3-Best-Practices-Work
pwsh ./Validate-All-Frameworks.ps1 -DataPath "../../implementation/2-Scripts/out"
```

**Output:** 
- Compliance scores by framework
- Control pass/fail details
- Gap analysis reports
- Remediation priorities

**Time:** 5-10 minutes automated validation

[View Validation Modules](https://github.com/zimaxnet/secai-framework/tree/main/workspace/3-Best-Practices-Work)

---

## Recommended Execution Sequence

**Phase 1: Dimension 1 (Week 1)**
- Run all collection scripts (3-4 hours)
- Transform to CSV (30 minutes)
- Initial data review

**Phase 2: Dimension 3 (Week 1-2)**
- Run multi-framework validation (5-10 minutes)
- Review compliance scores
- Identify top gaps

**Phase 3: Dimension 2 (Week 2-3)**
- Use D3 findings to focus interviews
- Conduct structured interviews (8-16 hours)
- Score process maturity

**Phase 4: Reporting (Week 3-4)**
- Generate executive summary
- Create remediation roadmap
- Present findings

---

## Output Deliverables

### Configuration Evidence
- 800+ JSON files of Azure resource data
- CSV files for analysis
- Resource inventory spreadsheet

### Process Documentation
- Interview transcripts
- Process maturity scores
- Gap analysis by domain

### Compliance Reports
- Framework-specific scores (e.g., "CIS: 78% compliant")
- Control pass/fail details
- Prioritized remediation list

### Executive Summary
- Overall security posture rating
- Top 10 risks
- Remediation roadmap with timelines

---

## Real-World Validation

The SecAI Framework was validated through assessment of a confidential insurance services customer:

**Environment:**
- 34+ Azure subscriptions (CSP and MCA tenants)
- 5,000+ resources across Dev, Test, UAT, PreProd, Prod
- Complex security stack: Wiz, CrowdStrike, Cribl, Chronicle, Splunk
- Multi-environment logging architecture

**Results:**
- 800+ evidence files collected
- Compliance scores across 5 frameworks
- 200+ findings identified
- Prioritized remediation roadmap delivered

**Timeline:**
- Week 1: Dimension 1 execution
- Week 2: Dimension 3 validation, interviews begin
- Week 3: Complete Dimension 2 interviews
- Week 4: Report generation and presentation

---

## Comparison with Traditional Assessments

| Aspect | Traditional Assessment | SecAI Framework |
|--------|----------------------|-----------------|
| **Scope** | Single dimension (config OR process) | Three dimensions (config + process + best practices) |
| **Automation** | Mostly manual | 80% automated (D1 + D3) |
| **Frameworks** | Single framework focus | Multi-framework (5 frameworks) |
| **Evidence** | Sample-based | Comprehensive (800+ files) |
| **Timeline** | 6-8 weeks | 2-4 weeks |
| **Repeatability** | Manual, varies by assessor | Automated, consistent |
| **Cost** | High consulting fees | Open source + internal labor |

---

## Best Practices for Execution

### Before Starting
1. Obtain proper authorization from Azure tenant owner
2. Document scope and objectives
3. Set up data storage location (10GB+)
4. Test Azure CLI connectivity
5. Verify RBAC permissions

### During Execution
1. Run scripts during off-hours (lower Azure API load)
2. Monitor script progress and logs
3. Save evidence files securely
4. Don't modify scripts mid-execution
5. Document any errors or issues

### After Completion
1. Backup all evidence files
2. Review data quality and completeness
3. Run validation checks
4. Generate preliminary findings
5. Schedule stakeholder review

---

## Integration with Azure Landing Zones

The SecAI Framework aligns with Azure Landing Zone architecture:

**Platform Subscriptions:**
- Identity subscription assessment
- Management subscription assessment
- Connectivity (hub) subscription assessment

**Landing Zone Subscriptions:**
- Corp (internal) subscription assessment
- Online (external) subscription assessment

**Validation Against ALZ Policies:**
- Policy compliance checking
- Configuration drift detection
- Baseline alignment verification

---

## Continuous Assessment

The framework supports ongoing security monitoring:

**Quarterly Assessments:**
- Rerun Dimension 1 scripts quarterly
- Track changes over time
- Monitor compliance score trends
- Identify new risks

**Monthly Spot Checks:**
- Run specific domain scripts (e.g., Network, Identity)
- Quick compliance validation
- Targeted reviews

**Continuous Monitoring:**
- Azure Policy continuous compliance
- Microsoft Defender for Cloud alerts
- Log Analytics queries for anomalies

---

**Last Updated**: October 18, 2025  
**Status**: Production Ready  
**Framework Version**: 2.0

