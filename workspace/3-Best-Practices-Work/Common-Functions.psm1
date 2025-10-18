#Requires -Version 7.0
<#
.SYNOPSIS
    Common Functions Module for Multi-Framework Validation
.DESCRIPTION
    Shared utilities for validating Azure environments against multiple compliance frameworks.
    Provides data loading, result formatting, and reporting functions.
#>

# Export functions
Export-ModuleMember -Function @(
    'Get-SecAIData'
    'New-ComplianceResult'
    'Test-JsonProperty'
    'Get-SubscriptionList'
    'Export-ComplianceReport'
    'Get-ComplianceSummary'
    'Get-FrameworkScore'
)

<#
.SYNOPSIS
    Loads SecAI data for a specific resource type
.DESCRIPTION
    Loads and parses JSON files from SecAI assessment output
.PARAMETER DataPath
    Path to SecAI output directory
.PARAMETER SubscriptionID
    Subscription ID to load data for
.PARAMETER ResourceType
    Type of resource (storage, keyvaults, vnets, nsgs, resources, sql_servers, etc.)
.EXAMPLE
    $storage = Get-SecAIData -DataPath "C:\Data" -SubscriptionID "abc-123" -ResourceType "storage"
#>
function Get-SecAIData {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DataPath,
        
        [Parameter(Mandatory=$true)]
        [string]$SubscriptionID,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("storage", "keyvaults", "vnets", "nsgs", "resources", "sql_servers", 
                     "sql_databases", "defender_pricing", "defender_settings", "diagnostic_settings",
                     "load_balancers", "az_firewalls", "private_endpoints", "route_tables",
                     "log_analytics", "activity_log")]
        [string]$ResourceType
    )
    
    $fileName = "$SubscriptionID`_$ResourceType.json"
    $filePath = Join-Path $DataPath $fileName
    
    if (-not (Test-Path $filePath)) {
        Write-Verbose "Data file not found: $fileName"
        return $null
    }
    
    try {
        $content = Get-Content $filePath -Raw | ConvertFrom-Json
        Write-Verbose "Loaded $fileName successfully"
        return $content
    }
    catch {
        Write-Warning "Failed to parse $fileName : $_"
        return $null
    }
}

<#
.SYNOPSIS
    Creates a standardized compliance result object
.DESCRIPTION
    Returns a hashtable with standard properties for compliance validation results
.PARAMETER Framework
    Framework name (MCSB, CIS, NIST, PCI-DSS, CCM)
.PARAMETER ControlID
    Framework-specific control ID
.PARAMETER ControlName
    Human-readable control name
.PARAMETER Status
    Compliance status (PASS, FAIL, SKIP, MANUAL, ERROR)
.PARAMETER Evidence
    Description of evidence checked
.PARAMETER Reason
    Explanation of the result
.PARAMETER TotalResources
    Total resources evaluated
.PARAMETER CompliantResources
    Number of compliant resources
.PARAMETER NonCompliantResources
    Number of non-compliant resources
.PARAMETER NonCompliantResourceNames
    Comma-separated list of non-compliant resource names
.PARAMETER Severity
    Control severity (Critical, High, Medium, Low)
.PARAMETER Domain
    Security domain (Network, Identity, Data, etc.)
.EXAMPLE
    $result = New-ComplianceResult -Framework "MCSB" -ControlID "DP-4" -Status "FAIL"
#>
function New-ComplianceResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Framework,
        
        [Parameter(Mandatory=$true)]
        [string]$ControlID,
        
        [Parameter(Mandatory=$true)]
        [string]$ControlName,
        
        [Parameter(Mandatory=$true)]
        [ValidateSet("PASS", "FAIL", "SKIP", "MANUAL", "ERROR")]
        [string]$Status,
        
        [string]$SubscriptionID = "",
        [string]$Evidence = "",
        [string]$Reason = "",
        [int]$TotalResources = 0,
        [int]$CompliantResources = 0,
        [int]$NonCompliantResources = 0,
        [string]$NonCompliantResourceNames = "",
        
        [ValidateSet("Critical", "High", "Medium", "Low")]
        [string]$Severity = "Medium",
        
        [ValidateSet("Network", "Identity", "Privileged Access", "Data Protection", 
                     "Asset Management", "Logging & Threat Detection", "Incident Response",
                     "Posture & Vulnerability", "Endpoint Security", "Backup & Recovery",
                     "DevOps Security", "Governance & Strategy")]
        [string]$Domain = "General"
    )
    
    $compliancePercentage = if ($TotalResources -gt 0) {
        [math]::Round(($CompliantResources / $TotalResources) * 100, 2)
    } else {
        0
    }
    
    return @{
        Framework = $Framework
        ControlID = $ControlID
        ControlName = $ControlName
        Domain = $Domain
        Severity = $Severity
        Status = $Status
        SubscriptionID = $SubscriptionID
        Evidence = $Evidence
        Reason = $Reason
        TotalResources = $TotalResources
        CompliantResources = $CompliantResources
        NonCompliantResources = $NonCompliantResources
        CompliancePercentage = $compliancePercentage
        NonCompliantResourceNames = $NonCompliantResourceNames
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
}

<#
.SYNOPSIS
    Tests if a JSON object has a specific property value
.DESCRIPTION
    Safely checks nested properties in JSON objects
.PARAMETER Object
    The JSON object to check
