#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Scope Discovery Script - PowerShell Version
.DESCRIPTION
    Discovers Azure management groups, subscriptions, and their hierarchy.
    Creates consolidated scope data for use in assessment scripts.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Determine script root and output directory
$ScriptDir = Split-Path -Parent $PSCommandPath
$RootDir = Split-Path -Parent $ScriptDir
$OutDir = Join-Path $RootDir "out"

# Create output directory if it doesn't exist
if (-not (Test-Path $OutDir)) {
    New-Item -Path $OutDir -ItemType Directory -Force | Out-Null
}

Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

# Discover tenantId
Write-Host "Discovering tenant information..." -ForegroundColor Yellow
try {
    $TenantId = az account show --query tenantId -o tsv 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($TenantId)) {
        throw "Not logged in or cannot access tenant information"
    }
    Write-Host "  Tenant ID: $TenantId" -ForegroundColor Green
}
catch {
    Write-Error "Failed to get tenant information. Please run .\00_login.ps1 first"
    exit 1
}

# Subscriptions
Write-Host ""
Write-Host "Discovering subscriptions..." -ForegroundColor Yellow
$SubsJsonPath = Join-Path $OutDir "subscriptions.json"

try {
    # Get subscriptions directly into a variable
    $subsOutput = az account list 2>&1
    
    # Check if command succeeded
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Azure CLI command failed with exit code: $LASTEXITCODE"
        Write-Host "Output: $subsOutput" -ForegroundColor Red
        throw "Failed to list subscriptions"
    }
    
    # Try to parse as JSON
    try {
        # Filter out warning lines before parsing
        $jsonLines = $subsOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
        $cleanJson = $jsonLines -join "`n"
        
        $subsData = $cleanJson | ConvertFrom-Json
        
        # Write to file
        $cleanJson | Set-Content -Path $SubsJsonPath -Encoding UTF8
        
        Write-Host "  Found $($subsData.Count) subscription(s)" -ForegroundColor Green
        
        # Show first 3
        $displayCount = [Math]::Min($subsData.Count, 3)
        for ($i = 0; $i -lt $displayCount; $i++) {
            $subName = $subsData[$i].name
            $subState = $subsData[$i].state
            Write-Host "    - $subName ($subState)" -ForegroundColor Gray
        }
        if ($subsData.Count -gt 3) {
            Write-Host "    ... and $($subsData.Count - 3) more" -ForegroundColor Gray
        }
    }
    catch {
        Write-Error "Failed to parse subscription data as JSON"
        Write-Host "Raw output length: $($subsOutput.Length)" -ForegroundColor Yellow
        Write-Host "First 200 characters: $($subsOutput.ToString().Substring(0, [Math]::Min(200, $subsOutput.ToString().Length)))" -ForegroundColor Yellow
        
        # Save raw output for debugging
        $subsOutput | Set-Content -Path (Join-Path $OutDir "subscriptions_raw.txt") -Encoding UTF8
        Write-Host "Raw output saved to: $(Join-Path $OutDir 'subscriptions_raw.txt')" -ForegroundColor Yellow
        throw
    }
}
catch {
    Write-Error "Failed to discover subscriptions: $_"
    "[]" | Set-Content -Path $SubsJsonPath -Encoding UTF8
    exit 1
}

# Management groups
Write-Host ""
Write-Host "Discovering management groups..." -ForegroundColor Yellow
$MgJsonPath = Join-Path $OutDir "management_groups.json"

# Try multiple approaches to get management groups
$mgData = $null
$mgApproaches = @(
    @{ Name = "with --no-register"; Command = "az account management-group list --no-register" },
    @{ Name = "with --refresh"; Command = "az account management-group list --refresh" },
    @{ Name = "without flags"; Command = "az account management-group list" }
)

