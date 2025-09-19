vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp" },
  callback = function()
    local lspconfig = require("lspconfig")

    -- Check if clangd is already attached to avoid duplicates
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    for _, client in ipairs(clients) do
      if client.name == "clangd" then return end
    end

    lspconfig.clangd.setup({})
    vim.cmd("LspStart clangd")
  end,
})
