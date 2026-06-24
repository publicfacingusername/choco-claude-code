$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'claude.exe'
$Url      = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.178/win32-x64/claude.exe'

Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
  -FileFullPath $exePath `
  -Url $Url `
  -Checksum '8e82516a82511cb321f3aabe696e5fa6a318c43c2a74d657b867d70adf5e699b' `
  -ChecksumType 'sha256'


























































