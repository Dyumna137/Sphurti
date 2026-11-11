-- A consistent, discoverable keymap layout for the engineering workflow.
-- Leader keys should also be set at the very top of init.lua, before lazy.nvim.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

local function bind(mode, lhs, rhs, desc)
  map(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
end

local function telescope_builtin(name, fallback)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok and builtin[name] then
      builtin[name]()
    elseif fallback then
      fallback()
    else
      vim.notify("Telescope is not available. Check your Telescope plugin setup.", vim.log.levels.WARN)
    end
  end
end

-- ---------------------------------------------------------------------------
-- Save / exit
-- ---------------------------------------------------------------------------
bind("n", "<C-s>", "<cmd>update<CR>", "Save: Write if changed")
bind("i", "<C-s>", "<Esc><cmd>update<CR>a", "Save: Write if changed")
bind("n", "<leader>wf", "<cmd>noautocmd update<CR>", "Save: Write without autocommands")
bind("n", "<C-q>", "<cmd>q<CR>", "Quit: Close current window")
bind("n", "<Esc>", "<cmd>nohlsearch<CR>", "Search: Clear highlights")
bind("n", "x", '"_x', "Edit: Delete character without yanking")

-- ---------------------------------------------------------------------------
-- Movement / editing
-- ---------------------------------------------------------------------------
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move: Display line down" })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move: Display line up" })
bind("n", "n", "nzzzv", "Search: Next match centered")
bind("n", "N", "Nzzzv", "Search: Previous match centered")
bind("n", "<C-d>", "<C-d>zz", "Move: Half page down centered")
bind("n", "<C-u>", "<C-u>zz", "Move: Half page up centered")
bind("n", "J", "mzJ`z", "Edit: Join line and keep cursor")
bind("v", "<", "<gv", "Edit: Indent left and keep selection")
bind("v", ">", ">gv", "Edit: Indent right and keep selection")
bind("v", "p", '"_dP', "Edit: Paste without replacing register")
bind({ "n", "v" }, "<leader>y", '"+y', "Clipboard: Yank to system clipboard")
bind("n", "<leader>Y", '"+Y', "Clipboard: Yank line to system clipboard")
bind("n", "<leader>+", "<C-a>", "Edit: Increment number")
bind("n", "<leader>-", "<C-x>", "Edit: Decrement number")
bind("n", "<leader>tw", "<cmd>setlocal wrap!<CR>", "Text: Toggle line wrapping")

-- ---------------------------------------------------------------------------
-- Files and buffers
-- Keep file-search mappings in plugins/telescope.lua, as in your original setup.
-- Buffer selection is assigned here so the buffer group has one predictable entry.
-- ---------------------------------------------------------------------------
bind("n", "<Tab>", "<cmd>bnext<CR>", "Buffer: Next")
bind("n", "<S-Tab>", "<cmd>bprevious<CR>", "Buffer: Previous")
bind("n", "<leader>bb", telescope_builtin("buffers", function()
  vim.cmd("buffers")
end), "Buffer: Choose")
bind("n", "<leader>bd", "<cmd>bdelete<CR>", "Buffer: Delete current")
bind("n", "<leader>bn", "<cmd>enew<CR>", "Buffer: New scratch buffer")
bind("n", "<leader>bc", function()
  local deleted = 0
  for _, buffer in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if buffer.bufnr ~= vim.api.nvim_get_current_buf()
      and buffer.hidden == 1
      and not vim.bo[buffer.bufnr].modified then
      local ok = pcall(vim.api.nvim_buf_delete, buffer.bufnr, { force = false })
      if ok then
        deleted = deleted + 1
      end
    end
  end
  vim.notify(("Closed %d hidden, unmodified buffer(s)"):format(deleted))
end, "Buffer: Clean hidden unmodified buffers")

