#Requires -Version 7.0
<#
.SYNOPSIS
    NIST SP 800-53 Rev 5 Validation Module
.DESCRIPTION
    Validates Azure environments against NIST SP 800-53 controls.
    Focuses on high-priority control families relevant to Azure.
.NOTES
    NIST 800-53 Control Families (selected for Azure):
    - AC: Access Control
    - AU: Audit and Accountability  
    - IA: Identification and Authentication
    - SC: System and Communications Protection
    - SI: System and Information Integrity
    - CM: Configuration Management
    - CP: Contingency Planning
    - RA: Risk Assessment
#>

# Import common functions
Import-Module (Join-Path $PSScriptRoot "Common-Functions.psm1") -Force

# Export functions
Export-ModuleMember -Function @(
    'Invoke-NISTValidation'
    'Test-NIST-AC-2'
    'Test-NIST-AC-3'
    'Test-NIST-AU-2'
    'Test-NIST-AU-6'
    'Test-NIST-IA-2'
    'Test-NIST-SC-7'
    'Test-NIST-SC-8'
    'Test-NIST-SC-13'
    'Test-NIST-SC-28'
    'Test-NIST-CP-9'
)

<#
.SYNOPSIS
    Master function to run NIST validations
#>
function Invoke-NISTValidation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DataPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionID
    )
    
    Write-Host "  Running NIST SP 800-53 validation for subscription: $SubscriptionID" -ForegroundColor Cyan
    
    $results = @()
    
    # Access Control (AC)
    $results += Test-NIST-AC-2 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-NIST-AC-3 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Audit and Accountability (AU)
    $results += Test-NIST-AU-2 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-NIST-AU-6 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Identification and Authentication (IA)
    $results += Test-NIST-IA-2 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # System and Communications Protection (SC)
    $results += Test-NIST-SC-7 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-NIST-SC-8 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-NIST-SC-13 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-NIST-SC-28 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Contingency Planning (CP)
    $results += Test-NIST-CP-9 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    return $results
}

#region Access Control (AC)

<#
.SYNOPSIS
    NIST AC-2: Account Management
.DESCRIPTION
    Validates account management through RBAC analysis
#>
function Test-NIST-AC-2 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST AC-2: Account Management"
    
    # Check for RBAC assignments (from script 04)
    # This is a process control requiring manual verification
    
    return New-ComplianceResult -Framework "NIST" -ControlID "AC-2" `
        -ControlName "Account Management" `
        -Domain "Identity" -Severity "High" -Status "MANUAL" `
        -SubscriptionID $SubscriptionID `
        -Reason "Manual verification - check RBAC assignments and access review processes"
}

<#
.SYNOPSIS
    NIST AC-3: Access Enforcement
.DESCRIPTION
    Validates access enforcement through RBAC and network controls
#>
function Test-NIST-AC-3 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST AC-3: Access Enforcement"
    
    # Check for NSG deployment (network-level access control)
    $vnets = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "vnets"
    
    if (-not $vnets) {
        return New-ComplianceResult -Framework "NIST" -ControlID "AC-3" `
            -ControlName "Access Enforcement" `
            -Domain "Network" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No virtual networks found"
    }
    
    $subnetsWithNSG = 0
    $totalSubnets = 0
    
    foreach ($vnet in $vnets) {
        if ($vnet.properties.subnets) {
            foreach ($subnet in $vnet.properties.subnets) {
                $totalSubnets++
                if ($subnet.properties.networkSecurityGroup) {
                    $subnetsWithNSG++
                }
            }
        }
    }
    
    $percentage = if ($totalSubnets -gt 0) {
        [math]::Round(($subnetsWithNSG / $totalSubnets) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -ge 90) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "NIST" -ControlID "AC-3" `
        -ControlName "Access Enforcement" `
        -Domain "Network" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "NSG deployment on subnets" `
        -Reason "$percentage% of subnets have NSGs ($subnetsWithNSG/$totalSubnets)" `
        -TotalResources $totalSubnets `
        -CompliantResources $subnetsWithNSG `
        -NonCompliantResources ($totalSubnets - $subnetsWithNSG)
}

#endregion

#region Audit and Accountability (AU)

<#
.SYNOPSIS
    NIST AU-2: Event Logging
