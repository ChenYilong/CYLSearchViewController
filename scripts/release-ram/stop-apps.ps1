<#
.SYNOPSIS
  Closes the apps that hold RAM on a Windows developer machine (Obsidian, Android Studio, Chrome, Edge).

.DESCRIPTION
  Part of the "Release RAM" task, see docs/Release-RAM.md. Each app is closed politely first (CloseMainWindow, so the app
  can save), then killed when it is still alive after -GraceSeconds. With -DryRun nothing is closed, the script only lists
  what it would close.

.PARAMETER Apps
  Process names without ".exe". Default: Obsidian, studio64 (Android Studio), chrome, msedge.

.EXAMPLE
  pwsh -File scripts/release-ram/stop-apps.ps1 -DryRun
  pwsh -File scripts/release-ram/stop-apps.ps1 -Apps obsidian,chrome
#>
[CmdletBinding()]
param(
    [string[]]$Apps = @('Obsidian', 'studio64', 'chrome', 'msedge'),
    [int]$GraceSeconds = 8,
    [switch]$DryRun
)

$ErrorActionPreference = 'Continue'
$totalMb = 0

foreach ($name in $Apps) {
    $procs = @(Get-Process -Name $name -ErrorAction SilentlyContinue)
    if ($procs.Count -eq 0) {
        Write-Host "[skip] $name is not running"
        continue
    }
    $mb = [math]::Round(($procs | Measure-Object WorkingSet64 -Sum).Sum / 1MB)
    $totalMb += $mb
    if ($DryRun) {
        Write-Host "[dry-run] would close $name ($($procs.Count) processes, about $mb MB)"
        continue
    }
    Write-Host "[close] $name ($($procs.Count) processes, about $mb MB)"
    foreach ($p in $procs) {
        if ($p.MainWindowHandle -ne 0) { [void]$p.CloseMainWindow() }
    }
    $deadline = (Get-Date).AddSeconds($GraceSeconds)
    while ((Get-Date) -lt $deadline -and (Get-Process -Name $name -ErrorAction SilentlyContinue)) {
        Start-Sleep -Milliseconds 500
    }
    $left = @(Get-Process -Name $name -ErrorAction SilentlyContinue)
    if ($left.Count -gt 0) {
        Write-Host "[kill] $name still alive after $GraceSeconds s"
        # taskkill /T also ends the helper processes of the app (Chrome and Edge start dozens).
        foreach ($p in $left) { & taskkill.exe /PID $p.Id /T /F 2>&1 | Out-Null }
    }
}

Write-Host "[done] apps: about $totalMb MB were held$(if ($DryRun) { ' (dry run, nothing closed)' })"
