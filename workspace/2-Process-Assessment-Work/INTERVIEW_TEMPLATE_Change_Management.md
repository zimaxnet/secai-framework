# Process Assessment Interview Template: Change Management

**SecAI Framework - Dimension 2**  
**Process Domain:** Change Management  
**Interview Date:** [DATE]  
**Interviewer:** [NAME]  
**Interviewee(s):** [NAME(S) / ROLE(S)]  
**Organization:** [ORG NAME]  
**Environment:** [Production / PreProd / Dev / All]

---

## Interview Overview

**Purpose:** Assess the maturity of change management processes for Azure environments

**Duration:** 60-90 minutes

**Outcome:** Maturity score (1-5) and recommendations

---

## Section 1: Change Planning & Initiation

### Q1.1: How are changes to Azure resources proposed and documented?

**Objective:** Understand change initiation process

**Possible Answers:**
- [ ] No formal process - changes made as needed
- [ ] Email requests to team
- [ ] Ticket system (Jira, ServiceNow, Azure DevOps)
- [ ] Change request form/template
- [ ] Automated CI/CD pipeline triggers

**Follow-up Questions:**
- Who can request a change?
- Is there a change request template?
- What information is required in a change request?

**Evidence to Collect:**
- [ ] Sample change request
- [ ] Change request template
- [ ] Screenshot of ticketing system

**Maturity Indicator:**
- **Level 1 (Ad Hoc):** No formal process, verbal requests
- **Level 2 (Documented):** Email or simple ticket system
- **Level 3 (Managed):** Formal ticketing system with required fields
- **Level 4 (Measured):** Template-based with categorization
- **Level 5 (Optimized):** Integrated with CI/CD, automated validation

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

### Q1.2: Are changes risk-assessed before implementation?

**Objective:** Determine if change risk is evaluated

**Possible Answers:**
- [ ] No risk assessment performed
- [ ] Informal risk assessment by implementer
- [ ] Formal risk assessment for production changes only
- [ ] All changes have documented risk assessment
- [ ] Automated risk scoring based on change type

**Follow-up Questions:**
- Who performs the risk assessment?
- What criteria are used (impact, likelihood)?
- Are high-risk changes handled differently?
- Is there a risk matrix or framework?

**Evidence to Collect:**
- [ ] Risk assessment template
- [ ] Risk matrix/criteria
- [ ] Sample risk assessment document

**Maturity Indicator:**
- **Level 1:** No risk assessment
- **Level 2:** Informal, ad-hoc assessment
- **Level 3:** Formal assessment for major changes
- **Level 4:** Risk assessment required for all changes
- **Level 5:** Automated risk scoring with mitigation tracking

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

### Q1.3: Is there a Change Advisory Board (CAB) or approval process?

**Objective:** Assess governance and oversight

**Possible Answers:**
- [ ] No formal approval process
- [ ] Manager approval required
- [ ] CAB reviews major changes
- [ ] CAB reviews all production changes
- [ ] Emergency CAB for urgent changes

**Follow-up Questions:**
- Who sits on the CAB?
- How often does CAB meet?
- What is the approval authority matrix?
- How are emergency changes handled?

**Evidence to Collect:**
- [ ] CAB charter or membership list
- [ ] Meeting schedule
- [ ] Approval authority matrix
- [ ] Emergency change procedure

**Maturity Indicator:**
- **Level 1:** No approval required
- **Level 2:** Single approver (manager)
- **Level 3:** CAB for major changes
- **Level 4:** CAB for all production changes with defined SLAs
- **Level 5:** Multi-tier approval with automated routing and escalation

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

## Section 2: Change Testing & Validation

### Q2.1: Are changes tested in a non-production environment before deployment?

**Objective:** Assess testing practices

**Possible Answers:**
- [ ] No testing - changes go directly to production
- [ ] Informal testing by implementer
- [ ] Testing in development environment
- [ ] Testing in dedicated test environment
- [ ] Multi-stage testing (Dev → Test → UAT → Prod)

**Follow-up Questions:**
- What test environments exist (Dev, Test, UAT)?
- Are test environments similar to production?
- Who performs testing?
- What are the test criteria/acceptance criteria?
- Are test results documented?

**Evidence to Collect:**
- [ ] Test environment inventory
- [ ] Test plan template
- [ ] Sample test results
- [ ] Environment parity documentation

**Maturity Indicator:**
- **Level 1:** No testing, direct to production
- **Level 2:** Ad-hoc testing in dev environment
- **Level 3:** Formal testing in separate test environment
- **Level 4:** Multi-stage testing with documented results
- **Level 5:** Automated testing with quality gates

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

### Q2.2: Is there a rollback plan for each change?

**Objective:** Assess change reversibility

**Possible Answers:**
- [ ] No rollback plan
- [ ] Informal rollback understanding
- [ ] Rollback plan for major changes
- [ ] Rollback plan required for all changes
- [ ] Automated rollback capability

