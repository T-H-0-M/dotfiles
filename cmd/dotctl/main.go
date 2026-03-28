package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"dotfiles/internal/config"
	"dotfiles/internal/ops"
	"dotfiles/internal/run"
	"dotfiles/internal/ui"

	"github.com/charmbracelet/lipgloss"
)

func main() {
	args := os.Args[1:]
	dryRun, yes, root := false, false, "."
	var positional []string

	// Parse global flags from anywhere; collect the rest as positional.
	for i := 0; i < len(args); i++ {
		switch args[i] {
		case "--dry-run":
			dryRun = true
		case "--yes", "-y":
			yes = true
		case "--root":
			if i+1 < len(args) {
				i++
				root = args[i]
			} else {
				fatal("--root requires a path")
			}
		case "--help", "-h":
			printHelp()
			return
		default:
			// Subcommand-specific flags (e.g. --full) and commands.
			positional = append(positional, args[i])
		}
	}

	absRoot, err := filepath.Abs(root)
	if err != nil {
		fatal("%v", err)
	}

	// Commands that don't need .env: help, doctor.
	cmd := ""
	if len(positional) > 0 {
		cmd = positional[0]
	}

	if cmd == "" {
		printHelp()
		return
	}

	// Doctor loads its own config.
	if cmd == "doctor" {
		o := &run.Opts{Root: absRoot, DryRun: dryRun}
		if err := ops.Doctor(o); err != nil {
			fatal("%v", err)
		}
		return
	}

	cfg, err := config.Load(absRoot)
	if err != nil {
		fatal("%v", err)
	}

	o := &run.Opts{Root: absRoot, Cfg: cfg, DryRun: dryRun, Yes: yes}

	switch cmd {
	case "install":
		err = ops.Install(o)
	case "update":
		item := ""
		if len(positional) > 1 {
			item = positional[1]
		}
		err = ops.Update(o, item)
	case "apply":
		err = ops.Apply(o)
	case "clean":
		full := false
		for _, a := range positional[1:] {
			if a == "--full" {
				full = true
			}
		}
		err = ops.Clean(o, full)
	case "link":
		filter := ""
		for _, a := range positional[1:] {
			if strings.HasPrefix(a, "--") {
				filter = strings.TrimPrefix(a, "--")
			}
		}
		if filter != "" {
			ui.Header("dotctl link --" + filter)
		} else {
			ui.Header("dotctl link")
		}
		if err := ops.Symlinks(o, filter); err != nil {
			fatal("%v", err)
		}
		ui.Done()
		return
	default:
		fatal("unknown command: %s\nRun dotctl --help for usage.", cmd)
	}

	if err != nil {
		fatal("%v", err)
	}
}

func fatal(format string, args ...any) {
	ui.Fatalf(format, args...)
	os.Exit(1)
}

// ---------------------------------------------------------------------------
// Styled help
// ---------------------------------------------------------------------------

func printHelp() {
	title := lipgloss.NewStyle().
		Bold(true).
		Foreground(lipgloss.Color("212")).
		Render("dotctl")

	subtitle := ui.Dim.Render("macOS dotfiles automation")

	cmdStyle := lipgloss.NewStyle().
		Foreground(lipgloss.Color("81")).
		Width(28)
	descStyle := ui.Dim

	cmds := []struct{ cmd, desc string }{
		{"install", "Full machine bootstrap"},
		{"update", "Update everything (flake, brew, zsh, tmux)"},
		{"update <item>", "Update one: " + strings.Join(ops.UpdateItems, ", ")},
		{"apply", "Apply nix-darwin configuration"},
		{"clean", "Nix store garbage collect"},
		{"clean --full", "Delete all generations + gc"},
		{"link", "Create dotfile symlinks"},
		{"link --<name>", "Link one: " + strings.Join(ops.LinkTargets, ", ")},
		{"doctor", "Validate local setup"},
	}

	flags := []struct{ flag, desc string }{
		{"--dry-run", "Print commands without executing"},
		{"--yes, -y", "Skip confirmation prompts"},
		{"--root PATH", "Set dotfiles root (default: .)"},
	}

	fmt.Printf("\n  %s  %s\n\n", title, subtitle)

	fmt.Printf("  %s\n\n", ui.Bold.Render("Commands"))
	for _, c := range cmds {
		fmt.Printf("    %s%s\n", cmdStyle.Render(c.cmd), descStyle.Render(c.desc))
	}

	fmt.Printf("\n  %s\n\n", ui.Bold.Render("Flags"))
	for _, f := range flags {
		fmt.Printf("    %s%s\n", cmdStyle.Render(f.flag), descStyle.Render(f.desc))
	}
	fmt.Println()
}
