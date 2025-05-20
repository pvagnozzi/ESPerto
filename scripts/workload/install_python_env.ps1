<#
.SYNOPSIS
    🐍 Setup Python virtual environment for ESPerto project.

.DESCRIPTION
    This script creates a Python virtual environment in the current directory,
    🚀 upgrades pip and setuptools, and installs all required packages from requirements.txt.
    It is intended for Windows PowerShell users working on the ESPerto firmware project.

.NOTES
    📂 Run this script from the project root folder.
    Example usage:
        ./scripts/workload/install_python_env.ps1
#>

$ErrorActionPreference = 'Stop'

# Set venv directory name
$venvDir = ".venv"

Write-Host "[1/4] 🐍 Creating Python virtual environment in '$venvDir'..."
python -m venv $venvDir

Write-Host "[2/4] ⚡ Activating virtual environment..."
$activateScript = Join-Path $venvDir "Scripts\Activate.ps1"
. $activateScript

Write-Host "[3/4] ⬆️  Upgrading pip and setuptools..."
pip install --upgrade pip setuptools

Write-Host "[4/4] 📦 Installing requirements from requirements.txt..."
pip install -r requirements.txt

Write-Host "`n✅ Python environment setup complete! To activate later, run:`n. $venvDir\Scripts\Activate.ps1"
