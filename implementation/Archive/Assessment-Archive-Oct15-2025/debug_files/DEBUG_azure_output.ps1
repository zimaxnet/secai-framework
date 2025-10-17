#Requires -Version 5.1
<#
.SYNOPSIS
    Debug Azure CLI Output
.DESCRIPTION
    Tests Azure CLI commands and shows raw output for troubleshooting.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Enable SSL bypass
$env:AZURE_CLI_DISABLE_CONNECTION_VERIFICATION = "1"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Azure CLI Output Diagnostic" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Azure AD Applications
Write-Host "[TEST 1] Azure AD Applications" -ForegroundColor Yellow
Write-Host "Running: az ad app list --query '[0:2]'" -ForegroundColor Gray
Write-Host ""

$appOutput = az ad app list --query '[0:2]' 2>&1
Write-Host "Exit Code: $LASTEXITCODE" -ForegroundColor Cyan
Write-Host "Output Type: $($appOutput.GetType().Name)" -ForegroundColor Cyan
Write-Host "Output Length: $($appOutput.Length)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Raw Output:" -ForegroundColor Cyan
Write-Host "---START---" -ForegroundColor Gray
$appOutput | ForEach-Object { Write-Host $_ }
Write-Host "---END---" -ForegroundColor Gray
Write-Host ""

# Try to parse
Write-Host "Attempting to parse as JSON..." -ForegroundColor Yellow
try {
    $parsed = $appOutput | ConvertFrom-Json
    Write-Host "[SUCCESS] Parsed successfully" -ForegroundColor Green
    Write-Host "  Type: $($parsed.GetType().Name)" -ForegroundColor Gray
    Write-Host "  Count: $(if ($parsed.Count) { $parsed.Count } else { 'N/A' })" -ForegroundColor Gray
}
catch {
    Write-Host "[FAILED] Could not parse" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Test 2: RBAC Role Assignments
Write-Host "[TEST 2] RBAC Role Assignments" -ForegroundColor Yellow
Write-Host "Running: az role assignment list --subscription b4b038e8-a1c2-499f-b440-2a244d40cd2c --query '[0:2]'" -ForegroundColor Gray
Write-Host ""

$rbacOutput = az role assignment list --subscription b4b038e8-a1c2-499f-b440-2a244d40cd2c --query '[0:2]' 2>&1
Write-Host "Exit Code: $LASTEXITCODE" -ForegroundColor Cyan
Write-Host "Output Type: $($rbacOutput.GetType().Name)" -ForegroundColor Cyan
Write-Host "Output Length: $($rbacOutput.Length)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Raw Output:" -ForegroundColor Cyan
Write-Host "---START---" -ForegroundColor Gray
$rbacOutput | ForEach-Object { Write-Host $_ }
Write-Host "---END---" -ForegroundColor Gray
Write-Host ""

# Try to parse
Write-Host "Attempting to parse as JSON..." -ForegroundColor Yellow
try {
    $parsed = $rbacOutput | ConvertFrom-Json
    Write-Host "[SUCCESS] Parsed successfully" -ForegroundColor Green
    Write-Host "  Type: $($parsed.GetType().Name)" -ForegroundColor Gray
    Write-Host "  Count: $(if ($parsed.Count) { $parsed.Count } else { 'N/A' })" -ForegroundColor Gray
}
catch {
    Write-Host "[FAILED] Could not parse" -ForegroundColor Red
    Write-Host "  Error: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Test 3: Check if output contains non-JSON text
Write-Host "[TEST 3] Check for Mixed Output" -ForegroundColor Yellow
$testOutput = az account show 2>&1
Write-Host "First line of 'az account show':" -ForegroundColor Gray
Write-Host "  $($testOutput[0])" -ForegroundColor White
Write-Host ""

if ($testOutput[0] -match "^[\{\[]") {
    Write-Host "[OK] Output starts with JSON character" -ForegroundColor Green
}
else {
    Write-Host "[WARN] Output does NOT start with JSON character" -ForegroundColor Yellow
    Write-Host "  This suggests warnings/errors are being mixed into output" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Diagnostic Complete" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Cleanup
Remove-Item Env:\AZURE_CLI_DISABLE_CONNECTION_VERIFICATION -ErrorAction SilentlyContinue

