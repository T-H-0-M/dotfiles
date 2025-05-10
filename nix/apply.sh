#!/bin/bash

# Helper script to apply Nix-Darwin configuration with .env variables
# This ensures environment variables from .env are available during flake evaluation

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f "$DOTFILES_DIR/.env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo -e "${YELLOW}Please create a .env file:${NC}"
    echo -e "  cp $DOTFILES_DIR/.env.example $DOTFILES_DIR/.env"
    echo -e "  # Edit .env with your configuration\n"
    exit 1
fi

# Source the .env file to export all variables
echo -e "${GREEN}Loading configuration from .env...${NC}"
set -a
source "$DOTFILES_DIR/.env"
set +a

# Validate required variables
if [ -z "$DOTFILES_HOSTNAME" ]; then
    echo -e "${RED}Error: DOTFILES_HOSTNAME is not set in .env${NC}"
    exit 1
fi

if [ -z "$DOTFILES_USER" ]; then
    echo -e "${RED}Error: DOTFILES_USER is not set in .env${NC}"
    exit 1
fi

echo -e "${GREEN}Configuration:${NC}"
echo -e "  Hostname: $DOTFILES_HOSTNAME"
echo -e "  User: $DOTFILES_USER\n"

# Determine if this is the first run or subsequent run
if command -v darwin-rebuild &> /dev/null; then
    echo -e "${GREEN}Applying Nix-Darwin configuration...${NC}"
    darwin-rebuild switch --flake "$SCRIPT_DIR#$DOTFILES_HOSTNAME"
else
    echo -e "${GREEN}First-time setup: Installing Nix-Darwin...${NC}"
    nix run nix-darwin -- switch --flake "$SCRIPT_DIR#$DOTFILES_HOSTNAME"
fi

echo -e "\n${GREEN}✓ Configuration applied successfully!${NC}"
