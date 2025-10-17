#!/usr/bin/env python3
"""
Azure Security Data Transformation Script
Converts security JSON data to CSV format for Excel import
"""

import json
import csv
import os
from pathlib import Path
from datetime import datetime

# Determine paths
SCRIPT_DIR = Path(__file__).parent
ROOT_DIR = SCRIPT_DIR.parent
OUT_DIR = ROOT_DIR / "out"
TRANSFORM_DIR = ROOT_DIR / "transformed"

# Create transformed directory if it doesn't exist
TRANSFORM_DIR.mkdir(exist_ok=True)

print("=" * 60)
print("Azure Security Data Transformation")
print("=" * 60)
print(f"Input directory: {OUT_DIR}")
print(f"Output directory: {TRANSFORM_DIR}")
print()

# ============================================================================
# Transform Secure Scores
# ============================================================================
print("Processing Secure Scores...")

secure_scores = []
score_files = list(OUT_DIR.glob("*_secure_score.json"))
print(f"  Found {len(score_files)} secure score files")

for score_file in score_files:
    # Extract subscription ID from filename
    sub_id = score_file.name.replace("_secure_score.json", "")
    
    try:
        with open(score_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            
            # Debug: show file size
            # print(f"  [DEBUG] {score_file.name} - {len(content)} bytes")
            
            # Skip empty files
            if not content or content == "{}" or content == "[]":
                print(f"  [SKIP] {score_file.name} - empty (size: {len(content)})")
                continue
            
            data = json.loads(content)
            
            # Handle array of scores
            if isinstance(data, list):
                count_before = len(secure_scores)
                for score_obj in data:
                    secure_scores.append({
                        'Subscription ID': sub_id,
                        'Score Name': score_obj.get('displayName', ''),
                        'Current Score': score_obj.get('current', 0),
                        'Max Score': score_obj.get('max', 0),
                        'Percentage': round((score_obj.get('current', 0) / score_obj.get('max', 1)) * 100, 2) if score_obj.get('max', 0) > 0 else 0,
                        'Resource ID': score_obj.get('id', '')
                    })
                print(f"  [OK] {score_file.name} - {len(secure_scores) - count_before} scores")
            # Handle single score object
            elif isinstance(data, dict) and 'current' in data:
                secure_scores.append({
                    'Subscription ID': sub_id,
                    'Score Name': data.get('displayName', ''),
                    'Current Score': data.get('current', 0),
                    'Max Score': data.get('max', 0),
                    'Percentage': round((data.get('current', 0) / data.get('max', 1)) * 100, 2) if data.get('max', 0) > 0 else 0,
                    'Resource ID': data.get('id', '')
                })
                print(f"  [OK] {score_file.name} - 1 score")
    except json.JSONDecodeError as e:
        print(f"  [WARN] Could not parse {score_file.name}: {e}")
    except Exception as e:
        print(f"  [ERROR] Failed to process {score_file.name}: {e}")

# Write secure scores CSV
if secure_scores:
    scores_csv = TRANSFORM_DIR / "secure_scores.csv"
    with open(scores_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Score Name', 'Current Score', 'Max Score', 'Percentage', 'Resource ID'
        ])
        writer.writeheader()
        writer.writerows(secure_scores)
    
    print(f"  ✓ Created secure_scores.csv ({len(secure_scores)} scores)")
else:
    print("  ⚠ No secure scores found")

# ============================================================================
# Transform Security Assessments
# ============================================================================
print()
print("Processing Security Assessments...")

assessments = []
assessment_files = list(OUT_DIR.glob("*_security_assessments.json"))
print(f"  Found {len(assessment_files)} security assessment files")
total_assessments = 0

