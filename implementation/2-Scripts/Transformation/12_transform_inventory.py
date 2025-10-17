#!/usr/bin/env python3
"""
Azure Inventory Data Transformation Script
Converts resource and resource group JSON data to CSV format for Excel import
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
print("Azure Inventory Data Transformation")
print("=" * 60)
print(f"Input directory: {OUT_DIR}")
print(f"Output directory: {TRANSFORM_DIR}")
print()

# ============================================================================
# Transform Resource Groups
# ============================================================================
print("Processing Resource Groups...")

resource_groups = []
rg_files = list(OUT_DIR.glob("*_rgs.json"))
print(f"  Found {len(rg_files)} resource group files")

for rg_file in rg_files:
    # Extract subscription ID from filename
    sub_id = rg_file.name.replace("_rgs.json", "")
    
    try:
        with open(rg_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            
            # Skip empty files
            if not content or content == "[]":
                print(f"  [SKIP] {rg_file.name} - empty")
                continue
            
            data = json.loads(content)
            
            # Handle array of resource groups
            if isinstance(data, list):
                for rg in data:
                    resource_groups.append({
                        'Subscription ID': sub_id,
                        'Resource Group Name': rg.get('name', ''),
                        'Location': rg.get('location', ''),
                        'Provisioning State': rg.get('properties', {}).get('provisioningState', '') if isinstance(rg.get('properties'), dict) else '',
                        'Resource ID': rg.get('id', ''),
                        'Tags': json.dumps(rg.get('tags', {})) if rg.get('tags') else ''
                    })
                print(f"  [OK] {rg_file.name} - {len(data)} resource groups")
    
    except json.JSONDecodeError as e:
        print(f"  [WARN] Could not parse {rg_file.name}: {e}")
    except Exception as e:
        print(f"  [ERROR] Failed to process {rg_file.name}: {e}")

# Write resource groups CSV
if resource_groups:
    rg_csv = TRANSFORM_DIR / "resource_groups.csv"
    with open(rg_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Resource Group Name', 'Location', 'Provisioning State', 'Resource ID', 'Tags'
        ])
        writer.writeheader()
        writer.writerows(resource_groups)
    
    print(f"  ✓ Created resource_groups.csv ({len(resource_groups)} resource groups)")
else:
    print("  ⚠ No resource groups found")

# ============================================================================
# Transform Resources
# ============================================================================
print()
print("Processing Resources...")

resources = []
resource_files = list(OUT_DIR.glob("*_resources.json"))
print(f"  Found {len(resource_files)} resource files")

for resource_file in resource_files:
    # Extract subscription ID from filename
    sub_id = resource_file.name.replace("_resources.json", "")
    
    try:
        with open(resource_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            
            # Skip empty files
            if not content or content == "[]":
                print(f"  [SKIP] {resource_file.name} - empty")
                continue
            
            data = json.loads(content)
            
            # Handle array of resources
            if isinstance(data, list):
                for resource in data:
                    resources.append({
                        'Subscription ID': sub_id,
                        'Resource Name': resource.get('name', ''),
                        'Resource Type': resource.get('type', ''),
                        'Resource Group': resource.get('resourceGroup', ''),
                        'Location': resource.get('location', ''),
                        'SKU': resource.get('sku', {}).get('name', '') if isinstance(resource.get('sku'), dict) else '',
                        'Kind': resource.get('kind', ''),
                        'Provisioning State': resource.get('provisioningState', ''),
                        'Resource ID': resource.get('id', ''),
                        'Tags': json.dumps(resource.get('tags', {})) if resource.get('tags') else ''
                    })
                print(f"  [OK] {resource_file.name} - {len(data)} resources")
    
    except json.JSONDecodeError as e:
        print(f"  [WARN] Could not parse {resource_file.name}: {e}")
    except Exception as e:
        print(f"  [ERROR] Failed to process {resource_file.name}: {e}")

# Write resources CSV
if resources:
    resources_csv = TRANSFORM_DIR / "resources.csv"
    with open(resources_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Resource Name', 'Resource Type', 'Resource Group', 
            'Location', 'SKU', 'Kind', 'Provisioning State', 'Resource ID', 'Tags'
        ])
        writer.writeheader()
        writer.writerows(resources)
    
    print(f"  ✓ Created resources.csv ({len(resources)} resources)")
else:
    print("  ⚠ No resources found")

# ============================================================================
# Summary Statistics
# ============================================================================
print()
print("=" * 60)
print("Transformation Summary")
print("=" * 60)
print(f"Resource Groups: {len(resource_groups)}")
print(f"Resources: {len(resources)}")
print()
print(f"Output files created in: {TRANSFORM_DIR}")
if resource_groups:
    print(f"  - resource_groups.csv")
if resources:
    print(f"  - resources.csv")
print()

# Resource Group Statistics
if resource_groups:
    print("Resource Group Statistics:")
    
    # Count by location
    locations = Counter(rg['Location'] for rg in resource_groups)
    print(f"  Top Locations:")
    for location, count in locations.most_common(5):
        print(f"    {location}: {count}")
    print()

# Resource Statistics
if resources:
    print("Resource Statistics:")
    
    # Count by type
    resource_types = Counter(r['Resource Type'] for r in resources)
    print(f"  Top Resource Types:")
    for rtype, count in resource_types.most_common(10):
        print(f"    {rtype}: {count}")
    print()
    
    # Count by location
    locations = Counter(r['Location'] for r in resources)
    print(f"  Top Locations:")
    for location, count in locations.most_common(5):
        print(f"    {location}: {count}")
    print()
    
    # Count by subscription
    subs = Counter(r['Subscription ID'] for r in resources)
    print(f"  Resources per Subscription:")
    print(f"    Average: {len(resources) / len(subs):.1f}")
    print(f"    Min: {min(subs.values())}")
    print(f"    Max: {max(subs.values())}")
    print()

print("=" * 60)
print("Transformation complete!")
print("=" * 60)

