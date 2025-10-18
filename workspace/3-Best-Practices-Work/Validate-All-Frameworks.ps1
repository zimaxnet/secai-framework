#Requires -Version 7.0
<#
.SYNOPSIS
    Multi-Framework Compliance Validation - Master Orchestrator
.DESCRIPTION
    Validates Azure environments against multiple compliance frameworks simultaneously:
    - Microsoft Cloud Security Benchmark (MCSB)
    - CIS Controls v8
    - NIST SP 800-53 Rev 5
    - PCI-DSS v3.2.1
    - CSA Cloud Controls Matrix (CCM) v4
    
    Uses SecAI Framework collected data to validate compliance across all frameworks.
    
.PARAMETER DataPath
    Path to directory containing SecAI assessment output files
.PARAMETER SubscriptionID
    Specific subscription ID to validate (optional - validates all if not specified)
.PARAMETER Frameworks
    Array of frameworks to validate (default: all)
    Options: "MCSB", "CIS-v8", "NIST", "PCI-DSS", "CCM", "All"
.PARAMETER OutputPath
    Path for compliance report output (default: ./reports)
.PARAMETER GenerateExecutiveSummary
    Generate executive summary dashboard (default: true)
.EXAMPLE
    # Validate all frameworks for all subscriptions
    .\Validate-All-Frameworks.ps1 -DataPath "../../implementation/2-Scripts/out"
    
.EXAMPLE
    # Validate only MCSB and NIST for specific subscription
    .\Validate-All-Frameworks.ps1 -DataPath "C:\Data" -SubscriptionID "abc-123" -Frameworks @("MCSB", "NIST")
    
.EXAMPLE
    # Validate all with custom output location
    .\Validate-All-Frameworks.ps1 -DataPath "C:\Data" -OutputPath "C:\Reports\Compliance"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$DataPath,
    
    [Parameter(Mandatory=$false)]
    [string]$SubscriptionID,
    
    [Parameter(Mandatory=$false)]
    [string[]]$Frameworks = @("All"),
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = "./reports",
    
    [Parameter(Mandatory=$false)]
    [bool]$GenerateExecutiveSummary = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# Banner
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "SecAI Framework - Multi-Framework Compliance Validation" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Frameworks: $(if ($Frameworks -contains 'All') { 'All (MCSB, CIS-v8, NIST, PCI-DSS, CCM)' } else { $Frameworks -join ', ' })" -ForegroundColor Yellow
Write-Host "Data Path: $DataPath" -ForegroundColor Gray
Write-Host "Output: $OutputPath" -ForegroundColor Gray
Write-Host ""

# Validate data path
if (-not (Test-Path $DataPath)) {
    Write-Error "Data path not found: $DataPath"
    Write-Host "Please run SecAI collection scripts (01-09) first" -ForegroundColor Yellow
    exit 1
}

# Create output directory
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "Created output directory: $OutputPath" -ForegroundColor Green
}

# Import modules
$modulePath = $PSScriptRoot
try {
    Write-Host "Loading validation modules..." -ForegroundColor Yellow
    Import-Module (Join-Path $modulePath "Common-Functions.psm1") -Force -ErrorAction Stop
    Import-Module (Join-Path $modulePath "Framework-MCSB.psm1") -Force -ErrorAction Stop
    Import-Module (Join-Path $modulePath "Framework-CISv8.psm1") -Force -ErrorAction Stop
    Import-Module (Join-Path $modulePath "Framework-NIST.psm1") -Force -ErrorAction Stop
    Import-Module (Join-Path $modulePath "Framework-PCIDSS.psm1") -Force -ErrorAction Stop
    Import-Module (Join-Path $modulePath "Framework-CCM.psm1") -Force -ErrorAction Stop
    Write-Host "  [OK] All modules loaded successfully" -ForegroundColor Green
}
catch {
    Write-Error "Failed to load modules: $_"
    exit 1
}

Write-Host ""

# Determine which frameworks to run
$frameworksToRun = if ($Frameworks -contains "All") {
    @("MCSB", "CIS-v8", "NIST", "PCI-DSS", "CCM")
} else {
    $Frameworks
}

Write-Host "Frameworks to validate: $($frameworksToRun -join ', ')" -ForegroundColor Cyan
Write-Host ""

# Get subscriptions to validate
if ($SubscriptionID) {
    $subscriptionsToValidate = @($SubscriptionID)
    Write-Host "Validating single subscription: $SubscriptionID" -ForegroundColor Yellow
}
else {
    $subscriptionsToValidate = Get-SubscriptionList -DataPath $DataPath
    Write-Host "Found $($subscriptionsToValidate.Count) subscription(s) to validate" -ForegroundColor Yellow
}

if ($subscriptionsToValidate.Count -eq 0) {
    Write-Error "No subscriptions found to validate"
    exit 1
}

Write-Host ""
Write-Host "Starting validation..." -ForegroundColor Cyan
Write-Host ""

# Run validations
$allResults = @()
$frameworkScores = @()

