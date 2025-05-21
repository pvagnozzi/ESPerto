# run-test.ps1
<#+
.SYNOPSIS
    Run all Python tests for ESPerto project in the correct virtual environment.
.DESCRIPTION
    This script checks if the Python virtual environment (.venv) exists. If not, it creates it by invoking install_python_env.ps1.
    It then activates the environment (if not already active) and runs all Python tests using pytest.
.NOTES
    Run from the project root or scripts/test folder.
    Example usage:
        ./scripts/test/run-test.ps1
#>

$venvDir = Join-Path $PSScriptRoot "..\..\.venv"
$venvActivate = Join-Path $venvDir "Scripts\Activate.ps1"
$pythonExe = Join-Path $venvDir "Scripts\python.exe"

# Check if .venv exists
if (-not (Test-Path $venvDir)) {
    Write-Host "[1/3] 🐍 Python virtual environment not found. Creating..."
    & "$PSScriptRoot\..\workload\install_python_env.ps1"
}

# Check if venv is active (by comparing $env:VIRTUAL_ENV)
if (-not $env:VIRTUAL_ENV -or ($env:VIRTUAL_ENV -ne (Resolve-Path $venvDir))) {
    Write-Host "[2/3] ⚡ Activating Python virtual environment..."
    . $venvActivate
}

Write-Host "[3/3] 🧪 Running all Python tests with pytest..."
pytest
