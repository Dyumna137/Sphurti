-- This file only loads necessary LSP plugins like nvim-lspconfig, mason.nvim, and null-ls.nvim:

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     event = { "BufReadPre", "BufNewFile" },
--     dependencies = {
--       "williamboman/mason.nvim",
--       "williamboman/mason-lspconfig.nvim",
--       "jose-elias-alvarez/null-ls.nvim", -- Needed for formatters/linters
--     },
--     config = function()
--       require "plugins.configs.lspconfigs"
--       require("custom.configs")  -- Loads all LSP configurations
--     end,
--   },
-- }

