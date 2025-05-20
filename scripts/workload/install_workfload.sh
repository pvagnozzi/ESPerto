#!/usr/bin/env bash

# install_workfload.sh
# Idempotent script to install/upgrade Git, VSCode, Docker, PowerShell, and developer tools on Linux/macOS/WSL
# Uses Homebrew, apt, dnf, and other package managers as available

: <<'DOC'
SYNOPSIS
    Installs or upgrades essential developer tools for the ESPerto project on Linux, macOS, or WSL.

DESCRIPTION
    This script installs or upgrades the following tools using the best available package manager:
      - Homebrew (macOS/Linux)
      - Scoop and Chocolatey (WSL/Windows)
      - Git
      - Visual Studio Code
      - Docker
      - PowerShell
      - OpenSSL
      - FiraCode Nerd Font (for terminal/dev UX)
      - Oh My Posh (prompt theme)
    It also configures Oh My Posh in your shell profile for a modern terminal experience.
    The script is idempotent: it will not reinstall tools that are already present, but will upgrade them if possible.

NOTES
    - Run this script from the project root or any folder.
    - Safe to run multiple times.
    - Supports macOS, Linux, and WSL environments.
    - Some steps may require sudo privileges.

EXAMPLE
    # Run from your shell:
    ./scripts/workload/install_workfload.sh
DOC

set -e

# Colors and emoji
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Helper: print with color and emoji
info() { echo -e "${CYAN}🔎 $1${RESET}"; }
success() { echo -e "${GREEN}✅ $1${RESET}"; }
warn() { echo -e "${YELLOW}⚠️  $1${RESET}"; }
step() { echo -e "${MAGENTA}$1${RESET}"; }

# Idempotent install/upgrade Homebrew
install_or_upgrade_brew() {
    if ! command -v brew &> /dev/null; then
        step "🍺 Installing Homebrew..."
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$($(command -v brew) shellenv)"
    else
        step "🍺 Homebrew already installed. Upgrading..."
        brew update && brew upgrade
    fi
}

# Idempotent install/upgrade Scoop (only on Windows, but check for WSL)
install_or_upgrade_scoop() {
    if [[ "$OS" == "Linux" && -n "$WSL_DISTRO_NAME" ]]; then
        if ! command -v scoop &> /dev/null; then
            step "🛒 Installing Scoop (WSL only)..."
            pwsh -Command "Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; irm get.scoop.sh | iex"
        else
            step "🛒 Scoop already installed. Updating..."
            scoop update
        fi
    fi
}

# Idempotent install/upgrade Chocolatey (only on Windows, but check for WSL)
install_or_upgrade_choco() {
    if [[ "$OS" == "Linux" && -n "$WSL_DISTRO_NAME" ]]; then
        if ! command -v choco &> /dev/null; then
            step "🍫 Installing Chocolatey (WSL only)..."
            pwsh -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        else
            step "🍫 Chocolatey already installed. Upgrading..."
            choco upgrade chocolatey -y
        fi
    fi
}

