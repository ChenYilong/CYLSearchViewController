<#
.SYNOPSIS
  Stops an emulator, even when it is busy or hung, and starts it again. Android emulator and HarmonyOS emulator.

.DESCRIPTION
  Part of the "Release RAM" task, see docs/Release-RAM.md.

  "Busy" means something still uses the emulator: an adb shell, a running Gradle or instrumentation test, a held
  C:/w/heavy.lock, or an emulator that does not answer. Stopping goes in three steps and never stops at the first one:
    1. the polite stop (Android: adb emu kill; HarmonyOS: close the emulator window),
    2. after -StopSeconds the emulator process tree is killed (taskkill /T /F),
    3. the stale lock files of the AVD (*.lock) and the stale adb entry are removed, so the next start is not refused.
  Without -Force the script refuses to stop an emulator that looks busy and prints who holds it. With -Force it stops it
  anyway: that is the point of the script, use it when you know nobody debugs on that emulator any more.

  Only the emulator named by -Avd / -Port (Android) or -HvdName (HarmonyOS) is touched. Every other emulator keeps running;
  list the ones that must survive with -Keep (Android serials such as emulator-5556) as a second guard.

.PARAMETER Platform
  android, harmonyos or both. Default android.
.PARAMETER Avd
  Android AVD name. Default CYL_Second_API_37.
.PARAMETER Port
  Android emulator console port (the serial is emulator-<Port>). Default 5558.
.PARAMETER HvdName
  HarmonyOS emulator instance name. Default "Mate 70 Pro".
.PARAMETER Keep
  Android serials that must never be stopped, for example emulator-5556. A request to stop one of them fails.
.PARAMETER StopOnly
  Stop, do not start again.
.PARAMETER Headless
  Start the Android emulator with -no-window (no GUI; use it when a windowed start hangs).
.PARAMETER DryRun
  Print what would happen, change nothing.

.EXAMPLE
  pwsh -File scripts/release-ram/restart-emulators.ps1 -DryRun
  pwsh -File scripts/release-ram/restart-emulators.ps1 -Force
  pwsh -File scripts/release-ram/restart-emulators.ps1 -Platform harmonyos -Force -Keep emulator-5556
  pwsh -File scripts/release-ram/restart-emulators.ps1 -Force -StopOnly
#>
[CmdletBinding()]
param(
    [ValidateSet('android', 'harmonyos', 'both')][string]$Platform = 'android',
    [string]$Avd = 'CYL_Second_API_37',
    [int]$Port = 5558,
    [string]$HvdName = 'Mate 70 Pro',
    [string[]]$Keep = @(),
    [int]$StopSeconds = 20,
    [int]$BootSeconds = 240,
    [string]$LockFile = 'C:/w/heavy.lock',
    [switch]$Force,
    [switch]$StopOnly,
    [switch]$Headless,
    [switch]$DryRun
)

$ErrorActionPreference = 'Continue'
$serial = "emulator-$Port"

function Write-Step([string]$text) { Write-Host $text }

