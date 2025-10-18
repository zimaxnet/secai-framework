# CIS Azure Foundations Benchmark v2.0 - SecAI Framework Mapping Matrix

**Purpose:** Map CIS Benchmark controls to SecAI Framework evidence collection  
**Date:** October 17, 2025  
**Status:** Initial Draft - Requires Validation Against CIS Benchmark Document

---

## How to Use This Matrix

1. **Obtain CIS Benchmark:** Download the official CIS Microsoft Azure Foundations Benchmark v2.0 from [CIS website](https://www.cisecurity.org/)
2. **Validate Controls:** Cross-reference control numbers and descriptions
3. **Update Evidence:** Add specific JSON file paths and properties to check
4. **Implement Validation:** Create automation to check each control
5. **Generate Scorecard:** Calculate compliance percentage automatically

---

## Mapping Structure

For each CIS control:
- **Control ID:** CIS control number
- **Title:** Control description
- **Level:** Level 1 (basic) or Level 2 (defense-in-depth)
- **SecAI Script:** Which collection script provides evidence
- **Evidence File:** Specific JSON file to check
- **Evidence Property:** Property path to validate
- **Pass Criteria:** What makes this control compliant
- **Validation Method:** How to check (manual, automated, PowerShell, etc.)

---

## Section 1: Identity and Access Management

### 1.1 Ensure that MFA is Enabled for All User Accounts (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 1.1 |
| **Title** | Ensure Multi-Factor Authentication (MFA) is enabled for all users |
| **Level** | 1 (Basic Security) |
| **SecAI Script** | 04_identity_and_privileged |
| **Evidence File** | Azure AD Conditional Access policies (if accessible) |
| **Evidence Property** | Conditional Access policies requiring MFA |
| **Pass Criteria** | All users are covered by CA policy requiring MFA |
| **Validation** | Manual review of Entra ID configuration |
| **Gap Risk** | HIGH - Credential compromise without MFA |
| **Remediation** | Enable MFA for all user accounts via Conditional Access |

### 1.2 Ensure Guest Users Are Reviewed on a Regular Basis (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 1.2 |
| **Title** | Ensure guest users are reviewed on a regular basis |
| **Level** | 1 |
| **SecAI Script** | 04_identity_and_privileged |
| **Evidence File** | Azure AD guest users (if accessible) |
| **Evidence Property** | List of guest users, last sign-in date |
| **Pass Criteria** | Process in place for quarterly guest user access reviews |
| **Validation** | Process Assessment (Dimension 2) - Interview |
| **Gap Risk** | MEDIUM - Stale guest accounts with access |
| **Remediation** | Implement quarterly access reviews for guest users |

### 1.3 Ensure that 'Require Multi-Factor Auth to Join Devices' is Set to 'Yes' (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 1.3 |
| **Title** | Ensure 'Require MFA to join devices' is set to 'Yes' |
| **Level** | 1 |
| **SecAI Script** | Manual - Entra ID Portal |
| **Evidence File** | Azure AD Device Settings |
| **Evidence Property** | Require MFA to join devices = Yes |
| **Pass Criteria** | Setting is enabled |
| **Validation** | Manual check in Entra ID → Devices → Device Settings |
| **Gap Risk** | MEDIUM - Device enrollment without strong authentication |
| **Remediation** | Enable setting in Entra ID device settings |

### 1.4-1.20 Additional Identity Controls

*[Note: Continue mapping all Section 1 controls - approximately 20+ controls]*

Key controls to map:
- 1.4 - 1.10: Azure AD security defaults, sign-in risk policies
- 1.11-1.15: Application permissions and consent
- 1.16-1.20: Service principals and managed identities
- 1.21-1.23: RBAC and privileged access

---

## Section 2: Microsoft Defender for Cloud

### 2.1 Ensure That Microsoft Defender for Cloud is Set to Standard Tier (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 2.1 |
| **Title** | Ensure Microsoft Defender for Cloud Standard tier is enabled |
| **Level** | 1 |
| **SecAI Script** | 03_policies_and_defender.ps1 |
| **Evidence File** | `{sub-id}_defender_pricing.json` |
| **Evidence Property** | `pricingTier` for each resource type |
| **Pass Criteria** | `pricingTier == "Standard"` for VMs, Storage, SQL, etc. |
| **Validation** | AUTOMATED - Parse JSON and check pricingTier |
| **Gap Risk** | HIGH - No advanced threat protection |
| **Remediation** | Enable Defender for Cloud Standard tier |

**Sample Evidence Check (PowerShell):**
```powershell
# Check if Defender Standard tier is enabled
$defenderPricing = Get-Content "{sub-id}_defender_pricing.json" | ConvertFrom-Json
$standardEnabled = $defenderPricing | Where-Object { $_.pricingTier -eq "Standard" }
if ($standardEnabled.Count -gt 0) {
    Write-Host "PASS: Defender Standard tier enabled"
} else {
    Write-Host "FAIL: Defender not on Standard tier"
}
```

### 2.2 Ensure That 'Automatic Provisioning of Monitoring Agent' is Set to 'On' (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 2.2 |
| **Title** | Ensure automatic provisioning of monitoring agent is enabled |
| **Level** | 1 |
| **SecAI Script** | 03_policies_and_defender.ps1 |
| **Evidence File** | `{sub-id}_defender_settings.json` |
| **Evidence Property** | `autoProvision` setting |
| **Pass Criteria** | Auto-provision is "On" |
| **Validation** | AUTOMATED - Parse JSON and check setting |
| **Gap Risk** | MEDIUM - VMs without monitoring agents |
| **Remediation** | Enable auto-provisioning in Defender for Cloud settings |

### 2.3-2.15 Additional Defender Controls

*[Note: Continue mapping all Section 2 controls]*

Key controls:
- 2.3-2.10: Defender plans for specific resource types (Storage, SQL, Containers, etc.)
- 2.11-2.15: Defender settings (email notifications, contact info, etc.)

---

## Section 3: Storage Accounts

### 3.1 Ensure that 'Secure Transfer Required' is Enabled for Storage Accounts (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 3.1 |
| **Title** | Ensure 'Secure transfer required' is enabled |
| **Level** | 1 |
| **SecAI Script** | 06_data_protection.ps1 |
| **Evidence File** | `{sub-id}_storage.json` |
| **Evidence Property** | `properties.supportsHttpsTrafficOnly` |
| **Pass Criteria** | `supportsHttpsTrafficOnly == true` for all storage accounts |
| **Validation** | AUTOMATED - Parse JSON and check property |
| **Gap Risk** | HIGH - Data transmitted over unencrypted HTTP |
| **Remediation** | Enable secure transfer on all storage accounts |

**Sample Evidence Check (PowerShell):**
```powershell
# Check secure transfer required on storage accounts
$storageAccounts = Get-Content "{sub-id}_storage.json" | ConvertFrom-Json
$nonCompliant = $storageAccounts | Where-Object { 
    $_.properties.supportsHttpsTrafficOnly -ne $true 
}
if ($nonCompliant.Count -eq 0) {
    Write-Host "PASS: All storage accounts require secure transfer"
} else {
    Write-Host "FAIL: $($nonCompliant.Count) storage accounts allow insecure transfer"
    $nonCompliant | Select-Object name | Format-Table
}
```

### 3.2 Ensure Default Network Access Rule for Storage Accounts is Set to Deny (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 3.2 |
| **Title** | Ensure default network access rule is 'Deny' |
| **Level** | 1 |
| **SecAI Script** | 06_data_protection.ps1 |
| **Evidence File** | `{sub-id}_storage.json` |
| **Evidence Property** | `properties.networkAcls.defaultAction` |
| **Pass Criteria** | `defaultAction == "Deny"` |
| **Validation** | AUTOMATED |
| **Gap Risk** | HIGH - Storage accessible from any network |
| **Remediation** | Set default network access to Deny, add specific firewall rules |

### 3.3-3.15 Additional Storage Controls

*[Note: Continue mapping all Section 3 controls]*

Key controls:
- 3.3-3.8: Storage account encryption, access keys, regeneration
- 3.9-3.12: Storage account authentication and shared access
- 3.13-3.15: Soft delete, logging, private endpoints

---

## Section 4: Database Services (SQL, PostgreSQL, MySQL)

### 4.1 Ensure that 'Auditing' is Enabled for SQL Servers (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 4.1 |
| **Title** | Ensure auditing is enabled for SQL Servers |
| **Level** | 1 |
| **SecAI Script** | 06_data_protection.ps1 |
| **Evidence File** | `{sub-id}_sql_servers.json` |
| **Evidence Property** | Auditing configuration |
| **Pass Criteria** | Auditing enabled on all SQL Servers |
| **Validation** | AUTOMATED |
| **Gap Risk** | HIGH - No audit trail for database access |
| **Remediation** | Enable auditing on SQL Servers |

### 4.2 Ensure that 'Data Encryption' is Enabled for SQL Databases (TDE) (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 4.2 |
| **Title** | Ensure TDE is enabled for SQL databases |
| **Level** | 1 |
| **SecAI Script** | 06_data_protection.ps1 |
| **Evidence File** | `{sub-id}_sql_databases.json` |
| **Evidence Property** | TDE status |
| **Pass Criteria** | TDE enabled on all databases |
| **Validation** | AUTOMATED |
| **Gap Risk** | CRITICAL - Database data not encrypted at rest |
| **Remediation** | Enable TDE on all SQL databases |

### 4.3-4.10 Additional Database Controls

*[Note: Continue mapping all Section 4 controls]*

Key controls:
- 4.3-4.6: Azure AD authentication, firewall rules
- 4.7-4.10: Advanced Threat Protection, vulnerability assessments

---

## Section 5: Logging and Monitoring

### 5.1.1 Ensure that Activity Log Retention is Set to At Least 365 Days (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 5.1.1 |
| **Title** | Ensure Activity Log retention ≥ 365 days |
| **Level** | 1 |
| **SecAI Script** | 07_logging_threat_detection.ps1 |
| **Evidence File** | `{sub-id}_activity_log.json` or diagnostic settings |
| **Evidence Property** | Retention days |
| **Pass Criteria** | Retention >= 365 days |
| **Validation** | AUTOMATED |
| **Gap Risk** | MEDIUM - Insufficient audit trail for investigations |
| **Remediation** | Configure diagnostic settings to export to Log Analytics with 365+ day retention |

### 5.1.2 Ensure Diagnostic Setting Captures All Activity Categories (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 5.1.2 |
| **Title** | Ensure diagnostic setting captures appropriate categories |
| **Level** | 1 |
| **SecAI Script** | 07_logging_threat_detection.ps1 |
| **Evidence File** | `{sub-id}_diagnostic_settings.json` |
| **Evidence Property** | Log categories enabled |
| **Pass Criteria** | All relevant categories enabled |
| **Validation** | AUTOMATED |
| **Gap Risk** | MEDIUM - Incomplete logging |
| **Remediation** | Enable all log categories in diagnostic settings |

### 5.2.1-5.2.9 Additional Logging Controls

*[Note: Continue mapping all Section 5 controls]*

Key controls:
- 5.2.1-5.2.5: Storage account logging
- 5.2.6-5.2.9: Key Vault logging and auditing

---

## Section 6: Networking

### 6.1 Ensure that Network Security Groups Flow Logs are Enabled (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 6.1 |
| **Title** | Ensure NSG flow logs are enabled |
| **Level** | 1 |
| **SecAI Script** | 05_network_security.ps1 |
| **Evidence File** | `{sub-id}_nsgs.json` + Network Watcher config |
| **Evidence Property** | NSG flow log configuration |
| **Pass Criteria** | Flow logs enabled for critical NSGs |
| **Validation** | Semi-automated - requires Network Watcher data |
| **Gap Risk** | MEDIUM - Limited network visibility |
| **Remediation** | Enable NSG flow logs via Network Watcher |

### 6.2 Ensure that Network Security Groups Use the Principle of Least Privilege (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 6.2 |
| **Title** | Ensure NSGs follow least privilege |
| **Level** | 1 |
| **SecAI Script** | 05_network_security.ps1 |
| **Evidence File** | `{sub-id}_nsgs.json` |
| **Evidence Property** | Security rules |
| **Pass Criteria** | No rules allowing 0.0.0.0/0 or Any/Any |
| **Validation** | AUTOMATED - check for overly permissive rules |
| **Gap Risk** | HIGH - Excessive network access |
| **Remediation** | Review and tighten NSG rules |

**Sample Evidence Check (PowerShell):**
```powershell
# Check for overly permissive NSG rules
$nsgs = Get-Content "{sub-id}_nsgs.json" | ConvertFrom-Json
$permissiveRules = @()
foreach ($nsg in $nsgs) {
    foreach ($rule in $nsg.properties.securityRules) {
        if ($rule.properties.sourceAddressPrefix -eq "*" -or 
            $rule.properties.sourceAddressPrefix -eq "0.0.0.0/0" -or
            $rule.properties.destinationAddressPrefix -eq "*") {
            $permissiveRules += [PSCustomObject]@{
                NSG = $nsg.name
                Rule = $rule.name
                Direction = $rule.properties.direction
                Access = $rule.properties.access
            }
        }
    }
}
if ($permissiveRules.Count -eq 0) {
    Write-Host "PASS: No overly permissive NSG rules found"
} else {
    Write-Host "FAIL: Found $($permissiveRules.Count) overly permissive rules"
    $permissiveRules | Format-Table
}
```

### 6.3-6.10 Additional Network Controls

*[Note: Continue mapping all Section 6 controls]*

Key controls:
- 6.3-6.5: Network Watcher, Azure Firewall
- 6.6-6.10: VNet peering, DDoS protection, private endpoints

---

## Section 7: Virtual Machines

### 7.1 Ensure Virtual Machines are Utilizing Managed Disks (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 7.1 |
| **Title** | Ensure VMs use managed disks |
| **Level** | 1 |
| **SecAI Script** | 02_inventory.ps1 |
| **Evidence File** | `{sub-id}_resources.json` |
| **Evidence Property** | VM disk configuration |
| **Pass Criteria** | All VMs use managed disks |
| **Validation** | AUTOMATED |
| **Gap Risk** | MEDIUM - Unmanaged disks lack enterprise features |
| **Remediation** | Migrate VMs to managed disks |

### 7.2-7.10 Additional VM Controls

*[Note: Continue mapping all Section 7 controls]*

Key controls:
- 7.2-7.4: VM backup, extensions
- 7.5-7.7: OS and data disk encryption
- 7.8-7.10: VM endpoint protection, updates

---

## Section 8: Key Vault

### 8.1 Ensure that Key Vault is Recoverable (Soft Delete Enabled) (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 8.1 |
| **Title** | Ensure Key Vault soft delete is enabled |
| **Level** | 1 |
| **SecAI Script** | 06_data_protection.ps1 |
| **Evidence File** | `{sub-id}_keyvaults.json` |
| **Evidence Property** | `properties.enableSoftDelete` |
| **Pass Criteria** | `enableSoftDelete == true` for all Key Vaults |
| **Validation** | AUTOMATED |
| **Gap Risk** | HIGH - Accidental secret deletion is permanent |
| **Remediation** | Enable soft delete on all Key Vaults |

### 8.2 Ensure that Key Vault Has Purge Protection Enabled (Level 1)

| Attribute | Value |
|-----------|-------|
| **CIS Control** | 8.2 |
| **Title** | Ensure Key Vault purge protection is enabled |
| **Level** | 1 |
| **SecAI Script** | 06_data_protection.ps1 |
| **Evidence File** | `{sub-id}_keyvaults.json` |
| **Evidence Property** | `properties.enablePurgeProtection` |
| **Pass Criteria** | `enablePurgeProtection == true` |
| **Validation** | AUTOMATED |
| **Gap Risk** | HIGH - Malicious or accidental purge |
| **Remediation** | Enable purge protection on all Key Vaults |

### 8.3-8.7 Additional Key Vault Controls

*[Note: Continue mapping remaining Key Vault controls]*

Key controls:
- 8.3-8.5: Key Vault logging, RBAC, firewall
- 8.6-8.7: Key rotation, expiration

---

## Section 9: AppService

### 9.1-9.10 App Service Controls

*[Note: Map all App Service controls]*

Key controls:
- 9.1-9.3: HTTPS only, client certificates
- 9.4-9.6: Authentication, managed identity
- 9.7-9.10: Monitoring, logging, backups

---

## Section 10: Other Security Considerations

### 10.1-10.5 Miscellaneous Controls

*[Note: Map remaining controls]*

---

## Implementation Guide

### Phase 1: Setup (1 week)
1. **Obtain CIS Benchmark:** Download official document
2. **Complete Mapping:** Fill in all ~78 controls
3. **Validate Evidence:** Confirm scripts collect required data
4. **Document Gaps:** Identify controls requiring manual checks

### Phase 2: Automation (2 weeks)
1. **Create Validation Scripts:** PowerShell scripts to check each control
2. **Build Scorecard:** Excel/CSV with automated status
3. **Generate Reports:** Compliance summary and gap analysis
4. **Test:** Run against real environment

### Phase 3: Integration (1 week)
1. **Link to Configuration Assessment:** Map to Dimension 1 outputs
2. **Create Dashboard:** Visual compliance tracking
3. **Document:** Update framework documentation
4. **Publish:** Move to `implementation/4-Templates/`

---

## Automation Example

```powershell
# Sample automation script structure
function Test-CISControl {
    param(
        [string]$ControlID,
        [string]$SubscriptionID,
        [string]$DataPath
    )
    
    switch ($ControlID) {
        "3.1" {
            # Check storage secure transfer
            $storage = Get-Content "$DataPath\$SubscriptionID_storage.json" | ConvertFrom-Json
            $nonCompliant = $storage | Where-Object { 
                $_.properties.supportsHttpsTrafficOnly -ne $true 
            }
            return @{
                Control = "3.1"
                Status = if ($nonCompliant.Count -eq 0) { "PASS" } else { "FAIL" }
                Details = "$($nonCompliant.Count) non-compliant storage accounts"
            }
        }
        "8.1" {
            # Check Key Vault soft delete
            $kvs = Get-Content "$DataPath\$SubscriptionID_keyvaults.json" | ConvertFrom-Json
            $nonCompliant = $kvs | Where-Object { 
                $_.properties.enableSoftDelete -ne $true 
            }
            return @{
                Control = "8.1"
                Status = if ($nonCompliant.Count -eq 0) { "PASS" } else { "FAIL" }
                Details = "$($nonCompliant.Count) Key Vaults without soft delete"
            }
        }
        default {
            return @{
                Control = $ControlID
                Status = "NOT IMPLEMENTED"
                Details = "Validation script not yet created"
            }
        }
    }
}

# Run all controls
$results = @()
$controls = @("3.1", "3.2", "8.1", "8.2") # Add all controls
foreach ($control in $controls) {
    $result = Test-CISControl -ControlID $control -SubscriptionID $subId -DataPath $dataPath
    $results += $result
}

# Generate compliance report
$passCount = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
$compliancePercentage = [math]::Round(($passCount / $results.Count) * 100, 2)

Write-Host "CIS Azure Foundations Benchmark Compliance: $compliancePercentage%"
Write-Host "PASS: $passCount | FAIL: $failCount | TOTAL: $($results.Count)"
```

---

## Next Steps

1. **Validate Against Official Benchmark:**
   - Download CIS Microsoft Azure Foundations Benchmark v2.0
   - Verify all control numbers and descriptions
   - Update this matrix with accurate control details

2. **Complete All Control Mappings:**
   - All 10 sections
   - Approximately 78 controls total
   - Both Level 1 and Level 2

3. **Build Automation:**
   - Create validation script for each control
   - Test against collected data
   - Generate compliance scorecard

4. **Create Excel Version:**
   - More user-friendly for stakeholders
   - Sortable, filterable
   - Dashboard views

---

**Document Status:** Draft - Requires CIS Benchmark Validation  
**Priority:** HIGH - Critical for Dimension 3  
**Owner:** Security Architecture Team  
**Next Action:** Obtain official CIS Benchmark document and complete mapping


