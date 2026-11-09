---
title: Neovim — Keymaps and Workflow
aliases:
  - Neovim Shortcuts
  - Neovim Workflow
  - Neovim Reference
tags:
  - tools/neovim
  - reference/keymaps
  - workflow/development
type: reference
status: active
created: 2026-11-09
updated: 2026-11-09
---

# Neovim — Keymaps and Workflow

*A practical field guide to getting around your code without getting lost in your editor.*

Neovim is at its best when it stops feeling like an editor and starts feeling like a place where work happens. This note is the map: how to find files, follow code, manage changes, build a project, and investigate what went wrong.

You do not need to memorise every shortcut. Keep this nearby, use the ones that solve today's problem, and let muscle memory do its thing. It has a better memory than most of us, anyway.

> **Leader key:** `<Space>`

## The shortcuts worth knowing first

These are the ones you are likely to reach for every day.

| I need to… | Shortcut |
|---|---|
| Find a file in the project | `<Space>sf` |
| Search text across the project | `<Space>sg` |
| Open the file explorer | `<Space>e` |
| List open buffers | `<Space>sb` |
| Jump to a symbol's definition | `gd` |
| Find references to a symbol | `gr` |
| Read symbol documentation | `K` |
| Open the project terminal | `<Space>tc` |
| Build the project | `<Space>eb` |
| See all diagnostics | `<Space>xx` |
| Review the Git diff | `<Space>gd` |

A useful way to think about the setup:

- **Telescope** helps you find files and text.
- **LSP** helps you understand code.
- **Git** helps you see what changed.
- **The terminal** helps you build, run, and test it.

They each have a job. Let them do it.

---

## 1. Find files and search the project

When you know roughly what you are looking for, search is usually faster than clicking through folders one by one.

| Shortcut | What it does | Good for |
|---|---|---|
| `<Space>sf` | Search all project files | Finding source, header, configuration, or documentation files |
| `<Space>gf` | Search Git-tracked files with preview | Finding files already tracked by Git |
| `<Space>sl` | Search Lua configuration files | Finding Neovim plugins and configuration |
| `<Space>sn` | Search Neovim configuration files | Looking through your editor setup |
| `<Space>sg` | Search text across files | Finding a function, variable, macro, or phrase |
| `<Space>/` | Search inside the current file | Finding something in the file already open |
| `<Space>e` | Open the file explorer | Browsing the directory tree |

**Example: find a Neovim configuration file**

1. Press `<Space>sl`.
2. Type `git.lua` or `gitsigns.lua`.
3. Select the result and get on with your day.

**Small distinction:** `<Space>sf` searches project files; `<Space>sg` searches the contents of those files. One finds the book, the other finds the sentence.

## 2. Move between files and buffers

A *buffer* is an open file (or editor buffer) in Neovim. You can keep several files open and move between them without searching for the same file repeatedly.

| Shortcut | What it does |
|---|---|
| `Tab` | Move to the next buffer |
| `Shift+Tab` | Move to the previous buffer |
| `<Space>sb` | List open buffers |
| `<Space>bd` | Close the current buffer |
| `<Space>bc` | Close hidden buffers |

**A useful habit:** keep the files relevant to your current task open. Use `<Space>sb` when you have forgotten what is already open. It happens; the editor is not judging you.

## 3. Move around long files

You do not have to scroll line by line like you are reading a particularly stubborn terms-and-conditions page.

| Shortcut | What it does |
|---|---|
| `Ctrl+d` | Scroll down |
| `Ctrl+u` | Scroll up |
| `n` | Move to the next search match |
| `N` | Move to the previous search match |
| `]d` | Move to the next diagnostic |
| `[d` | Move to the previous diagnostic |
| `]q` | Move to the next build error / quickfix item |
| `[q` | Move to the previous build error / quickfix item |

**A simple search routine**

1. Search with `/` or `<Space>/`.
2. Press `n` to move forward through matches.
3. Press `N` to move backward.
4. Use `Ctrl+d` and `Ctrl+u` to move through the surrounding code.

## 4. Understand code with LSP

LSP stands for *Language Server Protocol*. In practice, it gives Neovim language-aware features such as finding definitions, locating references, showing documentation, and applying code actions.

These mappings are useful in a supported file when the relevant language server is attached.

| Shortcut | What it does | When to use it |
|---|---|---|
| `gd` | Go to definition | Find where a function, type, or variable is defined |
| `gr` | Find references | See where a symbol is used |
| `K` | Show documentation | Inspect documentation or type information |
| `<Space>rn` | Rename symbol | Rename a symbol through the language server |
| `<Space>ca` | Show code actions | View available fixes or language-server actions |
| `<Space>ch` | Switch C/C++ header and source | Move between a related header and source file |

**Example: investigating an unfamiliar function**

1. Put the cursor on the function name.
2. Press `gd` to inspect its definition.
3. Press `gr` to see where it is used.
4. Press `K` to read the available documentation.
5. Trace the relevant calls before changing anything.

The important part is the last step. Jumping to a definition is easy; understanding why it exists is the actual engineering.

## 5. Splits and windows

Splits are useful when you need two pieces of information visible at once: a header beside its implementation, a configuration file beside its source, or code beside documentation.

| Shortcut | What it does |
|---|---|
| `<Space>vv` | Open a vertical split |
| `<Space>hh` | Open a horizontal split |
| `Ctrl+h` | Move to the window on the left |
| `Ctrl+j` | Move to the window below |
| `Ctrl+k` | Move to the window above |
| `Ctrl+l` | Move to the window on the right |
| `Ctrl+Arrow` | Resize the window |
| `<Space>se` | Equalise window sizes |