foreach ($approach in $mgApproaches) {
    Write-Host "  Trying: $($approach.Name)..." -ForegroundColor Gray
    try {
        $mgOutput = Invoke-Expression "$($approach.Command) 2>&1"
        
        if ($LASTEXITCODE -eq 0 -and $mgOutput) {
            try {
                # Filter out warning lines before parsing
                $mgJsonLines = $mgOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $mgCleanJson = $mgJsonLines -join "`n"
                
                $mgParsed = $mgCleanJson | ConvertFrom-Json
                if ($mgParsed -and $mgParsed.Count -gt 0) {
                    $mgData = $mgParsed
                    Write-Host "  [SUCCESS] Found $($mgData.Count) management group(s)" -ForegroundColor Green
                    
                    # Show first 3
                    $displayCount = [Math]::Min($mgData.Count, 3)
                    for ($i = 0; $i -lt $displayCount; $i++) {
                        Write-Host "    - $($mgData[$i].displayName) ($($mgData[$i].name))" -ForegroundColor Gray
                    }
                    if ($mgData.Count -gt 3) {
                        Write-Host "    ... and $($mgData.Count - 3) more" -ForegroundColor Gray
                    }
                    break
                }
            }
            catch {
                # JSON parse failed, continue
            }
        }
    }
    catch {
        # Continue to next approach
    }
}

if ($mgData) {
    $mgData | ConvertTo-Json -Depth 100 | Set-Content -Path $MgJsonPath -Encoding UTF8
}
else {
    "[]" | Set-Content -Path $MgJsonPath -Encoding UTF8
    Write-Host "  [WARNING] No management groups accessible" -ForegroundColor Yellow
    Write-Host "  This could mean:" -ForegroundColor Yellow
    Write-Host "    - You need 'Management Group Reader' role" -ForegroundColor Yellow
    Write-Host "    - Management groups not used in this tenant" -ForegroundColor Yellow
    Write-Host "  Run .\00_diagnostics.ps1 for more details" -ForegroundColor Cyan
}

# Map subscriptions to management groups
Write-Host ""
Write-Host "Mapping subscriptions to management groups..." -ForegroundColor Yellow
$MapJsonPath = Join-Path $OutDir "mg_sub_map.json"
$mappings = @()

# Only try mapping if we have management groups
if ($mgData -and $mgData.Count -gt 0) {
    foreach ($mgObj in $mgData) {
        $mgName = $mgObj.name
        if ([string]::IsNullOrWhiteSpace($mgName)) { continue }
        
        Write-Host "  Checking MG: $mgName..." -ForegroundColor Gray
        
        try {
            # Try to get subscriptions under this MG
            $mgSubs = az account management-group show --name $mgName --expand --recurse --query "children[?type=='Microsoft.Management/managementGroups/subscriptions'].name" -o tsv 2>$null
            
            if ($LASTEXITCODE -eq 0 -and $mgSubs) {
                foreach ($sub in $mgSubs -split "`n") {
                    $sub = $sub.Trim()
                    if ([string]::IsNullOrWhiteSpace($sub)) { continue }
                    $mappings += @{
                        mg = $mgName
                        subscriptionId = $sub
                    }
                }
            }
        }
        catch {
            # Best effort - skip if no permissions for this MG
        }
    }
    
    Write-Host "  Mapped $($mappings.Count) subscription(s) directly" -ForegroundColor Green
}

# Try Resource Graph as alternative if no mappings found
if ($mappings.Count -eq 0 -and $mgData -and $mgData.Count -gt 0) {
    Write-Host "  Trying alternative approach with Resource Graph..." -ForegroundColor Gray
    try {
        $query = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | project subscriptionId, mgAncestors = properties.managementGroupAncestorsChain | mv-expand ancestor = mgAncestors | where ancestor.name != '' | project subscriptionId, mg = tostring(ancestor.name) | distinct subscriptionId, mg"
        $rgOutput = az graph query -q $query --first 1000 2>&1
        
        if ($LASTEXITCODE -eq 0 -and $rgOutput) {
            try {
                # Filter out warning lines before parsing
                $rgJsonLines = $rgOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $rgCleanJson = $rgJsonLines -join "`n"
                
                $rgData = $rgCleanJson | ConvertFrom-Json
                if ($rgData.data -and $rgData.data.Count -gt 0) {
                    foreach ($item in $rgData.data) {
                        if ($item.subscriptionId -and $item.mg) {
                            $mappings += @{
                                mg = $item.mg
                                subscriptionId = $item.subscriptionId
                            }
                        }
                    }
                    Write-Host "  Resource Graph found $($mappings.Count) mappings" -ForegroundColor Green
                }
            }
            catch {
                # Resource Graph parse failed
            }
        }
    }
    catch {
        # Resource Graph might not be available
    }
}

