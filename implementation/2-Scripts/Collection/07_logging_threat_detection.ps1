#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Logging and Threat Detection Assessment
.DESCRIPTION
    Collects Log Analytics workspaces, diagnostic settings, and security monitoring configurations.
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
Write-Host "Logging & Threat Detection Assessment" -ForegroundColor Cyan
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

# Skip Sentinel checks (not deployed in this environment)
Write-Host "Skipping Microsoft Sentinel checks (not deployed)" -ForegroundColor Gray
$sentinelExists = $false
Write-Host ""

# Initialize counters
$successCount = 0
$errorCount = 0
$totalLAWorkspaces = 0
$totalDiagSettings = 0
$sentinelEnabledCount = 0

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
        # Log Analytics Workspaces
        Write-Host "  Collecting Log Analytics workspaces..." -ForegroundColor Yellow
        $laOutput = az monitor log-analytics workspace list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $laOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $workspaces = $cleanJson | ConvertFrom-Json
                $laCount = if ($workspaces) { $workspaces.Count } else { 0 }
                $totalLAWorkspaces += $laCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_la_workspaces.json") -Encoding UTF8
                Write-Host "    [OK] Found $laCount Log Analytics workspace(s)" -ForegroundColor Green
                
                # Check for Sentinel (only if detected at tenant level)
                if ($sentinelExists -and $laCount -gt 0) {
                    Write-Host "  Checking for Microsoft Sentinel..." -ForegroundColor Yellow
                    $hasSentinel = $false
                    
                    foreach ($workspace in $workspaces) {
                        $wsName = $workspace.name
                        $rgName = $workspace.resourceGroup
                        
                        # Try to get Sentinel data connectors as indicator
                        $sentinelCheck = az resource list --resource-group $rgName --resource-type "Microsoft.OperationalInsights/workspaces/providers/dataConnectors" --query "[?contains(id, '$wsName')]" 2>&1
                        
                        if ($LASTEXITCODE -eq 0) {
                            try {
                                # Filter out warning lines before parsing
                                $sentJsonLines = $sentinelCheck | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                                $sentCleanJson = $sentJsonLines -join "`n"
                                
                                $connectors = $sentCleanJson | ConvertFrom-Json
                                if ($connectors -and $connectors.Count -gt 0) {
                                    $hasSentinel = $true
                                    break
                                }
                            }
                            catch {
                                # Continue checking
                            }
                        }
                    }
                    
                    if ($hasSentinel) {
                        $sentinelEnabledCount++
                        Write-Host "    [OK] Microsoft Sentinel detected" -ForegroundColor Green
                    }
                    else {
                        Write-Host "    [OK] No Sentinel deployment detected" -ForegroundColor Gray
                    }
                    
                    # Save placeholder for Sentinel data
                    @{detected = $hasSentinel} | ConvertTo-Json | Set-Content -Path (Join-Path $OutDir "$sub`_sentinel.json") -Encoding UTF8
                }
                else {
                    # Sentinel not in tenant or no workspaces - skip check
                    "{}" | Set-Content -Path (Join-Path $OutDir "$sub`_sentinel.json") -Encoding UTF8
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse Log Analytics workspaces" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_la_workspaces.json") -Encoding UTF8
                "{}" | Set-Content -Path (Join-Path $OutDir "$sub`_sentinel.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list Log Analytics workspaces" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_la_workspaces.json") -Encoding UTF8
            "{}" | Set-Content -Path (Join-Path $OutDir "$sub`_sentinel.json") -Encoding UTF8
        }
        
        # Subscription-level Diagnostic Settings
        Write-Host "  Collecting diagnostic settings..." -ForegroundColor Yellow
        $diagOutput = az monitor diagnostic-settings subscription list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $diagJsonLines = $diagOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $diagCleanJson = $diagJsonLines -join "`n"
                
                $diagSettings = $diagCleanJson | ConvertFrom-Json
                
                # Handle both array and object with value property
                $diagCount = 0
                if ($diagSettings -is [array]) {
                    $diagCount = $diagSettings.Count
                }
                elseif ($diagSettings.value) {
                    $diagCount = $diagSettings.value.Count
                }
                
                $totalDiagSettings += $diagCount
                
                $diagCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_subscription_diag.json") -Encoding UTF8
                
                if ($diagCount -gt 0) {
                    Write-Host "    [OK] Found $diagCount diagnostic setting(s)" -ForegroundColor Green
                }
                else {
                    Write-Host "    [OK] No subscription diagnostic settings configured" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse diagnostic settings" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_subscription_diag.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to retrieve diagnostic settings" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_subscription_diag.json") -Encoding UTF8
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
Write-Host "Logging & Threat Detection Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total Log Analytics workspaces: $totalLAWorkspaces" -ForegroundColor White
Write-Host "  Subscriptions with Sentinel: $sentinelEnabledCount" -ForegroundColor White
Write-Host "  Total diagnostic settings: $totalDiagSettings" -ForegroundColor White
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] Logging and threat detection assessment complete!" -ForegroundColor Green
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}
