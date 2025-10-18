#Requires -Version 7.0
<#
.SYNOPSIS
    PCI-DSS v3.2.1 Validation Module
.DESCRIPTION
    Validates Azure environments against Payment Card Industry Data Security Standard.
    Focuses on requirements relevant to Azure infrastructure.
.NOTES
    PCI-DSS Requirements:
    1. Install and maintain firewall configuration
    2. Don't use vendor-supplied defaults
    3. Protect stored cardholder data
    4. Encrypt transmission of cardholder data
    5. Protect systems against malware
    6. Develop and maintain secure systems
    7-12: Additional requirements (access, monitoring, testing, policy)
#>

# Import common functions
Import-Module (Join-Path $PSScriptRoot "Common-Functions.psm1") -Force

# Export functions
Export-ModuleMember -Function @(
    'Invoke-PCIDSSValidation'
    'Test-PCIDSS-1-2-1'
    'Test-PCIDSS-3-4'
    'Test-PCIDSS-4-1'
    'Test-PCIDSS-10-1'
)

<#
.SYNOPSIS
    Master function to run PCI-DSS validations
#>
function Invoke-PCIDSSValidation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DataPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionID
    )
    
    Write-Host "  Running PCI-DSS v3.2.1 validation for subscription: $SubscriptionID" -ForegroundColor Cyan
    
    $results = @()
    
    # Requirement 1: Network Security
    $results += Test-PCIDSS-1-2-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Requirement 3: Protect Stored Data
    $results += Test-PCIDSS-3-4 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Requirement 4: Encrypt Transmission
    $results += Test-PCIDSS-4-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Requirement 10: Logging and Monitoring
    $results += Test-PCIDSS-10-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    return $results
}

#region Requirement 1: Firewall Configuration

<#
.SYNOPSIS
    PCI-DSS 1.2.1: Restrict inbound and outbound traffic
.DESCRIPTION
    Validates NSG and firewall configurations
#>
function Test-PCIDSS-1-2-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing PCI-DSS 1.2.1: Network traffic restrictions"
    
    $nsgs = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "nsgs"
    
    if (-not $nsgs) {
        return New-ComplianceResult -Framework "PCI-DSS" -ControlID "1.2.1" `
            -ControlName "Restrict inbound and outbound traffic to that necessary for CDE" `
            -Domain "Network" -Severity "Critical" -Status "FAIL" `
            -SubscriptionID $SubscriptionID `
            -Reason "No NSGs found - network traffic not restricted"
    }
    
    # Check for overly permissive rules
    $permissiveRules = 0
    $totalRules = 0
    $nonCompliantNSGs = @()
    
    foreach ($nsg in $nsgs) {
        if ($nsg.properties.securityRules) {
            foreach ($rule in $nsg.properties.securityRules) {
                $totalRules++
                if ($rule.properties.sourceAddressPrefix -in @("*", "Internet", "0.0.0.0/0") -and 
                    $rule.properties.access -eq "Allow" -and 
                    $rule.properties.direction -eq "Inbound") {
                    $permissiveRules++
                    if ($nsg.name -notin $nonCompliantNSGs) {
                        $nonCompliantNSGs += $nsg.name
                    }
                }
            }
        }
    }
    
    $status = if ($permissiveRules -eq 0) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "PCI-DSS" -ControlID "1.2.1" `
        -ControlName "Restrict inbound and outbound traffic" `
        -Domain "Network" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "NSG security rules" `
        -Reason "Overly permissive inbound rules: $permissiveRules of $totalRules total rules" `
        -TotalResources $nsgs.Count `
        -CompliantResources ($nsgs.Count - $nonCompliantNSGs.Count) `
        -NonCompliantResources $nonCompliantNSGs.Count `
        -NonCompliantResourceNames ($nonCompliantNSGs -join ", ")
}

#endregion

#region Requirement 3: Protect Stored Data

<#
.SYNOPSIS
    PCI-DSS 3.4: Render PAN unreadable
.DESCRIPTION
    Validates encryption of data at rest
#>
function Test-PCIDSS-3-4 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing PCI-DSS 3.4: Encryption at rest"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "PCI-DSS" -ControlID "3.4" `
            -ControlName "Render PAN unreadable (encryption at rest)" `
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
    
    $nonCompliantNames = @($storage | Where-Object {
        $_.properties.encryption.services.blob.enabled -ne $true
    } | Select-Object -ExpandProperty name) -join ", "
    
    return New-ComplianceResult -Framework "PCI-DSS" -ControlID "3.4" `
        -ControlName "Render PAN unreadable (encryption at rest)" `
        -Domain "Data Protection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage encryption" `
        -Reason "$percentage% of storage accounts encrypted ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant) `
        -NonCompliantResourceNames $nonCompliantNames
}

#endregion

#region Requirement 4: Encrypt Transmission

<#
.SYNOPSIS
    PCI-DSS 4.1: Use strong cryptography for transmission
.DESCRIPTION
    Validates TLS/HTTPS enforcement
#>
function Test-PCIDSS-4-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing PCI-DSS 4.1: Encryption in transit"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "PCI-DSS" -ControlID "4.1" `
            -ControlName "Use strong cryptography for transmission" `
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
    
    return New-ComplianceResult -Framework "PCI-DSS" -ControlID "4.1" `
        -ControlName "Use strong cryptography for transmission" `
        -Domain "Data Protection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage secure transfer required" `
        -Reason "$percentage% require secure transfer ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Requirement 10: Track and Monitor

<#
.SYNOPSIS
    PCI-DSS 10.1: Implement audit trails
.DESCRIPTION
    Validates logging and audit trail configuration
#>
function Test-PCIDSS-10-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing PCI-DSS 10.1: Audit trails"
    
    $diagSettings = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "diagnostic_settings"
    $logAnalytics = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "log_analytics"
    
    $hasLogging = $diagSettings -and $diagSettings.Count -gt 0
    $hasWorkspace = $logAnalytics -and $logAnalytics.Count -gt 0
    
    $status = if ($hasLogging -and $hasWorkspace) { "PASS" } else { "FAIL" }
    
    $reason = "Diagnostic settings: $(if ($hasLogging) { 'Configured' } else { 'Not configured' }). "
    $reason += "Log Analytics: $(if ($hasWorkspace) { $logAnalytics.Count } else { 0 }) workspace(s)"
    
    return New-ComplianceResult -Framework "PCI-DSS" -ControlID "10.1" `
        -ControlName "Implement audit trails" `
        -Domain "Logging & Threat Detection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Diagnostic settings, Log Analytics" `
        -Reason $reason
}

#endregion

