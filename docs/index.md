---
layout: default
title: Home
nav_order: 1
description: "Enterprise security research for Cursor IDE administration with Azure AI Foundry integration"
permalink: /
---

# SecAI Framework
{: .fs-9 }

The Security Framework for AI-Accelerated Development
{: .fs-6 .fw-300 }

Enterprise-grade security research and practical guidance for securing Cursor IDE, Azure AI Foundry, and AI development workflows.
{: .fs-5 .fw-300 }

[Get Started](/getting-started/){: .btn .btn-primary .fs-5 .mb-4 .mb-md-0 .mr-2 }
[View on GitHub](https://github.com/zimaxnet/secai-framework){: .btn .fs-5 .mb-4 .mb-md-0 }

---

## 🛠️ Implementation Package Available!
{: .label .label-green }

The **complete technical implementation** is now available in this repository!

**[→ Browse Implementation Folder](https://github.com/zimaxnet/secai-framework/tree/main/implementation){: .btn .btn-purple }**

The `implementation/` folder contains:
- ✅ **PowerShell Scripts** - Data collection scripts (00-10) for Azure assessments
- ✅ **Python Tools** - Transformation (11-17) and analysis (18-19) scripts
- ✅ **Excel Templates** - Assessment workbooks with 12 security domains
- ✅ **HTML Dashboards** - Team-specific report templates
- ✅ **Documentation** - 35+ implementation guides and execution procedures
- ✅ **Three-Dimensional Assessment** - Configuration, Process, and Best Practices methodology

Perfect for: Azure security assessments, CSP-to-MCA migrations, Landing Zone validations, and compliance audits.

[Implementation README](https://github.com/zimaxnet/secai-framework/blob/main/implementation/README.md){: .btn .btn-outline }
[Quick Start Guide](https://github.com/zimaxnet/secai-framework/blob/main/implementation/QUICK_START.md){: .btn .btn-outline }
---

## About the SecAI Framework

The **SecAI Framework** is a comprehensive security framework for AI-accelerated development, focusing on **Cursor IDE** and **Azure AI Foundry**. Created from a security architect's perspective, the framework provides:

- 🔐 **Security Architecture** - Zero-trust models, tenant isolation, data flow controls
- ☁️ **Azure AI Foundry Integration** - Keeping AI compute and data within Azure tenant
- 📋 **Security Policies** - Templates, guidelines, and governance frameworks
- 🔍 **Model Selection** - Evaluating AI models for security, privacy, and compliance
- 🛠️ **MCP Server Security** - Securing Model Context Protocol integrations
- 📊 **Real-World Case Studies** - Sanitized examples from production deployments

### Research Objectives

{: .note }
This is an **active research project** documenting findings and best practices for public consumption. Research is conducted by security professionals evaluating enterprise-grade Cursor deployments.

**Primary Goals:**
1. Document secure Cursor administration patterns for enterprise teams
2. Establish Azure AI Foundry integration best practices
3. Create reusable security policy templates and SOPs
4. Compare security models across AI development tools
5. Publish findings to help the broader security community

---

## Why Azure AI Foundry?

Azure AI Foundry (formerly Azure AI Studio) provides enterprise teams with:

✅ **Data Sovereignty** - All AI processing stays within your Azure tenant  
✅ **Compliance** - SOC 2, ISO 27001, HIPAA, FedRAMP certified infrastructure  
✅ **Audit & Governance** - Complete audit trails via Azure Monitor and Log Analytics  
✅ **Network Isolation** - Private endpoints, VNet integration, no public internet exposure  
✅ **Enterprise Controls** - RBAC, Conditional Access, PIM for just-in-time access  

By integrating Cursor with Azure AI Foundry, enterprises can leverage AI-accelerated development while maintaining strict security and compliance standards.

---

## Quick Navigation

<div class="grid grid-cols-3 gap-4">
  <div class="col">
    <h3>🚀 Getting Started</h3>
    <ul>
      <li><a href="/getting-started/">Overview</a></li>
      <li><a href="/getting-started/prerequisites">Prerequisites</a></li>
      <li><a href="/getting-started/cursor-setup">Cursor Setup</a></li>
      <li><a href="/getting-started/azure-ai-foundry-integration">Azure AI Foundry Integration</a></li>
    </ul>
  </div>
  
  <div class="col">
    <h3>🔐 Security</h3>
    <ul>
      <li><a href="/security-architecture/">Architecture Overview</a></li>
      <li><a href="/security-architecture/data-flow-diagrams">Data Flow Diagrams</a></li>
      <li><a href="/security-architecture/tenant-isolation">Tenant Isolation</a></li>
      <li><a href="/security-architecture/compliance-considerations">Compliance</a></li>
    </ul>
  </div>
  
  <div class="col">
    <h3>📋 Policies</h3>
    <ul>
      <li><a href="/security-policies/">Policy Templates</a></li>
      <li><a href="/security-policies/secrets-management">Secrets Management</a></li>
      <li><a href="/security-policies/team-guidelines">Team Guidelines</a></li>
      <li><a href="/security-policies/cursorignore-best-practices">.cursorignore Best Practices</a></li>
    </ul>
  </div>
</div>

---

## Research Methodology

Our research combines:

- **Security Architecture Review** - Analyzing Cursor's security model, data flows, and privacy controls
- **Azure Integration Testing** - Hands-on configuration of Cursor with Azure AI Foundry endpoints
- **Policy Development** - Creating security policies and SOPs based on enterprise requirements
- **Compliance Mapping** - Aligning configurations with CIS, NIST, ISO 27001, and CSA frameworks
- **Real-World Validation** - Testing policies with confidential customer programs (sanitized for publication)

### Research Team

**Lead Researcher**: Derek Brent Moore - Security Architect  
**Organization**: [Your Limited Corporation]  
**Publication**: Findings published to this wiki and shared via social media

---

## Key Research Areas

### 1. Cursor Enterprise Administration
- Privacy Mode configuration and enforcement
- SSO/SCIM integration with Azure Entra ID
- Telemetry and data retention controls
- Extension security and allowlisting
- Audit logging and monitoring

### 2. Azure AI Foundry Integration
- Configuring Cursor with Azure OpenAI endpoints
- Private endpoint configuration for network isolation
- API key vs. Entra ID authentication
- Model deployment security
- Cost management and quotas

### 3. Security Policies & Governance
- Secrets management best practices
- Team guidelines for safe AI usage
- Incident response procedures
- Compliance documentation templates
- Risk assessment frameworks

### 4. Model Selection & Security
- Comparing Azure OpenAI models (GPT-4, GPT-4 Turbo, o1, etc.)
- Security properties of different model families
- Data residency and sovereignty considerations
- Performance vs. security trade-offs
- Model fine-tuning security implications

### 5. MCP Server Security
- Evaluating GitHub MCP servers for Cursor
- Azure DevOps MCP integration security
- Custom MCP server development guidelines
- Transport security (stdio, SSE, HTTP)
- Authentication and authorization patterns

---

## Latest Updates

<span class="badge badge-new">NEW</span> **Oct 2025** - Wiki launched with initial research structure  
<span class="badge badge-research">RESEARCH</span> **Oct 2025** - Azure AI Foundry integration guide in progress  
<span class="badge badge-updated">UPDATED</span> **Oct 2025** - Security architecture diagrams added  

---

## Contributing to Research

This research project welcomes contributions from the security community:

- 📝 **Share Your Experiences** - Submit anonymized case studies
- 🔍 **Review Findings** - Provide feedback on documented practices
- 🛠️ **Test Configurations** - Validate security configurations in your environment
- 📊 **Data Analysis** - Contribute security metrics and KPIs

See our [contribution guidelines](/about/contributing) for more information.

---

## Disclaimer

{: .warning }
This research is provided "as-is" for educational and informational purposes. Always consult with your organization's security team before implementing any configurations. The research team is not responsible for any security incidents resulting from the use of this information.

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