function Find-AndroidTool([string]$relative, [string]$exe) {
    $sdk = @($env:ANDROID_SDK_ROOT, $env:ANDROID_HOME, "$env:LOCALAPPDATA\Android\Sdk") | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
    if ($sdk -and (Test-Path (Join-Path $sdk $relative))) { return (Join-Path $sdk $relative) }
    $cmd = Get-Command $exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

# Runs a program with a hard time limit: a hung adb must not hang this script.
function Invoke-Limited([string]$file, [string[]]$arguments, [int]$seconds) {
    $p = Start-Process -FilePath $file -ArgumentList $arguments -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\cyl-ram-out.txt" -RedirectStandardError "$env:TEMP\cyl-ram-err.txt"
    if (-not $p.WaitForExit($seconds * 1000)) {
        & taskkill.exe /PID $p.Id /T /F 2>&1 | Out-Null
        return @{ TimedOut = $true; Output = '' }
    }
    return @{ TimedOut = $false; Output = (Get-Content "$env:TEMP\cyl-ram-out.txt" -Raw -ErrorAction SilentlyContinue) }
}

function Get-CommandLines([string]$namePattern) {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object { $_.Name -match $namePattern }
}

# ---------------------------------------------------------------- Android

function Get-AndroidBusyReasons($adb) {
    $reasons = @()
    if (Test-Path $LockFile) { $reasons += "lock file $LockFile is held: $((Get-Content $LockFile -Raw -ErrorAction SilentlyContinue).Trim())" }
    $state = (Invoke-Limited $adb @('-s', $serial, 'get-state') 5)
    if ($state.TimedOut) { $reasons += "$serial does not answer adb (hung)" }
    elseif ($state.Output -match 'device') {
        $ps = (Invoke-Limited $adb @('-s', $serial, 'shell', 'ps', '-A') 8).Output
        if ($ps -match 'instrument|uiautomator') { $reasons += "an instrumentation or uiautomator process runs on $serial" }
    }
    $gradle = @(Get-CommandLines '^java') | Where-Object { $_.CommandLine -match 'GradleWrapperMain|GradleDaemon' -and $_.CommandLine -match 'connected|AndroidTest' }
    if ($gradle) { $reasons += 'a Gradle connected*AndroidTest build runs' }
    return $reasons
}

function Stop-AndroidEmulator($adb) {
    if ($Keep -contains $serial) { Write-Error "$serial is in -Keep; refusing to stop it"; return $false }
    $procs = @(Get-CommandLines '^(qemu-system|emulator)' | Where-Object { $_.CommandLine -match "-avd\s+$([regex]::Escape($Avd))(\s|$)" -or $_.CommandLine -match "-port\s+$Port(\s|$)" })
    $registered = $false
    if ($adb) {
        $devices = (Invoke-Limited $adb @('devices') 8).Output
        $registered = $devices -match [regex]::Escape($serial)
    }
    if ($procs.Count -eq 0 -and -not $registered) { Write-Step "[skip] $serial / $Avd is not running"; return $true }

    $reasons = if ($adb) { Get-AndroidBusyReasons $adb } else { @() }
    foreach ($r in $reasons) { Write-Step "[busy] $r" }
    if ($reasons.Count -gt 0 -and -not $Force) {
        Write-Error "$serial looks busy; nothing was stopped. Re-run with -Force when nobody uses it."
        return $false
    }
    if ($DryRun) {
        Write-Step "[dry-run] would stop $serial ($Avd): adb emu kill, then taskkill /T /F of $($procs.Count) process(es), then remove the lock files"
        return $true
    }

    # 1. polite stop
    if ($adb -and $registered) {
        Write-Step "[stop] adb -s $serial emu kill"
        [void](Invoke-Limited $adb @('-s', $serial, 'emu', 'kill') 10)
    }
    $deadline = (Get-Date).AddSeconds($StopSeconds)
    while ((Get-Date) -lt $deadline) {
        $alive = @(Get-CommandLines '^(qemu-system|emulator)' | Where-Object { $_.CommandLine -match "-avd\s+$([regex]::Escape($Avd))(\s|$)" -or $_.CommandLine -match "-port\s+$Port(\s|$)" })
        if ($alive.Count -eq 0) { break }
        Start-Sleep -Milliseconds 500
    }
    # 2. force
    $alive = @(Get-CommandLines '^(qemu-system|emulator)' | Where-Object { $_.CommandLine -match "-avd\s+$([regex]::Escape($Avd))(\s|$)" -or $_.CommandLine -match "-port\s+$Port(\s|$)" })
    foreach ($p in $alive) {
        Write-Step "[kill] $($p.Name) pid $($p.ProcessId) did not stop in $StopSeconds s"
        & taskkill.exe /PID $p.ProcessId /T /F 2>&1 | Out-Null
    }
    Start-Sleep -Seconds 1
    # 3. stale state: the AVD lock files (a killed emulator leaves them and the next start says "already running")
    $avdHome = if ($env:ANDROID_AVD_HOME) { $env:ANDROID_AVD_HOME } else { "$env:USERPROFILE\.android\avd" }
    $dir = Join-Path $avdHome "$Avd.avd"
    if (Test-Path $dir) {
        foreach ($f in @(Get-ChildItem -Path $dir -Filter '*.lock' -Force -ErrorAction SilentlyContinue)) {
            Remove-Item $f.FullName -Recurse -Force -ErrorAction SilentlyContinue
            Write-Step "[clean] removed $($f.Name)"
        }
    }
    if ($adb) {
        # Drop an offline entry of this serial only; other devices are left alone.
        [void](Invoke-Limited $adb @('disconnect', $serial) 5)
    }
    $left = @(Get-CommandLines '^(qemu-system|emulator)' | Where-Object { $_.CommandLine -match "-avd\s+$([regex]::Escape($Avd))(\s|$)" -or $_.CommandLine -match "-port\s+$Port(\s|$)" })
    if ($left.Count -gt 0) { Write-Error "$Avd is still running after the forced stop"; return $false }
    Write-Step "[ok] $serial stopped"
    return $true
}

function Start-AndroidEmulator($adb) {
    $emulator = Find-AndroidTool 'emulator\emulator.exe' 'emulator'
    if (-not $emulator) { Write-Error 'emulator.exe not found (set ANDROID_SDK_ROOT)'; return $false }
    $arguments = @('-avd', $Avd, '-port', "$Port", '-no-snapshot-save', '-no-metrics', '-no-audio')
    if ($Headless) { $arguments += '-no-window' }
    if ($DryRun) { Write-Step "[dry-run] would start: $emulator $($arguments -join ' ')"; return $true }
    Write-Step "[start] $Avd on port $Port"
    [void](Start-Process -FilePath $emulator -ArgumentList $arguments -WindowStyle Hidden -PassThru)
    $deadline = (Get-Date).AddSeconds($BootSeconds)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 3
        $boot = (Invoke-Limited $adb @('-s', $serial, 'shell', 'getprop', 'sys.boot_completed') 6)
        if (-not $boot.TimedOut -and $boot.Output -match '1') { Write-Step "[ok] $serial finished booting"; return $true }
    }
    Write-Error "$serial did not finish booting in $BootSeconds s"
    return $false
}

