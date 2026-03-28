package ui

import (
	"fmt"

	"github.com/charmbracelet/lipgloss"
)

var (
	Bold    = lipgloss.NewStyle().Bold(true)
	Dim     = lipgloss.NewStyle().Foreground(lipgloss.Color("241"))
	Green   = lipgloss.NewStyle().Foreground(lipgloss.Color("42"))
	Red     = lipgloss.NewStyle().Foreground(lipgloss.Color("196"))
	Yellow  = lipgloss.NewStyle().Foreground(lipgloss.Color("214"))
	Gray    = lipgloss.NewStyle().Foreground(lipgloss.Color("244"))
	Cyan    = lipgloss.NewStyle().Foreground(lipgloss.Color("81"))
	Magenta = lipgloss.NewStyle().Foreground(lipgloss.Color("212"))
)

// Header prints a bold styled header line.
func Header(title string) {
	fmt.Printf("\n%s\n\n", Bold.Render(title))
}

// StepStart prints the beginning of a step.
func StepStart(name string) {
	fmt.Printf("%s %s\n", Dim.Render("▶"), name)
}

// StepDone prints a successful step.
func StepDone(name string) {
	fmt.Printf("%s %s\n\n", Green.Render("✓"), name)
}

// StepSkipped prints a skipped step with a reason.
func StepSkipped(name, reason string) {
	if reason != "" {
		fmt.Printf("%s %s (%s)\n\n", Gray.Render("-"), name, reason)
	} else {
		fmt.Printf("%s %s (skipped)\n\n", Gray.Render("-"), name)
	}
}

// StepFailed prints a failed step.
func StepFailed(name string) {
	fmt.Printf("%s %s\n\n", Red.Render("✗"), name)
}

// Check prints a pass/fail check line.
func Check(name string, err error) {
	if err != nil {
		fmt.Printf("  %s %s: %v\n", Red.Render("✗"), name, err)
	} else {
		fmt.Printf("  %s %s\n", Green.Render("✓"), name)
	}
}

// LogLine prints an indented output line.
func LogLine(line string) {
	fmt.Printf("  %s\n", line)
}

// CmdLine prints an indented dimmed command line.
func CmdLine(line string) {
	fmt.Printf("  %s\n", Dim.Render(line))
}

// ErrLine prints an indented error-styled line.
func ErrLine(line string) {
	fmt.Printf("  %s %s\n", Red.Render("err |"), line)
}

// Done prints the final completion message.
func Done() {
	fmt.Println(Green.Render("All steps completed."))
}

// Fatalf prints an error and returns it (caller should os.Exit).
func Fatalf(format string, args ...any) {
	fmt.Printf("%s %s\n", Red.Render("error:"), fmt.Sprintf(format, args...))
}
