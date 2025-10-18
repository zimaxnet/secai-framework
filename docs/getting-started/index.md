---
layout: default
title: Getting Started
nav_order: 2
has_children: true
permalink: /getting-started/
---

# Getting Started with Azure Security Assessment
{: .no_toc }

Execute comprehensive Azure security assessments using VSCode and PowerShell/Python scripts.
{: .fs-6 .fw-300 }

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Overview

The SecAI Framework provides a complete three-dimensional assessment methodology for Azure environments:

1. **Dimension 1: Configuration Assessment** - Automated data collection via PowerShell/Python
2. **Dimension 2: Process Assessment** - Structured interviews with operational teams
3. **Dimension 3: Best Practices Assessment** - Multi-framework compliance validation

**Primary execution method:** VSCode + PowerShell + Python scripts  
**Optional enhancement:** Cursor IDE + Azure AI Foundry (when customer policy allows)

## Quick Start Checklist

Before you begin:

- [ ] Azure subscription access (Reader role minimum, Contributor recommended)
- [ ] PowerShell Core (pwsh) installed
- [ ] Python 3.8+ with pandas, openpyxl libraries
- [ ] Azure CLI installed and authenticated
- [ ] VSCode (or any code editor with terminal)
- [ ] 10GB disk space for evidence collection

**Optional Enhancement:**
- [ ] Cursor IDE Enterprise license
- [ ] Azure AI Foundry endpoint deployment
- [ ] Private endpoint configuration for AI chat

## Time Requirements

| Phase | Estimated Time | Method |
|-------|---------------|---------|
| Prerequisites setup | 30-60 minutes | Manual |
| Dimension 1 collection | 3-4 hours | Automated scripts |
| Data transformation | 30 minutes | Python scripts |
| Dimension 3 validation | 5-10 minutes | PowerShell modules |
| Dimension 2 interviews | 8-16 hours | Human interviews |
| Report generation | 2-4 hours | Semi-automated |
| **Total** | **15-25 hours** | **Spread over 2-3 weeks** |

{: .note }
Most time is automated script execution. Human effort is primarily in Dimension 2 interviews and report review.

---

## Execution Overview

### Primary Method: VSCode + Scripts

```bash
# 1. Authenticate to Azure
az login
az account set --subscription "your-subscription-id"

# 2. Run Dimension 1 collection scripts (3-4 hours)
cd implementation/2-Scripts/Collection
pwsh ./00_login.ps1
pwsh ./01_scope_discovery.ps1
pwsh ./02_inventory.ps1
pwsh ./03_policies_and_defender.ps1
pwsh ./04_identity_and_privileged_NO_AD_BYPASS_SSL.ps1
pwsh ./05_network_security.ps1
pwsh ./06_data_protection.ps1
pwsh ./07_logging_threat_detection.ps1
pwsh ./08_backup_recovery.ps1
pwsh ./09_posture_vulnerability.ps1
# Optional: Count evidence files
python ./10_evidence_counter.py

# 3. Run transformation scripts
cd ../Transformation
python 11_transform_security.py
python 12_transform_inventory.py
python 13_transform_rbac.py
python 14_transform_network.py
python 15_transform_data_protection.py
python 16_transform_logging.py
python 17_transform_policies.py

# 4. Run Dimension 3 validation (minutes)
cd ../../workspace/3-Best-Practices-Work
pwsh ./Validate-All-Frameworks.ps1 -DataPath "../../implementation/2-Scripts/out"

# 5. Review compliance scores and evidence
# 6. Conduct Dimension 2 interviews
# 7. Generate final reports
```

### Enhanced Method: Cursor + Azure AI Foundry (Optional)

If your organization allows AI-assisted development with data sovereignty:

- Use Cursor IDE for AI-accelerated script development
- Azure AI Foundry keeps all chat in your tenant
- Helpful for analyzing large datasets and generating insights
- [Setup Guide](/getting-started/cursor-setup) (optional)

---

## Assessment Workflow

### Phase 1: Configuration Assessment (Dimension 1)

**Objective:** Collect evidence of deployed resources and security configurations

**Steps:**
1. Authenticate to Azure CLI
2. Execute 10 collection scripts across 12 security domains
3. Transform JSON to CSV for analysis
4. Review evidence files

**Output:** 800+ JSON evidence files, CSV analysis files

**Time:** 3-4 hours automated execution

