# SecAI Framework

> Enterprise Azure Security Assessment Framework: Three-dimensional methodology for comprehensive Azure security evaluation with optional AI-accelerated analysis.

[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)
[![GitHub Pages](https://img.shields.io/badge/Docs-GitHub%20Pages-blue)](https://zimaxnet.github.io/secai-framework/)
[![Research: Active](https://img.shields.io/badge/Research-Active-green)](https://github.com/zimaxnet/secai-framework)
[![Framework](https://img.shields.io/badge/SecAI-Framework-purple)](https://zimaxnet.github.io/secai-framework/)

## 📋 Overview

The **SecAI Framework** is a production-ready Azure security assessment methodology that evaluates environments across three critical dimensions:

1. **Configuration Assessment** - Automated collection of 800+ evidence files across 12 security domains
2. **Process Assessment** - Structured interviews evaluating operational maturity
3. **Best Practices Assessment** - Multi-framework validation (MCSB, CIS v8, NIST 800-53, PCI-DSS, CSA CCM)

**🌐 View the full framework**: [https://zimaxnet.github.io/secai-framework/](https://zimaxnet.github.io/secai-framework/)

### Assessment Capabilities

- 📊 **Configuration Assessment** - 20 automated PowerShell/Python scripts, 12 security domains
- 🎤 **Process Assessment** - 8 operational domains, maturity scoring (5-level model)
- ✅ **Best Practices Assessment** - 40+ automated compliance checks across 5 frameworks
- 🔧 **Security Tools Analysis** - Comprehensive evaluation of enterprise security stacks
- 📈 **Real-World Validation** - Tested with 34+ subscriptions, 5,000+ resources

### Why Use This Framework

Organizations conducting Azure security assessments need:
- Systematic, repeatable assessment methodology
- Multi-framework compliance validation
- Automated evidence collection
- Process maturity evaluation
- Actionable remediation roadmaps

This framework provides **production-ready tools** developed from real-world enterprise assessments.

## 📚 Documentation

### Quick Navigation

Visit the **[full framework site](https://zimaxnet.github.io/secai-framework/)** for:

**Getting Started**
- [Prerequisites](https://zimaxnet.github.io/secai-framework/getting-started/prerequisites/)
- [Cursor IDE Setup](https://zimaxnet.github.io/secai-framework/getting-started/cursor-setup/)
- [Azure AI Foundry Integration](https://zimaxnet.github.io/secai-framework/getting-started/azure-ai-foundry-integration/)

**Security**
- [Security Architecture](https://zimaxnet.github.io/secai-framework/security-architecture/)
- [Security Policies & SOPs](https://zimaxnet.github.io/secai-framework/security-policies/)
- [Best Practices](https://zimaxnet.github.io/secai-framework/best-practices/)

**Tools & Vendors**
- [Security Tools Overview](https://zimaxnet.github.io/secai-framework/security-tools/)
- [Wiz Cloud Security](https://zimaxnet.github.io/secai-framework/security-tools/wiz/)
- [CrowdStrike Falcon](https://zimaxnet.github.io/secai-framework/security-tools/crowdstrike/)
- [Cribl Stream](https://zimaxnet.github.io/secai-framework/security-tools/cribl/)

**Advanced Topics**
- [Model Selection Guide](https://zimaxnet.github.io/secai-framework/model-selection/)
- [MCP Server Security](https://zimaxnet.github.io/secai-framework/mcp-servers/)
- [Case Studies](https://zimaxnet.github.io/secai-framework/case-studies/)

### Legacy Documentation

This repository also contains original template documentation in the `/archive` folder:
- Business_Justification.md
- Technical_Addendum.md
- Governance_SOP_Playbook.md

## 🚀 Quick Start

### For Assessment Teams

1. **Visit the framework site**: [https://zimaxnet.github.io/secai-framework/](https://zimaxnet.github.io/secai-framework/)
2. **Start with**: [Getting Started Guide](https://zimaxnet.github.io/secai-framework/getting-started/)
3. **Execute**: Dimension 1 collection scripts, Dimension 3 validation modules
4. **Review**: [Secure Enterprise Execution Guide](workspace/SECURE_ENTERPRISE_EXECUTION_GUIDE.md)

### For Contributors

We welcome contributions from the security community!

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/new-validation-module`)
3. Make your changes
4. Test locally with Jekyll: `cd docs && bundle exec jekyll serve`
5. Submit a pull request

See [Contributing Guidelines](https://zimaxnet.github.io/secai-framework/about/) for details.

## 🔐 Research Methodology

Our research combines:

- **Security Architecture Review** - Analyzing Cursor's security model and Azure integration
- **Hands-On Testing** - Real-world deployments in enterprise environments
- **Policy Development** - Creating security policies and SOPs
- **Vendor Analysis** - Deep research on security tools (Wiz, CrowdStrike, Cribl, etc.)
- **Compliance Mapping** - Aligning with CIS, NIST, ISO 27001, CSA frameworks
- **Real-World Validation** - Testing with confidential customer programs (sanitized)

## 📊 What Makes This Research Unique

### Real-World Security Stack

This research documents an actual production security stack used by a confidential insurance services customer:

**Cloud Security**: Wiz (CNAPP)  
**Endpoint Protection**: CrowdStrike Falcon  
**Identity**: Okta + Azure Entra ID  
**Network Security**: Azure Firewall + Prisma Access  
**Application Security**: Veracode  
**Testing**: Playwright + Selenium  
**Feature Management**: LaunchDarkly  
**Log Management**: Azure EventHub → Cribl Stream → Chronicle + Splunk  

**Multi-Environment**: Dev, Test, UAT, PreProd, Prod (each with separate logging)

### Why Not Palo Alto Cortex XDR?

Research includes analysis of why the customer chose NOT to deploy Cortex XDR despite using other Palo Alto products (Prisma Access):
- Feature overlap with CrowdStrike (endpoint security)
- Feature overlap with Wiz (cloud security)
- Cost considerations
- Operational complexity

This kind of **real-world decision analysis** is rare in public documentation.

---

## 🎯 Research Objectives

1. **Document Secure Architecture** - Comprehensive security patterns for Cursor with Azure AI Foundry
2. **Provide Policy Templates** - Reusable SOPs, policies, and governance frameworks
3. **Analyze Security Tools** - Deep dive into enterprise security stack components
4. **Share Real-World Experience** - Lessons learned from production deployments
5. **Build Community** - Foster collaboration among security professionals

## 👥 Framework Author

**Derek Brent Moore**, Security Architect  
**Contact**: derek@zimax.net  
**LinkedIn**: [linkedin.com/in/derekbmoore](https://linkedin.com/in/derekbmoore)

This framework is independent and not sponsored by Microsoft, Azure, or any vendor.

## 🤝 Contributing

We welcome contributions! See the [full contributing guidelines](https://zimaxnet.github.io/secai-framework/about/) on the framework site.

**Ways to Contribute**:
- Share your implementation experiences
- Submit case studies (anonymized)
- Improve documentation
- Report security considerations
- Test configurations

## 🔗 Links & Resources

- **📖 SecAI Framework Site**: [https://zimaxnet.github.io/secai-framework/](https://zimaxnet.github.io/secai-framework/)
- **🐛 Report Issues**: [GitHub Issues](https://github.com/zimaxnet/secai-framework/issues)
- **💬 Discussions**: [GitHub Discussions](https://github.com/zimaxnet/secai-framework/discussions)
- **🐦 Twitter/X**: [@zimaxnet](https://twitter.com/zimaxnet) - **#SecAI**
- **💼 LinkedIn**: [Derek Moore](https://linkedin.com/in/derekbmoore)

## 📄 License

This research is published under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

You are free to:
- **Share** - Copy and redistribute the material
- **Adapt** - Remix, transform, and build upon the material

Under the terms:
- **Attribution** - Give appropriate credit and indicate if changes were made

Code examples are additionally available under the [MIT License](https://opensource.org/licenses/MIT).

---

## ⚠️ Disclaimer

This research is provided "as-is" for educational purposes. Always consult your organization's security team before implementing any configurations. The research team is not responsible for any security incidents or data loss resulting from the use of this information.

---

## 🌟 Star History

If you find this research helpful, please star the repository to show your support!

---

## 📮 Contact

For questions about this framework:
- **Email**: derek@zimax.net
- **GitHub Issues**: [Report issues or ask questions](https://github.com/zimaxnet/secai-framework/issues)

---

**Start exploring**: [Visit the SecAI Framework →](https://zimaxnet.github.io/secai-framework/)

---

<details>
<summary>📂 Repository Structure</summary>

```
/
├── docs/                          # GitHub Pages Jekyll site
│   ├── _config.yml               # Jekyll configuration
│   ├── Gemfile                   # Ruby dependencies
│   ├── index.md                  # Home page
│   ├── getting-started/          # Setup guides
│   ├── security-architecture/    # Architecture docs
│   ├── security-policies/        # Policy templates
│   ├── security-tools/           # Vendor analysis
│   ├── model-selection/          # AI model guides
│   ├── mcp-servers/              # MCP security
│   ├── case-studies/             # Real-world examples
│   ├── best-practices/           # Operational guidance
│   └── about/                    # Research info
├── archive/                      # Original template files
├── .github/workflows/            # GitHub Actions
└── README.md                     # This file
```

</details>

---

### Legacy Template Documentation

This repository evolved from an enterprise workflow template. Original documentation is preserved in the `/archive` folder for reference.

#### Step-by-Step Setup (Legacy)

1. Create service connection with OIDC authentication:
   ```bash
   # Follow Microsoft's guide for Workload Identity Federation
   # https://learn.microsoft.com/azure/devops/pipelines/library/connect-to-azure
   ```

2. Create variable group linked to Key Vault:
   ```bash
   az pipelines variable-group create \
     --name Enterprise-KeyVault-Secrets \
     --authorize true \
     --variables @keyvault=YourKeyVaultName
   ```

3. Update `azure-pipeline.yaml` with your values:
   - Replace `Enterprise-OIDC-ServiceConnection` with your service connection name
   - Replace `YourKeyVaultName` with your Key Vault name

### Step 3: Set Up GitHub Codespaces

1. Add `.devcontainer/devcontainer.json` to your repository:
   ```bash
   mkdir -p .devcontainer
   cp devcontainer.json .devcontainer/
   ```

2. Configure organization-level Codespaces policies:
   - Settings → Codespaces → Policies
   - Restrict machine types (2-core, 4GB RAM recommended)
   - Enable port visibility controls
   - Configure extension allowlist

3. Test Codespace creation:
   ```bash
   gh codespace create --repo your-org/your-repo
   ```

### Step 4: Create GitHub Copilot Spaces

1. Navigate to [GitHub Copilot Spaces](https://github.com/features/preview/copilot-spaces)

2. Create a space for your project:
   ```
   Space Name: [ProjectName]-Security-Standards
   Description: Security requirements, coding standards, and architecture decisions
   Visibility: Organization (not public)
   ```

3. Add relevant content to the space:
   - **Architecture Documentation**: System design, data flow diagrams
   - **Security Requirements**: This template's security SOPs
   - **Coding Standards**: Style guides, best practices
   - **API Specifications**: OpenAPI/Swagger docs
   - **Compliance Requirements**: CIS/CSA/NIST mappings

4. Configure space settings:
   ```yaml
   # Recommended settings
   auto_sync: true
   content_exclusions:
     - "**/*.env"
     - "**/secrets/**"
     - "**/*.key"
     - "**/*.pem"
   ```

5. Share space with team:
   - Settings → Members → Add team members
   - Set appropriate permissions (view/edit)
   - Document space URL in project README

6. Test space integration:
   ```bash
   # Open Codespace
   gh codespace create --repo your-org/your-repo
   
   # In Codespace, verify Copilot has access to space context
   # Try asking: "What are our security requirements for Key Vault?"
   ```

### Step 5: Deploy Standard Operating Procedures

1. Review and customize [Governance_SOP_Playbook.md](archive/Governance_SOP_Playbook.md)
2. Conduct training sessions using `docs/assets/downloads/Training_Slides.pptx`
3. Publish SOPs to internal wiki/documentation portal
4. Schedule quarterly compliance reviews

## 🔐 Security Architecture

### Integrated Workflow with Dual AI Tools

```
┌─────────────────────────────────────────────────────────────┐
│ GitHub Copilot Space (Team Context)                         │
│  - Architecture docs, security standards, API specs         │
│  - Automatically synced, no secrets allowed                 │
│  - Shared across organization                               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Developer Codespace                                          │
│  - Cursor IDE (Privacy Mode) for code generation            │
│  - GitHub Copilot with Space context for suggestions        │
│  - Both tools respect security policies                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ OIDC Authentication via Entra ID                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Azure Key Vault (RBAC-scoped access)                        │
│  - Secrets retrieved on-demand (short-lived tokens)         │
│  - Never stored in code or AI context                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Azure DevOps Pipeline                                        │
│  - OIDC authentication, secrets masked in logs              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Audit Trail → Azure Monitor + GitHub Audit Log + Sentinel  │
└─────────────────────────────────────────────────────────────┘
```

### Secret Management Flow

```
Developer (Codespace)
    ↓
OIDC Authentication via Entra ID
    ↓
Azure Key Vault (RBAC-scoped access)
    ↓
Secrets retrieved on-demand (short-lived tokens)
    ↓
Pipeline deployment (secrets masked in logs)
    ↓
Audit trail → Azure Monitor + Sentinel
```

### Key Security Principles

1. **No Secrets in AI Chat** - Developers never paste credentials into Cursor or Copilot
2. **No Secrets in Copilot Spaces** - Spaces contain only documentation, never credentials
3. **OIDC Federation** - No long-lived service principals or static tokens
4. **Least Privilege** - RBAC enforced at every layer
5. **Comprehensive Logging** - All actions audited and retained for 2+ years
6. **Zero Trust** - Verify explicitly, assume breach, least privilege access
7. **Content Exclusions** - Automated filtering prevents sensitive files in AI context

## 📊 Compliance Framework Mapping

| Framework | Key Controls Implemented |
|-----------|-------------------------|
| **CIS Azure Foundations 1.4.0** | 3.1 (Key Vault), 4.1 (SQL TDE), 5.1 (Logging) |
| **CSA Cloud Controls Matrix v4** | IAM-01 (SSO), EKM-02 (Key Management), IVS-06 (Logging) |
| **NIST 800-53 Rev 5** | AC-2 (Account Management), AU-2 (Audit Logging), IA-5 (Authenticator Management) |
| **ISO 27001:2013** | A.9.1 (Access Control), A.12.4 (Logging), A.14.2 (Secure Development) |

## 📈 Success Metrics

### Security KPIs

- ✅ **Zero** secret exposure incidents
- ✅ **<15 minutes** mean time to secret rotation
- ✅ **100%** secret scanning coverage
- ✅ **100%** code review compliance

### Operational KPIs

- ⚡ **<30 minutes** environment setup time (down from 3 days)
- 🚀 **40%** improvement in code review velocity
- ✅ **>85%** developer satisfaction score
- 📊 **100%** compliance audit pass rate

## 🛠️ Customization Guide

### For Your Organization

1. **Replace placeholder values**:
   - `YourKeyVaultName` → Your Azure Key Vault name
   - `Enterprise-OIDC-ServiceConnection` → Your Azure DevOps service connection
   - `Enterprise-KeyVault-Secrets` → Your variable group name

2. **Adjust policies** to match your risk tolerance:
   - Codespace machine types and timeout periods
   - Secret rotation frequency
   - Audit log retention periods

3. **Extend SOPs** with organization-specific requirements:
   - Change management procedures
   - Escalation paths
   - Compliance frameworks

### Pipeline Customization

The provided `azure-pipeline.yaml` is a template. Customize the build stage:

```yaml
- script: |
    # Your build commands here
    npm install
    npm run build
    npm test
  displayName: 'Build and Test'
```

## 🧪 Testing the Template

### Security Validation Checklist

- [ ] OIDC authentication works without static credentials
- [ ] Key Vault access properly scoped with RBAC
- [ ] Secret scanning detects test secrets
- [ ] Codespace policies enforce machine type limits
- [ ] Cursor Privacy Mode enabled organization-wide
- [ ] Audit logs flowing to SIEM
- [ ] Incident response procedures tested

### Pilot Deployment

Week 3-4 of the [Implementation Roadmap](archive/Implementation_Roadmap.pdf):

1. Select pilot team (5-10 developers)
2. Deploy to pre-production environment
3. Run security assessment
4. Gather developer feedback
5. Measure baseline vs. target KPIs
6. Refine procedures based on lessons learned

## 📚 Training & Enablement

### Required Training Modules

All team members must complete:

1. **Secure AI Development** (4 hours)
2. **Azure Key Vault Management** (3 hours)
3. **GitHub Security Features** (3 hours)
4. **Incident Response Procedures** (2 hours)

Training materials provided in [`Training_Slides.pptx`](docs/assets/downloads/Training_Slides.pptx).

## 🆘 Support & Troubleshooting

### Common Issues

**Issue**: Pipeline fails with "Unauthorized" error
- **Solution**: Verify OIDC service connection is properly configured and authorized for the variable group

**Issue**: Codespace fails to start
- **Solution**: Check organization policies haven't blocked the base image or required extensions

**Issue**: Cursor not respecting Privacy Mode
- **Solution**: Verify Cursor Enterprise license is active and settings are enforced via MDM

### Getting Help

- Review the [Technical Addendum](archive/Technical_Addendum.md) for detailed architecture
- Consult the [Governance Playbook](archive/Governance_SOP_Playbook.md) for procedures
- Contact your security architecture team for guidance

## 🤝 Contributing

This template is designed to be a living document. Contributions welcome:

1. Fork this repository
2. Make improvements or add organization-specific adaptations
3. Share back with the community (remove sensitive/proprietary information)
4. Submit pull request with clear description

## 📄 License

This template is provided under [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

You are free to:
- **Share** - Copy and redistribute the material
- **Adapt** - Remix, transform, and build upon the material

Under the following terms:
- **Attribution** - Give appropriate credit and indicate if changes were made

## 🙏 Acknowledgments

This template represents industry best practices for secure AI-accelerated development workflows, combining:

- Microsoft's Azure security framework
- GitHub's secure development lifecycle
- OpenAI/Cursor's responsible AI practices
- NIST, CIS, and CSA compliance frameworks

## 📞 Contact

For questions, feedback, or case studies on implementing this template:

- Open an issue in this repository
- Share your success story with the community
- Contribute improvements back to the template

---

## 📖 Document Versions

| Document | Version | Last Updated |
|----------|---------|--------------|
| Business Justification | 1.0 | October 2025 |
| Technical Addendum | 1.0 | October 2025 |
| Governance SOP Playbook | 1.0 | October 2025 |
| README | 1.0 | October 2025 |

**Next Scheduled Review**: January 2026

---

**🚀 Start your secure AI-accelerated development journey today!**

1. Review the [Business Justification](archive/Business_Justification.md)
2. Study the [Technical Addendum](archive/Technical_Addendum.md)
3. Implement the [Governance Playbook](archive/Governance_SOP_Playbook.md)
4. Deploy using the [6-week roadmap](archive/Implementation_Roadmap.pdf)
5. Measure, iterate, and improve!

