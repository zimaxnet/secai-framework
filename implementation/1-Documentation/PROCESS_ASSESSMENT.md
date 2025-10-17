# Process Assessment Guide

**SecAI Framework - Dimension 2**

---

## Overview

Process Assessment focuses on **how operations are managed**, **how decisions are made**, and **how security is operationalized** in the Azure environment. Unlike configuration assessment (which is fully automated), process assessment requires **human interaction, interviews, and documentation review**.

---

## What is Process Assessment?

Process assessment evaluates the **operational maturity** of security practices:

- Change management procedures
- Incident response workflows
- Access provisioning processes
- Security review cadences
- Approval workflows
- Documentation practices
- Communication channels
- Training and awareness

**Key Principle:** Process assessment is **qualitative and contextual** - it evaluates not just if processes exist, but if they are effective, documented, followed, and continuously improved.

---

## Why Process Matters

### Configuration vs. Process

| Configuration Assessment | Process Assessment |
|-------------------------|-------------------|
| Azure Firewall is deployed | How are firewall rules approved and deployed? |
| Backup is configured | How often is restore tested? Who performs it? |
| RBAC roles assigned | How is access requested, approved, and reviewed? |
| Defender for Cloud enabled | Who reviews alerts? What is response time? |
| Diagnostic settings configured | Who monitors logs? What is escalation procedure? |

**Example Scenario:**

✅ **Good Configuration, Poor Process:**
- Azure Policy enforces NSG on all subnets (configuration is correct)
- No documented process for reviewing NSG rules
- Changes made ad-hoc without approval
- No periodic review of rules
- **Result:** Configuration drift, security gaps over time

✅ **Ideal State:**
- Azure Policy enforces NSG on all subnets (configuration)
- Change management process for NSG rules (process)
- Monthly review of all NSG rules (process)
- Documentation and approval required (process)
- **Result:** Sustained security posture

---

## Process Assessment Methodology

### Data Collection Methods

1. **Interviews**
   - Operations teams
   - Security teams
   - Network teams
   - Identity teams
   - Management

2. **Documentation Review**
   - SOPs and runbooks
   - Change management procedures
   - Incident response plans
   - Access request forms
   - Approval matrices

3. **Observation**
   - Review actual workflows
   - Examine ticketing systems
   - Check audit logs
   - Review communication channels

4. **Evidence Collection**
   - Screenshots of workflows
   - Sample tickets/requests
   - Approval emails
   - Meeting notes
   - Training materials

---

## Process Assessment Domains

### 1. Change Management

**Objective:** Evaluate how changes are proposed, approved, tested, and deployed

**Questions to Ask:**

- **Planning:**
  - How are changes proposed?
  - Who approves changes?
  - What is the approval process?
  - Are changes risk-assessed?

- **Testing:**
  - Is there a test environment?
  - Are changes tested before production?
  - Who performs testing?
  - What are test criteria?

- **Deployment:**
  - How are changes deployed?
  - Is there a rollback plan?
  - Who has deployment authority?
  - Are changes documented?

- **Communication:**
  - How are stakeholders notified?
  - Is there a change calendar?
  - Are changes coordinated?
  - What is the communication timeline?

**Evidence to Collect:**
- Change request template
- Approval workflow diagram
- Sample approved changes
- Deployment runbook
- Change calendar

**Maturity Levels:**

| Level | Description |
|-------|-------------|
| **1 - Ad Hoc** | No formal process, changes made as needed |
| **2 - Documented** | Process documented but not always followed |
| **3 - Managed** | Process followed, approvals required, tracked |
| **4 - Measured** | Process metrics tracked, KPIs monitored |
| **5 - Optimized** | Continuous improvement, automation, predictive |

**Common Gaps:**
- ❌ No formal change management process
- ❌ Approvals bypassed for "urgent" changes
- ❌ No testing in dev/test before production
- ❌ Changes not documented
- ❌ No rollback plan

---

### 2. Incident Response

**Objective:** Evaluate how security incidents are detected, responded to, and resolved

