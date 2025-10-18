---
layout: default
title: Home
nav_order: 1
description: "Enterprise Azure Security Assessment Framework - Three-dimensional methodology for comprehensive Azure security evaluation"
permalink: /
---

# SecAI Framework
{: .fs-9 }

Enterprise Azure Security Assessment Framework
{: .fs-6 .fw-300 }

Comprehensive three-dimensional security assessment for Azure environments. Execute via VSCode with optional AI-accelerated analysis using Cursor + Azure AI Foundry.
{: .fs-5 .fw-300 }

[Get Started](/getting-started/){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[View Implementation](https://github.com/zimaxnet/secai-framework/tree/main/implementation){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## 🛠️ Complete Implementation Package Available

The **production-ready implementation** is in this repository:

**[→ Browse Implementation Folder](https://github.com/zimaxnet/secai-framework/tree/main/implementation){: .btn .btn-purple }**

### What's Included:

**Dimension 1: Configuration Assessment**
- ✅ 10 PowerShell collection scripts (Azure CLI + Resource Graph)
- ✅ 7 Python transformation scripts (JSON → CSV)
- ✅ 2 Python analysis scripts (risk identification, subscription comparison)
- ✅ Covers 12 security domains across entire Azure estate

**Dimension 2: Process Assessment**  
- ✅ Interview templates for 8 operational domains
- ✅ Process maturity scoring framework
- ✅ Gap analysis and improvement roadmap generators

**Dimension 3: Best Practices Assessment**
- ✅ 5 PowerShell framework validation modules (MCSB, CIS, NIST, PCI-DSS, CCM)
- ✅ Master orchestrator for multi-framework validation
- ✅ 40+ automated compliance checks
- ✅ CSV reports and executive summaries

**Execution Environment:** VSCode on Windows/macOS/Linux  
**Optional Enhancement:** Cursor IDE with Azure AI Foundry for AI-assisted analysis

[Implementation README](https://github.com/zimaxnet/secai-framework/blob/main/implementation/README.md){: .btn .btn-outline }
[Quick Start Guide](https://github.com/zimaxnet/secai-framework/blob/main/implementation/QUICK_START.md){: .btn .btn-outline }

---

## Three-Dimensional Assessment Methodology

The SecAI Framework evaluates Azure environments across three critical dimensions:

### Dimension 1: Configuration Assessment
**What is deployed and how it's configured**
- ✅ 100% Automated - PowerShell + Python scripts
- ✅ 20 collection/transformation/analysis scripts
- ✅ 12 security domains: Network, Identity, Data, Logging, Backup, and more
- ✅ 800+ evidence files collected from Azure CLI and Resource Graph
- ✅ Execution: VSCode terminal (3-4 hours)

[View Configuration Scripts](https://github.com/zimaxnet/secai-framework/tree/main/implementation/2-Scripts)

### Dimension 2: Process Assessment  
**How operations are managed and governed**
- 📋 Interview-driven methodology
- 📋 8 operational domains: Change Management, Incident Response, Access Control, etc.
- 📋 Process maturity scoring (5-level model)
- 📋 Execution: Structured interviews + documentation review

[View Interview Templates](https://github.com/zimaxnet/secai-framework/tree/main/workspace/2-Process-Assessment-Work)

### Dimension 3: Best Practices Assessment
**Alignment with industry frameworks**
- ✅ Multi-framework validation: MCSB, CIS v8, NIST 800-53, PCI-DSS, CSA CCM
- ✅ 40+ automated compliance checks
- ✅ PowerShell modular validation suite
- ✅ Quantifiable compliance scores and gap reports
- ✅ Execution: PowerShell script against collected data (minutes)

[View Validation Modules](https://github.com/zimaxnet/secai-framework/tree/main/workspace/3-Best-Practices-Work)

**Recommended Execution Order:** Dimension 1 → Dimension 3 → Dimension 2

---

## About the SecAI Framework

The **SecAI Framework** is a comprehensive Azure security assessment methodology designed for enterprise environments. Created from a security architect's perspective, the framework provides:

- 📊 **Configuration Assessment** - Automated collection of 800+ evidence files across 12 security domains
- 🔍 **Process Assessment** - Structured interviews evaluating operational maturity
- ✅ **Best Practices Assessment** - Multi-framework validation (MCSB, CIS, NIST, PCI-DSS, CCM)
- 🔐 **Security Tools Analysis** - Deep-dive assessment of enterprise security stacks
- 📋 **Compliance Mapping** - Alignment with industry standards and frameworks
- 📊 **Real-World Validation** - Tested with confidential customer programs (sanitized for publication)

### Assessment Objectives

{: .note }
This is a **production-ready framework** developed through real-world Azure security assessments. Findings and methodologies are shared for public benefit.

**Primary Goals:**
1. Systematic assessment of Azure environments (34+ subscriptions, 5,000+ resources)
2. Multi-framework compliance validation (MCSB, CIS, NIST, PCI-DSS, CCM)
3. CSP-to-MCA migration security validation
4. Azure Landing Zone security baseline verification
5. Quarterly security posture assessment and improvement

---

## Optional: AI-Accelerated Assessment with Cursor + Azure AI Foundry

**Forward-Thinking Enhancement** (may not be available in all customer environments)

For organizations that allow AI-assisted development, the SecAI Framework can be accelerated using **Cursor IDE with Azure AI Foundry integration**:

✅ **Data Sovereignty** - AI chat stays within your Azure tenant (not Cursor servers)  
✅ **Secure Analysis** - Use GPT-4, o1, Codex for script development and data analysis  
✅ **Compliance** - All AI interactions logged via Azure Monitor  
✅ **Network Isolation** - Private endpoints, no public internet exposure  
✅ **Audit Trail** - Complete visibility into AI-assisted analysis

**Primary Method:** VSCode + PowerShell/Python scripts (works everywhere)  
**Enhanced Method:** Cursor + Azure AI Foundry (when security allows)

[Learn More: Secure AI for Security Assessments](/getting-started/cursor-setup)

---

## Quick Navigation

<div class="grid grid-cols-3 gap-4">
  <div class="col">
    <h3>🚀 Getting Started</h3>
    <ul>
      <li><a href="/getting-started/">Assessment Quick Start</a></li>
      <li><a href="/getting-started/prerequisites">Prerequisites</a></li>
      <li><a href="https://github.com/zimaxnet/secai-framework/tree/main/implementation/2-Scripts">Collection Scripts</a></li>
      <li><a href="https://github.com/zimaxnet/secai-framework/tree/main/workspace/3-Best-Practices-Work">Validation Modules</a></li>
    </ul>
  </div>
  
  <div class="col">
    <h3>🔐 Assessment Framework</h3>
    <ul>
      <li><a href="/security-architecture/">Three Dimensions</a></li>
      <li><a href="/security-tools/">Security Tools Stack</a></li>
      <li><a href="/best-practices/">Best Practices</a></li>
      <li><a href="/getting-started/cursor-setup">Optional: AI Enhancement</a></li>
    </ul>
  </div>
  
  <div class="col">
    <h3>📋 Implementation</h3>
    <ul>
      <li><a href="https://github.com/zimaxnet/secai-framework/tree/main/implementation">Implementation Folder</a></li>
      <li><a href="https://github.com/zimaxnet/secai-framework/blob/main/implementation/QUICK_START.md">Quick Start Guide</a></li>
      <li><a href="https://github.com/zimaxnet/secai-framework/blob/main/implementation/1-Documentation/EXECUTION_GUIDE.md">Execution Guide</a></li>
      <li><a href="https://github.com/zimaxnet/secai-framework/blob/main/implementation/1-Documentation/FRAMEWORK_OVERVIEW.md">Framework Overview</a></li>
    </ul>
  </div>
</div>

---

## Assessment Methodology

Our framework combines automated and manual assessment techniques:

- **Automated Collection** - PowerShell and Python scripts gather 800+ evidence files from Azure
- **Multi-Framework Validation** - Validate against MCSB, CIS, NIST, PCI-DSS, CSA CCM
- **Process Maturity Scoring** - Structured interviews assess operational effectiveness
- **Compliance Mapping** - Align configurations with industry standards and frameworks
- **Real-World Validation** - Tested with confidential insurance customer (34+ subscriptions, 5,000+ resources)

### Framework Team

**Lead Architect**: Derek Brent Moore - Security Architect  
**Organization**: Zimax Network & Security Consulting  
**Publication**: Findings published for public benefit

---

## Key Assessment Areas

### 1. Configuration Assessment (Dimension 1)
- 12 Security Domains: Network, Identity, Data Protection, Logging, Backup, etc.
- Automated collection via Azure CLI and Resource Graph
- 800+ JSON evidence files
- CSV transformation for analysis
- Resource inventory and configuration exports

### 2. Process Assessment (Dimension 2)
- Change Management maturity
- Incident Response procedures
- Access Provisioning workflows
- Patch Management cadence
- Security Monitoring operations
- Backup & Recovery testing
- Compliance Management processes
- Vendor Management oversight

### 3. Best Practices Assessment (Dimension 3)
- Microsoft Cloud Security Benchmark (MCSB) validation
- CIS Controls v8 compliance scoring
- NIST SP 800-53 control mapping
- PCI-DSS v3.2.1 requirements validation
- CSA Cloud Controls Matrix (CCM) assessment

### 4. Security Tools Stack Analysis
- Discovered and analyzed in customer environment:
- Cloud Security: Wiz CNAPP
- Endpoint Protection: CrowdStrike Falcon
- Network Security: Azure Firewall, Palo Alto Prisma Access
- Log Management: Cribl Stream, Chronicle, Splunk
- Identity: Okta, Azure Entra ID
- AppSec: Veracode
- Testing: Playwright, Selenium
- Feature Management: LaunchDarkly

### 5. Optional: AI-Enhanced Analysis
- Cursor IDE with Azure AI Foundry (when customer policy allows)
- Secure AI chat within Azure tenant for data analysis
- GPT-4, o1, Codex for script development assistance
- Private endpoint configuration for network isolation
- Complete audit trail via Azure Monitor

---

## Latest Updates

<span class="badge badge-new">NEW</span> **Oct 2025** - Multi-framework validation suite complete (MCSB, CIS, NIST, PCI-DSS, CCM)  
<span class="badge badge-updated">UPDATED</span> **Oct 2025** - Dimension 3 production-ready: 40+ automated compliance checks  
<span class="badge badge-new">NEW</span> **Oct 2025** - Assessment framework realigned: VSCode primary, Cursor optional enhancement  

---

## Contributing to Framework Development

This assessment framework welcomes contributions from the security community:

- 📝 **Share Assessment Findings** - Submit anonymized case studies and results
- 🔍 **Review Methodology** - Provide feedback on assessment approaches
- 🛠️ **Extend Framework** - Contribute new validation modules or controls
- 📊 **Data Analysis** - Share insights from framework execution

See our [contribution guidelines](/about/contributing) for more information.

---

## Disclaimer

{: .warning }
This assessment framework is provided "as-is" for educational and informational purposes. Always obtain proper authorization before assessing Azure environments. Consult with your organization's security team before implementing recommendations. The framework team is not responsible for any issues resulting from the use of this framework.

---

## License

This research is published under the [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).

You are free to:
- **Share** - Copy and redistribute the material
- **Adapt** - Remix, transform, and build upon the material

Under the terms:
- **Attribution** - Give appropriate credit and indicate if changes were made

---

## Contact & Social

- **Research Wiki**: [GitHub Pages URL]
- **GitHub Repository**: [https://github.com/yourusername/cursor-security-research](https://github.com/yourusername/cursor-security-research)
- **Twitter/X**: [@yourhandle](#)
- **LinkedIn**: [Your Profile](#)
- **Research Blog**: [Your Blog](#)

---

**Last Updated**: {{ "now" | date: "%B %d, %Y" }}  
**Wiki Version**: 1.0  
**Research Status**: Active

