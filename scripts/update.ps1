$ErrorActionPreference = 'Stop'

$baseUrl = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819'
$releaseBase = "$baseUrl/claude-code-releases"

$version = (Invoke-RestMethod -Uri "$releaseBase/stable").Trim()
if ([string]::IsNullOrWhiteSpace($version)) {
  throw 'Stable version lookup returned an empty value.'
}

$manifest = Invoke-RestMethod -Uri "$releaseBase/$version/manifest.json"
$checksum = $manifest.platforms.'win32-x64'.checksum
if ([string]::IsNullOrWhiteSpace($checksum)) {
  throw "Manifest missing win32-x64 checksum for $version."
}

$downloadUrl = "$releaseBase/$version/win32-x64/claude.exe"
$repoRoot = Split-Path -Parent $PSScriptRoot

$nuspec = Get-ChildItem -Path $repoRoot -Filter 'claude-code-*.nuspec' | Select-Object -First 1
if (-not $nuspec) {
  throw 'Could not find a claude-code nuspec file.'
}

$nuspecContent = Get-Content -Path $nuspec.FullName -Raw
$currentVersionMatch = [regex]::Match($nuspecContent, '<version>([^<]+)</version>')
$currentVersion = if ($currentVersionMatch.Success) { $currentVersionMatch.Groups[1].Value } else { '' }

$expectedNuspecName = "claude-code-$version.nuspec"
if ($currentVersion -eq $version -and $nuspec.Name -eq $expectedNuspecName) {
  $installPath = Join-Path $repoRoot 'tools\chocolateyinstall.ps1'
  $installContent = Get-Content -Path $installPath -Raw
  $hasDownloadUrl = $installContent -match [regex]::Escape($downloadUrl)
  $hasChecksum = $installContent -match [regex]::Escape($checksum)

  $checksumPath = Join-Path $repoRoot 'get_checksum.ps1'
  $checksumContent = Get-Content -Path $checksumPath -Raw
  $hasChecksumUrl = $checksumContent -match [regex]::Escape($downloadUrl)

  if ($hasDownloadUrl -and $hasChecksum -and $hasChecksumUrl) {
    Write-Host "Claude Code is already at $version. No update needed."
    return
  }
}

$updatedNuspec = [regex]::Replace(
  $nuspecContent,
  '<version>[^<]+</version>',
  "<version>$version</version>"
)
if ($updatedNuspec -ne $nuspecContent) {
  Set-Content -Path $nuspec.FullName -Value $updatedNuspec -Encoding utf8
}

if ($nuspec.Name -ne $expectedNuspecName) {
  Rename-Item -Path $nuspec.FullName -NewName $expectedNuspecName
}

$installPath = Join-Path $repoRoot 'tools\chocolateyinstall.ps1'
$installContent = Get-Content -Path $installPath -Raw
$installContent = [regex]::Replace(
  $installContent,
  'https://storage.googleapis.com/.+?/claude-code-releases/[^/]+/win32-x64/claude.exe',
  $downloadUrl
)
$installContent = [regex]::Replace(
  $installContent,
  "-Checksum\s+'[^']+'",
  "-Checksum '$checksum'"
)
Set-Content -Path $installPath -Value $installContent -Encoding utf8

$checksumPath = Join-Path $repoRoot 'get_checksum.ps1'
$checksumContent = Get-Content -Path $checksumPath -Raw
$checksumContent = [regex]::Replace(
  $checksumContent,
  'https?://storage.googleapis.com/.+?/claude-code-releases/[^/]+/win32-x64/claude.exe',
  $downloadUrl
)
$checksumContent = $checksumContent -replace 'Windsurf.exe', 'claude.exe'
Set-Content -Path $checksumPath -Value $checksumContent -Encoding utf8

Write-Host "Updated to Claude Code $version"
