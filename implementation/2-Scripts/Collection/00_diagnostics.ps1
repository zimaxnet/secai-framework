#Requires -Version 5.1
<#
.SYNOPSIS
    Azure CLI Diagnostics Script
.DESCRIPTION
    Tests Azure CLI connectivity and permissions for management groups and subscriptions.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Azure CLI Diagnostics" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Azure CLI installed
Write-Host "[1/7] Checking Azure CLI installation..." -ForegroundColor Yellow
try {
    $azVersion = az version --output json 2>$null | ConvertFrom-Json
    Write-Host "  [OK] Azure CLI version: $($azVersion.'azure-cli')" -ForegroundColor Green
}
catch {
    Write-Host "  [FAIL] Azure CLI not found or not working" -ForegroundColor Red
    exit 1
}

# Test 2: Authentication status
Write-Host "[2/7] Checking authentication status..." -ForegroundColor Yellow
try {
    $account = az account show --output json 2>$null | ConvertFrom-Json
    Write-Host "  [OK] Logged in as: $($account.user.name)" -ForegroundColor Green
    Write-Host "    Tenant ID: $($account.tenantId)" -ForegroundColor White
    Write-Host "    Default subscription: $($account.name)" -ForegroundColor White
}
catch {
    Write-Host "  [FAIL] Not logged in. Run .\00_login.ps1 first" -ForegroundColor Red
    exit 1
}

