#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Resource Inventory Script - PowerShell Version
.DESCRIPTION
    Collects comprehensive resource inventory across all subscriptions in scope.
    Includes resource groups, resources, and resource type counts.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Determine paths
$ScriptDir = Split-Path -Parent $PSCommandPath
$RootDir = Split-Path -Parent $ScriptDir
$OutDir = Join-Path $RootDir "out"
$ScopePath = Join-Path $OutDir "scope.json"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Azure Resource Inventory" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verify scope file exists
if (-not (Test-Path $ScopePath)) {
    Write-Error "Missing scope.json. Please run .\01_scope_discovery.ps1 first."
    exit 1
}

# Load scope
Write-Host "Loading scope file..." -ForegroundColor Yellow
try {
    $scopeContent = Get-Content $ScopePath -Raw
    $scope = $scopeContent | ConvertFrom-Json
    Write-Host "  Loaded $($scope.Count) subscription(s) from scope" -ForegroundColor Green
}
catch {
    Write-Error "Failed to parse scope.json: $_"
    exit 1
}

Write-Host ""

# Initialize counters
$successCount = 0
$errorCount = 0
$totalResources = 0
$totalResourceGroups = 0

# Process each subscription
$counter = 0
foreach ($s in $scope) {
    $counter++
    $sub = $s.subscriptionId
    if (-not $sub) { 
        Write-Host "[$counter/$($scope.Count)] Skipping entry with no subscription ID" -ForegroundColor Gray
        continue 
    }
    
    $displayName = $s.displayName
    if (-not $displayName) { $displayName = $sub }
    
    Write-Host "[$counter/$($scope.Count)] Processing: $displayName" -ForegroundColor Cyan
    Write-Host "  Subscription ID: $sub" -ForegroundColor Gray
    
    # Skip disabled subscriptions
    if ($s.state -ne "Enabled") {
        Write-Host "  [SKIPPED] Subscription state: $($s.state)" -ForegroundColor Yellow
        continue
    }
    
    try {
        # Collect Resource Groups
        Write-Host "  Collecting resource groups..." -ForegroundColor Yellow
        $rgOutput = az group list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $rgOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $rgs = $cleanJson | ConvertFrom-Json
                $rgCount = if ($rgs) { $rgs.Count } else { 0 }
                $totalResourceGroups += $rgCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_rgs.json") -Encoding UTF8
                Write-Host "    [OK] Found $rgCount resource group(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse resource groups: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_rgs.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list resource groups" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_rgs.json") -Encoding UTF8
        }
        
        # Collect Resources
        Write-Host "  Collecting resources..." -ForegroundColor Yellow
        $resourceOutput = az resource list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $resJsonLines = $resourceOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $resCleanJson = $resJsonLines -join "`n"
                
                $resources = $resCleanJson | ConvertFrom-Json
                $resourceCount = if ($resources) { $resources.Count } else { 0 }
                $totalResources += $resourceCount
                
                $resCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_resources.json") -Encoding UTF8
                Write-Host "    [OK] Found $resourceCount resource(s)" -ForegroundColor Green
                
                # Calculate resource type counts
                Write-Host "  Calculating resource type distribution..." -ForegroundColor Yellow
                $typeCounts = @{}
                foreach ($resource in $resources) {
                    $type = $resource.type
                    if ($type) {
                        if ($typeCounts.ContainsKey($type)) {
                            $typeCounts[$type]++
                        }
                        else {
                            $typeCounts[$type] = 1
                        }
                    }
                }
                
                # Convert to sorted array for better readability
                $typeCountArray = @()
                foreach ($key in $typeCounts.Keys | Sort-Object) {
                    $typeCountArray += @{
                        resourceType = $key
                        count = $typeCounts[$key]
                    }
                }
                
                $typeCountArray | ConvertTo-Json -Depth 5 | Set-Content -Path (Join-Path $OutDir "$sub`_resource_type_counts.json") -Encoding UTF8
                
                # Show top 5 resource types
                $topTypes = $typeCountArray | Sort-Object -Property count -Descending | Select-Object -First 5
                if ($topTypes.Count -gt 0) {
                    Write-Host "    Top resource types:" -ForegroundColor Gray
                    foreach ($t in $topTypes) {
                        Write-Host "      - $($t.resourceType): $($t.count)" -ForegroundColor Gray
                    }
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse resources" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_resources.json") -Encoding UTF8
                "{}" | Set-Content -Path (Join-Path $OutDir "$sub`_resource_type_counts.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list resources" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_resources.json") -Encoding UTF8
            "{}" | Set-Content -Path (Join-Path $OutDir "$sub`_resource_type_counts.json") -Encoding UTF8
        }
        
        $successCount++
        Write-Host "  [COMPLETE]" -ForegroundColor Green
    }
    catch {
        Write-Host "  [ERROR] Failed to process subscription: $_" -ForegroundColor Red
        $errorCount++
    }
    
    Write-Host ""
}

# Summary
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Inventory Collection Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total resource groups: $totalResourceGroups" -ForegroundColor White
Write-Host "  Total resources: $totalResources" -ForegroundColor White
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] Inventory collection complete!" -ForegroundColor Green
    Write-Host "Files created: *_rgs.json, *_resources.json, *_resource_type_counts.json" -ForegroundColor Gray
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}
