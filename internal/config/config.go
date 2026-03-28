package config

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// Config holds values loaded from the .env file.
type Config struct {
	Values           map[string]string
	DotfilesUser     string
	DotfilesHostname string
	NvimNamespace    string
}

// Load reads the .env file from root and returns a Config.
func Load(root string) (Config, error) {
	path := filepath.Join(root, ".env")
	values, err := parseEnvFile(path)
	if err != nil {
		return Config{}, err
	}
	return Config{
		Values:           values,
		DotfilesUser:     values["DOTFILES_USER"],
		DotfilesHostname: values["DOTFILES_HOSTNAME"],
		NvimNamespace:    values["NVIM_NAMESPACE"],
	}, nil
}

// Validate checks that the given keys are present and non-empty.
func (c Config) Validate(keys ...string) error {
	var missing []string
	for _, k := range keys {
		if strings.TrimSpace(c.Values[k]) == "" {
			missing = append(missing, k)
		}
	}
	if len(missing) > 0 {
		sort.Strings(missing)
		return fmt.Errorf("missing required values in .env: %s", strings.Join(missing, ", "))
	}
	return nil
}

// Environ returns the current process environment merged with .env values.
func (c Config) Environ() []string {
	merged := map[string]string{}
	for _, item := range os.Environ() {
		if k, v, ok := strings.Cut(item, "="); ok {
			merged[k] = v
		}
	}
	for k, v := range c.Values {
		merged[k] = v
	}
	out := make([]string, 0, len(merged))
	for k, v := range merged {
		out = append(out, k+"="+v)
	}
	sort.Strings(out)
	return out
}

func parseEnvFile(path string) (map[string]string, error) {
	f, err := os.Open(path)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, fmt.Errorf("%s not found; copy .env.example to .env", path)
		}
		return nil, fmt.Errorf("open %s: %w", path, err)
	}
	defer f.Close()

	values := map[string]string{}
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		line = strings.TrimPrefix(line, "export ")
		k, v, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}
		k = strings.TrimSpace(k)
		if k == "" {
			continue
		}
		values[k] = unquote(strings.TrimSpace(v))
	}
	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("read %s: %w", path, err)
	}

	// Expand variable references (up to 8 passes).
	for range 8 {
		changed := false
		for k, v := range values {
			expanded := os.Expand(v, func(name string) string {
				if val, ok := values[name]; ok {
					return val
				}
				return os.Getenv(name)
			})
			if expanded != v {
				values[k] = expanded
				changed = true
			}
		}
		if !changed {
			break
		}
	}
	return values, nil
}

func unquote(s string) string {
	if len(s) >= 2 && s[0] == '"' && s[len(s)-1] == '"' {
		s = s[1 : len(s)-1]
		s = strings.ReplaceAll(s, `\n`, "\n")
		s = strings.ReplaceAll(s, `\"`, `"`)
		return s
	}
	if len(s) >= 2 && s[0] == '\'' && s[len(s)-1] == '\'' {
		return s[1 : len(s)-1]
	}
	if idx := strings.Index(s, " #"); idx >= 0 {
		s = strings.TrimSpace(s[:idx])
	}
	return s
}
