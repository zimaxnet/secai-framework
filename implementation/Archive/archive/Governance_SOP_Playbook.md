# Governance & SOP Playbook: Secure AI-Accelerated Enterprise Workflow

This playbook defines governance practices and standard operating procedures (SOPs) for adopting the secure AI-accelerated workflow in enterprise environments. It ensures compliance, accountability, and operational excellence across all project phases.

## 1. Core Standard Operating Procedures (SOPs)

### SOP-001: No Secrets in AI Chat Interfaces

**Policy**: Developers must NEVER paste secrets into Cursor or any AI chat interface.

**Procedure**:
1. Identify sensitive data (passwords, API keys, tokens, certificates)
2. Store in Azure Key Vault using Azure CLI or portal
3. Reference secrets via pipeline variables or secure parameter files
4. Use AI assistance only for code structure, not credential management

**Violation Response**: Immediate secret rotation + security incident report

---

### SOP-002: Secure Secret Management

**Policy**: Secrets must be entered only via secure terminal commands into Azure Key Vault.

**Procedure**:
1. Authenticate using `az login` with MFA-enforced account
2. Set secrets using: `az keyvault secret set --vault-name <vault> --name <name> --value <value>`
3. Verify RBAC permissions are correctly scoped
4. Document secret purpose and expiration in Key Vault metadata
5. Enable audit logging for all secret operations

**Audit Frequency**: Monthly review of Key Vault access logs

---

### SOP-003: GitHub Codespaces Development

**Policy**: All development must occur inside GitHub Codespaces with approved devcontainer images.

**Procedure**:
1. Create Codespace from approved repository with `.devcontainer/devcontainer.json`
2. Verify organization policies are applied (extension restrictions, machine type limits)
3. Use Codespace for all code editing and testing
4. Commit changes through Codespace git integration
5. Destroy Codespace after session completion

**Approved Images**: `mcr.microsoft.com/devcontainers/universal:2` or organization-approved custom images

---

### SOP-004: Cursor IDE Configuration

**Policy**: Cursor Enterprise Privacy Mode must always be enabled; indexing must be limited to approved repositories.

**Procedure**:
1. Enable Privacy Mode: Settings → Features → Privacy Mode: ON
2. Configure repository allowlist: Settings → AI → Allowed Repositories
3. Disable telemetry: Settings → Privacy → Usage Data: OFF
4. Verify enterprise license: Settings → Account → Enterprise License Active
5. Report any AI suggestion of credentials immediately

**Administrator Enforcement**: Organization-wide policy enforced via MDM

---

### SOP-005: GitHub Copilot Spaces Management

**Policy**: Copilot Spaces must contain only documentation and standards; NEVER secrets or sensitive data.

**Procedure**:
1. **Space Creation**:
   - Navigate to GitHub Copilot Spaces interface
   - Set visibility to "Organization" (never public)
   - Name space: `[ProjectName]-[Purpose]` (e.g., `PaymentAPI-SecurityStandards`)
   - Add detailed description of space purpose

2. **Content Addition**:
   - Security engineer reviews ALL content before adding to space
   - Verify content exclusions are configured:
     ```yaml
     content_exclusions:
       - "**/*.env*"
       - "**/secrets/**"
       - "**/*.key"
       - "**/*.pem"
     ```
   - Add only approved content types:
     - ✅ Architecture documentation
     - ✅ Coding standards
     - ✅ API specifications
     - ✅ Security requirements
     - ❌ Secrets, keys, credentials
     - ❌ Production configurations
     - ❌ Customer data

3. **Access Management**:
   - Grant access via GitHub teams (not individual users)
   - Default permission: Read-only
   - Edit permission: Security Engineer + Technical Leads only
   - Document all access grants in team wiki

4. **Content Review**:
   - Quarterly audit of all space content
   - Verify GitHub secret scanning is active
   - Remove outdated or incorrect information
   - Update standards based on lessons learned

5. **Incident Response**:
   - If secret detected: Immediate removal + Key Vault rotation
   - Notify all space members within 30 minutes
   - Root cause analysis within 24 hours

**Audit Frequency**: Quarterly review of space content and members

**Violation Response**: Immediate space content removal + secret rotation + incident report

---

## 2. Approval Gates & Controls

### PR-001: Pull Request Security Checklist

