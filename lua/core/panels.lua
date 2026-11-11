-- Persistent output panels for terminal, builds, tests, Git and serial monitoring.
-- Neovim 0.10+ recommended.
local M = {
  bottom = {
    height = 12,
    kind = "terminal",
    win = nil,
    bufs = {},
    jobs = {},
    project_root = nil,
    terminal_cwd = nil,
  },
}

local kinds = {
  terminal = "Terminal",
  serial = "Serial Monitor",
  build = "Build Output",
  run = "Run Output",
  debug = "Debug Output",
  tests = "Test Output",
  git = "Git Output",
  diagnostics = "Diagnostics",
}

local function project_root(buf)
  return vim.fs.root(buf or 0, {
    ".git", "CMakeLists.txt", "Makefile", "platformio.ini", "sdkconfig",
  }) or vim.fn.getcwd()
end

local function active_project_root()
  local current_buf = vim.api.nvim_get_current_buf()
  local is_panel_buffer = false
  for _, panel_buf in pairs(M.bottom.bufs) do
    if panel_buf == current_buf then
      is_panel_buffer = true
      break
    end
  end

  if not is_panel_buffer then
    M.bottom.project_root = project_root(current_buf)
  end
  return M.bottom.project_root or project_root(current_buf)
end

local function shell_cd_command(path)
  local shell = vim.o.shell:lower()
  if shell:match("powershell") or shell:match("pwsh") then
    return "Set-Location -LiteralPath '" .. path:gsub("'", "''") .. "'\r"
  end
  if shell:match("cmd%.exe") or shell:match("command%.com") then
    return 'cd /d "' .. path .. '"\r'
  end
  return "cd -- " .. vim.fn.shellescape(path) .. "\n"
end

local function valid_window()
  return M.bottom.win ~= nil and vim.api.nvim_win_is_valid(M.bottom.win)
end

local function is_terminal_kind(kind)
  return kind == "terminal" or kind == "serial"
end

local function job_is_running(job)
  if not job then
    return false
  end
  local ok, result = pcall(vim.fn.jobwait, { job }, 0)
  return ok and result[1] == -1
end

local function ensure_buffer(kind)
  local buf = M.bottom.bufs[kind]
  if buf and vim.api.nvim_buf_is_valid(buf) then
    return buf
  end

  buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].filetype = is_terminal_kind(kind) and "terminal" or "log"
  vim.api.nvim_buf_set_name(buf, "[IDE] " .. kinds[kind])
  if not is_terminal_kind(kind) then
    vim.bo[buf].modifiable = false
  end
  M.bottom.bufs[kind] = buf
  return buf
end

-- A completed terminal buffer cannot reliably be reused for a new termopen job.
-- Replace it after the previous process has exited.
local function fresh_terminal_buffer(kind)
  local old = M.bottom.bufs[kind]
  if old and vim.api.nvim_buf_is_valid(old) and vim.bo[old].buftype == "terminal" then
    pcall(vim.api.nvim_buf_delete, old, { force = true })
    M.bottom.bufs[kind] = nil
  end
  M.bottom.jobs[kind] = nil
  if kind == "terminal" then
    M.bottom.terminal_cwd = nil
  end
  return ensure_buffer(kind)
end

local function show(kind)
  assert(kinds[kind], "unknown IDE panel: " .. tostring(kind))
  M.bottom.kind = kind
  local buf = ensure_buffer(kind)

  if not valid_window() then
    vim.cmd("botright split")
    M.bottom.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_height(M.bottom.win, M.bottom.height)
  end

  vim.api.nvim_win_set_buf(M.bottom.win, buf)
  vim.api.nvim_set_current_win(M.bottom.win)
  if is_terminal_kind(kind) then
    vim.cmd("startinsert")
  else
    vim.cmd("stopinsert")
  end
end

local function append(kind, lines)
  local buf = ensure_buffer(kind)
  if type(lines) == "string" then
    lines = vim.split(lines, "\n", { plain = true })
  end
  if not lines or #lines == 0 then
    return
  end

  local was_modifiable = vim.bo[buf].modifiable
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.bo[buf].modifiable = was_modifiable

  if valid_window() and vim.api.nvim_win_get_buf(M.bottom.win) == buf then
    local count = vim.api.nvim_buf_line_count(buf)
    vim.api.nvim_win_set_cursor(M.bottom.win, { count, 0 })
  end
