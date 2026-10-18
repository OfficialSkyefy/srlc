# SRLC (Skye's Rocket League Companion) installer: downloads the latest release from GitHub and installs it for this Windows user.
# Run it with:  irm https://raw.githubusercontent.com/OfficialSkyefy/srlc/main/install.ps1 | iex
# Installs to %LOCALAPPDATA%\Programs\Skyes Overlay (the folder keeps its original name so existing installs update in place)
# and adds Start Menu + Desktop shortcuts. No admin needed.
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'  # Windows PowerShell's progress bar makes downloads very slow
$repo = 'OfficialSkyefy/srlc'
$dest = Join-Path $env:LOCALAPPDATA 'Programs\Skyes Overlay'
$zip = Join-Path $env:TEMP 'SkyesOverlay.zip'
$staging = Join-Path $env:TEMP 'SkyesOverlay-install'

Write-Host ''
Write-Host "SRLC installer (Skye's Rocket League Companion)" -ForegroundColor Cyan
if (Get-Process 'Skyes Desktop Alpha' -ErrorAction SilentlyContinue) {
    Write-Host 'SRLC is running. Close it (right-click its taskbar icon > Close window), then run this again.' -ForegroundColor Yellow
    return
}

Write-Host '[1/3] Downloading the latest version (about 190 MB, usually under a minute)...'
$timer = [Diagnostics.Stopwatch]::StartNew()
Invoke-WebRequest "https://github.com/$repo/releases/latest/download/SkyesOverlay.zip" -OutFile $zip -UseBasicParsing
Write-Host ('      Downloaded {0:N0} MB in {1:N0} s.' -f ((Get-Item $zip).Length / 1MB), $timer.Elapsed.TotalSeconds) -ForegroundColor DarkGray

Write-Host '[2/3] Installing...'
$timer.Restart()
Add-Type -AssemblyName System.IO.Compression.FileSystem  # much faster than Expand-Archive for thousands of files
Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
[IO.Compression.ZipFile]::ExtractToDirectory($zip, $staging)
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item (Join-Path $staging 'Skyes Desktop Alpha\*') $dest -Recurse -Force
Remove-Item $zip, $staging -Recurse -Force -ErrorAction SilentlyContinue
Write-Host ('      Installed to {0} in {1:N0} s.' -f $dest, $timer.Elapsed.TotalSeconds) -ForegroundColor DarkGray

Write-Host '[3/3] Adding Start Menu and Desktop shortcuts...'
$exe = Join-Path $dest 'Skyes Desktop Alpha.exe'
$shell = New-Object -ComObject WScript.Shell
foreach ($folder in [Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop')) {
    Remove-Item (Join-Path $folder 'Skyes Overlay.lnk') -ErrorAction SilentlyContinue  # old name
    $link = $shell.CreateShortcut((Join-Path $folder 'SRLC.lnk'))
    $link.TargetPath = $exe
    $link.WorkingDirectory = $dest
    $link.Save()
}

Write-Host ''
Write-Host 'Done! Starting SRLC. Next time, open it from the "SRLC" shortcut. It updates itself.' -ForegroundColor Green
Start-Process $exe
