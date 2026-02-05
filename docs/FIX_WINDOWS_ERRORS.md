# Fix Windows Neovim Errors

## Your Error Messages:

```
Vim:E239: Invalid sign text: [I]
nvim-treesitter.config not found
```

## Root Cause:

Your **Windows config is outdated**. The fixes are already in GitHub, you just need to pull them.

---

## Quick Fix (On Windows):

### Step 1: Open PowerShell or Command Prompt

### Step 2: Navigate to your Neovim config
```powershell
cd C:\Users\RITABRATA\AppData\Local\nvim
```

### Step 3: Pull latest changes
```powershell
git pull origin refactor/bloat-removal-optimization
```

### Step 4: Restart Neovim
Close Neovim completely and reopen it.

---

## What Gets Fixed:

1. ✅ Sign text changed from `[E]` (3 chars) → `E ` (2 chars)
2. ✅ Treesitter module compatibility (tries both .configs and .config)
3. ✅ Modern vim.diagnostic.config() added
4. ✅ All E239 errors resolved

---

## If Git Pull Doesn't Work:

### Option 1: Force Pull
```powershell
cd C:\Users\RITABRATA\AppData\Local\nvim
git fetch origin
git reset --hard origin/refactor/bloat-removal-optimization
```

### Option 2: Fresh Clone
```powershell
# Backup current config
cd C:\Users\RITABRATA\AppData\Local
ren nvim nvim-backup

# Clone fresh
git clone -b refactor/bloat-removal-optimization https://github.com/Dyumna137/Sphurti.git nvim
```

---

## Verify Fixes:

After pulling and restarting Neovim:

1. **No E239 errors** - Signs should work
2. **No treesitter errors** - Syntax highlighting works
3. **LSP works** - `:LspInfo` shows active servers
4. **Completion works** - Type in insert mode

---

## For the yaml-language-server Warning:

This is a Mason download issue, not a config error.

**To fix:**
1. Open Neovim
2. Run: `:MasonInstall yaml-language-server`
3. Or just ignore it if you don't edit YAML files

---

## For the flake8 Warning:

If you don't use Python linting, ignore this warning.

**To remove warning:**
Edit `lua/plugins/none-ls.lua` or `lua/plugins/lint.lua` and remove flake8 references.

---

## Summary:

✅ **Main Issue**: Your Windows config is outdated  
✅ **Solution**: `git pull origin refactor/bloat-removal-optimization`  
✅ **Result**: All errors fixed

The GitHub repo already has all fixes from commits:
- 93e7721 - Neovim 0.9.5 compatibility
- Previous commits with sign fixes

Just pull and restart!

