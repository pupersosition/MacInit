#!/bin/bash

# Install applications via Homebrew Cask
# This script installs the applications found on your system

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[APP INSTALL]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log "Installing applications via Homebrew Cask..."

# Update Homebrew
brew update

# Install Cask applications based on your current setup
CASKS=(
    "brave-browser"     # Brave Browser
    "cursor"            # Cursor (AI-powered code editor)
    "docker"            # Docker Desktop
    "keepassxc"         # KeePassXC (password manager)
    "obsidian"          # Obsidian (note-taking)
    "ollama"            # Ollama (local LLM)
    "spotify"           # Spotify
    "warp"              # Warp (modern terminal)
)

# Optional applications (commented out by default)
OPTIONAL_CASKS=(
    # "daisydisk"           # DaisyDisk (disk usage analyzer)
    # "nordvpn"             # NordVPN
    # "ableton-live-lite"   # Ableton Live 12 Lite
    # "garageband"          # GarageBand (usually pre-installed)
    # "keynote"             # Keynote (usually pre-installed)
    # "numbers"             # Numbers (usually pre-installed)
    # "pages"               # Pages (usually pre-installed)
    # "imovie"              # iMovie (usually pre-installed)
    # "logi-options-plus"   # Logitech Options+
)

# Install each application
for cask in "${CASKS[@]}"; do
    if brew list --cask | grep -q "^${cask}$"; then
        success "$cask already installed"
    else
        log "Installing $cask..."
        if brew install --cask "$cask"; then
            success "$cask installed"
        else
            warning "Failed to install $cask - it may not be available or already installed"
        fi
    fi
done

# Ask about optional applications
echo ""
log "Optional applications available:"
for cask in "${OPTIONAL_CASKS[@]}"; do
    echo "  - $cask"
done

echo ""
read -p "Do you want to install optional applications? (y/N): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    for cask in "${OPTIONAL_CASKS[@]}"; do
        if brew list --cask | grep -q "^${cask}$"; then
            success "$cask already installed"
        else
            log "Installing $cask..."
            if brew install --cask "$cask"; then
                success "$cask installed"
            else
                warning "Failed to install $cask - it may not be available"
            fi
        fi
    done
fi

# Install additional command line tools
log "Installing additional command line tools..."

ADDITIONAL_TOOLS=(
    "wget"              # Download utility
    "curl"              # Already installed, but ensure latest
    "jq"                # JSON processor
    "fzf"               # Fuzzy finder
    "ripgrep"           # Better grep
    "fd"                # Better find
    "exa"               # Better ls
    "tldr"              # Simplified man pages
    "mas"               # Mac App Store CLI
)

for tool in "${ADDITIONAL_TOOLS[@]}"; do
    if brew list --formula | grep -q "^${tool}$"; then
        success "$tool already installed"
    else
        log "Installing $tool..."
        if brew install "$tool"; then
            success "$tool installed"
        else
            warning "Failed to install $tool"
        fi
    fi
done

# Cleanup
log "Cleaning up Homebrew..."
brew cleanup

success "Application installation completed!"

echo ""
echo "=== Installed Applications ==="
echo "Core applications:"
for cask in "${CASKS[@]}"; do
    if brew list --cask | grep -q "^${cask}$"; then
        echo "  ✓ $cask"
    fi
done

echo ""
echo "Command line tools:"
for tool in "${ADDITIONAL_TOOLS[@]}"; do
    if brew list --formula | grep -q "^${tool}$"; then
        echo "  ✓ $tool"
    fi
done

echo ""
echo "=== Post-Installation Notes ==="
echo "1. Docker: Start Docker Desktop from Applications"
echo "2. Warp: Configure terminal preferences if needed"
echo "3. Obsidian: Set up your vault location"
echo "4. KeePassXC: Import your password database"
echo "5. Cursor: Install preferred extensions"
echo ""

