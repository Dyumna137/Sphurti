--[[
═══════════════════════════════════════════════════════════════
  SPHURTI - Neovim Configuration
  Optimized for C/C++ and Embedded Development
═══════════════════════════════════════════════════════════════
--]]

-- ═══════════════════════════════════════════════════════════════
-- PERFORMANCE: Enable Lua module caching
-- ═══════════════════════════════════════════════════════════════
vim.loader.enable()

-- ═══════════════════════════════════════════════════════════════
-- PLATFORM: Windows-specific shell configuration
-- ═══════════════════════════════════════════════════════════════
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
	vim.opt.shell = "pwsh"
	vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
	vim.opt.shellquote = ""
	vim.opt.shellxquote = ""
end

-- ═══════════════════════════════════════════════════════════════
-- CORE: Load editor options and keymaps
-- ═══════════════════════════════════════════════════════════════
require("core.options")
require("core.keymaps")

-- ═══════════════════════════════════════════════════════════════
-- AUTOCOMMANDS: Automatic behaviors
-- ═══════════════════════════════════════════════════════════════

-- Visual feedback when copying text (try `yap` in normal mode)
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight yanked text briefly",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- ═══════════════════════════════════════════════════════════════
-- PLUGIN MANAGER: Install and configure lazy.nvim
-- ═══════════════════════════════════════════════════════════════
-- Auto-install lazy.nvim if not present
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end
vim.opt.rtp:prepend(lazypath)

-- ═══════════════════════════════════════════════════════════════
-- PLUGINS: Load all plugin configurations
-- Commands: :Lazy (status), :Lazy update (update all)
-- ═══════════════════════════════════════════════════════════════
require("lazy").setup({

	-- ─────────────────────────────────────────────────────────────
	-- CORE UTILITIES
	-- ─────────────────────────────────────────────────────────────
	{ "famiu/bufdelete.nvim", cmd = "Bdelete" },  -- Delete buffers safely
	require("plugins.telescope"),                  -- Fuzzy finder

	-- ─────────────────────────────────────────────────────────────
	-- UI & APPEARANCE
	-- ─────────────────────────────────────────────────────────────
	require("plugins.colortheme"),                 -- Color scheme
	require("plugins.lualine"),                    -- Status line

	-- ─────────────────────────────────────────────────────────────
	-- CODE INTELLIGENCE
	-- ─────────────────────────────────────────────────────────────
	require("plugins.treesitter"),                 -- Syntax highlighting
	require("plugins.lsp"),                        -- Language servers
	require("plugins.autocompletion"),             -- Code completion
	require("plugins.lsp_signature"),              -- Function signatures
	require("plugins.autopairs"),                  -- Auto-close brackets

	-- ─────────────────────────────────────────────────────────────
	-- CODE QUALITY
	-- ─────────────────────────────────────────────────────────────
	require("plugins.none-ls"),                    -- Formatting & linting

	-- ─────────────────────────────────────────────────────────────
	-- DEVELOPMENT TOOLS
	-- ─────────────────────────────────────────────────────────────
	require("plugins.debug"),                      -- Debugger (DAP)
	require("plugins.gitsigns"),                   -- Git integration
	
	-- ─────────────────────────────────────────────────────────────
	-- EXTRAS
	-- ─────────────────────────────────────────────────────────────
	require("plugins.misc"),                       -- Small utilities
}, {
	-- ═══════════════════════════════════════════════════════════════
	-- LAZY.NVIM OPTIONS
	-- ═══════════════════════════════════════════════════════════════
	
	defaults = {
		lazy = true,  -- Lazy-load by default for fast startup
	},
	
	-- Performance optimizations
	performance = {
		cache = { enabled = true },
		rtp = {
			-- Disable unused built-in plugins
			disabled_plugins = {
				"netrwPlugin",  -- File explorer (we use oil.nvim)
				"gzip",         -- Gzip support
				"zipPlugin",    -- Zip support  
				"tarPlugin",    -- Tar support
				"tohtml",       -- HTML export
				"tutor",        -- Built-in tutorial
				"matchit",      -- Extended % matching
				"matchparen",   -- Bracket highlighting
			},
		},
	},
	
	-- Auto-check for updates (silently)
	checker = {
		enabled = true,
		notify = false,
	},
	
	-- ═══════════════════════════════════════════════════════════════
	-- UI: Minimalist icons (simple & clear)
	-- ═══════════════════════════════════════════════════════════════
	ui = {
		icons = {
			cmd = "[cmd]",      -- Commands
			config = "[cfg]",   -- Configuration
			event = "[evt]",    -- Events
			ft = "[ft]",        -- Filetypes
			init = "[ini]",     -- Initialization
			keys = "[key]",     -- Keymaps
			plugin = "[plg]",   -- Plugins
			runtime = "[run]",  -- Runtime
			require = "[req]",  -- Requirements
			source = "[src]",   -- Source
			start = "[>>>]",    -- Started
			task = "[tsk]",     -- Tasks
			lazy = "[zzz]",     -- Lazy-loaded
			loaded = "[ok]",    -- Loaded
			not_loaded = "[ ]", -- Not loaded
		},
	},
})
