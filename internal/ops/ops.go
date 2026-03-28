package ops

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"time"

	"dotfiles/internal/config"
	"dotfiles/internal/run"
	"dotfiles/internal/ui"
)

// ---------------------------------------------------------------------------
// Install
// ---------------------------------------------------------------------------

func Install(o *run.Opts) error {
	ui.Header("dotctl install")
	if err := o.Cfg.Validate("DOTFILES_USER", "DOTFILES_HOSTNAME", "NVIM_NAMESPACE"); err != nil {
		return err
	}
	if err := run.Confirm("Run full dotfiles install?", o.Yes, o.DryRun); err != nil {
		return err
	}
	if err := run.EnsureSudo(o.DryRun); err != nil {
		return err
	}

	if err := run.Step("Check operating system", checkDarwin); err != nil {
		return err
	}
	if err := run.Step("Print configuration", func() error {
		ui.LogLine("Root:      " + o.Root)
		ui.LogLine("User:      " + o.Cfg.DotfilesUser)
		ui.LogLine("Hostname:  " + o.Cfg.DotfilesHostname)
		ui.LogLine("Nvim NS:   " + o.Cfg.NvimNamespace)
		return nil
	}); err != nil {
		return err
	}
	if err := run.Step("Ensure Nix is installed", func() error {
		if cmdExists("nix") {
			return run.Skip("already installed")
		}
		return run.Shell(o, "sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon")
	}); err != nil {
		return err
	}
	if err := Symlinks(o, ""); err != nil {
		return err
	}
	if err := installZsh(o); err != nil {
		return err
	}
	if err := run.Step("Install Tmux Plugin Manager", func() error {
		dir, err := homePath(".tmux", "plugins", "tpm")
		if err != nil {
			return err
		}
		if exists(dir) {
			return run.Skip("already installed")
		}
		return run.Cmd(o, "git", "clone", "https://github.com/tmux-plugins/tpm", dir)
	}); err != nil {
		return err
	}
	if err := applyDarwin(o); err != nil {
		return err
	}
	if err := run.Step("Check Neovim namespace", func() error {
		if o.Cfg.NvimNamespace == "thomas" {
			return run.Skip("namespace unchanged")
		}
		legacy := filepath.Join(o.Root, "nvim", "lua", "thomas")
		if !exists(legacy) {
			return run.Skip("legacy path not found")
		}
		ui.LogLine("Rename manually if needed:")
		ui.LogLine(fmt.Sprintf("  mv %s %s", legacy, filepath.Join(o.Root, "nvim", "lua", o.Cfg.NvimNamespace)))
		ui.LogLine("  Then update imports in nvim/init.lua and nvim/lua/thomas/lazy.lua")
		return nil
	}); err != nil {
		return err
	}

	ui.Done()
	return nil
}

// ---------------------------------------------------------------------------
// Update (all or a specific item)
// ---------------------------------------------------------------------------

var UpdateItems = []string{"brew", "flake", "zsh", "tmux", "symlinks"}

func Update(o *run.Opts, item string) error {
	if item != "" {
		return updateOne(o, item)
	}
	ui.Header("dotctl update")
	if err := run.Confirm("Run full update?", o.Yes, o.DryRun); err != nil {
		return err
	}
	if err := run.EnsureSudo(o.DryRun); err != nil {
		return err
	}
	if err := run.Step("Check operating system", checkDarwin); err != nil {
		return err
	}

	if err := UpdateFlake(o); err != nil {
		return err
	}
	if err := applyDarwin(o); err != nil {
		return err
	}
	if err := UpdateBrew(o); err != nil {
		return err
	}
	if err := UpdateZsh(o); err != nil {
		return err
	}
	if err := UpdateTmux(o); err != nil {
		return err
	}

	ui.Done()
	return nil
}

