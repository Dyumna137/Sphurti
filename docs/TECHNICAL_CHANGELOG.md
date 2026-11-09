# Technical Change Log

## Purpose

This document records the significant technical work completed in the Sphurti
Neovim environment, including the reasoning behind each decision. It describes
the current design rather than replacing older historical audit logs.

## Design goals

The configuration was shaped around four goals:

1. Keep startup fast enough for daily editing.
2. Make C/C++ embedded development practical for STM32 and ESP32 projects.
3. Make Git, diagnostics, and debugging state visible from inside Neovim.
4. Avoid silently installing tools or claiming hardware support that is not
   actually available.

## Architecture decisions

### Lazy plugin loading

Plugins use lazy.nvim events, commands, or key mappings instead of loading
everything at startup. Treesitter loads when a supported filetype opens,
debugging loads when a DAP mapping is used, and Gitsigns is restricted to Git
repositories.

**Reason:** Embedded projects need editor responsiveness, but debugging and
Git features are not required for every buffer. Delayed loading reduces
startup work without removing the features.

### LSP ownership

Mason configuration in `lua/plugins/lsp/mason.lua` is the authoritative list
for Lua, C/C++, Python, Rust, Java, and Bash language servers. Global
diagnostic behavior lives in `lua/plugins/lsp.lua`; shared attach behavior
lives in `lua/plugins/lsp/on_attach.lua`.

**Reason:** Keeping installation, global UI, and buffer behavior separate
prevents duplicate server setup and makes each responsibility discoverable.

### Treesitter scope

Treesitter is filetype-lazy for Lua, C, C++, Python, Rust, Java, Shell/Bash,
Make, and CMake. Parsers are requested only for those languages.

**Reason:** The user wanted language support preserved while avoiding
unnecessary parser loading for unrelated filetypes. Neovim reports Bash files
as `sh`, so `sh` is included as the actual trigger.

## Embedded workflow

The project-aware commands in `lua/core/embedded.lua` detect the current
project from `.git`, `platformio.ini`, `CMakeLists.txt`, `Makefile`, or
`sdkconfig`.

| Mapping | Purpose |
|---|---|
| `<Space>eb` | Build |
| `<Space>ef` | Flash |
| `<Space>em` | Serial monitor |
| `<Space>ed` | Check embedded debugging prerequisites |
| `<Space>et` | Report embedded tool paths |

Detection is ordered so PlatformIO and ESP-IDF projects are handled before
generic CMake or Make projects.

**Reason:** The same editor can support different firmware build systems
without hard-coding one vendor workflow. Missing tools produce an explicit
notification instead of a success-shaped fallback.

## Environment isolation

`tools/embedded-env.ps1` is a project-local, non-installing environment
script. Dot-sourcing it adds user-level tool directories to the current
PowerShell session and exposes:

- PlatformIO
- ARM `arm-none-eabi-gdb`
- OpenOCD

It also sets `SPHURTI_PLATFORMIO_HOME`, `SPHURTI_ARM_GCC_HOME`, and
`SPHURTI_OPENOCD_HOME`.

**Reason:** Tool installation and editor configuration should be separate.
The repository stays portable, Neovim does not modify the host during startup,
and each terminal can opt into the embedded toolchain explicitly.

## Git and diagnostics visibility

Git support combines Fugitive, Gitsigns, Telescope, and Lualine:

- Branch name and file changes appear in the statusline.
- Gitsigns shows line-level additions, changes, and deletions.
- `<Space>gs`, `<Space>gd`, `<Space>gl`, and `<Space>gb` expose common Git views.
- `<Space>gB` shows branches and upstream tracking.
- `<Space>gp` opens Git status.
- `<Space>gf` searches tracked files with a preview.
- `<Space>ld` and `:DiagnosticsReport` show project root, attached clients,
  and diagnostic counts.
- Trouble provides workspace and current-buffer diagnostic lists.

**Reason:** Firmware debugging often crosses source changes, compiler
diagnostics, and hardware output. These views keep the state visible without
requiring repeated terminal context switches.

## Debugging design

DAP is configured for desktop C/C++ through Mason's `OpenDebugAD7` adapter.
The key workflow is:

| Key | Action |
|---|---|
| `<F5>` | Start or continue |
| `<F1>` | Step into |
| `<F2>` | Step over |
| `<F3>` | Step out |
| `<Space>b` | Toggle breakpoint |
| `<Space>B` | Conditional breakpoint |
| `<F7>` | Toggle DAP UI |

STM32 debugging additionally requires ARM GDB, OpenOCD, an ELF file, target
configuration, and a connected debug probe. ESP32 debugging requires the
appropriate PlatformIO or ESP-IDF project and board drivers.

**Reason:** A generic debugger cannot safely guess MCU type, probe protocol,
reset strategy, ELF path, or server port. The configuration checks
prerequisites while target-specific settings remain in the firmware project.

## Validation performed

- `nvim --headless -u init.lua -l tests/smoke.lua`
  - Result: `SMOKE_TEST_OK`
- Verified Treesitter remains unloaded at startup and loads on supported
  filetypes.
- Verified C/C++ `clangd`, Python `pyright`, and Bash `bashls` attachment in
  practical file tests.
- Verified all six LSP configurations are registered: Lua, C/C++, Python,
  Rust, Java, and Bash.
- Verified `:EmbeddedToolReport` resolves PlatformIO, ARM GDB, and OpenOCD.
- Verified the project-local PowerShell environment script with
  `Get-Command` and tool version commands.
- Verified Git and DAP mappings are registered.

## Known limitations

- Rust requires `rustc` and `cargo` for `rust_analyzer` to attach correctly.
- Java requires a valid Java project and a compatible JDK/JDTLS setup.
- Hardware debugging still needs board-specific configuration and a physical
  probe.
- Existing historical documents may contain older metrics or feature claims;
  they are retained as history and labeled where practical.
- The worktree may contain separate documentation and lockfile edits from
  earlier work; this document does not claim those edits were changed.

## Related documentation

- [Embedded environment](EMBEDDED_ENVIRONMENT.md)
- [Embedded workflow](EMBEDDED_WORKFLOW.md)
- [Daily usage](USAGE.md)
- [Documentation audit](DOCUMENTATION_AUDIT.md)
- [Bloat removal log](BLOAT_REMOVAL_LOG.md)