# Test 3: List subscriptions
Write-Host "[3/7] Testing subscription access..." -ForegroundColor Yellow
try {
    $subs = az account list --output json 2>$null | ConvertFrom-Json
    Write-Host "  [OK] Can access $($subs.Count) subscription(s)" -ForegroundColor Green
    
    # Show first 5
    $displayCount = [Math]::Min($subs.Count, 5)
    for ($i = 0; $i -lt $displayCount; $i++) {
        Write-Host "    - $($subs[$i].name) ($($subs[$i].state))" -ForegroundColor Gray
    }
    if ($subs.Count -gt 5) {
        Write-Host "    ... and $($subs.Count - 5) more" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  [FAIL] Cannot list subscriptions" -ForegroundColor Red
    exit 1
}

# Test 4: Management groups (try multiple approaches)
Write-Host "[4/7] Testing management group access..." -ForegroundColor Yellow

$mgTests = @(
    @{ Name = "--no-register"; Command = "az account management-group list --no-register" },
    @{ Name = "default"; Command = "az account management-group list" },
    @{ Name = "--refresh"; Command = "az account management-group list --refresh" }
)

$mgSuccess = $false
$mgCount = 0
$mgData = $null

foreach ($test in $mgTests) {
    Write-Host "    Testing with $($test.Name)..." -ForegroundColor Gray
    try {
        $mgResult = Invoke-Expression "$($test.Command) --output json 2>`$null"
        if ($LASTEXITCODE -eq 0 -and $mgResult) {
            try {
                $mgData = $mgResult | ConvertFrom-Json
                if ($mgData -and $mgData.Count -gt 0) {
                    $mgCount = $mgData.Count
                    $mgSuccess = $true
                    Write-Host "  [OK] Found $mgCount management group(s) using $($test.Name)" -ForegroundColor Green
                    
                    # Show first 3
                    $displayCount = [Math]::Min($mgData.Count, 3)
                    for ($i = 0; $i -lt $displayCount; $i++) {
                        Write-Host "    - $($mgData[$i].displayName) ($($mgData[$i].name))" -ForegroundColor Gray
                    }
                    if ($mgData.Count -gt 3) {
                        Write-Host "    ... and $($mgData.Count - 3) more" -ForegroundColor Gray
                    }
                    break
                }
            }
            catch {
                # JSON parse failed, continue
            }
        }
    }
    catch {
        # Command failed, continue to next test
    }
}

if (-not $mgSuccess) {
    Write-Host "  [FAIL] Cannot access management groups" -ForegroundColor Red
    Write-Host "    This could mean:" -ForegroundColor Yellow
    Write-Host "    - You don't have 'Management Group Reader' role" -ForegroundColor Yellow
    Write-Host "    - Management groups are not used in this tenant" -ForegroundColor Yellow
    Write-Host "    - The resource provider is not registered" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  To check your role assignments, run:" -ForegroundColor Cyan
    Write-Host "    az role assignment list --assignee $($account.user.name) --all" -ForegroundColor White
}

# Test 5: Resource Graph
Write-Host "[5/7] Testing Azure Resource Graph access..." -ForegroundColor Yellow
try {
    $rgQuery = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | limit 1"
    $rgResult = az graph query -q $rgQuery --output json 2>$null
    if ($LASTEXITCODE -eq 0 -and $rgResult) {
        Write-Host "  [OK] Resource Graph is accessible" -ForegroundColor Green
    }
    else {
        Write-Host "  [WARN] Resource Graph may not be available" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  [WARN] Resource Graph not accessible (this is optional)" -ForegroundColor Yellow
}

# Test 6: Try to get MG hierarchy via Resource Graph
if ($mgSuccess) {
    Write-Host "[6/7] Testing MG-to-Subscription mapping..." -ForegroundColor Yellow
    try {
        $query = "resourcecontainers | where type == 'microsoft.resources/subscriptions' | project subscriptionId, properties.managementGroupAncestorsChain | limit 5"
        $rgResult = az graph query -q $query --output json 2>$null
        
        if ($LASTEXITCODE -eq 0 -and $rgResult) {
            try {
                $rgData = $rgResult | ConvertFrom-Json
                if ($rgData.data -and $rgData.data.Count -gt 0) {
                    Write-Host "  [OK] Can map subscriptions to management groups via Resource Graph" -ForegroundColor Green
                }
                else {
                    Write-Host "  [WARN] Resource Graph available but no MG data returned" -ForegroundColor Yellow
                }
            }
            catch {
                Write-Host "  [WARN] Cannot parse Resource Graph response" -ForegroundColor Yellow
            }
        }
        else {
            Write-Host "  [WARN] Cannot query MG hierarchy via Resource Graph" -ForegroundColor Yellow
            Write-Host "    Will try direct MG API instead" -ForegroundColor Gray
        }
    }
    catch {
        Write-Host "  [WARN] MG mapping via Resource Graph failed" -ForegroundColor Yellow
    }
}
else {
    Write-Host "[6/7] Skipping MG mapping test (no MG access)" -ForegroundColor Gray
}

# Test 7: Check specific permissions
Write-Host "[7/7] Checking role assignments..." -ForegroundColor Yellow
try {
    $roles = az role assignment list --assignee $($account.user.name) --all --output json 2>$null | ConvertFrom-Json
    
    $relevantRoles = $roles | Where-Object { 
        $_.roleDefinitionName -match "Management Group|Reader|Contributor|Owner" 
    }
    
    if ($relevantRoles.Count -gt 0) {
        Write-Host "  [OK] Found $($relevantRoles.Count) relevant role assignment(s):" -ForegroundColor Green
        foreach ($role in $relevantRoles | Select-Object -First 5) {
            $scope = $role.scope
            if ($scope.Length -gt 60) {
                $scope = $scope.Substring(0, 57) + "..."
            }
            Write-Host "    - $($role.roleDefinitionName) on $scope" -ForegroundColor Gray
        }
        if ($relevantRoles.Count -gt 5) {
            Write-Host "    ... and $($relevantRoles.Count - 5) more" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "  [WARN] No relevant role assignments found" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  [WARN] Could not retrieve role assignments" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "Diagnostics Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions: [OK] ($($subs.Count) found)" -ForegroundColor Green
if ($mgSuccess) {
    Write-Host "  Management Groups: [OK] ($mgCount found)" -ForegroundColor Green
}
else {
    Write-Host "  Management Groups: [FAIL] (not accessible)" -ForegroundColor Red
}
Write-Host ""

if (-not $mgSuccess) {
    Write-Host "Recommended Actions:" -ForegroundColor Yellow
    Write-Host "1. Ask your Azure administrator to grant you 'Management Group Reader' role" -ForegroundColor White
    Write-Host "2. Or have them run this command:" -ForegroundColor White
    Write-Host "   az role assignment create --assignee $($account.user.name) --role 'Management Group Reader' --scope /providers/Microsoft.Management/managementGroups/{mg-id}" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Note: The assessment scripts will still work without MG access," -ForegroundColor Cyan
    Write-Host "      but won't include management group hierarchy information." -ForegroundColor Cyan
}
else {
    Write-Host "[SUCCESS] All systems ready! You can proceed with the assessment scripts." -ForegroundColor Green
}
