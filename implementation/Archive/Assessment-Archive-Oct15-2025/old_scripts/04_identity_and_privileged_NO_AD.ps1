#Requires -Version 5.1
<#
.SYNOPSIS
    Azure RBAC Assessment (No Azure AD Queries)
.DESCRIPTION
    Collects RBAC role assignments without querying Azure AD (avoids Graph API SSL issues).
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
Write-Host "RBAC Assessment (AD Queries Skipped)" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[INFO] Skipping Azure AD app/SP queries due to proxy SSL issues" -ForegroundColor Yellow
Write-Host "[INFO] Collecting RBAC role assignments only" -ForegroundColor Yellow
Write-Host ""

# Verify scope file exists
if (-not (Test-Path $ScopePath)) {
    Write-Error "Missing scope.json. Please run .\01_scope_discovery.ps1 first."
    exit 1
}

# Create placeholder files for skipped data
Write-Host "Creating placeholder files for skipped Azure AD data..." -ForegroundColor Yellow
"[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
"[]" | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
Write-Host "  Skipped: tenant_applications.json" -ForegroundColor Gray
Write-Host "  Skipped: tenant_service_principals.json" -ForegroundColor Gray
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
        # Role Assignments - using --include-inherited to get more data without Graph lookups
        Write-Host "  Collecting RBAC role assignments..." -ForegroundColor Yellow
        
        # Use basic query without Graph API resolution
        $rbacOutput = az role assignment list --subscription $sub --include-inherited 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                $roleAssignments = $rbacOutput | ConvertFrom-Json
                $assignCount = $roleAssignments.Count
                $totalRoleAssignments += $assignCount
                
                $rbacOutput | Set-Content -Path (Join-Path $OutDir "$sub`_role_assignments.json") -Encoding UTF8
                Write-Host "    [OK] Found $assignCount role assignment(s)" -ForegroundColor Green
                
                # Show breakdown by role type
                $ownerCount = ($roleAssignments | Where-Object { $_.roleDefinitionName -eq "Owner" }).Count
                $contributorCount = ($roleAssignments | Where-Object { $_.roleDefinitionName -eq "Contributor" }).Count
                $readerCount = ($roleAssignments | Where-Object { $_.roleDefinitionName -eq "Reader" }).Count
                
                if ($ownerCount -gt 0 -or $contributorCount -gt 0) {
                    Write-Host "      Owner: $ownerCount, Contributor: $contributorCount, Reader: $readerCount" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse role assignments" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_role_assignments.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list role assignments" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_role_assignments.json") -Encoding UTF8
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
Write-Host "RBAC Assessment Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total role assignments: $totalRoleAssignments" -ForegroundColor White
Write-Host ""
Write-Host "  [NOTE] Azure AD data skipped due to SSL/proxy issues" -ForegroundColor Yellow
Write-Host "  [NOTE] Principal names in RBAC may show as GUIDs" -ForegroundColor Yellow
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] RBAC assessment complete!" -ForegroundColor Green
    Write-Host "Files created: *_role_assignments.json (AD queries skipped)" -ForegroundColor Gray
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "To resolve SSL issues for future runs:" -ForegroundColor Cyan
Write-Host "  1. Contact IT to add Azure CLI cert to trusted store" -ForegroundColor White
Write-Host "  2. Or set: `$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = '1'" -ForegroundColor White

