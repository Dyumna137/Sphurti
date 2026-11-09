# Project-local Embedded Environment

This configuration does not install embedded tools into the repository. The
repository contains a reusable environment script that exposes already
installed user-level tools to the current PowerShell session.

## Start the environment

From the Neovim configuration root:

```powershell
Set-Location $env:LOCALAPPDATA\nvim
. .\tools\embedded-env.ps1
```

The leading dot is important: it loads the script into the current terminal.
Running `.\tools\embedded-env.ps1` without the dot starts a child process and
cannot change the parent terminal's `PATH`.

Then verify:

```powershell
Get-Command platformio, arm-none-eabi-gdb, openocd
platformio --version
arm-none-eabi-gdb --version
openocd --version
```

Open a firmware project from that same terminal:

```powershell
Set-Location C:\path\to\firmware-project
nvim
```

Inside Neovim, use `<Space>et` or `:EmbeddedToolReport` to display the paths
Neovim is using. The environment lasts only for the current terminal session;
close the terminal to return to the normal system environment.

## What the script provides

| Variable | Purpose |
|---|---|
| `SPHURTI_PLATFORMIO_HOME` | PlatformIO user data directory |
| `SPHURTI_ARM_GCC_HOME` | PlatformIO-managed ARM toolchain |
| `SPHURTI_OPENOCD_HOME` | OpenOCD executable directory |

It discovers the current Windows user profile and does not contain a username,
secret, board credential, or machine-specific absolute path.

## Installation policy

The script intentionally does not install or update anything. Install tools
separately when required, then dot-source the script again. This keeps the
repository reproducible and prevents Neovim startup from modifying the host.
