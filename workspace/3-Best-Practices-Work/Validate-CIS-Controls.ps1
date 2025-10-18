#Requires -Version 7.0
<#
.SYNOPSIS
    CIS Azure Foundations Benchmark v2.0 - Automated Validation
.DESCRIPTION
    Validates Azure environment against CIS Benchmark controls using collected SecAI data.
    Reads JSON files from SecAI assessment and checks each control's compliance.
.PARAMETER DataPath
    Path to directory containing SecAI assessment output files (JSON)
.PARAMETER SubscriptionID
    Subscription ID to validate (optional - validates all if not specified)
.PARAMETER OutputPath
    Path for compliance report output (default: current directory)
.EXAMPLE
    .\Validate-CIS-Controls.ps1 -DataPath "C:\Assessment\Output" -OutputPath "C:\Reports"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$DataPath,
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionID,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "CIS Azure Benchmark Validation" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Validate data path exists
if (-not (Test-Path $DataPath)) {
    Write-Error "Data path not found: $DataPath"
    Write-Host "Please run SecAI collection scripts first (01-09)" -ForegroundColor Yellow
    exit 1
}

# Get list of subscriptions to validate
$subscriptionsToValidate = @()
if ($SubscriptionID) {
    $subscriptionsToValidate += $SubscriptionID
    Write-Host "Validating single subscription: $SubscriptionID" -ForegroundColor Yellow
}
else {
    # Find all subscription IDs from file names
    $files = Get-ChildItem -Path $DataPath -Filter "*_storage.json"
    $subscriptionsToValidate = $files | ForEach-Object { 
        $_.Name -replace '_storage\.json$', '' 
    }
    Write-Host "Found $($subscriptionsToValidate.Count) subscription(s) to validate" -ForegroundColor Yellow
}

if ($subscriptionsToValidate.Count -eq 0) {
    Write-Error "No subscriptions found to validate"
    exit 1
}

Write-Host ""

# Initialize results
$allResults = @()

#region Section 3: Storage Accounts

