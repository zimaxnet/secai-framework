#Requires -Version 7.0
<#
.SYNOPSIS
    Microsoft Cloud Security Benchmark (MCSB) Validation Module
.DESCRIPTION
    Validates Azure environments against Microsoft Cloud Security Benchmark controls.
    Maps MCSB controls to SecAI Framework evidence.
.NOTES
    MCSB Domains:
    - Network Security (NS)
    - Identity Management (IM)
    - Privileged Access (PA)
    - Data Protection (DP)
    - Asset Management (AM)
    - Logging and Threat Detection (LT)
    - Incident Response (IR)
    - Posture and Vulnerability Management (PV)
    - Endpoint Security (ES)
    - Backup and Recovery (BR)
    - DevOps Security (DS)
    - Governance and Strategy (GS)
#>

# Import common functions
Import-Module (Join-Path $PSScriptRoot "Common-Functions.psm1") -Force

# Export functions
Export-ModuleMember -Function @(
    'Invoke-MSCBValidation'
    'Test-MCSB-NS-1'
    'Test-MCSB-NS-2'
    'Test-MCSB-IM-1'
    'Test-MCSB-PA-1'
    'Test-MCSB-DP-1'
    'Test-MCSB-DP-4'
    'Test-MCSB-AM-1'
    'Test-MCSB-LT-1'
    'Test-MCSB-BR-1'
)

<#
.SYNOPSIS
    Master function to run all MCSB validations
.PARAMETER DataPath
    Path to SecAI output directory
.PARAMETER SubscriptionID
    Subscription ID to validate
.EXAMPLE
    $results = Invoke-MSCBValidation -DataPath "C:\Data" -SubscriptionID "abc-123"
#>
function Invoke-MSCBValidation {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DataPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionID
    )
    
    Write-Host "  Running MCSB validation for subscription: $SubscriptionID" -ForegroundColor Cyan
    
    $results = @()
    
    # Network Security (NS)
    $results += Test-MCSB-NS-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-MCSB-NS-2 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Identity Management (IM)
    $results += Test-MCSB-IM-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Privileged Access (PA)
    $results += Test-MCSB-PA-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Data Protection (DP)
    $results += Test-MCSB-DP-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    $results += Test-MCSB-DP-4 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Asset Management (AM)
    $results += Test-MCSB-AM-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Logging and Threat Detection (LT)
    $results += Test-MCSB-LT-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    # Backup and Recovery (BR)
    $results += Test-MCSB-BR-1 -DataPath $DataPath -SubscriptionID $SubscriptionID
    
    return $results
}

#region Network Security (NS)

<#
.SYNOPSIS
    MCSB NS-1: Implement network segmentation patterns
.DESCRIPTION
    Validates that network segmentation is implemented using NSGs and Azure Firewall
#>
function Test-MCSB-NS-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB NS-1: Network Segmentation"
    
    # Check for NSGs and Azure Firewalls
    $vnets = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "vnets"
    $nsgs = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "nsgs"
    $firewalls = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "az_firewalls"
    
    if (-not $vnets) {
        return New-ComplianceResult -Framework "MCSB" -ControlID "NS-1" `
            -ControlName "Implement network segmentation patterns" `
            -Domain "Network" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No virtual networks found"
    }
    
    # Check if subnets have NSGs
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
    
    $hasFirewall = $firewalls -and $firewalls.Count -gt 0
    $percentage = if ($totalSubnets -gt 0) {
        [math]::Round(($subnetsWithNSG / $totalSubnets) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -ge 80 -and $hasFirewall) { "PASS" } 
              elseif ($percentage -ge 60) { "FAIL" }
              else { "FAIL" }
    
    $reason = "NSG coverage: $percentage% ($subnetsWithNSG/$totalSubnets subnets). "
    $reason += if ($hasFirewall) { "Azure Firewall deployed." } else { "No Azure Firewall found." }
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "NS-1" `
        -ControlName "Implement network segmentation patterns" `
        -Domain "Network" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "VNets, NSGs, Azure Firewalls" `
        -Reason $reason `
        -TotalResources $totalSubnets `
        -CompliantResources $subnetsWithNSG `
        -NonCompliantResources ($totalSubnets - $subnetsWithNSG)
}

<#
.SYNOPSIS
    MCSB NS-2: Secure cloud services with network controls
.DESCRIPTION
    Validates that PaaS services use private endpoints or service endpoints
