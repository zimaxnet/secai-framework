#!/usr/bin/env python3
"""
Top Security Risks Analysis
Identifies and prioritizes the most critical security risks from collected data
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
print("TOP SECURITY RISKS ANALYSIS")
print("=" * 70)
print()

# ============================================================================
# Load Data
# ============================================================================

# Load secure scores
secure_scores = []
scores_file = TRANSFORM_DIR / "secure_scores.csv"
if scores_file.exists():
    with open(scores_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        secure_scores = list(reader)

# Load security assessments
assessments = []
assessments_file = TRANSFORM_DIR / "security_assessments.csv"
if assessments_file.exists():
    with open(assessments_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        assessments = list(reader)

# Load Key Vaults
key_vaults = []
kv_file = TRANSFORM_DIR / "key_vaults.csv"
if kv_file.exists():
    with open(kv_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        key_vaults = list(reader)

# Load SQL Servers
sql_servers = []
sql_file = TRANSFORM_DIR / "sql_servers.csv"
if sql_file.exists():
    with open(sql_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        sql_servers = list(reader)

# Load role assignments
role_assignments = []
rbac_file = TRANSFORM_DIR / "role_assignments.csv"
if rbac_file.exists():
    with open(rbac_file, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        role_assignments = list(reader)

print(f"Loaded Data:")
print(f"  Secure Scores: {len(secure_scores)}")
print(f"  Security Assessments: {len(assessments)}")
print(f"  Key Vaults: {len(key_vaults)}")
print(f"  SQL Servers: {len(sql_servers)}")
print(f"  Role Assignments: {len(role_assignments)}")
print()

# ============================================================================
# Risk Analysis
# ============================================================================

risks = []

# RISK 1: Key Vaults without protection
kv_no_soft_delete = [kv for kv in key_vaults if kv.get('Soft Delete') == 'No']
if kv_no_soft_delete:
    risks.append({
        'Risk ID': 'RISK-001',
        'Category': 'Data Protection',
        'Severity': 'CRITICAL',
        'Title': 'Key Vaults Without Soft Delete Protection',
        'Description': f'{len(kv_no_soft_delete)} of {len(key_vaults)} Key Vaults have soft delete disabled',
        'Impact': 'Permanent loss of encryption keys, secrets, and certificates if accidentally deleted',
        'Affected Count': len(kv_no_soft_delete),
        'Compliance Impact': 'HIGH',
        'Remediation': 'Enable soft delete and purge protection on all Key Vaults via Azure Policy',
        'Estimated Effort': '1 week',
        'Priority': 1
    })

# RISK 2: SQL Servers with public access
sql_public = [sql for sql in sql_servers if sql.get('Public Network Access') == 'Enabled']
if sql_public:
    risks.append({
        'Risk ID': 'RISK-002',
        'Category': 'Network Security',
        'Severity': 'CRITICAL',
        'Title': 'SQL Servers with Public Network Access Enabled',
        'Description': f'{len(sql_public)} of {len(sql_servers)} SQL servers are exposed to the internet',
        'Impact': 'Database servers vulnerable to brute force attacks and unauthorized access attempts',
        'Affected Count': len(sql_public),
        'Compliance Impact': 'HIGH',
        'Remediation': 'Disable public access and implement Private Endpoints',
        'Estimated Effort': '2-3 weeks',
        'Priority': 2
    })

# RISK 3: Low Secure Scores
if secure_scores:
    low_scores = [s for s in secure_scores if float(s.get('Percentage', 0)) < 40]
    if low_scores:
        risks.append({
            'Risk ID': 'RISK-003',
            'Category': 'Security Posture',
            'Severity': 'HIGH',
            'Title': 'Subscriptions with Low Secure Score',
            'Description': f'{len(low_scores)} of {len(secure_scores)} subscriptions have Secure Score below 40%',
            'Impact': 'Indicates significant security gaps and misconfigurations',
            'Affected Count': len(low_scores),
            'Compliance Impact': 'MEDIUM',
            'Remediation': 'Address Defender recommendations in low-scoring subscriptions',
            'Estimated Effort': '2-3 months',
            'Priority': 3
        })

# RISK 4: Unhealthy security assessments
unhealthy = [a for a in assessments if a.get('Status') == 'Unhealthy']
if unhealthy:
    risks.append({
        'Risk ID': 'RISK-004',
        'Category': 'Security Compliance',
        'Severity': 'HIGH',
        'Title': 'Unhealthy Security Assessments',
        'Description': f'{len(unhealthy)} security findings marked as unhealthy by Defender for Cloud',
        'Impact': 'Active security vulnerabilities and misconfigurations requiring remediation',
        'Affected Count': len(unhealthy),
        'Compliance Impact': 'HIGH',
        'Remediation': 'Prioritize by severity and remediate systematically',
        'Estimated Effort': 'Ongoing - 3-6 months',
        'Priority': 4
    })

# RISK 5: Excessive Owner assignments
if role_assignments:
    owners = [r for r in role_assignments if r.get('Role Name') == 'Owner']
    if len(owners) > 100:  # Threshold
        risks.append({
            'Risk ID': 'RISK-005',
            'Category': 'Identity & Access',
            'Severity': 'HIGH',
            'Title': 'Excessive Owner Role Assignments',
            'Description': f'{len(owners)} Owner role assignments across environment',
            'Impact': 'Over-privileged access increases risk of accidental or malicious changes',
            'Affected Count': len(owners),
            'Compliance Impact': 'MEDIUM',
            'Remediation': 'Review all Owner assignments, implement Just-In-Time (JIT) access via PIM',
            'Estimated Effort': '2-4 weeks',
            'Priority': 5
        })

# RISK 6: Direct user assignments
if role_assignments:
    user_assignments = [r for r in role_assignments if r.get('Principal Type') == 'User']
    privileged_users = [r for r in user_assignments if r.get('Role Name') in ['Owner', 'Contributor', 'User Access Administrator']]
    if privileged_users:
        risks.append({
            'Risk ID': 'RISK-006',
            'Category': 'Identity & Access',
            'Severity': 'MEDIUM',
            'Title': 'Direct User Assignments with Privileged Access',
            'Description': f'{len(privileged_users)} direct user assignments with Owner/Contributor access',
            'Impact': 'Direct assignments bypass group management and auditing',
            'Affected Count': len(privileged_users),
            'Compliance Impact': 'MEDIUM',
            'Remediation': 'Migrate to group-based access management',
            'Estimated Effort': '2 weeks',
            'Priority': 6
        })

# RISK 7: Subscriptions with very low scores
if secure_scores:
    critical_scores = [s for s in secure_scores if float(s.get('Percentage', 0)) < 10]
    if critical_scores:
        risks.append({
            'Risk ID': 'RISK-007',
            'Category': 'Security Posture',
            'Severity': 'CRITICAL',
            'Title': 'Subscriptions with Critical Secure Score',
            'Description': f'{len(critical_scores)} subscriptions have Secure Score below 10%',
            'Impact': 'Extreme security risk - immediate attention required',
            'Affected Count': len(critical_scores),
            'Compliance Impact': 'CRITICAL',
            'Remediation': 'Emergency security review and remediation',
            'Estimated Effort': '1-2 weeks',
            'Priority': 1
        })

# ============================================================================
# Generate Report
# ============================================================================

# Sort risks by priority
risks.sort(key=lambda x: (0 if x['Severity'] == 'CRITICAL' else 1 if x['Severity'] == 'HIGH' else 2, x['Priority']))

# Write to CSV
if risks:
    risk_csv = ANALYSIS_DIR / "top_security_risks.csv"
    with open(risk_csv, 'w', newline='', encoding='utf-8-sig') as f:
        fieldnames = ['Risk ID', 'Category', 'Severity', 'Title', 'Description', 'Impact', 
                      'Affected Count', 'Compliance Impact', 'Remediation', 'Estimated Effort', 'Priority']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(risks)
    
    print(f"✓ Created top_security_risks.csv ({len(risks)} risks)")
    print()

# Print summary
print("=" * 70)
print("TOP SECURITY RISKS IDENTIFIED")
print("=" * 70)
print()

critical_risks = [r for r in risks if r['Severity'] == 'CRITICAL']
high_risks = [r for r in risks if r['Severity'] == 'HIGH']
medium_risks = [r for r in risks if r['Severity'] == 'MEDIUM']

print(f"CRITICAL Severity: {len(critical_risks)}")
print(f"HIGH Severity: {len(high_risks)}")
print(f"MEDIUM Severity: {len(medium_risks)}")
print()

for risk in risks:
    severity_marker = "🔴" if risk['Severity'] == 'CRITICAL' else "🟠" if risk['Severity'] == 'HIGH' else "🟡"
    print(f"{severity_marker} {risk['Risk ID']}: {risk['Title']}")
    print(f"   Severity: {risk['Severity']} | Category: {risk['Category']}")
    print(f"   Affected: {risk['Affected Count']} items")
    print(f"   Remediation: {risk['Remediation']}")
    print(f"   Effort: {risk['Estimated Effort']}")
    print()

print("=" * 70)
print(f"Report saved to: {ANALYSIS_DIR / 'top_security_risks.csv'}")
print("=" * 70)

