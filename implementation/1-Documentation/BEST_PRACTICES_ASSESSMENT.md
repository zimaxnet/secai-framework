# Best Practices Assessment Guide

**SecAI Framework - Dimension 3**

---

## Overview

Best Practices Assessment evaluates **alignment with industry standards, compliance frameworks, and security benchmarks**. This dimension answers the question: "How does our Azure environment compare to established best practices and what others are doing?"

---

## What is Best Practices Assessment?

Best practices assessment provides **external benchmarking** against:

- Industry security frameworks (CIS, NIST, ISO)
- Microsoft recommendations (Azure Well-Architected, Cloud Security Benchmark)
- Regulatory requirements (HIPAA, PCI-DSS, SOC 2)
- Peer comparisons and industry trends
- Vendor best practices

**Key Principle:** Best practices assessment provides **context and validation** - it confirms whether your security posture meets external standards and identifies where you fall short.

---

## Why Best Practices Matter

### Configuration + Process ≠ Complete Picture

- **Configuration** tells you *what is deployed*
- **Process** tells you *how it's managed*
- **Best Practices** tell you *if it's good enough*

**Example:**

✅ **Configuration:** Azure Firewall deployed with 200 rules  
✅ **Process:** Rules reviewed monthly, changes require approval  
❓ **Best Practice:** Are the firewall rules aligned with CIS Benchmark? Are they following least privilege? How do they compare to industry standards?

Without best practices assessment, you might have perfect execution of a suboptimal approach.

---

## Security Frameworks

### CIS Azure Foundations Benchmark

**Overview:** Consensus-driven security configuration best practices

**Latest Version:** CIS Microsoft Azure Foundations Benchmark v2.0

**Coverage Areas:**
1. Identity and Access Management
2. Microsoft Defender for Cloud
3. Storage Accounts
4. Database Services
5. Logging and Monitoring
6. Networking
7. Virtual Machines
8. Key Vault
9. AppService
10. Other Security Considerations

**Assessment Method:**
- Azure Policy compliance dashboard
- Defender for Cloud regulatory compliance
- Manual control validation
- Automated scanning tools

**Example Controls:**

| Control | Description | Common Findings |
|---------|-------------|-----------------|
| 1.1 | Ensure MFA is enabled for all users | Often not enforced |
| 2.1 | Ensure that Defender for Cloud Standard tier is selected | Frequently on Free tier |
| 3.1 | Ensure storage account encryption is enabled | Usually compliant |
| 5.1.1 | Ensure Activity Log retention is at least 365 days | Often 90 days or less |
| 6.1 | Ensure Network Security Groups are configured | Varies widely |

**Scoring:**
- **Level 1:** Basic security (mandatory)
- **Level 2:** Defense-in-depth (recommended)

**Target:** 90%+ compliance for Level 1, 80%+ for Level 2

---

### NIST Cybersecurity Framework

**Overview:** Framework for improving critical infrastructure cybersecurity

**5 Core Functions:**

1. **Identify** - Asset management, risk assessment
2. **Protect** - Access control, data security
3. **Detect** - Anomalies and events
4. **Respond** - Response planning, communications
5. **Recover** - Recovery planning, improvements

**Assessment Method:**
- Control mapping from Azure configurations
- Process alignment review
- Maturity assessment per function
- Gap analysis

**Maturity Levels:**
- **Tier 1:** Partial - Informal, reactive
- **Tier 2:** Risk Informed - Risk management practices approved but not policy
- **Tier 3:** Repeatable - Formal policies, procedures implemented
- **Tier 4:** Adaptive - Continuous improvement, predictive

**Example Mapping:**

| NIST Function | SecAI Collection | Assessment |
|---------------|------------------|------------|
| Identify | Script 02 (Inventory) | Asset inventory complete? |
| Protect | Scripts 04-06 (Identity, Network, Data) | Controls implemented? |
| Detect | Script 07 (Logging, Sentinel) | Monitoring configured? |
| Respond | Process assessment | Incident response plan? |
| Recover | Script 08 (Backup) | Backup and DR in place? |

---

