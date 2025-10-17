#Requires -Version 5.1
<#
.SYNOPSIS
    Azure Network Security Assessment
.DESCRIPTION
    Collects network security configurations including VNets, NSGs, firewalls, load balancers, and private endpoints.
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
Write-Host "Network Security Assessment" -ForegroundColor Cyan
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
$totalVNets = 0
$totalNSGs = 0
$totalFirewalls = 0
$totalLoadBalancers = 0
$totalPrivateEndpoints = 0

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
        # Virtual Networks
        Write-Host "  Collecting virtual networks..." -ForegroundColor Yellow
        $vnetOutput = az network vnet list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $jsonLines = $vnetOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $cleanJson = $jsonLines -join "`n"
                
                $vnets = $cleanJson | ConvertFrom-Json
                $vnetCount = if ($vnets) { $vnets.Count } else { 0 }
                $totalVNets += $vnetCount
                
                $cleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_vnets.json") -Encoding UTF8
                Write-Host "    [OK] Found $vnetCount virtual network(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse virtual networks: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_vnets.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list virtual networks" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_vnets.json") -Encoding UTF8
        }
        
        # Network Security Groups
        Write-Host "  Collecting network security groups..." -ForegroundColor Yellow
        $nsgOutput = az network nsg list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $nsgJsonLines = $nsgOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $nsgCleanJson = $nsgJsonLines -join "`n"
                
                $nsgs = $nsgCleanJson | ConvertFrom-Json
                $nsgCount = if ($nsgs) { $nsgs.Count } else { 0 }
                $totalNSGs += $nsgCount
                
                $nsgCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_nsgs.json") -Encoding UTF8
                Write-Host "    [OK] Found $nsgCount network security group(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse NSGs: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_nsgs.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [ERROR] Failed to list NSGs" -ForegroundColor Red
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_nsgs.json") -Encoding UTF8
        }
        
        # Application Security Groups
        Write-Host "  Collecting application security groups..." -ForegroundColor Yellow
        $asgOutput = az network asg list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $asgJsonLines = $asgOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $asgCleanJson = $asgJsonLines -join "`n"
                
                $asgs = $asgCleanJson | ConvertFrom-Json
                $asgCount = if ($asgs) { $asgs.Count } else { 0 }
                
                $asgCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_asgs.json") -Encoding UTF8
                Write-Host "    [OK] Found $asgCount application security group(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse ASGs: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_asgs.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to list ASGs" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_asgs.json") -Encoding UTF8
        }
        
        # Route Tables
        Write-Host "  Collecting route tables..." -ForegroundColor Yellow
        $rtOutput = az network route-table list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $rtJsonLines = $rtOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $rtCleanJson = $rtJsonLines -join "`n"
                
                $routeTables = $rtCleanJson | ConvertFrom-Json
                $rtCount = if ($routeTables) { $routeTables.Count } else { 0 }
                
                $rtCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_route_tables.json") -Encoding UTF8
                Write-Host "    [OK] Found $rtCount route table(s)" -ForegroundColor Green
            }
            catch {
                Write-Host "    [WARN] Could not parse route tables: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_route_tables.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to list route tables" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_route_tables.json") -Encoding UTF8
        }
        
        # Azure Firewalls
        Write-Host "  Collecting Azure Firewalls..." -ForegroundColor Yellow
        $fwOutput = az network firewall list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $fwJsonLines = $fwOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $fwCleanJson = $fwJsonLines -join "`n"
                
                $firewalls = $fwCleanJson | ConvertFrom-Json
                $fwCount = if ($firewalls) { $firewalls.Count } else { 0 }
                $totalFirewalls += $fwCount
                
                $fwCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_az_firewalls.json") -Encoding UTF8
                
                if ($fwCount -gt 0) {
                    Write-Host "    [OK] Found $fwCount Azure Firewall(s)" -ForegroundColor Green
                }
                else {
                    Write-Host "    [OK] No Azure Firewalls found" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse firewalls: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_az_firewalls.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to list firewalls" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_az_firewalls.json") -Encoding UTF8
        }
        
        # Load Balancers
        Write-Host "  Collecting Load Balancers..." -ForegroundColor Yellow
        $lbOutput = az network lb list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $lbJsonLines = $lbOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $lbCleanJson = $lbJsonLines -join "`n"
                
                $loadBalancers = $lbCleanJson | ConvertFrom-Json
                $lbCount = if ($loadBalancers) { $loadBalancers.Count } else { 0 }
                $totalLoadBalancers += $lbCount
                
                $lbCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_load_balancers.json") -Encoding UTF8
                
                if ($lbCount -gt 0) {
                    Write-Host "    [OK] Found $lbCount Load Balancer(s)" -ForegroundColor Green
                }
                else {
                    Write-Host "    [OK] No Load Balancers found" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse load balancers: $_" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_load_balancers.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to list load balancers" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_load_balancers.json") -Encoding UTF8
        }
        
        # Private Endpoints
        Write-Host "  Collecting private endpoints..." -ForegroundColor Yellow
        $peOutput = az network private-endpoint list --subscription $sub 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            try {
                # Filter out warning lines before parsing
                $peJsonLines = $peOutput | Where-Object { $_ -notmatch '^WARNING:' -and $_ -notmatch 'InsecureRequestWarning' -and $_ -notmatch 'urllib3' -and $_ -notmatch 'site-packages' -and $_.Trim() -ne '' }
                $peCleanJson = $peJsonLines -join "`n"
                
                $privateEndpoints = $peCleanJson | ConvertFrom-Json
                $peCount = if ($privateEndpoints) { $privateEndpoints.Count } else { 0 }
                $totalPrivateEndpoints += $peCount
                
                $peCleanJson | Set-Content -Path (Join-Path $OutDir "$sub`_private_endpoints.json") -Encoding UTF8
                
                if ($peCount -gt 0) {
                    Write-Host "    [OK] Found $peCount private endpoint(s)" -ForegroundColor Green
                }
                else {
                    Write-Host "    [OK] No private endpoints found" -ForegroundColor Gray
                }
            }
            catch {
                Write-Host "    [WARN] Could not parse private endpoints" -ForegroundColor Yellow
                "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_private_endpoints.json") -Encoding UTF8
            }
        }
        else {
            Write-Host "    [WARN] Failed to list private endpoints" -ForegroundColor Yellow
            "[]" | Set-Content -Path (Join-Path $OutDir "$sub`_private_endpoints.json") -Encoding UTF8
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
Write-Host "Network Security Summary" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "  Subscriptions processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  Subscriptions with errors: $errorCount" -ForegroundColor Red
}
Write-Host "  Total virtual networks: $totalVNets" -ForegroundColor White
Write-Host "  Total network security groups: $totalNSGs" -ForegroundColor White
Write-Host "  Total Azure Firewalls: $totalFirewalls" -ForegroundColor White
Write-Host "  Total Load Balancers: $totalLoadBalancers" -ForegroundColor White
Write-Host "  Total private endpoints: $totalPrivateEndpoints" -ForegroundColor White
Write-Host ""
Write-Host "Output directory: $OutDir" -ForegroundColor Cyan
Write-Host ""

if ($successCount -gt 0) {
    Write-Host "[SUCCESS] Network security assessment complete!" -ForegroundColor Green
}
else {
    Write-Host "[WARNING] No subscriptions were successfully processed" -ForegroundColor Yellow
}
