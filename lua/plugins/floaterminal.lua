vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

-- Function: Create or reuse floating window
function OpenFloatingWindow(opts)
  -- Set default width and height to 80% of the screen
  local ui = vim.api.nvim_list_uis()[1]
  local width = math.floor((opts and opts.width or 0.8 * ui.width))
  local height = math.floor((opts and opts.height or 0.8 * ui.height))

  -- Calculate centered row and col
  local row = math.floor((ui.height - height) / 2)
  local col = math.floor((ui.width - width) / 2)

  -- Create a new scratch buffer
  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- No file, Scrath buffer
  end


  -- Set window options
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal', -- No borders Or Extra UI element
    border = 'rounded'
  })

  -- Optional: set some content
  -- vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
  --   "This is a floating window.",
  --   "Press 'q' to close it."
  -- })

  -- Optional: map `q` to close the window
  -- vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true })

  return { buf = buf, win = win }
end

local function toggle_terminal(use_file_dir)
  local filedir = nil

  if use_file_dir then
    local filepath = vim.api.nvim_buf_get_name(0)
    filedir = vim.fn.fnamemodify(filepath, ":p:h")
  else
    filedir = vim.fn.getcwd()
  end

  if not vim.api.nvim_win_is_valid(state.floating.win) then
    local old_dir = vim.fn.getcwd()
    vim.cmd("lcd " .. filedir)

    state.floating = OpenFloatingWindow { buf = state.floating.buf }

    if vim.bo[state.floating.buf].buftype ~= "terminal" then
      vim.cmd("terminal")
    end

    vim.cmd("lcd " .. old_dir) -- restore previous directory
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end
-- local toggle_terminal = function()
--   if not vim.api.nvim_win_is_valid(state.floating.win) then
--     state.floating = OpenFloatingWindow { buf = state.floating.buf } -- Passing previous buffer we have before, For fresh start don't pass if
--     if vim.bo[state.floating.buf].buftype ~= "terminal" then
--       vim.cmd.terminal()                                             -- Call terinal inside that buffer
--     end
--   else
--     vim.api.nvim_win_hide(state.floating.win)
--   end
-- end
-- first create a command or keymap for for this to run

-- Example Usage:
-- Creating a floating window Using default parameter
-- local buf, win = OpenFloatingWindow()
-- print(buf, win)

vim.api.nvim_create_user_command("Floaterminal", function(opts)
  local use_file_dir = opts.args == "file"
  toggle_terminal(use_file_dir)
end, {
  nargs = "?",
  complete = function()
    return { "file", "cwd" }
  end,
})
vim.keymap.set({ "n", "t" }, "<leader>tt", function()
  toggle_terminal(true)
end, { desc = "Toggle Floating Terminal (file dir)" })
vim.keymap.set({ "n", "t" }, "<leader>tw", function()
  toggle_terminal(false)
end, { desc = "Toggle Floating Terminal (cwd)" })

-- Above codes Work (toggle_terminal): You're storing the buffer in state.floating.buf, so it reuses that buffer when reopening.
-- Since you're not deleting or wiping the buffer, its contents persist — which is actually great if that’s your goal.

-- ✅ Behavior I'm  Observing
-- You open the floating window using :Floaterminal.
-- You type some text in it.
-- You call :Floaterminal again → it closes the window (not the buffer).
-- You call :Floaterminal again → it reopens the same buffer, so the previous text remains.
--
-- 🤖 Why It Happens
-- See the comments
