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
| `<Space>sl` | Find only files under the Neovim `lua/` directory |
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

The Git picker includes a preview window. Select a file in `<Space>gf` to
inspect it before opening.

## Git workflow

| Key | Use |
|---|---|
| `<Space>gs` | Fugitive Git status |
| `<Space>gd` | Diff current file |
| `<Space>gl` | Git log |
| `<Space>gb` | Git blame |
| `<Space>gB` | Branch list with upstream tracking |
| `<Space>gp` | Git status/pipeline view |
| `<Space>hs` | Stage hunk |
| `<Space>hr` | Reset hunk |
| `<Space>hp` | Preview hunk |

Fugitive opens its status buffer. In that buffer, press `?` to see available
actions.

The statusline shows the current branch. Use `<Space>gB` to inspect local and
remote branch tracking, and `<Space>gp` to inspect staged, unstaged, and
untracked changes. CI pipeline results are provided by the repository host;
from the project root, use `gh run list` in the terminal when GitHub Actions
checks are needed.

## Language server workflow

The active language servers are preserved for:

| Filetype | Server |
|---|---|
| C/C++ | `clangd` |
| Python | `pyright` |
| Rust | `rust_analyzer` |
| Java | `jdtls` |
| Bash (`sh`) | `bashls` |
| Lua/Neovim config | `lua_ls` |

Use `:LspInfo` to see which server is attached to the current buffer. Mason
installs configured servers with `:Mason`; it does not hide servers that are
not currently attached.

## Diagnostics workflow

1. Open a real `.c` or `.cpp` file inside the firmware project.
2. Ensure the project has `compile_commands.json`.
3. Run `:LspInfo`.
4. Run `:DiagnosticsReport` or press `<Space>ld`.
5. Use `[d` and `]d` to move between diagnostics.
6. Press `<Space>xx` for the full diagnostics list.
7. Press `<Space>xX` for the current-buffer diagnostics list.
8. Press `K` on a symbol for hover information.

If no LSP client attaches, check that `clangd` is installed and that the file
belongs to the intended project root.

## Embedded workflow

| Key | Use |
|---|---|
| `<Space>eb` | Build |
| `<Space>ef` | Flash |
| `<Space>em` | Serial monitor |
| `<Space>ed` | Check debugger prerequisites |

The commands detect PlatformIO, ESP-IDF, CMake, Make, and serial tools. They
report missing tools instead of pretending that hardware actions succeeded.

## Debugging workflow

| Key | Use |
|---|---|
| `<F5>` | Start or continue |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<Space>b` | Toggle breakpoint |
| `<Space>B` | Set a conditional breakpoint |
| `<F7>` | Toggle debugger UI |

Desktop C/C++ debugging is configured to use Mason's `cppdbg` adapter
(`OpenDebugAD7`).
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