# Idempotent install/upgrade Git
install_or_upgrade_git() {
    if ! command -v git &> /dev/null; then
        step "🔄 Installing Git..."
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y git
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y git
        elif [ -x "$(command -v brew)" ]; then
            brew install git
        else
            warn "Unsupported package manager for Git. Please install manually."
        fi
    else
        step "🔄 Git already installed. Upgrading..."
        if [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y git
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf upgrade -y git
        elif [ -x "$(command -v brew)" ]; then
            brew upgrade git
        fi
    fi
}

# Idempotent install/upgrade VSCode
install_or_upgrade_vscode() {
    if ! command -v code &> /dev/null; then
        step "🖥️  Installing Visual Studio Code..."
        if [ "$OS" = "Darwin" ]; then
            brew install --cask visual-studio-code
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y wget gpg
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
            sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
            sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
            sudo apt-get update && sudo apt-get install -y code
            rm microsoft.gpg
        elif [ -x "$(command -v dnf)" ]; then
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
            sudo dnf check-update || true
            sudo dnf install -y code
        elif [ -x "$(command -v brew)" ]; then
            brew install --cask visual-studio-code
        else
            warn "Unsupported package manager for VSCode. Please install manually."
        fi
    else
        step "🖥️  Visual Studio Code already installed. Upgrading..."
        if [ "$OS" = "Darwin" ]; then
            brew upgrade --cask visual-studio-code
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y code
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf upgrade -y code
        elif [ -x "$(command -v brew)" ]; then
            brew upgrade --cask visual-studio-code
        fi
    fi
}

# Idempotent install/upgrade Docker
install_or_upgrade_docker() {
    if ! command -v docker &> /dev/null; then
        step "🐳 Installing Docker..."
        if [ "$OS" = "Darwin" ]; then
            brew install --cask docker
            success "Please launch Docker Desktop from Applications after installation."
        elif [ -x "$(command -v apt-get)" ]; then
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            rm get-docker.sh
            sudo usermod -aG docker "$USER"
            success "Docker installed. You may need to log out and log back in for group changes to take effect."
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y docker
            sudo systemctl enable --now docker
            sudo usermod -aG docker "$USER"
            success "Docker installed. You may need to log out and log back in for group changes to take effect."
        elif [ -x "$(command -v brew)" ]; then
            brew install --cask docker
            success "Please launch Docker Desktop from Applications after installation."
        else
            warn "Unsupported package manager for Docker. Please install manually."
        fi
    else
        step "🐳 Docker already installed. Upgrading..."
        if [ "$OS" = "Darwin" ]; then
            brew upgrade --cask docker
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y docker
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf upgrade -y docker
        elif [ -x "$(command -v brew)" ]; then
            brew upgrade --cask docker
        fi
    fi
}

# Idempotent install/upgrade PowerShell
install_or_upgrade_powershell() {
    if ! command -v pwsh &> /dev/null; then
        step "💠 Installing PowerShell..."
        if [ "$OS" = "Darwin" ]; then
            brew install --cask powershell
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y wget apt-transport-https software-properties-common
            wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
            sudo dpkg -i packages-microsoft-prod.deb
            sudo apt-get update && sudo apt-get install -y powershell
            rm packages-microsoft-prod.deb
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y powershell
        elif [ -x "$(command -v brew)" ]; then
            brew install --cask powershell
        else
            warn "Unsupported package manager for PowerShell. Please install manually."
        fi
    else
        step "💠 PowerShell already installed. Upgrading..."
        if [ "$OS" = "Darwin" ]; then
            brew upgrade --cask powershell
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y powershell
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf upgrade -y powershell
        elif [ -x "$(command -v brew)" ]; then
            brew upgrade --cask powershell
        fi
    fi
}

# Idempotent install/upgrade Nerd Font (FiraCode)
install_or_upgrade_nerdfont() {
    if [ "$OS" = "Darwin" ]; then
        if ! fc-list | grep -qi "FiraCode Nerd Font"; then
            step "🔤 Installing FiraCode Nerd Font..."
            brew tap homebrew/cask-fonts
            brew install --cask font-firacode-nerd-font
        else
            step "🔤 FiraCode Nerd Font already installed."
        fi
    elif [ -x "$(command -v apt-get)" ]; then
        if ! fc-list | grep -qi "FiraCode Nerd Font"; then
            step "🔤 Installing FiraCode Nerd Font..."
            wget -O /tmp/FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
            mkdir -p ~/.local/share/fonts
            unzip -o /tmp/FiraCode.zip -d ~/.local/share/fonts/
            fc-cache -fv
            rm /tmp/FiraCode.zip
        else
            step "🔤 FiraCode Nerd Font already installed."
        fi
    fi
}

# Idempotent install/upgrade Oh My Posh
install_or_upgrade_ohmyposh() {
    if ! command -v oh-my-posh &> /dev/null; then
        step "💎 Installing Oh My Posh..."
        if [ "$OS" = "Darwin" ]; then
            brew install oh-my-posh
        elif [ -x "$(command -v apt-get)" ]; then
            sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
            sudo chmod +x /usr/local/bin/oh-my-posh
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y oh-my-posh
        elif [ -x "$(command -v brew)" ]; then
            brew install oh-my-posh
        else
            warn "Unsupported package manager for Oh My Posh. Please install manually."
        fi
    else
        step "💎 Oh My Posh already installed. Upgrading..."
        if [ "$OS" = "Darwin" ]; then
            brew upgrade oh-my-posh
        elif [ -x "$(command -v apt-get)" ]; then
            sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
            sudo chmod +x /usr/local/bin/oh-my-posh
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf upgrade -y oh-my-posh
        elif [ -x "$(command -v brew)" ]; then
            brew upgrade oh-my-posh
        fi
    fi
}

# Install or upgrade OpenSSL
install_or_upgrade_openssl() {
    if ! command -v openssl &> /dev/null; then
        step "🔒 Installing OpenSSL..."
        if [ "$OS" = "Darwin" ]; then
            brew install openssl
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y openssl
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf install -y openssl
        elif [ -x "$(command -v brew)" ]; then
            brew install openssl
        else
            warn "Unsupported package manager for OpenSSL. Please install manually."
        fi
    else
        step "🔒 OpenSSL already installed. Upgrading..."
        if [ "$OS" = "Darwin" ]; then
            brew upgrade openssl
        elif [ -x "$(command -v apt-get)" ]; then
            sudo apt-get update && sudo apt-get install -y openssl
        elif [ -x "$(command -v dnf)" ]; then
            sudo dnf upgrade -y openssl
        elif [ -x "$(command -v brew)" ]; then
            brew upgrade openssl
        fi
    fi
}

# Configure Oh My Posh for current user
configure_ohmyposh_profile() {
    local profile_file
    if [ "$SHELL" = "/bin/zsh" ]; then
        profile_file="$HOME/.zshrc"
    else
        profile_file="$HOME/.bashrc"
    fi
    if ! grep -q 'oh-my-posh init' "$profile_file"; then
        step "✨ Adding Oh My Posh initialization to $profile_file..."
        echo 'eval "$(oh-my-posh init $SHELL --config \"$(oh-my-posh get shell-path $SHELL)\")"' >> "$profile_file"
    else
        step "✨ Oh My Posh already configured in $profile_file."
    fi
}

# Main
OS="$(uname -s)"
info "Starting workload installation for $OS..."

install_or_upgrade_brew
install_or_upgrade_scoop
install_or_upgrade_choco
install_or_upgrade_git
install_or_upgrade_vscode
install_or_upgrade_docker
install_or_upgrade_powershell
install_or_upgrade_nerdfont
install_or_upgrade_ohmyposh
install_or_upgrade_openssl
configure_ohmyposh_profile

success "Installation/upgrade completed!"