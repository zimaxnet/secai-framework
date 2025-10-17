#!/usr/bin/env python3
"""
Azure Logging & Monitoring Transformation Script
Converts Log Analytics and diagnostic settings JSON data to CSV format for Excel import
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
print("Azure Logging & Monitoring Transformation")
print("=" * 60)
print(f"Input directory: {OUT_DIR}")
print(f"Output directory: {TRANSFORM_DIR}")
print()

# ============================================================================
# Transform Log Analytics Workspaces
# ============================================================================
print("Processing Log Analytics Workspaces...")

log_analytics = []
la_files = list(OUT_DIR.glob("*_la_workspaces.json"))
print(f"  Found {len(la_files)} Log Analytics files")

for la_file in la_files:
    sub_id = la_file.name.replace("_la_workspaces.json", "")
    
    try:
        with open(la_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            if isinstance(data, list):
                for workspace in data:
                    # Get properties
                    props = workspace.get('properties', {})
                    if isinstance(props, dict):
                        retention_days = props.get('retentionInDays', 0)
                        sku_name = props.get('sku', {}).get('name', '') if isinstance(props.get('sku'), dict) else ''
                        public_network_access = props.get('publicNetworkAccessForIngestion', 'Unknown')
                        provisioning_state = props.get('provisioningState', '')
                    else:
                        retention_days = 0
                        sku_name = ''
                        public_network_access = 'Unknown'
                        provisioning_state = ''
                    
                    log_analytics.append({
                        'Subscription ID': sub_id,
                        'Workspace Name': workspace.get('name', ''),
                        'Resource Group': workspace.get('resourceGroup', ''),
                        'Location': workspace.get('location', ''),
                        'SKU': sku_name,
                        'Retention Days': retention_days,
                        'Public Network Access': public_network_access,
                        'Provisioning State': provisioning_state,
                        'Resource ID': workspace.get('id', '')
                    })
                print(f"  [OK] {la_file.name} - {len(data)} workspaces")
    except Exception as e:
        print(f"  [ERROR] {la_file.name}: {e}")

if log_analytics:
    la_csv = TRANSFORM_DIR / "log_analytics_workspaces.csv"
    with open(la_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Workspace Name', 'Resource Group', 'Location', 
            'SKU', 'Retention Days', 'Public Network Access', 'Provisioning State', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(log_analytics)
    print(f"  ✓ Created log_analytics_workspaces.csv ({len(log_analytics)} workspaces)")

# ============================================================================
# Transform Diagnostic Settings
# ============================================================================
print()
print("Processing Diagnostic Settings...")

diagnostic_settings = []
diag_files = list(OUT_DIR.glob("*_subscription_diag.json"))
print(f"  Found {len(diag_files)} diagnostic settings files")

for diag_file in diag_files:
    sub_id = diag_file.name.replace("_subscription_diag.json", "")
    
    try:
        with open(diag_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            if not content or content == "[]":
                continue
            
            data = json.loads(content)
            
            # Handle both array and object with value property
            settings_list = []
            if isinstance(data, list):
                settings_list = data
            elif isinstance(data, dict) and 'value' in data:
                settings_list = data['value']
            
            for setting in settings_list:
                # Get properties
                props = setting.get('properties', {})
                if isinstance(props, dict):
                    workspace_id = props.get('workspaceId', '')
                    storage_account_id = props.get('storageAccountId', '')
                    event_hub_name = props.get('eventHubName', '')
                    
                    # Count enabled logs and metrics
                    logs = props.get('logs', [])
                    metrics = props.get('metrics', [])
                    enabled_logs = sum(1 for log in logs if log.get('enabled', False)) if isinstance(logs, list) else 0
                    enabled_metrics = sum(1 for metric in metrics if metric.get('enabled', False)) if isinstance(metrics, list) else 0
                else:
                    workspace_id = ''
                    storage_account_id = ''
                    event_hub_name = ''
                    enabled_logs = 0
                    enabled_metrics = 0
                
                # Determine destination
                destination = []
                if workspace_id:
                    destination.append('Log Analytics')
                if storage_account_id:
                    destination.append('Storage')
                if event_hub_name:
                    destination.append('Event Hub')
                destination_str = ', '.join(destination) if destination else 'None'
                
                diagnostic_settings.append({
                    'Subscription ID': sub_id,
                    'Setting Name': setting.get('name', ''),
                    'Destination': destination_str,
                    'Enabled Logs': enabled_logs,
                    'Enabled Metrics': enabled_metrics,
                    'Workspace ID': workspace_id,
                    'Storage Account ID': storage_account_id,
                    'Event Hub Name': event_hub_name,
                    'Resource ID': setting.get('id', '')
                })
            
            if settings_list:
                print(f"  [OK] {diag_file.name} - {len(settings_list)} settings")
    except Exception as e:
        print(f"  [ERROR] {diag_file.name}: {e}")

if diagnostic_settings:
    diag_csv = TRANSFORM_DIR / "diagnostic_settings.csv"
    with open(diag_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Setting Name', 'Destination', 'Enabled Logs', 'Enabled Metrics',
            'Workspace ID', 'Storage Account ID', 'Event Hub Name', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(diagnostic_settings)
    print(f"  ✓ Created diagnostic_settings.csv ({len(diagnostic_settings)} settings)")

# ============================================================================
# Summary Statistics
# ============================================================================
print()
print("=" * 60)
print("Transformation Summary")
print("=" * 60)
print(f"Log Analytics Workspaces: {len(log_analytics)}")
print(f"Diagnostic Settings: {len(diagnostic_settings)}")
print()
print(f"Output files created in: {TRANSFORM_DIR}")
if log_analytics:
    print(f"  - log_analytics_workspaces.csv")
if diagnostic_settings:
    print(f"  - diagnostic_settings.csv")
print()

# Log Analytics Statistics
if log_analytics:
    print("Log Analytics Workspace Statistics:")
    
    # SKU distribution
    skus = Counter(w['SKU'] for w in log_analytics)
    print(f"  By SKU:")
    for sku, count in skus.most_common():
        print(f"    {sku if sku else 'Not Set'}: {count}")
    
    # Retention analysis
    retentions = [w['Retention Days'] for w in log_analytics if w['Retention Days'] > 0]
    if retentions:
        print(f"  Retention Days:")
        print(f"    Min: {min(retentions)}")
        print(f"    Max: {max(retentions)}")
        print(f"    Avg: {sum(retentions)/len(retentions):.1f}")
    
    # Locations
    locations = Counter(w['Location'] for w in log_analytics)
    print(f"  Top Locations:")
    for location, count in locations.most_common(3):
        print(f"    {location}: {count}")
    print()

# Diagnostic Settings Statistics
if diagnostic_settings:
    print("Diagnostic Settings Statistics:")
    
    # Destinations
    destinations = Counter(d['Destination'] for d in diagnostic_settings)
    print(f"  By Destination:")
    for dest, count in destinations.most_common():
        print(f"    {dest}: {count}")
    
    # Coverage
    subs_with_diag = len(set(d['Subscription ID'] for d in diagnostic_settings))
    print(f"  Subscriptions with Diagnostics: {subs_with_diag}")
    print()

print("=" * 60)
print("Transformation complete!")
print("=" * 60)

