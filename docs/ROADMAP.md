# Neovim Configuration Roadmap

## Current State

**Performance:** 48ms startup time  
**Focus:** C/C++ and embedded systems development  
**Plugins:** 24 core plugins  
**Status:** Production-ready for current use case

---

## Multi-Language Support Analysis

### Current Language Support

**Fully Supported:**
- C/C++ (clangd LSP, debugging with DAP)
- Lua (built-in, used for config)
- Markdown (live preview with glow)

**Partial Support:**
- Any language with an LSP server can work
- Treesitter provides syntax highlighting for 50+ languages

**Missing:**
- Python (no LSP configured, no debugging)
- Rust (no rust-analyzer, no cargo integration)
- Go (no gopls, no Go-specific tools)
- JavaScript/TypeScript (no specific configuration)

---

## How to Add Language Support

### 1. Python Support

**What's Needed:**
- LSP: pyright or pylsp
- Formatter: black or ruff
- Linter: ruff or pylint
- Debugger: debugpy for nvim-dap
- Virtual environment detection

**Changes Required:**
```lua
-- In lua/plugins/lsp.lua, add:
require("lspconfig").pyright.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Or use pylsp:
require("lspconfig").pylsp.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = { enabled = false },
        mccabe = { enabled = false },
        pyflakes = { enabled = false },
        pylint = { enabled = false },
      }
    }
  }
})
```

**Installation:**
```bash
# Install LSP
npm install -g pyright
# Or
pip install python-lsp-server

# Install formatter
pip install black

# Install debugger
pip install debugpy
```

**DAP Configuration:**
```lua
-- In lua/plugins/debug.lua, add:
dap.adapters.python = {
  type = 'executable',
  command = 'python',
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      return '/usr/bin/python3'
    end,
  },
}
```

---

### 2. Rust Support

**What's Needed:**
- LSP: rust-analyzer
- Formatter: rustfmt (comes with Rust)
- Debugger: lldb or codelldb
- Cargo integration (build, test, run)

**Changes Required:**
```lua
-- In lua/plugins/lsp.lua, add:
require("lspconfig").rust_analyzer.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ['rust-analyzer'] = {
      checkOnSave = {
        command = "clippy"
      },
    },
  },
})
```

**Installation:**
```bash
# rust-analyzer comes with rustup
rustup component add rust-analyzer

# Or install separately
brew install rust-analyzer  # macOS
sudo pacman -S rust-analyzer  # Arch Linux
```

**Optional Plugin:**
- rustaceanvim (better Rust integration, replaces basic LSP setup)

---

### 3. Go Support

**What's Needed:**
- LSP: gopls
- Formatter: gofmt or goimports
- Linter: golangci-lint
- Debugger: delve

**Changes Required:**
```lua
-- In lua/plugins/lsp.lua, add:
require("lspconfig").gopls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
})
```

**Installation:**
```bash
# Install gopls
go install golang.org/x/tools/gopls@latest

# Install delve (debugger)
go install github.com/go-delve/delve/cmd/dlv@latest
```

**DAP Configuration:**
```lua
-- In lua/plugins/debug.lua, add:
dap.adapters.go = {
  type = 'executable',
  command = 'dlv',
  args = {'dap', '-l', '127.0.0.1:38697'}
}

dap.configurations.go = {
  {
    type = 'go',
    name = 'Debug',
    request = 'launch',
    program = '${file}'
  },
}
```

---

### 4. JavaScript/TypeScript Support

**What's Needed:**
- LSP: typescript-language-server or tsserver
- Formatter: prettier or eslint
- Linter: eslint
- Debugger: node-debug2 or chrome-debug

**Changes Required:**
```lua
-- In lua/plugins/lsp.lua, add:
require("lspconfig").ts_ls.setup({
  capabilities = capabilities,
  on_attach = on_attach,
})
```

**Installation:**
```bash
npm install -g typescript typescript-language-server
npm install -g prettier eslint
```

---

## Server/Remote Development Suitability

### Current Strengths for Server Use

**Good:**
- Lightweight (48ms startup)
- No GUI dependencies
- Terminal-based UI
- Low memory footprint
- Works over SSH perfectly

**Issues:**
- Noice.ui might have rendering issues on slow connections
- Live-preview (glow) needs terminal with image support
- Floaterminal requires proper terminal emulator

### Optimizations for Server Use

