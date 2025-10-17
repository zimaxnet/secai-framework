#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Backup and Recovery Assessment
.DESCRIPTION
    Collects Recovery Services vaults and backup policies.
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
Write-Host "Backup & Recovery Assessment" -ForegroundColor Cyan
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
$totalVaults = 0
$totalPolicies = 0

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
        # Recovery Services Vaults
        Write-Host "  Collecting Recovery Services vaults..." -ForegroundColor Yellow
        $vaultOutput = az backup vault list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $vaultOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $vaults = $cleanJson | ConvertFrom-Json
                $vaultCount = if ($vaults) { $vaults.Count } else { 0 }
                $totalVaults += $vaultCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_recovery_vaults.json") -Encoding UTF8
                Write-Host "    [OK] Found $vaultCount Recovery Services vault(s)" -ForegroundColor Green
                
                # Backup Policies (collect per vault - CRITICAL FIX)
                if ($vaultCount -gt 0) {
                    Write-Host "  Collecting backup policies..." -ForegroundColor Yellow
                    $allPolicies = @()
                    
                    foreach ($vault in $vaults) {
                        $vaultName = $vault.name
                        $rgName = $vault.resourceGroup
                        
                        Write-Host "    Querying policies in vault: $vaultName..." -ForegroundColor Gray
                        $policyOutput = az backup policy list --resource-group $rgName --vault-name $vaultName 2>&1
                        
                        if ($LASTEXITCODE -eq 0) {
                            try {
                                # Filter out warning lines before parsing
                                $policyJsonLines = $policyOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                                $policyCleanJson = $policyJsonLines -join "`n"
                                
                                $policies = $policyCleanJson | ConvertFrom-Json
                                # Add vault context to each policy
                                if ($policies) {
                                    foreach ($policy in $policies) {
                                        $policy | Add-Member -NotePropertyName "vaultName" -NotePropertyValue $vaultName -Force
                                        $policy | Add-Member -NotePropertyName "vaultResourceGroup" -NotePropertyValue $rgName -Force
                                    }
                                    $allPolicies += $policies
                                }
                            }
                            catch {
                                Write-Host "      [WARN] Could not parse policies for $vaultName : $_" -ForegroundColor Yellow
                            }
                        }
                        else {
                            Write-Host "      [WARN] Failed to retrieve policies for $vaultName" -ForegroundColor Yellow
                        }
                    }
                    
                    $policyCount = $allPolicies.Count
                    $totalPolicies += $policyCount
                    
                    if ($allPolicies.Count -gt 0) {
                        $allPolicies | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $OutDir "$sub`_backup_policies.json") -Encoding UTF8
                    }
                    else {
                        "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_backup_policies.json") -Encoding UTF8
                    }
                    
                    Write-Host "    [OK] Found $policyCount backup polic(ies) total" -ForegroundColor Green
                }
                else {
                    "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_backup_policies.json") -Encoding UTF8
                    Write-Host "    [OK] No Recovery vaults, skipping policy collection" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse Recovery vaults" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_recovery_vaults.json") -Encoding UTF8
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_backup_policies.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to list Recovery vaults" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_recovery_vaults.json") -Encoding UTF8
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_backup_policies.json") -Encoding UTF8
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
Write-Host "Backup & Recovery Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total Recovery Services vaults: $totalVaults" -ForegroundColor White
Write-Host "  Total backup policies: $totalPolicies" -ForegroundColor White
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] Backup and recovery assessment complete!" -ForegroundColor Green
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}