[View Collection Scripts](https://github.com/zimaxnet/secai-framework/tree/main/implementation/2-Scripts/Collection)

### Phase 2: Best Practices Assessment (Dimension 3)

**Objective:** Validate alignment with industry frameworks

**Steps:**
1. Run multi-framework validation script
2. Review compliance scores (MCSB, CIS, NIST, PCI-DSS, CCM)
3. Identify top gaps
4. Prioritize remediation

**Output:** Compliance scores, control pass/fail details, gap reports

**Time:** 5-10 minutes automated validation

[View Validation Modules](https://github.com/zimaxnet/secai-framework/tree/main/workspace/3-Best-Practices-Work)

### Phase 3: Process Assessment (Dimension 2)

**Objective:** Evaluate operational maturity

**Steps:**
1. Use Dimension 3 findings to focus interviews
2. Conduct structured interviews with teams
3. Score process maturity (5-level model)
4. Document gaps

**Output:** Process maturity scores, gap analysis

**Time:** 8-16 hours interviews

[View Interview Templates](https://github.com/zimaxnet/secai-framework/tree/main/workspace/2-Process-Assessment-Work)

### Phase 4: Reporting

**Objective:** Generate executive summary and remediation roadmap

**Steps:**
1. Consolidate findings from all three dimensions
2. Generate executive summary
3. Create prioritized remediation roadmap
4. Present findings to stakeholders

**Output:** Executive summary, remediation roadmap, detailed reports

**Time:** 2-4 hours

---

## Prerequisites Deep Dive

### Software Requirements

**Required:**
- **PowerShell Core (pwsh)** - Version 7.0 or higher
  - Windows: `winget install Microsoft.PowerShell`
  - macOS: `brew install powershell`
  - Linux: [Install instructions](https://docs.microsoft.com/powershell/scripting/install/installing-powershell)

- **Python 3.8+** - With pip package manager
  - Windows: Download from python.org
  - macOS: `brew install python3`
  - Linux: `apt install python3 python3-pip`

- **Azure CLI** - Latest version
  - All platforms: `https://aka.ms/install-azure-cli`
  - Verify: `az --version`

- **Python Libraries:**
  ```bash
  pip install pandas openpyxl azure-identity azure-mgmt-resource
  ```

- **VSCode** - Or any code editor with integrated terminal
  - Download: `https://code.visualstudio.com/`

**Optional (for AI-enhanced analysis):**
- **Cursor IDE** - Enterprise license
- **Azure AI Foundry** - Deployed endpoint
- **Azure OpenAI** - GPT-4 or o1 model deployment

### Azure Permission Requirements

Minimum Azure RBAC roles for assessment:

- **Reader** - Sufficient for read-only assessment (recommended starting point)
- **Contributor** - Required for remediation activities
- **Security Reader** - For Microsoft Defender for Cloud data
- **Log Analytics Reader** - For diagnostic log queries

{: .note }
For most assessments, **Reader** role is sufficient. Contributor is only needed if you plan to implement remediation.

### Network Requirements

| Source | Destination | Port | Protocol | Purpose |
|--------|-------------|------|----------|---------|
| Assessment Workstation | Azure Management API | 443 | HTTPS | Azure CLI queries |
| Assessment Workstation | Azure Resource Graph | 443 | HTTPS | Large-scale queries |
| Assessment Workstation | Azure Entra ID | 443 | HTTPS | Authentication |

{: .tip }
No inbound connectivity required. All queries are outbound from your workstation to Azure public endpoints.

---

## Next Steps

Now that you understand the assessment methodology and prerequisites, proceed with:

1. [Prerequisites Setup](prerequisites.md) - Install required software and authenticate
2. [Execute Dimension 1](/implementation/2-Scripts/Collection) - Run collection scripts
3. [Execute Dimension 3](/workspace/3-Best-Practices-Work) - Run validation modules
4. [Optional: Cursor Setup](cursor-setup.md) - AI-enhanced analysis (if allowed)

---

## Troubleshooting

Common issues during assessment execution:

| Issue | Possible Cause | Resolution |
|-------|---------------|------------|
| `az login` fails | Expired credentials | Run `az logout` then `az login` again |
| PowerShell script errors | Execution policy | Run `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned` |
| Python import errors | Missing libraries | Run `pip install pandas openpyxl azure-identity` |
| "Access Denied" errors | Insufficient RBAC | Verify you have Reader role on subscription |
| Scripts time out | Large subscription | Increase timeout in script or run against fewer resources |
| No data collected | Wrong subscription | Verify with `az account show` |

{: .tip }
For detailed troubleshooting, see the [Execution Guide](https://github.com/zimaxnet/secai-framework/blob/main/implementation/1-Documentation/EXECUTION_GUIDE.md).

---

**Last Updated**: October 18, 2025  
**Framework Status**: Production Ready  
**Status**: <span class="badge badge-new">Assessment-First Positioning</span>

