#!/bin/bash

# MacInit - Personal Mac Setup Script
# Run this script on a new Mac to replicate your development environment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error "This script is designed for macOS only!"
    exit 1
fi

log "Starting Mac initialization..."

# Ask for administrator password upfront
sudo -v

# Keep-alive: update existing sudo time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# 1. Install Xcode Command Line Tools
log "Installing Xcode Command Line Tools..."
if ! xcode-select --print-path &> /dev/null; then
    xcode-select --install
    log "Please complete the Xcode Command Line Tools installation and re-run this script."
    exit 1
else
    success "Xcode Command Line Tools already installed"
fi

# 2. Install Homebrew
log "Installing Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    success "Homebrew installed"
else
    success "Homebrew already installed"
fi

# 3. Install Homebrew packages
log "Installing Homebrew packages..."
brew update

# Install formulae (command line tools)
FORMULAE=(
    "bat"           # Better cat with syntax highlighting
    "htop"          # Better top
    "ctop"          # Container top
    "tree"          # Directory tree view
    "lazygit"       # Git TUI
    "node"          # Node.js
    "uv"            # Python package manager
)

for formula in "${FORMULAE[@]}"; do
    if brew list --formula | grep -q "^${formula}$"; then
        success "$formula already installed"
    else
        log "Installing $formula..."
        brew install "$formula"
        success "$formula installed"
    fi
done

# 4. Install Oh My Zsh
log "Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh My Zsh installed"
else
    success "Oh My Zsh already installed"
fi

# 5. Setup Zsh configuration
log "Setting up Zsh configuration..."
./scripts/setup_zsh.sh

# 6. Setup Git configuration
log "Setting up Git configuration..."
./scripts/setup_git.sh

# 7. Setup SSH
log "Setting up SSH..."
./scripts/setup_ssh.sh

# 8. Install applications via Homebrew Cask
log "Installing applications..."
./scripts/install_apps.sh

# 9. Configure macOS defaults
log "Configuring macOS defaults..."
./scripts/configure_macos.sh

# 10. Setup development environment
log "Setting up development environment..."
./scripts/setup_dev_env.sh

success "Mac initialization completed!"
log "Please restart your terminal or run 'source ~/.zshrc' to apply shell changes."
log "Some applications may require manual configuration."

# Final notes
echo ""
echo "=== POST-INSTALLATION NOTES ==="
echo "1. Configure your Git identity by running the git setup script"
echo "2. Add your SSH keys to GitHub/GitLab"
echo "3. Install additional software from the App Store if needed"
echo "4. Configure application preferences"
echo "5. Sign in to your cloud services"
echo ""

