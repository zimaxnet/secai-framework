# Manual Updates Required for Binary Files

The following files are in binary formats (Microsoft Office) and require manual editing to remove organization-specific references and make them generic for public template use.

## Files Requiring Manual Updates

### 1. Training_Slides.pptx

**Current References to Update:**
- Any slides mentioning "NICO" (National Indemnity Company)
- Any slides mentioning "TCS" (Tata Consultancy Services) - replace with "Your Organization"
- Specific team member names (Derek Brent Moore, etc.) - replace with role titles
- Azure subscription IDs or tenant IDs - replace with placeholders like `[YOUR-TENANT-ID]`

**Recommended Updates:**
- Title slide: "Secure AI-Accelerated Enterprise Workflow - Training"
- Throughout: Replace "NICO" with "Your Enterprise" or "Your Organization"
- Team structure slides: Use generic role titles instead of names
- Contact slides: Replace specific emails with `security-team@yourorg.com` placeholders

---

### 2. Implementation_Roadmap.xlsx

**Current References to Update:**
- Any worksheet names or headers mentioning "NICO"
- Resource names (e.g., `NICO-KeyVault` → `YourOrg-KeyVault` or `[YOUR-KEYVAULT-NAME]`)
- Team member names - replace with role titles:
  - "Derek Brent Moore" → "Security Architect (Onsite)"
  - Specific offshore names → "Security Engineer (Team)" / "Automation Engineer (Team)"
- Azure resource names:
  - `NICO-OIDC-Connection` → `Enterprise-OIDC-ServiceConnection`
  - `NICO-KeyVault-Secrets` → `Enterprise-KeyVault-Secrets`
- Any email addresses or contact information

**Recommended Structure:**
The roadmap should maintain the 6-week structure but use generic placeholders:

| Week | Phase | Activities | Owner |
|------|-------|-----------|-------|
| 0 | Setup | Enable enterprise accounts | Security Architect |
| 1 | Configuration | Configure Codespaces policies | Platform Team |
| 2 | Integration | Reconfigure pipelines to OIDC | Automation Engineer |
| 3-4 | Pilot | Deploy to pre-production | Project Team |
| 5 | Validation | Security assessment | Security Engineer |
| 6 | Production | Go-live with sign-off | Senior Leadership |

---

### 3. Infographic.png

**Current State:**
- Image appears very faint/low contrast
- May contain NICO-specific branding or logos

**Recommended Actions:**
1. **Regenerate the infographic** with higher contrast and resolution
2. **Remove any organization-specific**:
   - Logos (NICO, TCS)
   - Company names
   - Specific Azure resource names
3. **Use generic labels**:
   - "Enterprise Key Vault" instead of "NICO-KeyVault"
   - "Your Organization" instead of company names
   - Generic icons for roles instead of photos
4. **Ensure accessibility**:
   - Minimum 4.5:1 contrast ratio for text
   - Export at 300 DPI for print quality
   - Consider SVG format for scalability

**Suggested Infographic Content:**
```
┌─────────────────────────────────────────┐
│    Secure AI-Accelerated Workflow       │
│                                         │
│  Developer → Cursor IDE (Privacy Mode)  │
│      ↓                                  │
│  GitHub Codespaces (Containerized)      │
│      ↓                                  │
│  Azure Key Vault (OIDC Auth)            │
│      ↓                                  │
│  Azure DevOps Pipeline                  │
│      ↓                                  │
│  Production Deployment                  │
│      ↓                                  │
│  Audit & Compliance Monitoring          │
└─────────────────────────────────────────┘
```

---

## Quick Find-and-Replace Guide

For efficient updating across all binary files, search for and replace:

| Find | Replace With |
|------|-------------|
| NICO | Your Organization / Enterprise |
| National Indemnity Company | Your Enterprise Name |
| TCS | Your Service Provider / Your Team |
| Tata Consultancy Services | Your Organization / Your Team |
| Derek Brent Moore | Security Architect (Onsite) |
| NICO-KeyVault | Enterprise-KeyVault / [YOUR-KEYVAULT] |
| NICO-OIDC-Connection | Enterprise-OIDC-ServiceConnection |
| NICO-KeyVault-Secrets | Enterprise-KeyVault-Secrets |
| derek.moore@company.com | security-architect@yourorg.com |

---

## Verification Checklist

After making manual updates, verify:

- [ ] No organization-specific names remain (NICO, TCS)
- [ ] No personal names or email addresses
- [ ] No specific Azure resource IDs or tenant IDs
- [ ] Generic role titles used throughout
- [ ] Placeholder values clearly marked (e.g., `[YOUR-VALUE]`)
- [ ] All references to "client" or "customer" removed
- [ ] Document metadata (Author, Company) updated to "Enterprise Template"
- [ ] No internal URLs or intranet links
- [ ] Copyright/classification markings removed or updated to "Public Template"

---

## Tools to Assist

### For PowerPoint (.pptx):
1. **Find & Replace**: Home → Replace (Ctrl+H) - works across all slides
2. **Metadata Cleanup**: File → Info → Inspect Document → Remove personal information
3. **Export Options**: File → Save As → check "Remove personal information" option

### For Excel (.xlsx):
1. **Find & Replace**: Home → Find & Select → Replace (Ctrl+H) - works across all sheets
2. **Check All Sheets**: Use "Within: Workbook" option to search all worksheets
3. **Metadata Cleanup**: File → Info → Inspect Workbook → Remove personal information

### For PNG Images:
1. **Recommended Tools**:
   - Adobe Illustrator (for recreating as vector)
   - Canva (for quick infographic creation)
   - Draw.io / Excalidraw (for flowcharts)
   - Figma (for collaborative design)
2. **Export Settings**:
   - Format: PNG or SVG
   - Resolution: 300 DPI minimum
   - Color: RGB for digital, CMYK for print
   - Transparency: Yes (for overlays)

---

## After Completing Manual Updates

Once you've updated all binary files:

1. ✅ **Verify** all changes using the checklist above
2. 📝 **Document** any additional customizations you made
3. 🧪 **Test** that files open correctly and look professional
4. 📦 **Package** all updated files together
5. 🎉 **Publish** your enterprise template!

---

## Questions?

If you're unsure about any specific reference:
- **When in doubt, make it generic** - use placeholder text like `[YOUR-VALUE]`
- **Check the markdown files** - Business_Justification.md, Technical_Addendum.md, and Governance_SOP_Playbook.md have been updated as examples
- **Consistency matters** - use the same placeholders throughout all documents

---

**Last Updated**: October 2025  
**Template Version**: 1.0

