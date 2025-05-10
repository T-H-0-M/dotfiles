#!/bin/bash

# Dotfiles Update Script
# This script updates all system configurations and software

set -e  # Exit on error

# ANSI Color Codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
NC='\033[0m' # No Color

# Icons
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
ARROW="${BLUE}→${NC}"
STAR="${YELLOW}★${NC}"

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Print a fancy header
print_header() {
    local text="$1"
    local padding=$((58 - ${#text}))
    echo -e "\n${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${BOLD}${MAGENTA}${text}${NC}$(printf '%*s' ${padding} '')${BOLD}${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

# Print a section header
print_section() {
    echo -e "\n${BOLD}${BLUE}▶ $1${NC}\n"
}

# Print a step message
print_step() {
    echo -e "${DIM}${ARROW}${NC} $1"
}

# Print success message
print_success() {
    echo -e "${CHECK} $1"
}

# Print error message
print_error() {
    echo -e "${CROSS} ${RED}$1${NC}"
}

# Print warning message
print_warning() {
    echo -e "${YELLOW}⚠${NC}  ${YELLOW}$1${NC}"
}

print_header "DOTFILES UPDATE"

# Check if .env file exists
print_section "Loading Configuration"
if [ ! -f "$DOTFILES_DIR/.env" ]; then
    print_error ".env file not found!"
    print_warning "Please ensure .env exists before updating"
    exit 1
fi

# Source the .env file
print_step "Loading configuration from .env..."
set -a  # automatically export all variables
source "$DOTFILES_DIR/.env"
set +a
print_success "Configuration loaded"

# Update Nix Flake
print_section "Updating Nix Flake"
print_step "Running nix flake update..."
cd "$DOTFILES_DIR/nix"
nix flake update
print_success "Nix flake updated"

# Apply Nix-Darwin configuration
print_section "Applying Nix-Darwin Configuration"
print_warning "This step requires sudo access and may take several minutes..."
echo ""

# Export environment variables for nix-darwin
set -a
source "$DOTFILES_DIR/.env"
set +a

chmod +x apply.sh
sudo -E ./apply.sh

# Update Homebrew
print_section "Updating Homebrew Packages"
if command -v brew &> /dev/null; then
    print_step "Updating Homebrew..."
    brew update
    print_success "Homebrew updated"

    print_step "Upgrading Homebrew packages..."
    brew upgrade
    print_success "Homebrew packages upgraded"

    print_step "Cleaning up Homebrew..."
    brew cleanup
    print_success "Homebrew cleanup complete"
else
    print_warning "Homebrew not found, skipping Homebrew update"
fi

# Update Oh-My-Zsh
print_section "Updating Oh-My-Zsh"
if [ -d "$HOME/.oh-my-zsh" ]; then
    print_step "Updating Oh-My-Zsh..."
    cd "$HOME/.oh-my-zsh"
    git pull
    print_success "Oh-My-Zsh updated"
else
    print_warning "Oh-My-Zsh not found, skipping"
fi

# Update Powerlevel10k
print_section "Updating Powerlevel10k Theme"
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_step "Updating Powerlevel10k..."
    cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    git pull
    print_success "Powerlevel10k updated"
else
    print_warning "Powerlevel10k not found, skipping"
fi

# Update Zsh plugins
print_section "Updating Zsh Plugins"

if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_step "Updating zsh-autosuggestions..."
    cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
    git pull
    print_success "zsh-autosuggestions updated"
else
    print_warning "zsh-autosuggestions not found, skipping"
fi

if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    print_step "Updating zsh-syntax-highlighting..."
    cd "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
    git pull
    print_success "zsh-syntax-highlighting updated"
else
    print_warning "zsh-syntax-highlighting not found, skipping"
fi

# Update TPM and Tmux plugins
print_section "Updating Tmux Plugins"
if [ -d "$HOME/.tmux/plugins/tpm" ]; then
    print_step "Updating TPM..."
    cd "$HOME/.tmux/plugins/tpm"
    git pull
    print_success "TPM updated"

    print_step "Updating Tmux plugins..."
    if command -v tmux &> /dev/null; then
        # Update all plugins
        "$HOME/.tmux/plugins/tpm/bin/update_plugins" all
        print_success "Tmux plugins updated"
    else
        print_warning "Tmux not running, plugins will update on next tmux session"
    fi
else
    print_warning "TPM not found, skipping"
fi

# Update Neovim plugins
print_section "Updating Neovim Plugins"
if command -v nvim &> /dev/null; then
    print_step "Updating Neovim plugins..."
    nvim --headless "+Lazy! sync" +qa
    print_success "Neovim plugins updated"
else
    print_warning "Neovim not found, skipping plugin update"
fi

# Return to dotfiles directory
cd "$DOTFILES_DIR"

print_header "UPDATE COMPLETE!"

echo -e "${BOLD}${GREEN}All done!${NC} Your system is up to date.\n"
echo -e "${BOLD}Next Steps:${NC}\n"
echo -e "  ${CYAN}1.${NC} Restart your terminal or run: ${DIM}source ~/.zshrc${NC}"
echo -e "  ${CYAN}2.${NC} If in tmux, reload config: ${DIM}tmux source ~/.tmux.conf${NC} or ${DIM}Prefix + R${NC}"
echo -e "  ${CYAN}3.${NC} Restart any running applications to use updated versions\n"
echo -e "${DIM}For a fresh installation, run: ${BOLD}./install.sh${NC}\n"
