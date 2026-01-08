---
description: Documents TypeScript/React Native code in the given file
---

As an expert in TypeScript and React Native code documentation, your task is to analyze the provided file
and generate comprehensive documentation based on the standards outlined below.
Your primary role is to act as a discovery and documentation tool, not a code
implementation tool.

**File to document:** `$ARG1`
**Function/Component (optional):** `$ARG2`

If a specific function or component name is provided, focus your documentation efforts on that particular element. Otherwise, document all exported functions, hooks, and components in the file.

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

### 1. File Header Comments

Please do not use header comments, as they are outdated and provide no real
value.

### 2. JSDoc/TSDoc for Functions, Hooks, and Components

All exported functions, hooks, and React components must have a TSDoc block.

- **`@description`**: A clear, one-sentence summary of the function's purpose.
- **`@param`**: A description for every parameter that adds meaningful context beyond what the parameter name conveys.
- **`@returns`**: A description of the return value.

**Interfaces and Types**: Only add a TSDoc block at the interface/type declaration level. Do not add comments for individual properties within interfaces or types.

**Example Function:**

```typescript
/**
 * @description Calculates the total price of items in a cart.
 *
 * @param {Array<CartItem>} items - The array of items in the cart.
 * @param {number} taxRate - The applicable tax rate as a decimal (e.g., 0.05 for 5%).
 * @returns {number} The final price including tax.
 */
export const calculateTotalPrice = (items, taxRate) => {
  // function implementation...
};
```

**Example React Component:**

```typescript
/**
 * @description Renders a user's avatar with an optional status indicator.
 * @param {AvatarProps} props - The props for the component.
 * @param {string} props.imageUrl - The URL for the user's avatar image.
 * @param {'online' | 'offline'} [props.status] - The user's current status.
 * @returns {JSX.Element}
 */
export const UserAvatar = ({ imageUrl, status }) => {
  // component implementation...
};
```

### 3. Inline Comments

**Do not add inline comments unless they are already present in the code.**

Exceptions where inline comments should be added:
- To denote major components in a block of JSX/TSX.

If inline comments already exist in the code, you may refine them using the following tags:
- **`TODO:`** - For marking work that needs to be completed.
- **`NOTE:`** - For important clarifications or explanations.

When refining existing comments, ensure they explain _why_ a specific, non-obvious implementation choice was made, not _what_ the code is doing.

## 🧠 Discovery & Documentation Workflow

When tasked with documenting a file, feature, or component, follow this process:

1.  **Locate**: Find and read the specified file path (`$ARG1`). If the file doesn't exist at the exact path, search for it in the codebase.
2.  **Analyze**: Read and understand the target code. If a specific function/component name (`$ARG2`) is provided, focus on that element. Otherwise, identify all exported functions, hooks, and components that need documentation.
3.  **Document**: Generate the documentation according to the standards defined above. **IMPORTANT: Use the Edit tool to write the TSDoc blocks directly to the code file.** Do NOT output the documentation to stdout - it must be written to the actual file. Only include remarks if:
   - There is an implementation difference between iOS and Android, or
   - An existing comment has been left describing a remark.
4.  **Confirm**: Inform the user that the documentation has been written to the file.

## ❌ Constraints

The AI's role is strictly limited to discovery and documentation.

- **DO NOT** modify, refactor, or implement any application logic.
- **DO NOT** add new features or dependencies.
- **DO NOT** perform `git` commands or run build processes.

Your sole function is to read code and write documentation.

---