func updateOne(o *run.Opts, item string) error {
	ui.Header("dotctl update " + item)
	switch item {
	case "brew":
		if err := UpdateBrew(o); err != nil {
			return err
		}
	case "flake":
		if err := UpdateFlake(o); err != nil {
			return err
		}
	case "zsh":
		if err := UpdateZsh(o); err != nil {
			return err
		}
	case "tmux":
		if err := UpdateTmux(o); err != nil {
			return err
		}
	case "symlinks":
		if err := Symlinks(o, ""); err != nil {
			return err
		}
	default:
		return fmt.Errorf("unknown update item %q (valid: %v)", item, UpdateItems)
	}
	ui.Done()
	return nil
}

func UpdateBrew(o *run.Opts) error {
	return run.Step("Update Homebrew packages", func() error {
		if !cmdExists("brew") {
			return run.Skip("brew not found")
		}
		if err := run.Cmd(o, "brew", "update"); err != nil {
			return err
		}
		if err := run.Cmd(o, "brew", "upgrade"); err != nil {
			return err
		}
		return run.Cmd(o, "brew", "cleanup")
	})
}

func UpdateFlake(o *run.Opts) error {
	return run.Step("Update Nix flake", func() error {
		return run.CmdIn(o, filepath.Join(o.Root, "nix"), "nix", "flake", "update")
	})
}

func UpdateZsh(o *run.Opts) error {
	items := []struct {
		name string
		path []string
	}{
		{"Oh-My-Zsh", nil},
		{"Powerlevel10k", nil},
		{"zsh-autosuggestions", nil},
		{"zsh-syntax-highlighting", nil},
	}

	// Resolve paths.
	omz, err := homePath(".oh-my-zsh")
	if err != nil {
		return err
	}
	items[0].path = []string{omz}

	zshCustom := os.Getenv("ZSH_CUSTOM")
	if zshCustom == "" {
		zshCustom = filepath.Join(omz, "custom")
	}
	items[1].path = []string{filepath.Join(zshCustom, "themes", "powerlevel10k")}
	items[2].path = []string{filepath.Join(zshCustom, "plugins", "zsh-autosuggestions")}
	items[3].path = []string{filepath.Join(zshCustom, "plugins", "zsh-syntax-highlighting")}

	for _, it := range items {
		name := it.name
		dir := it.path[0]
		if err := run.Step("Update "+name, func() error {
			if !exists(dir) {
				return run.Skip("not installed")
			}
			return run.CmdIn(o, dir, "git", "pull")
		}); err != nil {
			return err
		}
	}
	return nil
}

func UpdateTmux(o *run.Opts) error {
	if err := run.Step("Update TPM", func() error {
		dir, err := homePath(".tmux", "plugins", "tpm")
		if err != nil {
			return err
		}
		if !exists(dir) {
			return run.Skip("TPM not installed")
		}
		return run.CmdIn(o, dir, "git", "pull")
	}); err != nil {
		return err
	}
	return run.Step("Update tmux plugins", func() error {
		if !cmdExists("tmux") {
			return run.Skip("tmux not installed")
		}
		path, err := homePath(".tmux", "plugins", "tpm", "bin", "update_plugins")
		if err != nil {
			return err
		}
		if !exists(path) {
			return run.Skip("TPM update script not found")
		}
		return run.Cmd(o, path, "all")
	})
}

// ---------------------------------------------------------------------------
// Apply (darwin-rebuild)
// ---------------------------------------------------------------------------

func Apply(o *run.Opts) error {
	ui.Header("dotctl apply")
	if err := o.Cfg.Validate("DOTFILES_USER", "DOTFILES_HOSTNAME"); err != nil {
		return err
	}
	if err := run.Confirm("Apply nix-darwin configuration?", o.Yes, o.DryRun); err != nil {
		return err
	}
	if err := run.EnsureSudo(o.DryRun); err != nil {
		return err
	}
	if err := run.Step("Check operating system", checkDarwin); err != nil {
		return err
	}
	if err := applyDarwin(o); err != nil {
		return err
	}
	ui.Done()
	return nil
}

