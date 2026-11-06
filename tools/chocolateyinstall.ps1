$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'claude.exe'
$UrlX64         = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.311/win32-x64/claude.exe'
$ChecksumX64    = '966f4b2ce962298f5dee6a942e8c47c8f97392e69e728e622319a98b259c0680'
$UrlArm64       = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.311/win32-arm64/claude.exe'
$ChecksumArm64  = '951b5d94bf2a5296db2c442784e68d18fa04dec2d7d2e805aa50e75d618aad5e'

# Chocolatey runs as an emulated x64 process on ARM64 Windows, so PROCESSOR_ARCHITECTURE reads AMD64 there; the CPU name does not.
$isArm64 = [bool]($env:PROCESSOR_IDENTIFIER -like 'ARMv*')

Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
  -FileFullPath $exePath `
  -Url $(if ($isArm64) { $UrlArm64 } else { $UrlX64 }) `
  -Checksum $(if ($isArm64) { $ChecksumArm64 } else { $ChecksumX64 }) `
  -ChecksumType 'sha256'
