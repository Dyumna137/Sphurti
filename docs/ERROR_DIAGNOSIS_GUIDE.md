# Error Diagnosis Guide - How I Debug Neovim Errors

This document explains step-by-step how to interpret Neovim errors and fix them.

---

## Table of Contents

1. [Error Reading Strategy](#error-reading-strategy)
2. [Common Error Patterns](#common-error-patterns)
3. [Diagnosis Workflow](#diagnosis-workflow)
4. [Today's Errors Fixed](#todays-errors-fixed)
5. [Tools & Commands](#tools--commands)

---

## Error Reading Strategy

### Step 1: Identify the Error Type

Read error messages from **bottom to top** (most recent first).

```
Error detected while processing...
Failed to run `config` for nvim-treesitter
/path/to/file.lua:21: module 'nvim-treesitter.configs' not found
```

**Key components:**
- `Failed to run 'config'` → Plugin configuration failed
- `nvim-treesitter` → Which plugin
- `file.lua:21` → Exact file and line number
- `module not found` → The actual problem

### Step 2: Extract the Root Cause

Ignore stack traces initially, focus on:
1. **What failed?** (plugin name)
2. **Where?** (file:line)
3. **Why?** (module not found, syntax error, etc.)

Example:
```
[mason.lua] nvim-lspconfig not available; aborting LSP setup
```

- **What:** LSP setup
- **Where:** mason.lua
- **Why:** lspconfig not available (loading order issue)

---

## Common Error Patterns

### Pattern 1: Module Not Found

```
module 'nvim-treesitter.configs' not found
```

**Diagnosis:**
1. Module name wrong? `.configs` vs `.config`
2. Plugin not installed?
3. Plugin corrupted?

**How to check:**
```bash
# Check if plugin exists
ls ~/.local/share/nvim/lazy/nvim-treesitter/

# Check what modules it provides
find ~/.local/share/nvim/lazy/nvim-treesitter/ -name "*.lua" | grep config
```

**Fix:**
- If wrong name: Change require statement
- If missing: Clear cache and reinstall
- If corrupted: `rm -rf ~/.local/share/nvim/lazy/nvim-treesitter`

### Pattern 2: Invalid Sign Text (E239)

```
Vim:E239: Invalid sign text: [E]
```

**Diagnosis:**
Neovim 0.9.5 only accepts **2 character** signs.

**How to check:**
```bash
# Find sign definitions
grep -n "sign_define\|Error.*=" ~/.config/nvim/lua/plugins/lsp.lua
```

**Fix:**
```lua
-- Before (3 chars - WRONG)
Error = "[E]",
Warn  = "[W]",

-- After (2 chars - CORRECT)
Error = "E ",
Warn  = "W ",
```

### Pattern 3: Plugin Not Available

```
[mason.lua] nvim-lspconfig not available; aborting LSP setup
```

**Diagnosis:**
Loading order issue - mason trying to use lspconfig before it loads.

**How to check:**
```bash
# Check dependency order
grep -A5 "dependencies" ~/.config/nvim/lua/plugins/lsp.lua
```

**Fix:**
Ensure lspconfig loads BEFORE mason:
```lua
-- lsp.lua
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",  -- Mason depends ON lspconfig
  }
}
```

### Pattern 4: Extraction Errors

```
nvim-treesitter[bash]: Error during tarball extraction.
tar: Cannot open: No such file or directory
```

**Diagnosis:**
1. Download interrupted
2. Too many parsers at once
3. Disk space/permissions

**How to check:**
```bash
# Check disk space
df -h ~

# Check treesitter parsers
ls ~/.local/share/nvim/lazy/nvim-treesitter/parser/
```

**Fix:**
Reduce `ensure_installed` to minimal parsers:
```lua
ensure_installed = { "c", "lua", "vim", "vimdoc" },
auto_install = true,  -- Install others on-demand
```

---

## Diagnosis Workflow

### Step-by-Step Process

```
1. READ ERROR MESSAGE
   ↓
2. IDENTIFY COMPONENT (plugin/file/line)
   ↓
3. CHECK FILE CONTENT
   ↓
4. VERIFY ASSUMPTIONS
   ↓
5. APPLY FIX
   ↓
6. TEST
   ↓
7. COMMIT IF WORKS
```

### Example: Treesitter Error

**Error seen:**
```
module 'nvim-treesitter.configs' not found
```

**Step 1: Read**
- Plugin: nvim-treesitter
- File: lua/plugins/treesitter.lua:21
- Issue: module not found

**Step 2: Identify**
```bash
grep -n "require.*nvim-treesitter" ~/.config/nvim/lua/plugins/treesitter.lua
```
Output: `require('nvim-treesitter.configs')`

**Step 3: Check**
Is it `.config` or `.configs`?
```bash
# Check plugin structure
find ~/.local/share/nvim/lazy/nvim-treesitter/lua -name "*config*"
```

**Step 4: Verify**
Try both names in plugin documentation or GitHub.

**Step 5: Fix**
```lua
-- If .configs is correct but plugin is corrupted:
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
```

**Step 6: Test**
```bash
nvim --headless +qall  # Test if it loads
nvim                    # Full test
```

**Step 7: Commit**
```bash
git add lua/plugins/treesitter.lua
git commit -m "fix(treesitter): correct module name to .configs"
git push
```

---

## Today's Errors Fixed

### Error 1: E239 Invalid Sign Text

**Error:**
```
Vim:E239: Invalid sign text: [E]
```

**File:** `lua/plugins/lsp.lua:66-69`

**Diagnosis:**
```bash
# Check current signs
grep "Error.*=" ~/.config/nvim/lua/plugins/lsp.lua
```

**Root cause:** 3-character signs `[E]` not allowed in Neovim 0.9.5

**Fix applied:**
```lua
# Line 66-70 in lua/plugins/lsp.lua
local diag_icons = {
  Error = "E ",  # Changed from "[E]" to "E "
  Warn  = "W ",  # Changed from "[W]" to "W "
  Hint  = "H ",  # Changed from "[H]" to "H "
  Info  = "I ",  # Changed from "[I]" to "I "
}
```

**Committed:** ✅ Commit 5548578

---

### Error 2: Treesitter Module Not Found

**Error:**
```
module 'nvim-treesitter.configs' not found
```

**File:** `lua/plugins/treesitter.lua:21`

**Diagnosis:**
```bash
# Check what's required
grep "require.*treesitter" lua/plugins/treesitter.lua

# Result: require('nvim-treesitter.configs')  ← Correct!
```

**Root cause:** Plugin files corrupted/incomplete, not code error

**Fix applied:**
1. Reduced `ensure_installed` from 15+ to 4 parsers
2. Enabled `auto_install = true`
3. Cleared cache: `rm -rf ~/.local/share/nvim/lazy/nvim-treesitter`

**Files changed:**
- `lua/plugins/treesitter.lua` (125 → 72 lines)

**Committed:** ✅ Commit 1e7b240

---

### Error 3: Mason LSP Loading Order

**Error:**
```
[mason.lua] nvim-lspconfig not available; aborting LSP setup
```

**File:** `lua/plugins/lsp/mason.lua:52`

**Diagnosis:**
```bash
# Check loading order
grep -A3 "dependencies" lua/plugins/lsp.lua

# Result: { import = "plugins.lsp.mason" }  ← WRONG ORDER
```

**Root cause:** mason.lua loads BEFORE lspconfig, but needs lspconfig

**Fix applied:**
1. Created new `lua/plugins/mason-setup.lua` (simplified)
2. Changed dependencies in `lua/plugins/lsp.lua`
3. Made mason depend ON lspconfig (not the other way)

**Before:**
```lua
-- lsp.lua
dependencies = {
  { import = "plugins.lsp.mason" },  ← Mason loads first (wrong!)
}
```

**After:**
```lua
-- lsp.lua
dependencies = {
  "williamboman/mason.nvim",  ← Just declare the plugin
}

-- mason-setup.lua
dependencies = {
  "neovim/nvim-lspconfig",  ← Mason depends on lspconfig
}
```

**Files changed:**
- `lua/plugins/lsp.lua` (updated dependencies)
- `lua/plugins/mason-setup.lua` (new, 70 lines)
- `lua/plugins/lsp/mason.lua` → `mason.lua.old` (backup)

**Committed:** ✅ Commit 8fe4687

---

### Error 4: Treesitter Extraction Errors

**Error:**
```
nvim-treesitter[bash]: Error during tarball extraction
```

**Diagnosis:**
```bash
# Check how many parsers installing
grep -A20 "ensure_installed" lua/plugins/treesitter.lua | wc -l

# Result: 15+ parsers (too many!)
```

**Root cause:** Installing 15+ parsers simultaneously overwhelms system

**Fix applied:**
Minimal install strategy:
```lua
ensure_installed = { "c", "lua", "vim", "vimdoc" },
auto_install = true,  -- Install others when files opened
```

**Committed:** ✅ Same as Error 2 (1e7b240)

---

## Tools & Commands

### Diagnostic Commands

```bash
# 1. Check Neovim version
nvim --version

# 2. Check plugin installation
ls ~/.local/share/nvim/lazy/

# 3. Check specific plugin
ls -la ~/.local/share/nvim/lazy/nvim-lspconfig/

# 4. Find error in config
grep -rn "error_text" ~/.config/nvim/

# 5. Check file syntax
luac -p ~/.config/nvim/lua/plugins/file.lua

# 6. Test config without UI
nvim --headless -c "quit"

# 7. Check lazy.nvim plugin list
nvim -c "Lazy" -c "q"

# 8. View startup time
nvim --startuptime startup.log
```

### Fix Commands

```bash
# Clear plugin cache
rm -rf ~/.local/share/nvim/lazy/
rm -rf ~/.cache/nvim/

# Reinstall specific plugin
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter/

# Check which files changed
git diff

# Check commit history
git log --oneline -10

# Push to GitHub
git push origin branch-name
```

### Testing Commands

```bash
# Test treesitter
nvim -c "TSInstallInfo" -c "q"

# Test LSP
nvim test.lua  # Open a file, check if LSP attaches

# Check diagnostics
nvim -c "lua vim.print(vim.diagnostic.config())"

# Check loaded plugins
nvim -c "Lazy" -c "q"
```

---

## Decision Tree for Errors

```
ERROR APPEARS
    │
    ├─ Module not found?
    │   ├─ Check: require() statement correct?
    │   │   ├─ Yes → Plugin corrupted, reinstall
    │   │   └─ No → Fix require() statement
    │   │
    │   └─ Check: Plugin installed?
    │       ├─ Yes → Check module name
    │       └─ No → Install plugin
    │
    ├─ Sign text error (E239)?
    │   └─ Make signs ≤ 2 chars
    │
    ├─ Plugin not available?
    │   └─ Check loading order (dependencies)
    │
    ├─ Extraction/download error?
    │   └─ Reduce ensure_installed, enable auto_install
    │
    └─ Syntax error?
        └─ Check Lua syntax: luac -p file.lua
```

---

## Quick Reference

### Where Files Are

```
~/.config/nvim/                  # Your config
├── init.lua                     # Entry point
├── lua/
│   ├── core/
│   │   ├── options.lua         # Neovim settings
│   │   └── keymaps.lua         # Key bindings
│   └── plugins/
│       ├── lsp.lua             # LSP global config
│       ├── mason-setup.lua     # LSP server installer
│       ├── treesitter.lua      # Syntax highlighting
│       ├── telescope.lua       # Fuzzy finder
│       └── lsp/
│           └── on_attach.lua   # LSP keymaps

~/.local/share/nvim/             # Plugin data
└── lazy/                        # Installed plugins
    ├── nvim-lspconfig/
    ├── nvim-treesitter/
    └── ...

~/.cache/nvim/                   # Compiled cache
```

### Git Workflow

```bash
# 1. Make changes
vim ~/.config/nvim/lua/plugins/file.lua

# 2. Test
nvim

# 3. Copy to source
cp ~/.config/nvim/lua/plugins/file.lua ~/path/to/Sphurti/lua/plugins/

# 4. Commit
cd ~/path/to/Sphurti
git add lua/plugins/file.lua
git commit -m "fix: description"

# 5. Push
git push origin branch-name
```

---

## Summary

**How I diagnose:**
1. Read error bottom-to-top
2. Identify: what/where/why
3. Check file content
4. Verify with commands
5. Apply targeted fix
6. Test thoroughly
7. Commit with clear message

**Key principle:** 
Make the **smallest possible change** that fixes the root cause.

**Today's fixes:**
- ✅ E239 signs: 3 chars → 2 chars
- ✅ Treesitter: 15 parsers → 4 (auto-install rest)
- ✅ Mason: Fixed loading order
- ✅ All changes pushed to GitHub

---

**Last updated:** 2026-02-05  
**Branch:** refactor/bloat-removal-optimization  
**Commits:** 5548578, 1e7b240, 8fe4687
