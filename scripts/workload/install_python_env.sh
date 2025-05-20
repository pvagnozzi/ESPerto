#!/usr/bin/env bash
#
# install_python_env.sh
# 🐍 Setup Python virtual environment for ESPerto project (Linux/macOS)
#
# SYNOPSIS
#     🐍 Creates a Python virtual environment, upgrades pip and setuptools, and installs requirements.
#
# DESCRIPTION
#     This script creates a Python virtual environment in the current directory,
#     upgrades pip and setuptools, and installs all required packages from requirements.txt.
#     It is intended for Linux/macOS users working on the ESPerto firmware project.
#
# NOTES
#     📂 Run this script from the project root folder.
#     Example usage:
#         ./scripts/workload/install_python_env.sh
#
set -e

venv_dir=".venv"

printf "[1/4] 🐍 Creating Python virtual environment in '%s'...\n" "$venv_dir"
python3 -m venv "$venv_dir"

printf "[2/4] ⚡ Activating virtual environment...\n"
# shellcheck disable=SC1090
source "$venv_dir/bin/activate"

printf "[3/4] ⬆️  Upgrading pip and setuptools...\n"
pip install --upgrade pip setuptools

printf "[4/4] 📦 Installing requirements from requirements.txt...\n"
pip install -r requirements.txt

printf "\n✅ Python environment setup complete! To activate later, run:\nsource %s/bin/activate\n" "$venv_dir"
