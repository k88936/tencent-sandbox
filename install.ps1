# tencent-sandbox Install Script
# This script sets up the tencent-sandbox Windows Sandbox configuration

param(
    [string]$InstallPath
)

Write-Host "Installing tencent-sandbox..." -ForegroundColor Green

if (-not $InstallPath) {
    $InstallPath = $PSScriptRoot
}

# Provide Windows Sandbox information (without requiring admin privileges)
Write-Host "Windows Sandbox Requirements:" -ForegroundColor Yellow
Write-Host "- Windows 10 Pro/Enterprise/Education (build 18305+) or Windows 11 Pro/Enterprise/Education" -ForegroundColor White
Write-Host "- Windows Sandbox feature must be enabled" -ForegroundColor White
Write-Host ""
Write-Host "To enable Windows Sandbox (run as Administrator):" -ForegroundColor Cyan
Write-Host "Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM' -All" -ForegroundColor White
Write-Host "Then restart your computer." -ForegroundColor White
Write-Host ""

# Create required directory structure (merged from mkdir.bat)
Write-Host "Creating directory structure..." -ForegroundColor Yellow

$directories = @(
    "App\QQ",
    "App\QQNT", 
    "App\TIM",
    "App\WeChat",
    "App\Weixin",
    "App\WXWork",
    "App\WeMeet",
    "App\TencentDocs",
    "Data\Common Files",
    "Data\Documents\Tencent",
    "Data\Documents\WeChat", 
    "Data\Documents\xwechat_files",
    "Data\Documents\WXWork",
    "Data\Roaming\Tencent",
    "Data\Roaming\WeChat",
    "Data\Roaming\xwechat",
    "Data\Roaming\TencentDocs",
    "Data\Roaming\WeMeet",
    "Data\SysWOW64",
    "Data\ProgramData\Tencent",
    "Desktop",
    "Scripts"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $InstallPath $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created: $dir" -ForegroundColor Gray
    }
}

# Create symbolic link to user's Downloads folder
Write-Host "Creating symbolic link to user's Downloads folder..." -ForegroundColor Yellow
$userDownloads = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
$sandboxDownloads = Join-Path $InstallPath "Downloads"

if (-not (Test-Path $sandboxDownloads)) {
    try {
        # Create symbolic link (requires administrator privileges)
        New-Item -ItemType SymbolicLink -Path $sandboxDownloads -Target $userDownloads -Force | Out-Null
        Write-Host "Created symbolic link: Downloads -> $userDownloads" -ForegroundColor Green
    }
    catch {
        # Fallback: create regular directory if symbolic link fails
        Write-Warning "Failed to create symbolic link (may require administrator privileges). Creating regular directory instead."
        New-Item -ItemType Directory -Path $sandboxDownloads -Force | Out-Null
        Write-Host "Created regular directory: Downloads" -ForegroundColor Gray
    }
}

# Create desktop shortcuts
Write-Host "Creating desktop shortcuts..." -ForegroundColor Yellow

$desktopPath = Join-Path $InstallPath "Desktop"
$shortcuts = @(
    @{Name = "QQ.lnk"; Target = "C:\Program Files (x86)\Tencent\QQ\QQ.exe" },
    @{Name = "WeChat.lnk"; Target = "C:\Program Files\Tencent\WeChat\WeChat.exe" },
    @{Name = "WeMeet.lnk"; Target = "C:\Program Files\Tencent\WeMeet\WeMeet.exe" }
)

foreach ($shortcut in $shortcuts) {
    $shortcutPath = Join-Path $desktopPath $shortcut.Name
    if (-not (Test-Path $shortcutPath)) {
        # Create empty shortcut files as placeholders
        New-Item -ItemType File -Path $shortcutPath -Force | Out-Null
        Write-Host "Created shortcut placeholder: $($shortcut.Name)" -ForegroundColor Gray
    }
}

Write-Host "tencent-sandbox installation completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Ensure Windows Sandbox is enabled (see requirements above)" -ForegroundColor White
Write-Host "2. Double-click Tencent.wsb to start the sandbox" -ForegroundColor White
Write-Host "3. Install your Tencent applications inside the sandbox" -ForegroundColor White
Write-Host "4. Move desktop shortcuts to fix persistence" -ForegroundColor White
Write-Host ""
Write-Host "Features:" -ForegroundColor Cyan
Write-Host "- Downloads folder is linked to your user Downloads" -ForegroundColor White
Write-Host "- Files downloaded in sandbox will appear in your main Downloads" -ForegroundColor White
Write-Host "- Directory structure automatically created" -ForegroundColor White