**Follow-up Questions:**
- How quickly can changes be rolled back?
- Has rollback been tested?
- Are there changes that cannot be rolled back?
- How is rollback decision made?

**Evidence to Collect:**
- [ ] Sample rollback plan
- [ ] Rollback procedure documentation
- [ ] Example of successful rollback

**Maturity Indicator:**
- **Level 1:** No rollback plan
- **Level 2:** Verbal rollback understanding
- **Level 3:** Documented rollback for major changes
- **Level 4:** Rollback plan required for all changes
- **Level 5:** Automated rollback with testing

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

## Section 3: Change Deployment & Execution

### Q3.1: How are changes deployed to production?

**Objective:** Understand deployment practices

**Possible Answers:**
- [ ] Manual deployment via Portal
- [ ] Manual deployment via CLI/PowerShell
- [ ] Scripts (IaC - ARM, Bicep, Terraform)
- [ ] CI/CD pipeline (Azure DevOps, GitHub Actions)
- [ ] Full automation with approvals and gates

**Follow-up Questions:**
- Who has authority to deploy to production?
- Are deployments scheduled (maintenance windows)?
- Is deployment process documented?
- Are deployment steps verified?

**Evidence to Collect:**
- [ ] Deployment runbook
- [ ] IaC templates
- [ ] CI/CD pipeline configuration
- [ ] Deployment schedule/calendar

**Maturity Indicator:**
- **Level 1:** Ad-hoc manual deployment
- **Level 2:** Script-based deployment
- **Level 3:** IaC with manual execution
- **Level 4:** CI/CD pipeline with manual approvals
- **Level 5:** Fully automated with quality gates and canary deployments

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

### Q3.2: Are changes tracked and documented during implementation?

**Objective:** Assess change tracking

**Possible Answers:**
- [ ] No tracking during implementation
- [ ] Informal notes in ticket
- [ ] Real-time updates in ticket system
- [ ] Detailed implementation log
- [ ] Automated deployment logging

**Follow-up Questions:**
- How are issues during deployment captured?
- Is there an implementation checklist?
- Are deployment logs retained?

**Evidence to Collect:**
- [ ] Sample implementation log
- [ ] Deployment checklist
- [ ] Ticket with implementation notes

**Maturity Indicator:**
- **Level 1:** No documentation
- **Level 2:** Ad-hoc notes
- **Level 3:** Updates in ticket system
- **Level 4:** Detailed implementation log
- **Level 5:** Automated logging with audit trail

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

## Section 4: Change Communication & Coordination

### Q4.1: How are stakeholders notified of planned changes?

**Objective:** Assess communication practices

**Possible Answers:**
- [ ] No notification
- [ ] Email to affected team
- [ ] Change calendar/schedule
- [ ] Automated notifications from ticketing system
- [ ] Multi-channel communication (email, Slack, Teams)

**Follow-up Questions:**
- How far in advance are changes communicated?
- Who receives notifications?
- Is there a change calendar?
- How are emergency changes communicated?

**Evidence to Collect:**
- [ ] Sample change notification
- [ ] Change calendar
- [ ] Communication plan template

**Maturity Indicator:**
- **Level 1:** No notification
- **Level 2:** Email to direct team
- **Level 3:** Scheduled notifications with change calendar
- **Level 4:** Automated notifications with lead time requirements
- **Level 5:** Multi-channel with role-based notifications

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

### Q4.2: Is there coordination between teams for complex changes?

**Objective:** Assess cross-team coordination

**Possible Answers:**
- [ ] No coordination
- [ ] Informal coordination between team leads
- [ ] Coordinated via CAB
- [ ] Formal coordination with documented handoffs
- [ ] Integrated planning with dependency mapping

**Follow-up Questions:**
- How are dependencies identified?
- How are conflicting changes managed?
- Is there a change freeze period?

**Evidence to Collect:**
- [ ] Coordination process documentation
- [ ] Sample complex change with multiple teams
- [ ] Change freeze schedule

**Maturity Indicator:**
- **Level 1:** No coordination
- **Level 2:** Ad-hoc coordination
- **Level 3:** CAB coordinates major changes
- **Level 4:** Formal coordination for all changes
- **Level 5:** Automated dependency tracking and conflict resolution

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

## Section 5: Post-Change Review & Continuous Improvement

### Q5.1: Are changes reviewed after implementation?

**Objective:** Assess post-implementation review

**Possible Answers:**
- [ ] No post-change review
- [ ] Review if change failed
- [ ] Review of major changes
- [ ] All changes reviewed
- [ ] Systematic review with lessons learned database

**Follow-up Questions:**
- What is reviewed (success criteria, issues)?
- Are lessons learned documented?
- Are processes improved based on findings?

**Evidence to Collect:**
- [ ] Post-implementation review template
- [ ] Sample review document
- [ ] Lessons learned database