**Example layout:** open a `.cpp` file and its `.h` file side by side. Use `<Space>vv` or `<Space>hh` to create the split, then use the `Ctrl` + direction mappings to move between windows.

A split should make comparison easier, not turn your screen into a badly organised control room. Close the extra windows when you are done.

## 6. Git without leaving Neovim

These mappings give you a quick view of repository state and line-level changes. They complement normal Git operations; they do not replace commits, branches, or a proper review of what you are about to save.

### Repository actions

| Shortcut | What it does |
|---|---|
| `<Space>gs` | Open Git status |
| `<Space>gd` | View Git diff |
| `<Space>gl` | View Git log |
| `<Space>gb` | View Git blame |

### Hunk actions

A *hunk* is a group of changed lines.

| Shortcut | What it does |
|---|---|
| `<Space>hs` | Stage the current hunk |
| `<Space>hr` | Reset the current hunk |
| `<Space>hp` | Preview the current hunk |

> **Take care with `<Space>hr`.** It resets the selected hunk. Preview it first and make sure the changes are not something you meant to keep. Git is excellent at remembering things, but it cannot read your mind.

## 7. Diagnostics and symbols

Diagnostics are messages from configured language servers, linters, or other tools. They can point out errors, warnings, and things worth investigating.

| Shortcut | What it does |
|---|---|
| `<Space>ld` | Open the diagnostics report |
| `<Space>xx` | Show all diagnostics |
| `<Space>xX` | Show diagnostics for the current file |
| `<Space>cs` | Show symbols |
| `]d` | Move to the next diagnostic |
| `[d` | Move to the previous diagnostic |

**Inline indicator:** diagnostics appear with a `●` marker.

When a build fails, start with the first meaningful error rather than trying to fix every message at once. Later errors are often just the first error's extended family.

## 8. Terminal, build, and embedded workflow

| Shortcut | What it does | Typical use |
|---|---|---|
| `<Space>tc` | Open a terminal at the project root | Run CMake, Make, Git, or project-level commands |
| `<Space>tt` | Open a terminal in the current file's directory | Run commands near the current source file |
| `<Space>eb` | Build | Start the configured build action |
| `<Space>ef` | Flash | Start the configured firmware flashing action |
| `<Space>em` | Open the serial monitor | Inspect device output |
| `<Space>et` | Open the tool report | Inspect the configured tool report |
| `<Esc><Esc>` | Leave terminal mode | Return from terminal input mode to Normal mode |

> **Project-dependent:** build, flash, serial-monitor, and tool-report shortcuts depend on the current project's configuration and installed tools. A keymap can launch an action; it cannot install a compiler, connect a board, or negotiate with a missing USB cable.

## 9. Debugging

Use these mappings when the project has a debugger configuration set up.

| Shortcut | What it does |
|---|---|
| `F5` | Start or continue debugging |
| `F9` | Toggle a breakpoint |
| `F10` | Step over |
| `F11` | Step into |
| `F12` | Step out |
| `F7` | Toggle the debugger UI |

A good debugging session is a series of small questions: where does execution go, what value does this have, and when does reality stop matching the assumption?

## 10. A practical development loop

You do not need a grand ritual for every edit. A repeatable sequence is enough: find the code, understand it, make a focused change, and verify the result.

1. **Find the file** — `<Space>sf`
2. **Trace the code** — `gd`, `gr`, and `K`
3. **Open the project terminal** — `<Space>tc`
4. **Build** — `<Space>eb`
5. **Inspect diagnostics** — `<Space>xx`, then `]q` / `[q` if needed
6. **Review the changes** — `<Space>gd`
7. **Stage the intended hunk** — `<Space>hs`
8. **Flash when appropriate** — `<Space>ef`
9. **Check device output** — `<Space>em`

**Do not skip verification.** A command completing is not proof that the software works. Check the build output, inspect the diff, run the relevant test, and confirm the behaviour on the actual device when hardware is involved.

### Pocket reference

```text
FIND FILES       <Space>sf   Search project files
SEARCH TEXT      <Space>sg   Search inside project files
BUFFERS          <Space>sb   List open buffers
DEFINITION       gd          Go to definition
REFERENCES       gr          Find references
TERMINAL         <Space>tc   Project-root terminal
BUILD            <Space>eb   Build project
DIAGNOSTICS      <Space>xx   Show all diagnostics
GIT DIFF         <Space>gd   Review changes
FLASH            <Space>ef   Flash firmware
SERIAL MONITOR   <Space>em   Inspect device output
```

## 11. When a shortcut does not work

Before blaming Neovim (or questioning your life choices), check the usual suspects:

- **Mode:** most navigation mappings are intended for Normal mode. In a terminal buffer, press `<Esc><Esc>` to leave terminal mode.
- **Language server:** `gd`, `gr`, and related LSP actions need a supported language server attached to the buffer.
- **Project setup:** build and flash actions may depend on project files, tools, environment variables, and a connected device.
- **Mapping configuration:** if a shortcut behaves differently, inspect the keymap configuration where it is defined.

If the problem persists, check `:map` or `:verbose map <key>` to inspect the mapping and where it was set. Replace `<key>` with the shortcut you are investigating.

## 12. Make this note yours

Shortcuts can stay the same while projects change. Keep the project-specific details here so the next session starts with less archaeology.

| Project detail | Your setup |
|---|---|
| Current project |  |
| Build command |  |
| Flash command / tool |  |
| Serial device |  |
| Serial baud rate |  |
| Test command |  |
| Mappings to revisit |  |

---

*The point is not to become a walking keymap manual. The point is to spend less time wrestling with the editor and more time building things that actually work.*
