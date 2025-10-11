# Binary Files - Manual Review Required

## Files That May Contain Client References

The following binary files cannot be automatically edited and may contain references to NICO (National Indemnity Company) or TCS (Tata Consultancy Services):

### 1. Training_Slides.pptx
**Location**: `docs/assets/downloads/Training_Slides.pptx`

**Potential References**:
- Title slides mentioning NICO or TCS
- Team member names
- Specific Azure resource names (NICO-KeyVault, etc.)
- Contact information

**Recommendation**: 
- Open in PowerPoint/LibreOffice
- Use Find & Replace (Ctrl+H) to search for "NICO" and "TCS"
- Replace with generic terms like "Your Organization" or "Enterprise"
- Check slide notes and metadata (File → Info → Inspect Document)
- Update Author field to remove personal names

### 2. Implementation_Roadmap.xlsx
**Location**: `docs/assets/downloads/Implementation_Roadmap.xlsx`

**Potential References**:
- Worksheet names with NICO
- Resource names (NICO-KeyVault, NICO-OIDC-Connection)
- Team member names
- Email addresses

**Recommendation**:
- Open in Excel/LibreOffice Calc
- Use Find & Replace across all worksheets
- Replace resource names with placeholders: `[YOUR-KEYVAULT]`, `[YOUR-RESOURCE-GROUP]`
- Replace names with role titles: "Security Architect", "Platform Engineer"
- Check workbook properties (File → Info → Inspect Workbook)

### 3. Binary PDF/DOCX Files in Archive
**Location**: `archive/`

**Files**:
- Business_Justification.docx
- Business_Justification.pdf
- Technical_Addendum.docx
- Technical_Addendum.pdf
- Governance_SOP_Playbook.docx
- Governance_SOP_Playbook.pdf
- Implementation_Roadmap.pdf

**Status**: These are in the archive folder for reference
**Recommendation**: These can remain as-is since they're archived legacy files, or delete them if you want to fully sanitize

## Quick Sanitization Checklist

- [ ] Open Training_Slides.pptx
- [ ] Find & Replace "NICO" → "Your Organization"
- [ ] Find & Replace "TCS" → "Your Service Provider" (if applicable)
- [ ] Find & Replace "National Indemnity" → "Your Enterprise"
- [ ] Replace any personal names with role titles
- [ ] Clear document metadata
- [ ] Save and test presentation

- [ ] Open Implementation_Roadmap.xlsx
- [ ] Find & Replace "NICO" → "Enterprise" or "[YOUR-ORG]"
- [ ] Replace resource names with placeholders
- [ ] Replace team member names with roles
- [ ] Clear workbook metadata
- [ ] Save and test workbook

## If You Want to Delete Instead

If you prefer to fully sanitize by removing these files:

```bash
# Remove binary files that may contain client information
rm docs/assets/downloads/Training_Slides.pptx
rm docs/assets/downloads/Implementation_Roadmap.xlsx

# Optionally remove archive binary files
rm archive/*.docx
rm archive/*.pdf
rm archive/Implementation_Roadmap.pdf
```

**Note**: This will break links in README.md that reference these files. Update accordingly.

## Current Sanitization Status

✅ **Completed**:
- Removed Executive_Summary.html (contained NICO/TCS)
- Removed Executive_Summary.pdf (contained NICO/TCS)
- Removed MANUAL_UPDATES_REQUIRED.md (meta-document)
- Sanitized all path references in markdown files
- Verified no NICO/TCS in docs/ markdown files

⚠️ **Requires Manual Review**:
- Training_Slides.pptx (binary file)
- Implementation_Roadmap.xlsx (binary file)
- Archive PDF/DOCX files (legacy, can delete or keep)

---

**Last Updated**: October 11, 2025

