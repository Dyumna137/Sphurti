# Project Workflow

## Recommended layout

Keep one firmware project in one repository:

```text
firmware-project/
├── .git/
├── CMakeLists.txt        # STM32/CMake projects
├── platformio.ini        # PlatformIO projects
├── sdkconfig             # ESP-IDF projects
├── compile_commands.json # clangd diagnostics
├── src/
├── include/
└── build/
```

Open Neovim from that repository:

```powershell
cd C:\path\to\firmware-project
nvim
```

## Editor and terminal together

The configuration uses a built-in terminal split, so no terminal plugin is
required:

| Key | Action |
|---|---|
| `<Space>tt` | Open terminal in the current file directory |
| `<Space>tc` | Open terminal in the project root |
| `<Esc><Esc>` | Leave terminal insert mode |
| `<Space>eb` | Build using the detected project tool |
| `<Space>ef` | Flash the detected project |
| `<Space>em` | Open the serial monitor |
| `<Space>et` | Show available tools |

Use `<Space>tc` for normal project work. Use `<Space>tt` when a script or
component lives in a specific subdirectory.

## Practical session

1. `<Space>sf` — find source files.
2. Edit firmware code.
3. `<Space>tc` — open a project terminal.
4. Run or use `<Space>eb` to build.
5. Fix compiler diagnostics with `[q`/`]q`, `[d`/`]d`, and `<Space>ld`.
6. `<Space>ef` — flash the board.
7. `<Space>em` — watch sensor/UART responses.
8. `<F5>` — debug when the target adapter is installed.

The terminal remains inside Neovim, while the project root keeps Git, build,
flash, and diagnostics commands aligned to the same repository.
