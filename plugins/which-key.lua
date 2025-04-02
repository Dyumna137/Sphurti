return {
  "folke/which-key.nvim",
  config = function()
    local wk = require("which-key")
    wk.setup({
      plugins = { spelling = { enabled = true } },
      window = { border = "rounded", position = "bottom" },
    })

    local mappings = require("custom.mappings")  -- ✅ Load mappings correctly
    for mode, map_table in pairs(mappings) do
      wk.register(map_table, { mode = mode })
    end
  end,
}