// ---------------------------------------------------------------------------
// Clean (nix garbage collection)
// ---------------------------------------------------------------------------

func Clean(o *run.Opts, full bool) error {
	if full {
		ui.Header("dotctl clean --full")
	} else {
		ui.Header("dotctl clean")
	}
	if full {
		return run.Step("Nix collect garbage (all generations)", func() error {
			return run.Cmd(o, "nix-collect-garbage", "-d")
		})
	}
	return run.Step("Nix store garbage collect", func() error {
		return run.Cmd(o, "nix", "store", "gc")
	})
}

// ---------------------------------------------------------------------------
// Doctor
// ---------------------------------------------------------------------------

func Doctor(o *run.Opts) error {
	ui.Header("dotctl doctor")

	tools := []string{"git", "nix", "brew", "nvim", "tmux", "zsh"}
	ui.Check("macOS", checkDarwin())
	for _, t := range tools {
		var err error
		if !cmdExists(t) {
			err = fmt.Errorf("not found")
		}
		ui.Check(t, err)
	}

	cfg, err := config.Load(o.Root)
	if err != nil {
		return err
	}
	if err := cfg.Validate("DOTFILES_USER", "DOTFILES_HOSTNAME"); err != nil {
		return err
	}
	ui.Check(".env", nil)
	ui.LogLine(fmt.Sprintf("  user=%s  host=%s", cfg.DotfilesUser, cfg.DotfilesHostname))
	fmt.Println()
	return nil
}

// ---------------------------------------------------------------------------
// Symlinks
// ---------------------------------------------------------------------------

type symlink struct {
	key, src, dst, label string
}

func symlinkTargets(root string) []symlink {
	return []symlink{
		{"nvim", filepath.Join(root, "nvim"), "~/.config/nvim", "Neovim config"},
		{"alacritty", filepath.Join(root, "alacritty"), "~/.config/alacritty", "Alacritty config"},
		{"tmux", filepath.Join(root, "tmux", ".tmux.conf"), "~/.tmux.conf", "Tmux config"},
		{"zsh", filepath.Join(root, "zsh", ".zshrc"), "~/.zshrc", "Zsh config"},
		{"nix", filepath.Join(root, "nix"), "~/.config/nix", "Nix config"},
		{"aerospace", filepath.Join(root, "aerospace"), "~/.config/aerospace", "AeroSpace config"},
		{"claude", filepath.Join(root, ".claude"), "~/.claude", "Claude Code config"},
		{"opencode", filepath.Join(root, ".opencode"), "~/.config/opencode", "OpenCode config"},
		{"cursor", filepath.Join(root, "cursor", "settings.json"), "~/Library/Application Support/Cursor/User/settings.json", "Cursor settings"},
	}
}

// LinkTargets returns the valid --<name> flags for dotctl link.
var LinkTargets = []string{"nvim", "alacritty", "tmux", "zsh", "nix", "aerospace", "claude", "opencode", "cursor"}

