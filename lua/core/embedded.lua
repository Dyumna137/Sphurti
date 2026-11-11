-- Project-aware build, run, test and embedded-device commands.
local M = {}
local panels = require("core.panels")

local ROOT_MARKERS = {
  ".git", "platformio.ini", "CMakeLists.txt", "Makefile", "sdkconfig",
}

local function notify(message, level)
  vim.notify("[embedded] " .. message, level or vim.log.levels.INFO)
end

local function root()
  return vim.fs.root(0, ROOT_MARKERS) or vim.fn.getcwd()
end

local function has(command)
  return vim.fn.executable(command) == 1
end

local function file_exists(path)
  return vim.fn.filereadable(path) == 1
end

local function is_dir(path)
  return vim.fn.isdirectory(path) == 1
end

local function current_source()
  local file = vim.api.nvim_buf_get_name(0)
  local extension = file:match("%.([^.]+)$")
  if extension and ({ c = true, cc = true, cpp = true, cxx = true })[extension:lower()] then
    return file, extension:lower()
  end
  return nil, nil
end

local function run(command, kind, opts)
  local cwd = root()
  local executable = command[1]
  if not has(executable) then
    notify(("'%s' is not available on PATH"):format(executable), vim.log.levels.ERROR)
    return
  end
  notify(("Running %s"):format(table.concat(command, " ")))
  return panels.run(kind or "build", command, vim.tbl_extend("force", { cwd = cwd }, opts or {}))
end

local function cmake_build(cwd)
  if not has("cmake") then
    return notify("'cmake' is not available on PATH", vim.log.levels.ERROR)
  end

  local build_dir = vim.fs.joinpath(cwd, "build")
  local cache = vim.fs.joinpath(build_dir, "CMakeCache.txt")
  if not is_dir(build_dir) or not file_exists(cache) then
    return panels.run("build", { "cmake", "-S", ".", "-B", "build" }, {
      cwd = cwd,
      on_exit = function(code)
        if code == 0 then
          panels.run("build", { "cmake", "--build", "build" }, { cwd = cwd })
        end
      end,
    })
  end
  return run({ "cmake", "--build", "build" }, "build")
end

local function standalone_build(cwd)
  local source, extension = current_source()
  if not source then
    return notify("No C/C++ source file is open and no project build system was found", vim.log.levels.ERROR)
  end

  local is_c = extension == "c"
  local candidates = is_c and { "gcc", "clang" } or { "g++", "clang++" }
  local compiler
  for _, candidate in ipairs(candidates) do
    if has(candidate) then
      compiler = candidate
      break
    end
  end
  if not compiler then
    return notify(("No compiler found. Install one of: %s"):format(table.concat(candidates, ", ")), vim.log.levels.ERROR)
  end

  local build_dir = vim.fs.joinpath(cwd, "build")
  vim.fn.mkdir(build_dir, "p")
  local output_name = vim.fn.fnamemodify(source, ":t:r") .. (vim.fn.has("win32") == 1 and ".exe" or "")
  local output = vim.fs.joinpath(build_dir, output_name)
  local standard = is_c and "c11" or "c++17"
  return run({ compiler, "-std=" .. standard, "-Wall", "-Wextra", source, "-o", output }, "build")
end

function M.build()
  local cwd = root()
  if file_exists(vim.fs.joinpath(cwd, "platformio.ini")) then
    if not has("platformio") and not has("pio") then
      return notify("Install PlatformIO CLI (platformio or pio)", vim.log.levels.ERROR)
    end
    return run({ has("platformio") and "platformio" or "pio", "run" }, "build")
  end

  if file_exists(vim.fs.joinpath(cwd, "sdkconfig")) then
    return run({ "idf.py", "build" }, "build")
  end

  if file_exists(vim.fs.joinpath(cwd, "CMakeLists.txt")) then
    return cmake_build(cwd)
  end

  if file_exists(vim.fs.joinpath(cwd, "Makefile")) then
    return run({ has("make") and "make" or "mingw32-make" }, "build")
  end

  return standalone_build(cwd)
end