foreach ($subID in $subscriptionsToValidate) {
    Write-Host "=" * 60 -ForegroundColor Gray
    Write-Host "Subscription: $subID" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Gray
    
    # Run each framework
    if ($frameworksToRun -contains "MCSB") {
        Write-Host "Framework: Microsoft Cloud Security Benchmark (MCSB)" -ForegroundColor Yellow
        $mscbResults = Invoke-MSCBValidation -DataPath $DataPath -SubscriptionID $subID
        $allResults += $mscbResults
        Write-Host ""
    }
    
    if ($frameworksToRun -contains "CIS-v8") {
        Write-Host "Framework: CIS Controls v8" -ForegroundColor Yellow
        $cisv8Results = Invoke-CISv8Validation -DataPath $DataPath -SubscriptionID $subID
        $allResults += $cisv8Results
        Write-Host ""
    }
    
    if ($frameworksToRun -contains "NIST") {
        Write-Host "Framework: NIST SP 800-53" -ForegroundColor Yellow
        $nistResults = Invoke-NISTValidation -DataPath $DataPath -SubscriptionID $subID
        $allResults += $nistResults
        Write-Host ""
    }
    
    if ($frameworksToRun -contains "PCI-DSS") {
        Write-Host "Framework: PCI-DSS v3.2.1" -ForegroundColor Yellow
        $pciResults = Invoke-PCIDSSValidation -DataPath $DataPath -SubscriptionID $subID
        $allResults += $pciResults
        Write-Host ""
    }
    
    if ($frameworksToRun -contains "CCM") {
        Write-Host "Framework: CSA Cloud Controls Matrix" -ForegroundColor Yellow
        $ccmResults = Invoke-CCMValidation -DataPath $DataPath -SubscriptionID $subID
        $allResults += $ccmResults
        Write-Host ""
    }
}

# Generate Summary
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""

# Overall summary
$overallSummary = Get-ComplianceSummary -Results $allResults

Write-Host "Overall Results:" -ForegroundColor White
Write-Host "  Total Controls Tested: $($overallSummary.TotalControls)" -ForegroundColor White
Write-Host "  PASS: $($overallSummary.PassCount)" -ForegroundColor Green
Write-Host "  FAIL: $($overallSummary.FailCount)" -ForegroundColor Red
Write-Host "  SKIP: $($overallSummary.SkipCount)" -ForegroundColor Gray
Write-Host "  MANUAL: $($overallSummary.ManualCount)" -ForegroundColor Yellow
Write-Host "  ERROR: $($overallSummary.ErrorCount)" -ForegroundColor Magenta
Write-Host ""
Write-Host "  Testable Controls: $($overallSummary.TestableControls)" -ForegroundColor White
Write-Host "  Overall Compliance: $($overallSummary.CompliancePercentage)%" -ForegroundColor $(
    if ($overallSummary.CompliancePercentage -ge 80) { "Green" }
    elseif ($overallSummary.CompliancePercentage -ge 60) { "Yellow" }
    else { "Red" }
)
Write-Host ""

# Per-framework summary
Write-Host "Framework-Specific Scores:" -ForegroundColor White
Write-Host ""

foreach ($fw in $frameworksToRun) {
    $score = Get-FrameworkScore -Results $allResults -Framework $fw
    
    $color = if ($score.Score -ge 80) { "Green" }
             elseif ($score.Score -ge 60) { "Yellow" }
             else { "Red" }
    
    Write-Host "  $($fw):" -ForegroundColor White
    Write-Host "    Score: $($score.Score)%" -ForegroundColor $color
    Write-Host "    Pass: $($score.Pass) | Fail: $($score.Fail) | Total: $($score.Total)" -ForegroundColor Gray
    Write-Host ""
    
    $frameworkScores += [PSCustomObject]@{
        Framework = $fw
        ComplianceScore = $score.Score
        PassCount = $score.Pass
        FailCount = $score.Fail
        SkipCount = $score.Skip
        ManualCount = $score.Manual
        TotalControls = $score.Total
        TestableControls = $score.Testable
    }
}

# Export results
Write-Host "Exporting results..." -ForegroundColor Yellow

# Main compliance report
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$mainReport = Export-ComplianceReport -Results $allResults -OutputPath $OutputPath -ReportName "Multi_Framework_Compliance"
Write-Host "  [OK] Detailed report: $mainReport" -ForegroundColor Green

# Framework summary report
$frameworkSummaryPath = Join-Path $OutputPath "Framework_Summary_$timestamp.csv"
$frameworkScores | Export-Csv -Path $frameworkSummaryPath -NoTypeInformation
Write-Host "  [OK] Framework summary: $frameworkSummaryPath" -ForegroundColor Green

# Failed controls report
$failedControls = $allResults | Where-Object { $_.Status -eq "FAIL" } | ForEach-Object { [PSCustomObject]$_ }
if ($failedControls.Count -gt 0) {
    $failedControlsPath = Join-Path $OutputPath "Failed_Controls_$timestamp.csv"
    $failedControls | Export-Csv -Path $failedControlsPath -NoTypeInformation
    Write-Host "  [OK] Failed controls: $failedControlsPath" -ForegroundColor Green
}

