# ⚡ Quick Reference Card

**Keep this open in VS Code for instant reference**

---

## 🚀 First 3 Things to Do

1. ✅ Read `00_START_HERE.md` (10 min)
2. ✅ Read `04_COPILOT_SAFE_USAGE.md` (10 min)  
3. ✅ Test Azure Portal access and document

---

## 📁 File Quick Guide

| File | Use When | Priority |
|------|----------|----------|
| **00_START_HERE.md** | Right now - orientation | 🔥 Critical |
| **04_COPILOT_SAFE_USAGE.md** | Before using Copilot | 🔥 Critical |
| **02_SECURITY_ASSESSMENT_CHECKLIST.md** | Starting assessment | 🔥 Critical |
| **03_SECURITY_TEMPLATES.md** | Creating docs | 🟢 Useful |
| **01_AZURE_CLI_ESSENTIALS.md** | CLI is available | 🟡 Later |

---

## 🔒 Safe Copilot Usage (Critical!)

### ✅ SAFE to ask:
```
"How do I configure Azure Key Vault with RBAC?"
"What are Azure security best practices for NSGs?"
"Show me a script to audit RBAC assignments"
```

### ❌ NEVER share:
- Customer names, subscription IDs, tenant IDs
- Resource names, IP addresses, URLs
- Credentials, secrets, connection strings
- PII, financial data, sensitive info

### Golden Rule:
**Use abstraction! Ask generic, apply specific.**

---

## 📊 Security Assessment Quick Start

### Phase 1: Reconnaissance (Portal Only)
- [ ] List subscriptions
- [ ] Review Security Center score
- [ ] Check compliance dashboard
- [ ] Document accessible resources

### Phase 2: Identity & Access
- [ ] List Owner role assignments
- [ ] Review service principals
- [ ] Check MFA enforcement
- [ ] Document privileged accounts

### Phase 3: Network Security
- [ ] Map VNets and subnets
- [ ] Review NSG rules (wide open?)
- [ ] List public IP addresses
- [ ] Check firewall configurations

### Phase 4: Data Protection
- [ ] List storage accounts (public access?)
- [ ] Check database encryption
- [ ] Review Key Vault configuration
- [ ] Verify backup settings

---

## ⚡ Essential Azure CLI Commands

*Use when CLI is available*

### Quick Security Scan
```bash
# Security assessments
az security assessment list --output table

# Policy compliance
az policy state list --output table

# RBAC audit
az role assignment list --all --output table

# Public IPs
az network public-ip list --output table
```

### Export Everything
```bash
# Create export folder
EXPORT_DIR="azure_export_$(date +%Y%m%d)"
mkdir -p "$EXPORT_DIR"

# Export security data
az security assessment list > "$EXPORT_DIR/security.json"
az role assignment list --all > "$EXPORT_DIR/rbac.json"
az resource list > "$EXPORT_DIR/resources.json"
az network nsg list > "$EXPORT_DIR/nsgs.json"
```

---

## 📝 Documentation Templates

### Risk Register Entry
```markdown
**Risk ID**: R001
**Description**: [What's the risk?]
**Likelihood**: High/Medium/Low
**Impact**: High/Medium/Low
**Score**: 1-10
**Mitigation**: [What to do?]
**Owner**: [Who?]
**Status**: Open/In Progress/Closed
```

### RBAC Matrix Entry
```markdown
| Identity | Role | Scope | MFA | Review Status |
|----------|------|-------|-----|---------------|
| [User] | Owner | Sub | Yes | ✅ |
```

### Finding Entry
```markdown
**Finding**: [Issue title]
**Severity**: Critical/High/Medium/Low
**Impact**: [Business impact]
**Recommendation**: [What to do]
**Timeline**: Immediate/Week/Month
```

---

## 🚨 Escalate Immediately If Found

- [ ] Publicly accessible database with sensitive data
- [ ] Storage account with public write access
- [ ] Admin credentials in plain text
- [ ] NSG allowing 0.0.0.0/0 to production
- [ ] Encryption disabled on sensitive data
- [ ] Active security incidents
- [ ] Missing MFA on privileged accounts

