-- Git helpers. Fugitive integration is used when installed; read-only fallbacks
-- use the persistent Neovim output panel and the Git executable.
local M = {}
local panels = require("core.panels")

function M.root(buf)
  return vim.fs.root(buf or 0, { ".git" })
end

local function git_available()
  return vim.fn.executable("git") == 1
end

local function require_root()
  local root = M.root()
  if not root then
    vim.notify("[git] Current file is not inside a Git repository", vim.log.levels.ERROR)
  end
  return root
end

local function run_git(args)
  local root = require_root()
  if not root then
    return
  end
  if not git_available() then
    vim.notify("[git] Git is not available on PATH", vim.log.levels.ERROR)
    return
  end
  return panels.run("git", vim.list_extend({ "git" }, args), { cwd = root })
end

function M.status()
  if not require_root() then
    return
  end
  if vim.fn.exists(":Git") == 2 then
    vim.cmd("Git")
  else
    run_git({ "status", "--short", "--branch" })
  end
end

function M.diff(staged)
  if not require_root() then
    return
  end
  if not staged and vim.fn.exists(":Gdiffsplit") == 2 then
    vim.cmd("Gdiffsplit")
    return
  end
  return run_git(staged and { "diff", "--staged" } or { "diff" })
end

function M.log()
  return run_git({ "log", "--oneline", "--decorate", "--graph", "-20" })
end

function M.blame()
  local root = require_root()
  if not root then
    return
  end
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return vim.notify("[git] Save the current buffer before running blame", vim.log.levels.WARN)
  end
  if vim.fn.exists(":Git") == 2 then
    vim.cmd("Git blame")
    return
  end
  return run_git({ "blame", "--", file })
end

function M.setup()
  vim.keymap.set("n", "<leader>gs", M.status, { desc = "Git: Status" })
  vim.keymap.set("n", "<leader>gd", function()
    M.diff(false)
  end, { desc = "Git: Working-tree diff" })
  vim.keymap.set("n", "<leader>gD", function()
    M.diff(true)
  end, { desc = "Git: Staged diff" })
  vim.keymap.set("n", "<leader>gl", M.log, { desc = "Git: Recent history" })
  vim.keymap.set("n", "<leader>gb", M.blame, { desc = "Git: Blame current file" })
end

return M
