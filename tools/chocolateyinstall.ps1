$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'claude.exe'
$Url      = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.132/win32-x64/claude.exe'

Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
  -FileFullPath $exePath `
  -Url $Url `
  -Checksum '9e24fc289828968ce3411fafaee42d4484d3e34b63e873358ede4395aceb1b33' `
  -ChecksumType 'sha256'








































