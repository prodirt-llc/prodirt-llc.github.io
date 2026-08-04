<#
  harvest-shots.ps1 — pull an app's Play Store screenshots into <appdir>\shots\.

  PowerShell port of harvest-shots.sh (no bash needed). Play serves listing
  screenshots from play-lh.googleusercontent.com at a resizable URL; we pull
  "=w540" (web-weight, ~800KB vs 2-3MB originals) and still crisp at the
  gallery's display size. These are your own assets. Run this AFTER refreshing
  the Play listing so it grabs the new screenshots, not the ones you replaced.

  Usage (from the repo root):
    powershell -ExecutionPolicy Bypass -File tools\harvest-shots.ps1            # all apps
    powershell -ExecutionPolicy Bypass -File tools\harvest-shots.ps1 colorseeker # one app

  Trailer Boss is in testing (no public listing) — add its shots by hand.
#>
param([string]$Only = "")

$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Safari/537.36"
$Root = Split-Path -Parent $PSScriptRoot   # tools\ -> repo root
$WebSize = "w540"                           # play-lh resize suffix for downloads

# site-folder -> package-id
$Apps = @(
  @{ dir = "bloodhound";     pkg = "bloodhound.com.bloodhound" },
  @{ dir = "fieldquote";     pkg = "com.prodirt.fieldquote" },
  @{ dir = "trailmapper";    pkg = "com.prodirt.trailmapper" },
  @{ dir = "bandpass";       pkg = "com.bandpass" },
  @{ dir = "colorseeker";    pkg = "com.colorseeker" },
  @{ dir = "kiteforcepro";   pkg = "com.kiteforcepro" },
  @{ dir = "evenspacing";    pkg = "even.spacingcalculator" },
  @{ dir = "FractionPro";    pkg = "com.prodirt.fractionpro" },
  @{ dir = "StrikeAnalyzer"; pkg = "com.prodirt.strikeanalyzer" }
)

function Harvest($dir, $pkg) {
  $out = Join-Path $Root "$dir\shots"
  Write-Host "== $dir ($pkg)"
  try {
    $html = (Invoke-WebRequest -Uri "https://play.google.com/store/apps/details?id=$pkg&hl=en&gl=US" `
             -UserAgent $UA -UseBasicParsing).Content
  } catch { Write-Host "   ! fetch failed"; return }

  # Screenshots render in the grid at the =w526-h296 thumb size; the icon and
  # feature graphic use other suffixes. Preserve document order, dedupe.
  $seen = New-Object System.Collections.Generic.List[string]
  foreach ($m in [regex]::Matches($html, 'https://play-lh\.googleusercontent\.com/[A-Za-z0-9_-]+=w526-h296')) {
    $base = $m.Value -replace '=w526-h296$', ''
    if (-not $seen.Contains($base)) { $seen.Add($base) | Out-Null }
  }
  if ($seen.Count -eq 0) { Write-Host "   ! no screenshots found (listing public?)"; return }

  New-Item -ItemType Directory -Force -Path $out | Out-Null
  Get-ChildItem -Path $out -Filter *.png -ErrorAction SilentlyContinue | Remove-Item -Force
  $i = 1
  foreach ($base in $seen) {
    $dest = Join-Path $out "$i.png"
    try {
      Invoke-WebRequest -Uri "$base=$WebSize" -OutFile $dest -UserAgent $UA -UseBasicParsing
      Write-Host "   -> shots\$i.png"
    } catch { Write-Host "   ! $i failed" }
    $i++
  }
  Write-Host "   done: $($i - 1) screenshot(s)"
}

foreach ($a in $Apps) {
  if ($Only -and $Only -ne $a.dir) { continue }
  Harvest $a.dir $a.pkg
}
Write-Host "All done."