end

function M.open(kind)
  assert(kinds[kind], "unknown IDE panel: " .. tostring(kind))
  if kind == "terminal" then
    return M.terminal()
  end
  show(kind)
end

function M.toggle(kind)
  kind = kind or M.bottom.kind
  assert(kinds[kind], "unknown IDE panel: " .. tostring(kind))

  if valid_window() and M.bottom.kind == kind then
    vim.api.nvim_win_close(M.bottom.win, false)
    M.bottom.win = nil
    return
  end

  if kind == "terminal" then
    return M.terminal()
  end
  show(kind)
end

function M.resize(delta)
  if not valid_window() then
    vim.notify("[panels] No output panel is open", vim.log.levels.INFO)
    return
  end
  M.bottom.height = math.max(5, M.bottom.height + delta)
  vim.api.nvim_win_set_height(M.bottom.win, M.bottom.height)
end

function M.terminal()
  local cwd = active_project_root()
  local buf
  if job_is_running(M.bottom.jobs.terminal) then
    buf = ensure_buffer("terminal")
    if M.bottom.terminal_cwd ~= cwd then
      vim.api.nvim_chan_send(M.bottom.jobs.terminal, shell_cd_command(cwd))
      M.bottom.terminal_cwd = cwd
    end
  else
    buf = fresh_terminal_buffer("terminal")
    vim.api.nvim_buf_call(buf, function()
      local job
      job = vim.fn.termopen(vim.o.shell, {
        cwd = cwd,
        on_exit = function(_, code)
          vim.schedule(function()
            if M.bottom.jobs.terminal == job then
              M.bottom.jobs.terminal = nil
              M.bottom.terminal_cwd = nil
            end
            if vim.api.nvim_buf_is_valid(buf) then
              vim.bo[buf].modified = false
            end
            if code ~= 0 then
              vim.notify(("[terminal] Shell exited with code %d"):format(code), vim.log.levels.WARN)
            end
          end)
        end,
      })
      if job <= 0 then
        vim.notify("[terminal] Could not start the configured shell", vim.log.levels.ERROR)
      else
        M.bottom.jobs.terminal = job
        M.bottom.terminal_cwd = cwd
      end
    end)
  end
  show("terminal")
end