### Microsoft Cloud Security Benchmark (MCSB)

**Overview:** Microsoft's security recommendations for Azure

**Previously:** Azure Security Benchmark (ASB)

**Coverage:** 14 security domains aligned with common frameworks

**Domains:**
1. Network Security
2. Identity Management
3. Privileged Access
4. Data Protection
5. Asset Management
6. Logging and Threat Detection
7. Incident Response
8. Posture and Vulnerability Management
9. Endpoint Security
10. Backup and Recovery
11. DevOps Security
12. Governance and Strategy
13. Application Security
14. Data Recovery

**Assessment Method:**
- Defender for Cloud Regulatory Compliance dashboard
- Direct mapping to Azure Policy
- Automated compliance scoring
- Recommendation tracking

**Target:** 80%+ compliance across all domains

---

### Azure Well-Architected Framework (Security Pillar)

**Overview:** Microsoft's architectural best practices

**5 Pillars:**
1. Cost Optimization
2. Operational Excellence
3. Performance Efficiency
4. Reliability
5. **Security** ← Our focus

**Security Pillar Principles:**

1. **Plan your security readiness**
   - Define security requirements
   - Establish governance
   - Create security culture

2. **Design to protect confidentiality**
   - Data classification
   - Encryption
   - Access controls

3. **Design to protect integrity**
   - Prevent unauthorized changes
   - Validate authenticity
   - Audit all access

4. **Design to protect availability**
   - DDoS protection
   - High availability
   - Disaster recovery

5. **Sustain and evolve your security posture**
   - Continuous monitoring
   - Threat intelligence
   - Incident response
   - Security training

**Assessment Method:**
- Well-Architected Review (official Microsoft tool)
- Architecture review sessions
- Control validation
- Recommendations prioritization

---

### ISO 27001 Controls

**Overview:** International standard for information security management

**Relevant for:** Organizations with ISO 27001 certification or seeking it

**Control Categories:**
- A.5: Information Security Policies
- A.6: Organization of Information Security
- A.7: Human Resource Security
- A.8: Asset Management
- A.9: Access Control
- A.10: Cryptography
- A.11: Physical and Environmental Security
- A.12: Operations Security
- A.13: Communications Security
- A.14: System Acquisition, Development and Maintenance
- A.15: Supplier Relationships
- A.16: Information Security Incident Management
- A.17: Business Continuity Management
- A.18: Compliance

**Azure Mapping:**

| ISO Control | Azure Equivalent | SecAI Evidence |
|-------------|------------------|----------------|
| A.9.1 Access control policy | RBAC, PIM, Conditional Access | Script 04 (Identity) |
| A.10.1 Cryptographic controls | Storage encryption, Key Vault | Script 06 (Data Protection) |
| A.12.4 Logging and monitoring | Log Analytics, Sentinel | Script 07 (Logging) |
| A.13.1 Network security | NSGs, Firewalls, VNets | Script 05 (Network) |
| A.17.1 Business continuity | Backup, DR | Script 08 (Backup) |

---

## Regulatory Compliance

### HIPAA (Healthcare)

**Relevant Azure Services:**
- Azure Policy for HIPAA compliance
- Defender for Cloud HIPAA dashboard
- Encrypted storage and databases
- Audit logging

**Key Requirements:**
- Access controls (164.308)
- Audit controls (164.312)
- Integrity controls (164.312)
- Transmission security (164.312)

### PCI-DSS (Payment Card Industry)

**Relevant for:** Organizations handling credit card data

**Key Requirements:**
- Network segmentation
- Access controls
- Encryption of cardholder data
- Vulnerability management
- Logging and monitoring

**Azure Mapping:**
- NSGs for segmentation (Script 05)
- Storage encryption (Script 06)
- Key Vault for keys (Script 06)
- Log Analytics (Script 07)

### SOC 2 (Service Organization Control)

**Trust Service Criteria:**
- Security
- Availability
- Processing Integrity
- Confidentiality
- Privacy

**Azure Evidence:**
- Azure certifications (Microsoft SOC 2 reports)
- Customer responsibility matrix
- Security controls implementation
- Audit logs and monitoring

