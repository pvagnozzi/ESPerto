# install_workload.ps1
# Idempotent script to install/upgrade Git, VSCode, Docker, PowerShell, and developer tools on Windows
# Uses winget, Chocolatey, Homebrew, and Scoop for package management

<#+
.SYNOPSIS
    Installs or upgrades essential developer tools for the ESPerto project on Windows.

.DESCRIPTION
    This script checks for administrator privileges and uses Windows package managers (winget, Chocolatey, Homebrew, Scoop)
    to install or upgrade the following tools:
      - Git
      - Visual Studio Code
      - Docker Desktop
      - PowerShell (latest)
      - OpenSSL
      - Chocolatey
      - Homebrew
      - Scoop
      - FiraCode Nerd Font (for terminal/dev UX)
      - Oh My Posh (prompt theme)
    It also configures Oh My Posh in your PowerShell profile for a modern terminal experience.
    The script is idempotent: it will not reinstall tools that are already present, but will upgrade them if possible.

.NOTES
    - Must be run as administrator (will auto-relaunch if not).
    - Requires Windows 10/11 with winget available.
    - Run from the project root or any folder.
    - Safe to run multiple times.

.EXAMPLE
    # Run from PowerShell as administrator:
    ./scripts/workload/install_workload.ps1
#>

# Check if the script is running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "\n\e[93m⚠️  This script must be run as administrator. Relaunching with elevated privileges...\e[0m\n"
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File '" + $MyInvocation.MyCommand.Definition + "'"
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

function Test-Winget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "\e[91m❌ Winget not found. Manual installation required.\e[0m"
        exit 1
    }
}

function Install-Or-Upgrade {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )
    $installed = winget list --id $PackageId | Select-String $PackageId
    if ($installed) {
        Write-Host "\e[96m🔄 $DisplayName already installed. Upgrading...\e[0m"
        winget upgrade --id $PackageId --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "\e[92m⬇️  $DisplayName not found. Installing...\e[0m"
        winget install --id $PackageId --accept-source-agreements --accept-package-agreements
    }
}

# Install or upgrade Chocolatey
function Install-Choco {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "\e[95m🍫 Chocolatey not found. Installing...\e[0m"
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    } else {
        Write-Host "\e[96m🍫 Chocolatey already installed. Upgrading...\e[0m"
        choco upgrade chocolatey -y
    }
}

# Install or upgrade Homebrew
function Install-Homebrew {
    if (-not (Get-Command brew -ErrorAction SilentlyContinue)) {
        Write-Host "\e[95m🍺 Homebrew not found. Installing...\e[0m"
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Homebrew/install/HEAD/install.ps1'))
    } else {
        Write-Host "\e[96m🍺 Homebrew already installed. Upgrading...\e[0m"
        brew update
        brew upgrade
    }
}

# Install or upgrade Scoop
function Install-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "\e[95m🛒 Scoop not found. Installing...\e[0m"
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        irm get.scoop.sh | iex
    } else {
        Write-Host "\e[96m🛒 Scoop already installed. Updating...\e[0m"
        scoop update
    }
}

# Install or upgrade Nerd Fonts (FiraCode as example)
function Install-NerdFont {
    $fontName = "FiraCode Nerd Font"
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $fontFile = Join-Path $fontDir "FiraCodeNerdFont-Regular.ttf"
    if (-not (Test-Path $fontFile)) {
        Write-Host "\e[95m🔤 Installing $fontName...\e[0m"
        choco install firacodenf -y
    } else {
        Write-Host "\e[96m🔤 $fontName already installed.\e[0m"
    }
}

# Install or upgrade Oh My Posh
function Install-OhMyPosh {
    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host "\e[95m💎 Oh My Posh not found. Installing...\e[0m"
        winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements
    } else {
        Write-Host "\e[96m💎 Oh My Posh already installed. Upgrading...\e[0m"
        winget upgrade JanDeDobbeleer.OhMyPosh --accept-source-agreements --accept-package-agreements
    }
}

# Configure PowerShell to use Oh My Posh for the current user
function Configure-OhMyPoshProfile {
    $profilePath = $PROFILE
    $ohMyPoshInit = 'oh-my-posh init pwsh --config "$(oh-my-posh get shell-path pwsh)" | Invoke-Expression'
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }
    $profileContent = Get-Content $profilePath -Raw
    if ($profileContent -notmatch 'oh-my-posh init pwsh') {
        Write-Host "\e[93m✨ Adding Oh My Posh initialization to PowerShell profile...\e[0m"
        Add-Content -Path $profilePath -Value $ohMyPoshInit
    } else {
        Write-Host "\e[96m✨ Oh My Posh already configured in PowerShell profile.\e[0m"
    }
}

# Ensure winget is available
Write-Host "\e[94m🔎 Checking for winget...\e[0m"
Test-Winget

# Install or upgrade Homebrew
Install-Homebrew

# Install or upgrade Scoop
Install-Scoop

# Install or upgrade Chocolatey
Install-Choco

# Install or upgrade Git
Install-Or-Upgrade -PackageId "Git.Git" -DisplayName "Git"

# Install or upgrade Visual Studio Code
Install-Or-Upgrade -PackageId "Microsoft.VisualStudioCode" -DisplayName "Visual Studio Code"

# Install or upgrade Docker Desktop
Install-Or-Upgrade -PackageId "Docker.DockerDesktop" -DisplayName "Docker Desktop"

# Install or upgrade PowerShell (latest version)
Install-Or-Upgrade -PackageId "Microsoft.Powershell" -DisplayName "PowerShell"

# Install or upgrade OpenSSL
Install-Or-Upgrade -PackageId "OpenSSL.OpenSSL" -DisplayName "OpenSSL"

# Install Nerd Font
Install-NerdFont

# Install or upgrade Oh My Posh
Install-OhMyPosh

# Configure PowerShell to use Oh My Posh for the current user
Configure-OhMyPoshProfile

Write-Host "\n\e[92m✅ Installation/upgrade completed!\e[0m\n"
