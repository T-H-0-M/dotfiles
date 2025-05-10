#!/bin/bash

# Dotfiles Installation Script
# This script creates symlinks and performs full system setup

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

print_header "DOTFILES INSTALLATION"

# Check if .env file exists
print_section "Validating Configuration"
if [ ! -f "$DOTFILES_DIR/.env" ]; then
    print_error ".env file not found!"
    print_warning "Please create a .env file based on .env.example:"
    echo -e "  ${DIM}cp $DOTFILES_DIR/.env.example $DOTFILES_DIR/.env${NC}"
    echo -e "  ${DIM}# Edit .env with your personal configuration${NC}\n"
    exit 1
fi

# Source the .env file
print_step "Loading configuration from .env..."
set -a  # automatically export all variables
source "$DOTFILES_DIR/.env"
set +a

# Validate required environment variables
REQUIRED_VARS=("DOTFILES_USER" "DOTFILES_HOSTNAME" "NVIM_NAMESPACE")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    print_error "Missing required environment variables in .env:"
    for var in "${MISSING_VARS[@]}"; do
        echo -e "    ${CROSS} $var"
    done
    echo ""
    exit 1
fi

print_success "Configuration loaded successfully"
echo -e "  ${DIM}User:${NC}      ${BOLD}$DOTFILES_USER${NC}"
echo -e "  ${DIM}Hostname:${NC}  ${BOLD}$DOTFILES_HOSTNAME${NC}"
echo -e "  ${DIM}Namespace:${NC} ${BOLD}$NVIM_NAMESPACE${NC}"

# Set defaults for optional variables
TMUX_STATUS_SESSION_NAME=${TMUX_STATUS_SESSION_NAME:-"tmux"}
TMUX_STATUS_BG=${TMUX_STATUS_BG:-"#53575e"}
TMUX_STATUS_FG=${TMUX_STATUS_FG:-"#000000"}

# Function to create symlink with backup
create_symlink() {
    local source=$1
    local target=$2
    local name=$3

    # Check if target exists and is not a symlink
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        print_warning "Backing up existing ${name}"
        mv "$target" "$target.backup"
    fi

    # Remove existing symlink if it exists
    if [ -L "$target" ]; then
        rm "$target"
    fi

    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    # Create symlink
    ln -s "$source" "$target"
    print_success "Linked ${name}"
}

# Check and install Nix if needed
print_section "Checking Nix Installation"
if command -v nix &> /dev/null; then
    print_success "Nix is already installed"
else
    print_step "Nix not found. Installing Nix..."
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
    print_success "Nix installed successfully"

    # Source nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
fi

# Create symlinks
print_section "Creating Symlinks"
create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim" "Neovim config"
create_symlink "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty" "Alacritty config"
create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf" "Tmux config"
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc" "Zsh config"
create_symlink "$DOTFILES_DIR/nix" "$HOME/.config/nix" "Nix config"
create_symlink "$DOTFILES_DIR/aerospace" "$HOME/.config/aerospace" "AeroSpace config"
create_symlink "$DOTFILES_DIR/.claude" "$HOME/.claude" "Claude Code config"

# Install Oh-My-Zsh
print_section "Installing Oh-My-Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_step "Installing Oh-My-Zsh..."
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "Oh-My-Zsh installed"
else
    print_success "Oh-My-Zsh already installed"
fi

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_step "Installing Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "Powerlevel10k installed"
else
    print_success "Powerlevel10k already installed"
fi

# Install Zsh plugins
if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_step "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed"
else
    print_success "zsh-autosuggestions already installed"
fi

if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    print_step "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed"
else
    print_success "zsh-syntax-highlighting already installed"
fi

# Install TPM
print_section "Installing Tmux Plugin Manager"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    print_step "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    print_success "TPM installed"
else
    print_success "TPM already installed"
fi

# Apply Nix-Darwin configuration
print_section "Applying Nix-Darwin Configuration"
print_warning "This step requires sudo access and may take several minutes..."
echo ""
cd "$DOTFILES_DIR/nix"
chmod +x apply.sh
sudo ./apply.sh

# Handle Neovim namespace rename if needed
if [ "$NVIM_NAMESPACE" != "thomas" ]; then
    print_section "Neovim Namespace Configuration"
    if [ -d "$DOTFILES_DIR/nvim/lua/thomas" ]; then
        print_warning "You need to rename the Neovim namespace from 'thomas' to '$NVIM_NAMESPACE'"
        echo -e "  ${DIM}cd $DOTFILES_DIR/nvim/lua${NC}"
        echo -e "  ${DIM}mv thomas $NVIM_NAMESPACE${NC}"
        echo -e "  ${DIM}# Update imports in init.lua and lazy.lua${NC}\n"
    fi
fi

print_header "INSTALLATION COMPLETE!"

echo -e "${BOLD}${GREEN}All done!${NC} Your development environment is ready.\n"
echo -e "${BOLD}Next Steps:${NC}\n"
echo -e "  ${CYAN}1.${NC} Start a new terminal session or run: ${DIM}source ~/.zshrc${NC}"
echo -e "  ${CYAN}2.${NC} Configure Powerlevel10k: ${DIM}p10k configure${NC}"
echo -e "  ${CYAN}3.${NC} Start tmux and install plugins: ${DIM}tmux${NC} then ${DIM}Ctrl+b Shift+i${NC}"
echo -e "  ${CYAN}4.${NC} Open Neovim to install plugins: ${DIM}nvim${NC}\n"
echo -e "${DIM}To update your configuration in the future, run: ${BOLD}./update.sh${NC}\n"