---

## Best Practices Assessment Process

### Step 1: Identify Applicable Frameworks

**Questions:**
- What industry are you in? (Healthcare, Finance, Government, etc.)
- What regulations apply? (HIPAA, PCI-DSS, FedRAMP, etc.)
- What certifications do you need? (ISO 27001, SOC 2, etc.)
- What frameworks does leadership require? (NIST, CIS, etc.)

**Output:** List of frameworks to assess against

---

### Step 2: Collect Framework Evidence

**Data Sources:**

1. **Azure Defender for Cloud**
   - Regulatory Compliance dashboard
   - Pre-built frameworks: CIS, PCI-DSS, ISO 27001, NIST 800-53, etc.
   - Compliance percentage per framework
   - Non-compliant resources

2. **SecAI Configuration Data**
   - Scripts 01-09 provide technical evidence
   - Map controls to collected data
   - Validate configurations against standards

3. **Process Documentation**
   - SOPs, runbooks map to process controls
   - Incident response plan validates IR requirements
   - Access management procedures validate identity controls

4. **Third-Party Assessments**
   - Penetration tests
   - Vulnerability scans
   - External audits

**Output:** Evidence matrix mapping controls to collected data

---

### Step 3: Map Controls to Evidence

**Example Control Mapping:**

| Framework | Control | Description | Azure Evidence | SecAI Script |
|-----------|---------|-------------|----------------|--------------|
| CIS | 1.23 | MFA for all users | Conditional Access policies | Script 04 |
| CIS | 3.1 | Storage encryption | Storage account properties | Script 06 |
| CIS | 5.1.1 | Activity log retention | Diagnostic settings | Script 07 |
| CIS | 6.1 | NSGs on subnets | NSG configurations | Script 05 |
| NIST | PR.AC-4 | Least privilege | RBAC assignments | Script 04 |
| NIST | PR.DS-1 | Data at rest encryption | Storage & SQL encryption | Script 06 |
| NIST | DE.AE-3 | Event correlation | Sentinel, Log Analytics | Script 07 |

---

### Step 4: Calculate Compliance Scores

**Scoring Method:**

For each framework:
```
Compliance % = (Compliant Controls / Total Controls) × 100
```

**Control Status:**
- ✅ **Compliant:** Control fully implemented and validated
- ⚠️ **Partial:** Control partially implemented, gaps exist
- ❌ **Non-Compliant:** Control not implemented
- ⊘ **Not Applicable:** Control doesn't apply to environment

**Example Scorecard:**

| Framework | Total Controls | Compliant | Partial | Non-Compliant | Score |
|-----------|----------------|-----------|---------|---------------|-------|
| CIS Azure Benchmark | 78 | 45 | 20 | 13 | 58% |
| NIST CSF | 108 | 70 | 25 | 13 | 65% |
| MCSB | 156 | 95 | 40 | 21 | 61% |
| ISO 27001 (relevant) | 45 | 30 | 10 | 5 | 67% |

**Targets:**
- **Production:** 80%+ compliance
- **Pre-Production:** 70%+ compliance
- **Development:** 60%+ compliance

---

### Step 5: Identify Gaps

**Gap Types:**

1. **Technical Gaps** (Configuration)
   - Missing security controls
   - Misconfigured resources
   - Non-compliant settings

2. **Process Gaps**
   - Missing procedures
   - Undocumented workflows
   - No periodic reviews

3. **Documentation Gaps**
   - Policies not written
   - Runbooks incomplete
   - Training materials missing

**Gap Prioritization:**

| Priority | Criteria | Example |
|----------|----------|---------|
| **Critical** | Regulatory violation, high risk | No encryption on healthcare data |
| **High** | CIS Level 1, exploitable | No NSGs on production subnets |
| **Medium** | CIS Level 2, defense in depth | Activity log retention < 365 days |
| **Low** | Nice to have, minimal risk | Inconsistent tagging |

---

### Step 6: Create Remediation Roadmap

**Roadmap Structure:**

