# 🤝 Contributing to Sphurti

Thank you for considering contributing to Sphurti! This document provides guidelines and best practices for contributing.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Plugin Guidelines](#plugin-guidelines)
- [Testing](#testing)
- [Documentation](#documentation)

---

## 📜 Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior

- ✅ Be respectful and considerate
- ✅ Use welcoming and inclusive language
- ✅ Accept constructive criticism gracefully
- ✅ Focus on what is best for the community
- ✅ Show empathy towards other community members

### Unacceptable Behavior

- ❌ Harassment, trolling, or derogatory comments
- ❌ Personal or political attacks
- ❌ Public or private harassment
- ❌ Publishing others' private information
- ❌ Other conduct which could reasonably be considered inappropriate

---

## 🎯 How Can I Contribute?

### Reporting Bugs

**Before submitting a bug report:**

1. Check the [existing issues](https://github.com/Dyumna137/Sphurti/issues)
2. Try the latest version
3. Run `:checkhealth` in Neovim

**Bug Report Template:**

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Open nvim
2. Run command '...'
3. See error

**Expected behavior**
What you expected to happen.

**Environment:**
- OS: [e.g., Ubuntu 22.04]
- Neovim version: [e.g., 0.9.5]
- Terminal: [e.g., kitty]

**Additional context**
Any other relevant information.
```

### Suggesting Enhancements

**Before suggesting an enhancement:**

1. Check if it already exists
2. Consider if it aligns with the project's focus (C/C++/embedded development)
3. Ensure it doesn't add unnecessary bloat

**Enhancement Request Template:**

```markdown
**Is your feature request related to a problem?**
A clear description of the problem.

**Describe the solution you'd like**
What you want to happen.

**Describe alternatives you've considered**
Any alternative solutions or features.

**Additional context**
Any other context or screenshots.
```

### Your First Code Contribution

**Good first issues:**
- Documentation improvements
- Fixing typos
- Adding comments
- Improving error messages
- Small bug fixes

**Look for issues labeled:**
- `good-first-issue`
- `help-wanted`
- `documentation`

---

## 🛠 Development Setup

### Prerequisites

```bash
# Neovim >= 0.9.0
nvim --version

# Git >= 2.19.0
git --version

# Node.js (for LSP servers)
node --version

# ripgrep (recommended)
rg --version
```

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone git@github.com:YOUR_USERNAME/Sphurti.git
cd Sphurti

# Add upstream remote
git remote add upstream git@github.com:Dyumna137/Sphurti.git
```

### Create Development Branch

```bash
# Update main
git checkout main
git pull upstream main

# Create feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b bugfix/fix-description
```

### Branch Naming Convention

```
<type>/<description>

Types:
- feature/    : New features
- bugfix/     : Bug fixes
- refactor/   : Code refactoring
- docs/       : Documentation only
- perf/       : Performance improvements
- test/       : Adding tests
- chore/      : Maintenance tasks

Examples:
✓ feature/add-rust-support
✓ bugfix/fix-lsp-crash
✓ refactor/optimize-startup
✓ docs/improve-readme
✓ perf/lazy-load-plugins
✗ my-branch (too vague)
✗ test (no description)
```

### Test Your Changes

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup

# Link your development config
ln -s $(pwd) ~/.config/nvim

# Test in Neovim
nvim

# Run health checks
nvim +checkhealth

# Test startup time
nvim --startuptime startup.log +qa
tail -1 startup.log
```

---

## 📤 Pull Request Process

### Before Submitting

**Checklist:**

```
□ Code follows project style guidelines
□ Comments added for complex logic
□ Documentation updated (if needed)
□ Tested locally (works without errors)
□ Commit messages follow convention
□ No merge conflicts with main
□ Performance impact considered
```

### Creating Pull Request

1. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open PR on GitHub:**
   - Go to: https://github.com/Dyumna137/Sphurti/pulls
   - Click "New Pull Request"
   - Select your branch
   - Fill in the template

3. **PR Title Format:**
   ```
   type(scope): brief description
   
   Examples:
   ✓ feat(lsp): add rust language server support
   ✓ fix(keymaps): resolve leader key conflict
   ✓ refactor(plugins): optimize lazy loading
   ✓ docs(readme): improve installation guide
   ✗ Fixed bug (too vague)
   ✗ Update (no context)
   ```

### PR Description Template

```markdown
## Description
Brief summary of changes.

## Type of Change
- [ ] Bug fix (non-breaking change fixing an issue)
- [ ] New feature (non-breaking change adding functionality)
- [ ] Breaking change (fix or feature causing existing functionality to change)
- [ ] Documentation update

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
How was this tested?
- [ ] Tested locally
- [ ] Ran :checkhealth
- [ ] Tested startup time
- [ ] No errors in console

## Screenshots (if applicable)
Add screenshots showing before/after.

## Related Issues
Closes #123
Related to #456

## Additional Notes
Any other context or considerations.
```

### Review Process

1. **Automated Checks:**
   - CI/CD will run (if configured)
   - Reviewers will be notified

2. **Review Feedback:**
   - Address comments promptly
   - Explain your approach if needed
   - Be open to suggestions

3. **Making Changes:**
   ```bash
   # Make requested changes
   git add .
   git commit -m "fix: address review comments"
   git push origin feature/your-feature-name
   ```

4. **Approval:**
   - Once approved, maintainers will merge
   - Your contribution will be credited

---

## 💻 Coding Standards

### Lua Style Guide

**Formatting:**

```lua
-- Use 2 spaces for indentation
local function example()
  local x = 1
  if x == 1 then
    print("hello")
  end
end

-- No trailing whitespace
-- End files with newline
```

**Naming Conventions:**

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

-- Tables (modules): snake_case
local my_module = {}
function my_module.do_something()
  -- ...
end
```

**Comments:**

```lua
-- Single line comments for brief explanations
local x = 1  -- Inline comments when needed

--[[
  Multi-line comments for:
  - Complex logic explanation
  - Function documentation
  - Module descriptions
]]

--- LSP-style documentation
--- @param name string User name
--- @return boolean Success status
local function validate_user(name)
  return #name > 0
end
```

**Error Handling:**

```lua
-- Use pcall for operations that might fail
local success, result = pcall(require, "optional_module")
if not success then
  vim.notify("Module not found", vim.log.levels.WARN)
  return
end

-- Guard clauses for early returns
local function process_data(data)
  if not data then
    return nil
  end
  
  if type(data) ~= "table" then
    return nil
  end
  
  -- Main logic here
end
```

### Plugin Configuration Standards

**File Structure:**

```lua
-- lua/plugins/example.lua
return {
  "author/plugin-name",
  
  -- Lazy loading (choose one)
  lazy = false,              -- Load at startup (avoid if possible)
  event = "VeryLazy",        -- Load after startup
  cmd = "CommandName",       -- Load on command
  keys = "<leader>key",      -- Load on keymap
  ft = "filetype",           -- Load for filetype
  
  -- Dependencies
  dependencies = {
    "other/plugin",
  },
  
  -- Options (prefer this over config when possible)
  opts = {
    setting1 = true,
    setting2 = "value",
  },
  
  -- Configuration function (when opts isn't enough)
  config = function()
    local plugin = require("plugin-name")
    plugin.setup({
      -- Settings here
    })
  end,
}
```

**Performance Considerations:**

```lua
-- ✅ GOOD: Lazy load
return {
  "expensive/plugin",
  event = "VeryLazy",
  config = function()
    require("plugin").setup()
  end,
}

-- ❌ BAD: Load at startup
return {
  "expensive/plugin",
  lazy = false,
  config = function()
    require("plugin").setup()
  end,
}

-- ✅ GOOD: Load only when needed
return {
  "author/telescope.nvim",
  cmd = "Telescope",
  keys = {
    { "<leader>ff", "<cmd>Telescope find_files<cr>" },
  },
}
```

### Keymap Standards

**Always use these options:**

```lua
vim.keymap.set('n', '<leader>key', function()
  -- Action here
end, {
  noremap = true,   -- Prevent recursive mapping (ALWAYS use)
  silent = true,    -- Don't show command in command line
  desc = "Human-readable description",  -- For which-key
})
```

**Naming Convention:**

```lua
-- Leader key namespaces
<leader>f  -- Find (telescope)
<leader>g  -- Git
<leader>d  -- Diagnostics
<leader>l  -- LSP
<leader>t  -- Toggle/Terminal
<leader>b  -- Buffer
<leader>w  -- Window
<leader>q  -- Quickfix
<leader>m  -- Make/Build
```

---

## 📝 Commit Message Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

```
feat     : New feature
fix      : Bug fix
docs     : Documentation only
style    : Formatting (no code change)
refactor : Code restructuring (no feature change)
perf     : Performance improvement
test     : Adding tests
chore    : Maintenance (build, deps)
revert   : Revert previous commit
```

### Scope

```
lsp       : LSP configuration
plugins   : Plugin changes
keymaps   : Keymap changes
options   : Editor options
ui        : UI components
docs      : Documentation
```

### Examples

**Good commit messages:**

```
✓ feat(lsp): add rust-analyzer support

Added rust-analyzer LSP server configuration with custom settings
for embedded development. Includes cargo check integration.

Closes #42

✓ fix(keymaps): resolve <leader>tw conflict

Changed floaterminal keymap from <leader>tw to <leader>tc to avoid
conflict with wrap toggle.

✓ refactor(plugins): optimize lazy loading

Converted 5 plugins from eager to lazy loading:
- telescope.nvim: Load on keys
- trouble.nvim: Load on cmd
- gitsigns.nvim: Load on BufRead

Startup time improved from 53ms to 48ms (9% faster).

✓ docs(readme): add troubleshooting section

Added common issues and solutions:
- LSP not working
- Slow startup
- Plugin errors
```

**Bad commit messages:**

```
✗ fix bug (what bug? where?)
✗ update (what was updated?)
✗ changes (what changes?)
✗ wip (work in progress - don't commit this!)
```

### Commit Best Practices

```bash
# 1. Make atomic commits (one logical change per commit)
# Good:
git commit -m "feat(lsp): add clangd configuration"
git commit -m "docs(readme): document clangd setup"

# Bad:
git commit -m "add clangd and update docs and fix bug"

# 2. Use present tense
✓ "add feature"
✗ "added feature"

# 3. Limit subject line to 50 characters
✓ "feat(lsp): add rust support"
✗ "feat(lsp): add comprehensive rust language server support with custom configuration"

# 4. Wrap body at 72 characters
git commit -m "feat(lsp): add rust support" -m "Added rust-analyzer with custom settings for embedded development."

# 5. Reference issues
git commit -m "fix(lsp): resolve crash on startup

Fixes #123
Related to #456"
```

---

## 🔌 Plugin Guidelines

### Adding New Plugins

**Checklist:**

```
□ Plugin is actively maintained (check last commit date)
□ Plugin has good documentation
□ Plugin doesn't duplicate existing functionality
□ Plugin is necessary (can't achieve with built-in features)
□ Plugin is properly lazy-loaded
□ Plugin configuration is documented
□ Plugin doesn't significantly impact startup time
```

### Plugin Evaluation Criteria

**Consider:**

1. **Necessity:**
   - Can this be done with built-in Neovim features?
   - Does existing plugin provide this functionality?

2. **Performance:**
   - What's the startup time impact?
   - Is it properly lazy-loaded?
   - Does it run async operations?

3. **Maintenance:**
   - Is the plugin actively maintained?
   - Last commit within 6 months?
   - Good issue response time?

4. **Quality:**
   - Well documented?
   - Has tests?
   - Good code quality?

5. **Dependencies:**
   - How many dependencies?
   - Are dependencies maintained?
   - Reasonable dependency tree?

### Removing Plugins

**If plugin meets any criteria:**

- Not used in 2+ weeks
- Better alternative exists
- Can be replaced with built-in feature
- Adds significant startup time
- No longer maintained
- Security concerns

**Process:**

1. Comment out in `init.lua`
2. Test for 1 week
3. If not missed, remove completely
4. Document in commit message WHY removed

---

## 🧪 Testing

### Manual Testing

**Before submitting PR:**

```bash
# 1. Clean install test
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
# Test: autocompletion, go-to-definition, diagnostics

# 5. Plugin loading
:Lazy profile
# Check: Are plugins lazy-loaded correctly?

# 6. Error checking
# Open nvim, use features, check for errors
:messages
```

### Test Scenarios

**Core Functionality:**

```vim
" Navigation
<leader>ff  " Find files
<leader>fg  " Live grep
gd          " Go to definition

" LSP
K           " Hover docs
<leader>ca  " Code actions
<leader>rn  " Rename

" Editing
gcc         " Comment line
<C-space>   " Trigger completion

" Build
<leader>mm  " Make build
[q / ]q     " Navigate errors
```

### Performance Testing

```bash
# Startup time (should be < 50ms)
nvim --startuptime startup.log +qa && tail -1 startup.log

# Memory usage
ps aux | grep nvim

# CPU usage during operations
# Open large file, use LSP features, check CPU
```

---

## 📚 Documentation

### What to Document

**When adding features:**

- ✅ README.md (if user-facing)
- ✅ Code comments (for complex logic)
- ✅ Keymaps (in keymaps.lua)
- ✅ Plugin purpose (in plugin file)
- ✅ Configuration options (in plugin file)

### Documentation Standards

**README.md updates:**

```markdown
# Add to relevant sections:
- Prerequisites (if new dependency)
- Installation (if setup steps needed)
- Keymaps (if new keymaps)
- Plugins (if new plugin)
- Troubleshooting (if common issues)
```

**Code comments:**

```lua
-- Brief explanation for simple code
local x = 1  -- Inline when necessary

-- Detailed explanation for complex code
--[[
  This function handles LSP attachment with the following steps:
  1. Check if LSP client supports capability
  2. Set buffer-local keymaps
  3. Configure autocommands for formatting
  
  @param client LSP client object
  @param bufnr Buffer number
]]
local function on_attach(client, bufnr)
  -- Implementation
end
```

### Documentation Tools

```bash
# Generate documentation
# (if we add automated doc generation)

# Check broken links
# (if we add link checking)

# Spell check
aspell check README.md
```

---

## ⚡ Performance Guidelines

### Optimization Principles

1. **Lazy Load Everything Possible:**
   ```lua
   -- ✅ GOOD
   event = "VeryLazy"
   cmd = "Command"
   keys = "<leader>key"
   
   -- ❌ BAD
   lazy = false
   ```

2. **Minimize Startup Code:**
   ```lua
   -- ✅ GOOD: Defer non-critical setup
   vim.defer_fn(function()
     require("heavy_plugin").setup()
   end, 100)
   
   -- ❌ BAD: Run immediately
   require("heavy_plugin").setup()
   ```

3. **Use Async Operations:**
   ```lua
   -- ✅ GOOD: Async
   vim.schedule(function()
     -- Heavy operation
   end)
   
   -- ❌ BAD: Blocking
   -- Heavy operation
   ```

4. **Profile Before Optimizing:**
   ```vim
   :Lazy profile
   ```

### Performance Targets

```
Startup time:  < 50ms
Memory usage:  < 100MB (idle)
Plugin count:  < 30 plugins
```

---

## 🎓 Learning Resources

### Neovim

- [Neovim Documentation](https://neovim.io/doc/)
- [Learn Vimscript the Hard Way](https://learnvimscriptthehardway.stevelosh.com/)
- [Neovim Lua Guide](https://github.com/nanotee/nvim-lua-guide)

### Lua

- [Learn Lua in Y Minutes](https://learnxinyminutes.com/docs/lua/)
- [Programming in Lua](https://www.lua.org/pil/)

### Git

- [Pro Git Book](https://git-scm.com/book/en/v2)
- [GitHub Flow](https://guides.github.com/introduction/flow/)

---

## 🏆 Recognition

Contributors will be:
- Listed in README.md
- Credited in release notes
- Acknowledged in commits

---

## 💬 Communication

- **Issues**: For bugs and feature requests
- **Discussions**: For questions and ideas
- **Pull Requests**: For code contributions

---

## 📞 Getting Help

**Stuck? Need help?**

1. Check existing issues
2. Read documentation thoroughly
3. Run `:checkhealth`
4. Ask in GitHub Discussions
5. Open an issue with details

---

## ✅ Contribution Checklist

Before submitting PR:

```
□ Code follows style guide
□ Commits follow message convention
□ Documentation updated
□ Tested locally
□ No errors in :checkhealth
□ Startup time not regressed
□ Changes don't break existing features
□ PR description complete
□ Ready for review
```

---

**Thank you for contributing to Sphurti! 🎉**

<p align="center">
  Every contribution makes this config better for the embedded development community.
</p>
