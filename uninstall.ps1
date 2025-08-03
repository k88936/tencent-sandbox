# tencent-sandbox Uninstall Script
# This script removes the tencent-sandbox configuration

param(
    [string]$InstallPath,
    [switch]$KeepData
)

Write-Host "Uninstalling tencent-sandbox..." -ForegroundColor Red

if (-not $InstallPath) {
    $InstallPath = $PSScriptRoot
}

# Confirm uninstallation
if (-not $KeepData) {
    $response = Read-Host "This will remove all tencent-sandbox files and data. Continue? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Uninstall cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Stop any running sandbox processes
Write-Host "Checking for running sandbox processes..." -ForegroundColor Yellow
$sandboxProcesses = Get-Process | Where-Object { $_.ProcessName -like "*sandbox*" -or $_.ProcessName -like "*WDAGUtilityAccount*" }
if ($sandboxProcesses) {
    Write-Host "Found running sandbox processes. Please close all sandbox windows first." -ForegroundColor Yellow
    exit 1
}

# Remove directories
Write-Host "Removing tencent-sandbox files..." -ForegroundColor Yellow

$itemsToRemove = @(
    "Tencent.wsb",
    "README.md",
    "install.ps1",
    "uninstall.ps1",
    "sandbox-setup.cmd"
)

if (-not $KeepData) {
    $itemsToRemove += @(
        "App",
        "Data", 
        "Desktop",
        "Scripts",
        "Downloads"
    )
}
else {
    Write-Host "Keeping data directories (App, Data, Desktop, Scripts, Downloads)..." -ForegroundColor Yellow
}

foreach ($item in $itemsToRemove) {
    $itemPath = Join-Path $InstallPath $item
    if (Test-Path $itemPath) {
        try {
            # Check if it's a symbolic link and handle appropriately
            $itemInfo = Get-Item $itemPath
            if ($itemInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
                # It's a symbolic link, remove it without following the link
                Remove-Item -Path $itemPath -Force
                Write-Host "Removed symbolic link: $item" -ForegroundColor Gray
            }
            else {
                # Regular file or directory
                Remove-Item -Path $itemPath -Recurse -Force
                Write-Host "Removed: $item" -ForegroundColor Gray
            }
        }
        catch {
            Write-Warning "Failed to remove: $item - $($_.Exception.Message)"
        }
    }
}

# Clean up any leftover empty directories
if (-not $KeepData) {
    $emptyDirs = Get-ChildItem -Path $InstallPath -Directory | Where-Object { 
        (Get-ChildItem -Path $_.FullName -Recurse | Measure-Object).Count -eq 0 
    }
    
    foreach ($dir in $emptyDirs) {
        try {
            Remove-Item -Path $dir.FullName -Force
            Write-Host "Removed empty directory: $($dir.Name)" -ForegroundColor Gray
        }
        catch {
            Write-Warning "Failed to remove empty directory: $($dir.Name)"
        }
    }
}

if ($KeepData) {
    Write-Host "tencent-sandbox uninstalled (data preserved)!" -ForegroundColor Green
    Write-Host "Your Tencent application data has been kept in App and Data folders." -ForegroundColor Cyan
}
else {
    Write-Host "tencent-sandbox completely uninstalled!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Note: Windows Sandbox feature remains enabled." -ForegroundColor Yellow
Write-Host "To disable it, run as Administrator:" -ForegroundColor Yellow
Write-Host "Disable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM'" -ForegroundColor White
