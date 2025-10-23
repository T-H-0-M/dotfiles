# Dotfiles

macOS development environment with Neovim, Tmux, Zsh, Alacritty, AeroSpace, and Nix-Darwin. Features automated installation, environment-based configuration via `.env`, and zero hardcoded values.

## What's Included

- **Nix-Darwin** - Declarative macOS system management
- **Neovim** - Editor with Lazy.nvim, LSP, and Treesitter
- **Tmux** - Terminal multiplexer with session persistence
- **Zsh** - Oh-My-Zsh with Powerlevel10k theme
- **Alacritty** - GPU-accelerated terminal emulator
- **AeroSpace** - i3-like tiling window manager
- **Claude Code** - AI assistant configurations

## Prerequisites

- macOS (Apple Silicon/ARM64, adaptable for Intel)
- Command Line Tools: `xcode-select --install`
- Administrator/sudo access (required for Nix-Darwin)

## Installation

> **⚠️ Security Notice**: Review scripts before running with sudo. Check `install.sh`, `update.sh`, and `nix/apply.sh`.

### 1. Clone Repository

```bash
git clone https://github.com/T-H-0-M/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Configure Environment

```bash
cp .env.example .env
vim .env  # Set DOTFILES_USER, DOTFILES_HOSTNAME, NVIM_NAMESPACE
```

### 3. Install

```bash
chmod +x install.sh && ./install.sh
```

The script installs Nix, creates symlinks, installs Oh-My-Zsh/TPM, and applies Nix-Darwin configuration.

### 4. Post-Install

```bash
source ~/.zshrc
p10k configure              # Configure Powerlevel10k
tmux                        # Then press Ctrl+b, Shift+i to install plugins
nvim                        # Opens and installs plugins automatically
```

**Note**: If your Neovim namespace differs from "thomas", rename `nvim/lua/thomas` and update imports in `init.lua`.

## Updating

```bash
cd ~/dotfiles && ./update.sh
```

Updates Nix packages, Homebrew, Oh-My-Zsh, Zsh plugins, Tmux plugins, and Neovim plugins.

## Configuration

All tools are configured via `.env` file. Edit `~/dotfiles/.env` and run `./update.sh` to apply changes.

### Nix-Darwin (`nix/flake.nix`)
Manages system packages and Homebrew casks. Edit `flake.nix` to add/remove packages, then run `./update.sh`.

### Neovim (`nvim/`)
- Structure: `init.lua`, `lua/thomas/core/`, `lua/thomas/plugins/`
- Key plugins: Telescope, LSP, Treesitter, Auto-session, VimTeX
- Install LSP servers: `:Mason` then `:MasonInstall <server>`
- Leader key: `Space`

### Tmux (`tmux/.tmux.conf`)
- Prefix: `Ctrl+b`
- Key bindings: `Prefix+R` (reload), `Prefix+v/h` (split), `Alt+Arrows` (navigate)
- Plugins: TPM, vim-tmux-navigator, tmux-resurrect, tmux-continuum
- Customize colors in `.env`: `TMUX_STATUS_BG`, `TMUX_STATUS_FG`

### Zsh (`zsh/.zshrc`)
- Features: Oh-My-Zsh, Powerlevel10k, zoxide (`z`), fzf
- Configure paths in `.env`: `PYTHON_VERSION`, `ANDROID_HOME`, etc.

### Alacritty (`alacritty/alacritty.toml`)
- Font: JetBrains Mono Light, 14pt
- 70% opacity with background blur
- Change themes: Update import path (themes in `alacritty/themes/themes/`)

### AeroSpace (`aerospace/aerospace.toml`)
- i3-like tiling window manager
- Key bindings: `Alt+h/j/k/l` (focus), `Alt+Shift+h/j/k/l` (move), `Alt+[1-9,A-Z]` (workspace)
- Service mode: `Alt+Shift+;`

### Claude Code (`.claude/`)
- Custom agents and commands
- Add new agents in `.claude/agents/`, commands in `.claude/commands/`

## Troubleshooting

**Missing `.env` or variables**
```bash
cp ~/dotfiles/.env.example ~/dotfiles/.env
vim ~/dotfiles/.env  # Set required variables
./install.sh
```

**Symlinks not working**
```bash
ls -la ~/.config/nvim ~/.tmux.conf ~/.zshrc  # Verify links
./install.sh  # Re-create if needed
```

**Tmux plugins not loading**
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# In tmux: Ctrl+b, Shift+i
```

**Neovim plugins not installing**
```bash
rm -rf ~/.local/share/nvim/lazy
nvim  # Will auto-install
```

**LSP servers missing**
```bash
nvim
:Mason  # Install language servers
```

**Wrong hostname**
```bash
scutil --get ComputerName  # Check hostname
vim ~/dotfiles/.env  # Update DOTFILES_HOSTNAME
./update.sh
```

**Commands not found**
```bash
source ~/.zshrc  # Reload shell
cd ~/dotfiles && ./update.sh  # Rebuild Nix config
```

---

**License**: Personal use. Feel free to fork and customize.
