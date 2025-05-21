#!/usr/bin/env bash
# run-test.sh
# 🧪 Run all Python tests for ESPerto project in the correct virtual environment (Linux/macOS)
#
# SYNOPSIS
#     Checks for the Python virtual environment (.venv). If not present, creates it by invoking install_python_env.sh.
#     Activates the environment if not already active, then runs all Python tests using pytest.
#
# NOTES
#     Run from the project root or scripts/test folder.
#     Example usage:
#         ./scripts/test/run-test.sh
#
set -e

venv_dir="$(dirname "$0")/../../.venv"
venv_activate="$venv_dir/bin/activate"

# Check if .venv exists
if [ ! -d "$venv_dir" ]; then
    echo "[1/3] 🐍 Python virtual environment not found. Creating..."
    "$(dirname "$0")/../workload/install_python_env.sh"
fi

# Check if venv is active
if [ -z "$VIRTUAL_ENV" ] || [ "$VIRTUAL_ENV" != "$(realpath "$venv_dir")" ]; then
    echo "[2/3] ⚡ Activating Python virtual environment..."
    # shellcheck disable=SC1090
    source "$venv_activate"
fi

echo "[3/3] 🧪 Running all Python tests with pytest..."
pytest
