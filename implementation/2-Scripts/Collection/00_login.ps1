#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Login Script - PowerShell Version
.DESCRIPTION
    Performs interactive Azure CLI login and configures output format.
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

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Azure CLI Login" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Interactive login (opens browser)
Write-Host "Opening browser for authentication..." -ForegroundColor Yellow
az login | Out-Null

if ($LASTEXITCODE -ne 0) {
    Write-Error "Login failed. Please try again."
    exit 1
}

# Set output to json for consistency
az config set core.output=json 2>$null | Out-Null

# Display tenant information
$TenantId = az account show --query tenantId -o tsv
$AccountName = az account show --query user.name -o tsv
$SubscriptionName = az account show --query name -o tsv

Write-Host ""
Write-Host "Login successful!" -ForegroundColor Green
Write-Host "  Tenant ID: $TenantId" -ForegroundColor White
Write-Host "  Account: $AccountName" -ForegroundColor White
Write-Host "  Default Subscription: $SubscriptionName" -ForegroundColor White
Write-Host ""
Write-Host "Ready to run assessment scripts." -ForegroundColor Cyan