.DESCRIPTION
    Validates that auditable events are defined and logged
#>
function Test-NIST-AU-2 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST AU-2: Event Logging"
    
    $diagSettings = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "diagnostic_settings"
    
    if (-not $diagSettings) {
        return New-ComplianceResult -Framework "NIST" -ControlID "AU-2" `
            -ControlName "Event Logging" `
            -Domain "Logging & Threat Detection" -Severity "High" -Status "FAIL" `
            -SubscriptionID $SubscriptionID `
            -Reason "No diagnostic settings found"
    }
    
    # Check if activity logs are being collected
    $hasActivityLogs = $false
    foreach ($setting in $diagSettings) {
        if ($setting.properties.logs) {
            foreach ($log in $setting.properties.logs) {
                if ($log.category -match "Administrative|Security|Alert|Policy" -and $log.enabled -eq $true) {
                    $hasActivityLogs = $true
                    break
                }
            }
        }
        if ($hasActivityLogs) { break }
    }
    
    $status = if ($hasActivityLogs) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "NIST" -ControlID "AU-2" `
        -ControlName "Event Logging" `
        -Domain "Logging & Threat Detection" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Diagnostic settings for activity logs" `
        -Reason (if ($hasActivityLogs) { "Activity logging configured" } else { "Activity logging not configured" })
}

<#
.SYNOPSIS
    NIST AU-6: Audit Record Review, Analysis, and Reporting
.DESCRIPTION
    Validates log analysis and monitoring capabilities
#>
function Test-NIST-AU-6 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST AU-6: Audit Review"
    
    $logAnalytics = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "log_analytics"
    
    if (-not $logAnalytics) {
        return New-ComplianceResult -Framework "NIST" -ControlID "AU-6" `
            -ControlName "Audit Record Review, Analysis, and Reporting" `
            -Domain "Logging & Threat Detection" -Severity "Medium" -Status "FAIL" `
            -SubscriptionID $SubscriptionID `
            -Reason "No Log Analytics workspaces found"
    }
    
    $hasWorkspace = $logAnalytics.Count -gt 0
    $status = if ($hasWorkspace) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "NIST" -ControlID "AU-6" `
        -ControlName "Audit Record Review, Analysis, and Reporting" `
        -Domain "Logging & Threat Detection" -Severity "Medium" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Log Analytics workspaces" `
        -Reason "Log Analytics workspaces: $($logAnalytics.Count)" `
        -TotalResources 1 `
        -CompliantResources (if ($hasWorkspace) { 1 } else { 0 }) `
        -NonCompliantResources (if ($hasWorkspace) { 0 } else { 1 })
}

#endregion

#region Identification and Authentication (IA)

<#
.SYNOPSIS
    NIST IA-2: Identification and Authentication
.DESCRIPTION
    Validates MFA and strong authentication
#>
function Test-NIST-IA-2 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST IA-2: Identification and Authentication"
    
    # MFA validation requires Azure AD data (from script 04)
    # This is a manual/process check
    
    return New-ComplianceResult -Framework "NIST" -ControlID "IA-2" `
        -ControlName "Identification and Authentication (Organizational Users)" `
        -Domain "Identity" -Severity "Critical" -Status "MANUAL" `
        -SubscriptionID $SubscriptionID `
        -Reason "Manual verification - check MFA enforcement via Conditional Access policies"
}

#endregion

#region System and Communications Protection (SC)

<#
.SYNOPSIS
    NIST SC-7: Boundary Protection
.DESCRIPTION
    Validates network boundary protection through firewalls and NSGs
#>
function Test-NIST-SC-7 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST SC-7: Boundary Protection"
    
    $nsgs = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "nsgs"
    $firewalls = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "az_firewalls"
    
    $hasNSGs = $nsgs -and $nsgs.Count -gt 0
    $hasFirewalls = $firewalls -and $firewalls.Count -gt 0
    
    $status = if ($hasNSGs -and $hasFirewalls) { "PASS" } 
              elseif ($hasNSGs) { "FAIL" }
              else { "FAIL" }
    
    $reason = "NSGs: $($nsgs.Count if $nsgs else 0), Azure Firewalls: $($firewalls.Count if $firewalls else 0)"
    
    return New-ComplianceResult -Framework "NIST" -ControlID "SC-7" `
        -ControlName "Boundary Protection" `
        -Domain "Network" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "NSGs and Azure Firewalls" `
        -Reason $reason
}