**Phase 1: Critical Gaps (0-30 days)**
- Address regulatory violations
- Fix high-risk configurations
- Implement missing critical controls

**Phase 2: High Priority (30-90 days)**
- Implement CIS Level 1 controls
- Address exploitable vulnerabilities
- Improve logging and monitoring

**Phase 3: Medium Priority (90-180 days)**
- Implement CIS Level 2 controls
- Enhance defense-in-depth
- Improve process documentation

**Phase 4: Low Priority (180-365 days)**
- Optimize configurations
- Implement nice-to-have controls
- Continuous improvement

**Example Roadmap:**

| Phase | Control | Effort | Owner | Status |
|-------|---------|--------|-------|--------|
| 1 | Enable storage encryption | 2 weeks | Security | In Progress |
| 1 | Deploy NSGs to all subnets | 3 weeks | Network | Not Started |
| 2 | Increase log retention to 365 days | 1 week | Operations | Not Started |
| 2 | Implement quarterly access reviews | 2 weeks | Identity | Not Started |
| 3 | Deploy Azure Firewall to dev/test | 4 weeks | Network | Not Started |

---

## Best Practices by Domain

### Identity and Access Management

**CIS Recommendations:**
- ✅ MFA for all users
- ✅ Guest users reviewed periodically
- ✅ Privileged accounts use PIM
- ✅ Service principals use managed identities where possible
- ✅ RBAC follows least privilege

**Azure Best Practices:**
- Use Entra ID (Azure AD) exclusively
- Implement Conditional Access policies
- Time-bound privileged access with PIM
- Regular access reviews (quarterly)
- Disable unused accounts

**Common Gaps:**
- MFA not enforced universally
- Too many Owner role assignments
- No periodic access reviews
- Service principals with static credentials

---

### Network Security

**CIS Recommendations:**
- ✅ NSGs on all subnets
- ✅ Default deny rules
- ✅ No unrestricted internet access (0.0.0.0/0)
- ✅ Azure Firewall or NVA deployed
- ✅ Network segmentation implemented

**Azure Best Practices:**
- Hub-spoke network topology
- Azure Firewall in hub
- Private Endpoints for PaaS services
- DDoS Protection Standard
- Network Watcher enabled

**Common Gaps:**
- NSGs not on all subnets
- Overly permissive rules
- No centralized firewall
- Flat network (no segmentation)
- Public endpoints exposed

---

### Data Protection

**CIS Recommendations:**
- ✅ Storage accounts encrypted at rest
- ✅ SQL TDE enabled
- ✅ Key Vault for secrets
- ✅ Soft delete enabled
- ✅ Purge protection enabled

**Azure Best Practices:**
- Customer-managed keys (CMK) for sensitive data
- Key Vault with RBAC (not access policies)
- Storage account firewall configured
- SQL Advanced Threat Protection
- Data classification and labeling

**Common Gaps:**
- Storage accounts without soft delete
- Key Vaults without purge protection
- SQL without Advanced Threat Protection
- Unencrypted databases

---

### Logging and Monitoring

**CIS Recommendations:**
- ✅ Activity log retention ≥ 365 days
- ✅ Diagnostic settings on all resources
- ✅ Log Analytics Workspace deployed
- ✅ Security alerts configured
- ✅ Log queries for threat detection

**Azure Best Practices:**
- Centralized logging to single workspace
- Sentinel for SIEM capabilities
- Alerting on critical events
- Log Export for long-term retention
- Integration with SOC

**Common Gaps:**
- Logs not centralized
- Retention < 365 days
- No active monitoring
- Alerts not configured
- Sentinel not deployed

---

### Backup and Recovery

**CIS Recommendations:**
- ✅ Backup configured for critical resources
- ✅ Backup policies defined
- ✅ Regular restore testing
- ✅ Immutable backups
- ✅ Cross-region backup

**Azure Best Practices:**
- Recovery Services Vaults with soft delete
- Backup policies aligned to RPO/RTO
- Quarterly restore testing
- DR plan documented and tested
- Backup monitoring and alerting