-- Start a dedicated terminal process in its own persistent panel (e.g. serial monitor).
function M.termrun(kind, command, opts)
  opts = opts or {}
  assert(kinds[kind] and is_terminal_kind(kind), "termrun requires a terminal panel kind")
  assert(type(command) == "table" and #command > 0, "termrun requires an argv table")

  if job_is_running(M.bottom.jobs[kind]) then
    show(kind)
    vim.notify("[panels] This terminal process is already running", vim.log.levels.INFO)
    return
  end

  local buf = fresh_terminal_buffer(kind)
  vim.api.nvim_buf_call(buf, function()
    local job
    job = vim.fn.termopen(command, {
      cwd = opts.cwd or project_root(),
      on_exit = function(_, code)
        vim.schedule(function()
          if M.bottom.jobs[kind] == job then
            M.bottom.jobs[kind] = nil
          end
          if vim.api.nvim_buf_is_valid(buf) then
            vim.bo[buf].modified = false
          end
          if code ~= 0 then
            vim.notify(("[%s] Process exited with code %d"):format(kinds[kind], code), vim.log.levels.WARN)
          end
        end)
      end,
    })
    if job <= 0 then
      vim.notify(("[%s] Could not start process"):format(kinds[kind]), vim.log.levels.ERROR)
    else
      M.bottom.jobs[kind] = job
    end
  end)
  show(kind)
end

-- Parse newline-delimited job output without splitting partial lines between callbacks.
local function consume_stream(stream, data)
  if not data or #data == 0 then
    return {}
  end

  local parts = vim.deepcopy(data)
  parts[1] = (stream.partial or "") .. (parts[1] or "")
  stream.partial = parts[#parts] or ""

  local complete = {}
  for index = 1, #parts - 1 do
    complete[#complete + 1] = parts[index]
  end
  return complete
end

function M.run(kind, command, opts)
  opts = opts or {}
  assert(kinds[kind] and not is_terminal_kind(kind), "run requires a log panel kind")
  assert(type(command) == "table" and #command > 0, "run requires an argv table")

  local old_job = M.bottom.jobs[kind]
  if job_is_running(old_job) then
    vim.notify(("[%s] A process is already running in this panel"):format(kinds[kind]), vim.log.levels.WARN)
    show(kind)
    return old_job
  end

  local buf = ensure_buffer(kind)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
  vim.bo[buf].modifiable = false
  show(kind)

  local output = {}
  local stdout_stream = { partial = "" }
  local stderr_stream = { partial = "" }

  local function receive(stream, data)
    local lines = consume_stream(stream, data)
    if #lines > 0 then
      vim.list_extend(output, lines)
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          append(kind, lines)
        end
      end)
    end
  end

  local job
  job = vim.fn.jobstart(command, {
    cwd = opts.cwd or project_root(),
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      receive(stdout_stream, data)
    end,
    on_stderr = function(_, data)
      receive(stderr_stream, data)
    end,
    on_exit = function(_, code)
      local trailing = {}
      if stdout_stream.partial ~= "" then
        trailing[#trailing + 1] = stdout_stream.partial
      end
      if stderr_stream.partial ~= "" then
        trailing[#trailing + 1] = stderr_stream.partial
      end
      vim.list_extend(output, trailing)

      vim.schedule(function()
        if M.bottom.jobs[kind] == job then
          M.bottom.jobs[kind] = nil
        end
        if vim.api.nvim_buf_is_valid(buf) then
          append(kind, trailing)
          append(kind, { "", ("Process exited with code %d"):format(code) })
        end

        if kind == "build" or kind == "tests" then
          vim.fn.setqflist({}, "r", {
            title = kinds[kind],
            lines = output,
            efm = vim.o.errorformat,
          })
          if code ~= 0 then
            vim.cmd("copen")
          end
        end

        if opts.on_exit then
          opts.on_exit(code)
        end
      end)
    end,
  })

  if job <= 0 then
    vim.notify(("[panels] Failed to start: %s"):format(command[1]), vim.log.levels.ERROR)
    return nil
  end

  M.bottom.jobs[kind] = job
  return job
end

-- Kept as a compatibility alias for older modules. Commands now run inside Neovim.
function M.external(kind, command, opts)
  return M.run(kind, command, opts)
end

function M.set_diagnostics()
  local items = vim.diagnostic.toqflist(vim.diagnostic.get())
  vim.fn.setqflist({}, "r", { title = "Diagnostics", items = items })
  vim.cmd("copen")
end

function M.setup()
  vim.api.nvim_create_user_command("IDEPanel", function(opts)
    M.open(opts.args)
  end, {
    nargs = 1,
    complete = function()
      return vim.tbl_keys(kinds)
    end,
    desc = "Open an IDE output panel",
    force = true,
  })

  vim.api.nvim_create_user_command("IDEPanelToggle", function()
    M.toggle()
  end, { desc = "Toggle the current IDE panel", force = true })

  vim.api.nvim_create_user_command("IDEPanelResize", function(opts)
    M.resize(tonumber(opts.args) or 0)
  end, { nargs = 1, desc = "Resize the IDE bottom panel", force = true })

  local map_opts = { desc = "IDE panel" }
  vim.keymap.set({ "n", "t" }, "<leader>tt", function()
    M.toggle("terminal")
  end, vim.tbl_extend("force", map_opts, { desc = "Terminal: Toggle persistent terminal" }))

  vim.keymap.set("n", "<leader>pp", function()
    M.toggle()
  end, { desc = "Panels: Toggle current output panel" })
  vim.keymap.set("n", "<leader>pb", function()
    M.open("build")
  end, { desc = "Panels: Build output" })
  vim.keymap.set("n", "<leader>pr", function()
    M.open("run")
  end, { desc = "Panels: Run output" })
  vim.keymap.set("n", "<leader>pt", function()
    M.open("tests")
  end, { desc = "Panels: Test output" })
  vim.keymap.set("n", "<leader>p+", function()
    M.resize(2)
  end, { desc = "Panels: Increase height" })
  vim.keymap.set("n", "<leader>p-", function()
    M.resize(-2)
  end, { desc = "Panels: Decrease height" })

  vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Terminal: Enter normal mode" })
  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Terminal: Focus left window" })
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Terminal: Focus lower window" })
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Terminal: Focus upper window" })
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Terminal: Focus right window" })
end

return M
