-- ╭───────────────────────────╮
-- │ KEYMAPS & SHORTCUTS       │
-- ╰───────────────────────────╯

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
vim.o.updatetime = 500 -- Optional, can remove if not using CursorHold
-- ╭───────────────────────────╮
-- │ BASIC MAPPINGS            │
-- ╰───────────────────────────╯
keymap({ "n", "v" }, "<Space>", "<Nop>", opts)      -- Disable default <Space> behavior
keymap("n", "<Esc>", ":noh<CR>", opts)              -- Clear search highlights
keymap("n", "<C-s>", ":w<CR>", opts)                -- Save file
keymap("n", "<leader>wf", ":noautocmd w<CR>", opts) -- Save without triggering autocommands
keymap("n", "<C-q>", ":q<CR>", opts)                -- Quit file
keymap("n", "x", '"_x', opts)                       -- Delete char without yanking

-- ╭───────────────────────────╮
-- │ NAVIGATION                │
-- ╰───────────────────────────╯
keymap("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true }) -- Move down (respecting wrapped lines)
keymap("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true }) -- Move up (respecting wrapped lines)
keymap("n", "n", "nzzzv", opts)                                -- Center screen after search next
keymap("n", "N", "Nzzzv", opts)                                -- Center screen after search previous
keymap("n", "<C-d>", "<C-d>zz", opts)                          -- Scroll down and center
keymap("n", "<C-u>", "<C-u>zz", opts)                          -- Scroll up and center

-- ╭───────────────────────────╮
-- │ SPLIT / WINDOW MANAGEMENT │
-- ╰───────────────────────────╯
keymap("n", "<leader>vv", "<C-w>v", opts)                                                                   -- Split window vertically
keymap("n", "<leader>hh", "<C-w>s", opts)                                                                   -- Split window horizontally
keymap("n", "<leader>se", "<C-w>=", opts)                                                                   -- Equalize window sizes
keymap("n", "<leader>xs", ":close<CR>", opts)                                                               -- Close current split
keymap("n", "<C-h>", "<C-w>h", vim.tbl_extend("force", opts, { desc = "Move focus to the left window" }))   -- Navigate left
keymap("n", "<C-j>", "<C-w>j", vim.tbl_extend("force", opts, { desc = "Move focus to the bottom window" })) -- Navigate down
keymap("n", "<C-k>", "<C-w>k", vim.tbl_extend("force", opts, { desc = "Move focus to the top window" }))    -- Navigate up
keymap("n", "<C-l>", "<C-w>l", vim.tbl_extend("force", opts, { desc = "Move focus to the right window" }))  -- Navigate right

-- ╭───────────────────────────╮
-- │ RESIZE SPLITS             │
-- ╰───────────────────────────╯
keymap("n", "<C-Up>", ":resize -2<CR>", opts)             -- Decrease window height
keymap("n", "<C-Down>", ":resize +2<CR>", opts)           -- Increase window height
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)  -- Decrease window width
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts) -- Increase window width

-- ╭───────────────────────────╮
-- │ TABS & BUFFERS            │
-- ╰───────────────────────────╯
keymap("n", "<leader>to", ":tabnew<CR>", opts)                        -- New tab
keymap("n", "<leader>tx", ":tabclose<CR>", opts)                      -- Close tab
keymap("n", "<leader>tn", ":tabn<CR>", opts)                          -- Next tab
keymap("n", "<leader>tp", ":tabp<CR>", opts)                          -- Previous tab
keymap("n", "<Tab>", ":bnext<CR>", opts)                              -- Next buffer
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)                        -- Previous buffer
keymap("n", "<leader>sb", ":buffers<CR>:buffer ", { noremap = true }) -- Buffer list + select
-- keymap("n", "<leader>x", ":Bdelete<CR>", opts)                        -- Close buffer -- NOTE: i can't still finding good keymap for closing buffer
keymap("n", "<leader>bn", ":enew<CR>", opts)                          -- New buffer

-- ╭───────────────────────────╮
-- │ EDITING SHORTCUTS         │
-- ╰───────────────────────────╯
keymap("n", "<leader>+", "<C-a>", opts)           -- Increment number
keymap("n", "<leader>-", "<C-x>", opts)           -- Decrement number
keymap("n", "<leader>lw", ":set wrap!<CR>", opts) -- Toggle line wrapping

-- ╭───────────────────────────╮
-- │ INSERT MODE EXIT          │
-- ╰───────────────────────────╯
-- keymap("i", "jk", "<ESC>", opts) -- Exit insert with jk
-- keymap("i", "kj", "<ESC>", opts) -- Exit insert with kj

-- ╭────────────────────────────╮
-- │ VISUAL MODE BEHAVIOR       │
-- ╰────────────────────────────╯
keymap("v", "p", '"_dP', opts) -- Paste over without yanking
-- Stay in Indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- ╭────────────────────────────╮
-- │ SYSTEM CLIPBOARD           │
-- ╰────────────────────────────╯
keymap({ "n", "v" }, "<leader>y", '"+y', opts) -- Yank to system clipboard
keymap("n", "<leader>Y", '"+Y', opts)          -- Yank line to system clipboard

-- ╭────────────────────────────╮
-- │ FILE EXPLORER              │
-- ╰────────────────────────────╯
-- keymap("n", "<leader>e", ":Lex<CR>", opts)               -- Open file explorer (netrw)
-- keymap("n", "<leader>e", ":Neotree toggle<CR>", opts)

-- ╭────────────────────────────╮
-- │ OTHERS                     │
-- ╰────────────────────────────╯

keymap("n", "<leader>bc", function()
  for _, buf in ipairs(vim.fn.getbufinfo()) do
    if buf.listed == 1 and buf.hidden == 1 then
      vim.cmd("bdelete " .. buf.bufnr)
    end
  end
end, { desc = "Clean hidden buffers" })

keymap("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format Code" })

keymap("n", "<C-k>", function()
  vim.diagnostic.open_float(nil, {
    focusable = true,
    border = "rounded",
    source = "always",
    prefix = "",
    scope = "cursor",
    close_events = {}, -- stays open until closed manually
  })
end, { desc = "Manually show detailed diagnostic float" })

-- only when using windows OS
-- Ctrl+B = Visual Block Mode (remapped from Ctrl+V because terminal hijacks it)
vim.keymap.set("n", "<C-b>", "<C-v>", { noremap = true })

-- ╭────────────────────────────╮
-- │ OTHERS                     │
-- ╰────────────────────────────╯
-- Modes: 'n' = normal, 'i' = insert, 'v' = visual

-- Disable in normal, insert, and visual modes
for _, mode in pairs({ 'n', 'v' }) do
  vim.keymap.set(mode, '<Up>', '<Nop>', { noremap = true, silent = true })
  vim.keymap.set(mode, '<Down>', '<Nop>', { noremap = true, silent = true })
  vim.keymap.set(mode, '<Left>', '<Nop>', { noremap = true, silent = true })
  vim.keymap.set(mode, '<Right>', '<Nop>', { noremap = true, silent = true })
end

vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({
    hidden = true,                              -- show hidden files
    no_ignore = true,                           -- don’t skip ignored files
    search_dirs = { vim.fn.stdpath("config") }, -- search your nvim config
  })
end, { desc = "[F]ind [F]iles (including config)" })
-- it tells Neovim: “When I press <leader>ff, run Telescope and search my config files, including hidden ones.”
