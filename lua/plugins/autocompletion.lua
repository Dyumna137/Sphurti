-- ╭───────────────────────────────╮
-- │🤖⚙️AUTOCOMPLETION (nvim-cmp)  │
-- ╰───────────────────────────────╯
-- NOTE:🧵 3. What is cmp (completion plugin)?
-- 💡 Think of it as autocomplete magic inside Neovim.
-- It gives:
-- ✨ Suggestions as you type,  cmp shows the suggestions, but it doesn't generate them by itself.
-- 🧠 Autocomplete from:
-- LSP (cmp-nvim-lsp)
-- Buffer (cmp-buffer)
-- File paths (cmp-path)
-- Snippets (cmp_luasnip)
--
-- INFO:It doesn't know code by itself — it pulls suggestions from sources like LSPs.
-- Who gives smart suggestions like functions, types, variables, etc?
-- [LSP server] → (cmp-nvim-lsp) → [cmp] → shows popup

-- This file sets up advanced autocompletion using nvim-cmp with icons and snippets.
-- It's integrated with luasnip, lspkind, blink.cmp, and various useful sources.
-- Double quotes are used throughout for consistency.

local KIND_ICONS = {
  Text = "󰉿",
  Method = "󰊕",
  Function = "󰊕",
  Constructor = "󰒓",

  Field = "󰜢",
  Variable = "󰆦",
  Property = "󰖷",

  Class = "󱡠",
  Interface = "󱡠",
  Struct = "󱡠",
  Module = "󰅩",

  Unit = "󰪚",
  Value = "󰦨",
  Enum = "󰦨",
  EnumMember = "󰦨",

  Keyword = "󰻾",
  Constant = "󰏿",

  Snippet = "󱄽",
  Color = "󰏘",
  File = "󰈔",
  Reference = "󰬲",
  Folder = "󰉋",
  Event = "󱐋",
  Operator = "󰪚",
  TypeParameter = "󰬛",
}

return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "BufReadPost" },
  -- event = "VeryLazy", -- Change to "InsertEnter" for more eager loading
  version = "1.*",
  dependencies = {
    {
      "L3MON4D3/LuaSnip",
      version = "2.*",
      build = (function()
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
      opts = {},
    },
    {
      "folke/lazydev.nvim",
      opts = {},
    },
    {
      "hrsh7th/nvim-cmp",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
      },
    },
    { "onsails/lspkind.nvim" },
  },
  opts = {
    keymap = {
      preset = "default",
    },
    appearance = {
      nerd_font_variant = "mono",
    },
    completion = {
      -- Default settings for auto-completion
      -- autocomplete = {
      --   require("cmp").TriggerEvent.TextChanged,
      --   require("cmp").TriggerEvent.InsertEnter,
      -- },
      documentation = {
        auto_show = false,
        auto_show_delay_ms = 500,
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "lazydev" },
      providers = {
        lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },
    snippets = { preset = "luasnip" },
    fuzzy = { implementation = "lua" },
    signature = { enabled = true },
  },
  config = function()
    require("lspkind").init()
    local cmp = require("cmp")
    cmp.setup({
      window = {
        -- Optionally uncomment for custom popup blending:
        -- completion = vim.tbl_deep_extend("force", cmp.config.window.bordered(), { winblend = 10 }),
        -- documentation = vim.tbl_deep_extend("force", cmp.config.window.bordered(), { winblend = 10 }),
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-y>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = true }),
        ["<C-e>"] = cmp.mapping.close(),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lua" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "luasnip" },
        { name = "buffer",  keyword_length = 5 },
      }),
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
          vim_item.kind = string.format("%s", KIND_ICONS[vim_item.kind] or "")
          vim_item.menu = ({
            buffer = "[Buffer]",
            nvim_lsp = "[LSP]",
            nvim_lua = "[api]",
            path = "[Path]",
            luasnip = "[Snippet]",
          })[entry.source.name]
          return vim_item
        end,
      },
      experimental = {
        native_menu = false,
        ghost_text = true,
      },
    })

    vim.cmd([[
      highlight! CmpItemAbbr guifg=#ffffff
      highlight! CmpItemAbbrMatch guifg=#82AAFF gui=bold
      highlight! CmpItemKind guifg=#C586C0
      highlight! CmpItemMenu guifg=#A6ACCD
    ]])
  end,

}

--[[
📝 NOTES FOR FUTURE ME:

1. 📦 Snippets:
   - LuaSnip is your snippet engine.
   - You are using 'friendly-snippets' which includes many ready-made snippets. Customize them if needed!

2. 🎛️ Customization:
   - You can enable the `window.winblend` options for a transparent look.
   - Consider customizing the `completion.documentation` to `auto_show = true` if you want docs to appear on hover.

3. 💡 Icons:
   - Icons are aligned based on the `nerd_font_variant`. Adjust if using different fonts.

4. 🚀 Performance:
   - You can switch `fuzzy.implementation` from 'lua' to 'prefer_rust_with_warning' if you want performance boost (requires rust).

5. ⚠️ Repetition:
   - KIND_ICONS was defined twice in your original config. Keep it once at the top to avoid redundancy.

6. 🔧 Signature Help:
   - Enabled by default. You can fine-tune this based on your LSP.

7. 🧼 Clean Code:
   - Avoid duplicate returns and unnecessary nesting in Lua plugin specs. Try to separate plugin definitions and configurations.
--]]
