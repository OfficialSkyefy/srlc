# Skyes Overlay installer: downloads the latest release from GitHub and installs it for this Windows user.
# Run it with:  irm https://raw.githubusercontent.com/OfficialSkyefy/skyes-overlay/main/install.ps1 | iex
# Installs to %LOCALAPPDATA%\Programs\Skyes Overlay and adds Start Menu + Desktop shortcuts. No admin needed.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # Windows PowerShell's progress bar makes downloads very slow
$repo = 'OfficialSkyefy/skyes-overlay'
$dest = Join-Path $env:LOCALAPPDATA 'Programs\Skyes Overlay'
$zip = Join-Path $env:TEMP 'SkyesOverlay.zip'
$staging = Join-Path $env:TEMP 'SkyesOverlay-install'

if (Get-Process 'Skyes Desktop Alpha' -ErrorAction SilentlyContinue) {
    Write-Host 'Skyes is running. Close it (right-click its taskbar icon > Close window), then run this again.' -ForegroundColor Yellow
    return
}
Write-Host 'Downloading the latest Skyes Overlay...'
Invoke-WebRequest "https://github.com/$repo/releases/latest/download/SkyesOverlay.zip" -OutFile $zip -UseBasicParsing
Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
Expand-Archive $zip $staging -Force
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item (Join-Path $staging 'Skyes Desktop Alpha\*') $dest -Recurse -Force
Remove-Item $zip, $staging -Recurse -Force -ErrorAction SilentlyContinue

$exe = Join-Path $dest 'Skyes Desktop Alpha.exe'
$shell = New-Object -ComObject WScript.Shell
foreach ($folder in [Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop')) {
    $link = $shell.CreateShortcut((Join-Path $folder 'Skyes Overlay.lnk'))
    $link.TargetPath = $exe
    $link.WorkingDirectory = $dest
    $link.Save()
}
Write-Host "Installed to $dest. Starting Skyes..." -ForegroundColor Green
Start-Process $exe
