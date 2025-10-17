#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Policy and Defender for Cloud Assessment
.DESCRIPTION
    Collects Azure Policy definitions, assignments, and Defender for Cloud configurations.
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
Write-Host "Azure Policy & Defender Assessment" -ForegroundColor Cyan
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

# Collect tenant-wide policy definitions (once)
Write-Host "Collecting tenant-wide policy definitions..." -ForegroundColor Yellow
try {
    $policyDefOutput = az policy definition list 2>&1
    if ($LASTEXITCODE -eq 0) {
        try {
            $policyDefs = $policyDefOutput | ConvertFrom-Json
            $policyDefOutput | Set-Content -Path (Join-Path $OutDir "tenant_policy_definitions.json") -Encoding UTF8
            Write-Host "  [OK] Found $($policyDefs.Count) policy definition(s)" -ForegroundColor Green
        }
        catch {
            Write-Host "  [WARN] Could not parse policy definitions" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "tenant_policy_definitions.json") -Encoding UTF8
        }
    }
    else {
        Write-Host "  [ERROR] Failed to retrieve policy definitions" -ForegroundColor Red
        "[]" | Set-Content -Path (Join-Path $OutDir "tenant_policy_definitions.json") -Encoding UTF8
    }
}
catch {
    Write-Host "  [ERROR] Exception: $_" -ForegroundColor Red
    "[]" | Set-Content -Path (Join-Path $OutDir "tenant_policy_definitions.json") -Encoding UTF8
}

Write-Host ""

# Initialize counters
$successCount = 0
$errorCount = 0
$totalPolicyAssignments = 0
$totalPolicySetDefs = 0
$defenderEnabledCount = 0

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
        # Policy Assignments
        Write-Host "  Collecting policy assignments..." -ForegroundColor Yellow
        $policyAssignOutput = az policy assignment list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $policyAssignOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $assignments = $cleanJson | ConvertFrom-Json
                $assignCount = if ($assignments) { $assignments.Count } else { 0 }
                $totalPolicyAssignments += $assignCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_policy_assignments.json") -Encoding UTF8
                Write-Host "    [OK] Found $assignCount policy assignment(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse policy assignments: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_policy_assignments.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list policy assignments" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_policy_assignments.json") -Encoding UTF8
        }
        
        # Policy Set Definitions (Initiatives)
        Write-Host "  Collecting policy set definitions..." -ForegroundColor Yellow
        $policySetOutput = az policy set-definition list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $setJsonLines = $policySetOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $setCleanJson = $setJsonLines -join "`n"
                
                $policySets = $setCleanJson | ConvertFrom-Json
                $setCount = if ($policySets) { $policySets.Count } else { 0 }
                $totalPolicySetDefs += $setCount
                
                $setCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_policy_set_definitions.json") -Encoding UTF8
                Write-Host "    [OK] Found $setCount policy set definition(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse policy set definitions: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_policy_set_definitions.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list policy set definitions" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_policy_set_definitions.json") -Encoding UTF8
        }
        
        # Defender for Cloud Pricing
        Write-Host "  Collecting Defender for Cloud pricing..." -ForegroundColor Yellow
        $defenderOutput = az security pricing list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $defJsonLines = $defenderOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $defCleanJson = $defJsonLines -join "`n"
                
                $pricing = $defCleanJson | ConvertFrom-Json
                $defCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_defender_pricing.json") -Encoding UTF8
                
                # Check if any Defender plans are enabled
                $enabledPlans = 0
                if ($pricing.value) {
                    $enabledPlans = ($pricing.value | Where-Object { $_.properties.pricingTier -eq "Standard" }).Count
                }
                
                if ($enabledPlans -gt 0) {
                    $defenderEnabledCount++
                    Write-Host "    [OK] Defender enabled for $enabledPlans resource type(s)" -ForegroundColor Green
                }
                else {
                    Write-Host "    [OK] Defender pricing retrieved (Free tier)" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse Defender pricing: $_" -ForegroundColor Yellow
                "{}" | Set-Content -Path (Join-Path $OutDir "$sub`_defender_pricing.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to retrieve Defender pricing" -ForegroundColor Yellow
            "{}" | Set-Content -Path (Join-Path $OutDir "$sub`_defender_pricing.json") -Encoding UTF8
        }
        
        # Regulatory Compliance Standards
        Write-Host "  Collecting regulatory compliance standards..." -ForegroundColor Yellow
        $complianceOutput = az security regulatory-compliance-standards list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $compJsonLines = $complianceOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $compCleanJson = $compJsonLines -join "`n"
                
                $compliance = $compCleanJson | ConvertFrom-Json
                $compCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_regulatory_compliance.json") -Encoding UTF8
                
                $compCount = 0
                if ($compliance.value) {
                    $compCount = $compliance.value.Count
                }
                
                Write-Host "    [OK] Found $compCount compliance standard(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse compliance standards: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_regulatory_compliance.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to retrieve compliance standards" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_regulatory_compliance.json") -Encoding UTF8
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
Write-Host "Policy & Defender Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total policy assignments: $totalPolicyAssignments" -ForegroundColor White
Write-Host "  Total policy set definitions: $totalPolicySetDefs" -ForegroundColor White
Write-Host "  Subscriptions with Defender enabled: $defenderEnabledCount" -ForegroundColor White
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] Policy and Defender assessment complete!" -ForegroundColor Green
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}
