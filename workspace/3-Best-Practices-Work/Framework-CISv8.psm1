#Requires -Version 7.0
<#
.SYNOPSIS
    CIS Controls v8 Validation Module
.DESCRIPTION
    Validates Azure environments against CIS Critical Security Controls v8.
    Focuses on Implementation Groups 1 & 2 (foundational controls).
.NOTES
    CIS Controls v8 Structure:
    - 18 Control Groups
    - 153 Safeguards total
    - Implementation Groups: IG1 (56), IG2 (74), IG3 (23)
    
    Key Control Groups:
    1. Inventory and Control of Enterprise Assets
    2. Inventory and Control of Software Assets
    3. Data Protection
    6. Access Control Management
    8. Audit Log Management
    11. Data Recovery
    12. Network Infrastructure Management
    13. Network Monitoring and Defense
#>

# Import common functions
Import-Module (Join-Path $PSScriptRoot "Common-Functions.psm1") -Force

# Export functions
Export-ModuleMember -Function @(
    'Invoke-CISv8Validation'
    'Test-CISv8-01-01'
    'Test-CISv8-03-11'
    'Test-CISv8-06-01'
    'Test-CISv8-08-02'
    'Test-CISv8-11-01'
    'Test-CISv8-12-02'
)

<#
.SYNOPSIS
    Master function to run CIS Controls v8 validations
#>
function Invoke-CISv8Validation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DataPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionID
    )
    
    Write-Host "  Running CIS Controls v8 validation for subscription: $SubscriptionID" -ForegroundColor Cyan
    
    $results = @()
    
    # Control 1: Asset Inventory
    $results += Test-CISv8-01-01 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Control 3: Data Protection
    $results += Test-CISv8-03-11 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Control 6: Access Control
    $results += Test-CISv8-06-01 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Control 8: Audit Logs
    $results += Test-CISv8-08-02 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Control 11: Data Recovery
    $results += Test-CISv8-11-01 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Control 12: Network Infrastructure
    $results += Test-CISv8-12-02 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    return $results
}

#region Control 1: Asset Inventory

<#
.SYNOPSIS
    CIS v8 1.1: Establish and Maintain Asset Inventory
.DESCRIPTION
    Validates asset inventory is maintained
#>
function Test-CISv8-01-01 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CIS v8 1.1: Asset Inventory"
    
    $resources = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "resources"
    
    if (-not $resources) {
        return New-ComplianceResult -Framework "CIS-v8" -ControlID "1.1" `
            -ControlName "Establish and Maintain Detailed Enterprise Asset Inventory" `
            -Domain "Asset Management" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No resources found"
    }
    
    # Check for asset tagging (inventory metadata)
    $taggedResources = @($resources | Where-Object {
        $_.tags -and $_.tags.Count -gt 0
    })
    
    $total = $resources.Count
    $compliant = $taggedResources.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -ge 80) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "CIS-v8" -ControlID "1.1" `
        -ControlName "Establish and Maintain Detailed Enterprise Asset Inventory" `
        -Domain "Asset Management" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Resource inventory with tags" `
        -Reason "$percentage% of assets have tags ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Control 3: Data Protection

<#
.SYNOPSIS
    CIS v8 3.11: Encrypt Sensitive Data at Rest
.DESCRIPTION
    Validates encryption of sensitive data
#>
function Test-CISv8-03-11 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CIS v8 3.11: Encrypt Data at Rest"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "CIS-v8" -ControlID "3.11" `
            -ControlName "Encrypt Sensitive Data at Rest" `
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
    
    return New-ComplianceResult -Framework "CIS-v8" -ControlID "3.11" `
        -ControlName "Encrypt Sensitive Data at Rest" `
        -Domain "Data Protection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage encryption" `
        -Reason "$percentage% encrypted ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Control 6: Access Control

<#
.SYNOPSIS
    CIS v8 6.1: Establish an Access Granting Process
.DESCRIPTION
    Validates access control implementation
#>
function Test-CISv8-06-01 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CIS v8 6.1: Access Granting Process"
    
    # This is a process control
    return New-ComplianceResult -Framework "CIS-v8" -ControlID "6.1" `
        -ControlName "Establish an Access Granting Process" `
        -Domain "Identity" -Severity "High" -Status "MANUAL" `
        -SubscriptionID $SubscriptionID `
        -Reason "Process validation - check access request and approval procedures"
}

