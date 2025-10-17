#!/usr/bin/env python3
"""
Subscription Comparison Analysis
Compares security posture, resources, and configurations across all subscriptions
"""

import csv
from pathlib import Path
from collections import defaultdict

# Determine paths
SCRIPT_DIR = Path(__file__).parent
ROOT_DIR = SCRIPT_DIR.parent
TRANSFORM_DIR = ROOT_DIR / "transformed"
ANALYSIS_DIR = ROOT_DIR / "analysis"

# Create analysis directory
ANALYSIS_DIR.mkdir(exist_ok=True)

print("=" * 70)
print("SUBSCRIPTION COMPARISON ANALYSIS")
print("=" * 70)
print()

# ============================================================================
# Load All Data
# ============================================================================

def load_csv(filename):
    """Helper to load CSV files"""
    filepath = TRANSFORM_DIR / filename
    if filepath.exists():
        with open(filepath, 'r', encoding='utf-8-sig') as f:
            return list(csv.DictReader(f))
    return []

print("Loading data...")
secure_scores = load_csv("secure_scores.csv")
assessments = load_csv("security_assessments.csv")
resources = load_csv("resources.csv")
resource_groups = load_csv("resource_groups.csv")
role_assignments = load_csv("role_assignments.csv")
storage_accounts = load_csv("storage_accounts.csv")
key_vaults = load_csv("key_vaults.csv")
vnets = load_csv("virtual_networks.csv")
nsgs = load_csv("network_security_groups.csv")

print(f"  ✓ Loaded {len(secure_scores)} secure scores")
print(f"  ✓ Loaded {len(assessments)} assessments")
print(f"  ✓ Loaded {len(resources)} resources")
print()

# ============================================================================
# Build Subscription Profiles
# ============================================================================

print("Building subscription profiles...")

# Get unique subscription IDs from scope
sub_ids = set()
for item in resources + role_assignments + secure_scores:
    if item.get('Subscription ID'):
        sub_ids.add(item['Subscription ID'])

print(f"  Found {len(sub_ids)} unique subscriptions")
print()

# Build profile for each subscription
subscription_profiles = []

for sub_id in sorted(sub_ids):
    profile = {
        'Subscription ID': sub_id,
    }
    
    # Secure Score
    sub_scores = [s for s in secure_scores if s['Subscription ID'] == sub_id]
    if sub_scores:
        profile['Secure Score %'] = float(sub_scores[0].get('Percentage', 0))
        profile['Secure Score'] = f"{sub_scores[0].get('Current Score', 0)}/{sub_scores[0].get('Max Score', 0)}"
    else:
        profile['Secure Score %'] = 0
        profile['Secure Score'] = 'N/A'
    
    # Security Assessments
    sub_assessments = [a for a in assessments if a['Subscription ID'] == sub_id]
    profile['Total Assessments'] = len(sub_assessments)
    profile['Unhealthy'] = len([a for a in sub_assessments if a.get('Status') == 'Unhealthy'])
    profile['Healthy'] = len([a for a in sub_assessments if a.get('Status') == 'Healthy'])
    
    # Resources
    sub_resources = [r for r in resources if r['Subscription ID'] == sub_id]
    profile['Total Resources'] = len(sub_resources)
    
    # Resource Groups
    sub_rgs = [rg for rg in resource_groups if rg['Subscription ID'] == sub_id]
    profile['Resource Groups'] = len(sub_rgs)
    
    # Role Assignments
    sub_roles = [r for r in role_assignments if r['Subscription ID'] == sub_id]
    profile['Role Assignments'] = len(sub_roles)
    profile['Owners'] = len([r for r in sub_roles if r.get('Role Name') == 'Owner'])
    profile['Contributors'] = len([r for r in sub_roles if r.get('Role Name') == 'Contributor'])
    
    # Storage
    sub_storage = [s for s in storage_accounts if s['Subscription ID'] == sub_id]
    profile['Storage Accounts'] = len(sub_storage)
    
    # Key Vaults
    sub_kvs = [kv for kv in key_vaults if kv['Subscription ID'] == sub_id]
    profile['Key Vaults'] = len(sub_kvs)
    profile['KV Soft Delete'] = len([kv for kv in sub_kvs if kv.get('Soft Delete') == 'Yes'])
    
    # VNets
    sub_vnets = [v for v in vnets if v['Subscription ID'] == sub_id]
    profile['VNets'] = len(sub_vnets)
    
    # NSGs
    sub_nsgs = [n for n in nsgs if n['Subscription ID'] == sub_id]
    profile['NSGs'] = len(sub_nsgs)
    
    # Risk Score (simple calculation)
    risk_score = 0
    if profile['Secure Score %'] < 40:
        risk_score += 30
    elif profile['Secure Score %'] < 70:
        risk_score += 15
    
    if profile['Unhealthy'] > 50:
        risk_score += 25
    elif profile['Unhealthy'] > 20:
        risk_score += 15
    
    if profile['Owners'] > 10:
        risk_score += 20
    elif profile['Owners'] > 5:
        risk_score += 10
    
    if profile['Key Vaults'] > 0 and profile['KV Soft Delete'] == 0:
        risk_score += 25
    
    profile['Risk Score'] = risk_score
    profile['Risk Level'] = 'CRITICAL' if risk_score >= 60 else 'HIGH' if risk_score >= 40 else 'MEDIUM' if risk_score >= 20 else 'LOW'
    
    subscription_profiles.append(profile)

