local M = {}

local function extend_path()
	local candidates = {
		vim.fn.expand("$APPDATA") .. "/Python/Python313/Scripts",
		vim.fn.expand("$USERPROFILE") .. "/.platformio/packages/toolchain-gccarmnoneeabi/bin",
		vim.fn.expand("$LOCALAPPDATA") .. "/Microsoft/WinGet/Packages/xpack-dev-tools.openocd-xpack_Microsoft.Winget.Source_8wekyb3d8bbwe/xpack-openocd-0.12.0-7/bin",
	}
	local path = vim.env.PATH or ""
	for _, directory in ipairs(candidates) do
		if vim.fn.isdirectory(directory) == 1 and not path:find(vim.pesc(directory), 1, true) then
			path = directory .. ";" .. path
		end
	end
	vim.env.PATH = path
end

local function notify(message, level)
	vim.notify("[embedded] " .. message, level or vim.log.levels.INFO)
end

local function root()
	local markers = { ".git", "platformio.ini", "CMakeLists.txt", "Makefile", "sdkconfig" }
	local found = vim.fs.find(markers, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1]
	return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

local function has(path, name)
	return vim.fn.executable(path or name) == 1
end

local function run(command, opts)
	opts = opts or {}
	local cwd = root()
	local command_name = type(command) == "table" and command[1] or command
	if not has(nil, command_name) then
		notify(("'%s' is not available on PATH"):format(command_name), vim.log.levels.ERROR)
		return
	end

	notify(("running %s in %s"):format(table.concat(command, " "), cwd))
	vim.fn.jobstart(command, {
		cwd = cwd,
		term = opts.term,
		on_exit = function(_, code)
			if code == 0 then
				notify(("completed: %s"):format(command_name))
			else
				notify(("%s exited with code %d"):format(command_name, code), vim.log.levels.ERROR)
			end
		end,
	})
end

local function terminal(command)
	local cwd = root()
	vim.cmd("botright split")
	vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.3))
	vim.fn.termopen(command, {
		cwd = cwd,
		on_exit = function(_, code)
			if code ~= 0 then
				notify(("monitor exited with code %d"):format(code), vim.log.levels.WARN)
			end
		end,
	})
	vim.cmd("startinsert")
end

function M.build()
	local cwd = root()
	if vim.fn.filereadable(cwd .. "/platformio.ini") == 1 and has(nil, "platformio") then
		return run({ "platformio", "run" }, { term = true })
	end
	if vim.fn.filereadable(cwd .. "/sdkconfig") == 1 and has(nil, "idf.py") then
		return run({ "idf.py", "build" }, { term = true })
	end
	if vim.fn.isdirectory(cwd .. "/build") == 1 and has(nil, "cmake") then
		return run({ "cmake", "--build", "build" }, { term = true })
	end
	if vim.fn.filereadable(cwd .. "/Makefile") == 1 and has(nil, "make") then
		return run({ "make" }, { term = true })
	end
	notify("no supported build project or tool found (PlatformIO, ESP-IDF, CMake, or Make)", vim.log.levels.ERROR)
end

function M.flash()
	local cwd = root()
	if vim.fn.filereadable(cwd .. "/platformio.ini") == 1 and has(nil, "platformio") then
		return run({ "platformio", "run", "--target", "upload" }, { term = true })
	end
	if vim.fn.filereadable(cwd .. "/sdkconfig") == 1 and has(nil, "idf.py") then
		return run({ "idf.py", "flash" }, { term = true })
	end
	for _, script in ipairs({ "flash.cmd", "flash.ps1", "flash.bat" }) do
		if vim.fn.filereadable(cwd .. "/" .. script) == 1 then
			return run(vim.fn.has("win32") == 1 and { "cmd", "/c", script } or { "sh", script }, { term = true })
		end
	end
	notify("no flash command found; add a project flash script or install PlatformIO/ESP-IDF", vim.log.levels.ERROR)
end

function M.monitor()
	local cwd = root()
	if vim.fn.filereadable(cwd .. "/platformio.ini") == 1 and has(nil, "platformio") then
		return terminal({ "platformio", "device", "monitor" })
	end
	if vim.fn.filereadable(cwd .. "/sdkconfig") == 1 and has(nil, "idf.py") then
		return terminal({ "idf.py", "monitor" })
	end
	if has(nil, "python") then
		return terminal({ "python", "-m", "serial.tools.miniterm" })
	end
	notify("no serial monitor found; install PlatformIO, ESP-IDF, or pyserial", vim.log.levels.ERROR)
end

function M.debug()
	local cwd = root()
	if vim.fn.filereadable(cwd .. "/platformio.ini") == 1 and has(nil, "platformio") then
		notify("PlatformIO detected; use its project debug configuration or :EmbeddedMonitor", vim.log.levels.INFO)
		return
	end
	if has(nil, "arm-none-eabi-gdb") and has(nil, "openocd") then
		notify("ARM GDB and OpenOCD detected; configure target-specific DAP settings in the project", vim.log.levels.INFO)
		return
	end
	notify("embedded debugging requires arm-none-eabi-gdb + OpenOCD, or PlatformIO/ESP-IDF", vim.log.levels.ERROR)
end

function M.report()
	extend_path()
	local tools = { "platformio", "pio", "arm-none-eabi-gdb", "openocd" }
	local lines = { "Embedded tool availability:" }
	for _, tool in ipairs(tools) do
		local path = vim.fn.exepath(tool)
		table.insert(lines, ("%s: %s"):format(tool, path ~= "" and path or "missing"))
	end
	notify(table.concat(lines, "\n"))
end

function M.setup()
	extend_path()
	vim.api.nvim_create_user_command("EmbeddedBuild", M.build, { desc = "Build the current embedded project" })
	vim.api.nvim_create_user_command("EmbeddedFlash", M.flash, { desc = "Flash the current embedded project" })
	vim.api.nvim_create_user_command("EmbeddedMonitor", M.monitor, { desc = "Open the embedded serial monitor" })
	vim.api.nvim_create_user_command("EmbeddedDebug", M.debug, { desc = "Check embedded debugging support" })
	vim.api.nvim_create_user_command("EmbeddedToolReport", M.report, { desc = "Report embedded tool paths" })
end

return M
