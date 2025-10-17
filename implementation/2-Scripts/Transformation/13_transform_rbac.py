#!/usr/bin/env python3
"""
Azure RBAC Data Transformation Script
Converts role assignment JSON data to CSV format for Excel import
"""

import json
import csv
from pathlib import Path
from collections import Counter

# Determine paths
SCRIPT_DIR = Path(__file__).parent
ROOT_DIR = SCRIPT_DIR.parent
OUT_DIR = ROOT_DIR / "out"
TRANSFORM_DIR = ROOT_DIR / "transformed"

# Create transformed directory if it doesn't exist
TRANSFORM_DIR.mkdir(exist_ok=True)

print("=" * 60)
print("Azure RBAC Data Transformation")
print("=" * 60)
print(f"Input directory: {OUT_DIR}")
print(f"Output directory: {TRANSFORM_DIR}")
print()

# ============================================================================
# Transform Role Assignments
# ============================================================================
print("Processing Role Assignments...")

role_assignments = []
rbac_files = list(OUT_DIR.glob("*_role_assignments.json"))
print(f"  Found {len(rbac_files)} role assignment files")

for rbac_file in rbac_files:
    # Extract subscription ID from filename
    sub_id = rbac_file.name.replace("_role_assignments.json", "")
    
    try:
        with open(rbac_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            
            # Skip empty files
            if not content or content == "[]":
                print(f"  [SKIP] {rbac_file.name} - empty")
                continue
            
            data = json.loads(content)
            
            # Handle array of role assignments
            if isinstance(data, list):
                for assignment in data:
                    # Extract principal info
                    principal_id = assignment.get('principalId', '')
                    principal_name = assignment.get('principalName', '')
                    principal_type = assignment.get('principalType', '')
                    
                    # Extract role info
                    role_name = assignment.get('roleDefinitionName', '')
                    role_id = assignment.get('roleDefinitionId', '')
                    
                    # Extract scope info
                    scope = assignment.get('scope', '')
                    assignment_id = assignment.get('id', '')
                    
                    # Determine scope level from scope path
                    scope_level = 'Unknown'
                    if '/subscriptions/' in scope:
                        parts = scope.split('/')
                        if len(parts) == 3:  # /subscriptions/{id}
                            scope_level = 'Subscription'
                        elif '/resourceGroups/' in scope:
                            if len(parts) == 5:  # /subscriptions/{id}/resourceGroups/{rg}
                                scope_level = 'Resource Group'
                            else:  # Resource level
                                scope_level = 'Resource'
                    
                    role_assignments.append({
                        'Subscription ID': sub_id,
                        'Principal Name': principal_name,
                        'Principal ID': principal_id,
                        'Principal Type': principal_type,
                        'Role Name': role_name,
                        'Scope Level': scope_level,
                        'Scope': scope,
                        'Role Definition ID': role_id,
                        'Assignment ID': assignment_id
                    })
                
                print(f"  [OK] {rbac_file.name} - {len(data)} role assignments")
    
    except json.JSONDecodeError as e:
        print(f"  [WARN] Could not parse {rbac_file.name}: {e}")
    except Exception as e:
        print(f"  [ERROR] Failed to process {rbac_file.name}: {e}")

# Write role assignments CSV
if role_assignments:
    rbac_csv = TRANSFORM_DIR / "role_assignments.csv"
    with open(rbac_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Principal Name', 'Principal ID', 'Principal Type', 
            'Role Name', 'Scope Level', 'Scope', 'Role Definition ID', 'Assignment ID'
        ])
        writer.writeheader()
        writer.writerows(role_assignments)
    
    print(f"  ✓ Created role_assignments.csv ({len(role_assignments)} assignments)")
else:
    print("  ⚠ No role assignments found")

# ============================================================================
# Summary Statistics
# ============================================================================
print()
print("=" * 60)
print("Transformation Summary")
print("=" * 60)
print(f"Role Assignments: {len(role_assignments)}")
print()
print(f"Output files created in: {TRANSFORM_DIR}")
if role_assignments:
    print(f"  - role_assignments.csv")
print()

# RBAC Statistics
if role_assignments:
    print("RBAC Statistics:")
    print()
    
    # Count by role name
    roles = Counter(r['Role Name'] for r in role_assignments)
    print(f"  Top Roles Assigned:")
    for role, count in roles.most_common(10):
        print(f"    {role}: {count}")
    print()
    
    # Count privileged roles (Owner, Contributor, User Access Administrator)
    privileged_roles = ['Owner', 'Contributor', 'User Access Administrator']
    privileged_count = sum(1 for r in role_assignments if r['Role Name'] in privileged_roles)
    print(f"  Privileged Role Assignments:")
    print(f"    Owner: {sum(1 for r in role_assignments if r['Role Name'] == 'Owner')}")
    print(f"    Contributor: {sum(1 for r in role_assignments if r['Role Name'] == 'Contributor')}")
    print(f"    User Access Administrator: {sum(1 for r in role_assignments if r['Role Name'] == 'User Access Administrator')}")
    print(f"    Total Privileged: {privileged_count} ({privileged_count/len(role_assignments)*100:.1f}%)")
    print()
    
    # Count by principal type
    principal_types = Counter(r['Principal Type'] for r in role_assignments)
    print(f"  By Principal Type:")
    for ptype, count in principal_types.most_common():
        print(f"    {ptype}: {count}")
    print()
    
    # Count by scope level
    scope_levels = Counter(r['Scope Level'] for r in role_assignments)
    print(f"  By Scope Level:")
    for level, count in scope_levels.most_common():
        print(f"    {level}: {count}")
    print()
    
    # Count unique principals
    unique_principals = len(set(r['Principal ID'] for r in role_assignments))
    print(f"  Unique Principals: {unique_principals}")
    print(f"  Avg Assignments per Principal: {len(role_assignments)/unique_principals:.1f}")
    print()

print("=" * 60)
print("Transformation complete!")
print("=" * 60)