**Common Gaps:**
- No restore testing
- Backup policies don't meet RPO/RTO
- No cross-region backup
- DR plan not documented
- Critical resources not backed up

---

## Best Practices Assessment Deliverables

### 1. Compliance Scorecard

Summary table:
- Framework name
- Total controls assessed
- Compliance percentage
- Top gaps
- Target score
- Timeline to target

### 2. Control Coverage Matrix

Detailed mapping:
- Framework control ID
- Control description
- Implementation status
- Evidence source
- Gap description (if any)
- Remediation action

### 3. Gap Analysis Report

For each gap:
- Control description
- Current state
- Desired state
- Risk if not remediated
- Remediation effort estimate
- Priority
- Owner

### 4. Remediation Roadmap

Phased plan:
- Phase 1-4 with timelines
- Controls to remediate
- Effort and owner
- Dependencies
- Success criteria

### 5. Executive Summary

High-level overview:
- Overall compliance posture
- Key strengths
- Critical gaps
- Investment required
- Risk mitigation

---

## Best Practices Assessment Tools

### Azure Native Tools

1. **Defender for Cloud Regulatory Compliance**
   - Pre-built frameworks (CIS, ISO, PCI-DSS, etc.)
   - Automated compliance scoring
   - Drill-down to non-compliant resources

2. **Azure Policy**
   - Custom policy definitions
   - Policy initiatives (sets)
   - Compliance dashboard

3. **Microsoft Secure Score**
   - Security posture score
   - Improvement actions
   - Trend analysis

4. **Azure Advisor**
   - Security recommendations
   - Best practice guidance
   - Cost optimization

### Third-Party Tools

1. **Prowler** (Open Source)
   - CIS Benchmark scanning
   - Multi-cloud support
   - Automated reporting

2. **CloudSploit** (Open Source)
   - Security scanning
   - Configuration checks
   - Compliance reporting

3. **Wiz, Prisma Cloud, Crowdstrike** (Commercial)
   - Comprehensive security posture management
   - Continuous compliance monitoring
   - Advanced threat detection

---

## Continuous Compliance

### Ongoing Monitoring

**Daily:**
- Defender for Cloud secure score
- New security alerts
- Policy compliance changes

**Weekly:**
- Compliance scorecard review
- New vulnerabilities
- Remediation progress

**Monthly:**
- Full compliance report
- Trend analysis
- Remediation plan updates

**Quarterly:**
- Framework re-assessment
- Process reviews
- Executive reporting

### Automation

**Azure Policy:**
- Deny non-compliant deployments
- Auto-remediate known issues
- Enforce compliance at creation

**Azure DevOps / GitHub Actions:**
- IaC compliance scanning
- Pre-deployment validation
- Continuous compliance testing

---

## Best Practices Assessment Success Criteria

✅ **All applicable frameworks identified**  
✅ **Evidence collected and mapped to controls**  
✅ **Compliance scores calculated**  
✅ **Gaps prioritized by risk**  
✅ **Remediation roadmap created with owners and timelines**  
✅ **Executive summary delivered**  
✅ **Continuous monitoring established**  

---

## Integration with Other Dimensions

Best practices assessment **validates and contextualizes** configuration and process:

| Dimension | Question | Best Practice Adds |
|-----------|----------|-------------------|
| Configuration | "Are NSGs deployed?" | "Do NSG rules align with CIS Benchmark deny-by-default?" |
| Process | "Are access reviews performed?" | "Are quarterly reviews sufficient per NIST guidelines?" |
| Both | "Backups configured and tested monthly" | "Does this meet ISO 27001 requirements for critical systems?" |

---

## Conclusion

Best Practices Assessment ensures your Azure environment meets external standards and industry expectations. Combined with Configuration Assessment (what exists) and Process Assessment (how it's managed), it provides a **complete, defensible security posture**.

---

**See Also:**
- `CONFIGURATION_ASSESSMENT.md` - Dimension 1
- `PROCESS_ASSESSMENT.md` - Dimension 2
- `FRAMEWORK_OVERVIEW.md` - Complete framework overview

---

**Framework Version:** 2.0  
**Last Updated:** October 17, 2025

