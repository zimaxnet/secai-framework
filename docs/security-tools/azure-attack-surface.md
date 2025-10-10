---
layout: default
title: Azure Attack Surface Management
parent: Security Tools & Vendors
nav_order: 16
---

# Microsoft Defender External Attack Surface Management (EASM)
{: .no_toc }

Analysis of Azure's native attack surface management capabilities for Cursor deployments.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

**Microsoft Defender External Attack Surface Management (EASM)** is Azure's native solution for discovering, monitoring, and securing your organization's external attack surface. It provides continuous visibility into internet-facing assets and identifies security risks.

### Service Information

| | |
|---|---|
| **Service** | Microsoft Defender EASM |
| **Provider** | Microsoft Azure |
| **Launched** | 2022 (GA), evolved from RiskIQ acquisition |
| **Integration** | Native Azure, Microsoft Defender XDR |
| **Website** | [https://azure.microsoft.com/products/defender-external-attack-surface-management](https://azure.microsoft.com/products/defender-external-attack-surface-management) |
| **Pricing Model** | Per-asset monitoring |
| **Notable** | Built on RiskIQ technology (Microsoft acquired 2021) |

---

## Core Capabilities

### 1. Asset Discovery

**Automated External Asset Discovery**:
```
EASM Discovers:
├── Azure Resources (Public-Facing)
│   ├── Azure OpenAI (if public endpoint enabled)
│   ├── App Services with public access
│   ├── Storage Accounts (anonymous access)
│   ├── API Management gateways
│   ├── Application Gateway/Load Balancers
│   └── Public IPs and DNS
│
├── Domains & Subdomains
│   ├── company.com
│   ├── *.company.com (wildcard discovery)
│   ├── cursor-api.company.com
│   ├── dev-aoai.company.com
│   └── Forgotten/orphaned subdomains
│
├── SSL/TLS Certificates
│   ├── Active certificates
│   ├── Expiring certificates
│   ├── Self-signed certificates
│   └── Certificate chain issues
│
├── IP Addresses
│   ├── Azure public IPs
│   ├── Historical IP associations
│   └── Third-party hosted assets
│
└── Technologies Detected
    ├── Web servers (nginx, IIS)
    ├── Frameworks (.NET, Node.js)
    ├── Cloud providers
    └── CDNs and hosting
```

**Discovery Process**:
```
Seed → Crawl → Validate → Monitor

1. Seed Data (you provide):
   - company.com
   - Known Azure subscriptions
   - IP ranges
   
2. EASM Crawls:
   - DNS enumeration
   - Certificate transparency logs
   - WHOIS data
   - Autonomous System Numbers (ASN)
   - Historical data (from RiskIQ)
   
3. Validates Assets:
   - Confirms ownership
   - Categorizes by type
   - Assesses criticality
   
4. Continuous Monitoring:
   - Daily rescans
   - Change detection
   - New asset alerts
```

### 2. Risk & Vulnerability Assessment

**Attack Surface Insights**:
```yaml
easm_risk_assessment:
  asset: "aoai-cursor-dev.openai.azure.com"
  
  findings:
    - risk: "Public network access enabled"
      severity: HIGH
      recommendation: "Enable private endpoint only"
      remediation: "az cognitiveservices account update --public-network-access Disabled"
      
    - risk: "Diagnostic logging not configured"
      severity: MEDIUM
      recommendation: "Enable audit logging to Log Analytics"
      
    - risk: "No WAF protection"
      severity: MEDIUM
      recommendation: "Deploy Azure Application Gateway with WAF"
      
    - risk: "Geo-restriction not configured"
      severity: LOW
      recommendation: "Restrict access to US regions only"
  
  risk_score: 72/100 (Medium-High)
  priority: "Fix within 30 days"
```

### 3. Integration with Microsoft Defender XDR

**Unified Security Portal**:
```
Microsoft Defender Portal (security.microsoft.com):
├── Defender for Endpoint (CrowdStrike alternative)
├── Defender for Cloud (Wiz alternative)
├── Defender for Identity
├── Defender EASM
└── Microsoft Sentinel

Benefit: Single pane of glass for Microsoft security

EASM Findings → Defender XDR:
  ↓
Correlation with:
  - Endpoint detections
  - Identity anomalies
  - Cloud misconfigurations
  - Threat intelligence
  ↓
Unified Incident:
  "External asset vulnerable + active exploitation detected"
```

### 4. Threat Intelligence Integration

**Microsoft Threat Intelligence**:
```
EASM enrichment sources:
├── RiskIQ threat data (Microsoft-owned)
├── Microsoft Threat Intelligence Center (MSTIC)
├── Azure Sentinel threat feeds
├── VirusTotal (for malware)
└── OSINT sources

Example:
EASM discovers: cursor-api.company.com
  ↓
Threat Intel Check:
  - Domain age: 2 years
  - Reputation: Clean
  - Malware associated: None
  - SSL cert: Valid, trusted CA
  - Historical incidents: None
  ↓
Risk: Low
```

---

## Comparison: EASM vs. UpGuard

### Feature Comparison

| Feature | Azure EASM | UpGuard | Winner |
|---------|------------|---------|--------|
| **Azure Integration** | ⭐⭐⭐⭐⭐ Native | ⭐⭐⭐ API | Azure EASM |
| **Asset Discovery** | ⭐⭐⭐⭐ Good | ⭐⭐⭐⭐⭐ Excellent | UpGuard |
| **Vendor Monitoring** | ❌ None | ⭐⭐⭐⭐⭐ Core feature | UpGuard |
| **Data Leak Detection** | ⚠️ Limited | ⭐⭐⭐⭐⭐ Excellent | UpGuard |
| **Threat Intelligence** | ⭐⭐⭐⭐⭐ Microsoft | ⭐⭐⭐⭐ Good | Azure EASM |
| **Pricing** | $$ | $$$ | Azure EASM |
| **Microsoft 365 Integration** | ⭐⭐⭐⭐⭐ | ⭐⭐ | Azure EASM |

### When to Use Which?

**Use Azure EASM If**:
- Heavy Azure investment
- Using Microsoft E5 licensing
- Want native integration
- Budget-conscious
- Microsoft-centric security stack

**Use UpGuard If**:
- Need vendor risk management
- Multi-cloud environment
- Want data leak detection
- Executive-friendly dashboards
- Third-party focus

**Use Both If**:
- Large enterprise ($1B+ revenue)
- Complex supply chain
- Hybrid/multi-cloud
- Comprehensive coverage desired

---

## Pricing Model

### Azure EASM Pricing

```
Pricing Structure:
├── Per discovered asset per month
├── Asset types:
│   ├── Domains: $X/domain/month
│   ├── IP addresses: $Y/IP/month
│   ├── Hosts: $Z/host/month
│   └── Pages: $W/page/month
│
└── Typical costs:
    - 100 assets: ~$3K-5K/month = $36K-60K/year
    - 500 assets: ~$12K-20K/month = $144K-240K/year
    - 1000 assets: ~$20K-35K/month = $240K-420K/year

Customer Estimate (300 external assets):
~$8K/month = $96K/year

Compare to:
- UpGuard: $45K/year (fewer features but focused)
- Qualys external scanning: $50K/year (module)
- Manual tracking: Impossible at scale
```

---

## Integration with Cursor Environment

### Monitoring Cursor Public Endpoints

```bash
# Configure EASM to monitor Cursor-related assets
az easm workspace create \
  --resource-group rg-cursor-ai-research \
  --workspace-name easm-cursor-security \
  --location eastus2

# Add seed data
az easm workspace asset add \
  --workspace-name easm-cursor-security \
  --kind domain \
  --name "company.com"

# EASM automatically discovers:
discovered_assets = [
    "cursor-api.company.com",
    "aoai-prod.company.com",
    "dev-cursor.company.com",  # Forgotten dev environment!
    "old-api.company.com",     # Orphaned, still running
]

# Alert on new assets
# Alert on vulnerabilities
# Alert on changes
```

---

## Resources & Links

- **Product Page**: [Azure Defender EASM](https://azure.microsoft.com/products/defender-external-attack-surface-management)
- **Documentation**: [Microsoft Learn - Defender EASM](https://learn.microsoft.com/azure/external-attack-surface-management/)
- **Pricing**: [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)

---

## Conclusion

**For Cursor Security Architecture**:

Azure Defender EASM provides **native external attack surface monitoring** for Azure-centric organizations. Its tight integration with Microsoft Defender XDR and Azure services makes it a natural choice for Microsoft-heavy environments.

**Key Value Props**:
1. ✅ Native Azure integration
2. ✅ Discovers forgotten Azure resources
3. ✅ Microsoft threat intelligence
4. ✅ Unified with Defender XDR
5. ✅ Competitive pricing

**Recommendation**: **Excellent for Microsoft-centric environments**. Consider alongside or instead of UpGuard depending on vendor risk needs.

---

**Last Updated**: October 10, 2025  
**Review Status**: <span class="badge badge-security">Azure Native</span>

