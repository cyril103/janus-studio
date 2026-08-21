param(
    [string]$Prefix = $(if ($env:JANUS_STUDIO_PREFIX) {
        $env:JANUS_STUDIO_PREFIX
    } else {
        Join-Path $env:LOCALAPPDATA "JanusStudio"
    })
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command janus -ErrorAction SilentlyContinue)) {
    throw "La commande janus est nécessaire pour construire Janus Studio."
}

Push-Location $ProjectRoot
try {
    & janus build --release
    if ($LASTEXITCODE -ne 0) { throw "La construction de Janus Studio a échoué." }
} finally {
    Pop-Location
}

$Executable = Join-Path $ProjectRoot "target\release\janus-studio.exe"
if (-not (Test-Path -LiteralPath $Executable -PathType Leaf)) {
    throw "Exécutable de production introuvable: $Executable"
}

$Bin = Join-Path $Prefix "bin"
$Lib = Join-Path $Prefix "lib\janus-studio"
$Share = Join-Path $Prefix "share\janus-studio"
New-Item -ItemType Directory -Force -Path $Bin, $Lib,
    (Join-Path $Share "assets"), (Join-Path $Share "samples") | Out-Null
Copy-Item -Force -LiteralPath $Executable -Destination (Join-Path $Lib "janus-studio.exe")
Copy-Item -Recurse -Force -Path (Join-Path $ProjectRoot "assets\*") `
    -Destination (Join-Path $Share "assets")
Copy-Item -Recurse -Force -Path (Join-Path $ProjectRoot "samples\*") `
    -Destination (Join-Path $Share "samples")

$Launcher = @"
@echo off
setlocal
if not "%~2"=="" (
  echo usage: janus-studio [dossier-ou-fichier] 1>&2
  exit /b 2
)
set "target=%~f1"
if "%~1"=="" set "target=%CD%"
set "JANUS_STUDIO_RESOURCE_DIR=%~dp0..\share\janus-studio"
"%~dp0..\lib\janus-studio\janus-studio.exe" "%target%"
set "status=%ERRORLEVEL%"
exit /b %status%
"@
Set-Content -Encoding ASCII -LiteralPath (Join-Path $Bin "janus-studio.cmd") -Value $Launcher
Set-Content -Encoding ASCII `
    -LiteralPath (Join-Path $Share ".installed-by-janus-studio") `
    -Value "janus-studio"
Copy-Item -Force -LiteralPath (Join-Path $PSScriptRoot "uninstall.ps1") `
    -Destination (Join-Path $Bin "janus-studio-uninstall.ps1")
$UninstallLauncher = @"
@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0janus-studio-uninstall.ps1" -Prefix "%~dp0.."
exit /b %ERRORLEVEL%
"@
Set-Content -Encoding ASCII `
    -LiteralPath (Join-Path $Bin "janus-studio-uninstall.cmd") `
    -Value $UninstallLauncher

$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (($UserPath -split ";") -notcontains $Bin) {
    $UpdatedPath = if ($UserPath) { "$Bin;$UserPath" } else { $Bin }
    [Environment]::SetEnvironmentVariable("Path", $UpdatedPath, "User")
    Set-Content -Encoding ASCII `
        -LiteralPath (Join-Path $Share ".path-added-by-installer") `
        -Value $Bin
    Write-Host "Le PATH utilisateur a été mis à jour; ouvrez un nouveau terminal."
}

Write-Host "Janus Studio est installé dans $Prefix."
Write-Host "Lancez-le avec : janus-studio [dossier-ou-fichier]"
