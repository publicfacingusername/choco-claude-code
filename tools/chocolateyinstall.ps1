$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'claude.exe'
$Url      = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.152/win32-x64/claude.exe'

Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
  -FileFullPath $exePath `
  -Url $Url `
  -Checksum 'bbea6d550bdd765c3b9e3b1fa19a49d04dd16c1687e5b21f9e0974a18b867a73' `
  -ChecksumType 'sha256'




















