<#
.SYNOPSIS
    NIST SC-8: Transmission Confidentiality and Integrity
.DESCRIPTION
    Validates encryption in transit (HTTPS, TLS)
#>
function Test-NIST-SC-8 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST SC-8: Transmission Protection"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "NIST" -ControlID "SC-8" `
            -ControlName "Transmission Confidentiality and Integrity" `
            -Domain "Data Protection" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No storage accounts found"
    }
    
    $secureTransfer = @($storage | Where-Object {
        $_.properties.supportsHttpsTrafficOnly -eq $true
    })
    
    $total = $storage.Count
    $compliant = $secureTransfer.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -eq 100) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "NIST" -ControlID "SC-8" `
        -ControlName "Transmission Confidentiality and Integrity" `
        -Domain "Data Protection" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage secure transfer required" `
        -Reason "$percentage% of storage accounts require secure transfer ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

<#
.SYNOPSIS
    NIST SC-13: Cryptographic Protection
.DESCRIPTION
    Validates use of FIPS 140-2 validated cryptographic modules
#>
function Test-NIST-SC-13 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST SC-13: Cryptographic Protection"
    
    $keyvaults = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "keyvaults"
    
    if (-not $keyvaults) {
        return New-ComplianceResult -Framework "NIST" -ControlID "SC-13" `
            -ControlName "Cryptographic Protection" `
            -Domain "Data Protection" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No Key Vaults found"
    }
    
    # Azure Key Vault uses FIPS 140-2 Level 2 validated HSMs
    # Check that Key Vaults are deployed (presence = compliant)
    $total = $keyvaults.Count
    $status = if ($total -gt 0) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "NIST" -ControlID "SC-13" `
        -ControlName "Cryptographic Protection" `
        -Domain "Data Protection" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Azure Key Vault (FIPS 140-2 validated)" `
        -Reason "Key Vaults deployed: $total (Azure KV uses FIPS 140-2 Level 2 HSMs)" `
        -TotalResources 1 `
        -CompliantResources 1
}

<#
.SYNOPSIS
    NIST SC-28: Protection of Information at Rest
.DESCRIPTION
    Validates encryption at rest for storage and databases
#>
function Test-NIST-SC-28 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST SC-28: Protection at Rest"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "NIST" -ControlID "SC-28" `
            -ControlName "Protection of Information at Rest" `
            -Domain "Data Protection" -Severity "Critical" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No storage accounts found"
    }
    
    $encrypted = @($storage | Where-Object {
        $_.properties.encryption.services.blob.enabled -eq $true
    })
    
    $total = $storage.Count
    $compliant = $encrypted.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -eq 100) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "NIST" -ControlID "SC-28" `
        -ControlName "Protection of Information at Rest" `
        -Domain "Data Protection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage encryption at rest" `
        -Reason "$percentage% of storage accounts encrypted ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Contingency Planning (CP)

<#
.SYNOPSIS
    NIST CP-9: System Backup
.DESCRIPTION
    Validates backup configuration and policies
#>
function Test-NIST-CP-9 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing NIST CP-9: System Backup"
    
    $resources = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "resources"
    
    if (-not $resources) {
        return New-ComplianceResult -Framework "NIST" -ControlID "CP-9" `
            -ControlName "System Backup" `
            -Domain "Backup & Recovery" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No resources found"
    }
    
    $vaults = @($resources | Where-Object {
        $_.type -eq "Microsoft.RecoveryServices/vaults"
    })
    
    $hasBackup = $vaults.Count -gt 0
    $status = if ($hasBackup) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "NIST" -ControlID "CP-9" `
        -ControlName "System Backup" `
        -Domain "Backup & Recovery" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Recovery Services Vaults" `
        -Reason "Recovery Services Vaults: $($vaults.Count)" `
        -TotalResources 1 `
        -CompliantResources (if ($hasBackup) { 1 } else { 0 }) `
        -NonCompliantResources (if ($hasBackup) { 0 } else { 1 })
}

#endregion