# ---------------------------------------------------------------- HarmonyOS

function Get-HarmonyProcesses {
    Get-CommandLines '^(Emulator|qemu)' | Where-Object { $_.CommandLine -match [regex]::Escape($HvdName) }
}

function Stop-HarmonyEmulator {
    $procs = @(Get-HarmonyProcesses)
    if ($procs.Count -eq 0) { Write-Step "[skip] HarmonyOS emulator '$HvdName' is not running"; return $true }
    $reasons = @()
    if (Test-Path $LockFile) { $reasons += "lock file $LockFile is held: $((Get-Content $LockFile -Raw -ErrorAction SilentlyContinue).Trim())" }
    $hdcBusy = @(Get-CommandLines '^hdc') | Where-Object { $_.CommandLine -match 'shell' -and $_.CommandLine -match 'aa test|hilog|uitest' }
    if ($hdcBusy) { $reasons += 'an hdc shell runs aa test / hilog / uitest' }
    foreach ($r in $reasons) { Write-Step "[busy] $r" }
    if ($reasons.Count -gt 0 -and -not $Force) {
        Write-Error "HarmonyOS emulator '$HvdName' looks busy; nothing was stopped. Re-run with -Force when nobody uses it."
        return $false
    }
    if ($DryRun) { Write-Step "[dry-run] would stop '$HvdName': close the window, then taskkill /T /F of $($procs.Count) process(es)"; return $true }
    Write-Step "[stop] HarmonyOS emulator '$HvdName'"
    foreach ($p in $procs) {
        $gui = Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue
        if ($gui -and $gui.MainWindowHandle -ne 0) { [void]$gui.CloseMainWindow() }
    }
    $deadline = (Get-Date).AddSeconds($StopSeconds)
    while ((Get-Date) -lt $deadline -and @(Get-HarmonyProcesses).Count -gt 0) { Start-Sleep -Milliseconds 500 }
    foreach ($p in @(Get-HarmonyProcesses)) {
        Write-Step "[kill] $($p.Name) pid $($p.ProcessId) did not stop in $StopSeconds s"
        & taskkill.exe /PID $p.ProcessId /T /F 2>&1 | Out-Null
    }
    Start-Sleep -Seconds 1
    if (@(Get-HarmonyProcesses).Count -gt 0) { Write-Error "'$HvdName' is still running after the forced stop"; return $false }
    Write-Step "[ok] HarmonyOS emulator '$HvdName' stopped"
    return $true
}

function Start-HarmonyEmulator {
    $exe = @("$env:ProgramFiles\Huawei\DevEco Studio\tools\emulator\Emulator.exe", "${env:ProgramFiles(x86)}\Huawei\DevEco Studio\tools\emulator\Emulator.exe") |
        Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $exe) { Write-Error 'DevEco Emulator.exe not found under Program Files\Huawei\DevEco Studio\tools\emulator'; return $false }
    if ($DryRun) { Write-Step "[dry-run] would start: $exe -hvd `"$HvdName`""; return $true }
    Write-Step "[start] HarmonyOS emulator '$HvdName'"
    [void](Start-Process -FilePath $exe -ArgumentList @('-hvd', $HvdName) -PassThru)
    Start-Sleep -Seconds 5
    if (@(Get-HarmonyProcesses).Count -eq 0) { Write-Error "'$HvdName' did not start"; return $false }
    Write-Step "[ok] '$HvdName' is starting (it takes about a minute to boot; check: hdc list targets)"
    return $true
}

# ---------------------------------------------------------------- main

$adb = Find-AndroidTool 'platform-tools\adb.exe' 'adb'
$ok = $true

if ($Platform -in @('android', 'both')) {
    if (Stop-AndroidEmulator $adb) {
        if (-not $StopOnly) { $ok = (Start-AndroidEmulator $adb) -and $ok }
    } else { $ok = $false }
}
if ($Platform -in @('harmonyos', 'both')) {
    if (Stop-HarmonyEmulator) {
        if (-not $StopOnly) { $ok = (Start-HarmonyEmulator) -and $ok }
    } else { $ok = $false }
}

if ($ok) { Write-Step '[done] emulators'; exit 0 } else { Write-Step '[failed] see the errors above'; exit 1 }
