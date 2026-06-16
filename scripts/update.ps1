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

$nuspecPath = Join-Path $repoRoot 'claude-code.nuspec'
if (-not (Test-Path -Path $nuspecPath)) {
  throw 'Could not find claude-code.nuspec.'
}

$nuspecContent = Get-Content -Path $nuspecPath -Raw
$currentVersionMatch = [regex]::Match($nuspecContent, '<version>([^<]+)</version>')
$currentVersion = if ($currentVersionMatch.Success) { $currentVersionMatch.Groups[1].Value } else { '' }

if ($currentVersion -eq $version) {
  $installPath = Join-Path $repoRoot 'tools\chocolateyinstall.ps1'
  $installContent = Get-Content -Path $installPath -Raw
  $hasDownloadUrl = $installContent -match [regex]::Escape($downloadUrl)
  $hasChecksum = $installContent -match [regex]::Escape($checksum)

  if ($hasDownloadUrl -and $hasChecksum) {
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
  Set-Content -Path $nuspecPath -Value $updatedNuspec -Encoding utf8
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

Write-Host "Updated to Claude Code $version"

# If running in GitHub Actions, set output variable to indicate whether the nuspec file was changed
if (-not $env:GITHUB_OUTPUT) {
  return
}

if (git diff --name-only -- claude-code.nuspec) {
  "changed=true" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
  "version=$version" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
} else {
  "changed=false" | Out-File -FilePath $env:GITHUB_OUTPUT -Append
}
