-- lua/plugins/none-ls.lua
--[[
Module: plugins.none-ls

Purpose:
  Configure none-ls / null-ls as the central place to declare formatters and
  linters for Neovim. Keep this file minimal and let the LSP on_attach handle
  per-buffer keymaps and format-on-save toggles.

Notes:
  - Plugin repo: "nvimtools/none-ls.nvim"
  - Runtime module name: "null-ls" (upstream kept the old name)
  - This file returns a lazy.nvim plugin spec (repo string must be the first element).
--]]

local M = {}

--- Main config function for null-ls (defensive and documented).
--- @return nil
function M.config()
	local ok, null_ls = pcall(require, "null-ls")
	if not ok or not null_ls then
		vim.notify("none-ls / null-ls not available; skipping null-ls setup", vim.log.levels.WARN)
		return
	end

	local builtins = null_ls.builtins
	if not builtins then
		vim.notify("null-ls builtins missing; skipping setup", vim.log.levels.WARN)
		return
	end

	local formatting = builtins.formatting or {}
	local diagnostics = builtins.diagnostics or {}

	local function add_if_exists(tbl, val)
		if val then
			table.insert(tbl, val)
		end
	end

	local sources = {}

	-- Python
	if formatting.black then
		add_if_exists(sources, formatting.black.with({ extra_args = { "--fast" } }))
	end
	add_if_exists(sources, formatting.isort)
	add_if_exists(sources, diagnostics.flake8)

	-- Lua
	add_if_exists(sources, formatting.stylua)

	-- JS/TS
	add_if_exists(sources, formatting.prettier)

	-- C/C++
	add_if_exists(sources, formatting.clang_format)

	if vim.tbl_isempty(sources) then
		vim.notify("null-ls: no valid sources found; installation may be incomplete", vim.log.levels.WARN)
		return
	end

	null_ls.setup({
		sources = sources,
		-- If you later want per-project root detection you can add:
		-- root_dir = require("null-ls.utils").root_pattern(".git", "pyproject.toml"),
	})

	vim.notify("null-ls: configured with " .. tostring(#sources) .. " source(s)", vim.log.levels.INFO)
end

-- Return a lazy.nvim plugin spec table (repo string first element)
return {
	"nvimtools/none-ls.nvim",
	event = "BufReadPre",
	config = M.config,
}