// Symlinks creates symlinks. If filter is non-empty, only the matching target is linked.
func Symlinks(o *run.Opts, filter string) error {
	all := symlinkTargets(o.Root)
	var targets []symlink
	if filter != "" {
		for _, l := range all {
			if l.key == filter {
				targets = append(targets, l)
				break
			}
		}
		if len(targets) == 0 {
			return fmt.Errorf("unknown link target %q (valid: %v)", filter, LinkTargets)
		}
	} else {
		targets = all
	}

	stepName := "Create dotfile symlinks"
	if filter != "" {
		stepName = "Link " + targets[0].label
	}

	return run.Step(stepName, func() error {
		for _, l := range targets {
			dst, err := expandHome(l.dst)
			if err != nil {
				return err
			}
			if err := ensureSymlink(o, l.src, dst, l.label); err != nil {
				return err
			}
		}
		return nil
	})
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

func checkDarwin() error {
	if runtime.GOOS != "darwin" {
		return fmt.Errorf("unsupported OS %q (macOS only)", runtime.GOOS)
	}
	return nil
}

func cmdExists(name string) bool {
	_, err := exec.LookPath(name)
	return err == nil
}

func exists(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}

func homePath(parts ...string) (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(append([]string{home}, parts...)...), nil
}

func expandHome(path string) (string, error) {
	if len(path) >= 2 && path[:2] == "~/" {
		home, err := homePath()
		if err != nil {
			return "", err
		}
		return filepath.Join(home, path[2:]), nil
	}
	if path == "~" {
		return homePath()
	}
	return path, nil
}

func ensureSymlink(o *run.Opts, src, dst, label string) error {
	ui.LogLine("Linking " + label)
	if o.DryRun {
		ui.CmdLine(fmt.Sprintf("[dry-run] ln -s %s %s", src, dst))
		return nil
	}

	if info, err := os.Lstat(dst); err == nil {
		if info.Mode()&os.ModeSymlink == 0 {
			backup := fmt.Sprintf("%s.backup.%d", dst, time.Now().Unix())
			ui.LogLine("Backing up " + dst + " -> " + backup)
			if err := os.Rename(dst, backup); err != nil {
				return fmt.Errorf("backup %s: %w", dst, err)
			}
		} else {
			os.Remove(dst)
		}
	} else if !os.IsNotExist(err) {
		return fmt.Errorf("stat %s: %w", dst, err)
	}

	if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
		return fmt.Errorf("mkdir for %s: %w", dst, err)
	}
	return os.Symlink(src, dst)
}

func applyDarwin(o *run.Opts) error {
	return run.Step("Apply nix-darwin configuration", func() error {
		if err := checkDarwin(); err != nil {
			return err
		}
		nixDir := filepath.Join(o.Root, "nix")
		flakeRef := fmt.Sprintf("%s#%s", nixDir, o.Cfg.DotfilesHostname)
		if cmdExists("darwin-rebuild") {
			return run.CmdIn(o, nixDir, "sudo", "-E", "darwin-rebuild", "switch", "--flake", flakeRef)
		}
		return run.CmdIn(o, nixDir, "sudo", "-E", "nix", "run", "nix-darwin", "--", "switch", "--flake", flakeRef)
	})
}

func installZsh(o *run.Opts) error {
	if err := run.Step("Install Oh-My-Zsh", func() error {
		dir, err := homePath(".oh-my-zsh")
		if err != nil {
			return err
		}
		if exists(dir) {
			return run.Skip("already installed")
		}
		return run.Shell(o, `RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended`)
	}); err != nil {
		return err
	}

	zshCustom := os.Getenv("ZSH_CUSTOM")
	if zshCustom == "" {
		omz, err := homePath(".oh-my-zsh", "custom")
		if err != nil {
			return err
		}
		zshCustom = omz
	}

	clones := []struct {
		name, repo, dest string
	}{
		{"Powerlevel10k", "https://github.com/romkatv/powerlevel10k.git", filepath.Join(zshCustom, "themes", "powerlevel10k")},
		{"zsh-autosuggestions", "https://github.com/zsh-users/zsh-autosuggestions", filepath.Join(zshCustom, "plugins", "zsh-autosuggestions")},
		{"zsh-syntax-highlighting", "https://github.com/zsh-users/zsh-syntax-highlighting.git", filepath.Join(zshCustom, "plugins", "zsh-syntax-highlighting")},
	}
	for _, c := range clones {
		name, repo, dest := c.name, c.repo, c.dest
		if err := run.Step("Install "+name, func() error {
			if exists(dest) {
				return run.Skip("already installed")
			}
			args := []string{"clone"}
			if name == "Powerlevel10k" {
				args = append(args, "--depth=1")
			}
			args = append(args, repo, dest)
			return run.Cmd(o, "git", args...)
		}); err != nil {
			return err
		}
	}
	return nil
}