for assess_file in assessment_files:
    # Extract subscription ID from filename
    sub_id = assess_file.name.replace("_security_assessments.json", "")
    
    try:
        with open(assess_file, 'r', encoding='utf-8-sig') as f:
            content = f.read().strip()
            
            # Skip empty files
            if not content or content == "[]":
                print(f"  [SKIP] {assess_file.name} - empty")
                continue
            
            # Try to parse JSON (may fail due to duplicate keys)
            try:
                data = json.loads(content)
            except json.JSONDecodeError:
                # JSON parsing failed due to duplicate keys - use regex extraction
                import re
                
                # Extract assessments using regex
                # Pattern to find each assessment object
                assessment_pattern = r'"displayName":\s*"([^"]*)".*?"status":\s*\{[^}]*"code":\s*"([^"]*)"'
                matches = re.findall(assessment_pattern, content, re.DOTALL)
                
                count = len(matches)
                total_assessments += count
                
                # Extract basic info for each assessment
                for match in matches:
                    display_name, status_code = match
                    assessments.append({
                        'Subscription ID': sub_id,
                        'Assessment Name': display_name,
                        'Status': status_code,
                        'Cause': '',
                        'Description': '',
                        'Affected Resource': '',
                        'Assessment ID': ''
                    })
                
                print(f"  [OK] {assess_file.name}: {count} assessments (regex extraction)")
                continue
            
            # Handle array of assessments
            if isinstance(data, list):
                for assessment in data:
                    # Extract key fields
                    display_name = assessment.get('displayName', '')
                    resource_id = assessment.get('id', '')
                    
                    # Get status info
                    status_code = ''
                    status_cause = ''
                    status_description = ''
                    
                    if 'status' in assessment:
                        status_code = assessment['status'].get('code', '')
                        status_cause = assessment['status'].get('cause', '')
                        status_description = assessment['status'].get('description', '')
                    elif 'properties' in assessment and 'status' in assessment['properties']:
                        status_code = assessment['properties']['status'].get('code', '')
                        status_cause = assessment['properties']['status'].get('cause', '')
                        status_description = assessment['properties']['status'].get('description', '')
                    
                    # Get resource details
                    resource_details = assessment.get('resourceDetails', {})
                    if 'properties' in assessment and 'resourceDetails' in assessment['properties']:
                        resource_details = assessment['properties']['resourceDetails']
                    
                    affected_resource = resource_details.get('id', '')
                    
                    assessments.append({
                        'Subscription ID': sub_id,
                        'Assessment Name': display_name,
                        'Status': status_code,
                        'Cause': status_cause,
                        'Description': status_description[:500] if status_description else '',  # Truncate long descriptions
                        'Affected Resource': affected_resource,
                        'Assessment ID': resource_id
                    })
                
                total_assessments += len(data)
                print(f"  [OK] {assess_file.name}: {len(data)} assessments")
    
    except Exception as e:
        print(f"  [ERROR] Failed to process {assess_file.name}: {e}")

# Write assessments CSV
if assessments:
    assessments_csv = TRANSFORM_DIR / "security_assessments.csv"
    with open(assessments_csv, 'w', newline='', encoding='utf-8-sig') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'Subscription ID', 'Assessment Name', 'Status', 'Cause', 'Description', 'Affected Resource', 'Assessment ID'
        ])
        writer.writeheader()
        writer.writerows(assessments)
    
    print(f"  ✓ Created security_assessments.csv ({len(assessments)} assessments parsed)")
else:
    print("  ⚠ No security assessments could be parsed")

if total_assessments > len(assessments):
    print(f"  [INFO] Total assessments in files: ~{total_assessments} (some couldn't be parsed due to JSON format issues)")

# ============================================================================
# Summary Statistics
# ============================================================================
print()
print("=" * 60)
print("Transformation Summary")
print("=" * 60)
print(f"Secure Scores: {len(secure_scores)}")
print(f"Security Assessments: {len(assessments)} parsed ({total_assessments} total)")
print()
print(f"Output files created in: {TRANSFORM_DIR}")
if secure_scores:
    print(f"  - secure_scores.csv")
if assessments:
    print(f"  - security_assessments.csv")
print()

# Calculate aggregate metrics
if secure_scores:
    print("Secure Score Statistics:")
    avg_current = sum(s['Current Score'] for s in secure_scores) / len(secure_scores)
    avg_max = sum(s['Max Score'] for s in secure_scores) / len(secure_scores)
    avg_pct = sum(s['Percentage'] for s in secure_scores) / len(secure_scores)
    print(f"  Average Score: {avg_current:.1f} / {avg_max:.1f} ({avg_pct:.1f}%)")
    print(f"  Min Score: {min(s['Percentage'] for s in secure_scores):.1f}%")
    print(f"  Max Score: {max(s['Percentage'] for s in secure_scores):.1f}%")
    print()

if assessments:
    # Count by status
    status_counts = {}
    for a in assessments:
        status = a['Status']
        status_counts[status] = status_counts.get(status, 0) + 1
    
    print("Assessment Status Breakdown:")
    for status, count in sorted(status_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {status}: {count}")
    print()

print("=" * 60)
print("Transformation complete!")
print("=" * 60)