function M.flash()
  local cwd = root()
  if file_exists(vim.fs.joinpath(cwd, "platformio.ini")) then
    local cli = has("platformio") and "platformio" or (has("pio") and "pio" or nil)
    if not cli then
      return notify("PlatformIO CLI is not available on PATH", vim.log.levels.ERROR)
    end
    return run({ cli, "run", "--target", "upload" }, "run")
  end

  if file_exists(vim.fs.joinpath(cwd, "sdkconfig")) then
    return run({ "idf.py", "flash" }, "run")
  end

  for _, script in ipairs({ "flash.cmd", "flash.bat", "flash.ps1" }) do
    local path = vim.fs.joinpath(cwd, script)
    if file_exists(path) then
      if script:match("%.ps1$") then
        local shell = has("pwsh") and "pwsh" or (has("powershell") and "powershell" or nil)
        if not shell then
          return notify("PowerShell was not found to run flash.ps1", vim.log.levels.ERROR)
        end
        return run({ shell, "-NoProfile", "-File", path }, "run")
      end
      local shell = vim.fn.has("win32") == 1 and "cmd.exe" or "sh"
      local command = vim.fn.has("win32") == 1 and { shell, "/c", path } or { shell, path }
      return run(command, "run")
    end
  end

  notify("No flash action found. Add a project flash script or configure PlatformIO/ESP-IDF.", vim.log.levels.ERROR)
end

function M.run()
  local cwd = root()
  local source = current_source()
  local default = vim.fs.joinpath(cwd, "build")
  if source then
    default = vim.fs.joinpath(default, vim.fn.fnamemodify(source, ":t:r") .. (vim.fn.has("win32") == 1 and ".exe" or ""))
  end

  local executable = vim.fn.input("Executable path: ", default, "file")
  if executable == "" then
    return
  end
  if not file_exists(executable) then
    return notify("Executable does not exist: " .. executable, vim.log.levels.ERROR)
  end
  return run({ executable }, "run")
end

function M.test()
  local cwd = root()
  if file_exists(vim.fs.joinpath(cwd, "CMakeLists.txt")) and is_dir(vim.fs.joinpath(cwd, "build")) and has("ctest") then
    return run({ "ctest", "--test-dir", "build", "--output-on-failure" }, "tests")
  end

  if file_exists(vim.fs.joinpath(cwd, "Makefile")) then
    local make = has("make") and "make" or (has("mingw32-make") and "mingw32-make" or nil)
    if make then
      return run({ make, "test" }, "tests")
    end
  end

  notify("No CTest build or Makefile test target was detected", vim.log.levels.ERROR)
end

function M.monitor()
  local cwd = root()
  if file_exists(vim.fs.joinpath(cwd, "platformio.ini")) then
    local cli = has("platformio") and "platformio" or (has("pio") and "pio" or nil)
    if not cli then
      return notify("PlatformIO CLI is not available on PATH", vim.log.levels.ERROR)
    end
    return panels.termrun("serial", { cli, "device", "monitor" }, { cwd = cwd })
  end

  if file_exists(vim.fs.joinpath(cwd, "sdkconfig")) then
    if not has("idf.py") then
      return notify("ESP-IDF command 'idf.py' is not available on PATH", vim.log.levels.ERROR)
    end
    return panels.termrun("serial", { "idf.py", "monitor" }, { cwd = cwd })
  end

  if not has("python") then
    return notify("Install Python and pyserial, or use PlatformIO/ESP-IDF", vim.log.levels.ERROR)
  end

  local port = vim.fn.input("Serial port (e.g. COM5): ", "COM3")
  if port == "" then
    return
  end
  local baud = vim.fn.input("Baud rate: ", "115200")
  if baud == "" or not tonumber(baud) then
    return notify("Invalid baud rate", vim.log.levels.ERROR)
  end
  return panels.termrun("serial", { "python", "-m", "serial.tools.miniterm", port, baud }, { cwd = cwd })
end

function M.debug()
  if has("arm-none-eabi-gdb") and has("openocd") then
    notify("ARM GDB and OpenOCD are available. A target-specific launch configuration is still required.")
    return
  end
  if has("gdb") and has("openocd") then
    notify("GDB and OpenOCD are available. Configure target, interface and adapter speed for this board.")
    return
  end
  notify("Debugging tools not detected. Check GDB, OpenOCD and your target-specific configuration.", vim.log.levels.WARN)
end

function M.setup()
  panels.setup()
  local commands = {
    EmbeddedBuild = { M.build, "Build the current project" },
    EmbeddedFlash = { M.flash, "Flash the connected target" },
    EmbeddedRun = { M.run, "Run a built executable" },
    EmbeddedTest = { M.test, "Run project tests" },
    EmbeddedMonitor = { M.monitor, "Open the serial monitor" },
    EmbeddedDebug = { M.debug, "Check embedded debugging tools" },
  }
  for name, definition in pairs(commands) do
    vim.api.nvim_create_user_command(name, definition[1], { desc = definition[2], force = true })
  end
end

return M