**1. Create Server-Specific Profile**
```lua
-- In init.lua, detect if running over SSH:
local is_ssh = os.getenv("SSH_CONNECTION") ~= nil

if is_ssh then
  -- Disable heavy UI plugins
  vim.g.disable_noice = true
  vim.g.disable_alpha = true
end
```

**2. Disable Visual Plugins**
- Noice.nvim (use regular cmdline)
- Alpha.nvim (dashboard not needed on server)
- Glow (markdown preview requires terminal support)

**3. Keep Essential Plugins**
- LSP (code intelligence)
- Telescope (file navigation)
- Treesitter (syntax)
- Gitsigns (git integration)
- Oil.nvim (file management)

**4. Add Server-Friendly Tools**
- vim-tmux-navigator (if using tmux)
- Better terminal integration
- Quick file editing (no dashboard delay)

---

## Important Improvements Needed

### 1. Multi-Language LSP Management

**Current Problem:**
- LSP servers manually configured in lsp.lua
- No automatic installation
- Hard to manage multiple languages

**Solution: Add mason.nvim**
```lua
{
  "williamboman/mason.nvim",
  cmd = "Mason",
  build = ":MasonUpdate",
  config = function()
    require("mason").setup()
  end,
}

{
  "williamboman/mason-lspconfig.nvim",
  dependencies = { "mason.nvim", "nvim-lspconfig" },
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls", "clangd", "pyright", 
        "rust_analyzer", "gopls", "ts_ls"
      },
      automatic_installation = true,
    })
  end,
}
```

**Benefits:**
- One-command LSP installation: `:Mason`
- Automatic updates
- Easy to add new languages
- No manual PATH management

**Why:** Currently adding Python/Rust/Go requires manual system-level installations. Mason makes it seamless.

---

### 2. Better Treesitter Configuration

**Current Problem:**
- Basic treesitter setup
- No incremental selection
- No textobjects
- Limited to syntax highlighting

**Solution: Add treesitter-textobjects**
```lua
-- In lua/plugins/treesitter.lua, add:
{
  "nvim-treesitter/nvim-treesitter-textobjects",
  dependencies = "nvim-treesitter",
  config = function()
    require("nvim-treesitter.configs").setup({
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
          },
        },
        move = {
          enable = true,
          goto_next_start = {
            ["]f"] = "@function.outer",
            ["]c"] = "@class.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
            ["[c"] = "@class.outer",
          },
        },
      },
    })
  end,
}
```

**Benefits:**
- Select functions with `vaf`
- Jump between functions with `]f` and `[f`
- Smart code navigation
- Language-agnostic text objects

**Why:** Improves code navigation significantly. Currently you can't easily select or jump to functions.

---

### 3. Project-Specific Configuration

**Current Problem:**
- Same config for all projects
- No per-project LSP settings
- No per-project formatting rules

**Solution: Add .nvim.lua support**
```lua
-- In lua/core/options.lua, add:
vim.opt.exrc = true  -- Enable project-specific vimrc
vim.opt.secure = true  -- Prevent unsafe commands

-- Create autocommand to load .nvim.lua
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local project_config = vim.fn.getcwd() .. "/.nvim.lua"
    if vim.fn.filereadable(project_config) == 1 then
      vim.cmd("source " .. project_config)
    end
  end,
})
```

**Example .nvim.lua:**
```lua
-- Project-specific settings
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Project-specific LSP
require("lspconfig").pyright.setup({
  settings = {
    python = {
      pythonPath = ".venv/bin/python"
    }
  }
})
```

**Why:** Different projects have different requirements. Python projects might need virtual env detection, Go projects need different formatting.

---

### 4. Better Debugging Experience

**Current Problem:**
- DAP configured for C/C++ only
- No visual debugger UI
- Hard to set breakpoints
- No variable inspection

**Solution: Add nvim-dap-ui**
```lua
{
  "rcarriga/nvim-dap-ui",
  dependencies = { "nvim-dap", "nvim-nio" },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    
    dapui.setup({
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          size = 40,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          size = 10,
          position = "bottom",
        },
      },
    })

    -- Auto-open UI when debugging starts
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
  end,
}
```

**Why:** Current debugging is bare-bones. DAP-UI provides a visual debugger similar to VS Code.

---

### 5. Snippet Support

**Current Problem:**
- nvim-cmp configured but no snippet engine
- LSP snippets don't work
- No custom snippets

