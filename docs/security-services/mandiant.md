---
layout: default
title: Mandiant IR Services
parent: Security Services & Consultants
nav_order: 1
---

# Mandiant - Elite Incident Response & Threat Intelligence
{: .no_toc }

Deep dive into Mandiant's incident response retainer and its critical role in enterprise security posture.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

**Mandiant** (a Google Cloud company) is the world's leading incident response and threat intelligence firm, known for responding to the most sophisticated cyberattacks including nation-state sponsored APTs (Advanced Persistent Threats).

### Company Information

| | |
|---|---|
| **Company** | Mandiant, Inc. (Google Cloud) |
| **Founded** | 2004 (as Mandiant), acquired by Google 2022 |
| **Headquarters** | Reston, VA (Washington DC area) |
| **Founder** | Kevin Mandia (CEO until Google acquisition) |
| **Website** | [https://www.mandiant.com](https://www.mandiant.com) |
| **Parent** | Google Cloud |
| **Notable** | Discovered major breaches: SolarWinds, Target, Sony, Equifax |

---

## Why Keep Mandiant on Retainer?

### The Insurance Policy Analogy

**Retainer as Breach Insurance**:
```
Traditional Insurance:
├── Pay premium: $X/year
├── If incident occurs: Covered
├── Benefit: Financial protection
└── Limit: Financial only

Mandiant Retainer:
├── Pay retainer: $150K-500K/year
├── If breach occurs: Immediate expert response
├── Benefit: Technical + financial protection
├── Includes:
│   ├── Faster response (hours vs days)
│   ├── Better outcome (contain vs total loss)
│   ├── Lower total cost
│   └── Regulatory credibility
└── Additional value: Quarterly threat briefings, exercises
```

### Real-World Breach Scenarios

**Scenario 1: Ransomware Attack Without Retainer**
```
Timeline:
T+0:    Ransomware encrypts 60% of systems
T+2hr:  Security team realizes scope
T+4hr:  Start searching for IR firm
T+12hr: Find available firm, negotiate contract
T+24hr: IR team arrives, starts investigation
T+72hr: Containment achieved
T+7d:   Full recovery

Cost:
├── IR firm: $500/hr × 800 hours = $400K
├── Downtime: 7 days × $100K/day = $700K
├── Ransom: $2M (paid)
├── Legal fees: $300K
├── Notification costs: $200K
├── Reputation damage: $5M+
└── Total: $8.6M+

Time to containment: 72 hours
Data loss: Significant
```

**Scenario 2: Ransomware Attack With Mandiant Retainer**
```
Timeline:
T+0:    Ransomware detected by CrowdStrike
T+0.5hr: Activate Mandiant retainer (1 phone call)
T+2hr:  Mandiant team connects remotely
T+4hr:  Containment measures deployed
T+12hr: Ransomware fully contained
T+3d:   Systems recovered (no ransom paid)

Cost:
├── Retainer: $250K/year (already paid)
├── IR hours: $350/hr × 300 hours = $105K
├── Downtime: 12 hours × $100K/day = $50K
├── Ransom: $0 (not paid)
├── Legal fees: $50K
├── Notification: $50K (limited scope)
└── Total: $505K

Time to containment: 12 hours
Data loss: Minimal

Savings vs without retainer: $8.1M (94% reduction!)
```

---

## Mandiant Retainer Services

### Included in Annual Retainer

**1. Incident Response Hotline**
```yaml
service: "24/7/365 Hotline"
response_time: "2 hours to initial contact"
escalation: "1 hour for critical incidents"
contact_methods:
  - phone: "+1-888-MANDIANT"
  - email: "hotline@mandiant.com"
  - secure_portal: "mandiant.com/client-portal"
```

**2. Quarterly Threat Intelligence Briefings**
```
Briefing Contents:
├── Threat landscape specific to insurance sector
├── APT groups targeting similar organizations
├── Emerging attack techniques
├── Vulnerabilities relevant to your stack
├── Defensive recommendations
└── Q&A with Mandiant analysts

Format: 90-minute virtual session
Attendees: CISO, Security team, SOC
Value: Strategic awareness, prioritization
```

**3. Annual Tabletop Exercise**
```
Tabletop Scenario: Azure OpenAI Data Breach

Participants:
├── CISO
├── Security Architect
├── Legal
├── PR/Communications
├── Engineering Lead
└── Executive Leadership

Mandiant facilitates:
├── Realistic breach scenario
├── Decision points and trade-offs
├── Communication challenges
├── Legal/regulatory considerations
├── Technical response options
└── Post-exercise debrief

Outcome: Improved incident response readiness
```

**4. Proactive Threat Hunting (Optional Add-On)**
```bash
# Mandiant analyzes your SIEM data monthly
# Looking for: Advanced persistent threats, stealthy attackers

mandiant_hunt:
  frequency: monthly
  data_sources:
    - Chronicle logs (90 days)
    - CrowdStrike telemetry
    - Azure activity logs
    - Network flow logs
  
  hunt_objectives:
    - APT group indicators
    - Living-off-the-land techniques
    - Credential theft traces
    - Lateral movement patterns
    - Data staging activities
  
  deliverable:
    - Hunt report with findings
    - IOCs for blocking
    - Defensive recommendations
```

---

## Mandiant Threat Intelligence

### Google-Mandiant Combined Power

**Since Google Acquisition**:
```
Mandiant Threat Intelligence + Google:
├── VirusTotal data (Google-owned)
├── Google Threat Analysis Group (TAG)
├── Chronicle security analytics
├── Google Cloud threat data
└── Combined: Unparalleled visibility

Benefits for Cursor Security:
✅ Early warning of threats
✅ Azure OpenAI-specific intelligence
✅ AI/ML security research
✅ Attacker tradecraft insights
```

### Threat Actor Tracking

**Mandiant APT Naming**:
```
Notable Threat Groups:
├── APT1 (China, PLA Unit 61398)
├── APT28 (Russia, GRU/Fancy Bear)
├── APT29 (Russia, SVR/Cozy Bear)
├── APT38 (North Korea, Lazarus Group)
├── APT41 (China, Dual Espionage/Crime)
└── FIN7 (Financially motivated, global)

Insurance Sector Specific:
├── APT groups targeting financial data
├── Ransomware gangs (REvil, BlackCat, LockBit)
├── Insider threat patterns
└── Business email compromise (BEC) actors

Intelligence Provided:
- TTPs (Tactics, Techniques, Procedures)
- IOCs (Indicators of Compromise)
- YARA rules for detection
- Defensive measures
```

---

## When to Activate Mandiant Retainer

### Incident Categories

**Tier 1: Activate Immediately** (Critical)
- Confirmed data breach
- Ransomware infection
- Nation-state APT suspected
- Customer data compromised
- Regulatory notification required

**Tier 2: Activate Within Hours** (High)
- Suspected breach (needs confirmation)
- Unusual Azure OpenAI activity (possible compromise)
- Multiple CrowdStrike detections
- Insider threat evidence
- Supply chain compromise

**Tier 3: Consult Before Activating** (Medium)
- Large-scale phishing campaign
- DDoS attack
- Website defacement
- Potential vulnerability exploitation

**Don't Activate For**:
- Normal malware (CrowdStrike handles)
- Single phishing email
- Minor policy violations
- Routine security alerts

---

## Mandiant's Approach

### Investigation Methodology

**Mandiant Consulting Methodology** (MCM):
```
Phase 1: Initial Response (Hours 0-4)
├── Establish secure communication
├── Understand incident scope
├── Initiate evidence preservation
├── Deploy forensic tools
└── Initial containment recommendations

Phase 2: Investigation (Days 1-7)
├── Forensic analysis
├── Timeline reconstruction
├── Attacker TTP identification
├── Data exfiltration assessment
└── Attribution (if possible)

Phase 3: Containment & Eradication (Days 3-14)
├── Remove attacker access
├── Patch vulnerabilities
├── Credential rotation
├── Network segmentation
└── Monitoring enhancement

Phase 4: Recovery & Hardening (Days 7-30)
├── System restoration
├── Validation testing
├── Enhanced monitoring
├── Security improvements
└── Lessons learned report

Phase 5: Post-Incident (Ongoing)
├── Continued monitoring (90 days)
├── Threat intelligence sharing
├── Executive briefing
└── Regulatory support
```

---

## Integration with Existing Tools

### Mandiant + Chronicle

**Native Integration**:
```
Chronicle (Google Cloud) + Mandiant (Google Cloud):
├── Seamless data sharing
├── Mandiant threat intel auto-ingested
├── IOCs automatically blocked
├── Detection rules from Mandiant
└── Unified Google security ecosystem

Benefits:
✅ No separate integration work
✅ Real-time intelligence updates
✅ Consistent detection rules
✅ Single pane of glass (Chronicle)
```

### Mandiant + CrowdStrike

**Endpoint Forensics**:
```bash
# During IR, Mandiant uses CrowdStrike data

# CrowdStrike provides:
crowdstrike_export:
  - process_execution_history
  - network_connections
  - file_access_logs
  - registry_modifications
  - memory_dumps (if requested)

# Mandiant analyzes for:
mandiant_analysis:
  - malware artifacts
  - attacker tools (cobalt strike, mimikatz)
  - lateral movement evidence
  - persistence mechanisms
  - data exfiltration indicators
```

---

## Deliverables

### Incident Response Report

**Mandiant IR Report Structure**:
```markdown
# Executive Summary (2-3 pages)
- What happened
- Impact assessment
- Current status
- Recommendations

# Technical Analysis (20-50 pages)
- Timeline of attack
- Attack vectors used
- Systems compromised
- Data accessed/stolen
- Attacker TTPs
- Attribution (if possible)

# Remediation Recommendations
- Immediate actions (close vulnerabilities)
- Short-term hardening (90 days)
- Long-term improvements (strategic)

# Regulatory Appendix
- Breach notification requirements
- Evidence for regulators
- Compliance implications

# IOCs (Indicators of Compromise)
- Malware hashes
- C2 server IPs
- Malicious domains
- Registry keys
- File paths
```

---

## Resources & Links

- **Website**: [https://www.mandiant.com](https://www.mandiant.com)
- **Threat Intelligence**: [https://www.mandiant.com/advantage](https://www.mandiant.com/advantage)
- **Google Cloud Integration**: [https://cloud.google.com/mandiant](https://cloud.google.com/mandiant)
- **Blog**: [https://www.mandiant.com/resources/blog](https://www.mandiant.com/resources/blog)
- **M-Trends Report**: Annual threat landscape report (free)

---

## Conclusion

**For Cursor Security Architecture**:

Mandiant retainer provides **critical breach response capability** that automated tools cannot replace. In a world where breaches are "when not if," having Mandiant on retainer ensures rapid, expert response that minimizes damage and demonstrates due diligence to regulators and cyber insurance carriers.

**Key Value Props**:
1. ✅ 24/7 access to world's best IR team
2. ✅ 2-hour response time guarantee
3. ✅ Nation-state APT expertise
4. ✅ Regulatory credibility
5. ✅ Lower total breach cost

**Recommendation**: **Essential for regulated industries** (insurance, finance, healthcare) and organizations with high-value data.

---

**Last Updated**: October 10, 2025  
**Review Status**: <span class="badge badge-security">Industry Best Practice</span>

