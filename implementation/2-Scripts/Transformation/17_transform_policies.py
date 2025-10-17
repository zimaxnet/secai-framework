#!/usr/bin/env python3
"""
Azure Policies & Compliance Transformation Script
Converts policy and compliance JSON data to CSV format for Excel import
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
print("Azure Policies & Compliance Transformation")
print("=" * 60)
print(f"Input directory: {OUT_DIR}")
print(f"Output directory: {TRANSFORM_DIR}")
print()

# ============================================================================
# Transform Policy Assignments
# ============================================================================
print("Processing Policy Assignments...")

policy_assignments = []
policy_files = list(OUT_DIR.glob("*_policy_assignments.json"))
print(f"  Found {len(policy_files)} policy assignment files")

for policy_file in policy_files:
    sub_id = policy_file.name.replace("_policy_assignments.json", "")
    
    try:
        with open(policy_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for assignment in data:
                    # Get properties
                    props = assignment.get('properties', {})
                    if isinstance(props, dict):
                        display_name = props.get('displayName', '')
                        description = props.get('description', '')
                        policy_def_id = props.get('policyDefinitionId', '')
                        enforcement_mode = props.get('enforcementMode', 'Default')
                        scope = props.get('scope', '')
                    else:
                        display_name = ''
                        description = ''
                        policy_def_id = ''
                        enforcement_mode = 'Default'
                        scope = ''
                    
                    # Extract policy name from definition ID
                    policy_name = policy_def_id.split('/')[-1] if policy_def_id else ''
                    
                    # Determine scope level
                    scope_level = 'Unknown'
                    if '/subscriptions/' in scope:
                        parts = scope.split('/')
                        if len(parts) == 3:
                            scope_level = 'Subscription'
                        elif '/resourceGroups/' in scope:
                            scope_level = 'Resource Group'
                    elif '/providers/Microsoft.Management/managementGroups/' in scope:
                        scope_level = 'Management Group'
                    
                    policy_assignments.append({
                        'Subscription ID': sub_id,
                        'Assignment Name': assignment.get('name', ''),
                        'Display Name': display_name,
                        'Policy Name': policy_name,
                        'Enforcement Mode': enforcement_mode,
                        'Scope Level': scope_level,
                        'Scope': scope,
                        'Description': description[:500] if description else '',  # Truncate long descriptions
                        'Policy Definition ID': policy_def_id,
                        'Resource ID': assignment.get('id', '')
                    })
                print(f"  [OK] {policy_file.name} - {len(data)} assignments")
    except Exception as e:
        print(f"  [ERROR] {policy_file.name}: {e}")

if policy_assignments:
    policy_csv = TRANSFORM_DIR / "policy_assignments.csv"
    with open(policy_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Assignment Name', 'Display Name', 'Policy Name', 
            'Enforcement Mode', 'Scope Level', 'Scope', 'Description', 
            'Policy Definition ID', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(policy_assignments)
    print(f"  ✓ Created policy_assignments.csv ({len(policy_assignments)} assignments)")

# ============================================================================
# Transform Defender for Cloud Pricing
# ============================================================================
print()
print("Processing Defender for Cloud Pricing...")

defender_pricing = []
defender_files = list(OUT_DIR.glob("*_defender_pricing.json"))
print(f"  Found {len(defender_files)} Defender pricing files")

for defender_file in defender_files:
    sub_id = defender_file.name.replace("_defender_pricing.json", "")
    
    try:
        with open(defender_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "{}":
                continue
            
            data = json.loads(content)
            
            # Handle object with value property
            pricing_list = []
            if isinstance(data, dict) and 'value' in data:
                pricing_list = data['value']
            elif isinstance(data, list):
                pricing_list = data
            
            for pricing in pricing_list:
                # Get properties
                props = pricing.get('properties', {})
                if isinstance(props, dict):
                    pricing_tier = props.get('pricingTier', 'Free')
                else:
                    pricing_tier = 'Free'
                
                defender_pricing.append({
                    'Subscription ID': sub_id,
                    'Resource Type': pricing.get('name', ''),
                    'Pricing Tier': pricing_tier,
                    'Resource ID': pricing.get('id', '')
                })
            
            if pricing_list:
                print(f"  [OK] {defender_file.name} - {len(pricing_list)} pricing plans")
    except Exception as e:
        print(f"  [ERROR] {defender_file.name}: {e}")

if defender_pricing:
    defender_csv = TRANSFORM_DIR / "defender_pricing.csv"
    with open(defender_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Resource Type', 'Pricing Tier', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(defender_pricing)
    print(f"  ✓ Created defender_pricing.csv ({len(defender_pricing)} pricing plans)")

# ============================================================================
# Summary Statistics
# ============================================================================
print()
print("=" * 60)
print("Transformation Summary")
print("=" * 60)
print(f"Policy Assignments: {len(policy_assignments)}")
print(f"Defender Pricing Plans: {len(defender_pricing)}")
print()
print(f"Output files created in: {TRANSFORM_DIR}")
if policy_assignments:
    print(f"  - policy_assignments.csv")
if defender_pricing:
    print(f"  - defender_pricing.csv")
print()

# Policy Statistics
if policy_assignments:
    print("Policy Assignment Statistics:")
    
    # Enforcement mode
    enforcement = Counter(p['Enforcement Mode'] for p in policy_assignments)
    print(f"  By Enforcement Mode:")
    for mode, count in enforcement.most_common():
        print(f"    {mode}: {count}")
    
    # Scope level
    scopes = Counter(p['Scope Level'] for p in policy_assignments)
    print(f"  By Scope Level:")
    for scope, count in scopes.most_common():
        print(f"    {scope}: {count}")
    
    # Top policies
    policies = Counter(p['Display Name'] for p in policy_assignments if p['Display Name'])
    print(f"  Top Assigned Policies:")
    for policy, count in policies.most_common(5):
        print(f"    {policy[:60]}: {count}")
    print()

# Defender Statistics
if defender_pricing:
    print("Defender for Cloud Statistics:")
    
    # Tier distribution
    tiers = Counter(d['Pricing Tier'] for d in defender_pricing)
    print(f"  By Pricing Tier:")
    for tier, count in tiers.most_common():
        print(f"    {tier}: {count}")
    
    # Standard tier breakdown
    standard_plans = [d for d in defender_pricing if d['Pricing Tier'] == 'Standard']
    if standard_plans:
        print(f"  Standard Tier Resource Types:")
        resource_types = Counter(d['Resource Type'] for d in standard_plans)
        for rtype, count in resource_types.most_common():
            print(f"    {rtype}: {count}")
    
    # Coverage
    subs_with_standard = len(set(d['Subscription ID'] for d in standard_plans))
    total_subs = len(set(d['Subscription ID'] for d in defender_pricing))
    print(f"  Subscriptions with Standard Tier: {subs_with_standard}/{total_subs}")
    print()

print("=" * 60)
print("Transformation complete!")
print("=" * 60)