#>
function Test-MCSB-NS-2 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB NS-2: Secure cloud services"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    $privateEndpoints = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "private_endpoints"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "MCSB" -ControlID "NS-2" `
            -ControlName "Secure cloud services with network controls" `
            -Domain "Network" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No storage accounts found"
    }
    
    # Check for storage accounts with network restrictions
    $secureStorage = @($storage | Where-Object {
        $_.properties.networkAcls.defaultAction -eq "Deny"
    })
    
    $total = $storage.Count
    $compliant = $secureStorage.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -ge 100) { "PASS" } else { "FAIL" }
    
    $privateEndpointCount = if ($privateEndpoints) { $privateEndpoints.Count } else { 0 }
    $reason = "$percentage% of storage accounts have network restrictions. "
    $reason += "Private endpoints deployed: $privateEndpointCount"
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "NS-2" `
        -ControlName "Secure cloud services with network controls" `
        -Domain "Network" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage network ACLs, Private Endpoints" `
        -Reason $reason `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Identity Management (IM)

<#
.SYNOPSIS
    MCSB IM-1: Use centralized identity and authentication system
.DESCRIPTION
    Validates Azure AD integration for resources
#>
function Test-MCSB-IM-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB IM-1: Centralized identity"
    
    # This is primarily a process/configuration check
    # We can check for Azure AD integrated resources
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "IM-1" `
        -ControlName "Use centralized identity and authentication system" `
        -Domain "Identity" -Severity "Critical" -Status "MANUAL" `
        -SubscriptionID $SubscriptionID `
        -Reason "Manual verification required - check Azure AD integration across services"
}

#endregion

#region Privileged Access (PA)

<#
.SYNOPSIS
    MCSB PA-1: Protect and limit highly privileged/administrative users
.DESCRIPTION
    Validates PIM usage and privileged role assignments
#>
function Test-MCSB-PA-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB PA-1: Protect privileged users"
    
    # Check RBAC for Owner/Contributor assignments
    # This requires RBAC data from script 04
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "PA-1" `
        -ControlName "Protect and limit highly privileged users" `
        -Domain "Privileged Access" -Severity "Critical" -Status "MANUAL" `
        -SubscriptionID $SubscriptionID `
        -Reason "Manual verification required - check PIM usage and privileged role assignments"
}

#endregion

#region Data Protection (DP)

<#
.SYNOPSIS
    MCSB DP-1: Discovery, classify, and label sensitive data
.DESCRIPTION
    Validates data classification and labeling
#>
function Test-MCSB-DP-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB DP-1: Data classification"
    
    # Check for resource tagging (as proxy for data classification)
    $resources = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "resources"
    
    if (-not $resources) {
        return New-ComplianceResult -Framework "MCSB" -ControlID "DP-1" `
            -ControlName "Discovery, classify, and label sensitive data" `
            -Domain "Data Protection" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No resources found"
    }
    
    # Check for data classification tags
    $classifiedResources = @($resources | Where-Object {
        $_.tags -and ($_.tags.DataClassification -or $_.tags.'Data Classification' -or $_.tags.Sensitivity)
    })
    
    $total = $resources.Count
    $compliant = $classifiedResources.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -ge 80) { "PASS" } elseif ($percentage -ge 50) { "FAIL" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "DP-1" `
        -ControlName "Discovery, classify, and label sensitive data" `
        -Domain "Data Protection" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Resource tags (DataClassification, Sensitivity)" `
        -Reason "$percentage% of resources have classification tags ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

<#
.SYNOPSIS
    MCSB DP-4: Enable data at rest encryption by default
.DESCRIPTION
    Validates encryption at rest for storage and databases
#>
function Test-MCSB-DP-4 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB DP-4: Data at rest encryption"
    
    $storage = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "storage"
    
    if (-not $storage) {
        return New-ComplianceResult -Framework "MCSB" -ControlID "DP-4" `
            -ControlName "Enable data at rest encryption by default" `
            -Domain "Data Protection" -Severity "Critical" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No storage accounts found"
    }
    
    # Check storage encryption
    $encryptedStorage = @($storage | Where-Object {
        $_.properties.encryption.services.blob.enabled -eq $true
    })
    
    $total = $storage.Count
    $compliant = $encryptedStorage.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -eq 100) { "PASS" } else { "FAIL" }
    
    $nonCompliantNames = @($storage | Where-Object {
        $_.properties.encryption.services.blob.enabled -ne $true
    } | Select-Object -ExpandProperty name) -join ", "
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "DP-4" `
        -ControlName "Enable data at rest encryption by default" `
        -Domain "Data Protection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Storage account blob encryption" `
        -Reason "$percentage% of storage accounts encrypted ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant) `
        -NonCompliantResourceNames $nonCompliantNames
}

#endregion

#region Asset Management (AM)

<#
.SYNOPSIS
    MCSB AM-1: Track and inventory assets
.DESCRIPTION
    Validates asset inventory and tracking
