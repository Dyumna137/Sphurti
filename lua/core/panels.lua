local M = {
	bottom = {
		height = 12,
		kind = "terminal",
		win = nil,
		bufs = {},
		jobs = {},
	},
}

local kinds = {
	terminal = "Terminal",
	build = "Build Output",
	run = "Run Output",
	debug = "Debug Console",
	tests = "Tests",
	diagnostics = "Diagnostics",
}

local function project_root()
	return vim.fs.root(0, { ".git", "CMakeLists.txt", "Makefile", "platformio.ini", "sdkconfig" }) or vim.fn.getcwd()
end

local function valid_window()
	return M.bottom.win and vim.api.nvim_win_is_valid(M.bottom.win)
end

local function ensure_buffer(kind)
	local buf = M.bottom.bufs[kind]
	if buf and vim.api.nvim_buf_is_valid(buf) then
		return buf
	end

	buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "hide"
	vim.bo[buf].filetype = kind == "terminal" and "terminal" or "log"
	vim.api.nvim_buf_set_name(buf, "[IDE] " .. kinds[kind])
	M.bottom.bufs[kind] = buf
	return buf
end

local function show(kind)
	M.bottom.kind = kind
	local buf = ensure_buffer(kind)
	if not valid_window() then
		vim.cmd("botright split")
		M.bottom.win = vim.api.nvim_get_current_win()
		vim.api.nvim_win_set_height(M.bottom.win, M.bottom.height)
	end
	vim.api.nvim_win_set_buf(M.bottom.win, buf)
	vim.api.nvim_set_current_win(M.bottom.win)
	if kind == "terminal" then
		vim.cmd("startinsert")
	end
end

local function append(kind, lines)
	local buf = ensure_buffer(kind)
	if type(lines) == "string" then
		lines = vim.split(lines, "\n", { plain = true })
	end
	if #lines == 0 then
		return
	end
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
	vim.bo[buf].modifiable = false
	if valid_window() and vim.api.nvim_win_get_buf(M.bottom.win) == buf then
		vim.api.nvim_win_set_cursor(M.bottom.win, { vim.api.nvim_buf_line_count(buf), 0 })
	end
end

function M.open(kind)
	assert(kinds[kind], "unknown IDE panel: " .. tostring(kind))
	show(kind)
end

function M.toggle(kind)
	kind = kind or M.bottom.kind
	if valid_window() then
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
	if valid_window() then
		M.bottom.height = math.max(5, M.bottom.height + delta)
		vim.api.nvim_win_set_height(M.bottom.win, M.bottom.height)
	end
end

function M.terminal()
	local buf = ensure_buffer("terminal")
	if vim.bo[buf].channel == 0 then
		vim.api.nvim_buf_call(buf, function()
			vim.fn.termopen(vim.o.shell, {
				cwd = project_root(),
				on_exit = function()
					if vim.api.nvim_buf_is_valid(buf) then
						vim.bo[buf].modified = false
					end
				end,
			})
		end)
	end
	show("terminal")
end

function M.external(kind, command)
	local cwd = project_root()
	if vim.fn.executable("pwsh.exe") == 1 then
		local script = vim.fn.tempname() .. ".ps1"
		local command_text = table.concat(vim.tbl_map(function(value)
			return vim.fn.shellescape(value)
		end, command), " ")
		vim.fn.writefile({
			"Set-Location -LiteralPath " .. vim.fn.shellescape(cwd),
			"& " .. command_text,
			"$exitCode = $LASTEXITCODE",
			"Write-Host ('Process exited with code ' + $exitCode)",
			"Read-Host 'Press Enter to close'",
			"Remove-Item -LiteralPath $PSCommandPath -Force",
			"exit $exitCode",
		}, script)
		return vim.fn.jobstart({
			"cmd.exe",
			"/c",
			"start",
			"",
			"pwsh.exe",
			"-NoLogo",
			"-NoExit",
			"-File",
			script,
		})
	end

	vim.notify("[embedded] Windows Terminal and PowerShell were not found; using the Neovim output panel", vim.log.levels.WARN)
	return M.run(kind, command)
end

function M.run(kind, command)
	assert(kinds[kind], "unknown IDE panel: " .. tostring(kind))
	local buf = ensure_buffer(kind)
	vim.bo[buf].modifiable = true
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
	vim.bo[buf].modifiable = false
	show(kind)
	local output = {}
	local job = vim.fn.jobstart(command, {
		cwd = project_root(),
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = function(_, data)
			vim.list_extend(output, data)
			vim.schedule(function()
				append(kind, data)
			end)
		end,
		on_stderr = function(_, data)
			vim.list_extend(output, data)
			vim.schedule(function()
				append(kind, data)
			end)
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				if kind == "build" or kind == "tests" then
					vim.fn.setqflist({}, "r", {
						title = kinds[kind],
						lines = output,
					})
				end

				append(kind, { "", ("Process exited with code %d"):format(code) })
			end)
		end,
	})
	M.bottom.jobs[kind] = job
	return job
end

function M.set_diagnostics()
	local items = vim.diagnostic.toqflist(vim.diagnostic.get())
	vim.fn.setqflist({}, "r", { title = "Diagnostics", items = items })
	M.open("diagnostics")
end

function M.setup()
	vim.api.nvim_create_user_command("IDEPanel", function(opts)
		M.open(opts.args)
	end, { nargs = 1, complete = function()
		return vim.tbl_keys(kinds)
	end, desc = "Open an IDE output panel" })
	vim.api.nvim_create_user_command("IDEPanelToggle", function()
		M.toggle()
	end, { desc = "Toggle the persistent IDE bottom panel" })
	vim.api.nvim_create_user_command("IDEPanelResize", function(opts)
		M.resize(tonumber(opts.args) or 0)
	end, { nargs = 1, desc = "Resize the IDE bottom panel" })
	vim.keymap.set({ "n", "t" }, "<C-\\>", function()
		M.toggle("terminal")
	end, { desc = "IDE: Toggle bottom panel" })
	vim.keymap.set("n", "<leader>q", function()
		if valid_window() then
			M.toggle()
		else
			vim.cmd("close")
		end
	end, { desc = "IDE: Close current panel" })
	vim.keymap.set("n", "<leader>q+", function()
		M.resize(2)
	end, { desc = "IDE: Increase bottom panel height" })
	vim.keymap.set("n", "<leader>q-", function()
		M.resize(-2)
	end, { desc = "IDE: Decrease bottom panel height" })
end

return M