**Questions to Ask:**

- **Detection:**
  - How are incidents detected?
  - Who monitors security alerts?
  - What is response time SLA?
  - Are alerts prioritized?

- **Response:**
  - What is the incident response plan?
  - Who is on the incident response team?
  - What are escalation procedures?
  - How is containment performed?

- **Resolution:**
  - How are incidents investigated?
  - What tools are used?
  - How is root cause determined?
  - How is remediation performed?

- **Post-Incident:**
  - Are post-mortems conducted?
  - Are lessons learned documented?
  - Are processes improved?
  - Is training updated?

**Evidence to Collect:**
- Incident response plan
- Escalation matrix
- Sample incident tickets
- Post-mortem reports
- Playbooks and runbooks

**Maturity Assessment:**

| Capability | Maturity |
|------------|----------|
| Incident detection | ⚪ None / 🟡 Manual / 🟢 Automated |
| Response time | ⚪ No SLA / 🟡 > 4 hours / 🟢 < 1 hour |
| Playbooks | ⚪ None / 🟡 Some / 🟢 Comprehensive |
| Post-mortems | ⚪ Never / 🟡 Sometimes / 🟢 Always |
| Continuous improvement | ⚪ None / 🟡 Ad hoc / 🟢 Systematic |

**Common Gaps:**
- ❌ No documented incident response plan
- ❌ Security alerts not monitored 24/7
- ❌ No defined escalation procedures
- ❌ Post-mortems not conducted
- ❌ Lessons learned not implemented

---

### 3. Access Management

**Objective:** Evaluate how access is requested, approved, provisioned, and reviewed

**Questions to Ask:**

- **Provisioning:**
  - How is access requested?
  - Who approves access requests?
  - How long does provisioning take?
  - Is just-in-time (JIT) access used?

- **Review:**
  - Are access rights reviewed periodically?
  - Who performs access reviews?
  - What is the review frequency?
  - How are findings remediated?

- **Deprovisioning:**
  - How is access revoked?
  - Are departures handled promptly?
  - Is there an offboarding checklist?
  - Are service accounts reviewed?

- **Privileged Access:**
  - How is privileged access managed?
  - Is PIM (Privileged Identity Management) used?
  - Are privileged actions logged?
  - Is privileged access time-bound?

**Evidence to Collect:**
- Access request form
- Approval workflow
- Access review reports
- Offboarding checklist
- PIM configuration

**KPIs to Track:**
- Average time to provision access
- Percentage of access requests approved
- Frequency of access reviews
- Time to revoke access on departure
- Privileged access usage

**Common Gaps:**
- ❌ Access requests not tracked
- ❌ No periodic access reviews
- ❌ Departures not processed promptly
- ❌ Privileged access not time-bound
- ❌ Service accounts not reviewed

---

### 4. Vulnerability Management

**Objective:** Evaluate how vulnerabilities are identified, assessed, and remediated

**Questions to Ask:**

- **Identification:**
  - How are vulnerabilities discovered?
  - What scanning tools are used?
  - What is scan frequency?
  - Are scans automated?

- **Assessment:**
  - How are vulnerabilities prioritized?
  - Who assesses vulnerabilities?
  - What is risk rating criteria?
  - Are compensating controls considered?

- **Remediation:**
  - What is remediation SLA by severity?
  - Who is responsible for remediation?
  - How is remediation tracked?
  - Is remediation validated?

- **Reporting:**
  - Are vulnerability metrics tracked?
  - Who receives vulnerability reports?
  - What is reporting frequency?
  - Are trends analyzed?

**Evidence to Collect:**
- Vulnerability scan reports
- Remediation SLA documentation
- Vulnerability tracking dashboard
- Sample remediation tickets
- Trend reports

**Remediation SLAs (Example):**

| Severity | SLA | Typical |
|----------|-----|---------|
| Critical | 7 days | 30 days |
| High | 30 days | 90 days |
| Medium | 90 days | 180 days |
| Low | 180 days | Best effort |

