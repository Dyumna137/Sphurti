-- ╭───────────────────────────╮
-- │ KEYMAPS & SHORTCUTS       │
-- ╰───────────────────────────╯

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
-- ╭───────────────────────────╮
-- │ BASIC MAPPINGS            │
-- ╰───────────────────────────╯
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
keymap("n", "<leader>vv", "<C-w>v", { desc = "Split vertical" })
keymap("n", "<leader>hh", "<C-w>s", { desc = "Split horizontal" })
keymap("n", "<leader>se", "<C-w>=", { desc = "Equalize splits" })
keymap("n", "<leader>xs", ":close<CR>", { desc = "Close split" })
keymap("n", "<C-h>", "<C-w>h", { desc = "Focus left window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Focus bottom window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Focus top window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Focus right window" })

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
-- ╰───────────────────────────╮
keymap("n", "<leader>+", "<C-a>", opts)            -- Increment number
keymap("n", "<leader>-", "<C-x>", opts)            -- Decrement number
keymap("n", "<leader>tw", ":set wrap!<CR>", opts)  -- Toggle line wrapping

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
-- Note: File explorer keymaps are defined in their respective plugin configs
-- Oil: "-" and "<space>-" in plugins/oil.lua
-- Neo-tree: can be added if needed

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

-- LSP format and diagnostics are handled in plugins/lsp/on_attach.lua

-- Windows-specific: Ctrl+B = Visual Block Mode (terminal hijacks Ctrl+V)
if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
  vim.keymap.set("n", "<C-b>", "<C-v>", { noremap = true })
end

-- ╭────────────────────────────╮
-- │ TRAINING WHEELS REMOVAL    │
-- ╰────────────────────────────╯
-- Disable arrow keys to enforce hjkl muscle memory
-- Note: Ctrl+Arrow still works for window resizing
for _, mode in pairs({ 'n', 'v' }) do
  vim.keymap.set(mode, '<Up>', '<Nop>', { noremap = true, silent = true })
  vim.keymap.set(mode, '<Down>', '<Nop>', { noremap = true, silent = true })
  vim.keymap.set(mode, '<Left>', '<Nop>', { noremap = true, silent = true })
  vim.keymap.set(mode, '<Right>', '<Nop>', { noremap = true, silent = true })
end

-- Telescope keymaps are defined in plugins/telescope.lua
