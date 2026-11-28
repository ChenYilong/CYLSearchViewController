<#
.SYNOPSIS
  Release RAM on a Windows developer machine: closes the heavy apps, restarts the file explorer and restarts the emulators.

.DESCRIPTION
  The entry point of the "Release RAM" task. The manual is docs/Release-RAM.md (Windows section). The steps live in
  scripts/release-ram/; this file only runs them in order, so each step can also be run alone.

    1. scripts/release-ram/stop-apps.ps1              Obsidian, Android Studio, Chrome, Edge
    2. scripts/release-ram/close-explorer-windows.ps1 every File Explorer window; -RestartShell restarts explorer.exe
    3. scripts/release-ram/restart-emulators.ps1      stop (also a busy or hung one) and start the emulators this task needs
    4. scripts/release-ram/set-brightness.ps1         optional, -DimDisplay: built-in display to near black (-Restore undoes it)

  Nothing is closed without -Apply, a plain run is a dry run that lists what would happen. The script does not message
  the other sessions: tell them yourself after step 3 (see the manual, "After the run").

.PARAMETER Apply
  Really do it. Without it the script only prints the plan (dry run).
.PARAMETER Force
  Stop an emulator even when it looks busy. Use it when you know nobody debugs on it.
.PARAMETER RestartShell
  Restart explorer.exe (taskbar flickers for about two seconds), not only close the windows.
.PARAMETER SkipEmulators
  Do not touch the emulators.
.PARAMETER StopEmulatorsOnly
  Stop the emulators, do not start them again.
.PARAMETER DimDisplay
  Also lower the built-in display brightness (set-brightness.ps1).
.PARAMETER Keep
  Android serials that must never be stopped (for example emulator-5556, which belongs to another session).

.EXAMPLE
  pwsh -File ./release-ram.ps1                       # dry run: prints the plan
  pwsh -File ./release-ram.ps1 -Apply -Force       # do everything, restart busy emulators too
  pwsh -File ./release-ram.ps1 -Apply -Force -Keep emulator-5556 -RestartShell
  pwsh -File ./release-ram.ps1 -Apply -SkipEmulators
#>
[CmdletBinding()]
param(
    [switch]$Apply,
    [switch]$Force,
    [switch]$RestartShell,
    [switch]$SkipEmulators,
    [switch]$StopEmulatorsOnly,
    [switch]$DimDisplay,
    [string[]]$Keep = @(),
    [ValidateSet('android', 'harmonyos', 'both')][string]$Platform = 'both'
)

$ErrorActionPreference = 'Continue'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$steps = Join-Path $here 'scripts\release-ram'
$dry = -not $Apply
if ($dry) { Write-Host '== DRY RUN: nothing is changed. Add -Apply to do it. ==' }

& (Join-Path $steps 'stop-apps.ps1') -DryRun:$dry

& (Join-Path $steps 'close-explorer-windows.ps1') -RestartShell:$RestartShell -DryRun:$dry

if (-not $SkipEmulators) {
    & (Join-Path $steps 'restart-emulators.ps1') -Platform $Platform -Keep $Keep -Force:$Force -StopOnly:$StopEmulatorsOnly -DryRun:$dry
    if ($LASTEXITCODE -ne 0) { Write-Host '[failed] the emulator step failed, see above' }
}

if ($DimDisplay) { & (Join-Path $steps 'set-brightness.ps1') -DryRun:$dry }

Write-Host ''
Write-Host 'Next: tell the other Windows and macOS sessions that the emulators were restarted (docs/Release-RAM.md, "After the run").'