function Test-CIS-3-1 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "3.1"
    $controlName = "Ensure that 'Secure transfer required' is set to 'Enabled'"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $storageFile = Join-Path $DataPath "$SubID`_storage.json"
    
    if (-not (Test-Path $storageFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No storage accounts found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $storage = Get-Content $storageFile -Raw | ConvertFrom-Json
        
        if (-not $storage -or $storage.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No storage accounts found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        $compliant = @($storage | Where-Object { 
            $_.properties.supportsHttpsTrafficOnly -eq $true 
        })
        
        $nonCompliant = @($storage | Where-Object { 
            $_.properties.supportsHttpsTrafficOnly -ne $true 
        })
        
        $total = $storage.Count
        $compliantCount = $compliant.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($compliantCount -eq $total) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliant.Count) storage account(s) allow insecure transfer" } else { "All storage accounts require secure transfer" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliant.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliant.Count -gt 0) { $nonCompliant.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse storage data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

function Test-CIS-3-2 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "3.2"
    $controlName = "Ensure default network access rule for Storage Accounts is set to deny"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $storageFile = Join-Path $DataPath "$SubID`_storage.json"
    
    if (-not (Test-Path $storageFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No storage accounts found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $storage = Get-Content $storageFile -Raw | ConvertFrom-Json
        
        if (-not $storage -or $storage.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No storage accounts found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        $compliant = @($storage | Where-Object { 
            $_.properties.networkAcls.defaultAction -eq "Deny" 
        })
        
        $nonCompliant = @($storage | Where-Object { 
            $_.properties.networkAcls.defaultAction -ne "Deny" 
        })
        
        $total = $storage.Count
        $compliantCount = $compliant.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($compliantCount -eq $total) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliant.Count) storage account(s) allow public network access" } else { "All storage accounts deny public access by default" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliant.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliant.Count -gt 0) { $nonCompliant.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse storage data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

#endregion

#region Section 6: Networking

function Test-CIS-6-2 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "6.2"
    $controlName = "Ensure that Network Security Groups flow logs are captured and sent to Log Analytics"
    $level = 2
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    # This is a manual check - requires Network Watcher NSG Flow Logs config
    # SecAI doesn't currently collect this data
    
    return @{
        SubscriptionID = $SubID
        ControlID = $controlID
        ControlName = $controlName
        Level = $level
        Status = "MANUAL"
        Reason = "Manual verification required - check Network Watcher NSG Flow Logs"
        TotalResources = 0
        CompliantResources = 0
        NonCompliantResources = 0
        CompliancePercentage = 0
    }
}

function Test-CIS-6-6 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "6.6"
    $controlName = "Ensure that Network Watcher is 'Enabled'"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    # Check if Network Watcher resources exist
    $resourcesFile = Join-Path $DataPath "$SubID`_resources.json"
    
    if (-not (Test-Path $resourcesFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Resource inventory file not found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $resources = Get-Content $resourcesFile -Raw | ConvertFrom-Json
        $networkWatchers = @($resources | Where-Object { $_.type -eq "Microsoft.Network/networkWatchers" })
        
        $status = if ($networkWatchers.Count -gt 0) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "PASS") { "Network Watcher enabled: $($networkWatchers.Count) instance(s)" } else { "Network Watcher not enabled" }
            TotalResources = if ($networkWatchers.Count -gt 0) { 1 } else { 0 }
            CompliantResources = if ($networkWatchers.Count -gt 0) { 1 } else { 0 }
            NonCompliantResources = if ($networkWatchers.Count -eq 0) { 1 } else { 0 }
            CompliancePercentage = if ($networkWatchers.Count -gt 0) { 100 } else { 0 }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse resource data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

#endregion

#region Section 8: Key Vault

function Test-CIS-8-1 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "8.1"
    $controlName = "Ensure that the Expiration Date is set for all Keys in Key Vault"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $kvFile = Join-Path $DataPath "$SubID`_keyvaults.json"
    
    if (-not (Test-Path $kvFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No Key Vaults found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    # Note: This requires additional data collection (key properties)
    # SecAI collects Key Vault config but not individual key details
    
    return @{
        SubscriptionID = $SubID
        ControlID = $controlID
        ControlName = $controlName
        Level = $level
        Status = "MANUAL"
        Reason = "Manual verification required - check individual keys in each vault"
        TotalResources = 0
        CompliantResources = 0
        NonCompliantResources = 0
        CompliancePercentage = 0
    }
}

function Test-CIS-8-4 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "8.4"
    $controlName = "Ensure that Soft Delete is Enabled for all Key Vaults"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $kvFile = Join-Path $DataPath "$SubID`_keyvaults.json"
    
    if (-not (Test-Path $kvFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No Key Vaults found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $keyvaults = Get-Content $kvFile -Raw | ConvertFrom-Json
        
        if (-not $keyvaults -or $keyvaults.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No Key Vaults found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        $compliant = @($keyvaults | Where-Object { 
            $_.properties.enableSoftDelete -eq $true 
        })
        
        $nonCompliant = @($keyvaults | Where-Object { 
            $_.properties.enableSoftDelete -ne $true 
        })
        
        $total = $keyvaults.Count
        $compliantCount = $compliant.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($compliantCount -eq $total) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliant.Count) Key Vault(s) without soft delete" } else { "All Key Vaults have soft delete enabled" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliant.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliant.Count -gt 0) { $nonCompliant.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse Key Vault data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

function Test-CIS-8-5 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "8.5"
    $controlName = "Ensure that Purge Protection is Enabled for all Key Vaults"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $kvFile = Join-Path $DataPath "$SubID`_keyvaults.json"
    
    if (-not (Test-Path $kvFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No Key Vaults found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $keyvaults = Get-Content $kvFile -Raw | ConvertFrom-Json
        
        if (-not $keyvaults -or $keyvaults.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No Key Vaults found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        $compliant = @($keyvaults | Where-Object { 
            $_.properties.enablePurgeProtection -eq $true 
        })
        
        $nonCompliant = @($keyvaults | Where-Object { 
            $_.properties.enablePurgeProtection -ne $true 
        })
        
        $total = $keyvaults.Count
        $compliantCount = $compliant.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($compliantCount -eq $total) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliant.Count) Key Vault(s) without purge protection" } else { "All Key Vaults have purge protection enabled" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliant.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliant.Count -gt 0) { $nonCompliant.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse Key Vault data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

#endregion

#region Section 2: Defender for Cloud

function Test-CIS-2-1 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "2.1"
    $controlName = "Ensure that Microsoft Defender for Cloud is set to Standard tier"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $defenderFile = Join-Path $DataPath "$SubID`_defender_pricing.json"
    
    if (-not (Test-Path $defenderFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Defender pricing data not found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $defenderPricing = Get-Content $defenderFile -Raw | ConvertFrom-Json
        
        if (-not $defenderPricing -or $defenderPricing.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "FAIL"
                Reason = "No Defender for Cloud pricing configuration found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        $standardTier = @($defenderPricing | Where-Object { 
            $_.properties.pricingTier -eq "Standard" 
        })
        
        $freeTier = @($defenderPricing | Where-Object { 
            $_.properties.pricingTier -ne "Standard" 
        })
        
        $total = $defenderPricing.Count
        $compliantCount = $standardTier.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        
        # CIS requires Standard tier for key resource types
        $criticalTypes = @("VirtualMachines", "SqlServers", "AppServices", "StorageAccounts", "KeyVaults")
        $criticalOnStandard = @($standardTier | Where-Object { 
            $criticalTypes -contains $_.name 
        })
        
        $status = if ($criticalOnStandard.Count -eq $criticalTypes.Count) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($freeTier.Count) resource type(s) on Free tier" } else { "All critical resource types on Standard tier" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $freeTier.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($freeTier.Count -gt 0) { $freeTier.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse Defender pricing data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

#endregion

#region Section 4: Database Services

function Test-CIS-4-1-1 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "4.1.1"
    $controlName = "Ensure that auditing is enabled for SQL servers"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $sqlFile = Join-Path $DataPath "$SubID`_sql_servers.json"
    
    if (-not (Test-Path $sqlFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No SQL servers found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $sqlServers = Get-Content $sqlFile -Raw | ConvertFrom-Json
        
        if (-not $sqlServers -or $sqlServers.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No SQL servers found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        # Note: Full auditing check requires additional API calls
        # This is a simplified check - manual verification recommended
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "MANUAL"
            Reason = "Manual verification required - check SQL server auditing settings in portal"
            TotalResources = $sqlServers.Count
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse SQL server data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

function Test-CIS-4-1-3 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "4.1.3"
    $controlName = "Ensure no Azure SQL Databases allow ingress from 0.0.0.0/0"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $sqlFile = Join-Path $DataPath "$SubID`_sql_servers.json"
    
    if (-not (Test-Path $sqlFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No SQL servers found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $sqlServers = Get-Content $sqlFile -Raw | ConvertFrom-Json
        
        if (-not $sqlServers -or $sqlServers.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No SQL servers found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        # Check firewall rules for "Allow all" (0.0.0.0 to 0.0.0.0 or 0.0.0.0 to 255.255.255.255)
        $nonCompliantServers = @()
        foreach ($server in $sqlServers) {
            $hasAllowAll = $false
            if ($server.firewallRules) {
                foreach ($rule in $server.firewallRules) {
                    if (($rule.properties.startIpAddress -eq "0.0.0.0" -and $rule.properties.endIpAddress -eq "0.0.0.0") -or
                        ($rule.properties.startIpAddress -eq "0.0.0.0" -and $rule.properties.endIpAddress -eq "255.255.255.255")) {
                        $hasAllowAll = $true
                        break
                    }
                }
            }
            if ($hasAllowAll) {
                $nonCompliantServers += $server
            }
        }
        
        $compliantCount = $sqlServers.Count - $nonCompliantServers.Count
        $total = $sqlServers.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($nonCompliantServers.Count -eq 0) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliantServers.Count) SQL server(s) allow ingress from 0.0.0.0/0" } else { "No SQL servers allow unrestricted access" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliantServers.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliantServers.Count -gt 0) { $nonCompliantServers.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse SQL server data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

#endregion

#region Section 5: Logging and Monitoring

function Test-CIS-5-1-3 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "5.1.3"
    $controlName = "Ensure diagnostic setting is configured to export activity logs"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $diagFile = Join-Path $DataPath "$SubID`_diagnostic_settings.json"
    
    if (-not (Test-Path $diagFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "FAIL"
            Reason = "No diagnostic settings found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 1
            CompliancePercentage = 0
        }
    }
    
    try {
        $diagSettings = Get-Content $diagFile -Raw | ConvertFrom-Json
        
        if (-not $diagSettings -or $diagSettings.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "FAIL"
                Reason = "No diagnostic settings configured"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 1
                CompliancePercentage = 0
            }
        }
        
        # Check if there's at least one diagnostic setting with activity logs enabled
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
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "PASS") { "Diagnostic settings configured for activity logs" } else { "Activity log diagnostic settings not configured" }
            TotalResources = 1
            CompliantResources = if ($hasActivityLogs) { 1 } else { 0 }
            NonCompliantResources = if ($hasActivityLogs) { 0 } else { 1 }
            CompliancePercentage = if ($hasActivityLogs) { 100 } else { 0 }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse diagnostic settings data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

function Test-CIS-5-3 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "5.3"
    $controlName = "Ensure that logging for Azure Key Vault is 'Enabled'"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $kvFile = Join-Path $DataPath "$SubID`_keyvaults.json"
    
    if (-not (Test-Path $kvFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "SKIP"
            Reason = "No Key Vaults found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    # Note: This requires checking diagnostic settings for each Key Vault
    # Full implementation requires cross-referencing with diagnostic_settings.json
    
    return @{
        SubscriptionID = $SubID
        ControlID = $controlID
        ControlName = $controlName
        Level = $level
        Status = "MANUAL"
        Reason = "Manual verification required - check diagnostic settings for each Key Vault"
        TotalResources = 0
        CompliantResources = 0
        NonCompliantResources = 0
        CompliancePercentage = 0
    }
}

#endregion

#region Section 7: Virtual Machines

function Test-CIS-7-1 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "7.1"
    $controlName = "Ensure Virtual Machines are utilizing Managed Disks"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $resourcesFile = Join-Path $DataPath "$SubID`_resources.json"
    
    if (-not (Test-Path $resourcesFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Resource inventory file not found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $resources = Get-Content $resourcesFile -Raw | ConvertFrom-Json
        $vms = @($resources | Where-Object { $_.type -eq "Microsoft.Compute/virtualMachines" })
        
        if ($vms.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No virtual machines found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        # Check for managed disks (simplified check - full check requires VM details)
        # If VM has managedDisk property, it's using managed disks
        $compliantVMs = @($vms | Where-Object { 
            $_.properties.storageProfile.osDisk.managedDisk -ne $null 
        })
        
        $nonCompliantVMs = @($vms | Where-Object { 
            $_.properties.storageProfile.osDisk.managedDisk -eq $null 
        })
        
        $total = $vms.Count
        $compliantCount = $compliantVMs.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($compliantCount -eq $total) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliantVMs.Count) VM(s) using unmanaged disks" } else { "All VMs using managed disks" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliantVMs.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliantVMs.Count -gt 0) { $nonCompliantVMs.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse VM data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

#endregion

#region Section 9: App Service

function Test-CIS-9-1 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "9.1"
    $controlName = "Ensure App Service authentication is set up for apps"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $resourcesFile = Join-Path $DataPath "$SubID`_resources.json"
    
    if (-not (Test-Path $resourcesFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Resource inventory file not found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $resources = Get-Content $resourcesFile -Raw | ConvertFrom-Json
        $appServices = @($resources | Where-Object { 
            $_.type -eq "Microsoft.Web/sites" -and $_.kind -notmatch "functionapp" 
        })
        
        if ($appServices.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No App Services found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        # Note: Full auth check requires additional API call to get auth settings
        # This is a simplified check
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "MANUAL"
            Reason = "Manual verification required - check authentication settings for each App Service"
            TotalResources = $appServices.Count
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse App Service data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

function Test-CIS-9-2 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "9.2"
    $controlName = "Ensure web app redirects all HTTP traffic to HTTPS"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $resourcesFile = Join-Path $DataPath "$SubID`_resources.json"
    
    if (-not (Test-Path $resourcesFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Resource inventory file not found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $resources = Get-Content $resourcesFile -Raw | ConvertFrom-Json
        $appServices = @($resources | Where-Object { 
            $_.type -eq "Microsoft.Web/sites" -and $_.kind -notmatch "functionapp" 
        })
        
        if ($appServices.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No App Services found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        $compliant = @($appServices | Where-Object { 
            $_.properties.httpsOnly -eq $true 
        })
        
        $nonCompliant = @($appServices | Where-Object { 
            $_.properties.httpsOnly -ne $true 
        })
        
        $total = $appServices.Count
        $compliantCount = $compliant.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($compliantCount -eq $total) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliant.Count) App Service(s) allow HTTP traffic" } else { "All App Services redirect to HTTPS" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliant.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliant.Count -gt 0) { $nonCompliant.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse App Service data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

function Test-CIS-9-3 {
    param(
        [string]$DataPath,
        [string]$SubID
    )
    
    $controlID = "9.3"
    $controlName = "Ensure web app is using the latest version of TLS encryption"
    $level = 1
    
    Write-Host "  Testing CIS $controlID - $controlName" -ForegroundColor Gray
    
    $resourcesFile = Join-Path $DataPath "$SubID`_resources.json"
    
    if (-not (Test-Path $resourcesFile)) {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Resource inventory file not found"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
    
    try {
        $resources = Get-Content $resourcesFile -Raw | ConvertFrom-Json
        $appServices = @($resources | Where-Object { 
            $_.type -eq "Microsoft.Web/sites" -and $_.kind -notmatch "functionapp" 
        })
        
        if ($appServices.Count -eq 0) {
            return @{
                SubscriptionID = $SubID
                ControlID = $controlID
                ControlName = $controlName
                Level = $level
                Status = "SKIP"
                Reason = "No App Services found"
                TotalResources = 0
                CompliantResources = 0
                NonCompliantResources = 0
                CompliancePercentage = 0
            }
        }
        
        # Check for TLS 1.2 or higher
        $compliant = @($appServices | Where-Object { 
            $_.properties.siteConfig.minTlsVersion -eq "1.2" -or 
            $_.properties.siteConfig.minTlsVersion -eq "1.3" 
        })
        
        $nonCompliant = @($appServices | Where-Object { 
            $_.properties.siteConfig.minTlsVersion -ne "1.2" -and 
            $_.properties.siteConfig.minTlsVersion -ne "1.3" 
        })
        
        $total = $appServices.Count
        $compliantCount = $compliant.Count
        $percentage = if ($total -gt 0) { [math]::Round(($compliantCount / $total) * 100, 2) } else { 0 }
        $status = if ($compliantCount -eq $total) { "PASS" } else { "FAIL" }
        
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = $status
            Reason = if ($status -eq "FAIL") { "$($nonCompliant.Count) App Service(s) not using TLS 1.2+" } else { "All App Services using TLS 1.2 or higher" }
            TotalResources = $total
            CompliantResources = $compliantCount
            NonCompliantResources = $nonCompliant.Count
            CompliancePercentage = $percentage
            NonCompliantResourceNames = if ($nonCompliant.Count -gt 0) { $nonCompliant.name -join ", " } else { "" }
        }
    }
    catch {
        return @{
            SubscriptionID = $SubID
            ControlID = $controlID
            ControlName = $controlName
            Level = $level
            Status = "ERROR"
            Reason = "Failed to parse App Service data: $_"
            TotalResources = 0
            CompliantResources = 0
            NonCompliantResources = 0
            CompliancePercentage = 0
        }
    }
}

#endregion

# Main validation loop
Write-Host "Running CIS Benchmark validation..." -ForegroundColor Yellow
Write-Host ""

foreach ($subID in $subscriptionsToValidate) {
    Write-Host "Validating subscription: $subID" -ForegroundColor Cyan
    
    # Section 2: Defender for Cloud
    $allResults += Test-CIS-2-1 -DataPath $DataPath -SubID $subID
    
    # Section 3: Storage Accounts
    $allResults += Test-CIS-3-1 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-3-2 -DataPath $DataPath -SubID $subID
    
    # Section 4: Database Services
    $allResults += Test-CIS-4-1-1 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-4-1-3 -DataPath $DataPath -SubID $subID
    
    # Section 5: Logging and Monitoring
    $allResults += Test-CIS-5-1-3 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-5-3 -DataPath $DataPath -SubID $subID
    
    # Section 6: Networking
    $allResults += Test-CIS-6-2 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-6-6 -DataPath $DataPath -SubID $subID
    
    # Section 7: Virtual Machines
    $allResults += Test-CIS-7-1 -DataPath $DataPath -SubID $subID
    
    # Section 8: Key Vault
    $allResults += Test-CIS-8-1 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-8-4 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-8-5 -DataPath $DataPath -SubID $subID
    
    # Section 9: App Service
    $allResults += Test-CIS-9-1 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-9-2 -DataPath $DataPath -SubID $subID
    $allResults += Test-CIS-9-3 -DataPath $DataPath -SubID $subID
    
    Write-Host ""
}

# Generate summary
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Validation Summary" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

$passCount = ($allResults | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($allResults | Where-Object { $_.Status -eq "FAIL" }).Count
$skipCount = ($allResults | Where-Object { $_.Status -eq "SKIP" }).Count
$manualCount = ($allResults | Where-Object { $_.Status -eq "MANUAL" }).Count
$errorCount = ($allResults | Where-Object { $_.Status -eq "ERROR" }).Count
$totalTests = $allResults.Count

$testableControls = $totalTests - $skipCount - $manualCount
$compliancePercentage = if ($testableControls -gt 0) { 
    [math]::Round(($passCount / $testableControls) * 100, 2) 
} else { 0 }

Write-Host "Total Controls Tested: $totalTests" -ForegroundColor White
Write-Host "  PASS: $passCount" -ForegroundColor Green
Write-Host "  FAIL: $failCount" -ForegroundColor Red
Write-Host "  SKIP: $skipCount" -ForegroundColor Gray
Write-Host "  MANUAL: $manualCount" -ForegroundColor Yellow
Write-Host "  ERROR: $errorCount" -ForegroundColor Magenta
Write-Host ""
Write-Host "Compliance Score: $compliancePercentage%" -ForegroundColor $(if ($compliancePercentage -ge 80) { "Green" } elseif ($compliancePercentage -ge 60) { "Yellow" } else { "Red" })
Write-Host ""

# Export results to CSV
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$csvFile = Join-Path $OutputPath "CIS_Compliance_Report_$timestamp.csv"

$allResults | ForEach-Object { [PSCustomObject]$_ } | Export-Csv -Path $csvFile -NoTypeInformation

Write-Host "Report saved to: $csvFile" -ForegroundColor Green
Write-Host ""

# Show failed controls
$failedControls = $allResults | Where-Object { $_.Status -eq "FAIL" }
if ($failedControls.Count -gt 0) {
    Write-Host "Failed Controls (requires remediation):" -ForegroundColor Red
    foreach ($failed in $failedControls) {
        Write-Host "  - CIS $($failed.ControlID): $($failed.ControlName)" -ForegroundColor Yellow
        Write-Host "    Reason: $($failed.Reason)" -ForegroundColor Gray
        if ($failed.NonCompliantResourceNames) {
            Write-Host "    Resources: $($failed.NonCompliantResourceNames)" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

Write-Host "[COMPLETE] CIS validation finished" -ForegroundColor Green

