#!/bin/bash

# Setup SSH configuration
# This script helps generate SSH keys and configure SSH settings

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[SSH SETUP]${NC} $1"
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

log "Setting up SSH configuration..."

# Create .ssh directory if it doesn't exist
if [ ! -d "$HOME/.ssh" ]; then
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    log "Created .ssh directory"
fi

# Check if SSH key already exists
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
    warning "SSH key already exists:"
    ls -la "$HOME/.ssh/" | grep -E "(id_ed25519|id_rsa)"
    echo ""
    read -p "Do you want to generate a new SSH key? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Skipping SSH key generation"
        skip_key_generation=true
    fi
fi

# Generate SSH key
if [ "$skip_key_generation" != true ]; then
    echo ""
    read -p "Enter your email address for the SSH key: " ssh_email
    
    if [ -z "$ssh_email" ]; then
        error "Email address is required for SSH key generation"
        exit 1
    fi
    
    log "Generating new SSH key..."
    ssh-keygen -t ed25519 -C "$ssh_email" -f "$HOME/.ssh/id_ed25519" -N ""
    
    # Set proper permissions
    chmod 600 "$HOME/.ssh/id_ed25519"
    chmod 644 "$HOME/.ssh/id_ed25519.pub"
    
    success "SSH key generated successfully"
fi

# Create or update SSH config
log "Setting up SSH config..."

# Create SSH config with common settings
cat > "$HOME/.ssh/config" << 'EOF'
# Global SSH configuration

# Use SSH key authentication by default
PreferredAuthentications publickey,keyboard-interactive,password

# Keep connections alive
ServerAliveInterval 60
ServerAliveCountMax 3

# Reuse connections
ControlMaster auto
ControlPath ~/.ssh/control-%r@%h:%p
ControlPersist 600

# Security settings
Protocol 2
Compression yes

# GitHub configuration
Host github.com
    HostName github.com
    User git
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519

# GitLab configuration
Host gitlab.com
    HostName gitlab.com
    User git
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519

# Bitbucket configuration
Host bitbucket.org
    HostName bitbucket.org
    User git
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF

chmod 600 "$HOME/.ssh/config"
success "SSH config created"

# Add SSH key to ssh-agent
log "Adding SSH key to ssh-agent..."

# Start ssh-agent if not running
if ! pgrep -x "ssh-agent" > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# Add SSH key to agent
if [ -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519" 2>/dev/null || ssh-add "$HOME/.ssh/id_ed25519"
    success "SSH key added to ssh-agent"
fi

# Display public key for easy copying
if [ -f "$HOME/.ssh/id_ed25519.pub" ]; then
    echo ""
    echo "=== Your SSH Public Key ==="
    echo "Copy this key to your Git hosting service (GitHub, GitLab, etc.):"
    echo ""
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    echo "=========================="
    echo ""
    
    # Offer to copy to clipboard if pbcopy is available
    if command -v pbcopy &> /dev/null; then
        read -p "Copy SSH public key to clipboard? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            cat "$HOME/.ssh/id_ed25519.pub" | pbcopy
            success "SSH public key copied to clipboard!"
        fi
    fi
fi

# Test SSH connection to GitHub
log "Testing SSH connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    success "GitHub SSH connection successful!"
else
    warning "GitHub SSH connection test failed. Make sure to add your public key to GitHub."
fi

log "SSH setup completed!"

echo ""
echo "=== Next Steps ==="
echo "1. Add your SSH public key to your Git hosting services:"
echo "   - GitHub: https://github.com/settings/ssh/new"
echo "   - GitLab: https://gitlab.com/-/profile/keys"
echo "   - Bitbucket: https://bitbucket.org/account/settings/ssh-keys/"
echo "2. Test your SSH connection: ssh -T git@github.com"
echo ""

