---
layout: default
title: Black Hills Information Security
parent: Security Services & Consultants
nav_order: 2
---

# Black Hills Information Security - Practical Penetration Testing
{: .no_toc }

Analysis of Black Hills InfoSec and their practical approach to penetration testing and security training.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

**Black Hills Information Security (BHIS)** is a boutique security firm known for practical, business-focused penetration testing and exceptional security training. Founded by John Strand, BHIS emphasizes real-world attack techniques and actionable findings.

### Company Information

| | |
|---|---|
| **Company** | Black Hills Information Security, LLC |
| **Founded** | 2012 |
| **Headquarters** | Rapid City, South Dakota |
| **Founder** | John Strand (CEO, SANS Instructor) |
| **Website** | [https://www.blackhillsinfosec.com](https://www.blackhillsinfosec.com) |
| **Size** | ~50 employees, boutique firm |
| **Notable** | Creators of "Backdoors & Breaches" card game, "Wild West Hackin' Fest" |

---

## Service Philosophy

### "Practical, Not Academic"

**BHIS Approach**:
```
Other Pentesting Firms:
├── Find 500 vulnerabilities
├── Generate 200-page report
├── List every CVE found
├── Use automated scanners heavily
└── Result: Overwhelming, hard to prioritize

Black Hills Approach:
├── Find 20 critical vulnerabilities
├── Generate 30-page actionable report
├── Focus on business impact
├── Demonstrate actual exploitation
└── Result: Clear priorities, immediate action

Example:
Don't just say: "SSL certificate expired on dev.company.com"
Instead: "We compromised Azure OpenAI keys by exploiting expired SSL cert on dev server, then pivoted to production. Here's the attack path and remediation."
```

### Business Impact Focus

**Reporting Style**:
```markdown
## Finding 1: Azure OpenAI API Key Exposure

**Business Impact**: HIGH - Attackers could:
- Generate $50K+ of unauthorized API charges
- Exfiltrate customer data from AI conversations
- Use AI for reconnaissance on internal systems
- Train models on proprietary code

**Technical Details**:
- API key found in: Application Insights logs
- Exposed for: 6 months
- Accessible to: Any developer with log access
- Exploitability: Trivial (curl command)

**Remediation**:
1. Rotate API key immediately (15 minutes)
2. Remove keys from logs (Azure CLI command provided)
3. Implement Key Vault integration (2 hours)
4. Add DLP policy for API keys (30 minutes)

**Cost to Fix**: 3 hours
**Cost if Exploited**: $50K-500K

**Priority**: CRITICAL - Fix within 24 hours
```

---

## Services Offered

### 1. Penetration Testing

**Testing Scope for Cursor Environment**:

```yaml
external_penetration_test:
  duration: 2 weeks
  cost: $25K-40K
  
  scope:
    - Azure public endpoints
    - DNS enumeration
    - SSL/TLS configuration
    - Azure OpenAI public access (if any)
    - Azure Portal login
    - Developer-facing websites
  
  methodology:
    - OSINT reconnaissance
    - Vulnerability scanning
    - Manual exploitation
    - Social engineering (with approval)
  
  deliverable:
    - Executive summary (2 pages)
    - Technical findings (15 pages)
    - Remediation guide
    - Retest after 90 days (included)

internal_penetration_test:
  duration: 3 weeks
  cost: $35K-55K
  
  scope:
    - Internal network
    - Azure VNet
    - Private endpoints
    - Key Vault access
    - Lateral movement
    - Privilege escalation
  
  methodology:
    - Assume breach (start as regular user)
    - Attempt to access Azure OpenAI
    - Attempt to steal Key Vault secrets
    - Try to pivot to production
  
  deliverable:
    - Attack path diagrams
    - Exploited vulnerabilities
    - Remediation roadmap
    - Proof-of-concept exploits (for validation)
```

### 2. Red Team Lite

**Quarterly Red Team Engagements**:
```
Engagement: "Can attacker steal Azure OpenAI keys?"

Week 1: Reconnaissance
├── OSINT on company
├── Employee LinkedIn research
├── GitHub repository scanning
├── Azure resource enumeration
└── Identify attack surface

Week 2: Initial Access
├── Phishing campaign (simulated)
├── Exploit public-facing apps
├── Compromised credentials (from dark web)
└── Social engineering

Week 3: Post-Exploitation
├── Lateral movement
├── Privilege escalation
├── Key Vault access attempts
├── Data exfiltration simulation
└── Persistence mechanisms

Week 4: Reporting
├── Document attack chain
├── Demonstrate impact
├── Remediation recommendations
└── Executive presentation

Cost: $30K-45K per quarter
```

### 3. Security Training

**BHIS Signature Training Courses**:

```
For Cursor Developers:
├── "Securing the Modern Enterprise" (3 days)
│   ├── Cloud security fundamentals
│   ├── Secure coding practices
│   ├── Threat modeling
│   └── Incident response basics
│
├── "Enterprise Cloud Security" (2 days)
│   ├── Azure security deep dive
│   ├── IAM and RBAC
│   ├── Key Vault best practices
│   └── Monitoring and detection
│
└── Custom "Secure AI Development" Workshop (1 day)
    ├── Cursor security best practices
    ├── API key management
    ├── Prompt injection attacks
    ├── Data leakage prevention
    └── Hands-on labs

Cost: $2K-3K/person for public courses
      $15K-25K for private onsite training (up to 30 people)
```

### 4. Continuous Pentesting

**Monthly Testing Model**:
```yaml
service: "Penetration Testing as a Service (PTaaS)"
frequency: monthly
duration: 40 hours/month
cost: $10K-15K/month

scope:
  - rolling_targets: true
  - prioritized_by_risk: true
  
month_1: External perimeter
month_2: Internal network
month_3: Web applications
month_4: Azure infrastructure
month_5: API security
month_6: Social engineering
# Repeat cycle...

benefits:
  - continuous_assessment: true
  - fresh_perspective_monthly: true
  - track_remediation: true
  - trendanalysis: true
```

---

## Why Choose Black Hills?

### vs. Other Pentesting Firms

| Factor | Black Hills | Large Firms (Big 4, etc.) | Automated Tools Only |
|--------|-------------|--------------------------|---------------------|
| **Cost** | $$-$$$ | $$$$ | $ |
| **Quality** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Practicality** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐ |
| **Communication** | ⭐⭐⭐⭐⭐ | ⭐⭐ | N/A |
| **Customization** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| **Training Value** | ⭐⭐⭐⭐⭐ | ⭐ | N/A |

**Customer Testimonial Pattern**:
> "BHIS found real issues that matter and explained them in plain English. Their report had 15 findings we could fix immediately, not 500 CVEs we'd never address."

### BHIS Differentiators

1. **Practical Focus**: Business impact, not just CVE counts
2. **Clear Communication**: Developers and executives both understand reports
3. **Training Excellence**: Learn while being tested
4. **Fair Pricing**: $25K-55K vs $100K+ for comparable Big 4 work
5. **No Fluff**: Concise reports with actionable recommendations
6. **Follow-Through**: Free retesting after remediation

---

## Integration with Cursor Security

### Pentesting Cursor + Azure AI Foundry

**Test Objectives**:
```
Primary Objective:
"Can external attacker or malicious insider steal Azure OpenAI API keys and use AI services fraudulently?"

Secondary Objectives:
├── Test Azure private endpoint security
├── Evaluate Key Vault RBAC effectiveness
├── Assess Okta MFA bypass potential
├── Test Purview DLP blocking
├── Evaluate CrowdStrike detection
└── Test incident response procedures

Success Criteria (for security team):
✅ BHIS cannot steal API keys within 3 weeks
✅ All attempts detected by monitoring
✅ DLP blocks exfiltration attempts
✅ Incident response activates correctly
```

### Example Findings

**Finding 1: API Key in Application Insights**
```markdown
## Severity: CRITICAL

**Issue**: Azure OpenAI API keys logged in Application Insights

**Discovery Method**:
1. Gained access to Azure Portal (phishing → MFA bypass)
2. Browsed Application Insights logs
3. Found exception logs containing full API keys
4. Used keys to call Azure OpenAI API
5. Generated $500 of unauthorized AI usage

**Proof**:
- Screenshot of logs
- Successful API call demonstration
- Cost impact in Azure billing

**Impact**:
- Financial: Unlimited API usage until detected
- Data: Could access AI conversation history
- Compliance: PCI-DSS violation if customer data processed

**Remediation**:
```bash
# Fix 1: Remove keys from logs (immediately)
az monitor app-insights component update \
  --app cursor-insights \
  --resource-group rg-cursor-ai-research \
  --set 'properties.DisableIpMasking=true'

# Fix 2: Implement log scrubbing
# Azure Function to sanitize logs in real-time

# Fix 3: Add DLP policy
# Alert if API key appears in any log
```

**Status**: FIXED - Verified in retest
```

---

## Training Programs

### Wild West Hackin' Fest

**BHIS's Security Conference**:
```
Event: Wild West Hackin' Fest (WWHF)
Location: Deadwood, South Dakota
Frequency: Annual (September)
Format: 4-day conference + training

Features:
├── Hands-on hacking challenges
├── CTF (Capture the Flag) competition
├── Training courses
├── Vendor expo
├── Networking
└── "Most fun security conference"

Courses Offered:
├── Penetration Testing Fundamentals
├── Red Team Operations
├── Purple Team Defensive Ops
├── Cloud Security
├── Active Defense & Cyber Deception
└── Incident Response

Cost: $2K-4K per person (training + conference)
Value: Practical skills + networking
```

### Webcast Series (Free!)

**Weekly Training**:
- **Webcasts**: Free security training every Thursday
- **YouTube**: [https://youtube.com/blackhillsinfosec](https://youtube.com/blackhillsinfosec)
- **Topics**: Penetration testing, defense, threat hunting
- **Format**: Live + recorded
- **Community**: Active Discord server

---

## Pricing Model

### Transparent, Fair Pricing

**Standard Engagements**:
```
External Pentest:
├── Small scope (5-10 IPs): $15K-25K
├── Medium scope (10-25 IPs): $25K-40K
└── Large scope (25+ IPs): $40K-60K

Internal Pentest:
├── Small network (< 500 IPs): $25K-40K
├── Medium network (500-2000 IPs): $40K-65K
└── Large network (2000+ IPs): $65K-100K

Web Application Pentest:
├── Single app (< 50 pages): $15K-25K
├── Multiple apps: $25K-50K
└── Complex SaaS platform: $50K-100K

Cloud Infrastructure (Azure):
├── Single subscription: $30K-50K
├── Multiple subscriptions: $50K-80K
└── Includes: IAM, networking, storage, compute

Red Team (Quarterly):
├── 2-week engagement: $30K-45K
├── 4-week engagement: $55K-75K
└── Includes: Report + debrief + retest

Retainer (Annual):
├── 40 hours/month: $120K/year
├── 80 hours/month: $200K/year
└── Flexible scope, priority scheduling
```

**vs. Competitors**:
- Big 4 firms: 2-3x BHIS pricing
- Large security firms: 1.5-2x BHIS pricing
- Automated tools: 0.1x but much lower quality
- **BHIS**: Sweet spot of cost/quality

---

## Resources & Links

- **Website**: [https://www.blackhillsinfosec.com](https://www.blackhillsinfosec.com)
- **Training**: [https://www.antisyphontraining.com](https://www.antisyphontraining.com) (BHIS's training company)
- **YouTube**: [Black Hills InfoSec Channel](https://youtube.com/blackhillsinfosec)
- **Discord**: Active community for questions
- **Blog**: Regular security articles and research
- **GitHub**: [https://github.com/blackhillsinfosec](https://github.com/blackhillsinfosec)

### Notable Tools from BHIS

- **Backdoors & Breaches**: Incident response card game for training
- **PleaseStop**: Tool for testing web app security
- **Hashcrack**: Password cracking training
- **ThreatHunting**: Threat hunting resources

---

## Conclusion

**For Cursor Security Architecture**:

Black Hills Information Security provides **affordable, practical penetration testing** with exceptional value. Their business-focused approach makes findings actionable, and their training programs improve overall security team capabilities.

**Key Value Props**:
1. ✅ Practical, actionable findings
2. ✅ Fair pricing (half of Big 4 costs)
3. ✅ Excellent communication
4. ✅ Training included (knowledge transfer)
5. ✅ Real-world attack techniques

**Recommendation**: **Excellent for quarterly/annual pentesting** and security team training. Perfect for organizations wanting quality work without Big 4 prices.

---

**Last Updated**: October 10, 2025  
**Review Status**: <span class="badge badge-security">Community Recommended</span>