**Common Gaps:**
- ❌ No regular vulnerability scanning
- ❌ Vulnerabilities not prioritized
- ❌ No defined remediation SLAs
- ❌ Remediation not tracked
- ❌ No metrics or reporting

---

### 5. Patch Management

**Objective:** Evaluate how systems are patched and updated

**Questions to Ask:**

- **Planning:**
  - What is the patching cadence?
  - Are patches tested before deployment?
  - Is there a patch management calendar?
  - Are emergency patches handled differently?

- **Deployment:**
  - How are patches deployed?
  - Is patching automated?
  - Are systems rebooted as needed?
  - Is rollback available?

- **Verification:**
  - How is patch compliance verified?
  - What is the compliance target?
  - Are exceptions documented?
  - How are non-compliant systems handled?

**Evidence to Collect:**
- Patch management policy
- Patching schedule
- Compliance reports
- Exception documentation

**Patching Maturity:**

| Maturity | Description |
|----------|-------------|
| **Low** | Ad-hoc patching, no schedule, manual |
| **Medium** | Regular schedule, some automation, 80%+ compliance |
| **High** | Automated patching, testing, 95%+ compliance, rapid emergency patches |

**Common Gaps:**
- ❌ No regular patching schedule
- ❌ Patches not tested before deployment
- ❌ No patch compliance tracking
- ❌ Emergency patches delayed
- ❌ Systems chronically out of date

---

### 6. Logging and Monitoring

**Objective:** Evaluate how logs are collected, monitored, and used

**Questions to Ask:**

- **Collection:**
  - What logs are collected?
  - Are logs centralized?
  - What is log retention?
  - Are logs tamper-proof?

- **Monitoring:**
  - Who monitors logs?
  - What is monitoring frequency?
  - Are alerts configured?
  - What is alert response time?

- **Analysis:**
  - Are logs analyzed for threats?
  - What tools are used?
  - Are baselines established?
  - Are anomalies detected?

- **Reporting:**
  - Are log reports generated?
  - Who receives reports?
  - What is reporting frequency?
  - Are metrics tracked?

**Evidence to Collect:**
- Logging architecture diagram
- Log retention policy
- Alert configuration
- Sample security reports
- Log review procedures

**Common Gaps:**
- ❌ Logs not centralized
- ❌ No one actively monitoring logs
- ❌ Alerts not configured
- ❌ Insufficient log retention
- ❌ No log analysis performed

---

### 7. Backup and Recovery

**Objective:** Evaluate backup processes and disaster recovery capabilities

**Questions to Ask:**

- **Backup:**
  - What is backed up?
  - What is backup frequency?
  - Are backups tested?
  - Are backups encrypted?

- **Restore:**
  - How often are restores tested?
  - Who can perform restores?
  - What is RTO (Recovery Time Objective)?
  - What is RPO (Recovery Point Objective)?

- **Disaster Recovery:**
  - Is there a DR plan?
  - When was DR last tested?
  - Are DR drills conducted?
  - Is DR documentation current?

**Evidence to Collect:**
- Backup policy
- Restore test results
- DR plan document
- DR drill reports
- RTO/RPO documentation

**Backup Testing Frequency:**

| Asset Type | Test Frequency | Industry Standard |
|------------|----------------|-------------------|
| Critical systems | Monthly | Best practice |
| Production systems | Quarterly | Minimum |
| Non-critical systems | Annually | Acceptable |

**Common Gaps:**
- ❌ Backups not tested regularly
- ❌ No documented RTO/RPO
- ❌ DR plan outdated or non-existent
- ❌ DR never tested
- ❌ Backup restore procedures unclear

---

### 8. Security Awareness Training

**Objective:** Evaluate security training and awareness programs

**Questions to Ask:**

- **Training:**
  - Is security training provided?
  - What is training frequency?
  - Is training mandatory?
  - Is completion tracked?

- **Awareness:**
  - Are security communications sent?
  - Are phishing simulations conducted?
  - Are security champions designated?
  - Is security promoted culturally?

