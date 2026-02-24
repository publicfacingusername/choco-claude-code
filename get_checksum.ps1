$url = 'https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/2.1.44/win32-x64/claude.exe'
$f = "$env:TEMP\claude.exe"; Invoke-WebRequest $url -OutFile $f; (Get-FileHash $f -Algorithm SHA256).Hash; Remove-Item $f















