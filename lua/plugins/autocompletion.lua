-- ╭──────────────────────────────────────╮
-- │ AUTOCOMPLETION - blink.cmp          │
-- ╰──────────────────────────────────────╯
-- Modern Neovim completion engine with LSP, snippets, and buffer completion
-- Using blink.cmp for better performance over nvim-cmp

return {
  "saghen/blink.cmp",
  event = "InsertEnter", -- Only load when entering insert mode
  version = "1.*",
  
  dependencies = {
    -- Snippet engine
    {
      "L3MON4D3/LuaSnip",
      version = "2.*",
      build = (function()
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return nil
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
    },
    
    -- Lua LSP completion for Neovim config
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  
  opts = {
    keymap = {
      preset = "default",
      -- Custom keymaps can be added here:
      -- ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      -- ['<C-e>'] = { 'hide' },
    },
    
    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },
    
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        draw = {
          treesitter = { "lsp" },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = true,
      },
    },
    
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "lazydev" },
      providers = {
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          score_offset = 100, -- Prioritize lazydev suggestions
        },
      },
    },
    
    snippets = {
      preset = "luasnip",
    },
    
    fuzzy = {
      -- Use 'fzf' for better performance if available
      implementation = "lua",
    },
    
    signature = {
      enabled = true,
    },
  },
}
