#Requires -Version 5.1
<#
.SYNOPSIS
    Check Scope.json File
.DESCRIPTION
    Displays the content and structure of scope.json to diagnose issues
#>

$ScriptDir = Split-Path -Parent $PSCommandPath
$RootDir = Split-Path -Parent $ScriptDir
$OutDir = Join-Path $RootDir "out"
$ScopePath = Join-Path $OutDir "scope.json"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Scope File Diagnostic" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $ScopePath)) {
    Write-Error "Scope file not found: $ScopePath"
    exit 1
}

Write-Host "Reading scope file: $ScopePath" -ForegroundColor Yellow
Write-Host ""

try {
    $scopeContent = Get-Content $ScopePath -Raw
    $scope = $scopeContent | ConvertFrom-Json
    
    Write-Host "Total entries: $($scope.Count)" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "First 3 entries:" -ForegroundColor Yellow
    Write-Host ""
    
    $displayCount = [Math]::Min($scope.Count, 3)
    for ($i = 0; $i -lt $displayCount; $i++) {
        $entry = $scope[$i]
        Write-Host "Entry $($i + 1):" -ForegroundColor Cyan
        Write-Host "  subscriptionId: $($entry.subscriptionId)" -ForegroundColor White
        Write-Host "  displayName: $($entry.displayName)" -ForegroundColor White
        Write-Host "  state: $($entry.state)" -ForegroundColor White
        Write-Host "  managementGroup: $($entry.managementGroup)" -ForegroundColor White
        Write-Host ""
    }
    
    # Check for tenant ID in subscription fields
    Write-Host "Checking for issues..." -ForegroundColor Yellow
    $tenantIdPattern = "^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$"
    $issues = 0
    
    foreach ($entry in $scope) {
        $subId = $entry.subscriptionId
        if ($subId -eq "11514d53-14fb-44c6-9d8f-447443bff746") {
            Write-Host "[ISSUE] Found tenant ID in subscription field!" -ForegroundColor Red
            Write-Host "  DisplayName: $($entry.displayName)" -ForegroundColor Yellow
            $issues++
        }
    }
    
    if ($issues -eq 0) {
        Write-Host "[OK] No obvious issues detected" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "[ERROR] Found $issues entries with tenant ID instead of subscription ID" -ForegroundColor Red
        Write-Host "The scope discovery script needs to be fixed." -ForegroundColor Yellow
    }
}
catch {
    Write-Error "Failed to parse scope.json: $_"
    Write-Host ""
    Write-Host "Raw content (first 500 chars):" -ForegroundColor Yellow
    Write-Host $scopeContent.Substring(0, [Math]::Min(500, $scopeContent.Length))
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan

