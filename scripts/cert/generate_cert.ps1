<#
.SYNOPSIS
    🔒 Generate a self-signed SSL certificate and private key for ESPerto project.

.DESCRIPTION
    This script creates a self-signed certificate (server.crt) and private key (server.key)
    using OpenSSL. The files are generated in the 'certs' directory and copied to 'data/certs'
    for use with SPIFFS or other embedded filesystems.

.NOTES
    - Requires OpenSSL to be installed and available in PATH.
    - Run this script from any location; paths are resolved automatically.
    - Certificate is valid for 365 days and uses 2048-bit RSA.
    - Customize the subject fields as needed for your environment.

.EXAMPLE
    ./scripts/cert/generate_cert.ps1
#>

$certDir = Join-Path $PSScriptRoot "..\..\certs"
$dataCertDir = Join-Path $PSScriptRoot "..\..\data\certs"
New-Item -ItemType Directory -Force -Path $certDir | Out-Null
New-Item -ItemType Directory -Force -Path $dataCertDir | Out-Null

$certPath = Join-Path $certDir "server.crt"
$keyPath = Join-Path $certDir "server.key"

# Generate self-signed certificate
Write-Host "[1/3] 🔏 Generating self-signed certificate and key..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
  -keyout $keyPath `
  -out $certPath `
  -subj "/C=IT/ST=Italy/L=City/O=ESP32Dev/CN=esp32.local"

# Copy to data/certs for SPIFFS
Write-Host "[2/3] 📂 Copying certificate and key to data/certs..."
Copy-Item $keyPath (Join-Path $dataCertDir "server.key") -Force
Copy-Item $certPath (Join-Path $dataCertDir "server.crt") -Force

Write-Host "[3/3] ✅ Certificate and key generated in $certDir and copied to $dataCertDir."