**Solution: Add LuaSnip**
```lua
{
  "L3MON4D3/LuaSnip",
  event = "InsertEnter",
  dependencies = {
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
  },
  config = function()
    local ls = require("luasnip")
    ls.config.set_config({
      history = true,
      updateevents = "TextChanged,TextChangedI",
    })
    
    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}

-- Update nvim-cmp configuration to include:
sources = {
  { name = "luasnip" },  -- Add this
  { name = "nvim_lsp" },
  { name = "buffer" },
  { name = "path" },
}
```

**Why:** Many LSP completions are snippets (function templates, etc). Without a snippet engine, they don't work.

---

### 6. Better Git Integration

**Current Strengths:**
- Gitsigns for line-level changes
- Telescope git commands

**Missing:**
- Git blame
- Diff view
- Merge conflict resolution
- Git history browsing

**Solution: Add diffview.nvim and git-blame.nvim**
```lua
{
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git Diff" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "File History" },
  },
}

{
  "f-person/git-blame.nvim",
  event = "BufReadPre",
  config = function()
    vim.g.gitblame_enabled = 0  -- Disabled by default
    vim.g.gitblame_message_template = "<author> • <date> • <summary>"
  end,
  keys = {
    { "<leader>gb", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
  },
}
```

**Why:** Git blame and visual diff viewing are essential for team development.

---

### 7. Session Management

**Current Problem:**
- No session persistence
- Reopening project loses state
- Have to manually reopen files

**Solution: Add persistence.nvim or auto-session**
```lua
{
  "folke/persistence.nvim",
  event = "BufReadPre",
  opts = {},
  keys = {
    { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
    { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
    { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Session" },
  },
}
```

**Why:** Saves open files, window layout, and state. Useful when working on multiple projects.

---

### 8. Testing Integration

**Current Problem:**
- No test runner integration
- Have to switch to terminal to run tests
- Can't see test results inline

**Solution: Add neotest**
```lua
{
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    -- Language-specific adapters:
    "nvim-neotest/neotest-python",
    "rouge8/neotest-rust",
    "nvim-neotest/neotest-go",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-python"),
        require("neotest-rust"),
        require("neotest-go"),
      },
    })
  end,
  keys = {
    { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Nearest Test" },
    { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File Tests" },
    { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test Summary" },
  },
}
```

**Why:** Run tests directly from Neovim, see results inline, debug failing tests.

---

### 9. Better Search and Replace

**Current Strengths:**
- Telescope for file finding
- Basic Vim search

**Missing:**
- Project-wide search and replace
- Visual preview of replacements
- Regex support with preview

**Solution: Add spectre.nvim**
```lua
{
  "nvim-pack/nvim-spectre",
  cmd = "Spectre",
  keys = {
    { "<leader>sr", function() require("spectre").open() end, desc = "Search & Replace" },
    { "<leader>sw", function() require("spectre").open_visual({ select_word = true }) end, desc = "Search Current Word" },
    { "<leader>sf", function() require("spectre").open_file_search() end, desc = "Search in Current File" },
  },
}
```

**Why:** Refactoring across multiple files. Better than Vim's `:s///` for large projects.

---

### 10. Code Documentation

**Current Problem:**
- No inline documentation generation
- No hover documentation enhancement

**Solution: Add neogen for documentation generation**
```lua
{
  "danymat/neogen",
  dependencies = "nvim-treesitter",
  cmd = "Neogen",
  keys = {
    { "<leader>cg", function() require("neogen").generate() end, desc = "Generate Docs" },
  },
  config = function()
    require("neogen").setup({
      enabled = true,
      languages = {
        python = { template = { annotation_convention = "google_docstrings" } },
        rust = { template = { annotation_convention = "rustdoc" } },
        go = { template = { annotation_convention = "godoc" } },
      },
    })
  end,
}
```

**Why:** Generate function documentation templates automatically.

---

## Priority Roadmap

### Phase 1: Essential Improvements (High Priority)

1. **Add mason.nvim** - Simplifies LSP management for all languages
2. **Add LuaSnip** - Fix snippet support (many completions broken without it)
3. **Add nvim-dap-ui** - Better debugging experience
4. **Add Python support** - Expand beyond C/C++

**Impact:** Makes config usable for multiple languages, fixes broken features.  
**Time:** 1-2 hours  
**Difficulty:** Easy

---

### Phase 2: Multi-Language Support (Medium Priority)

