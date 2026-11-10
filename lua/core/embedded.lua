local M = {}
local panels = require("core.panels")

local function notify(message, level)
	vim.notify("[embedded] " .. message, level or vim.log.levels.INFO)
end

local function root()
	local markers = { ".git", "platformio.ini", "CMakeLists.txt", "Makefile", "sdkconfig" }
	local found = vim.fs.find(markers, { upward = true, path = vim.api.nvim_buf_get_name(0) })[1]
	return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

local function current_source()
	local file = vim.api.nvim_buf_get_name(0)
	if file:match("%.c$") or file:match("%.cc$") or file:match("%.cpp$") or file:match("%.cxx$") then
		return file
	end
end

local function has(path, name)
	return vim.fn.executable(path or name) == 1
end

local function run(command, kind)
	local cwd = root()
	local command_name = type(command) == "table" and command[1] or command
	if not has(nil, command_name) then
		notify(("'%s' is not available on PATH"):format(command_name), vim.log.levels.ERROR)
		return
	end

	notify(("running %s in %s"):format(table.concat(command, " "), cwd))
	panels.external(kind or "build", command)
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
		return run({ "platformio", "run" }, "build")
	end
	if vim.fn.filereadable(cwd .. "/sdkconfig") == 1 and has(nil, "idf.py") then
		return run({ "idf.py", "build" }, "build")
	end
	if vim.fn.isdirectory(cwd .. "/build") == 1 and has(nil, "cmake") then
		return run({ "cmake", "--build", "build" }, "build")
	end
	if vim.fn.filereadable(cwd .. "/Makefile") == 1 and has(nil, "make") then
		return run({ "make" }, "build")
	end
	local source = current_source()
	local compiler = has(nil, "g++") and "g++" or (has(nil, "clang++") and "clang++" or nil)
	if source and compiler then
		local output = vim.fs.joinpath(cwd, vim.fn.fnamemodify(source, ":t:r") .. (vim.fn.has("win32") == 1 and ".exe" or ""))
		return run({ compiler, "-std=c++17", "-Wall", "-Wextra", source, "-o", output }, "build")
	end
	notify("no supported build project found; use a Makefile/CMake project or open a C/C++ source file with g++/clang++ available", vim.log.levels.ERROR)
end

function M.flash()
	local cwd = root()
	if vim.fn.filereadable(cwd .. "/platformio.ini") == 1 and has(nil, "platformio") then
		return run({ "platformio", "run", "--target", "upload" }, "run")
	end

	if vim.fn.filereadable(cwd .. "/sdkconfig") == 1 and has(nil, "idf.py") then
		return run({ "idf.py", "flash" }, "run")
	end
	for _, script in ipairs({ "flash.cmd", "flash.ps1", "flash.bat" }) do
		if vim.fn.filereadable(cwd .. "/" .. script) == 1 then
			return run(vim.fn.has("win32") == 1 and { "cmd", "/c", script } or { "sh", script }, "run")
		end
	end
	notify("no flash command found; add a project flash script or install PlatformIO/ESP-IDF", vim.log.levels.ERROR)
end

function M.run()
	local source = current_source()
	local default = source and vim.fs.joinpath(root(), vim.fn.fnamemodify(source, ":t:r") .. (vim.fn.has("win32") == 1 and ".exe" or "")) or root() .. "/build/"
	local executable = vim.fn.input("Executable: ", default, "file")
	if executable == "" then
		return
	end
	if vim.fn.filereadable(executable) == 0 then
		notify("executable does not exist: " .. executable, vim.log.levels.ERROR)
		return
	end
	panels.external("run", { executable })
end

function M.test()
	local cwd = root()
	if vim.fn.isdirectory(cwd .. "/build") == 1 and has(nil, "ctest") then
		return run({ "ctest", "--test-dir", "build", "--output-on-failure" }, "tests")
	end
	if vim.fn.filereadable(cwd .. "/Makefile") == 1 and has(nil, "make") then
		return run({ "make", "test" }, "tests")
	end
	notify("no CTest build directory or Makefile test target found", vim.log.levels.ERROR)
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

function M.setup()
	panels.setup()
	vim.api.nvim_create_user_command("EmbeddedBuild", M.build, { desc = "Build the current embedded project" })
	vim.api.nvim_create_user_command("EmbeddedFlash", M.flash, { desc = "Flash the current embedded project" })
	vim.api.nvim_create_user_command("EmbeddedRun", M.run, { desc = "Run a built project executable" })
	vim.api.nvim_create_user_command("EmbeddedTest", M.test, { desc = "Run project tests" })
	vim.api.nvim_create_user_command("EmbeddedMonitor", M.monitor, { desc = "Open the embedded serial monitor" })
	vim.api.nvim_create_user_command("EmbeddedDebug", M.debug, { desc = "Check embedded debugging support" })
end

return M
