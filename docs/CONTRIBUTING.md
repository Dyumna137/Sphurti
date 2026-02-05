# Contributing to Sphurti

Thank you for your interest in contributing to this Neovim configuration. This document outlines the guidelines and process for contributing.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Commit Guidelines](#commit-guidelines)
- [Pull Request Process](#pull-request-process)
- [Plugin Guidelines](#plugin-guidelines)
- [Testing](#testing)

---

## Code of Conduct

### Expected Behavior

- Be respectful and professional
- Provide constructive feedback
- Focus on improving the configuration
- Accept criticism gracefully
- Help others learn

### Unacceptable Behavior

- Harassment or discriminatory language
- Personal attacks
- Trolling or inflammatory comments
- Publishing private information
- Other unprofessional conduct

---

## How to Contribute

### Reporting Bugs

Before submitting a bug report:
1. Check existing issues
2. Try the latest version
3. Run `:checkhealth` in Neovim

**Bug Report Format:**
```
Title: Brief description of the issue

Environment:
- OS: [e.g., Ubuntu 22.04]
- Neovim version: [e.g., 0.9.5]
- Terminal: [e.g., kitty, alacritty]

Steps to Reproduce:
1. Open nvim
2. Run command X
3. See error

Expected Behavior:
What should happen

Actual Behavior:
What actually happens

Additional Context:
Any other relevant information
```

### Suggesting Features

Before suggesting a feature:
1. Check if it already exists
2. Ensure it aligns with C/C++/embedded development focus
3. Consider performance impact
4. Check if it can be done with existing plugins

**Feature Request Format:**
```
Title: Brief feature description

Problem:
What problem does this solve?

Proposed Solution:
How should it work?

Alternatives:
Other ways to solve this

Performance Impact:
Will this slow down startup or usage?

Why This Fits:
How does this help C/C++/embedded development?
```

---

## Development Setup

### Prerequisites

```bash
# Required
neovim >= 0.9.0
git >= 2.19.0

# Recommended
ripgrep
fd
nodejs (for LSP)
```

### Setup Development Environment

1. **Fork the repository on GitHub**

2. **Clone your fork:**
   ```bash
   git clone git@github.com:YOUR_USERNAME/Sphurti.git
   cd Sphurti
   ```

3. **Add upstream remote:**
   ```bash
   git remote add upstream git@github.com:Dyumna137/Sphurti.git
   ```

4. **Create feature branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

5. **Test your changes:**
   ```bash
   # Backup existing config
   mv ~/.config/nvim ~/.config/nvim.backup
   
   # Link development config
   ln -s $(pwd) ~/.config/nvim
   
   # Test
   nvim
   ```

### Branch Naming

Format: `<type>/<description>`

Types:
- `feature/` - New features
- `bugfix/` - Bug fixes
- `refactor/` - Code restructuring
- `docs/` - Documentation changes
- `perf/` - Performance improvements

Examples:
- `feature/add-rust-support`
- `bugfix/fix-telescope-crash`
- `refactor/simplify-lsp-config`
- `docs/improve-readme`

---

## Coding Standards

### Lua Style

**Indentation:**
- Use 2 spaces (no tabs)
- Consistent indentation throughout

**Naming:**
```lua
-- Variables: snake_case
local user_name = "John"
local is_valid = true

-- Functions: snake_case
local function calculate_sum(a, b)
  return a + b
end

-- Constants: UPPER_SNAKE_CASE
local MAX_RETRIES = 3
local DEFAULT_TIMEOUT = 5000

-- Tables/modules: snake_case
local my_module = {}
```

**Comments:**
```lua
-- Single line for brief explanations
local x = 1

-- Multi-line for complex logic
--[[
  This function does X by:
  1. First step
  2. Second step
  3. Final step
]]
local function complex_operation()
  -- implementation
end
```

**Error Handling:**
```lua
-- Use pcall for operations that might fail
local ok, result = pcall(require, "optional_module")
if not ok then
  vim.notify("Module not found", vim.log.levels.WARN)
  return
end

-- Guard clauses for early returns
local function process_data(data)
  if not data then return nil end
  if type(data) ~= "table" then return nil end
  
  -- Main logic here
end
```

### Plugin Configuration

**Standard structure:**
```lua
-- lua/plugins/example.lua
return {
  "author/plugin-name",
  
  -- Lazy loading
  event = "VeryLazy",  -- or cmd, keys, ft
  
  -- Dependencies
  dependencies = {
    "other/plugin",
  },
  
  -- Configuration
  opts = {
    setting1 = true,
    setting2 = "value",
  },
  
  -- Or use config function
  config = function()
    require("plugin").setup({
      -- settings
    })
  end,
}
```

**Lazy loading:**
- Prefer `event`, `cmd`, `keys`, or `ft` over `lazy = false`
- Use `VeryLazy` for non-critical plugins
- Use specific events when possible

**Examples:**
```lua
-- Good: Lazy load
{
  "author/plugin",
  event = "VeryLazy",
}

-- Bad: Load at startup
{
  "author/plugin",
  lazy = false,
}

-- Good: Load on command
{
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
}

-- Good: Load on keymap
{
  "folke/trouble.nvim",
  keys = {
    { "<leader>xx", "<cmd>Trouble<cr>" },
  },
}
```

### Keymap Standards

**Always include these options:**
```lua
vim.keymap.set('n', '<leader>key', function()
  -- Action
end, {
  noremap = true,  -- Prevent recursive mapping
  silent = true,   -- Don't show in command line
  desc = "Clear description for which-key",
})
```

**Keymap organization:**
```lua
-- Group related keymaps
-- Leader key namespaces:
-- <leader>f - Find (telescope)
-- <leader>g - Git
-- <leader>d - Diagnostics
-- <leader>l - LSP
-- <leader>t - Terminal/Toggle
-- <leader>b - Buffer
-- <leader>w - Window
-- <leader>m - Make/Build
```

---

## Commit Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation only
- `style` - Code style (formatting, no logic change)
- `refactor` - Code restructuring
- `perf` - Performance improvement
- `test` - Adding tests
- `chore` - Maintenance (deps, build)

### Scopes

- `lsp` - LSP configuration
- `plugins` - Plugin changes
- `keymaps` - Keymap changes
- `options` - Editor options
- `ui` - UI components
- `docs` - Documentation

### Examples

**Good commits:**
```
feat(lsp): add rust-analyzer support

Added rust-analyzer LSP with custom settings for embedded
development. Includes cargo check integration.

Closes #42

---

fix(keymaps): resolve leader key conflict

Changed terminal toggle from <leader>tw to <leader>tc to
avoid conflict with wrap toggle.

---

refactor(plugins): optimize lazy loading

Changed 5 plugins from eager to lazy loading:
- telescope: Load on keys
- trouble: Load on cmd
- gitsigns: Load on event

Startup improved from 53ms to 48ms.
```

**Bad commits:**
```
fix bug
update
changes
wip
```

### Commit Best Practices

1. **One logical change per commit**
2. **Use present tense** ("add" not "added")
3. **Limit subject to 50 characters**
4. **Wrap body at 72 characters**
5. **Reference issues** (`Fixes #123`, `Related to #456`)

---

## Pull Request Process

### Before Submitting

Checklist:
- [ ] Code follows style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated if needed
- [ ] Tested locally
- [ ] Commit messages follow convention
- [ ] No merge conflicts
- [ ] Performance impact considered

### Creating Pull Request

1. **Update your branch:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Push to your fork:**
   ```bash
   git push origin feature/your-feature
   ```

3. **Open PR on GitHub**

4. **PR Title Format:**
   ```
   type(scope): brief description
   
   Examples:
   feat(lsp): add rust language server
   fix(telescope): resolve search crash
   docs(readme): improve installation guide
   ```

### PR Description

```markdown
## Description
What does this PR do?

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation

## Changes Made
- Change 1
- Change 2

## Testing
- [ ] Tested locally
- [ ] Ran :checkhealth
- [ ] Checked startup time
- [ ] No console errors

## Related Issues
Fixes #123
Related to #456
```

### Review Process

1. Automated checks will run (if configured)
2. Maintainers will review
3. Address feedback promptly
4. Make requested changes
5. Once approved, maintainers merge

---

## Plugin Guidelines

### Adding Plugins

Checklist:
- [ ] Actively maintained (recent commits)
- [ ] Good documentation
- [ ] No duplicate functionality
- [ ] Actually necessary
- [ ] Properly lazy-loaded
- [ ] Configuration documented
- [ ] Minimal startup impact

### Evaluation Criteria

**Necessity:**
- Can this be done with built-in features?
- Does an existing plugin provide this?

**Performance:**
- What's the startup time impact?
- Is it properly lazy-loaded?
- Does it use async operations?

**Maintenance:**
- Last commit within 6 months?
- Active issue response?
- Regular updates?

**Quality:**
- Well documented?
- Has tests?
- Good code quality?

### Removing Plugins

Remove if:
- Not used in 2+ weeks
- Better alternative exists
- Can be replaced with built-in
- Adds significant startup time
- No longer maintained

Process:
1. Comment out in configuration
2. Test for 1 week
3. If not missed, remove completely
4. Document in commit why removed

---

## Testing

### Manual Testing

Before submitting PR:

```bash
# 1. Clean install
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
nvim

# 2. Health check
nvim +checkhealth

# 3. Startup time
nvim --startuptime startup.log +qa
tail -1 startup.log

# 4. LSP functionality
nvim test.c
# Test: completion, go-to-definition, diagnostics

# 5. Plugin loading
:Lazy profile
```

### Test Scenarios

**Core functionality:**
- File finding: `<leader>ff`
- Live grep: `<leader>fg`
- LSP: `gd`, `gr`, `K`, `<leader>ca`
- Diagnostics: `<leader>xx`
- Build: `<leader>mm`
- Terminal: `<leader>tt`

**Performance:**
```bash
# Should be under 50ms
nvim --startuptime startup.log +qa
tail -1 startup.log
```

---

## Performance Guidelines

### Optimization Principles

1. **Lazy load everything possible**
2. **Minimize startup code**
3. **Use async operations**
4. **Profile before optimizing**

**Examples:**
```lua
-- Good: Deferred loading
vim.defer_fn(function()
  require("heavy_plugin").setup()
end, 100)

-- Bad: Immediate loading
require("heavy_plugin").setup()
```

### Performance Targets

- Startup time: < 50ms
- Memory usage: < 100MB idle
- Plugin count: < 30 plugins

---

## Recognition

Contributors will be:
- Listed in README
- Credited in release notes
- Acknowledged in commits

---

## Getting Help

Need help?
1. Check existing issues
2. Read documentation
3. Run `:checkhealth`
4. Ask in GitHub Discussions

---

## Final Checklist

Before submitting:
- [ ] Follows style guide
- [ ] Commits follow convention
- [ ] Documentation updated
- [ ] Tested locally
- [ ] No errors in :checkhealth
- [ ] Startup time maintained
- [ ] Existing features work
- [ ] PR description complete

---

Thank you for contributing!