# Sort by risk score descending
subscription_profiles.sort(key=lambda x: x['Risk Score'], reverse=True)

# ============================================================================
# Write Reports
# ============================================================================

# Write detailed comparison CSV
comparison_csv = ANALYSIS_DIR / "subscription_comparison.csv"
with open(comparison_csv, 'w', newline='', encoding='utf-8-sig') as f:
    fieldnames = ['Subscription ID', 'Secure Score %', 'Secure Score', 'Total Assessments', 
                  'Unhealthy', 'Healthy', 'Total Resources', 'Resource Groups', 
                  'Role Assignments', 'Owners', 'Contributors', 'Storage Accounts', 
                  'Key Vaults', 'KV Soft Delete', 'VNets', 'NSGs', 'Risk Score', 'Risk Level']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(subscription_profiles)

print(f"✓ Created subscription_comparison.csv")
print()

# Write high-risk subscriptions
high_risk_subs = [s for s in subscription_profiles if s['Risk Level'] in ['CRITICAL', 'HIGH']]
if high_risk_subs:
    high_risk_csv = ANALYSIS_DIR / "high_risk_subscriptions.csv"
    with open(high_risk_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(high_risk_subs)
    print(f"✓ Created high_risk_subscriptions.csv ({len(high_risk_subs)} subscriptions)")
    print()

# ============================================================================
# Display Summary
# ============================================================================

print("=" * 70)
print("SUBSCRIPTION RISK RANKING")
print("=" * 70)
print()

print(f"Total Subscriptions: {len(subscription_profiles)}")
print(f"  CRITICAL Risk: {len([s for s in subscription_profiles if s['Risk Level'] == 'CRITICAL'])}")
print(f"  HIGH Risk: {len([s for s in subscription_profiles if s['Risk Level'] == 'HIGH'])}")
print(f"  MEDIUM Risk: {len([s for s in subscription_profiles if s['Risk Level'] == 'MEDIUM'])}")
print(f"  LOW Risk: {len([s for s in subscription_profiles if s['Risk Level'] == 'LOW'])}")
print()

print("TOP 10 HIGHEST RISK SUBSCRIPTIONS:")
print()

for i, sub in enumerate(subscription_profiles[:10], 1):
    risk_marker = "🔴" if sub['Risk Level'] == 'CRITICAL' else "🟠" if sub['Risk Level'] == 'HIGH' else "🟡"
    print(f"{i}. {risk_marker} {sub['Subscription ID'][:8]}... | Risk Score: {sub['Risk Score']} | {sub['Risk Level']}")
    print(f"   Secure Score: {sub['Secure Score %']:.1f}% | Unhealthy: {sub['Unhealthy']} | Owners: {sub['Owners']}")
    print()

print("=" * 70)
print("BEST PERFORMING SUBSCRIPTIONS:")
print("=" * 70)
print()

# Get lowest risk subscriptions
best_subs = sorted(subscription_profiles, key=lambda x: x['Risk Score'])[:5]

for i, sub in enumerate(best_subs, 1):
    print(f"{i}. ✅ {sub['Subscription ID'][:8]}... | Risk Score: {sub['Risk Score']} | {sub['Risk Level']}")
    print(f"   Secure Score: {sub['Secure Score %']:.1f}% | Unhealthy: {sub['Unhealthy']} | Resources: {sub['Total Resources']}")
    print()

print("=" * 70)
print(f"Analysis complete! Reports saved to: {ANALYSIS_DIR}")
print("=" * 70)

