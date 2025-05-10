# Dotfiles

A comprehensive macOS development environment configuration featuring Neovim,
Tmux, Zsh, Alacritty, AeroSpace window manager, and Nix-Darwin for declarative
system management.

**Key Features**:

- **Environment-Based Configuration**: User-specific settings centralized in
  `.env` file
- **Zero Hardcoded Values**: Dynamic configuration for Nix-Darwin, Zsh, and Tmux
- **Simple Installation**: Automated scripts with validation and helpful error
  messages
- **Portable and Reusable**: Easy to adapt to different machines and users

## Table of Contents

- [What's Included](#whats-included)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration Details](#configuration-details)
  - [Nix-Darwin](#nix-darwin)
  - [Neovim](#neovim)
  - [Tmux](#tmux)
  - [Zsh](#zsh)
  - [Alacritty](#alacritty)
  - [AeroSpace](#aerospace)
  - [Claude Code](#claude-code)
- [Customization](#customisation)
- [Key Features and Keybindings](#key-features-and-keybindings)
- [Troubleshooting](#troubleshooting)

## What's Included

This dotfiles repository provides a complete development environment with:

- **Nix-Darwin**: Declarative macOS system configuration with automatic package
  management
- **Neovim**: Modern Vim-based editor configured with Lazy.nvim plugin manager
- **Tmux**: Terminal multiplexer with session persistence and vim-style
  navigation
- **Zsh**: Shell configuration with Oh-My-Zsh, Powerlevel10k theme, and useful
  plugins
- **Alacritty**: Fast, GPU-accelerated terminal emulator
- **AeroSpace**: Tiling window manager for macOS with i3-like keybindings
- **Claude Code**: AI-powered development assistant configurations

## Prerequisites

Before installing, ensure you have:

- macOS (configured for Apple Silicon/ARM64, but can be adapted for Intel)
- Command Line Tools: `xcode-select --install`
- Git: `brew install git` or use Xcode Command Line Tools
- **Administrator/sudo access**: Required for Nix-Darwin system configuration

## Installation

> **⚠️ Important Security Notice**
>
> Before running any scripts, especially with `sudo`, **please read through the
> code to understand what it does**. This is standard practice for any
> programmer and crucial for the safety of your system.
>
> Key scripts to review:
>
> - `install.sh`: Automated installation script (requires sudo for Nix-Darwin)
> - `update.sh`: Updates all configurations and software
> - `nix/apply.sh`: Applies Nix-Darwin system configuration
>
> Never run scripts with elevated privileges without understanding their
> contents. All scripts in this repository are designed to be readable and
> transparent.

The installation process has been streamlined into a single automated script
that handles everything for you.

### Step 1: Clone the Repository

```bash
# Clone to your home directory
cd ~
git clone https://github.com/T-H-0-M/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### Step 2: Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit .env with your personal configuration
# Required variables:
#   - DOTFILES_USER: Your macOS username
#   - DOTFILES_HOSTNAME: Your computer hostname (check with: scutil --get ComputerName)
#   - NVIM_NAMESPACE: Your preferred Neovim namespace (e.g., your username)
vim .env  # Vim will never let you down
```

**Important**: All user-specific configuration is centralized in the `.env`
file. This makes it easy to customise the dotfiles for your system without
modifying tracked files.

### Step 3: Run the Installation Script

The installation script will automatically:

- Install Nix (if not already installed)
- Create symlinks for all configuration files
- Install Oh-My-Zsh and plugins (Powerlevel10k, autosuggestions,
  syntax-highlighting)
- Install Tmux Plugin Manager (TPM)
- Apply Nix-Darwin configuration with all packages

```bash
# Make the install script executable and run it
chmod +x install.sh
./install.sh
```

The script will:

1. Validate your `.env` configuration
2. Check and install Nix if needed
3. Create symlinks for all dotfiles:
   - `~/.config/nvim` → `~/dotfiles/nvim`
   - `~/.config/alacritty` → `~/dotfiles/alacritty`
   - `~/.tmux.conf` → `~/dotfiles/tmux/.tmux.conf`
   - `~/.zshrc` → `~/dotfiles/zsh/.zshrc`
   - `~/.config/nix` → `~/dotfiles/nix`
   - `~/.config/aerospace` → `~/dotfiles/aerospace`
   - `~/.claude` → `~/dotfiles/.claude`
4. Install Oh-My-Zsh with Powerlevel10k theme
5. Install Zsh plugins (autosuggestions, syntax-highlighting)
6. Install Tmux Plugin Manager
7. Apply Nix-Darwin configuration (installs all packages)

**Note**: The script will prompt for your sudo password when applying the
Nix-Darwin configuration.

### Step 4: Complete Setup

After the installation completes:

```bash
# Start a new terminal session or source your zsh configuration
source ~/.zshrc

# Configure Powerlevel10k (follow the interactive prompts)
p10k configure

# Start tmux and install plugins
tmux
# Inside tmux, press: Ctrl+b then Shift+i

# Open Neovim to install plugins
nvim
```

### Step 5: Optional - Rename Neovim Namespace

If your `NVIM_NAMESPACE` in `.env` is different from "thomas":

```bash
cd ~/dotfiles/nvim/lua
mv thomas YOUR_NAMESPACE

# Update the imports in nvim/init.lua and nvim/lua/YOUR_NAMESPACE/lazy.lua
# to use your namespace instead of "thomas"
```

## Updating

To update all your configurations and software to the latest versions:

```bash
cd ~/dotfiles
./update.sh
```

The update script will:

- Update the Nix flake lock file (`nix flake update`)
- Apply the updated Nix-Darwin configuration
- Update Homebrew and all Homebrew packages
- Update Oh-My-Zsh
- Update Powerlevel10k theme
- Update all Zsh plugins
- Update Tmux Plugin Manager and tmux plugins
- Update Neovim plugins

**Note**: Like the install script, the update script requires sudo access for
applying Nix-Darwin configuration changes.

## Configuration Details

### Nix-Darwin

Location: `nix/flake.nix`

This configuration manages your entire macOS system declaratively:

**System Packages**: Includes development tools, CLI utilities, and language
runtimes

**Homebrew Integration**: Manages GUI applications through Homebrew Casks:

- Browsers: Firefox, Chrome
- Development: VSCode, Android Studio, Docker, Postman
- Communication: Zoom, Discord, WhatsApp
- Productivity: 1Password, Alfred
- Creative: GIMP, OBS, FinalCut Pro

**System Preferences**:

- Dark mode enabled
- 24-hour time format
- Fast key repeat rate
- Dock auto-hide
- Finder column view

**To customise**:

1. Set your hostname and username in `.env`:
   - `DOTFILES_HOSTNAME`: Your computer hostname
   - `DOTFILES_USER`: Your macOS username
2. Edit `nix/flake.nix` to modify packages:
   - Update system packages in `environment.systemPackages`
   - Add/remove Homebrew casks in `homebrew.casks`
3. Apply changes:
   ```bash
   cd ~/dotfiles
   ./update.sh
   ```

The Nix flake automatically reads `DOTFILES_HOSTNAME` and `DOTFILES_USER` from
your environment, so you don't need to hardcode them in the flake.

### Neovim

Location: `nvim/`

A modern Neovim configuration using Lazy.nvim plugin manager.

**Structure**:

- `init.lua`: Entry point
- `lua/thomas/core/`: Core settings (options, keymaps, filetypes)
- `lua/thomas/plugins/`: Plugin configurations
- `lua/thomas/plugins/lsp/`: LSP configurations

**Key Plugins**:

- Lazy.nvim: Plugin manager
- Telescope: Fuzzy finder
- LSP: Language server support
- Treesitter: Syntax highlighting
- Auto-session: Session management
- Nvim-tree: File explorer
- Trouble: Diagnostics list
- Todo-comments: Highlight TODO comments
- VimTeX: LaTeX support

**To customise**:

1. Edit plugin configurations in `nvim/lua/thomas/plugins/`
2. Modify keymaps in `nvim/lua/thomas/core/keymaps.lua`
3. Change editor options in `nvim/lua/thomas/core/options.lua`
4. Add new plugins by creating files in `nvim/lua/thomas/plugins/`

**Installing LSP servers**:

- Open Neovim and run `:Mason`
- Use `:MasonInstall <server>` to install language servers

### Tmux

Location: `tmux/.tmux.conf`

**Key Features**:

- 256-colour support with true colour
- Mouse support enabled
- Session persistence with tmux-resurrect and tmux-continuum
- Vim-style pane navigation
- Custom status line (minimal-tmux-status theme)

**Key Bindings**:

- Prefix: `Ctrl+b` (default)
- Reload config: `Prefix + R`
- Split horizontally: `Prefix + v`
- Split vertically: `Prefix + h`
- Navigate panes: `Alt + Arrow keys` (no prefix needed)
- Switch windows: `Shift + Left/Right`
- Resize panes: `Shift + h/j/k/l`
- Kill pane: `Prefix + x`
- Kill window: `Prefix + X`

**Plugins**:

- TPM: Plugin manager
- vim-tmux-navigator: Seamless vim/tmux navigation
- tmux-yank: Copy to system clipboard
- tmux-resurrect: Save/restore sessions
- tmux-continuum: Automatic session saving
- minimal-tmux-status: Minimalist status line

**To customise**:

1. Set theme colours in `.env`:
   - `TMUX_STATUS_SESSION_NAME`: Session name display
   - `TMUX_STATUS_BG`: Background colour (hex)
   - `TMUX_STATUS_FG`: Foreground colour (hex)
2. Edit `tmux/.tmux.conf` for:
   - Keybinding changes
   - Adding new plugins in the `@plugin` section
3. Reload configuration:
   - Source changes: `source ~/.zshrc` (to export new .env values)
   - Reload tmux: `tmux source ~/.tmux.conf` or `Prefix + R`

Status bar colours are automatically read from environment variables with
fallback to defaults.

### Zsh

Location: `zsh/.zshrc`

**Features**:

- Oh-My-Zsh framework
- Powerlevel10k theme (requires Nerd Font)
- Auto-suggestions and syntax highlighting
- Zoxide for smart directory jumping
- FZF for fuzzy finding

**Plugins**:

- git: Git aliases and functions
- zsh-autosuggestions: Command suggestions
- zsh-syntax-highlighting: Syntax highlighting

**Custom Aliases**:

- `cd` is aliased to `z` (zoxide)

**Environment Variables**:

- Python path: `~/Library/Python/3.11/bin`
- Java home: OpenJDK 17 via Homebrew
- Android SDK paths
- LaTeX path
- LM Studio CLI path

**To customise**:

1. Set environment variables in `.env`:
   - `PYTHON_VERSION`: Python version for user packages
   - `LM_STUDIO_PATH`: LM Studio CLI path
   - `GO_BIN_PATH`: Go binaries path
   - `MACTEX_PATH`: MacTeX binaries path
   - `ANDROID_HOME`: Android SDK location
2. Add custom aliases in `zsh/.zshrc` (search for "# Example aliases")
3. Modify Oh-My-Zsh theme if desired (currently Powerlevel10k)
4. Reload configuration: `source ~/.zshrc`

All paths are automatically configured based on your `.env` file.

### Alacritty

Location: `alacritty/alacritty.toml`

**Features**:

- GPU-accelerated rendering
- 256-colour + true colour support
- Transparent background (70% opacity)
- Background blur effect
- JetBrains Mono Light font
- Coolnight colour theme

**Configuration**:

- Font size: 14pt
- Window padding: 2px
- Decorations: Buttonless (macOS)
- Option key as Alt (Both)

**To customise**:

1. Edit `alacritty/alacritty.toml`
2. Change font: Update `font.normal.family` (line 16)
3. Adjust font size: Modify `font.size` (line 19)
4. Change opacity: Edit `window.opacity` (line 10)
5. Switch theme: Update import path (line 22)
   - Available themes in `alacritty/themes/themes/`

### AeroSpace

Location: `aerospace/aerospace.toml`

A tiling window manager for macOS inspired by i3.

**Key Features**:

- Automatic window tiling
- Multiple workspaces (1-9, A-Z)
- Vim-style navigation
- Monitor-aware workspace management

**Key Bindings**:

- Focus windows: `Alt + h/j/k/l`
- Move windows: `Alt + Shift + h/j/k/l`
- Switch workspace: `Alt + [1-9, A-Z]`
- Move to workspace: `Alt + Shift + [1-9, A-Z]`
- Resize: `Alt + -/=` (smart resize)
- Layout toggle: `Alt + /` (tiles), `Alt + ,` (accordion)
- Fullscreen: `Ctrl + Shift + f`
- Terminal: `Alt + Enter` (opens iTerm2)
- Service mode: `Alt + Shift + ;`
- Workspace toggle: `Alt + Tab`

**Service Mode** (press `Alt + Shift + ;` to enter):

- `Esc`: Reload config
- `r`: Reset layout
- `f`: Toggle floating/tiling
- `Backspace`: Close all windows except current

**To customise**:

1. Edit `aerospace/aerospace.toml`:
   - Change terminal emulator (line 93-98): Replace iTerm2 with Alacritty/other
   - Change browser (line 104): Replace Firefox with your preferred browser
   - Modify keybindings in `[mode.main.binding]` section
   - Adjust gaps (lines 60-65) for window spacing
   - Change keyboard layout preset (line 49) if not using QWERTY
2. Restart AeroSpace to apply changes:
   ```bash
   aerospace reload-config
   ```

### Claude Code

Location: `.claude/`

Custom configurations for Claude Code AI assistant:

**Agents**:

- `task-breakdown-planner`: For complex task planning
- `react-typescript-engineer`: React/TypeScript development
- `react-native-jest-tester`: Jest testing for React Native

**Commands**:

- `/document`: Documents a given file

**To customise**:

1. Add new agents in `.claude/agents/`
2. Add custom commands in `.claude/commands/`
3. Follow the file format of existing configurations

## Customisation

### Environment Variables (.env)

All user-specific configuration is managed through the `.env` file. To
customise:

1. **Edit your `.env` file**:

   ```bash
   nano ~/dotfiles/.env
   ```

2. **Available Configuration Options**:

   **Required Variables**:
   - `DOTFILES_USER`: Your macOS username
   - `DOTFILES_HOSTNAME`: Your computer hostname
   - `NVIM_NAMESPACE`: Your Neovim configuration namespace

   **Optional Variables**:
   - `DOTFILES_FULLNAME`: Your full name (for git, etc.)
   - `DOTFILES_EMAIL`: Your email address
   - `PYTHON_VERSION`: Python version (default: 3.11)
   - `LM_STUDIO_PATH`: LM Studio CLI path
   - `GO_BIN_PATH`: Go binaries path
   - `MACTEX_PATH`: MacTeX binaries path
   - `ANDROID_HOME`: Android SDK home
   - `TMUX_STATUS_SESSION_NAME`: Tmux status bar session name
   - `TMUX_STATUS_BG`: Tmux status bar background colour
   - `TMUX_STATUS_FG`: Tmux status bar foreground colour

3. **Apply Changes**:

   After editing `.env`, reload configurations:

   ```bash
   # Reload Zsh configuration
   source ~/.zshrc

   # Reload Tmux configuration (in tmux)
   tmux source ~/.tmux.conf

   # Apply Nix-Darwin changes
   cd ~/dotfiles
   ./update.sh
   ```

### Neovim Namespace

If you want to use a different namespace than "thomas":

1. **Set in `.env`**:

   ```bash
   NVIM_NAMESPACE="yourname"
   ```

2. **Rename directory and update imports**:

   ```bash
   cd ~/dotfiles/nvim/lua
   mv thomas yourname

   # Edit nvim/init.lua
   # Change: require("thomas.core") → require("yourname.core")
   # Change: require("thomas.lazy") → require("yourname.lazy")

   # Edit nvim/lua/yourname/lazy.lua
   # Change: import = "thomas.plugins" → import = "yourname.plugins"
   ```

### Changing Color Themes

**Alacritty**:

1. Browse themes in `alacritty/themes/themes/`
2. Update import in `alacritty/alacritty.toml` line 22

**Tmux**:

1. Edit `tmux/.tmux.conf` lines 66-69
2. Change background (`@minimal-tmux-bg`) and foreground (`@minimal-tmux-fg`)
   colours

**Neovim**:

1. Install a new colourscheme plugin in `nvim/lua/thomas/plugins/`
2. Set it in your configuration

### Adding New Packages

**Via Nix**:

1. Edit `nix/flake.nix`
2. Add to `environment.systemPackages` (for CLI tools) or `homebrew.casks` (for
   GUI apps)
3. Apply changes:
   ```bash
   cd ~/dotfiles
   ./update.sh
   ```

**Via Homebrew** (for packages not in Nix):

1. Edit `nix/flake.nix`
2. Add to `homebrew.brews` or `homebrew.casks`
3. Apply changes:
   ```bash
   cd ~/dotfiles
   ./update.sh
   ```

The update script automatically loads your `.env` configuration and applies all
changes to the Nix-Darwin system.

## Key Features and Keybindings

### Neovim

- Leader key: `Space` (default)
- Local leader: `,` (for VimTeX, etc.)
- Relative line numbers enabled
- System clipboard integration
- 4-space tabs with auto-indent

### Tmux

- Seamless Vim/Tmux navigation with Ctrl+h/j/k/l
- Mouse support for scrolling and pane selection
- Persistent sessions that survive restarts
- Vi-mode for copy mode

### Zsh

- Smart directory jumping with `z` (zoxide)
- Fuzzy file finding with `Ctrl+R` (fzf)
- Git integration with useful aliases
- Command auto-suggestions

### AeroSpace

- i3-like tiling window management
- 35+ workspaces for organising windows
- Keyboard-driven workflow
- Multi-monitor support

## Troubleshooting

### Environment Configuration Issues

**Problem**: .env file not found or missing variables

```bash
# Create .env from example
cp ~/dotfiles/.env.example ~/dotfiles/.env

# Edit with your configuration
nano ~/dotfiles/.env

# Verify required variables are set
grep -E "^DOTFILES_(USER|HOSTNAME|NVIM_NAMESPACE)=" ~/dotfiles/.env

# Re-run installation
cd ~/dotfiles
./install.sh
```

**Problem**: Configuration changes not taking effect

```bash
# Ensure .env is being sourced
source ~/dotfiles/.env

# Verify variables are set
echo $DOTFILES_USER
echo $DOTFILES_HOSTNAME

# Update configs
cd ~/dotfiles
./update.sh
source ~/.zshrc
```

### Nix Installation Issues

**Problem**: Permission denied or sudo errors

```bash
# Ensure you have sudo access
sudo -v

# If you get permission errors:
# 1. Make sure you're an administrator on your Mac
# 2. Check System Settings > Users & Groups
# 3. Your account should have "Allow user to administer this computer" checked

# Run the update script (which requires sudo for Nix-Darwin)
cd ~/dotfiles
./update.sh
```

**Problem**: Flake evaluation fails

```bash
# Ensure flakes are enabled
nix --version  # Should be 2.4+
nix show-config | grep experimental-features  # Should show "flakes"
```

**Problem**: Wrong hostname

```bash
# Check your hostname
scutil --get ComputerName
# Or
hostname

# Update in .env file
nano ~/dotfiles/.env
# Set DOTFILES_HOSTNAME to your actual hostname
```

### Symlink Issues

**Problem**: Configuration not loading

```bash
# Verify symlinks
ls -la ~/.config/nvim
ls -la ~/.config/alacritty
ls -la ~/.tmux.conf
ls -la ~/.zshrc

# Re-run install script if needed
cd ~/dotfiles
./install.sh
```

### Tmux Plugin Installation

**Problem**: Plugins not loading

```bash
# Install TPM if missing
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Inside tmux, press: Ctrl+b then Shift+i
```

### Neovim Issues

**Problem**: Lazy.nvim not bootstrapping

```bash
# Remove lazy.nvim and restart
rm -rf ~/.local/share/nvim/lazy
nvim  # Will auto-install
```

**Problem**: LSP servers not working

```bash
# Install Mason and LSP servers
nvim
:Mason
# Install desired language servers
```

### Font Issues

**Problem**: Icons/glyphs not displaying

- Install Nerd Fonts: Already included in Nix config
- Verify font in terminal: Should use "JetBrains Mono Nerd Font"
- Alacritty: Check `font.normal.family` in `alacritty.toml`

### AeroSpace Not Starting

**Problem**: AeroSpace not launching at login

```bash
# Check if installed
aerospace --version

# Enable start at login in aerospace.toml (line 15)
# Restart AeroSpace
brew services restart aerospace
```

### Path Issues

**Problem**: Commands not found

```bash
# Ensure .env is loaded
source ~/dotfiles/.env
source ~/.zshrc

# Verify Nix is in PATH
echo $PATH | grep nix

# Verify environment-based paths are set
echo $PATH | grep -E "(Python|go|lm-studio)"

# Rebuild Nix config
cd ~/dotfiles
./update.sh
```

---

## License

This configuration is available for personal use. Feel free to fork and
customise for your own setup.

## Credits

Built with configurations inspired by the dotfiles community and various
open-source projects.