#>
function Test-MCSB-AM-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB AM-1: Asset tracking"
    
    $resources = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "resources"
    
    if (-not $resources) {
        return New-ComplianceResult -Framework "MCSB" -ControlID "AM-1" `
            -ControlName "Track and inventory assets" `
            -Domain "Asset Management" -Severity "Medium" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No resources found"
    }
    
    # Check for required tags (Environment, Owner, CostCenter, etc.)
    $requiredTags = @("Environment", "Owner")
    $taggedResources = @($resources | Where-Object {
        $tags = $_.tags
        if (-not $tags) { return $false }
        $hasAllTags = $true
        foreach ($tag in $requiredTags) {
            if (-not $tags.$tag) {
                $hasAllTags = $false
                break
            }
        }
        $hasAllTags
    })
    
    $total = $resources.Count
    $compliant = $taggedResources.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -ge 90) { "PASS" } elseif ($percentage -ge 70) { "FAIL" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "AM-1" `
        -ControlName "Track and inventory assets" `
        -Domain "Asset Management" -Severity "Medium" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Resource tags (Environment, Owner)" `
        -Reason "$percentage% of resources have required tags ($compliant/$total)" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Logging and Threat Detection (LT)

<#
.SYNOPSIS
    MCSB LT-1: Enable threat detection capabilities
.DESCRIPTION
    Validates Microsoft Defender for Cloud and logging
#>
function Test-MCSB-LT-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB LT-1: Threat detection"
    
    $defenderPricing = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "defender_pricing"
    
    if (-not $defenderPricing) {
        return New-ComplianceResult -Framework "MCSB" -ControlID "LT-1" `
            -ControlName "Enable threat detection capabilities" `
            -Domain "Logging & Threat Detection" -Severity "Critical" -Status "ERROR" `
            -SubscriptionID $SubscriptionID `
            -Reason "Defender pricing data not found"
    }
    
    # Check for Standard tier on key resource types
    $criticalTypes = @("VirtualMachines", "SqlServers", "AppServices", "StorageAccounts", "KeyVaults")
    $standardTier = @($defenderPricing | Where-Object {
        $_.properties.pricingTier -eq "Standard"
    })
    
    $criticalOnStandard = @($standardTier | Where-Object {
        $criticalTypes -contains $_.name
    })
    
    $total = $criticalTypes.Count
    $compliant = $criticalOnStandard.Count
    $percentage = if ($total -gt 0) {
        [math]::Round(($compliant / $total) * 100, 2)
    } else { 0 }
    
    $status = if ($percentage -eq 100) { "PASS" } else { "FAIL" }
    
    $missingTypes = $criticalTypes | Where-Object { 
        $_ -notin $standardTier.name 
    }
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "LT-1" `
        -ControlName "Enable threat detection capabilities" `
        -Domain "Logging & Threat Detection" -Severity "Critical" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Defender for Cloud pricing tiers" `
        -Reason "$percentage% of critical resource types on Standard tier ($compliant/$total). Missing: $($missingTypes -join ', ')" `
        -TotalResources $total `
        -CompliantResources $compliant `
        -NonCompliantResources ($total - $compliant)
}

#endregion

#region Backup and Recovery (BR)

<#
.SYNOPSIS
    MCSB BR-1: Ensure regular backup and recovery
.DESCRIPTION
    Validates backup configuration
#>
function Test-MCSB-BR-1 {
    [CmdletBinding()]
    param(
        [string]$DataPath,
        [string]$SubscriptionID
    )
    
    Write-Verbose "Testing MCSB BR-1: Backup and recovery"
    
    # Check for Recovery Services Vaults
    $resources = Get-SecAIData -DataPath $DataPath -SubscriptionID $SubscriptionID -ResourceType "resources"
    
    if (-not $resources) {
        return New-ComplianceResult -Framework "MCSB" -ControlID "BR-1" `
            -ControlName "Ensure regular backup and recovery" `
            -Domain "Backup & Recovery" -Severity "High" -Status "SKIP" `
            -SubscriptionID $SubscriptionID `
            -Reason "No resources found"
    }
    
    $vaults = @($resources | Where-Object { 
        $_.type -eq "Microsoft.RecoveryServices/vaults" 
    })
    
    $hasBackup = $vaults.Count -gt 0
    $status = if ($hasBackup) { "PASS" } else { "FAIL" }
    
    return New-ComplianceResult -Framework "MCSB" -ControlID "BR-1" `
        -ControlName "Ensure regular backup and recovery" `
        -Domain "Backup & Recovery" -Severity "High" -Status $status `
        -SubscriptionID $SubscriptionID `
        -Evidence "Recovery Services Vaults" `
        -Reason "Recovery Services Vaults deployed: $($vaults.Count)" `
        -TotalResources 1 `
        -CompliantResources (if ($hasBackup) { 1 } else { 0 }) `
        -NonCompliantResources (if ($hasBackup) { 0 } else { 1 })
}

#endregion

