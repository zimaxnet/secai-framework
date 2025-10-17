#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Identity and Privileged Access Assessment
.DESCRIPTION
    Collects Azure AD applications, service principals, and RBAC role assignments.
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
Write-Host "Identity & Privileged Access Assessment" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Verify scope file exists
if (-not (Test-Path $ScopePath)) {
    Write-Error "Missing scope.json. Please run .\01_scope_discovery.ps1 first."
    exit 1
}

# Collect tenant-wide Azure AD data (once)
Write-Host "Collecting Azure AD applications (tenant-wide)..." -ForegroundColor Yellow
Write-Host "  [WARNING] This may take several minutes for large tenants" -ForegroundColor Yellow
try {
    $appOutput = az ad app list 2>&1
    if ($LASTEXITCODE -eq 0) {
        try {
            $apps = $appOutput | ConvertFrom-Json
            $appOutput | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
            Write-Host "  [OK] Found $($apps.Count) application(s)" -ForegroundColor Green
        }
        catch {
            Write-Host "  [WARN] Could not parse applications" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
        }
    }
    else {
        Write-Host "  [ERROR] Failed to retrieve applications (may need Azure AD read permissions)" -ForegroundColor Red
        "[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
    }
}
catch {
    Write-Host "  [ERROR] Exception: $_" -ForegroundColor Red
    "[]" | Set-Content -Path (Join-Path $OutDir "tenant_applications.json") -Encoding UTF8
}

Write-Host ""
Write-Host "Collecting service principals (tenant-wide)..." -ForegroundColor Yellow
Write-Host "  [WARNING] This may take several minutes for large tenants" -ForegroundColor Yellow
try {
    $spOutput = az ad sp list --all 2>&1
    if ($LASTEXITCODE -eq 0) {
        try {
            $sps = $spOutput | ConvertFrom-Json
            $spOutput | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
            Write-Host "  [OK] Found $($sps.Count) service principal(s)" -ForegroundColor Green
        }
        catch {
            Write-Host "  [WARN] Could not parse service principals" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
        }
    }
    else {
        Write-Host "  [ERROR] Failed to retrieve service principals (may need Azure AD read permissions)" -ForegroundColor Red
        "[]" | Set-Content -Path (Join-Path $OutDir "tenant_service_principals.json") -Encoding UTF8
    }
}
catch {
    Write-Host "  [ERROR] Exception: $_" -ForegroundColor Red
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
Write-Host "Identity & Access Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total role assignments: $totalRoleAssignments" -ForegroundColor White
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] Identity and access assessment complete!" -ForegroundColor Green
    Write-Host "Files created: tenant_applications.json, tenant_service_principals.json, *_role_assignments.json" -ForegroundColor Gray
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}
