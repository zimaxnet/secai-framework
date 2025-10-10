---
layout: default
title: Wiz Cloud Security
parent: Security Tools & Vendors
nav_order: 1
---

# Wiz - Cloud Native Application Protection Platform (CNAPP)
{: .no_toc }

Comprehensive analysis of Wiz cloud security platform and its role in Cursor security architecture.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

**Wiz** is an agentless Cloud Native Application Protection Platform (CNAPP) that provides comprehensive security for cloud environments including Azure, AWS, and GCP.

### Vendor Information

| | |
|---|---|
| **Company** | Wiz, Inc. |
| **Founded** | 2020 |
| **Headquarters** | New York, NY |
| **Founders** | Assaf Rappaport, Yinon Costica, Roy Reznik, Ami Luttwak |
| **Website** | [https://www.wiz.io](https://www.wiz.io) |
| **Status** | Private (Unicorn, $12B+ valuation) |
| **Notable** | Founded by former Microsoft Azure Security leaders |

---

## Core Capabilities

### 1. Cloud Security Posture Management (CSPM)

**What It Does**:
- Continuously scans cloud configurations
- Identifies misconfigurations and compliance violations
- Provides remediation guidance
- Tracks compliance with CIS, NIST, PCI-DSS, HIPAA

**For Cursor Deployments**:
```
Wiz monitors:
├── Azure OpenAI resource configurations
├── Key Vault security settings
├── Virtual Network configurations
├── Private Endpoint security
├── Azure Firewall rules
├── Storage account encryption
└── RBAC assignments
```

**Example Findings**:
- ⚠️ Azure OpenAI has public network access enabled
- ⚠️ Key Vault missing diagnostic logging
- ✅ All storage accounts have encryption at rest
- ⚠️ RBAC permissions too broad on 3 service principals

### 2. Cloud Workload Protection (CWPP)

**Capabilities**:
- Vulnerability scanning for VMs and containers
- Runtime threat detection
- Secrets scanning in container images
- Malware detection

**For Cursor Environment**:
- Scans container images used for development
- Detects vulnerabilities in Cursor devcontainer images
- Identifies exposed secrets in container layers

### 3. Container Security

**Features**:
- Agentless container image scanning
- Kubernetes security posture
- Container registry scanning
- Runtime protection

**Integration with Cursor**:
```yaml
# Example: Wiz detects issues in Cursor devcontainer
Finding:
  Resource: devcontainer:cursor-azure-dev:latest
  Issue: High-severity CVE in base image
  CVE: CVE-2024-XXXXX (npm vulnerability)
  Recommendation: Update base image to node:20-alpine
  Risk Score: 8.5/10
```

### 4. Identity & Access Analysis

**Capabilities**:
- Effective permissions mapping
- Identifies overprivileged identities
- Detects unused permissions
- Cross-cloud identity analysis

**For Azure OpenAI**:
```
Wiz Analysis:
├── Service Principal: cursor-api-access
│   ├── Assigned: Cognitive Services Contributor (too broad)
│   ├── Actually Uses: Only read/inference operations
│   ├── Recommendation: Use "Cognitive Services User" instead
│   └── Risk Reduction: 70%
```

---

## Architecture & Integration

### Agentless Scanning

**How It Works**:
1. **Read-only API access** to Azure subscription
2. **Snapshot-based scanning** of disk volumes (no production impact)
3. **Memory-based analysis** without requiring agents
4. **Continuous monitoring** (scans every few hours)

**Benefits for Cursor**:
- ✅ No performance impact on Azure OpenAI
- ✅ No agent maintenance overhead
- ✅ Immediate deployment (no agent rollout)
- ✅ Complete visibility without endpoint access

### Azure Integration

**Permissions Required**:
```bash
# Azure service principal for Wiz
az ad sp create-for-rbac \
  --name "Wiz-Scanner" \
  --role "Reader" \
  --scopes /subscriptions/{subscription-id}

# Additional permissions for advanced features
az role assignment create \
  --role "Storage Blob Data Reader" \
  --assignee {wiz-sp-id} \
  --scope /subscriptions/{subscription-id}
```

**Data Sources**:
- Azure Resource Manager API
- Azure Security Center
- Azure Activity Logs
- Azure Policy compliance data
- Microsoft Defender for Cloud alerts

---

## Key Features for Cursor Security

### 1. Secrets Detection

**Capability**: Scans all cloud resources for exposed secrets

**What It Finds**:
- API keys in VM metadata
- Secrets in container environment variables
- Credentials in Azure App Configuration
- Keys in Azure Functions configuration
- Passwords in automation scripts

**Alert Example**:
```
🚨 Secret Detected
Resource: Azure Function - cursor-api-proxy
Type: Azure OpenAI API Key
Location: Application Settings
Risk: CRITICAL
Recommendation: Move to Key Vault, use Managed Identity
```

### 2. Network Exposure Analysis

**Capability**: Maps network paths and identifies exposure risks

**For Cursor Architecture**:
```
Wiz Network Graph:
Internet
  ↓
  ✅ Azure Firewall (locked down)
  ↓
  ❌ Azure OpenAI (public endpoint exposed!) 
      → Recommendation: Enable private endpoint
```

### 3. Compliance Monitoring

**Frameworks Supported**:
- CIS Azure Foundations Benchmark
- NIST 800-53
- PCI-DSS
- HIPAA
- SOC 2
- ISO 27001
- Custom frameworks

**Example Compliance Report**:
```
CIS Azure Foundations 1.4.0
├── 3.1 Key Vault Encryption: ✅ Pass
├── 3.8 Key Vault Recoverable: ✅ Pass
├── 6.1 Network Watcher: ⚠️ Fail (Not enabled in all regions)
└── 9.1 App Service Authentication: ✅ Pass

Overall Compliance: 87%
```

---

## Integration with Cursor Workflow

### Pre-Deployment Scanning

Before deploying Cursor infrastructure:

```bash
# Infrastructure as Code scanning
# Wiz CLI scans Bicep/Terraform before deployment

wiz-cli iac scan ./azure-infrastructure/

# Results:
# ✅ Key Vault configured securely
# ⚠️ Azure OpenAI missing private endpoint (HIGH)
# ⚠️ NSG rules too permissive (MEDIUM)
# ✅ Storage accounts have encryption
```

### Runtime Monitoring

Continuous monitoring of deployed Cursor environment:

**Dashboard Widgets**:
1. **Critical Issues**: 0 (target)
2. **High Severity**: 2 (API keys in App Settings)
3. **Medium Severity**: 5 (NSG rule optimization)
4. **Compliance Score**: 92% (CIS Azure)

### Incident Response Integration

**Wiz → SIEM Integration**:
```python
# Wiz webhook → EventHub → Cribl → Chronicle

# Example Wiz alert
{
  "alert_id": "WIZ-2024-12345",
  "severity": "CRITICAL",
  "type": "Secret Exposed",
  "resource": "az-openai-cursor-prod",
  "finding": "Azure OpenAI API key found in Application Insights logs",
  "recommendation": "Rotate key immediately, remove from logs",
  "timestamp": "2024-10-10T14:32:00Z"
}
```

---

## Pricing Model

### Licensing Structure

**Per-Workload Pricing**:
- Charged per cloud workload (VM, container, serverless function)
- Typically $2-5 per workload per month
- Volume discounts available

**Example Cost** (Cursor environment with 50 developers):
```
Workloads:
├── 10 VMs (Azure VMs for build servers): $30/month
├── 50 Container images: $150/month
├── 20 Azure Functions: $60/month
├── 5 Azure OpenAI instances: $15/month
└── 100 other Azure resources: $300/month

Total: ~$555/month
Annual: ~$6,660

ROI: Prevents 1-2 critical security incidents = 10-50x return
```

---

## Strengths & Weaknesses

### Strengths ✅

1. **Agentless Architecture**
   - No performance impact
   - Immediate deployment
   - No agent maintenance

2. **Comprehensive Coverage**
   - All Azure resources
   - Multi-cloud support
   - Deep visibility

3. **Fast Time to Value**
   - Deploy in hours, not weeks
   - Immediate findings
   - Quick remediation

4. **Excellent UX**
   - Intuitive dashboard
   - Clear remediation steps
   - Risk-based prioritization

5. **API & Automation**
   - Strong API for automation
   - CLI for CI/CD integration
   - Webhook support

### Weaknesses ⚠️

1. **Cost at Scale**
   - Can get expensive with many workloads
   - Per-resource pricing adds up

2. **Alert Fatigue**
   - High volume of findings initially
   - Requires tuning and prioritization

3. **Limited Runtime Protection**
   - Agentless = less runtime visibility
   - Some advanced threats require agents

4. **Relatively New**
   - Founded in 2020 (vs established vendors)
   - Rapid feature additions = some instability

---

## Best Practices for Wiz with Cursor

### 1. Scope Wiz Scanning

**Focus on Critical Resources**:
```yaml
# Wiz project configuration
projects:
  - name: "Cursor-AI-Infrastructure"
    scope:
      - resource_groups: ["rg-cursor-ai-*"]
      - tags: ["project:cursor", "environment:prod"]
    priority: HIGH
    
  - name: "Development-Environments"
    scope:
      - resource_groups: ["rg-dev-*"]
    priority: MEDIUM
```

### 2. Automate Remediation

**Example**: Auto-fix non-compliant resources

```python
# Wiz webhook → Azure Function → Auto-remediate

def handle_wiz_alert(alert):
    if alert['type'] == 'public_network_access_enabled':
        resource_id = alert['resource_id']
        
        # Auto-remediate: Disable public access
        subprocess.run([
            'az', 'cognitiveservices', 'account', 'update',
            '--ids', resource_id,
            '--public-network-access', 'Disabled'
        ])
        
        # Verify private endpoint exists
        # ...
```

### 3. Integrate with CI/CD

**Pre-deployment Scanning**:
```yaml
# Azure DevOps pipeline
- task: WizCLI@1
  inputs:
    command: 'iac scan'
    path: './infrastructure'
    failOnHighSeverity: true
```

### 4. Create Custom Policies

**Example**: Cursor-specific security policy

```yaml
# Custom Wiz policy: Cursor Security Requirements
policy:
  name: "Cursor AI Security Policy"
  rules:
    - name: "Azure OpenAI must use private endpoints"
      resource_type: "Microsoft.CognitiveServices"
      condition: "networkAcls.defaultAction == 'Deny'"
      severity: HIGH
      
    - name: "Key Vault must have soft delete enabled"
      resource_type: "Microsoft.KeyVault"
      condition: "properties.enableSoftDelete == true"
      severity: CRITICAL
```

---

## Alternatives to Wiz

| Alternative | Strengths | Weaknesses |
|-------------|-----------|------------|
| **Prisma Cloud** | Mature, comprehensive | Agent-based, complex setup |
| **Orca Security** | Agentless, similar to Wiz | Fewer features, smaller company |
| **Aqua Security** | Strong container focus | Less cloud-native |
| **Microsoft Defender for Cloud** | Native Azure, included | Less comprehensive than Wiz |

### Why Customer Chose Wiz

1. **Agentless approach** preferred over Prisma Cloud agents
2. **Better UX** than Microsoft Defender
3. **Comprehensive coverage** across all Azure services
4. **Strong API** for automation
5. **Rapid innovation** and feature releases

---

## Integration with Other Tools

### Wiz + CrowdStrike

**Complementary, Not Overlapping**:
- **Wiz**: Cloud workloads, configurations, vulnerabilities
- **CrowdStrike**: Endpoint detection, runtime threats, incident response

**Data Sharing**:
```
Wiz finds vulnerability in Azure VM
  ↓
Wiz API → Chronicle SIEM
  ↓
Correlate with CrowdStrike endpoint data
  ↓
Unified security view: Cloud posture + endpoint threats
```

### Wiz + Veracode

**Different Focus**:
- **Wiz**: Infrastructure, cloud configs, deployed workloads
- **Veracode**: Source code, application vulnerabilities, dependencies

**Example Workflow**:
```
1. Developer writes code → Veracode SAST scan (pre-commit)
2. Code deployed to Azure → Wiz scans deployed infrastructure
3. Wiz finds misconfiguration → Alert to security team
4. Veracode finds code vulnerability → Block deployment
```

---

## Resources & Links

### Official Resources

- **Website**: [https://www.wiz.io](https://www.wiz.io)
- **Documentation**: [https://docs.wiz.io](https://docs.wiz.io)
- **Blog**: [https://www.wiz.io/blog](https://www.wiz.io/blog)
- **Trust Portal**: [https://trust.wiz.io](https://trust.wiz.io)

### Learning Resources

- **Wiz Academy**: Free training and certifications
- **Community Slack**: Active user community
- **YouTube Channel**: Product demos and tutorials
- **GitHub**: [https://github.com/wiz-sec](https://github.com/wiz-sec)

### API & Integration

- **API Documentation**: REST API for automation
- **Terraform Provider**: Infrastructure as code
- **Kubernetes Admission Controller**: Policy enforcement
- **CI/CD Plugins**: Jenkins, GitHub Actions, Azure DevOps

---

## Conclusion

**For Cursor Security Architecture**:

Wiz provides **comprehensive cloud security visibility** without performance impact. Its agentless architecture is ideal for securing Azure AI Foundry deployments, Key Vault configurations, and network security.

**Key Value Props for Cursor**:
1. ✅ Validates Azure OpenAI security configurations
2. ✅ Detects exposed secrets in cloud resources
3. ✅ Ensures compliance with security frameworks
4. ✅ No agent overhead on production workloads
5. ✅ Fast time to value (deploy in hours)

**Recommendation**: **Essential tool** for any enterprise Cursor deployment on Azure.

---

**Last Updated**: October 10, 2025  
**Review Status**: <span class="badge badge-security">Security Validated</span>

