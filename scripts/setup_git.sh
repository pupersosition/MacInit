#!/bin/bash

# Setup Git configuration
# This script helps configure Git with your identity and preferences

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[GIT SETUP]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log "Setting up Git configuration..."

# Check if Git is already configured
if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
    current_name=$(git config --global user.name)
    current_email=$(git config --global user.email)
    warning "Git is already configured:"
    echo "  Name: $current_name"
    echo "  Email: $current_email"
    echo ""
    read -p "Do you want to reconfigure Git? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Skipping Git user configuration"
        skip_user_config=true
    fi
fi

# Configure Git user identity
if [ "$skip_user_config" != true ]; then
    echo ""
    echo "Please enter your Git configuration details:"
    read -p "Full Name: " git_name
    read -p "Email Address: " git_email

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    success "Git user identity configured"
fi

# Configure Git settings
log "Configuring Git preferences..."

# Set default branch name to main
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor nano

# Enable color output
git config --global color.ui auto

# Configure line ending handling
git config --global core.autocrlf input
git config --global core.safecrlf true

# Configure merge and diff tools
git config --global merge.tool vimdiff
git config --global diff.tool vimdiff

# Configure push behavior
git config --global push.default simple
git config --global push.autoSetupRemote true

# Configure pull behavior (rebase instead of merge)
git config --global pull.rebase true

# Configure credential helper for macOS
git config --global credential.helper osxkeychain

# Configure some useful aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.graph 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
git config --global alias.contributors 'shortlog --summary --numbered'

# Configure rerere (reuse recorded resolution)
git config --global rerere.enabled true

# Configure automatic garbage collection
git config --global gc.auto 1

success "Git configuration completed!"

# Display current configuration
echo ""
echo "Current Git configuration:"
git config --global --list | grep -E "^(user\.|alias\.|core\.|color\.|push\.|pull\.)" | sort

log "Git setup completed!"