**Maturity Indicator:**
- **Level 1:** No review
- **Level 2:** Review only when problems occur
- **Level 3:** Review of major changes
- **Level 4:** All changes reviewed systematically
- **Level 5:** Automated review with metrics and continuous improvement

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

### Q5.2: Are change metrics tracked and reported?

**Objective:** Assess measurement and reporting

**Possible Answers:**
- [ ] No metrics tracked
- [ ] Basic counts (# of changes)
- [ ] Success/failure metrics
- [ ] Comprehensive metrics dashboard
- [ ] Predictive analytics and trend analysis

**Follow-up Questions:**
- What metrics are tracked?
- Who reviews metrics?
- Are metrics used to improve processes?

**Metrics to Ask About:**
- Change volume
- Change success rate
- Average time to implement
- Emergency change rate
- Rollback rate

**Evidence to Collect:**
- [ ] Metrics dashboard
- [ ] Sample metrics report
- [ ] Trend analysis

**Maturity Indicator:**
- **Level 1:** No metrics
- **Level 2:** Basic counting
- **Level 3:** Success rate and quality metrics
- **Level 4:** Comprehensive dashboard with trends
- **Level 5:** Predictive analytics driving proactive improvements

**Notes:**
```
[Interviewer notes here]
```

**Score:** [1-5]

---

## Maturity Assessment Summary

### Individual Section Scores

| Section | Topic | Score (1-5) |
|---------|-------|-------------|
| 1 | Change Planning & Initiation | [avg of Q1.1-1.3] |
| 2 | Testing & Validation | [avg of Q2.1-2.2] |
| 3 | Deployment & Execution | [avg of Q3.1-3.2] |
| 4 | Communication & Coordination | [avg of Q4.1-4.2] |
| 5 | Post-Change Review & Improvement | [avg of Q5.1-5.2] |

### Overall Change Management Maturity Score: [AVERAGE]

---

## Maturity Level Definitions

| Level | Name | Description |
|-------|------|-------------|
| **1** | **Ad Hoc** | No formal change process, changes made as needed with minimal documentation |
| **2** | **Documented** | Basic change process documented but not consistently followed |
| **3** | **Managed** | Formal change process followed for most changes, approvals required, basic tracking |
| **4** | **Measured** | Comprehensive change management with metrics, continuous monitoring, quality gates |
| **5** | **Optimized** | Highly automated, predictive analytics, continuous improvement, industry-leading practices |

**Current Maturity Level:** [Level based on overall score]

---

## Key Findings

### Strengths:
```
[List 3-5 key strengths of the change management process]
- 
- 
- 
```

### Gaps:
```
[List 3-5 critical gaps or areas for improvement]
- 
- 
- 
```

### Quick Wins:
```
[List 2-3 improvements that can be implemented quickly]
- 
- 
```

---

## Recommendations

### Priority 1 (Critical - 0-30 days):
```
[List immediate actions needed]
1. 
2. 
3. 
```

### Priority 2 (High - 30-90 days):
```
[List high-priority improvements]
1. 
2. 
3. 
```

### Priority 3 (Medium - 90-180 days):
```
[List medium-priority enhancements]
1. 
2. 
3. 
```

---

## Evidence Collected

| Evidence Type | Collected? | Location/Notes |
|---------------|------------|----------------|
| Change request template | ☐ Yes ☐ No | |
| Risk assessment template | ☐ Yes ☐ No | |
| CAB charter/membership | ☐ Yes ☐ No | |
| Test plan template | ☐ Yes ☐ No | |
| Rollback procedure | ☐ Yes ☐ No | |
| Deployment runbook | ☐ Yes ☐ No | |
| IaC templates | ☐ Yes ☐ No | |
| Change calendar | ☐ Yes ☐ No | |
| Communication plan | ☐ Yes ☐ No | |
| Post-change review template | ☐ Yes ☐ No | |
| Metrics dashboard | ☐ Yes ☐ No | |

---

## Next Steps

1. **Review Findings:** Share draft report with interviewee for validation
2. **Gather Additional Evidence:** Collect any missing documentation
3. **Validate Technical Controls:** Cross-reference with Configuration Assessment (SecAI Scripts)
4. **Develop Roadmap:** Create detailed improvement roadmap
5. **Present to Leadership:** Executive summary and recommendations

---

## Appendix: Additional Notes

```
[Additional context, observations, or notes from the interview]









```

---

**Interview Completed By:** [NAME]  
**Date:** [DATE]  
**Review Status:** ☐ Draft ☐ Under Review ☐ Final  
**Next Review Date:** [DATE]

---

## Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-17 | Security Team | Initial template |
|  |  |  |  |

---

**Template Status:** Ready for Use ✅  
**Part of:** SecAI Framework - Process Assessment (Dimension 2)  
**Related Templates:** Incident Response, Access Management, Vulnerability Management