Every pull request must include verification of:

- [ ] No hardcoded secrets or credentials
- [ ] All secrets referenced via Key Vault or pipeline variables
- [ ] Secret scanning passed (GitHub Advanced Security)
- [ ] Dependency vulnerability check passed
- [ ] Unit tests passed with >80% coverage
- [ ] Linting and code quality checks passed
- [ ] Security reviewer approval obtained

---

### PR-002: Mandatory Code Review

**Policy**: At least one security-trained reviewer must approve all pull requests.

**Procedure**:
1. Developer submits PR with completed security checklist
2. Automated checks run (secret scanning, SAST, dependency check)
3. Security reviewer performs manual review
4. If secrets found: PR rejected + immediate rotation + incident report
5. Once approved, merge to protected branch

**Security Reviewer Requirements**: Completion of secure coding training + Key Vault access management certification

---

### PR-003: Secret Scanning Enforcement

**Policy**: GitHub Advanced Security secret scanning must be enabled and enforced on all repositories.

**Procedure**:
1. Enable GitHub Advanced Security for organization
2. Configure custom secret scanning patterns for organization-specific tokens
3. Set push protection to block commits containing secrets
4. Monitor secret scanning alerts in Security tab
5. Remediate detected secrets within 1 hour of detection

**Alert Escalation**: Security team notified immediately via PagerDuty/email

---

### PR-004: Branch Protection Rules

**Policy**: Critical branches (main, release, production) require signed commits and approval.

**Configuration**:
- Require signed commits (GPG or S/MIME)
- Require pull request reviews (minimum 1, security reviewer)
- Require status checks to pass before merging
- Restrict force pushes
- Restrict deletions
- Require linear history
- Include administrators in restrictions

---

## 3. Audit & Compliance Procedures

### AUDIT-001: Comprehensive Audit Logging

**Policy**: Enable audit streams in GitHub, Azure DevOps, and Cursor Enterprise.

**Implementation**:
- **GitHub**: Organization audit log → Azure Monitor via webhook
- **Azure DevOps**: Auditing → Enable all categories → Export to Log Analytics
- **Cursor Enterprise**: Admin Console → Audit Logs → SIEM integration
- **Azure Key Vault**: Diagnostic Settings → Send to Log Analytics Workspace

**Retention**: Minimum 2 years for compliance, 7 years for financial data

---

### AUDIT-002: Quarterly Access Reviews

**Policy**: Conduct quarterly reviews of all SSO and SCIM-provisioned accounts.

**Procedure**:
1. Export user list from Entra ID, GitHub, Azure DevOps
2. Validate each user's role against current job function
3. Remove accounts for terminated employees (within 24 hours of termination)
4. Downgrade over-privileged accounts to least privilege
5. Document review findings and remediations
6. Report to security governance board

**Review Schedule**: Q1 (January), Q2 (April), Q3 (July), Q4 (October)

---

### AUDIT-003: Secret Exposure Incident Response

**Policy**: Any suspected secret exposure triggers immediate Key Vault rotation.

**Response Procedure**:
1. **T+0 minutes**: Detect exposure (automated scanning or manual report)
2. **T+5 minutes**: Revoke exposed secret in Key Vault
3. **T+15 minutes**: Generate new secret and update all consumers
4. **T+30 minutes**: Verify all services operational with new secret
5. **T+60 minutes**: Complete incident report with root cause
6. **T+24 hours**: Security review meeting with findings and preventive measures

**Escalation**: Security Architect (immediate) → CISO (within 4 hours if production impact)

---

### AUDIT-004: Compliance Framework Mapping

**Policy**: Ensure practices align with CIS, CSA, and NIST standards.

**Mapping Requirements**:

| Control ID | Framework | Implementation Evidence |
|------------|-----------|------------------------|
| CIS 3.1 | Azure Foundations | Key Vault soft delete enabled |
| CIS 4.1 | Azure Foundations | SQL TDE enabled with Key Vault CMK |
| CSA CCM IAM-01 | Cloud Controls Matrix | SSO via Entra ID + MFA |
| CSA CCM EKM-02 | Cloud Controls Matrix | Key Vault for all cryptographic keys |
| NIST AC-2 | 800-53 Rev 5 | SCIM provisioning + quarterly reviews |
| NIST AU-2 | 800-53 Rev 5 | Comprehensive audit logging enabled |
| NIST IA-5 | 800-53 Rev 5 | OIDC federation, no static credentials |
| NIST SC-13 | 800-53 Rev 5 | FIPS 140-2 validated cryptography |

