# Azure Assessment Kit (CSP ➜ MCA)

Generated: 2025-10-14T20:21:08.143110Z

This kit helps you:
1) Inventory **all management groups, subscriptions, resource groups, and resources** across the tenant.
2) Pull **Azure Policy** (incl. Defender for Cloud) assignments and compliance evidence for MCA scopes.
3) Export **security evidence** per the 12 security domains to support your spreadsheet's *Assessment Questions*, *Evidence to Collect*, and *Evidence Count* columns.
4) Produce machine‑readable JSON and CSV that you can paste into your spreadsheet or hand to Copilot Web.

## Quick start
```bash
# 0) Login once (Interactive or device login)
./scripts/00_login.sh

# 1) Enumerate tenant → MGs → Subs and build a working scope file
./scripts/01_scope_discovery.sh

# 2) Full inventory and counts per subscription (resources, resource types, RGs)
./scripts/02_inventory.sh

# 3) Policy & Defender for Cloud evidence from MG/sub scopes
./scripts/03_policies_and_defender.sh

# 4) Identity & Privileged Access (RBAC, PIM listings)
./scripts/04_identity_and_privileged.sh

# 5) Network Security (VNets, NSGs, ASGs, Firewalls, Routes, Private Endpoints)
./scripts/05_network_security.sh

# 6) Data Protection (Storage, Key Vaults, SQL, soft delete, purge protection)
./scripts/06_data_protection.sh

# 7) Logging & Threat Detection (Diagnostic settings, LA workspaces, Sentinel, Defender plans)
./scripts/07_logging_threat_detection.sh

# 8) Backup & Recovery
./scripts/08_backup_recovery.sh

# 9) Posture & Vulnerability (secure score, regulatory compliance snapshots)
./scripts/09_posture_vulnerability.sh

# 10) Evidence counter (summarizes counts per artifact)
python3 ./scripts/10_evidence_counter.py
```

All outputs go to `./out/`. The file `./out/scope.json` carries the discovered management groups and subscriptions and is reused across scripts.

> **Note**: These scripts are pure Azure CLI. No `jq` is required. If you have Azure Resource Graph enabled, some queries are faster but each script has fallbacks.

## CSP vs MCA scopes
- CSP subscriptions live under the **root management group** (often `\`/`/`) with *no policies attached*.
- MCA subscriptions live under respective management groups **with policy assignments** (incl. ~1000 Defender policies).
- The goal is to **evidence current state**, then use the MCA policy posture to drive remediation after migration.

## Evidence Mapping
Use `templates/assessment_matrix.csv` as a starter catalog of the 12 security domains, the suggested evidence to collect, and the output file that each script produces. The `10_evidence_counter.py` script computes counts per output file and writes `out/evidence_counts.csv` for direct spreadsheet import.

## Creating files from VS Code terminal
Yes—you can create files directly from VS Code’s terminal. These scripts already write JSON/CSV under `./out/`. You can then:
- Paste JSON/CSV into your spreadsheet, or
- Upload the files to Copilot Web to help fill the spreadsheet automatically.

If you prefer a manual workflow, you can run commands individually and copy terminal JSON into files with shell redirection, e.g.
```bash
az account list -o json > ./out/subscriptions.json
```

## Optional: Limits & Permissions
- You need **Reader** at tenant root for discovery; **Policy Read** permissions at MGs/subs for policy/defender.
- For PIM export you need to be allowed to read Azure AD role assignments (and/or Entra PIM APIs if applicable).

---
