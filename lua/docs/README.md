# Neovim Engineering Workflow Update

This is a focused update for the existing Windows + Neovim + Lazy.nvim configuration. It keeps your `core.*` module layout and avoids adding any new plugin dependency.

## What changed

- Standardised leader-key groups: `f` find, `b` buffers, `w` windows, `t` terminal, `m` make/build, `g` Git, `d` diagnostics, `p` panels, `q` quickfix.
- Consolidated terminal ownership in `core.panels`. `core.terminal` is now a small compatibility layer so existing `require("core.terminal").setup()` calls continue to work.
- Build, run, tests and Git fallback output now run inside Neovim instead of spawning a separate PowerShell window.
- Added persistent `terminal` and `serial` terminal buffers and separate log panels for build, run, tests and Git. The persistent terminal retargets to the active project's root when invoked from a normal project buffer in another project.
- Build output is converted to the quickfix list. A failed build/test opens quickfix automatically.
- CMake projects are configured with `cmake -S . -B build` on first build, then built with `cmake --build build`.
- Standalone `.c` files use `gcc`/`clang`; C++ source files use `g++`/`clang++`.
- Serial-monitor fallback asks for a COM port and baud rate before launching pyserial.
- Git status/diff/log/blame use Fugitive when available and safe read-only Git CLI fallbacks otherwise.
- Removed the custom `errorformat` append and Windows `VimLeave !cls` command to avoid overriding Neovim's standard compiler parsing or unexpectedly clearing the host terminal.

## File layout

Copy these files into your existing Neovim config:

```text
%LOCALAPPDATA%\nvim\lua\core\options.lua
%LOCALAPPDATA%\nvim\lua\core\keymaps.lua
%LOCALAPPDATA%\nvim\lua\core\embedded.lua
%LOCALAPPDATA%\nvim\lua\core\git.lua
%LOCALAPPDATA%\nvim\lua\core\panels.lua
%LOCALAPPDATA%\nvim\lua\core\terminal.lua
%LOCALAPPDATA%\nvim\lua\core\diagnostics.lua
```

## Before installing

1. Close Neovim.
2. Back up your existing `lua\core` folder.
3. Extract this package. Copy the seven files from `lua\core` into your existing `lua\core` folder, replacing the matching files.
4. Keep your existing `init.lua`, Lazy.nvim plugin specs, LSP configuration and Telescope plugin file unchanged initially.

Example PowerShell backup:

```powershell
$nvim = "$env:LOCALAPPDATA\nvim"
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item "$nvim\lua\core" "$nvim\lua\core.backup-$stamp" -Recurse
```

Then copy the updated files from the extracted package:

```powershell
$source = Join-Path (Get-Location) 'lua\core'
$destination = "$env:LOCALAPPDATA\nvim\lua\core"
Copy-Item "$source\*.lua" $destination -Force
```

Run those commands from the extracted package directory.

## Important startup detail

Put these two lines at the very beginning of `init.lua`, before Lazy.nvim setup or any plugin configuration:

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "
```

They are also set in `core/keymaps.lua`, but setting them early ensures plugin keymaps see the correct leader.

## Telescope duplicate mapping check

The updated `core/keymaps.lua` leaves your file-search mappings in `plugins/telescope.lua`, exactly where your original configuration said they live. It adds `<Space>bb` as a buffer-picker shortcut. Check `:verbose nmap <Space>bb` if your Telescope file already defines it. Keep one mapping per shortcut; do not delete your Telescope plugin setup or fzf extension configuration.

## Plugin expectations

No new plugin is required for the updated Lua modules. Existing tools are detected when their commands are needed:

- `git` for Git commands
- `rg` for `:grep` and Telescope live-grep support
- `make` or `mingw32-make` for Makefile projects
- `cmake` for CMake projects
- `gcc`/`clang` for standalone C, `g++`/`clang++` for standalone C++
- `platformio` or `pio` for PlatformIO
- `idf.py` for ESP-IDF
- Python + `pyserial` for the generic serial monitor
- `arm-none-eabi-gdb` + `openocd` for the embedded-debugger tool check

For Fugitive's interactive Git status and split diff, keep `tpope/vim-fugitive` installed. Without it, Git status/diff/log/blame still have command-line output fallbacks.

## First launch and smoke tests

Open Neovim and run:

```vim
:checkhealth
:lua print(vim.fn.executable('git'))
:lua print(vim.fn.executable('gcc'))
:lua print(vim.fn.executable('make'))
:verbose nmap <Space>mb
:verbose nmap <Space>tt
:verbose nmap <Space>gs
```

Then test:

1. Run `:Telescope find_files` to verify the picker. Use the shortcut already defined in your `plugins/telescope.lua` for the same action.
2. `<Space>tt` opens the persistent terminal; press `<Esc><Esc>` to leave terminal input mode. Opening it from a source file in another project updates its working directory to that project's root.
3. `<Space>mb` runs the project build.
4. If the build fails, the quickfix list should open. Use `]q` and `[q` to move between parsed errors.
5. `<Space>gs` opens Fugitive status when installed, otherwise Git status output.
6. `<Space>gD` shows staged changes; `<Space>gd` shows unstaged changes (or Fugitive's working-tree split diff).

## Rollback

Close Neovim, then restore the backup folder you created before installation. The update does not edit `init.lua`, plugin specs, LSP files, or project files.

## Known scope limits

- The C/C++ one-file fallback is for simple single-translation-unit experiments. Real projects should use CMake or Makefiles so include paths, defines, source lists and link libraries are correct.
- `EmbeddedDebug` checks whether common tools exist; it does not create a target-specific OpenOCD/GDB launch configuration.
- Serial port defaults to `COM3` and `115200`; enter the correct values for your board.
- `compile_commands.json` should be generated by your CMake project for accurate clangd indexing.
