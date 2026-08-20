param(
    [string]$Prefix = $(if ($env:JANUS_STUDIO_PREFIX) {
        $env:JANUS_STUDIO_PREFIX
    } else {
        Join-Path $env:LOCALAPPDATA "JanusStudio"
    })
)

$ErrorActionPreference = "Stop"
$Bin = Join-Path $Prefix "bin"
$Lib = Join-Path $Prefix "lib\janus-studio"
$Share = Join-Path $Prefix "share\janus-studio"
$Marker = Join-Path $Share ".installed-by-janus-studio"
$PathMarker = Join-Path $Share ".path-added-by-installer"

if (-not (Test-Path -LiteralPath $Marker -PathType Leaf)) {
    Write-Host "Janus Studio n'est pas installé dans $Prefix."
    exit 0
}

$RemoveFromPath = Test-Path -LiteralPath $PathMarker -PathType Leaf
Remove-Item -Force -ErrorAction SilentlyContinue `
    -LiteralPath (Join-Path $Bin "janus-studio.cmd"), `
        (Join-Path $Bin "janus-studio-uninstall.cmd"), `
        (Join-Path $Bin "janus-studio-uninstall.ps1")
Remove-Item -Recurse -Force -LiteralPath $Lib, $Share

if ($RemoveFromPath) {
    $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $UpdatedEntries = @($UserPath -split ";" | Where-Object {
        $_ -and $_ -ne $Bin
    })
    [Environment]::SetEnvironmentVariable(
        "Path",
        [string]::Join(";", $UpdatedEntries),
        "User"
    )
    Write-Host "Le PATH utilisateur a été mis à jour; ouvrez un nouveau terminal."
}

foreach ($Directory in @(
    (Join-Path $Prefix "lib"),
    (Join-Path $Prefix "share"),
    $Bin,
    $Prefix
)) {
    if ((Test-Path -LiteralPath $Directory -PathType Container) -and
        -not (Get-ChildItem -Force -LiteralPath $Directory)) {
        Remove-Item -Force -LiteralPath $Directory
    }
}

Write-Host "Janus Studio a été désinstallé de $Prefix."
