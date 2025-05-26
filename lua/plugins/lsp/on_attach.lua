
local M = {}

M.on_attach = function(client, bufnr)
  local map = function(keys, func, desc, mode)
    mode = mode or 'n'
    vim.keymap.set(mode, keys, func, {
      buffer = bufnr,
      desc = 'LSP: ' .. desc,
    })
  end

  map('K', vim.lsp.buf.hover, 'Hover Documentation')
  map('<C-k>', vim.lsp.buf.signature_help, 'Signature Help')
  -- map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
  -- map('gra', vim.lsp.buf.code_action, '[Code] [Action]', { 'n', 'v' })

  -- Disable formatting for some LSPs if needed
  if client.name == "tsserver" or client.name == "lua_ls" then
    client.server_capabilities.documentFormattingProvider = false
  end
  -- add more if needed
end

return M
