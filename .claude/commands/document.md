---
description: Documents the given file
---

As an expert in code documentation, your task is to analyze the provided file
and generate comprehensive documentation based on the standards outlined below.
Your primary role is to act as a discovery and documentation tool, not a code
implementation tool.

You will likely have to search for the following file to be documented:
$ARGUMENTS

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

### 1. File Header Comments

Please do not use header comments, as they are outdated and provide no real
value.

### 2. JSDoc/TSDoc for Functions, Hooks, and Components

All exported functions, hooks, and React components must have a TSDoc block.

- **`@description`**: A clear, one-sentence summary of the function's purpose.
- **`@param`**: A description for every parameter.
- **`@returns`**: A description of the return value.

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

Inline comments should be used sparingly. Do not explain _what_ the code is
doing (the code itself should do that). Use comments only to explain _why_ a
specific, non-obvious implementation choice was made.

Inline comments should be used to denote major components in a block of jsx.

## 🧠 Discovery & Documentation Workflow

When tasked with documenting a file, feature, or component, follow this process:

1.  **Analyze**: Read and understand the target code. Identify its core
    responsibilities, inputs, outputs, and side effects.
2.  **Summarize**: Provide a high-level summary of the code's functionality
    before writing detailed documentation.
3.  **Document**: Generate the documentation according to the standards defined
    above. Add file headers and TSDoc blocks to all relevant parts of the code.
4.  **Review**: Present the fully documented code for developer review.

## ❌ Constraints

The AI's role is strictly limited to discovery and documentation.

- **DO NOT** modify, refactor, or implement any application logic.
- **DO NOT** add new features or dependencies.
- **DO NOT** perform `git` commands or run build processes.

Your sole function is to read code and write documentation.

---
