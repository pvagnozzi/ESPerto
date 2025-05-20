#!/usr/bin/env bash
#
# generate_cert.sh
# 🔒 Generate a self-signed SSL certificate and private key for ESPerto project (Linux/macOS/WSL)
#
#: <<'DOC'
# SYNOPSIS
#     🔒 Generates a self-signed certificate (server.crt) and private key (server.key) for ESPerto.
#
# DESCRIPTION
#     This script uses OpenSSL to create a self-signed certificate and key in the 'certs' directory,
#     and copies them to 'data/certs' for use with SPIFFS or other embedded filesystems.
#     - Certificate is valid for 365 days and uses 2048-bit RSA.
#     - Customize the subject fields as needed for your environment.
#
# NOTES
#     - Requires OpenSSL to be installed and available in PATH.
#     - Run from any location; paths are resolved automatically.
#     - Safe to run multiple times (overwrites existing files).
#
# EXAMPLE
#     ./scripts/cert/generate_cert.sh
#DOC
set -e
CERT_DIR="$(dirname "$0")/../../certs"
DATA_CERT_DIR="$(dirname "$0")/../../data/certs"
mkdir -p "$CERT_DIR"
mkdir -p "$DATA_CERT_DIR"

# Generate self-signed certificate
printf "[1/3] 🔏 Generating self-signed certificate and key...\n"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout "$CERT_DIR/server.key" \
  -out "$CERT_DIR/server.crt" \
  -subj "/C=IT/ST=Italy/L=City/O=ESP32Dev/CN=esp32.local"

# Copy to data/certs for SPIFFS
printf "[2/3] 📂 Copying certificate and key to data/certs...\n"
cp "$CERT_DIR/server.key" "$DATA_CERT_DIR/server.key"
cp "$CERT_DIR/server.crt" "$DATA_CERT_DIR/server.crt"

printf "[3/3] ✅ Certificate and key generated in $CERT_DIR and copied to $DATA_CERT_DIR.\n"