$mappings | ConvertTo-Json -Depth 10 | Set-Content -Path $MapJsonPath -Encoding UTF8
Write-Host "  Total mapped: $($mappings.Count) subscription(s) to management groups" -ForegroundColor Green

# Build consolidated scope file
Write-Host ""
Write-Host "Building consolidated scope file..." -ForegroundColor Yellow
$ScopeJsonPath = Join-Path $OutDir "scope.json"

try {
    # Read subscriptions
    if (-not (Test-Path $SubsJsonPath)) {
        throw "Subscriptions file not found: $SubsJsonPath"
    }
    
    $subsContent = Get-Content $SubsJsonPath -Raw
    if ([string]::IsNullOrWhiteSpace($subsContent)) {
        throw "Subscriptions file is empty"
    }
    
    $subscriptions = $subsContent | ConvertFrom-Json
    
    # Read MG mappings
    $mgMapping = @()
    if (Test-Path $MapJsonPath) {
        $mapContent = Get-Content $MapJsonPath -Raw
        if (-not [string]::IsNullOrWhiteSpace($mapContent) -and $mapContent.Trim() -ne "[]") {
            try {
                $mgMapping = $mapContent | ConvertFrom-Json
            }
            catch {
                Write-Host "  Warning: Could not parse MG mappings" -ForegroundColor Yellow
            }
        }
    }

    # Create lookup dictionary for MG mappings
    $mgLookup = @{}
    foreach ($mapping in $mgMapping) {
        if ($mapping.subscriptionId) {
            # Store first MG found for each subscription (direct parent)
            if (-not $mgLookup.ContainsKey($mapping.subscriptionId)) {
                $mgLookup[$mapping.subscriptionId] = $mapping.mg
            }
        }
    }

    # Build scope array
    $scope = @()
    foreach ($sub in $subscriptions) {
        # Extract subscription ID - az account list returns 'id' field with the subscription ID
        $subId = $null
        
        # Try different possible field names
        if ($sub.id) { 
            $subId = $sub.id 
            # If it's a full resource ID path, extract just the subscription ID
            if ($subId -match "/subscriptions/([a-f0-9\-]{36})") {
                $subId = $matches[1]
            }
        }
        if (-not $subId -and $sub.subscriptionId) { $subId = $sub.subscriptionId }
        if (-not $subId -and $sub.subscription_id) { $subId = $sub.subscription_id }
        
        # Skip if we don't have a valid subscription ID or if it's a tenant ID
        if (-not $subId -or $subId -eq $TenantId) {
            Write-Host "  Warning: Skipping invalid entry (no valid subscription ID)" -ForegroundColor Yellow
            continue
        }
        
        # Get display name
        $displayName = $sub.name
        if (-not $displayName) { $displayName = $sub.displayName }
        if (-not $displayName) { $displayName = $subId }
        
        # Get management group from lookup
        $mgName = $mgLookup[$subId]
        
        $scope += @{
            subscriptionId = $subId
            displayName = $displayName
            state = $sub.state
            managementGroup = $mgName
        }
    }

    $scope | ConvertTo-Json -Depth 10 | Set-Content -Path $ScopeJsonPath -Encoding UTF8
    Write-Host "  Wrote scope file: $ScopeJsonPath" -ForegroundColor Green
    Write-Host "  Total subscriptions in scope: $($scope.Count)" -ForegroundColor Green

    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Scope discovery complete!" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "Output files:" -ForegroundColor White
    Write-Host "  - $MgJsonPath" -ForegroundColor Gray
    Write-Host "  - $SubsJsonPath" -ForegroundColor Gray
    Write-Host "  - $MapJsonPath" -ForegroundColor Gray
    Write-Host "  - $ScopeJsonPath" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Error "Failed to build consolidated scope file: $_"
    Write-Host ""
    Write-Host "Debugging information:" -ForegroundColor Yellow
    Write-Host "  Check the files in: $OutDir" -ForegroundColor Yellow
    Write-Host "  Run .\00_diagnostics.ps1 to verify permissions" -ForegroundColor Cyan
    exit 1
}