Write-Host ""

# Display top failures
if ($failedControls.Count -gt 0) {
    Write-Host "=" * 60 -ForegroundColor Red
    Write-Host "CRITICAL FAILURES (Top 10)" -ForegroundColor Red
    Write-Host "=" * 60 -ForegroundColor Red
    Write-Host ""
    
    $criticalFailures = $failedControls | 
        Where-Object { $_.Severity -eq "Critical" } | 
        Sort-Object Framework, ControlID | 
        Select-Object -First 10
    
    foreach ($failure in $criticalFailures) {
        Write-Host "  $($failure.Framework) $($failure.ControlID): $($failure.ControlName)" -ForegroundColor Yellow
        Write-Host "    Domain: $($failure.Domain)" -ForegroundColor Gray
        Write-Host "    Reason: $($failure.Reason)" -ForegroundColor Gray
        if ($failure.NonCompliantResourceNames) {
            Write-Host "    Resources: $($failure.NonCompliantResourceNames)" -ForegroundColor Gray
        }
        Write-Host ""
    }
}

# Generate executive summary if requested
if ($GenerateExecutiveSummary) {
    Write-Host "Generating executive summary..." -ForegroundColor Yellow
    
    $execSummaryPath = Join-Path $OutputPath "Executive_Summary_$timestamp.txt"
    
    $summary = @"
========================================================
EXECUTIVE COMPLIANCE SUMMARY
========================================================
Date: $(Get-Date -Format "MMMM dd, yyyy HH:mm")
Assessment: Multi-Framework Azure Security Compliance
Subscriptions Validated: $($subscriptionsToValidate.Count)

OVERALL COMPLIANCE SCORE: $($overallSummary.CompliancePercentage)%

Framework-Specific Scores:
$(foreach ($fw in $frameworkScores) {
"  - $($fw.Framework): $($fw.ComplianceScore)% ($($fw.PassCount) pass / $($fw.FailCount) fail)"
})

Summary Statistics:
  Total Controls Evaluated: $($overallSummary.TotalControls)
  Passed: $($overallSummary.PassCount)
  Failed: $($overallSummary.FailCount)
  Requires Manual Review: $($overallSummary.ManualCount)
  Skipped (N/A): $($overallSummary.SkipCount)
  Errors: $($overallSummary.ErrorCount)

Risk Assessment:
$(if ($overallSummary.CompliancePercentage -ge 80) {
"  STATUS: GOOD - Compliance posture is acceptable
  ACTION: Continue monitoring and address remaining gaps"
} elseif ($overallSummary.CompliancePercentage -ge 60) {
"  STATUS: FAIR - Compliance gaps exist
  ACTION: Prioritize remediation of failed critical controls"
} else {
"  STATUS: POOR - Significant compliance gaps
  ACTION: Immediate remediation required, executive escalation recommended"
})

Critical Failures Requiring Immediate Attention:
$( $criticalFailures | ForEach-Object {
"  - $($_.Framework) $($_.ControlID): $($_.ControlName)
    Impact: $($_.Reason)"
})

Next Steps:
1. Review detailed reports in: $OutputPath
2. Prioritize remediation of critical failures
3. Assign ownership for each gap
4. Create remediation timeline
5. Schedule follow-up assessment

Report Files Generated:
- Detailed results: $mainReport
- Framework summary: $frameworkSummaryPath
$(if ($failedControls.Count -gt 0) { "- Failed controls: $failedControlsPath" } else { "" })
- Executive summary: $execSummaryPath

========================================================
"@
    
    $summary | Set-Content -Path $execSummaryPath -Encoding UTF8
    Write-Host "  [OK] Executive summary: $execSummaryPath" -ForegroundColor Green
    Write-Host ""
}

# Final summary
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host "VALIDATION COMPLETE" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan
Write-Host ""
Write-Host "Overall Compliance: $($overallSummary.CompliancePercentage)%" -ForegroundColor $(
    if ($overallSummary.CompliancePercentage -ge 80) { "Green" }
    elseif ($overallSummary.CompliancePercentage -ge 60) { "Yellow" }
    else { "Red" }
)
Write-Host "Critical Failures: $(($failedControls | Where-Object { $_.Severity -eq 'Critical' }).Count)" -ForegroundColor $(
    if (($failedControls | Where-Object { $_.Severity -eq 'Critical' }).Count -eq 0) { "Green" } else { "Red" }
)
Write-Host ""
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
Write-Host ""

# Return summary for programmatic use
return @{
    OverallCompliance = $overallSummary.CompliancePercentage
    TotalControls = $overallSummary.TotalControls
    PassCount = $overallSummary.PassCount
    FailCount = $overallSummary.FailCount
    FrameworkScores = $frameworkScores
    ReportPath = $mainReport
}

