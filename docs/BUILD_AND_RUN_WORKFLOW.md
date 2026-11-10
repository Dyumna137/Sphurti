# Build and Run Workflow

This guide explains how the Neovim configuration builds and runs a C++ file on
Windows.

## Quick start: one C++ file

Open a source file:

```powershell
nvim C:\work\hello\main.cpp
```

Inside Neovim:

1. Press `Space b`.
2. The configuration detects `g++` or `clang++`.
3. It runs a command equivalent to:

   ```text
   clang++ -std=c++17 -Wall -Wextra main.cpp -o main.exe
   ```

4. The executable is created beside the source file.
5. Press `Space r`.
6. Select or accept the generated executable path.

No Makefile is required for this fallback.

## Where output appears

- `Space b`: opens a separate PowerShell/Windows Terminal window.
- `Space r`: opens a separate PowerShell/Windows Terminal window.
- `Space t`: opens a separate test terminal.
- `Ctrl+\`: opens the persistent terminal inside Neovim.

The external launcher uses a temporary `.ps1` file. This avoids Windows
quoting problems with paths such as `D:\Projects\My App\main.cpp`. The script:

1. Changes to the project directory.
2. Runs the compiler or executable.
3. Displays the exit code.
4. Waits for Enter so output can be read.
5. Deletes itself.

If PowerShell or Windows Terminal is unavailable, the command falls back to
the Neovim output panel.

## Makefile workflow

A Makefile is a normal editable project file. Open it with:

```vim
:e Makefile
```

Or use `Space e` and select `Makefile`.

Example:

```make
CXX = clang++
CXXFLAGS = -std=c++17 -Wall -Wextra
TARGET = main.exe
SOURCES = main.cpp

all:
	$(CXX) $(CXXFLAGS) $(SOURCES) -o $(TARGET)

run: all
	./$(TARGET)

clean:
	del /Q $(TARGET)
```

The command must start with a tab, not spaces, before `$(CXX)` and `del`.

With a Makefile present:

- `Space b` runs `make`.
- `Space r` prompts for the executable.
- `Space t` runs `make test` if that target exists.

## CMake workflow

For a CMake project, configure it once:

```powershell
cmake -S . -B build
```

Then use:

```text
Space b
```

The configuration detects the `build` directory and runs:

```powershell
cmake --build build
```

## Available panel commands

The `:IDEPanel` command accepts these arguments:

```vim
:IDEPanel terminal
:IDEPanel build
:IDEPanel run
:IDEPanel debug
:IDEPanel tests
:IDEPanel diagnostics
```

Use `Space q` to close the current docked panel. Use `Space q+` and `Space q-`
to resize the bottom panel.

## Relevant implementation files

- [`lua/core/embedded.lua`](../lua/core/embedded.lua): detects projects and
  chooses build, run, test, flash, and monitor commands.
- [`lua/core/panels.lua`](../lua/core/panels.lua): manages persistent panels
  and the external PowerShell launcher.
- [`lua/core/keymaps.lua`](../lua/core/keymaps.lua): defines keyboard
  shortcuts.
- [`docs/EMBEDDED_WORKFLOW.md`](./EMBEDDED_WORKFLOW.md): embedded project
  workflow and debugger limitations.

## Troubleshooting

Check compiler availability:

```powershell
Get-Command g++,clang++,cmake,make
```

Check the current project directory:

```vim
:pwd
```

Check available commands:

```vim
:command EmbeddedBuild
:command EmbeddedRun
:command IDEPanel
```

If the terminal opens but nothing runs, restart Neovim with `:qa` and reopen
it so the latest Lua modules are loaded.
