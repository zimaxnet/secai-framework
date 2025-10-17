#!/usr/bin/env python3
"""
Azure Network Data Transformation Script
Converts network configuration JSON data to CSV format for Excel import
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
print("Azure Network Data Transformation")
print("=" * 60)
print(f"Input directory: {OUT_DIR}")
print(f"Output directory: {TRANSFORM_DIR}")
print()

# ============================================================================
# Transform Virtual Networks
# ============================================================================
print("Processing Virtual Networks...")

vnets = []
vnet_files = list(OUT_DIR.glob("*_vnets.json"))
print(f"  Found {len(vnet_files)} VNet files")

for vnet_file in vnet_files:
    sub_id = vnet_file.name.replace("_vnets.json", "")
    
    try:
        with open(vnet_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for vnet in data:
                    # Get address prefixes
                    address_space = vnet.get('addressSpace', {})
                    address_prefixes = ', '.join(address_space.get('addressPrefixes', [])) if isinstance(address_space, dict) else ''
                    
                    # Count subnets
                    subnets = vnet.get('subnets', [])
                    subnet_count = len(subnets) if isinstance(subnets, list) else 0
                    
                    vnets.append({
                        'Subscription ID': sub_id,
                        'VNet Name': vnet.get('name', ''),
                        'Resource Group': vnet.get('resourceGroup', ''),
                        'Location': vnet.get('location', ''),
                        'Address Prefixes': address_prefixes,
                        'Subnet Count': subnet_count,
                        'Provisioning State': vnet.get('provisioningState', ''),
                        'Resource ID': vnet.get('id', '')
                    })
                print(f"  [OK] {vnet_file.name} - {len(data)} VNets")
    except Exception as e:
        print(f"  [ERROR] {vnet_file.name}: {e}")

if vnets:
    vnet_csv = TRANSFORM_DIR / "virtual_networks.csv"
    with open(vnet_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'VNet Name', 'Resource Group', 'Location', 
            'Address Prefixes', 'Subnet Count', 'Provisioning State', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(vnets)
    print(f"  ✓ Created virtual_networks.csv ({len(vnets)} VNets)")

# ============================================================================
# Transform Network Security Groups
# ============================================================================
print()
print("Processing Network Security Groups...")

nsgs = []
nsg_files = list(OUT_DIR.glob("*_nsgs.json"))
print(f"  Found {len(nsg_files)} NSG files")

for nsg_file in nsg_files:
    sub_id = nsg_file.name.replace("_nsgs.json", "")
    
    try:
        with open(nsg_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for nsg in data:
                    # Count rules
                    security_rules = nsg.get('securityRules', [])
                    default_rules = nsg.get('defaultSecurityRules', [])
                    rule_count = len(security_rules) if isinstance(security_rules, list) else 0
                    default_rule_count = len(default_rules) if isinstance(default_rules, list) else 0
                    
                    nsgs.append({
                        'Subscription ID': sub_id,
                        'NSG Name': nsg.get('name', ''),
                        'Resource Group': nsg.get('resourceGroup', ''),
                        'Location': nsg.get('location', ''),
                        'Custom Rules': rule_count,
                        'Default Rules': default_rule_count,
                        'Total Rules': rule_count + default_rule_count,
                        'Provisioning State': nsg.get('provisioningState', ''),
                        'Resource ID': nsg.get('id', '')
                    })
                print(f"  [OK] {nsg_file.name} - {len(data)} NSGs")
    except Exception as e:
        print(f"  [ERROR] {nsg_file.name}: {e}")

if nsgs:
    nsg_csv = TRANSFORM_DIR / "network_security_groups.csv"
    with open(nsg_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'NSG Name', 'Resource Group', 'Location', 
            'Custom Rules', 'Default Rules', 'Total Rules', 'Provisioning State', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(nsgs)
    print(f"  ✓ Created network_security_groups.csv ({len(nsgs)} NSGs)")

# ============================================================================
# Transform Azure Firewalls
# ============================================================================
print()
print("Processing Azure Firewalls...")

firewalls = []
fw_files = list(OUT_DIR.glob("*_az_firewalls.json"))
print(f"  Found {len(fw_files)} firewall files")

for fw_file in fw_files:
    sub_id = fw_file.name.replace("_az_firewalls.json", "")
    
    try:
        with open(fw_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for fw in data:
                    # Get SKU info
                    sku = fw.get('sku', {})
                    sku_name = sku.get('name', '') if isinstance(sku, dict) else ''
                    sku_tier = sku.get('tier', '') if isinstance(sku, dict) else ''
                    
                    firewalls.append({
                        'Subscription ID': sub_id,
                        'Firewall Name': fw.get('name', ''),
                        'Resource Group': fw.get('resourceGroup', ''),
                        'Location': fw.get('location', ''),
                        'SKU Name': sku_name,
                        'SKU Tier': sku_tier,
                        'Provisioning State': fw.get('provisioningState', ''),
                        'Resource ID': fw.get('id', '')
                    })
                print(f"  [OK] {fw_file.name} - {len(data)} Firewalls")
    except Exception as e:
        print(f"  [ERROR] {fw_file.name}: {e}")

if firewalls:
    fw_csv = TRANSFORM_DIR / "azure_firewalls.csv"
    with open(fw_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Firewall Name', 'Resource Group', 'Location', 
            'SKU Name', 'SKU Tier', 'Provisioning State', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(firewalls)
    print(f"  ✓ Created azure_firewalls.csv ({len(firewalls)} Firewalls)")

# ============================================================================
# Transform Private Endpoints
# ============================================================================
print()
print("Processing Private Endpoints...")

private_endpoints = []
pe_files = list(OUT_DIR.glob("*_private_endpoints.json"))
print(f"  Found {len(pe_files)} private endpoint files")

for pe_file in pe_files:
    sub_id = pe_file.name.replace("_private_endpoints.json", "")
    
    try:
        with open(pe_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for pe in data:
                    # Get private link service connections
                    connections = pe.get('privateLinkServiceConnections', [])
                    connection_count = len(connections) if isinstance(connections, list) else 0
                    
                    private_endpoints.append({
                        'Subscription ID': sub_id,
                        'Private Endpoint Name': pe.get('name', ''),
                        'Resource Group': pe.get('resourceGroup', ''),
                        'Location': pe.get('location', ''),
                        'Connection Count': connection_count,
                        'Provisioning State': pe.get('provisioningState', ''),
                        'Resource ID': pe.get('id', '')
                    })
                print(f"  [OK] {pe_file.name} - {len(data)} Private Endpoints")
    except Exception as e:
        print(f"  [ERROR] {pe_file.name}: {e}")

if private_endpoints:
    pe_csv = TRANSFORM_DIR / "private_endpoints.csv"
    with open(pe_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Private Endpoint Name', 'Resource Group', 'Location', 
            'Connection Count', 'Provisioning State', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(private_endpoints)
    print(f"  ✓ Created private_endpoints.csv ({len(private_endpoints)} Private Endpoints)")

# ============================================================================
# Summary Statistics
# ============================================================================
print()
print("=" * 60)
print("Transformation Summary")
print("=" * 60)
print(f"Virtual Networks: {len(vnets)}")
print(f"Network Security Groups: {len(nsgs)}")
print(f"Azure Firewalls: {len(firewalls)}")
print(f"Private Endpoints: {len(private_endpoints)}")
print()
print(f"Output files created in: {TRANSFORM_DIR}")
if vnets:
    print(f"  - virtual_networks.csv")
if nsgs:
    print(f"  - network_security_groups.csv")
if firewalls:
    print(f"  - azure_firewalls.csv")
if private_endpoints:
    print(f"  - private_endpoints.csv")
print()

# Network Statistics
if vnets:
    print("Virtual Network Statistics:")
    locations = Counter(v['Location'] for v in vnets)
    print(f"  Top Locations:")
    for location, count in locations.most_common(5):
        print(f"    {location}: {count}")
    total_subnets = sum(v['Subnet Count'] for v in vnets)
    print(f"  Total Subnets: {total_subnets}")
    print(f"  Avg Subnets per VNet: {total_subnets/len(vnets):.1f}")
    print()

if nsgs:
    print("Network Security Group Statistics:")
    total_custom_rules = sum(n['Custom Rules'] for n in nsgs)
    total_rules = sum(n['Total Rules'] for n in nsgs)
    print(f"  Total Custom Rules: {total_custom_rules}")
    print(f"  Total Rules (incl. default): {total_rules}")
    print(f"  Avg Rules per NSG: {total_rules/len(nsgs):.1f}")
    print()

if firewalls:
    print("Azure Firewall Statistics:")
    skus = Counter(f['SKU Tier'] for f in firewalls)
    print(f"  By SKU Tier:")
    for sku, count in skus.most_common():
        print(f"    {sku}: {count}")
    print()

if private_endpoints:
    print("Private Endpoint Statistics:")
    locations = Counter(p['Location'] for p in private_endpoints)
    print(f"  Top Locations:")
    for location, count in locations.most_common(3):
        print(f"    {location}: {count}")
    print()

print("=" * 60)
print("Transformation complete!")
print("=" * 60)

