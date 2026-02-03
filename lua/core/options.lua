-- File: ~/.config/nvim/lua/core/options.lua
-- options.lua is usually where you keep all editor-wide settings like vim.opt.*.
-- Putting things like editor like-wide settings instead of init.lua is cleaner.
-- ╭────────────────────────────╮
-- │ GENERAL                    │
-- ╰────────────────────────────╯
local opt = vim.opt

opt.mouse = 'a'               -- Enable mouse support
opt.clipboard = 'unnamedplus' -- Sync Neovim clipboard with system
opt.fileencoding = 'utf-8'    -- Set file encoding to UTF-8
opt.swapfile = false          -- Don't use swap files
opt.backup = false            -- Don't create backup files
opt.writebackup = false       -- Disable backup before overwriting files
opt.undofile = true           -- Enable persistent undo
-- Ensure undo directory exists
local undodir = vim.fn.stdpath('data') .. '/undo'
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, 'p')
end
opt.undodir = undodir
opt.cmdheight = 1             -- Command-line height for messages (explicit: default is 1)
opt.updatetime = 250          -- Faster completion & update time (trade-off: battery vs responsiveness)
opt.timeout = true            -- Enable timeout for mappings
opt.timeoutlen = 1000         -- Time (in ms) to wait for a mapped sequence to complete
opt.termguicolors = true      -- Enable 24-bit colors

-- ╭────────────────────────────╮
-- │ UI / INTERFACE             │
-- ╰────────────────────────────╯
opt.number = true         -- Show absolute line numbers
opt.relativenumber = true -- Show relative numbers
opt.numberwidth = 4       -- Width of the number column
opt.signcolumn = 'yes:1'  -- Always show sign column (fixed width: prevents layout shift)
opt.cursorline = true     -- Highlight current line (negligible perf impact in Neovim 0.9+)
opt.showmode = false      -- Don't show --INSERT-- mode
opt.showtabline = 0       -- Hidden: bufferline.nvim handles tab/buffer display
opt.pumheight = 10        -- Max number of items in completion popup
opt.conceallevel = 0      -- Show `` in markdown

-- ╭────────────────────────────╮
-- │ SEARCHING                  │
-- ╰────────────────────────────╯
opt.hlsearch = true       -- Enable search highlighting (clear with <Esc>)
opt.incsearch = true      -- Show matches as you type
opt.ignorecase = true     -- Ignore case when searching...
opt.smartcase = true      -- ...unless capital letters are used
opt.inccommand = 'split'  -- Live preview of substitutions (Neovim 0.5+)

-- ╭────────────────────────────╮
-- │ INDENTATION & TABS         │
-- ╰────────────────────────────╯
-- Fixed indentation settings (4 spaces, expandtab enabled)
opt.autoindent = true  -- Auto-indent new lines
opt.smartindent = true -- Smart indentation
opt.breakindent = true -- Keep indentation on wrapped lines
opt.tabstop = 4        -- Default: a tab is 4 spaces
opt.shiftwidth = 4     -- Default: indent by 4 spaces
opt.softtabstop = 4    -- Default: backspace deletes 4 spaces
opt.expandtab = true   -- Convert tabs to spaces

-- ╭────────────────────────────╮
-- │ SPLITS & WINDOWS           │
-- ╰────────────────────────────╯
opt.splitbelow = true    -- Horizontal splits open below
opt.splitright = true    -- Vertical splits open to the right
opt.splitkeep = 'screen' -- Keep screen position on split (Neovim 0.9+)

-- ╭────────────────────────────╮
-- │ WRAPPING & SCROLLING       │
-- ╰────────────────────────────╯
opt.wrap = true              -- Wrap long lines
opt.linebreak = true         -- Wrap at word boundaries when wrapping
opt.scrolloff = 4            -- Minimum lines above/below cursor
opt.sidescrolloff = 8        -- Columns to keep left/right of cursor
opt.whichwrap:append('b,s,h,l') -- Allow h/l to move to next/prev line (arrows disabled)
opt.virtualedit = 'block'    -- Allow cursor beyond EOL in visual block mode

-- ╭────────────────────────────╮
-- │ COMPLETION                 │
-- ╰────────────────────────────╯
opt.completeopt = { "menu", "menuone", "noselect" } -- Better autocompletion experience
opt.shortmess:append('c')                           -- No completion menu messages
opt.wildmode = 'longest:full,full'                  -- Command-line completion behavior
-- NOTE: 🧠 Why not in on_attach?
-- Because completeopt is a global editor option, not buffer-local or LSP-specific. It only needs to be set once, and setting it in on_attach would be redundant and inefficient.

-- ╭────────────────────────────╮
-- │ FORMATTING / TEXT          │
-- ╰────────────────────────────╯
opt.iskeyword:append('-')                  -- Treat `foo-bar` as one word
opt.formatoptions:remove { 'c', 'r', 'o' } -- Disable auto comment insertion
-- ╭────────────────────────────╮
-- │ RUNTIME & SECURITY         │
-- ╰────────────────────────────╯
-- Remove Vim-specific paths (Linux/Unix only)
if vim.fn.has("unix") == 1 then
  opt.runtimepath:remove('/usr/share/vim/vimfiles')
end

-- Security: disable loading project-local configs
opt.exrc = false

-- ╭────────────────────────────╮
-- │ OTHERS                     │
-- ╰────────────────────────────╯
-- Modern Neovim features
opt.laststatus = 3   -- Global statusline (Neovim 0.7+)
opt.fillchars = { eob = " " } -- Hide ~ for empty lines

-- C/C++ compiler error format (GCC/ARM-GCC/Clang)
opt.errorformat:append('%f:%l:%m')

-- Use ripgrep for :grep if available (faster than default grep)
if vim.fn.executable('rg') == 1 then
  opt.grepprg = 'rg --vimgrep --smart-case --hidden'
  opt.grepformat = '%f:%l:%c:%m'
end

-- Clear the screen when Neovim exits (Windows only)
if vim.fn.has("win32") == 1 then
  vim.api.nvim_create_autocmd("VimLeave", {
    group = vim.api.nvim_create_augroup("clear-screen-on-exit", { clear = true }),
    command = "silent !cls",
    desc = "Clear terminal screen on exit",
  })
end
