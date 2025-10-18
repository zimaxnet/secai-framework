# Workspace - Internal Scratchpad

**Purpose:** Internal working directory for framework development, analysis, and principal architect guidance.

⚠️ **This folder is NOT published to GitHub Pages and is excluded from public documentation.**

---

## What Goes Here

### ✅ Include in Workspace:
- Principal architect guidance and decisions
- Work-in-progress analysis and findings
- Interview templates and notes from process assessments
- Compliance mapping matrices under development
- Gap analysis drafts and remediation planning
- Internal meeting notes and strategy discussions
- Tools and scripts being tested before productionization
- Cursor AI interaction logs and research notes
- Customer-specific adaptations (sanitized before moving to main docs)

### ❌ Do NOT Include:
- Customer data or PII (use `implementation/3-Data/` with its own gitignore)
- Credentials, API keys, or secrets
- Large binary files
- Final documentation (move to appropriate docs/ or implementation/ folders)

---

## Folder Structure

```
workspace/
├── README.md                          # This file
├── 1-Principal-Architect-Guidance/    # Architect decisions and guidance
├── 2-Process-Assessment-Work/         # Process dimension development
├── 3-Best-Practices-Work/             # Best practices dimension development
├── 4-Analysis-Scratch/                # Ad-hoc analysis and research
├── 5-Cursor-AI-Sessions/              # AI interaction logs and research
└── 6-Migration-Planning/              # CSP to MCA migration planning
```

---

## How to Use This Workspace

### 1. Principal Architect Guidance
Store decisions, architectural guidance, and strategic direction here. When guidance is finalized and sanitized, promote it to the main documentation.

**Example workflow:**
1. Capture guidance in `1-Principal-Architect-Guidance/`
2. Review and sanitize
3. Move to `docs/security-architecture/` or `implementation/1-Documentation/`

### 2. Process Assessment Work
Develop interview templates, capture findings, and create process maturity assessments.

**Example workflow:**
1. Create interview template in `2-Process-Assessment-Work/`
2. Test with real assessments
3. Refine and sanitize
4. Promote to `implementation/4-Templates/` when ready

### 3. Best Practices Work
Map compliance frameworks, create control matrices, and develop gap analysis templates.

**Example workflow:**
1. Create control mapping in `3-Best-Practices-Work/`
2. Validate against customer environments
3. Generalize and sanitize
4. Promote to `implementation/4-Templates/` when production-ready

### 4. Analysis Scratch
Quick analysis, research notes, data exploration. This is your scratchpad.

### 5. Cursor AI Sessions
Logs of AI interactions, research notes from using Cursor with Azure AI Foundry, prompt engineering experiments.

### 6. Migration Planning
CSP to MCA migration planning, customer-specific roadmaps (sanitized before promoting).

---

## Gitignore Status

This `workspace/` folder is added to:
- ✅ `.gitignore` - Not committed to Git
- ✅ `docs/_config.yml` - Not published to GitHub Pages

It functions like `implementation/3-Data/` - a protected working area.

---

## Promoting Work from Workspace to Production

When content is ready to be public:

1. **Sanitize:**
   - Remove customer-specific references
   - Generalize examples
   - Remove internal-only notes

2. **Move to appropriate location:**
   - General docs → `docs/`
   - Implementation guides → `implementation/1-Documentation/`
   - Templates → `implementation/4-Templates/`
   - Scripts → `implementation/2-Scripts/`

3. **Update references:**
   - Link from main README or docs
   - Update navigation if needed

4. **Delete or archive workspace version:**
   - Keep workspace clean
   - Archive if needed for reference

---

## Security Considerations

### Using Cursor AI with Azure AI Foundry

This workspace can store:
- Prompts and responses for framework development
- Research on secure AI usage patterns
- Testing notes for AI-assisted security analysis

**Remember:**
- Never include API keys or credentials
- No customer data in AI prompts (use sanitized examples)
- Review AI outputs before promoting to production docs
- Document AI usage patterns for research purposes

### Compliance

This workspace is internal-only and not subject to the same sanitization requirements as public docs. However:
- Still follow basic security hygiene
- No credentials or secrets
- Sanitize before promoting to public areas

---

## Folder Lifecycle

**Active Development:**
- Workspace is the primary working area
- Files change frequently
- Not version controlled (gitignored)

**Production Ready:**
- Content sanitized and generalized
- Moved to appropriate public folder
- Version controlled and published

**Archive:**
- Create `workspace/archive/` for old work
- Keep workspace clean and current

---

**Last Updated:** October 17, 2025  
**Status:** Active Development Area


