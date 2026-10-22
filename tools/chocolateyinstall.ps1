$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'claude.exe'
$UrlX64         = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.308/win32-x64/claude.exe'
$ChecksumX64    = 'c9796ba22a9221586b36371b36f5b66198d66eb4badf6a4cf4a5f7b07becea53'
$UrlArm64       = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.308/win32-arm64/claude.exe'
$ChecksumArm64  = '35b5af5dde46a775ccd5a4d15760913c6088cf7292e1b15f0b09b1fd3f93bfd2'

# Chocolatey runs as an emulated x64 process on ARM64 Windows, so PROCESSOR_ARCHITECTURE reads AMD64 there; the CPU name does not.
$isArm64 = [bool]($env:PROCESSOR_IDENTIFIER -like 'ARMv*')

Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
  -FileFullPath $exePath `
  -Url $(if ($isArm64) { $UrlArm64 } else { $UrlX64 }) `
  -Checksum $(if ($isArm64) { $ChecksumArm64 } else { $ChecksumX64 }) `
  -ChecksumType 'sha256'
