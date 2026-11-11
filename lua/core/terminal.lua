-- Compatibility layer: core.panels owns the single persistent terminal.
-- This module remains so existing `require("core.terminal").setup()` calls work.
local M = {}

function M.toggle()
  require("core.panels").toggle("terminal")
end

function M.setup()
  local panels = require("core.panels")
  vim.api.nvim_create_user_command("ProjectTerminal", function()
    panels.terminal()
  end, { desc = "Open the persistent terminal at the project root", force = true })
end

return M