#endregion

#region Control 8: Audit Logs

<#
.SYNOPSIS
    CIS v8 8.2: Collect Audit Logs
.DESCRIPTION
    Validates audit log collection
#>
function Test-CISv8-08-02 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CIS v8 8.2: Collect Audit Logs"
    
    $diagSettings = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "diagnostic_settings"
    $logAnalytics = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "log_analytics"
    
    $hasLogging = $diagSettings -and $diagSettings.Count -gt 0
    $hasWorkspace = $logAnalytics -and $logAnalytics.Count -gt 0
    
    $status = if ($hasLogging -and $hasWorkspace) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "CIS-v8" -ControlID "8.2" `
        -ControlName "Collect Audit Logs" `
        -Domain "Logging & Threat Detection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Diagnostic settings, Log Analytics" `
        -Reason "Logging configured: $(if ($hasLogging) { 'Yes' } else { 'No' }), Workspace: $(if ($hasWorkspace) { 'Yes' } else { 'No' })"
}

#endregion

#region Control 11: Data Recovery

<#
.SYNOPSIS
    CIS v8 11.1: Establish and Maintain a Data Recovery Process
.DESCRIPTION
    Validates backup configuration
#>
function Test-CISv8-11-01 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CIS v8 11.1: Data Recovery"
    
    $resources = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "resources"
    
    if (-not $resources) {
        return New-ComplianceResult -Framework "CIS-v8" -ControlID "11.1" `
            -ControlName "Establish and Maintain a Data Recovery Process" `
            -Domain "Backup & Recovery" -Severity "Critical" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No resources found"
    }
    
    $vaults = @($resources | Where-Object {
        $_.type -eq "Microsoft.RecoveryServices/vaults"
    })
    
    $hasBackup = $vaults.Count -gt 0
    $status = if ($hasBackup) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "CIS-v8" -ControlID "11.1" `
        -ControlName "Establish and Maintain a Data Recovery Process" `
        -Domain "Backup & Recovery" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Recovery Services Vaults" `
        -Reason "Backup infrastructure: $(if ($hasBackup) { $vaults.Count.ToString() + ' vault(s)' } else { 'Not configured' })" `
        -TotalResources 1 `
        -CompliantResources (if ($hasBackup) { 1 } else { 0 }) `
        -NonCompliantResources (if ($hasBackup) { 0 } else { 1 })
}

#endregion

#region Control 12: Network Infrastructure

<#
.SYNOPSIS
    CIS v8 12.2: Establish and Maintain Secure Network Architecture
.DESCRIPTION
    Validates network segmentation and security architecture
#>
function Test-CISv8-12-02 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing CIS v8 12.2: Secure Network Architecture"
    
    $vnets = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "vnets"
    $nsgs = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "nsgs"
    $firewalls = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "az_firewalls"
    
    if (-not $vnets) {
        return New-ComplianceResult -Framework "CIS-v8" -ControlID "12.2" `
            -ControlName "Establish and Maintain Secure Network Architecture" `
            -Domain "Network" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No virtual networks found"
    }
    
    # Check for network segmentation (NSGs) and centralized security (Firewall)
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
    
    $nsgPercentage = if ($totalSubnets -gt 0) {
        [math]::Round(($subnetsWithNSG / $totalSubnets) * 100, 2)
    } else { 0 }
    
    $hasFirewall = $firewalls -and $firewalls.Count -gt 0
    
    $status = if ($nsgPercentage -ge 80 -and $hasFirewall) { "PASS" }
              elseif ($nsgPercentage -ge 80) { "FAIL" }
              else { "FAIL" }
    
    $reason = "Network segmentation: $nsgPercentage% ($subnetsWithNSG/$totalSubnets subnets with NSGs). "
    $reason += "Centralized security: $(if ($hasFirewall) { $firewalls.Count.ToString() + ' firewall(s)' } else { 'No Azure Firewall' })"
    
    return New-ComplianceResult -Framework "CIS-v8" -ControlID "12.2" `
        -ControlName "Establish and Maintain Secure Network Architecture" `
        -Domain "Network" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "VNets, NSGs, Azure Firewalls" `
        -Reason $reason `
        -TotalResources $totalSubnets `
        -CompliantResources $subnetsWithNSG `
        -NonCompliantResources ($totalSubnets - $subnetsWithNSG)
}

#endregion

