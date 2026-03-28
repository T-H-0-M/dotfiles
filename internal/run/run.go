package run

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"strings"
	"sync"

	"dotfiles/internal/config"
	"dotfiles/internal/ui"
)

// Opts controls execution behavior.
type Opts struct {
	Root   string
	Cfg    config.Config
	DryRun bool
	Quiet  bool
	Yes    bool
}

// SkipErr signals a step was intentionally skipped.
type SkipErr struct{ Reason string }

func (e *SkipErr) Error() string { return e.Reason }

// Skip returns a SkipErr with the given reason.
func Skip(reason string) error { return &SkipErr{Reason: reason} }

// IsSkip returns true if err is a SkipErr.
func IsSkip(err error) bool {
	_, ok := err.(*SkipErr)
	return ok
}

// Step runs a named step, printing status via ui.
// Returns the error from fn (nil on success or skip).
func Step(name string, fn func() error) error {
	ui.StepStart(name)
	err := fn()
	switch {
	case err == nil:
		ui.StepDone(name)
	case IsSkip(err):
		ui.StepSkipped(name, err.Error())
		return nil
	default:
		ui.StepFailed(name)
		return err
	}
	return nil
}

// Cmd executes a command, streaming output unless quiet.
func Cmd(o *Opts, name string, args ...string) error {
	ui.CmdLine("$ " + formatCmd(name, args...))
	if o.DryRun {
		return nil
	}
	return execCmd(o, o.Root, name, args...)
}

// CmdIn executes a command in the given directory.
func CmdIn(o *Opts, dir, name string, args ...string) error {
	ui.CmdLine("$ " + formatCmd(name, args...))
	if o.DryRun {
		return nil
	}
	return execCmd(o, dir, name, args...)
}

// Shell executes a shell command via bash -lc.
func Shell(o *Opts, command string) error {
	ui.CmdLine("$ " + command)
	if o.DryRun {
		return nil
	}
	return execCmd(o, o.Root, "/bin/bash", "-lc", command)
}

func execCmd(o *Opts, dir, name string, args ...string) error {
	cmd := exec.Command(name, args...)
	cmd.Dir = dir
	cmd.Env = o.Cfg.Environ()

	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return fmt.Errorf("stdout pipe: %w", err)
	}
	stderr, err := cmd.StderrPipe()
	if err != nil {
		return fmt.Errorf("stderr pipe: %w", err)
	}
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("start %s: %w", name, err)
	}

	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		drain(stdout, o.Quiet, ui.LogLine)
	}()
	go func() {
		defer wg.Done()
		drain(stderr, o.Quiet, ui.ErrLine)
	}()
	wg.Wait()

	if err := cmd.Wait(); err != nil {
		return fmt.Errorf("%s failed: %w", formatCmd(name, args...), err)
	}
	return nil
}

func drain(r io.Reader, quiet bool, logFn func(string)) {
	if quiet {
		_, _ = io.Copy(io.Discard, r)
		return
	}
	s := bufio.NewScanner(r)
	s.Buffer(make([]byte, 0, 64*1024), 1024*1024)
	for s.Scan() {
		if line := strings.TrimSpace(s.Text()); line != "" {
			logFn(line)
		}
	}
}

func formatCmd(name string, args ...string) string {
	parts := []string{quote(name)}
	for _, a := range args {
		parts = append(parts, quote(a))
	}
	return strings.Join(parts, " ")
}

func quote(s string) string {
	if s == "" {
		return "''"
	}
	if !strings.ContainsAny(s, " \t\n\"'$") {
		return s
	}
	return "'" + strings.ReplaceAll(s, "'", `'\''`) + "'"
}

// EnsureSudo prompts for sudo credentials up front.
func EnsureSudo(dryRun bool) error {
	if dryRun {
		return nil
	}
	if _, err := exec.LookPath("sudo"); err != nil {
		return fmt.Errorf("sudo not found")
	}
	fmt.Println("Authenticating sudo...")
	cmd := exec.Command("sudo", "-v")
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}

// Confirm asks the user to proceed. Skipped if yes or dryRun is true.
func Confirm(prompt string, yes, dryRun bool) error {
	if yes || dryRun {
		return nil
	}
	fmt.Printf("%s [y/N] ", prompt)
	var answer string
	fmt.Scanln(&answer)
	answer = strings.TrimSpace(strings.ToLower(answer))
	if answer != "y" && answer != "yes" {
		return fmt.Errorf("cancelled")
	}
	return nil
}
