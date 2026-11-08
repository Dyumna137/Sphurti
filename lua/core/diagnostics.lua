local M = {}

function M.report()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	local root = vim.fs.root(0, { "compile_commands.json", "CMakeLists.txt", ".git" })
	local lines = {
		("Buffer: %s"):format(vim.api.nvim_buf_get_name(0)),
		("Project root: %s"):format(root or "not found"),
		("LSP clients: %d"):format(#clients),
		("Buffer diagnostics: %d"):format(#vim.diagnostic.get(0)),
	}

	if #clients == 0 then
		table.insert(lines, "Hint: open a C/C++/Lua file to trigger the matching language server.")
	else
		for _, client in ipairs(clients) do
			table.insert(lines, ("- %s (%s)"):format(client.name, client.root_dir or "no root"))
		end
	end

	if root and vim.fn.filereadable(root .. "/compile_commands.json") == 0 then
		table.insert(lines, "Hint: generate compile_commands.json for accurate clangd firmware diagnostics.")
	end

	vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

function M.setup()
	vim.api.nvim_create_user_command("DiagnosticsReport", M.report, {
		desc = "Report current LSP and diagnostics state",
	})
	vim.keymap.set("n", "<leader>ld", "<cmd>DiagnosticsReport<CR>", {
		desc = "LSP: Diagnostics report",
	})
end

return M
