<#
.SYNOPSIS
  Lowers the brightness of the built-in display to a near-black level, and restores it later.

.DESCRIPTION
  Part of the "Release RAM" task, see docs/Release-RAM.md. Windows exposes brightness through WMI only for the built-in
  panel of a laptop (WmiMonitorBrightnessMethods). External monitors need DDC/CI, which Windows has no built-in command
  for: use the monitor's own buttons, or a tool such as Monitorian or ControlMyMonitor, and set it to the same level.
  The previous level is saved to $env:TEMP\cyl-release-ram-brightness.txt so -Restore can put it back.

.PARAMETER Percent
  Target brightness, 0 to 100. Default 1 (near black but the panel is still readable when you look closely).

.EXAMPLE
  pwsh -File scripts/release-ram/set-brightness.ps1 -DryRun
  pwsh -File scripts/release-ram/set-brightness.ps1 -Percent 1
  pwsh -File scripts/release-ram/set-brightness.ps1 -Restore
#>
[CmdletBinding()]
param(
    [ValidateRange(0, 100)][int]$Percent = 1,
    [switch]$Restore,
    [switch]$DryRun
)

$ErrorActionPreference = 'Continue'
$saved = Join-Path $env:TEMP 'cyl-release-ram-brightness.txt'

$current = Get-CimInstance -Namespace root/WMI -ClassName WmiMonitorBrightness -ErrorAction SilentlyContinue |
    Where-Object { $_.Active } | Select-Object -First 1
$methods = Get-CimInstance -Namespace root/WMI -ClassName WmiMonitorBrightnessMethods -ErrorAction SilentlyContinue |
    Where-Object { $_.Active } | Select-Object -First 1

if (-not $current -or -not $methods) {
    Write-Host '[skip] no built-in display with WMI brightness control (a desktop PC, or only external monitors).'
    Write-Host '       Lower the external monitors by hand or with Monitorian / ControlMyMonitor.'
    exit 0
}

if ($Restore) {
    if (-not (Test-Path $saved)) { Write-Host "[skip] nothing to restore ($saved is missing)"; exit 0 }
    $previous = [int](Get-Content $saved -Raw).Trim()
    if ($DryRun) { Write-Host "[dry-run] would restore the brightness to $previous%"; exit 0 }
    [void](Invoke-CimMethod -InputObject $methods -MethodName WmiSetBrightness -Arguments @{ Timeout = 0; Brightness = $previous })
    Write-Host "[restore] brightness is $previous% again"
    Remove-Item $saved -Force
    exit 0
}

Write-Host "[info] built-in display brightness is $($current.CurrentBrightness)%"
if ($DryRun) { Write-Host "[dry-run] would set it to $Percent%"; exit 0 }
# Keep the first saved level: running the script twice must not overwrite the real one with the dimmed one.
if (-not (Test-Path $saved)) { Set-Content -Path $saved -Value $current.CurrentBrightness }
[void](Invoke-CimMethod -InputObject $methods -MethodName WmiSetBrightness -Arguments @{ Timeout = 0; Brightness = $Percent })
Write-Host "[set] brightness is $Percent% (restore with -Restore)"
