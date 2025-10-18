#Requires -Version 7.0
<#
.SYNOPSIS
    CSA Cloud Controls Matrix (CCM) v4 Validation Module
.DESCRIPTION
    Validates Azure environments against Cloud Security Alliance Cloud Controls Matrix.
    Focuses on cloud-specific security controls.
.NOTES
    CCM Domains:
    - IAM: Identity & Access Management
    - IVS: Infrastructure & Virtualization Security
    - EKM: Encryption & Key Management
    - LOG: Logging & Monitoring
    - SEF: Security Incident Management
    - DSP: Data Security & Privacy
    - BCR: Business Continuity & DR
    - And others...
#>

# Import common functions
Import-Module (Join-Path $PSScriptRoot "Common-Functions.psm1") -Force

# Export functions
Export-ModuleMember -Function @(
    'Invoke-CCMValidation'
    'Test-CCM-IAM-01'
    'Test-CCM-IVS-02'
    'Test-CCM-EKM-01'
    'Test-CCM-EKM-02'
    'Test-CCM-LOG-01'
    'Test-CCM-BCR-01'
)

<#
.SYNOPSIS
    Master function to run CCM validations
#>
function Invoke-CCMValidation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DataPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionID
    )
    
    Write-Host "  Running CSA CCM validation for subscription: $SubscriptionID" -ForegroundColor Cyan
    
    $results = @()
    
    # Identity & Access Management (IAM)
    $results += Test-CCM-IAM-01 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Infrastructure & Virtualization Security (IVS)
    $results += Test-CCM-IVS-02 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Encryption & Key Management (EKM)
    $results += Test-CCM-EKM-01 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-CCM-EKM-02 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Logging & Monitoring (LOG)
    $results += Test-CCM-LOG-01 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Business Continuity & DR (BCR)
    $results += Test-CCM-BCR-01 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    return $results
}

#region Identity & Access Management (IAM)

<#
.SYNOPSIS
    CCM IAM-01: Access Control
.DESCRIPTION
    Validates access control implementation via RBAC
#>
function Test-CCM-IAM-01 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CCM IAM-01: Access Control"
    
    # RBAC validation - requires data from script 04
    # This is a manual/process check
    
    return New-ComplianceResult -Framework "CCM" -ControlID "IAM-01" `
        -ControlName "Access Control" `
        -Domain "Identity" -Severity "High" -Status "MANUAL" `
        -SubscriptionID $SubscriptionID `
        -Reason "Manual verification - check RBAC policies and least privilege implementation"
}

#endregion

#region Infrastructure & Virtualization Security (IVS)

<#
.SYNOPSIS
    CCM IVS-02: Network Security
.DESCRIPTION
    Validates network segmentation and controls
#>
function Test-CCM-IVS-02 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CCM IVS-02: Network Security"
    
    $nsgs = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "nsgs"
    $vnets = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "vnets"
    
    if (-not $vnets) {
        return New-ComplianceResult -Framework "CCM" -ControlID "IVS-02" `
            -ControlName "Network Security" `
            -Domain "Network" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No virtual networks found"
    }
    
    # Check subnet NSG coverage
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
    
    return New-ComplianceResult -Framework "CCM" -ControlID "IVS-02" `
        -ControlName "Network Security" `
        -Domain "Network" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "NSG deployment on subnets" `
        -Reason "$percentage% of subnets protected by NSGs ($subnetsWithNSG/$totalSubnets)" `
        -TotalResources $totalSubnets `
        -CompliantResources $subnetsWithNSG `
        -NonCompliantResources ($totalSubnets - $subnetsWithNSG)
}

#endregion

#region Encryption & Key Management (EKM)

<#
.SYNOPSIS
    CCM EKM-01: Encryption & Key Management
.DESCRIPTION
    Validates encryption implementation and key management
