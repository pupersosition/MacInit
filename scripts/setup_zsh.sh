#!/bin/bash

# Setup Zsh configuration
# This script configures Oh My Zsh with your preferred settings

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${BLUE}[ZSH SETUP]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log "Setting up Zsh configuration..."

# Backup existing .zshrc if it exists
if [ -f "$HOME/.zshrc" ]; then
    log "Backing up existing .zshrc..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create .zshrc with your configuration
cat > "$HOME/.zshrc" << 'EOF'
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(git)

# Homebrew Path (for Apple Silicon Macs)
if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# Preferred editor for local and remote sessions
export EDITOR='nano'

# Add common aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Better ls with bat if available
if command -v bat &> /dev/null; then
    alias cat='bat'
fi

# Better top with htop if available
if command -v htop &> /dev/null; then
    alias top='htop'
fi

# Python/UV aliases
alias python='python3'
alias pip='python3 -m pip'

# Node.js aliases
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install --global'
alias nt='npm test'
alias nr='npm run'
alias ns='npm start'

# Docker aliases (if Docker is installed)
if command -v docker &> /dev/null; then
    alias d='docker'
    alias dc='docker-compose'
    alias dps='docker ps'
    alias di='docker images'
    alias drmi='docker rmi'
    alias drm='docker rm'
fi

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract function
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Weather function (requires curl)
weather() {
    curl -s "wttr.in/$1"
}

# Public IP function
myip() {
    curl -s https://ipinfo.io/ip
}
EOF

success "Zsh configuration created at ~/.zshrc"

# Set Zsh as the default shell if it isn't already
if [ "$SHELL" != "/bin/zsh" ]; then
    log "Setting Zsh as default shell..."
    chsh -s /bin/zsh
    success "Zsh set as default shell"
fi

log "Zsh setup completed!"

