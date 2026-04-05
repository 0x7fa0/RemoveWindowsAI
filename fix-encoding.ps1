[CmdletBinding()]
param(
    [string]$RemoteUrl = 'https://raw.githubusercontent.com/zoicware/RemoveWindowsAI/main/RemoveWindowsAi.ps1',
    [string]$DestinationPath,
    [switch]$OverwriteOriginal,
    [switch]$Run
)

$ErrorActionPreference = 'Stop'

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$originalPath = Join-Path $scriptDir 'RemoveWindowsAi.ps1'

if ([string]::IsNullOrWhiteSpace($DestinationPath)) {
    if ($OverwriteOriginal) {
        $DestinationPath = $originalPath
    } else {
        $DestinationPath = Join-Path $scriptDir 'RemoveWindowsAi.fixed.ps1'
    }
}

Write-Host "Downloading script from:" -ForegroundColor Cyan
Write-Host $RemoteUrl -ForegroundColor White

$response = Invoke-WebRequest -Uri $RemoteUrl -UseBasicParsing
$content = $response.Content

$utf8Bom = New-Object System.Text.UTF8Encoding($true)
[System.IO.File]::WriteAllText($DestinationPath, $content, $utf8Bom)

Write-Host ""
Write-Host "Saved with UTF-8 BOM to:" -ForegroundColor Green
Write-Host $DestinationPath -ForegroundColor White

$bytes = [System.IO.File]::ReadAllBytes($DestinationPath)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    Write-Host "BOM verification: OK" -ForegroundColor Green
} else {
    Write-Host "BOM verification: FAILED" -ForegroundColor Red
    exit 1
}

if ($Run) {
    Write-Host ""
    Write-Host "Launching saved script..." -ForegroundColor Yellow
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $DestinationPath
}
