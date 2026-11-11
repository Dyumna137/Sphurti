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
    lines[#lines + 1] = "Hint: Open a C/C++/Lua file and check that its language server is installed and configured."
  else
    for _, client in ipairs(clients) do
      lines[#lines + 1] = ("- %s (%s)"):format(client.name, client.config and client.config.root_dir or "root not reported")
    end
  end

  if root and vim.fn.filereadable(root .. "/compile_commands.json") == 0 then
    lines[#lines + 1] = "Hint: Generate compile_commands.json for more accurate clangd project diagnostics."
  end

  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO)
end

function M.open()
  vim.diagnostic.setqflist({ open = true })
end

function M.setup()
  vim.api.nvim_create_user_command("DiagnosticsReport", M.report, {
    desc = "Report current LSP and diagnostics state",
    force = true,
  })
  vim.api.nvim_create_user_command("DiagnosticsList", M.open, {
    desc = "Put current diagnostics in the quickfix list",
    force = true,
  })

  vim.keymap.set("n", "<leader>dd", M.open, { desc = "Diagnostics: Open quickfix list" })
  vim.keymap.set("n", "<leader>dl", "<cmd>DiagnosticsReport<CR>", { desc = "Diagnostics: LSP report" })
  vim.keymap.set("n", "<leader>df", vim.diagnostic.open_float, { desc = "Diagnostics: Show current line" })
  vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Diagnostics: Next" })
  vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Diagnostics: Previous" })
end

return M
