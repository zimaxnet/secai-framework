#Requires -Version 5.1
<#
.SYNOPSIS
    Azure RBAC Assessment with SSL Bypass
.DESCRIPTION
    Collects RBAC role assignments with SSL verification disabled for corporate proxy environments.
    WARNING: Only use in trusted corporate networks.
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
Write-Host "RBAC Assessment (SSL Bypass Enabled)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[WARNING] SSL certificate verification is DISABLED" -ForegroundColor Yellow
Write-Host "[WARNING] Only use this in trusted corporate networks" -ForegroundColor Yellow
Write-Host ""

# Disable SSL verification for Azure CLI
$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = "1"
Write-Host "[INFO] Set AZURE_CLI_DISABLE_CONNECTION_VERIFICATION=1" -ForegroundColor Yellow
Write-Host ""

# Verify scope file exists
if (-not (Test-Path $ScopePath)) {
    Write-Error "Missing scope.json. Please run .\01_scope_discovery.ps1 first."
    exit 1
}

# Test connectivity first
Write-Host "Testing Azure connectivity..." -ForegroundColor Yellow
try {
    $testResult = az account show 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Azure Resource Manager API accessible" -ForegroundColor Green
    }
    else {
        Write-Host "  [ERROR] Cannot connect to Azure. Check login status." -ForegroundColor Red
        Write-Host "  Run: .\00_login.ps1" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host "  [ERROR] Azure CLI connectivity test failed" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Helper function to filter out warnings from Azure CLI output
function Get-JsonFromOutput {
    param([string[]]$output)
    
    # Find the first line that starts with [ or {
    $jsonStartIndex = -1
    for ($i = 0; $i -lt $output.Length; $i++) {
        if ($output[$i] -match '^\s*[\[\{]') {
            $jsonStartIndex = $i
            break
        }
    }
    
    if ($jsonStartIndex -ge 0) {
        # Return lines from JSON start to end
        return $output[$jsonStartIndex..($output.Length - 1)] -join "`n"
    }
    
    return $null
}

# Try to collect Azure AD data with SSL bypass
Write-Host "Attempting Azure AD data collection (with SSL bypass)..." -ForegroundColor Yellow
try {
    $appOutput = az ad app list 2>&1
    if ($LASTEXITCODE -eq 0) {
        try {
            # Filter out warnings and extract JSON
            $jsonContent = Get-JsonFromOutput -output $appOutput
            if ($jsonContent) {
                $apps = $jsonContent | ConvertFrom-Json
                $jsonContent | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
                Write-Host "  [OK] Found $($apps.Count) application(s)" -ForegroundColor Green
            }
            else {
                Write-Host "  [WARN] No JSON found in output" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
            }
        }
        catch {
            Write-Host "  [WARN] Could not parse applications: $_" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
        }
    }
    else {
        Write-Host "  [WARN] Failed to retrieve applications" -ForegroundColor Yellow
        "[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
    }
}
catch {
    Write-Host "  [WARN] Exception retrieving applications: $_" -ForegroundColor Yellow
    "[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
}

Write-Host ""
Write-Host "Attempting service principals collection (with SSL bypass)..." -ForegroundColor Yellow
try {
    $spOutput = az ad sp list --all 2>&1
    if ($LASTEXITCODE -eq 0) {
        try {
            # Filter out warnings and extract JSON
            $jsonContent = Get-JsonFromOutput -output $spOutput
            if ($jsonContent) {
                $sps = $jsonContent | ConvertFrom-Json
                $jsonContent | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
                Write-Host "  [OK] Found $($sps.Count) service principal(s)" -ForegroundColor Green
            }
            else {
                Write-Host "  [WARN] No JSON found in output" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
            }
        }
        catch {
            Write-Host "  [WARN] Could not parse service principals: $_" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
        }
    }
    else {
        Write-Host "  [WARN] Failed to retrieve service principals" -ForegroundColor Yellow
        "[]" | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
    }
}
catch {
    Write-Host "  [WARN] Exception retrieving service principals: $_" -ForegroundColor Yellow
    "[]" | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
}

Write-Host ""

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
$totalRoleAssignments = 0

# Process each subscription for RBAC
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
        # Role Assignments
        Write-Host "  Collecting RBAC role assignments..." -ForegroundColor Yellow
        $rbacOutput = az role assignment list --subscription $sub --all 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warnings and extract JSON
                $jsonContent = Get-JsonFromOutput -output $rbacOutput
                if ($jsonContent) {
                    $roleAssignments = $jsonContent | ConvertFrom-Json
                    $assignCount = $roleAssignments.Count
                    $totalRoleAssignments += $assignCount
                    
                    $jsonContent | Set-Content -Path (Join-Path $OutDir "$sub`_role_assignments.json") -Encoding UTF8
                    Write-Host "    [OK] Found $assignCount role assignment(s)" -ForegroundColor Green
                    
                    # Show breakdown by role type
                    $ownerCount = ($roleAssignments | Where-Object { $_.roleDefinitionName -eq "Owner" }).Count
                    $contributorCount = ($roleAssignments | Where-Object { $_.roleDefinitionName -eq "Contributor" }).Count
                    $readerCount = ($roleAssignments | Where-Object { $_.roleDefinitionName -eq "Reader" }).Count
                    
                    if ($ownerCount -gt 0 -or $contributorCount -gt 0) {
                        Write-Host "      Owner: $ownerCount, Contributor: $contributorCount, Reader: $readerCount" -ForegroundColor Gray
                    }
                }
                else {
                    Write-Host "    [WARN] No JSON found in output" -ForegroundColor Yellow
                    "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_role_assignments.json") -Encoding UTF8
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse role assignments: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_role_assignments.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list role assignments" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_role_assignments.json") -Encoding UTF8
            $errorCount++
        }
        
        if ($LASTEXITCODE -eq 0) {
            $successCount++
        }
        
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
Write-Host "RBAC Assessment Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total role assignments: $totalRoleAssignments" -ForegroundColor White
Write-Host ""
Write-Host "  [NOTE] SSL verification was DISABLED" -ForegroundColor Yellow
Write-Host "  [NOTE] Only use this approach in trusted networks" -ForegroundColor Yellow
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] RBAC assessment complete!" -ForegroundColor Green
}
else {
    Write-Host "[ERROR] No subscriptions were successfully processed" -ForegroundColor Red
    Write-Host "Please check permissions and connectivity" -ForegroundColor Yellow
}

# Clean up environment variable
Write-Host ""
Write-Host "Cleaning up SSL bypass setting..." -ForegroundColor Gray
Remove-Item Env:\AZURE_CLI_DISABLE_CONNECTION_VERIFICATION -ErrorAction SilentlyContinue

