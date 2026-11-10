# Embedded Workflow Status

## Scope

This configuration is intended to make C/C++ firmware work comfortable on
Windows while supporting both STM32 and ESP32 projects. It provides editor
features and project-aware commands, but it does not bundle vendor toolchains or
program hardware by itself.

## Current workflow

From a project root, the following mappings are available:

| Mapping | Command | Detection order |
|---|---|---|
| `<leader>b` | `:EmbeddedBuild` | PlatformIO, ESP-IDF, CMake build directory, Make |
| `<leader>r` | `:EmbeddedRun` | Prompts for a built executable |
| `<leader>t` | `:EmbeddedTest` | CTest build directory, Make test target |
| `<leader>x` | Diagnostics panel | Current LSP diagnostics and quickfix navigation |
| `<C-\>` | Bottom terminal panel | Persistent terminal session |
| `<leader>q+` / `<leader>q-` | Resize bottom panel | Adjusts the docked panel height |
| `<leader>eb` | `:EmbeddedBuild` | PlatformIO, ESP-IDF, CMake build directory, Make |
| `<leader>ef` | `:EmbeddedFlash` | PlatformIO, ESP-IDF, `flash.cmd`, `flash.ps1`, `flash.bat` |
| `<leader>em` | `:EmbeddedMonitor` | PlatformIO monitor, ESP-IDF monitor, pyserial |
| `<leader>ed` | `:EmbeddedDebug` | PlatformIO or ARM GDB plus OpenOCD |

Commands report missing tools through `vim.notify`; they never pretend that a
flash or debug action succeeded.

The bottom panel keeps separate persistent buffers for Terminal, Build Output,
Run Output, Tests, Debug Console, and Diagnostics. Build, run, and test
commands open in a separate Windows Terminal tab when `wt.exe` is available;
the Neovim panel remains available through `:IDEPanel` for manually viewing
captured output or diagnostics.

`:IDEPanel` accepts one of `terminal`, `build`, `run`, `debug`, `tests`, or
`diagnostics`, for example `:IDEPanel build`. A Makefile is not required for a
standalone C/C++ file: open the source file and use `<leader>b`; the config
automatically uses `g++` or `clang++` and writes an executable beside the
source. `<leader>r` then runs that executable.

`<leader>E` toggles the built-in left-side Netrw explorer. `<leader>d` starts
or continues DAP, `<leader>dw` toggles the on-demand right debugger dock, and
`<leader>dt` adds a watch expression. The dock uses nvim-dap-ui's live scopes,
stacks, watches, breakpoints, and REPL elements.

## Toolchain requirements

### STM32

- ARM GNU Toolchain: `arm-none-eabi-gcc` and `arm-none-eabi-gdb`
- CMake or Make
- OpenOCD, ST-LINK GDB server, or J-Link tooling
- A project `compile_commands.json` for accurate `clangd` diagnostics

### ESP32

- ESP-IDF (`idf.py`) or PlatformIO
- CMake for ESP-IDF projects
- USB serial drivers and a serial monitor
- OpenOCD/GDB when hardware debugging is required

The current host has Neovim 0.11.6, LLVM `clang`/`clangd`, CMake, Make, Git,
`fd`, and Python with `pyserial` installed. ARM GCC/GDB, OpenOCD, ESP-IDF,
esptool, and PlatformIO still need to be installed separately when the
relevant board workflow is needed.

## Before and after

| Area | Before | After | Reason |
|---|---|---|---|
| Startup | Passed basic smoke test | Still passes with embedded commands registered | Confirms additions do not break startup |
| File explorer | `<leader>e` called `:Lexplore` while netrw plugin was disabled | `<leader>e` opens `:Explore`; `<leader>E` toggles `:Lexplore` | Restores a working built-in explorer without adding plugin bloat |
| Telescope files | Required missing `fd` executable | Uses `fd` when available, otherwise Git file listing | Keeps search usable on the current Windows host |
| Embedded commands | No project-aware build/flash/monitor/debug commands | Project-aware build, run, test, flash, monitor, and debug checks | Makes the common firmware loop discoverable |
| Output workflow | Build commands opened transient terminal windows | Persistent bottom panels with quickfix routing | Preserves sessions and enables source-error navigation |
| Tool installation | Configuration implied tools existed | Missing tools are reported explicitly | Avoids silent failures and unsafe automatic installs |
| Sensor visibility | No serial monitor entry point | PlatformIO, ESP-IDF, or pyserial monitor detection | Enables observing UART sensor responses when the project tool exists |
| Debugging | Desktop `cppdbg` only | Desktop setup retained plus embedded prerequisite checks | Avoids claiming hardware debugging before ARM/OpenOCD tools exist |
| Local Markdown links | 0 broken links found | 0 broken links found | No unnecessary documentation link churn |

## Limitations

Hardware-specific debugging still needs target configuration: MCU type,
interface (ST-Link/J-Link/USB-JTAG), ELF path, reset strategy, and GDB server
port. Those details belong in each firmware project rather than being guessed
globally by the Neovim configuration.

nvim-dap-ui provides live locals/scopes, call stacks (including thread frames),
watches, breakpoints, and a debugger REPL. Registers and memory views are
adapter-specific and are not fabricated when the active DAP adapter does not
expose those capabilities.

## Git and diagnostics

Use `<leader>gf` for tracked Git files and `<leader>gs` for Fugitive status.
Use `<leader>ld` or `:DiagnosticsReport` to see the current project root, LSP
clients, buffer diagnostics, and whether `compile_commands.json` is missing.
