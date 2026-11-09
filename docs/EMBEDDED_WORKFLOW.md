# Embedded Workflow Status

## Scope

This configuration is intended to make C/C++ firmware work comfortable on
Windows while supporting both STM32 and ESP32 projects. It provides editor
features and project-aware commands, but it does not bundle vendor toolchains or
program hardware by itself.

## Current workflow

For a project-local PowerShell environment, dot-source
[EMBEDDED_ENVIRONMENT.md](EMBEDDED_ENVIRONMENT.md) before launching Neovim.
It exposes PlatformIO, ARM GDB, and OpenOCD for that terminal without
installing or changing tools from inside Neovim.

From a project root, the following mappings are available:

| Mapping | Command | Detection order |
|---|---|---|
| `<leader>eb` | `:EmbeddedBuild` | PlatformIO, ESP-IDF, CMake build directory, Make |
| `<leader>ef` | `:EmbeddedFlash` | PlatformIO, ESP-IDF, `flash.cmd`, `flash.ps1`, `flash.bat` |
| `<leader>em` | `:EmbeddedMonitor` | PlatformIO monitor, ESP-IDF monitor, pyserial |
| `<leader>ed` | `:EmbeddedDebug` | PlatformIO or ARM GDB plus OpenOCD |

Commands report missing tools through `vim.notify`; they never pretend that a
flash or debug action succeeded.

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
| Embedded commands | No project-aware build/flash/monitor/debug commands | Four commands and four mappings | Makes the common firmware loop discoverable |
| Tool installation | Configuration implied tools existed | Missing tools are reported explicitly | Avoids silent failures and unsafe automatic installs |
| Sensor visibility | No serial monitor entry point | PlatformIO, ESP-IDF, or pyserial monitor detection | Enables observing UART sensor responses when the project tool exists |
| Debugging | Desktop `cppdbg` only | Desktop setup retained plus embedded prerequisite checks | Avoids claiming hardware debugging before ARM/OpenOCD tools exist |
| Local Markdown links | 0 broken links found | 0 broken links found | No unnecessary documentation link churn |

## Limitations

Hardware-specific debugging still needs target configuration: MCU type,
interface (ST-Link/J-Link/USB-JTAG), ELF path, reset strategy, and GDB server
port. Those details belong in each firmware project rather than being guessed
globally by the Neovim configuration.

## Git and diagnostics

Use `<leader>gf` for tracked Git files and `<leader>gs` for Fugitive status.
Use `<leader>ld` or `:DiagnosticsReport` to see the current project root, LSP
clients, buffer diagnostics, and whether `compile_commands.json` is missing.