#>
function Test-CCM-EKM-01 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CCM EKM-01: Encryption & Key Management"
    
    $keyvaults = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "keyvaults"
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    # Check Key Vault deployment
    $hasKeyVault = $keyvaults -and $keyvaults.Count -gt 0
    
    # Check storage encryption
    $encryptedStorage = if ($storage) {
        @($storage | Where-Object {
            $_.properties.encryption.services.blob.enabled -eq $true
        }).Count
    } else { 0 }
    
    $storageTotal = if ($storage) { $storage.Count } else { 0 }
    $storagePercentage = if ($storageTotal -gt 0) {
        [math]::Round(($encryptedStorage / $storageTotal) * 100, 2)
    } else { 100 }
    
    $status = if ($hasKeyVault -and $storagePercentage -eq 100) { "PASS" } else { "FAIL" }
    
    $reason = "Key Vaults: $(if ($keyvaults) { $keyvaults.Count } else { 0 }). "
    $reason += "Storage encryption: $storagePercentage%"
    
    return New-ComplianceResult -Framework "CCM" -ControlID "EKM-01" `
        -ControlName "Encryption & Key Management" `
        -Domain "Data Protection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Key Vaults and storage encryption" `
        -Reason $reason
}

<#
.SYNOPSIS
    CCM EKM-02: Encryption in Transit
.DESCRIPTION
    Validates HTTPS/TLS enforcement
#>
function Test-CCM-EKM-02 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CCM EKM-02: Encryption in Transit"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "CCM" -ControlID "EKM-02" `
            -ControlName "Encryption in Transit" `
            -Domain "Data Protection" -Severity "Critical" -Status "SKIP" `
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
    
    return New-ComplianceResult -Framework "CCM" -ControlID "EKM-02" `
        -ControlName "Encryption in Transit" `
        -Domain "Data Protection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage secure transfer" `
        -Reason "$percentage% require HTTPS ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Logging & Monitoring (LOG)

<#
.SYNOPSIS
    CCM LOG-01: Logging and Monitoring
.DESCRIPTION
    Validates comprehensive logging implementation
#>
function Test-CCM-LOG-01 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CCM LOG-01: Logging"
    
    $diagSettings = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "diagnostic_settings"
    $logAnalytics = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "log_analytics"
    
    $hasLogging = $diagSettings -and $diagSettings.Count -gt 0
    $hasWorkspace = $logAnalytics -and $logAnalytics.Count -gt 0
    
    # Check for centralized logging
    $hasCentralized = $hasLogging -and $hasWorkspace
    
    $status = if ($hasCentralized) { "PASS" } else { "FAIL" }
    
    $reason = "Diagnostic settings: $(if ($diagSettings) { $diagSettings.Count } else { 0 }). "
    $reason += "Log Analytics workspaces: $(if ($logAnalytics) { $logAnalytics.Count } else { 0 })"
    
    return New-ComplianceResult -Framework "CCM" -ControlID "LOG-01" `
        -ControlName "Logging and Monitoring" `
        -Domain "Logging & Threat Detection" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Diagnostic settings, Log Analytics" `
        -Reason $reason
}

#endregion

#region Business Continuity & DR (BCR)

<#
.SYNOPSIS
    CCM BCR-01: Business Continuity Planning
.DESCRIPTION
    Validates backup and DR configuration
#>
function Test-CCM-BCR-01 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CCM BCR-01: Business Continuity"
    
    $resources = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "resources"
    
    if (-not $resources) {
        return New-ComplianceResult -Framework "CCM" -ControlID "BCR-01" `
            -ControlName "Business Continuity Planning" `
            -Domain "Backup & Recovery" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No resources found"
    }
    
    $vaults = @($resources | Where-Object {
        $_.type -eq "Microsoft.RecoveryServices/vaults"
    })
    
    $hasBackup = $vaults.Count -gt 0
    $status = if ($hasBackup) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "CCM" -ControlID "BCR-01" `
        -ControlName "Business Continuity Planning" `
        -Domain "Backup & Recovery" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Recovery Services Vaults" `
        -Reason "Backup vaults deployed: $($vaults.Count)" `
        -TotalResources 1 `
        -CompliantResources (if ($hasBackup) { 1 } else { 0 }) `
        -NonCompliantResources (if ($hasBackup) { 0 } else { 1 })
}

#endregion

