#!/usr/bin/env python3
"""
Azure Data Protection Transformation Script
Converts storage, Key Vault, and SQL JSON data to CSV format for Excel import
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
print("Azure Data Protection Transformation")
print("=" * 60)
print(f"Input directory: {OUT_DIR}")
print(f"Output directory: {TRANSFORM_DIR}")
print()

# ============================================================================
# Transform Storage Accounts
# ============================================================================
print("Processing Storage Accounts...")

storage_accounts = []
storage_files = list(OUT_DIR.glob("*_storage.json"))
print(f"  Found {len(storage_files)} storage account files")

for storage_file in storage_files:
    sub_id = storage_file.name.replace("_storage.json", "")
    
    try:
        with open(storage_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for storage in data:
                    # Get SKU info
                    sku = storage.get('sku', {})
                    sku_name = sku.get('name', '') if isinstance(sku, dict) else ''
                    sku_tier = sku.get('tier', '') if isinstance(sku, dict) else ''
                    
                    # Get encryption info
                    encryption = storage.get('encryption', {})
                    key_source = encryption.get('keySource', '') if isinstance(encryption, dict) else ''
                    
                    # Get access tier
                    access_tier = storage.get('accessTier', '')
                    
                    # Get HTTPS only
                    https_only = storage.get('enableHttpsTrafficOnly', False)
                    
                    # Get public access
                    allow_blob_public = storage.get('allowBlobPublicAccess', None)
                    
                    storage_accounts.append({
                        'Subscription ID': sub_id,
                        'Storage Account Name': storage.get('name', ''),
                        'Resource Group': storage.get('resourceGroup', ''),
                        'Location': storage.get('location', ''),
                        'SKU Name': sku_name,
                        'SKU Tier': sku_tier,
                        'Access Tier': access_tier,
                        'HTTPS Only': 'Yes' if https_only else 'No',
                        'Allow Public Blob Access': str(allow_blob_public) if allow_blob_public is not None else 'Unknown',
                        'Encryption Key Source': key_source,
                        'Provisioning State': storage.get('provisioningState', ''),
                        'Resource ID': storage.get('id', '')
                    })
                print(f"  [OK] {storage_file.name} - {len(data)} storage accounts")
    except Exception as e:
        print(f"  [ERROR] {storage_file.name}: {e}")

if storage_accounts:
    storage_csv = TRANSFORM_DIR / "storage_accounts.csv"
    with open(storage_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Storage Account Name', 'Resource Group', 'Location', 
            'SKU Name', 'SKU Tier', 'Access Tier', 'HTTPS Only', 'Allow Public Blob Access',
            'Encryption Key Source', 'Provisioning State', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(storage_accounts)
    print(f"  ✓ Created storage_accounts.csv ({len(storage_accounts)} accounts)")

# ============================================================================
# Transform Key Vaults
# ============================================================================
print()
print("Processing Key Vaults...")

key_vaults = []
kv_files = list(OUT_DIR.glob("*_keyvaults.json"))
print(f"  Found {len(kv_files)} Key Vault files")

for kv_file in kv_files:
    sub_id = kv_file.name.replace("_keyvaults.json", "")
    
    try:
        with open(kv_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for kv in data:
                    # Get SKU
                    sku = kv.get('sku', {})
                    sku_name = sku.get('name', '') if isinstance(sku, dict) else ''
                    
                    # Get properties
                    props = kv.get('properties', {})
                    if isinstance(props, dict):
                        enabled_for_deployment = props.get('enabledForDeployment', False)
                        enabled_for_disk_encryption = props.get('enabledForDiskEncryption', False)
                        enabled_for_template = props.get('enabledForTemplateDeployment', False)
                        soft_delete_enabled = props.get('enableSoftDelete', False)
                        purge_protection = props.get('enablePurgeProtection', False)
                        public_network_access = props.get('publicNetworkAccess', 'Unknown')
                    else:
                        enabled_for_deployment = False
                        enabled_for_disk_encryption = False
                        enabled_for_template = False
                        soft_delete_enabled = False
                        purge_protection = False
                        public_network_access = 'Unknown'
                    
                    key_vaults.append({
                        'Subscription ID': sub_id,
                        'Key Vault Name': kv.get('name', ''),
                        'Resource Group': kv.get('resourceGroup', ''),
                        'Location': kv.get('location', ''),
                        'SKU': sku_name,
                        'Soft Delete': 'Yes' if soft_delete_enabled else 'No',
                        'Purge Protection': 'Yes' if purge_protection else 'No',
                        'Public Network Access': public_network_access,
                        'Enabled For Deployment': 'Yes' if enabled_for_deployment else 'No',
                        'Enabled For Disk Encryption': 'Yes' if enabled_for_disk_encryption else 'No',
                        'Enabled For Template': 'Yes' if enabled_for_template else 'No',
                        'Resource ID': kv.get('id', '')
                    })
                print(f"  [OK] {kv_file.name} - {len(data)} Key Vaults")
    except Exception as e:
        print(f"  [ERROR] {kv_file.name}: {e}")

if key_vaults:
    kv_csv = TRANSFORM_DIR / "key_vaults.csv"
    with open(kv_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Key Vault Name', 'Resource Group', 'Location', 'SKU',
            'Soft Delete', 'Purge Protection', 'Public Network Access', 
            'Enabled For Deployment', 'Enabled For Disk Encryption', 'Enabled For Template',
            'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(key_vaults)
    print(f"  ✓ Created key_vaults.csv ({len(key_vaults)} Key Vaults)")

# ============================================================================
# Transform SQL Servers
# ============================================================================
print()
print("Processing SQL Servers...")

sql_servers = []
sql_server_files = list(OUT_DIR.glob("*_sql_servers.json"))
print(f"  Found {len(sql_server_files)} SQL server files")

for sql_file in sql_server_files:
    sub_id = sql_file.name.replace("_sql_servers.json", "")
    
    try:
        with open(sql_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for server in data:
                    # Get version
                    version = server.get('version', '')
                    
                    # Get admin login
                    admin_login = server.get('administratorLogin', '')
                    
                    # Get public network access
                    public_network = server.get('publicNetworkAccess', 'Unknown')
                    
                    # Get minimal TLS version
                    min_tls = server.get('minimalTlsVersion', '')
                    
                    sql_servers.append({
                        'Subscription ID': sub_id,
                        'SQL Server Name': server.get('name', ''),
                        'Resource Group': server.get('resourceGroup', ''),
                        'Location': server.get('location', ''),
                        'Version': version,
                        'Admin Login': admin_login,
                        'Public Network Access': public_network,
                        'Minimal TLS Version': min_tls,
                        'State': server.get('state', ''),
                        'Resource ID': server.get('id', '')
                    })
                print(f"  [OK] {sql_file.name} - {len(data)} SQL servers")
    except Exception as e:
        print(f"  [ERROR] {sql_file.name}: {e}")

if sql_servers:
    sql_csv = TRANSFORM_DIR / "sql_servers.csv"
    with open(sql_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'SQL Server Name', 'Resource Group', 'Location', 
            'Version', 'Admin Login', 'Public Network Access', 'Minimal TLS Version',
            'State', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(sql_servers)
    print(f"  ✓ Created sql_servers.csv ({len(sql_servers)} servers)")

# ============================================================================
# Transform SQL Databases
# ============================================================================
print()
print("Processing SQL Databases...")

sql_databases = []
sql_db_files = list(OUT_DIR.glob("*_sql_dbs.json"))
print(f"  Found {len(sql_db_files)} SQL database files")

for db_file in sql_db_files:
    sub_id = db_file.name.replace("_sql_dbs.json", "")
    
    try:
        with open(db_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for db in data:
                    # Get SKU info
                    sku = db.get('sku', {})
                    sku_name = sku.get('name', '') if isinstance(sku, dict) else ''
                    sku_tier = sku.get('tier', '') if isinstance(sku, dict) else ''
                    
                    # Get max size
                    max_size = db.get('maxSizeBytes', 0)
                    max_size_gb = round(max_size / (1024**3), 2) if max_size else 0
                    
                    sql_databases.append({
                        'Subscription ID': sub_id,
                        'Database Name': db.get('name', ''),
                        'Resource Group': db.get('resourceGroup', ''),
                        'Location': db.get('location', ''),
                        'SKU Name': sku_name,
                        'SKU Tier': sku_tier,
                        'Max Size (GB)': max_size_gb,
                        'Status': db.get('status', ''),
                        'Collation': db.get('collation', ''),
                        'Resource ID': db.get('id', '')
                    })
                print(f"  [OK] {db_file.name} - {len(data)} databases")
    except Exception as e:
        print(f"  [ERROR] {db_file.name}: {e}")

if sql_databases:
    db_csv = TRANSFORM_DIR / "sql_databases.csv"
    with open(db_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Database Name', 'Resource Group', 'Location', 
            'SKU Name', 'SKU Tier', 'Max Size (GB)', 'Status', 'Collation', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(sql_databases)
    print(f"  ✓ Created sql_databases.csv ({len(sql_databases)} databases)")

# ============================================================================
# Summary Statistics
# ============================================================================
print()
print("=" * 60)
print("Transformation Summary")
print("=" * 60)
print(f"Storage Accounts: {len(storage_accounts)}")
print(f"Key Vaults: {len(key_vaults)}")
print(f"SQL Servers: {len(sql_servers)}")
print(f"SQL Databases: {len(sql_databases)}")
print()
print(f"Output files created in: {TRANSFORM_DIR}")
if storage_accounts:
    print(f"  - storage_accounts.csv")
if key_vaults:
    print(f"  - key_vaults.csv")
if sql_servers:
    print(f"  - sql_servers.csv")
if sql_databases:
    print(f"  - sql_databases.csv")
print()

# Storage Account Statistics
if storage_accounts:
    print("Storage Account Statistics:")
    
    # SKU distribution
    skus = Counter(s['SKU Name'] for s in storage_accounts)
    print(f"  By SKU:")
    for sku, count in skus.most_common(5):
        print(f"    {sku}: {count}")
    
    # HTTPS enforcement
    https_count = sum(1 for s in storage_accounts if s['HTTPS Only'] == 'Yes')
    print(f"  HTTPS Only Enabled: {https_count}/{len(storage_accounts)} ({https_count/len(storage_accounts)*100:.1f}%)")
    
    # Public access
    public_disabled = sum(1 for s in storage_accounts if s['Allow Public Blob Access'] == 'False')
    print(f"  Public Blob Access Disabled: {public_disabled}/{len(storage_accounts)} ({public_disabled/len(storage_accounts)*100:.1f}%)")
    print()

# Key Vault Statistics
if key_vaults:
    print("Key Vault Statistics:")
    
    # Soft delete
    soft_delete = sum(1 for k in key_vaults if k['Soft Delete'] == 'Yes')
    print(f"  Soft Delete Enabled: {soft_delete}/{len(key_vaults)} ({soft_delete/len(key_vaults)*100:.1f}%)")
    
    # Purge protection
    purge_prot = sum(1 for k in key_vaults if k['Purge Protection'] == 'Yes')
    print(f"  Purge Protection Enabled: {purge_prot}/{len(key_vaults)} ({purge_prot/len(key_vaults)*100:.1f}%)")
    
    # Public access
    public_access = Counter(k['Public Network Access'] for k in key_vaults)
    print(f"  Public Network Access:")
    for access, count in public_access.most_common():
        print(f"    {access}: {count}")
    print()

# SQL Statistics
if sql_servers:
    print("SQL Server Statistics:")
    
    # Versions
    versions = Counter(s['Version'] for s in sql_servers)
    print(f"  By Version:")
    for version, count in versions.most_common():
        print(f"    {version}: {count}")
    
    # Public access
    public_access = Counter(s['Public Network Access'] for s in sql_servers)
    print(f"  Public Network Access:")
    for access, count in public_access.most_common():
        print(f"    {access}: {count}")
    
    # TLS versions
    tls_versions = Counter(s['Minimal TLS Version'] for s in sql_servers)
    print(f"  Minimal TLS Version:")
    for tls, count in tls_versions.most_common():
        print(f"    {tls if tls else 'Not Set'}: {count}")
    print()

if sql_databases:
    print("SQL Database Statistics:")
    
    # Tiers
    tiers = Counter(d['SKU Tier'] for d in sql_databases)
    print(f"  By SKU Tier:")
    for tier, count in tiers.most_common():
        print(f"    {tier}: {count}")
    
    # Total size
    total_size = sum(d['Max Size (GB)'] for d in sql_databases)
    print(f"  Total Provisioned Size: {total_size:.2f} GB")
    print(f"  Avg DB Size: {total_size/len(sql_databases):.2f} GB")
    print()

print("=" * 60)
print("Transformation complete!")
print("=" * 60)