-- ---------------------------------------------------------------------------
-- Windows / splits
-- ---------------------------------------------------------------------------
bind("n", "<leader>wv", "<cmd>vsplit<CR>", "Window: Vertical split")
bind("n", "<leader>ws", "<cmd>split<CR>", "Window: Horizontal split")
bind("n", "<leader>we", "<C-w>=", "Window: Equalize splits")
bind("n", "<leader>wc", "<cmd>close<CR>", "Window: Close current split")
bind("n", "<leader>wo", "<cmd>only<CR>", "Window: Keep only current split")
bind("n", "<C-h>", "<C-w>h", "Window: Focus left")
bind("n", "<C-j>", "<C-w>j", "Window: Focus below")
bind("n", "<C-k>", "<C-w>k", "Window: Focus above")
bind("n", "<C-l>", "<C-w>l", "Window: Focus right")
bind("n", "<C-Up>", "<cmd>resize +2<CR>", "Window: Increase height")
bind("n", "<C-Down>", "<cmd>resize -2<CR>", "Window: Decrease height")
bind("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Window: Decrease width")
bind("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Window: Increase width")

-- ---------------------------------------------------------------------------
-- Tab pages (use buffers for ordinary file switching)
-- ---------------------------------------------------------------------------
bind("n", "<leader>to", "<cmd>tabnew<CR>", "Tab: New tab page")
bind("n", "<leader>tx", "<cmd>tabclose<CR>", "Tab: Close tab page")
bind("n", "<leader>tn", "<cmd>tabnext<CR>", "Tab: Next tab page")
bind("n", "<leader>tp", "<cmd>tabprevious<CR>", "Tab: Previous tab page")

-- ---------------------------------------------------------------------------
-- File explorer
-- ---------------------------------------------------------------------------
bind("n", "<leader>e", "<cmd>Explore<CR>", "Explorer: Open in current window")
bind("n", "<leader>E", "<cmd>Lexplore<CR>", "Explorer: Toggle left tree")
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 0
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25

-- ---------------------------------------------------------------------------
-- Quickfix
-- ---------------------------------------------------------------------------
bind("n", "<leader>qo", "<cmd>copen<CR>", "Quickfix: Open")
bind("n", "<leader>qc", "<cmd>cclose<CR>", "Quickfix: Close")
bind("n", "]q", "<cmd>cnext<CR>", "Quickfix: Next item")
bind("n", "[q", "<cmd>cprev<CR>", "Quickfix: Previous item")

-- ---------------------------------------------------------------------------
-- Project / embedded tools
-- ---------------------------------------------------------------------------
require("core.embedded").setup()
require("core.git").setup()
require("core.diagnostics").setup()
require("core.terminal").setup() -- compatibility command; panels owns the terminal

bind("n", "<leader>mb", "<cmd>EmbeddedBuild<CR>", "Make: Build project")
bind("n", "<leader>mr", "<cmd>EmbeddedRun<CR>", "Make: Run executable")
bind("n", "<leader>mt", "<cmd>EmbeddedTest<CR>", "Make: Run tests")
bind("n", "<leader>mf", "<cmd>EmbeddedFlash<CR>", "Make: Flash firmware")
bind("n", "<leader>mm", "<cmd>EmbeddedMonitor<CR>", "Make: Serial monitor")
bind("n", "<leader>md", "<cmd>EmbeddedDebug<CR>", "Make: Check debug tools")
bind("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<CR>", "C/C++: Switch source/header")

-- ---------------------------------------------------------------------------
-- Notes / scratch buffers
-- ---------------------------------------------------------------------------
bind("n", "<leader>nd", function()
  vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", true, true)
end, "Note: Insert date")
bind("n", "<leader>nt", function()
  vim.api.nvim_put({ os.date("%H:%M") }, "c", true, true)
end, "Note: Insert time")
bind("n", "<leader>nn", function()
  vim.cmd("enew")
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.swapfile = false
  vim.bo.filetype = "markdown"
end, "Note: New scratch buffer")

-- ---------------------------------------------------------------------------
-- Windows: Ctrl-B enters Visual Block mode (Ctrl-V is often intercepted).
-- ---------------------------------------------------------------------------
if vim.fn.has("win32") == 1 then
  bind("n", "<C-b>", "<C-v>", "Edit: Visual block mode")
end

-- Optional training wheels: remove arrow movement in normal/visual mode.
for _, mode in ipairs({ "n", "v" }) do
  map(mode, "<Up>", "<Nop>", opts)
  map(mode, "<Down>", "<Nop>", opts)
  map(mode, "<Left>", "<Nop>", opts)
  map(mode, "<Right>", "<Nop>", opts)
end
