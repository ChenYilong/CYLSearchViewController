<#
.SYNOPSIS
  Closes every File Explorer window and, with -RestartShell, restarts explorer.exe (taskbar, desktop, folder windows).

.DESCRIPTION
  Part of the "Release RAM" task, see docs/Release-RAM.md. Windows are closed through the Shell.Application COM object,
  which leaves the taskbar and the desktop alone. -RestartShell then stops explorer.exe and starts it again, which gives
  back the RAM that a long-running shell holds (the taskbar is gone for about two seconds). With -DryRun nothing is closed.

.EXAMPLE
  pwsh -File scripts/release-ram/close-explorer-windows.ps1 -DryRun
  pwsh -File scripts/release-ram/close-explorer-windows.ps1 -RestartShell
#>
[CmdletBinding()]
param(
    [switch]$RestartShell,
    [switch]$DryRun
)

$ErrorActionPreference = 'Continue'

$shell = New-Object -ComObject Shell.Application
$windows = @($shell.Windows() | Where-Object { $_.FullName -like '*\explorer.exe' })
Write-Host "[info] $($windows.Count) File Explorer windows are open"
foreach ($w in $windows) {
    $where = try { $w.LocationName } catch { '?' }
    if ($DryRun) {
        Write-Host "[dry-run] would close the window '$where'"
    } else {
        Write-Host "[close] the window '$where'"
        try { $w.Quit() } catch { Write-Host "[warn] could not close '$where': $($_.Exception.Message)" }
    }
}

if ($RestartShell) {
    $before = @(Get-Process -Name explorer -ErrorAction SilentlyContinue)
    $mb = [math]::Round(($before | Measure-Object WorkingSet64 -Sum).Sum / 1MB)
    if ($DryRun) {
        Write-Host "[dry-run] would restart explorer.exe (holds about $mb MB)"
    } else {
        Write-Host "[restart] explorer.exe (holds about $mb MB)"
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        # Windows normally starts the shell again by itself; start it when it did not.
        if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) { Start-Process explorer.exe }
        # Windows started by the restart (the shell opens "Quick access" sometimes): close them again.
        Start-Sleep -Seconds 2
        $again = New-Object -ComObject Shell.Application
        foreach ($w in @($again.Windows() | Where-Object { $_.FullName -like '*\explorer.exe' })) {
            try { $w.Quit() } catch { }
        }
    }
}
Write-Host "[done] file explorer$(if ($DryRun) { ' (dry run, nothing closed)' })"