---

## 4. Roles & Responsibilities (RACI Matrix)

| Activity | Security Architect | Principal Security Architect | Security Engineer | Automation Engineer | App SME | Project Director |
|----------|-------------------|----------------------------|------------------|-------------------|---------|-----------------|
| **SOP Development** | A | R | C | C | C | I |
| **Policy Enforcement** | R | A | R | I | I | I |
| **Security Reviews** | A | R | R | I | C | I |
| **Incident Response** | A | I | R | C | C | R |
| **Compliance Audits** | R | A | R | I | I | I |
| **Training Delivery** | C | I | R | R | R | A |
| **Escalations** | R | A | I | I | I | R |

**Legend**: R = Responsible, A = Accountable, C = Consulted, I = Informed

---

## 5. Training & Enablement

### Required Training Modules

All team members must complete:

1. **Secure AI Development with Dual Tools** (5 hours)
   - AI security risks and mitigations
   - Cursor Privacy Mode configuration
   - GitHub Copilot privacy settings
   - Secure prompt engineering
   - When to use Cursor vs Copilot
   
2. **GitHub Copilot Spaces Management** (2 hours)
   - Creating and configuring spaces
   - Content exclusion patterns
   - Access control best practices
   - What to include/exclude from spaces
   - Quarterly audit procedures
   
3. **Azure Key Vault Management** (3 hours)
   - Secret lifecycle management
   - RBAC configuration
   - Audit log review
   - Integration with AI tools
   
4. **GitHub Security Features** (3 hours)
   - Secret scanning configuration
   - Dependabot alerts
   - Code scanning with CodeQL
   - Copilot Space security scanning
   
5. **Incident Response Procedures** (2 hours)
   - Secret exposure response
   - Copilot Space incident handling
   - Escalation procedures
   - Post-incident reviews

### Training Validation
- Completion certificate required before Key Vault or Copilot Space access
- Annual refresher training mandatory
- Quiz score >85% required to pass
- Hands-on lab completion required for Copilot Spaces module

---

## 6. Key Performance Indicators (KPIs)

### Security Metrics

| Metric | Target | Measurement Frequency |
|--------|--------|----------------------|
| Secret exposure incidents | 0 per quarter | Continuous monitoring |
| Mean time to secret rotation | <15 minutes | Per incident |
| Secret scanning coverage | 100% of repositories | Weekly |
| Code review compliance | 100% of PRs | Daily |
| Unauthorized Key Vault access attempts | 0 per month | Daily |

### Operational Metrics

| Metric | Target | Measurement Frequency |
|--------|--------|----------------------|
| Environment setup time | <30 minutes | Per Codespace creation |
| Pipeline execution time | <10 minutes | Per pipeline run |
| Failed pipeline runs due to auth issues | <2% | Weekly |
| Developer satisfaction | >85% | Quarterly survey |
| Compliance audit pass rate | 100% | Quarterly |

---

## 7. Continuous Improvement

### Monthly Security Review
- Review all audit logs for anomalies
- Update threat model based on new attack vectors
- Refine secret scanning patterns
- Review and update SOPs based on lessons learned

### Quarterly Governance Board
- Report on KPI achievement
- Present compliance audit results
- Discuss security incidents and remediations
- Approve policy updates

### Annual Framework Review
- Full audit of CIS/CSA/NIST compliance
- Third-party security assessment
- Penetration testing of Codespaces environment
- Update playbook based on industry best practices

---

## 8. Conclusion

The SOPs, approval gates, and audit procedures defined in this playbook ensure that enterprise adoption of AI-accelerated workflows is both secure and compliant. They provide a repeatable framework for enterprise-scale projects that balances security controls with developer productivity.

This playbook represents a **living document** that should be updated quarterly based on:
- Emerging security threats
- New platform capabilities
- Lessons learned from incidents
- Industry best practice evolution

---

**Document Version**: 1.0  
**Last Updated**: October 2025  
**Classification**: Public Template  
**Next Review Date**: January 2026

