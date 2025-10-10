---
layout: default
title: Qualys VMDR
parent: Security Tools & Vendors
nav_order: 15
---

# Qualys - Vulnerability Management, Detection & Response
{: .no_toc }

Comprehensive analysis of Qualys VMDR platform for continuous vulnerability management.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

**Qualys** is a pioneer and leader in cloud-based vulnerability management and compliance solutions. The Qualys VMDR (Vulnerability Management, Detection, and Response) platform provides continuous monitoring, detection, and automated response to vulnerabilities across IT assets.

### Vendor Information

| | |
|---|---|
| **Company** | Qualys, Inc. |
| **Founded** | 1999 |
| **Headquarters** | Foster City, CA |
| **Founders** | Philippe Courtot (former CEO), Gerhard Eschelbeck |
| **Website** | [https://www.qualys.com](https://www.qualys.com) |
| **Status** | Public (NASDAQ: QLYS) |
| **Notable** | First pure SaaS security company, 25+ years |

---

## Core Capabilities

### 1. Vulnerability Scanning

**Comprehensive Asset Scanning**:
```
Qualys Scans:
├── Network Devices
│   ├── Routers, switches
│   ├── Firewalls (Azure Firewall via API)
│   └── VPN concentrators
│
├── Servers
│   ├── Azure VMs
│   ├── On-prem servers
│   ├── Linux and Windows
│   └── Cloud workloads
│
├── Endpoints
│   ├── Developer workstations
│   ├── Laptops (with Cursor IDE)
│   └── Mobile devices
│
├── Web Applications
│   ├── Internal portals
│   ├── Azure-hosted apps
│   └── Custom applications
│
├── Containers
│   ├── Docker images
│   ├── Kubernetes clusters
│   └── Azure Container Instances
│
└── Databases
    ├── Azure SQL
    ├── Cosmos DB
    └── PostgreSQL/MySQL
```

**Scan Types**:
```yaml
authenticated_scan:
  - uses_credentials: true
  - depth: comprehensive
  - finds: configuration issues, missing patches, weak passwords
  - coverage: 100% of accessible systems
  
unauthenticated_scan:
  - uses_credentials: false
  - depth: external view
  - finds: exposed services, known vulnerabilities
  - coverage: external attack surface
  
agent_based_scan:
  - lightweight_agent: Qualys Cloud Agent
  - continuous_monitoring: true
  - real_time_detection: true
  - no_scan_windows: true
```

### 2. Vulnerability Detection & Response

**Automated Remediation Workflow**:
```
Detection → Prioritization → Remediation → Validation

Example: Critical Azure VM Vulnerability
1. Qualys detects: CVE-2024-12345 on vm-cursor-dev-01
2. VMDR evaluates:
   ├── CVSS Score: 9.8 (Critical)
   ├── Exploitability: High
   ├── Asset criticality: Medium (dev environment)
   ├── Patch available: Yes
   └── Risk score: 95/100

3. VMDR prioritizes: Fix within 24 hours

4. Automated remediation:
   ├── Create Azure DevOps ticket
   ├── Assign to VM owner (John Developer)
   ├── Attach patch instructions
   ├── Set SLA: 24 hours
   └── Escalate if not completed

5. Validation:
   ├── Qualys rescans VM
   ├── Confirms patch applied
   ├── Closes ticket
   └── Updates dashboard
```

### 3. Asset Inventory

**Continuous Asset Discovery**:
```
Qualys Asset View:
├── Total Assets: 575
│   ├── Critical: 45 (Azure OpenAI, Key Vault, prod systems)
│   ├── High: 120 (PreProd, important dev resources)
│   ├── Medium: 250 (Test/UAT systems)
│   └── Low: 160 (Dev, temporary resources)
│
├── By Type:
│   ├── Azure VMs: 125
│   ├── Azure App Services: 80
│   ├── Containers: 150
│   ├── Databases: 35
│   ├── Endpoints: 185
│   └── Network devices: 0 (cloud-only)
│
├── By Operating System:
│   ├── Windows Server: 85
│   ├── Ubuntu Linux: 95
│   ├── RedHat Enterprise: 30
│   ├── Windows 10/11: 180
│   └── macOS: 5
│
└── By Vulnerability Status:
    ├── Critical vulns: 8 assets
    ├── High vulns: 45 assets
    ├── Medium vulns: 220 assets
    ├── Low vulns: 450 assets
    └── Clean: 125 assets
```

### 4. Compliance & Reporting

**Built-In Compliance Frameworks**:
```
Qualys Compliance Modules:
├── PCI-DSS (Payment Card Industry)
│   └── For payment processing systems
│
├── HIPAA (Healthcare)
│   └── If processing health data
│
├── SOC 2
│   └── Trust services criteria validation
│
├── NIST 800-53
│   └── Federal compliance
│
├── CIS Benchmarks
│   ├── CIS Azure Foundations
│   ├── CIS Windows
│   └── CIS Linux
│
└── Custom Policies
    └── Organization-specific requirements
```

**Compliance Dashboard**:
```
PCI-DSS Compliance Status:
├── Requirement 6.2: Patch Critical Vulnerabilities
│   ├── Status: 92% compliant
│   ├── Non-compliant: 8 assets with critical vulns >30 days
│   └── Action: Remediate or document exception
│
├── Requirement 11.2: Quarterly Network Scans
│   ├── Status: ✅ Compliant
│   ├── Last scan: 2024-10-05
│   └── Next scan: 2025-01-05
│
└── Overall PCI-DSS Status: 95% compliant
```

---

## Integration with Cursor Environment

### Scanning Azure Resources

**Azure Integration**:
```bash
# Qualys Azure Connector
# Discovers and scans all Azure resources

qualys_azure_config:
  subscription_id: "xxxx-xxxx-xxxx"
  tenant_id: "yyyy-yyyy-yyyy"
  service_principal:
    app_id: "zzz-zzz-zzz"
    secret: "${QUALYS_SP_SECRET}"  # From Key Vault
  
  scan_scope:
    resource_groups:
      - "rg-cursor-ai-*"
      - "rg-prod-*"
      - "rg-preprod-*"
    
    exclude:
      - "rg-temp-*"  # Temporary resources
      - "rg-sandbox-*"  # Sandbox testing
  
  scan_schedule:
    frequency: daily
    time: "02:00 UTC"  # Off-peak hours
    
  findings_integration:
    - Azure Security Center
    - Azure Sentinel
    - Chronicle SIEM
```

**Azure-Specific Checks**:
```
Qualys Azure Policy Compliance:
├── Azure OpenAI
│   ├── Public network access: should be Disabled
│   ├── Diagnostic logging: must be Enabled
│   ├── RBAC: least privilege validation
│   └── API version: check for outdated
│
├── Key Vault
│   ├── Soft delete: must be Enabled
│   ├── Purge protection: must be Enabled
│   ├── Public access: should be Disabled
│   ├── Private endpoint: should exist
│   └── RBAC: no overly broad permissions
│
├── Storage Accounts
│   ├── Public blob access: should be Disabled
│   ├── HTTPS required: must be Enforced
│   ├── TLS version: minimum 1.2
│   └── Encryption: verify enabled
│
└── Virtual Networks
    ├── NSG rules: no 0.0.0.0/0 inbound
    ├── DDoS protection: should be enabled
    └── Service endpoints: validated
```

### 2. Developer Workstation Scanning

**Endpoint Agent**:
```bash
# Qualys Cloud Agent on developer laptops
# Lightweight, continuous scanning

agent_capabilities:
  - vulnerability_detection: true
  - patch_management: true
  - malware_detection: false  # Use CrowdStrike for this
  - inventory_tracking: true
  - compliance_validation: true
  
  performance_impact:
    cpu: <2%
    memory: ~100 MB
    disk: ~200 MB
  
  scan_frequency:
    - real_time_monitoring: critical vulnerabilities
    - daily_scan: comprehensive check
    - weekly_deep_scan: full system analysis
```

**Findings Example**:
```
Workstation: LAPTOP-DEV-042
User: john.developer@company.com

Critical Vulnerabilities (2):
├── CVE-2024-XXXXX: Windows privilege escalation
│   ├── CVSS: 9.8
│   ├── Patch: Available
│   ├── Remediate: Install KB5043936
│   └── SLA: 7 days
│
└── CVE-2024-YYYYY: npm vulnerability
    ├── CVSS: 8.5
    ├── Package: old-jwt-lib@1.2.3
    ├── Remediate: Update to 2.0.1
    └── SLA: 30 days

High Vulnerabilities (8):
- Details available in Qualys console

Action: Auto-created tickets for john.developer
```

---

## Pricing Model

### Per-Asset Licensing

```
Qualys VMDR Pricing:
├── Per asset: $400-800/asset/year
│   └── Asset = IP address, endpoint, cloud resource
│
├── Volume discounts:
│   ├── 1-100 assets: $700/asset
│   ├── 100-500 assets: $550/asset
│   ├── 500-1000 assets: $450/asset
│   └── 1000+ assets: $400/asset (negotiated)
│
└── Modules (add-ons):
    ├── Policy Compliance: +$100/asset
    ├── Web App Scanning: +$150/asset
    ├── Container Security: +$75/asset
    └── Patch Management: +$125/asset

Example Cost (575 assets):
575 assets × $450/asset = $258,750/year
With modules: ~$300K/year

Compare to:
- Manual vulnerability management: 2 FTE = $300K/year + slower
- Breach from unpatched vuln: $4M average
- ROI: Significant
```

---

## Strengths & Weaknesses

### Strengths ✅

1. **Comprehensive Coverage**: VMs, endpoints, containers, cloud
2. **Continuous Scanning**: Daily or real-time monitoring
3. **Azure Integration**: Native cloud connector
4. **Compliance Built-In**: PCI, HIPAA, NIST, CIS
5. **Mature Platform**: 25 years of development

### Weaknesses ⚠️

1. **Cost**: Expensive at scale ($400-800 per asset)
2. **Complexity**: Feature-rich but complex UI
3. **Overlap with Wiz**: Some capability duplication
4. **Agent Overhead**: On endpoints (minimal but present)

---

## Qualys vs. Wiz

**Why Customer Might Use Both** (or choose one):

| Capability | Qualys | Wiz | Winner |
|------------|--------|-----|--------|
| VM Vulnerability Scanning | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Qualys |
| Cloud Security Posture | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Wiz |
| Container Security | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Wiz |
| Endpoint Scanning | ⭐⭐⭐⭐⭐ | ❌ None | Qualys |
| Compliance Reporting | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Qualys |
| Ease of Use | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Wiz |
| Cost | $$$ | $$ | Wiz |

**Customer Decision**:
```
If using Wiz already:
- Qualys adds: Endpoint vulnerability scanning, compliance reporting
- Consider: Is endpoint scanning worth $300K/year?
- Alternative: Microsoft Defender for Endpoint (included in E5)

If NOT using Wiz:
- Qualys provides: Comprehensive vulnerability management
- Consider: Qualys strong choice for traditional environments
```

---

## Resources & Links

- **Website**: [https://www.qualys.com](https://www.qualys.com)
- **Documentation**: [https://qualysguard.qg2.apps.qualys.com/qwebhelp/fo_portal/index.htm](https://qualysguard.qg2.apps.qualys.com/qwebhelp/fo_portal/index.htm)
- **Community**: [Qualys Community](https://community.qualys.com)
- **Training**: [Qualys Learning Center](https://www.qualys.com/training/)

---

**Last Updated**: October 10, 2025  
**Review Status**: <span class="badge badge-security">Validated</span>

