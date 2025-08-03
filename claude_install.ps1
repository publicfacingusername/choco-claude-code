param(
    [Parameter(Position=0)]
    [ValidatePattern('^(stable|latest|\d+\.\d+\.\d+(-[^\s]+)?)$')]
    [string]$Target = "stable"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$ProgressPreference = 'SilentlyContinue'

# Check for 32-bit Windows
if (-not [Environment]::Is64BitProcess) {
    Write-Error "Claude Code does not support 32-bit Windows. Please use a 64-bit version of Windows."
    exit 1
}

$GCS_BUCKET = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
$DOWNLOAD_DIR = "$env:USERPROFILE\.claude\downloads"

# Always use x64 for Windows (ARM64 Windows can run x64 through emulation)
$platform = "win32-x64"
New-Item -ItemType Directory -Force -Path $DOWNLOAD_DIR | Out-Null

# Always download stable version (which has the most up-to-date installer)
try {
    $version = Invoke-RestMethod -Uri "$GCS_BUCKET/stable" -ErrorAction Stop
}
catch {
    Write-Error "Failed to get stable version: $_"
    exit 1
}

try {
    $manifest = Invoke-RestMethod -Uri "$GCS_BUCKET/$version/manifest.json" -ErrorAction Stop
    $checksum = $manifest.platforms.$platform.checksum

    if (-not $checksum) {
        Write-Error "Platform $platform not found in manifest"
        exit 1
    }
}
catch {
    Write-Error "Failed to get manifest: $_"
    exit 1
}

# Download and verify
$binaryPath = "$DOWNLOAD_DIR\claude-$version-$platform.exe"
try {
    Invoke-WebRequest -Uri "$GCS_BUCKET/$version/$platform/claude.exe" -OutFile $binaryPath -ErrorAction Stop
}
catch {
    Write-Error "Failed to download binary: $_"
    if (Test-Path $binaryPath) {
        Remove-Item -Force $binaryPath
    }
    exit 1
}

# Calculate checksum
$actualChecksum = (Get-FileHash -Path $binaryPath -Algorithm SHA256).Hash.ToLower()

if ($actualChecksum -ne $checksum) {
    Write-Error "Checksum verification failed"
    Remove-Item -Force $binaryPath
    exit 1
}

# Run claude install to set up launcher and shell integration
Write-Output "Setting up Claude Code..."
try {
    if ($Target) {
        & $binaryPath install $Target
    }
    else {
        & $binaryPath install
    }
}
finally {
    # Clean up downloaded file
    if (Test-Path $binaryPath) {
        try {
            # Wait a moment for any file handles to be released
            Start-Sleep -Milliseconds 100
        }
        catch {
            Write-Warning "Could not remove temporary file: $binaryPath"
        }
    }
}

Write-Output ""
Write-Output "$([char]0x2705) Installation complete!"
Write-Output ""
