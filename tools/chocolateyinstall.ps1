$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$exePath  = Join-Path $toolsDir 'claude.exe'
$Url      = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.19/win32-x64/claude.exe'

Get-ChocolateyWebFile -PackageName $env:ChocolateyPackageName `
  -FileFullPath $exePath `
  -Url $Url `
  -Checksum '68cf03a1fd538ceedbfbf139b886d146cf9af47aae22f8eac957ecefd2328930' `
  -ChecksumType 'sha256'









