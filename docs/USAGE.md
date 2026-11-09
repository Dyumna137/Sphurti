# Sphurti Neovim Usage Guide

## Start in the right place

Open Neovim from the firmware project root:

```powershell
cd C:\path\to\firmware-project
nvim
```

This makes file search, Git, clangd, build commands, and embedded commands use
the expected project.

## Finding files

| Key | Use |
|---|---|
| `<Space>sf` | Find files in the current project directory |
| `<Space>gf` | Find tracked Git files in the current repository |
| `<Space>sn` | Find files in this Neovim configuration |
| `<Space>/` | Search inside the current file |
| `<Space>sg` | Search text across the project |
| `<Space>e` | Open the file explorer |

For this configuration, these files should be visible:

```text
<Space>sn → type git.lua
<Space>sn → type gitsigns.lua
```

Use `<Space>gf` when you want only tracked files. Use `<Space>sf` when you
also need untracked files.

## Git workflow

| Key | Use |
|---|---|
| `<Space>gs` | Fugitive Git status |
| `<Space>gd` | Diff current file |
| `<Space>gl` | Git log |
| `<Space>gb` | Git blame |
| `<Space>hs` | Stage hunk |
| `<Space>hr` | Reset hunk |
| `<Space>hp` | Preview hunk |

Fugitive opens its status buffer. In that buffer, press `?` to see available
actions.

## Diagnostics workflow

1. Open a real `.c` or `.cpp` file inside the firmware project.
2. Ensure the project has `compile_commands.json`.
3. Run `:LspInfo`.
4. Run `:DiagnosticsReport` or press `<Space>ld`.
5. Use `[d` and `]d` to move between diagnostics.
6. Press `<Space>xx` for the full diagnostics list.
7. Press `K` on a symbol for hover information.

If no LSP client attaches, check that `clangd` is installed and that the file
belongs to the intended project root.

## Embedded workflow

| Key | Use |
|---|---|
| `<Space>eb` | Build |
| `<Space>ef` | Flash |
| `<Space>em` | Serial monitor |
| `<Space>ed` | Check debugger prerequisites |
| `<Space>et` | Show tool paths |

The commands detect PlatformIO, ESP-IDF, CMake, Make, and serial tools. They
report missing tools instead of pretending that hardware actions succeeded.

## Debugging workflow

| Key | Use |
|---|---|
| `<F5>` | Start or continue |
| `<F9>` | Toggle breakpoint |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<F7>` | Toggle debugger UI |

Desktop C/C++ debugging requires Mason `cpptools`/`OpenDebugAD7`.
STM32 debugging additionally requires ARM GDB, OpenOCD, and a connected
ST-Link/J-Link. ESP32 debugging requires PlatformIO or ESP-IDF plus the board's
USB/JTAG drivers.

## Fast diagnosis checklist

Run these in Neovim:

```vim
:checkhealth
:Lazy
:Mason
:LspInfo
:DiagnosticsReport
:EmbeddedToolReport
```

Run these in PowerShell:

```powershell
git status
Get-Command git,clangd,clang-format,platformio
nvim --headless -u init.lua -l tests/smoke.lua
```

If a file is not found:

1. Check the current directory with `:pwd`.
2. Use `<Space>sn` for Neovim configuration files.
3. Use `<Space>sf` for all project files.
4. Use `<Space>gf` only for tracked files.
5. Confirm the file with `git ls-files lua/core/git.lua`.
