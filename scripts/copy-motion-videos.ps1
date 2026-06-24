param(
  [string]$SourceDir = "C:\Users\minye\motion_data\data\inter-x\vis_all",
  [string]$DataDir = "..\data",
  [string]$OutputDir = "..\assets\videos"
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$resolvedDataDir = Resolve-Path (Join-Path $scriptDir $DataDir)
$resolvedOutputDir = Join-Path $scriptDir $OutputDir
New-Item -ItemType Directory -Force -Path $resolvedOutputDir | Out-Null

$motionNames = New-Object System.Collections.Generic.HashSet[string]

Get-ChildItem -LiteralPath $resolvedDataDir -Filter "data-quality-*.json" | ForEach-Object {
  $items = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
  foreach ($item in $items) {
    if ($item.m1.name) { [void]$motionNames.Add([string]$item.m1.name) }
    if ($item.m2.name) { [void]$motionNames.Add([string]$item.m2.name) }
  }
}

$copied = 0
$missing = 0

foreach ($name in $motionNames) {
  $fileName = "${name}_0.mp4"
  $sourcePath = Join-Path $SourceDir $fileName
  $targetPath = Join-Path $resolvedOutputDir $fileName

  if (Test-Path -LiteralPath $sourcePath) {
    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
    $copied += 1
  } else {
    Write-Warning "Missing video: $sourcePath"
    $missing += 1
  }
}

Write-Output "Copied videos: $copied"
Write-Output "Missing videos: $missing"
