local M = {}

-- Categories for which-key.nvim
M.general = {
  n = { -- Normal mode mappings
    ["<leader>f"] = { name = "+file" },
    ["<leader>g"] = { name = "+git" },
    ["<leader>l"] = { name = "+lsp" },
    ["<leader>t"] = { name = "+toggle" },
    ["<leader>ff"] = { "<cmd>Telescope find_files<CR>", "Find Files" },
    ["<leader>fg"] = { "<cmd>Telescope live_grep<CR>", "Live Grep" },
  },
  v = { -- Visual mode mappings
    ["<leader>y"] = { '"+y', "Yank to clipboard" },
  },
}

local map = vim.keymap.set

map("n", "<leader>r", function()
  vim.cmd "w" -- Save the current file before running

  -- Get the full filename and extension
  local file = vim.fn.expand "%"
  local ext = vim.fn.expand "%:e"

  -- Table of commands for different file extensions
  local run_cmds = {
    -- Compile and run C files
    c = "gcc " .. file .. " -o " .. file:gsub("%.%w+$", "") .. " && " .. file:gsub("%.%w+$", ""),
    -- Compile and run C++ files
    cpp = "g++ " .. file .. " -o " .. file:gsub("%.%w+$", "") .. " && " .. file:gsub("%.%w+$", ""),
    -- Run Python files
    py = "python " .. file,
    -- Run JavaScript files using Node.js
    js = "node " .. file,
    -- Run TypeScript files (requires ts-node)
    ts = "ts-node " .. file,
    -- Compile and run Java files
    java = "javac " .. file .. " && java " .. file:gsub("%.java$", ""),
    -- Compile and run Rust files
    rs = "rustc " .. file .. " && " .. file:gsub("%.rs$", ""),
    -- Run Shell scripts
    sh = "bash " .. file,
    -- Run Lua scripts
    lua = "lua " .. file,
    -- Run PHP scripts
    php = "php " .. file,
    -- Run Go files
    go = "go run " .. file,
    -- Run Ruby scripts
    rb = "ruby " .. file,
    -- Run Perl scripts
    pl = "perl " .. file,
    -- Run Swift files
    swift = "swift " .. file,
    -- Compile and run Kotlin files
    kotlin = "kotlinc " .. file .. " -include-runtime -d out.jar && java -jar out.jar",
    -- Run R scripts
    r = "Rscript " .. file,

     -- Compile and run Assembly (NASM for Linux and Windows)
    asm = vim.fn.has("win32") == 1 and "nasm -f win32 " .. file .. " -o " .. file:gsub("%.asm$", ".obj") .. " && gcc " .. file:gsub("%.asm$", ".obj") .. " -o " .. file:gsub("%.asm$", ".exe") .. " && " .. file:gsub("%.asm$", ".exe")
                            or "nasm -f elf64 " .. file .. " -o " .. file:gsub("%.asm$", ".o") .. " && ld " .. file:gsub("%.asm$", ".o") .. " -o " .. file:gsub("%.asm$", "") .. " && " .. file:gsub("%.asm$", ""),
  }



  -- Get the corresponding run command for the file extension
  local run_cmd = run_cmds[ext]

  if run_cmd then
    -- Open a terminal in a horizontal split and execute the command
    vim.cmd("split | terminal " .. run_cmd)
    vim.cmd "resize 10" -- Resize the terminal split
  else
    -- Print an error message if no command is found for the file type
    print("No run command configured for *." .. ext)
  end
end, { silent = true })


-- Git keybindings
local gs = require "gitsigns"
map("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Git hunk" })
map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Git hunk" })
map("n", "<leader>gb", gs.toggle_current_line_blame, { desc = "Toggle Git blame" })

-- Open external terminal commands
map("n", "<leader>p", ':!powershell.exe -Command "Get-Process"<CR>', { noremap = true, silent = true })
map("n", "<leader>b", ":!C:\\Program Files\\Git\\bin\\bash.exe -c 'ls -l'<CR>", { noremap = true, silent = true })

-- Terminal split commands
map("n", "<leader>tc", ":close<CR>", { noremap = true, silent = true })
map("n", "<leader>tc", ":split | terminal cmd.exe<CR>", { noremap = true, silent = true })
map("n", "<leader>tp", ":split | terminal pwsh<CR>", { noremap = true, silent = true })

-- Open external terminals in current directory
map("n", "<leader>ec", ":!start cmd.exe /k cd %:p:h<CR>", { noremap = true, silent = true })
map("n", "<leader>ep", ":!start pwsh -NoExit -Command cd %:p:h<CR>", { noremap = true, silent = true })

-- Terminal keymaps
map("n", "<leader>th", ":split | terminal<CR>", { noremap = true, silent = true })
map("n", "<leader>tv", ":vsplit | terminal<CR>", { noremap = true, silent = true })
map("t", "<leader>q", "<C-\\><C-n>:q<CR>", { noremap = true, silent = true })

-- Format with conform.nvim
map("n", "<leader>f", function()
  require("conform").format()
end)

return M.general