**Evidence to Collect:**
- Training materials
- Completion reports
- Phishing simulation results
- Security awareness communications

**Common Gaps:**
- ❌ No mandatory security training
- ❌ Training outdated or generic
- ❌ No phishing simulations
- ❌ Security not part of culture

---

## Process Assessment Deliverables

### 1. Process Maturity Assessment

For each domain, provide:
- Current maturity level (1-5)
- Strengths
- Gaps
- Recommendations
- Target maturity level

### 2. Process Documentation Inventory

List of all process documents:
- SOPs and runbooks
- Incident response plans
- Change management procedures
- Access request forms
- Approval matrices

**Status for each:**
- ✅ Exists and current
- ⚠️ Exists but outdated
- ❌ Does not exist

### 3. Gap Analysis

Comparison of:
- Current process vs. desired process
- Documented process vs. actual practice
- Industry best practices vs. current state

### 4. Recommendations

Prioritized list of:
- Process improvements needed
- Documentation to create/update
- Training requirements
- Tool/automation opportunities

---

## Process Assessment Interview Guide

### Sample Questions by Role

**Operations Team:**
- Walk me through a typical change deployment
- How do you handle emergency changes?
- What tools do you use daily?
- Where is documentation kept?

**Security Team:**
- How do you receive security alerts?
- What is your typical response time?
- How do you prioritize incidents?
- Who do you escalate to?

**Network Team:**
- How are firewall rules requested?
- Who approves network changes?
- How often are NSG rules reviewed?
- How is network segmentation maintained?

**Identity Team:**
- How long does access provisioning take?
- How often are access reviews performed?
- How is privileged access managed?
- What is the offboarding process?

**Management:**
- How is security prioritized?
- What are security KPIs?
- How often are security metrics reviewed?
- What is the budget for security improvements?

---

## Process Assessment Success Criteria

✅ **Interviews completed** with all key teams  
✅ **Documentation reviewed** (SOPs, runbooks, policies)  
✅ **Evidence collected** (screenshots, samples, reports)  
✅ **Maturity assessed** for each domain  
✅ **Gaps identified** with prioritization  
✅ **Recommendations provided** with actionable next steps  

---

## Common Process Anti-Patterns

### "We'll Document It Later"
- Process exists in people's heads
- Not written down
- Tribal knowledge
- **Risk:** Knowledge loss, inconsistency

### "We Don't Have Time"
- Process exists but bypassed for speed
- "Emergency" exception becomes normal
- **Risk:** Uncontrolled changes, security gaps

### "We've Always Done It This Way"
- Process outdated but not updated
- Doesn't align with current needs
- **Risk:** Inefficiency, doesn't prevent modern threats

### "We Don't Need a Process for That"
- Ad-hoc handling of critical activities
- No consistency or accountability
- **Risk:** Mistakes, gaps, finger-pointing

---

## Integrating Process with Configuration

Configuration assessment shows **what exists**.  
Process assessment shows **how it's managed**.

**Example Integration:**

| Configuration Finding | Process Question | Integrated Recommendation |
|-----------------------|------------------|---------------------------|
| 50 NSG rules on production subnet | How are NSG rules reviewed? | Implement monthly NSG rule review process |
| 200+ RBAC role assignments | How are access reviews performed? | Establish quarterly access review process |
| Defender alerts enabled | Who monitors alerts? What is SLA? | Create 24/7 SOC or managed service |
| Backups configured | How often are restores tested? | Implement quarterly restore testing |

---

## Next Steps

After process assessment:

1. **Review findings** with operations teams
2. **Prioritize process improvements** based on risk and maturity
3. **Create process documentation** where missing
4. **Update existing documentation** where outdated
5. **Define KPIs** for process effectiveness
6. **Proceed to Best Practices Assessment** (Dimension 3)

---

**See Also:**
- `CONFIGURATION_ASSESSMENT.md` - Dimension 1
- `BEST_PRACTICES_ASSESSMENT.md` - Dimension 3
- `FRAMEWORK_OVERVIEW.md` - Complete framework overview