---

## 📅 Daily Checklist

### Morning
- [ ] Check Security Center alerts
- [ ] Review compliance dashboard
- [ ] Check email for security updates

### During Work
- [ ] Document findings as you go
- [ ] Use Copilot with abstraction ONLY
- [ ] Take sanitized screenshots
- [ ] Update risk register

### End of Day
- [ ] Save all documentation
- [ ] Update weekly report
- [ ] Log any blockers
- [ ] Plan tomorrow

---

## 🎯 Week 1 Goals

- [ ] Environment fully documented
- [ ] Azure CLI requested
- [ ] Security assessment started
- [ ] Resource inventory created
- [ ] RBAC matrix drafted
- [ ] Top 5 risks identified
- [ ] First weekly report delivered

---

## 💡 Pro Tips

1. **Export to files** - Portal data can disappear
2. **Screenshot everything** (sanitized!) - Evidence
3. **Update docs daily** - Don't wait till end
4. **Use templates** - Consistency matters
5. **Ask generic questions** - Copilot safety
6. **Script everything** - Repeatability
7. **Color code risks** - Red/Orange/Yellow/Green

---

## 📞 Quick Commands

### Navigate
```bash
cd ~/secure-workspace
ls docs/
```

### Read File
```bash
cat docs/00_START_HERE.md
less docs/02_SECURITY_ASSESSMENT_CHECKLIST.md
```

### Edit in VS Code
```bash
code docs/00_START_HERE.md
```

### Create New Doc
```bash
code documentation/security-assessments/week1-findings.md
```

---

## 🔗 File Locations

```
~/secure-workspace/
├── docs/                  ← Reference files (these)
├── documentation/         ← Your assessments
├── scripts/              ← Your automation
└── deliverables/         ← Final reports
```

---

## ✅ Success Indicators

You're on track when:
- ✅ Can navigate environment confidently
- ✅ Using Copilot safely with abstraction
- ✅ Documenting findings systematically
- ✅ Creating professional deliverables
- ✅ Identifying security risks
- ✅ Making progress on assessment
- ✅ Communicating status regularly

---

## 🆘 Common Issues

**"Can't access Azure Portal"**  
→ Check VPN/network, verify credentials

**"Azure CLI not working"**  
→ May not be installed yet - work with portal

**"Copilot seems unsafe"**  
→ Read `04_COPILOT_SAFE_USAGE.md` thoroughly

**"Don't know what to do next"**  
→ Follow `02_SECURITY_ASSESSMENT_CHECKLIST.md`

**"Need to create a report"**  
→ Use templates in `03_SECURITY_TEMPLATES.md`

---

## 📊 Risk Scoring

| Likelihood | Impact Low | Impact Med | Impact High | Impact Critical |
|------------|------------|------------|-------------|-----------------|
| Very Likely | 4 | 6 | 8 | **10** |
| Likely | 3 | 5 | 7 | **9** |
| Possible | 2 | 4 | 6 | 8 |
| Unlikely | 1 | 3 | 5 | 7 |

**Critical (9-10)**: Fix immediately  
**High (7-8)**: Fix within week  
**Medium (4-6)**: Fix within month  
**Low (1-3)**: Fix when resources available

---

## 🎯 Remember

**You're the Security Architect**  
Security is YOUR responsibility.

**Work within constraints**  
Limited tools ≠ limited effectiveness.

**Document everything**  
If it's not documented, it didn't happen.

**Use Copilot safely**  
Abstraction always, customer data never.

**Escalate concerns**  
Better safe than sorry.

---

## 📖 Full Documentation

For complete details, read the full files:
- `00_START_HERE.md` - Complete orientation
- `01_AZURE_CLI_ESSENTIALS.md` - All CLI commands
- `02_SECURITY_ASSESSMENT_CHECKLIST.md` - Full methodology
- `03_SECURITY_TEMPLATES.md` - All templates
- `04_COPILOT_SAFE_USAGE.md` - Complete safety guide

---

**Print this page or keep it open for quick reference!**

🛡️ **Security first, always.**





