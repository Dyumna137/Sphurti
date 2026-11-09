# Dot-source this file from a project terminal:
#   . .\tools\embedded-env.ps1

$ErrorActionPreference = "Stop"

$toolPaths = @(
    (Join-Path $env:APPDATA "Python\Python313\Scripts"),
    (Join-Path $env:USERPROFILE ".platformio\packages\toolchain-gccarmnoneeabi\bin")
)

$openOcdRoot = Get-ChildItem `
    (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages") `
    -Directory -Filter "xpack-dev-tools.openocd-xpack_*" `
    -ErrorAction SilentlyContinue |
    ForEach-Object { Join-Path $_.FullName "xpack-openocd-0.12.0-7\bin" } |
    Where-Object { Test-Path $_ } |
    Select-Object -First 1

if ($openOcdRoot) {
    $toolPaths += $openOcdRoot
}

$existing = @($env:Path -split ";" | Where-Object { $_ })
foreach ($path in $toolPaths) {
    if ((Test-Path $path) -and $existing -notcontains $path) {
        $existing = @($path) + $existing
    }
}
$env:Path = $existing -join ";"

$env:SPHURTI_PLATFORMIO_HOME = Join-Path $env:USERPROFILE ".platformio"
$env:SPHURTI_ARM_GCC_HOME = Join-Path $env:USERPROFILE ".platformio\packages\toolchain-gccarmnoneeabi"
$env:SPHURTI_OPENOCD_HOME = $openOcdRoot

$required = "platformio", "arm-none-eabi-gdb", "openocd"
$missing = @($required | Where-Object { -not (Get-Command $_ -ErrorAction SilentlyContinue) })
if ($missing.Count -gt 0) {
    Write-Warning ("Missing embedded tools in this terminal: " + ($missing -join ", "))
} else {
    Write-Host "Embedded environment ready: PlatformIO, ARM GDB, and OpenOCD"
}
