# Migration Planning (CSP to MCA)

**Purpose:** Plan and track Azure migrations from CSP to Microsoft Customer Agreement with Landing Zones.

---

## What Goes Here

- Migration assessments and readiness
- CSP vs MCA gap analysis
- Landing Zone design and validation
- Cutover planning and runbooks
- Risk assessment and mitigation
- Rollback procedures
- Post-migration validation

---

## Migration Phases

### Phase 1: Assessment
- Current state analysis (CSP subscriptions)
- Target state definition (MCA + Landing Zones)
- Gap identification
- Workload inventory
- Dependency mapping

### Phase 2: Design
- Landing Zone architecture
- Network topology (hub-spoke)
- Policy framework design
- RBAC structure
- Naming conventions

### Phase 3: Build
- Landing Zone deployment
- Policy assignments (~1,000 controls)
- Network configuration
- Identity integration
- Monitoring setup

### Phase 4: Migration
- Pilot workload migration
- Validation and testing
- Full migration waves
- Cutover execution
- Post-migration validation

### Phase 5: Optimization
- Policy tuning
- Performance optimization
- Cost optimization
- Process refinement

---

## Deliverables

### Assessment Deliverables
- [ ] Current state inventory (use SecAI scripts!)
- [ ] CSP vs MCA comparison
- [ ] Gap analysis matrix
- [ ] Migration complexity assessment
- [ ] Risk register

### Planning Deliverables
- [ ] Landing Zone architecture diagram
- [ ] Migration roadmap (Gantt chart)
- [ ] Cutover plan and schedule
- [ ] Resource requirements
- [ ] Budget and timeline

### Execution Deliverables
- [ ] Landing Zone deployment scripts
- [ ] Migration runbooks
- [ ] Validation checklists
- [ ] Rollback procedures
- [ ] Communication plan

---

## SecAI Framework Integration

### Use Configuration Assessment (Dimension 1) for:
- ✅ Current state CSP inventory
- ✅ Landing Zone validation
- ✅ Pre/post migration comparison
- ✅ Policy compliance verification

### Scripts to Run:
- `01_scope_discovery.ps1` - Inventory CSP subscriptions
- `02_inventory.ps1` - Complete resource inventory
- `03_policies_and_defender.ps1` - Current policy state
- `05_network_security.ps1` - Network topology
- Run again post-migration to validate

---

## Migration Artifacts

```
6-Migration-Planning/
├── README.md                          # This file
├── current-state-assessment/          # CSP environment assessment
├── target-state-design/               # MCA + Landing Zones design
├── gap-analysis/                      # CSP vs MCA gaps
├── migration-waves/                   # Wave planning
├── cutover-plans/                     # Detailed cutover procedures
├── validation-checklists/             # Pre/post migration validation
└── lessons-learned/                   # Post-migration retrospective
```

---

## Status Tracking

**Current Phase:** [TBD]  
**Migration Timeline:** [TBD]  
**Subscriptions to Migrate:** [TBD]  
**Target Completion:** [TBD]

---

## Sanitization Before Publishing

If migration insights are valuable for the public framework:
1. Remove customer-specific names and IDs
2. Generalize subscription counts and resource types
3. Sanitize architecture diagrams
4. Create case study in `docs/case-studies/`

---

**Owner:** Migration Team  
**Status:** Planning  
**Confidentiality:** Internal Only


