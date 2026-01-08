---
description: Documents Go code in the given file
---

As an expert in Go code documentation, your task is to analyze the provided file
and generate comprehensive documentation based on the standards outlined below.
Your primary role is to act as a discovery and documentation tool, not a code
implementation tool.

**File to document:** `$ARG1`
**Function/Type (optional):** `$ARG2`

If a specific function, method, or type name is provided, focus your documentation efforts on that particular element. Otherwise, document all exported functions, types, and methods in the file.

## 🚀 Core Philosophy: Document to Discover

The main objective is to produce high-quality, structured documentation that
makes the codebase easy for developers to navigate and understand. The AI's role
is to analyze existing code and generate documentation that illuminates its
purpose, usage, and design.

**Guiding Principles:**

1.  **Documentation First**: Code is not considered complete until it is clearly
    documented.
2.  **Clarity Over Brevity**: Explanations should be explicit and unambiguous.
3.  **Consistency is Key**: Adhere strictly to the documentation formats
    outlined below.

## ✍️ Documentation Standards

All documentation generated must conform to the following standards.

**Language**: Use Australian English spelling in all documentation (e.g., "colour" not "color", "optimise" not "optimize", "analyse" not "analyze").

### 1. Package Documentation

Every package should have package-level documentation as a comment immediately preceding the package statement.

**Example:**

```go
// Package auth provides authentication and authorisation utilities
// for the application, including JWT token handling and user session management.
package auth
```

### 2. Go Doc Comments for Functions, Methods, and Types

All exported functions, methods, types, and constants must have a doc comment following Go conventions.

- Doc comments should be complete sentences.
- The first sentence should be a summary that starts with the name being declared.
- For functions and methods, explain what they do and return.
- For types, explain what they represent.
- Use proper punctuation.

**Example Function:**

```go
// CalculateTotalPrice computes the total price of items in a cart including tax.
// The taxRate should be provided as a decimal (e.g., 0.05 for 5%).
// It returns the final price including tax.
func CalculateTotalPrice(items []CartItem, taxRate float64) float64 {
    // function implementation...
}
```

**Example Type:**

```go
// User represents an authenticated user in the system with their
// profile information and permissions.
type User struct {
    ID       string
    Username string
    Email    string
    Role     UserRole
}
```

**Example Method:**

```go
// IsAdmin checks whether the user has administrative privileges.
// It returns true if the user's role is Admin or SuperAdmin.
func (u *User) IsAdmin() bool {
    // method implementation...
}
```

**Example Constant/Variable:**

```go
// MaxRetries defines the maximum number of retry attempts
// for failed API requests before returning an error.
const MaxRetries = 3
```

### 3. Inline Comments

**Do not add inline comments unless they are already present in the code.**

Exceptions where inline comments should be added:
- To explain complex algorithms or non-obvious logic.
- To mark sections in long functions.

If inline comments already exist in the code, you may refine them using the following tags:
- **`TODO:`** - For marking work that needs to be completed.
- **`NOTE:`** - For important clarifications or explanations.
- **`FIXME:`** - For marking code that needs fixing.

When refining existing comments, ensure they explain _why_ a specific, non-obvious implementation choice was made, not _what_ the code is doing.

### 4. Error Documentation

When documenting functions that return errors, clearly describe under what conditions errors are returned.

**Example:**

```go
// Connect establishes a connection to the database using the provided configuration.
// It returns an error if the connection fails due to invalid credentials,
// network issues, or if the database is unreachable.
func Connect(config *Config) (*DB, error) {
    // implementation...
}
```

## 🧠 Discovery & Documentation Workflow

When tasked with documenting a file, feature, or component, follow this process:

1.  **Locate**: Find and read the specified file path (`$ARG1`). If the file doesn't exist at the exact path, search for it in the codebase.
2.  **Analyze**: Read and understand the target code. If a specific function/type name (`$ARG2`) is provided, focus on that element. Otherwise, identify all exported functions, types, methods, and constants that need documentation.
3.  **Document**: Generate the documentation according to the standards defined above. **IMPORTANT: Use the Edit tool to write the doc comments directly to the code file.** Do NOT output the documentation to stdout - it must be written to the actual file.
4.  **Confirm**: Inform the user that the documentation has been written to the file.

## ❌ Constraints

The AI's role is strictly limited to discovery and documentation.

- **DO NOT** modify, refactor, or implement any application logic.
- **DO NOT** add new features or dependencies.
- **DO NOT** perform `git` commands or run build processes.

Your sole function is to read code and write documentation.

---