5. **Add Rust support** (rust-analyzer, DAP)
6. **Add Go support** (gopls, delve)
7. **Add JavaScript/TypeScript support** (tsserver)
8. **Add treesitter-textobjects** - Better code navigation

**Impact:** Config becomes truly multi-language.  
**Time:** 2-3 hours  
**Difficulty:** Medium

---

### Phase 3: Workflow Enhancements (Medium Priority)

9. **Add diffview.nvim** - Better git workflow
10. **Add persistence.nvim** - Session management
11. **Add spectre.nvim** - Project-wide search/replace
12. **Add project-specific config support** - Per-project settings

**Impact:** Improves daily workflow, especially for large projects.  
**Time:** 1-2 hours  
**Difficulty:** Easy

---

### Phase 4: Advanced Features (Low Priority)

13. **Add neotest** - Test runner integration
14. **Add neogen** - Documentation generation
15. **Add git-blame.nvim** - Git blame inline
16. **Create server profile** - Optimized for SSH use

**Impact:** Nice-to-have features for specific workflows.  
**Time:** 2-3 hours  
**Difficulty:** Medium

---

## Implementation Strategy

### For Immediate Use (Pick One)

**Option A: Add One Language at a Time**
1. Start with Python (most common)
2. Test thoroughly
3. Document the process
4. Repeat for Rust, Go, etc.

**Option B: Add Mason First**
1. Add mason.nvim and mason-lspconfig
2. Install all LSP servers through Mason
3. Configure each language afterwards

**Recommended: Option B** - Mason makes everything else easier.

---

### For Server Use

**Create Server-Specific Branch:**
```bash
git checkout -b config/server-optimized
```

**Disable in init.lua:**
```lua
-- Detect SSH
if os.getenv("SSH_CONNECTION") then
  -- Disable heavy plugins
  disabled_plugins = {
    "alpha.nvim",
    "noice.nvim", 
    "glow.nvim",
  }
end
```

**Keep Minimal Set:**
- nvim-lspconfig
- nvim-cmp
- telescope.nvim
- treesitter
- oil.nvim
- gitsigns.nvim

---

## Testing Changes

**After Each Addition:**
1. Check startup time: `nvim --startuptime startup.log`
2. Verify lazy-loading: `:Lazy profile`
3. Test in real project
4. Document keymaps in README

**Performance Targets:**
- Startup: < 60ms (currently 48ms)
- First edit: < 100ms
- LSP response: < 200ms

---

## Migration Path

### From Current Config to Multi-Language

**Step 1: Add Mason (30 mins)**
```bash
# Add plugins
# Configure mason.nvim
# Install LSPs through :Mason
```

**Step 2: Add Python Support (30 mins)**
```bash
# Install pyright through Mason
# Configure DAP for Python
# Test in Python project
```

**Step 3: Test & Document (15 mins)**
```bash
# Verify everything works
# Update README with Python setup
# Commit changes
```

**Repeat for other languages.**

---

## Known Issues to Fix

### 1. Trouble.nvim Issue (Fixed)
- Was requiring multiple presses
- Fixed with event="VeryLazy" and auto_refresh

### 2. Telescope Git Files (Fixed)
- Wasn't showing git files
- Fixed with smart git_files/find_files fallback

### 3. No Snippet Engine (Unfixed)
- LSP snippet completions don't work
- Need to add LuaSnip

### 4. No Multi-Language LSP Manager (Unfixed)
- Manual installation required
- Need to add Mason

---

## Conclusion

**Current Config:**
- Excellent for C/C++ development
- Fast and minimal
- Well-structured and documented

**To Make Multi-Language:**
- Add Mason for LSP management
- Add language-specific LSPs (Python, Rust, Go)
- Add LuaSnip for snippets
- Add DAP configurations per language

**For Server Use:**
- Already good over SSH
- Disable Noice/Alpha for faster startup
- Keep core features (LSP, Telescope, Oil)

**Priority:**
1. Mason.nvim (makes everything else easier)
2. LuaSnip (fixes broken completions)
3. Python support (most requested)
4. Rust/Go support (common in systems programming)

**Estimated Time for Full Multi-Language Support:**
- Phase 1 (Essential): 1-2 hours
- Phase 2 (Multi-language): 2-3 hours
- Phase 3 (Enhancements): 1-2 hours
- Total: 4-7 hours of focused work

**Next Steps:**
1. Review this roadmap
2. Choose priority features
3. Implement phase by phase
4. Test thoroughly
5. Document as you go
