#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Data Protection Assessment
.DESCRIPTION
    Collects data protection configurations including storage accounts, Key Vaults, and SQL databases.
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
Write-Host "Data Protection Assessment" -ForegroundColor Cyan
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
$totalStorageAccounts = 0
$totalKeyVaults = 0
$totalSQLServers = 0
$totalSQLDatabases = 0

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
        # Storage Accounts
        Write-Host "  Collecting storage accounts..." -ForegroundColor Yellow
        $storageOutput = az storage account list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $storageOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $storageAccounts = $cleanJson | ConvertFrom-Json
                $storageCount = if ($storageAccounts) { $storageAccounts.Count } else { 0 }
                $totalStorageAccounts += $storageCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_storage.json") -Encoding UTF8
                Write-Host "    [OK] Found $storageCount storage account(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse storage accounts: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_storage.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list storage accounts" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_storage.json") -Encoding UTF8
        }
        
        # Key Vaults
        Write-Host "  Collecting Key Vaults..." -ForegroundColor Yellow
        $kvOutput = az keyvault list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $kvOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $keyVaults = $cleanJson | ConvertFrom-Json
                $kvCount = if ($keyVaults) { $keyVaults.Count } else { 0 }
                $totalKeyVaults += $kvCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_keyvaults.json") -Encoding UTF8
                Write-Host "    [OK] Found $kvCount Key Vault(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse Key Vaults: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_keyvaults.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list Key Vaults" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_keyvaults.json") -Encoding UTF8
        }
        
        # SQL Servers
        Write-Host "  Collecting SQL servers..." -ForegroundColor Yellow
        $sqlServerOutput = az sql server list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $sqlServerOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $sqlServers = $cleanJson | ConvertFrom-Json
                $sqlServerCount = if ($sqlServers) { $sqlServers.Count } else { 0 }
                $totalSQLServers += $sqlServerCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_sql_servers.json") -Encoding UTF8
                Write-Host "    [OK] Found $sqlServerCount SQL server(s)" -ForegroundColor Green
                
                # SQL Databases (collect per server - CRITICAL FIX)
                if ($sqlServerCount -gt 0) {
                    Write-Host "  Collecting SQL databases..." -ForegroundColor Yellow
                    $allDatabases = @()
                    
                    foreach ($server in $sqlServers) {
                        $serverName = $server.name
                        $rgName = $server.resourceGroup
                        
                        Write-Host "    Querying databases on server: $serverName..." -ForegroundColor Gray
                        $dbOutput = az sql db list --subscription $sub --resource-group $rgName --server $serverName 2>&1
                        
                        if ($LASTEXITCODE -eq 0) {
                            try {
                                # Filter out warning lines before parsing
                                $dbJsonLines = $dbOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                                $dbCleanJson = $dbJsonLines -join "`n"
                                
                                $databases = $dbCleanJson | ConvertFrom-Json
                                $allDatabases += $databases
                            }
                            catch {
                                Write-Host "      [WARN] Could not parse databases for $serverName : $_" -ForegroundColor Yellow
                            }
                        }
                    }
                    
                    $dbCount = $allDatabases.Count
                    $totalSQLDatabases += $dbCount
                    $allDatabases | ConvertTo-Json -Depth 10 | Set-Content -Path (Join-Path $OutDir "$sub`_sql_dbs.json") -Encoding UTF8
                    Write-Host "    [OK] Found $dbCount SQL database(s) total" -ForegroundColor Green
                }
                else {
                    "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_sql_dbs.json") -Encoding UTF8
                    Write-Host "    [OK] No SQL servers, skipping database collection" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse SQL servers: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_sql_servers.json") -Encoding UTF8
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_sql_dbs.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to list SQL servers" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_sql_servers.json") -Encoding UTF8
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_sql_dbs.json") -Encoding UTF8
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
Write-Host "Data Protection Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total storage accounts: $totalStorageAccounts" -ForegroundColor White
Write-Host "  Total Key Vaults: $totalKeyVaults" -ForegroundColor White
Write-Host "  Total SQL servers: $totalSQLServers" -ForegroundColor White
Write-Host "  Total SQL databases: $totalSQLDatabases" -ForegroundColor White
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] Data protection assessment complete!" -ForegroundColor Green
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}