.PARAMETER PropertyPath
    Dot-notation path to property (e.g., "properties.encryption.enabled")
.PARAMETER ExpectedValue
    Expected value for the property
.EXAMPLE
    Test-JsonProperty -Object $storage -PropertyPath "properties.supportsHttpsTrafficOnly" -ExpectedValue $true
#>
function Test-JsonProperty {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [object]$Object,
        
        [Parameter(Mandatory=$true)]
        [string]$PropertyPath,
        
        [Parameter(Mandatory=$true)]
        [object]$ExpectedValue
    )
    
    if (-not $Object) { return $false }
    
    $current = $Object
    $properties = $PropertyPath -split '\.'
    
    foreach ($prop in $properties) {
        if ($null -eq $current.$prop) {
            return $false
        }
        $current = $current.$prop
    }
    
    return $current -eq $ExpectedValue
}

<#
.SYNOPSIS
    Gets list of subscriptions from SecAI data
.DESCRIPTION
    Scans data directory for subscription IDs based on file naming pattern
.PARAMETER DataPath
    Path to SecAI output directory
.EXAMPLE
    $subs = Get-SubscriptionList -DataPath "C:\Data"
#>
function Get-SubscriptionList {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$DataPath
    )
    
    if (-not (Test-Path $DataPath)) {
        Write-Error "Data path not found: $DataPath"
        return @()
    }
    
    # Find all files matching pattern and extract subscription IDs
    $files = Get-ChildItem -Path $DataPath -Filter "*_storage.json" -ErrorAction SilentlyContinue
    
    if ($files.Count -eq 0) {
        Write-Warning "No subscription data files found in $DataPath"
        return @()
    }
    
    $subscriptionIDs = $files | ForEach-Object {
        $_.Name -replace '_storage\.json$', ''
    }
    
    return $subscriptionIDs | Sort-Object -Unique
}

<#
.SYNOPSIS
    Exports compliance results to CSV
.DESCRIPTION
    Exports all validation results to a CSV file
.PARAMETER Results
    Array of compliance result objects
.PARAMETER OutputPath
    Directory to save the report
.PARAMETER ReportName
    Base name for the report file
.EXAMPLE
    Export-ComplianceReport -Results $results -OutputPath "C:\Reports" -ReportName "Multi_Framework"
#>
function Export-ComplianceReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$Results,
        
        [Parameter(Mandatory=$true)]
        [string]$OutputPath,
        
        [string]$ReportName = "Compliance_Report"
    )
    
    if ($Results.Count -eq 0) {
        Write-Warning "No results to export"
        return
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $fileName = "$ReportName`_$timestamp.csv"
    $filePath = Join-Path $OutputPath $fileName
    
    # Ensure output directory exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    # Convert results to PSCustomObjects for CSV export
    $csvData = $Results | ForEach-Object {
        [PSCustomObject]$_
    }
    
    $csvData | Export-Csv -Path $filePath -NoTypeInformation
    
    Write-Host "Report saved to: $filePath" -ForegroundColor Green
    return $filePath
}

<#
.SYNOPSIS
    Generates compliance summary statistics
.DESCRIPTION
    Calculates summary statistics from validation results
.PARAMETER Results
    Array of compliance result objects
.EXAMPLE
    $summary = Get-ComplianceSummary -Results $results
#>
function Get-ComplianceSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$Results
    )
    
    $total = $Results.Count
    $pass = ($Results | Where-Object { $_.Status -eq "PASS" }).Count
    $fail = ($Results | Where-Object { $_.Status -eq "FAIL" }).Count
    $skip = ($Results | Where-Object { $_.Status -eq "SKIP" }).Count
    $manual = ($Results | Where-Object { $_.Status -eq "MANUAL" }).Count
    $error = ($Results | Where-Object { $_.Status -eq "ERROR" }).Count
    
    $testable = $total - $skip - $manual
    $compliancePercentage = if ($testable -gt 0) {
        [math]::Round(($pass / $testable) * 100, 2)
    } else {
        0
    }
    
    return @{
        TotalControls = $total
        PassCount = $pass
        FailCount = $fail
        SkipCount = $skip
        ManualCount = $manual
        ErrorCount = $error
        TestableControls = $testable
        CompliancePercentage = $compliancePercentage
    }
}

<#
.SYNOPSIS
    Calculates compliance score for a specific framework
.DESCRIPTION
    Filters results by framework and calculates compliance score
.PARAMETER Results
    Array of compliance result objects
.PARAMETER Framework
    Framework name to filter by
.EXAMPLE
    $score = Get-FrameworkScore -Results $results -Framework "MCSB"
#>
function Get-FrameworkScore {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [array]$Results,
        
        [Parameter(Mandatory=$true)]
        [string]$Framework
    )
    
    $frameworkResults = $Results | Where-Object { $_.Framework -eq $Framework }
    
    if ($frameworkResults.Count -eq 0) {
        return @{
            Framework = $Framework
            Score = 0
            Total = 0
            Pass = 0
            Fail = 0
        }
    }
    
    $summary = Get-ComplianceSummary -Results $frameworkResults
    
    return @{
        Framework = $Framework
        Score = $summary.CompliancePercentage
        Total = $summary.TotalControls
        Pass = $summary.PassCount
        Fail = $summary.FailCount
        Skip = $summary.SkipCount
        Manual = $summary.ManualCount
        Testable = $summary.TestableControls
    }
}

