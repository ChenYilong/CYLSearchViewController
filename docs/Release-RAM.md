# Release RAM

A manual for developers: how to free RAM on a development machine before a test or build batch, and how to restart the
emulators that the next batch needs. There is one section per operating system. Run the section that matches your machine
(Windows: [Windows](#windows); macOS: [macOS](#macos)). The scripts are in the repository root and in
[scripts/release-ram](../scripts/release-ram); run them by hand as shown below.

## Task (recorded 2026-11-26, owner)

English translation of the owner's order. The steps for the whole task:

1. Make sure no emulator is being debugged (no session uses an emulator), then close: the WeChat mini program devtools, the
   HarmonyOS emulator, the React Native watchman, Gradle, Obsidian, Android Studio, the Android emulator, Chrome, every
   Finder window.
2. Close the inactive emulators (inactive = no session is debugging on it); an inactive emulator is put to sleep or shut
   down. Close Bionic, opencode, MiniMax Code and TextExpander. Lower the brightness of every display to nearly black.
3. When it is done, send a message to every session on Windows and on macOS: "The emulators were restarted; if you were
   waiting for an emulator to debug, start the emulator debugging again."
4. The Windows section (written 2026-11-26) covers: close Obsidian, Android Studio, Chrome and Edge; restart the file
   browser and close all file browser windows; close the inactive emulators; restart the emulators that this task needs.

## Windows

Scripts (all PowerShell 7, `pwsh`; run them from the repository root):

| Script | What it does |
|:---|:---|
| [release-ram.ps1](../release-ram.ps1) | Entry point: runs the four steps below in order. A plain run is a dry run. |
| [scripts/release-ram/stop-apps.ps1](../scripts/release-ram/stop-apps.ps1) | Closes Obsidian, Android Studio (`studio64`), Chrome and Edge: asks them to close first, kills what is still alive after 8 s (with the helper processes). |
| [scripts/release-ram/close-explorer-windows.ps1](../scripts/release-ram/close-explorer-windows.ps1) | Closes every File Explorer window; `-RestartShell` also restarts `explorer.exe`. |
| [scripts/release-ram/restart-emulators.ps1](../scripts/release-ram/restart-emulators.ps1) | Stops the Android emulator and/or the HarmonyOS emulator, even a busy or hung one, and starts it again. |
| [scripts/release-ram/set-brightness.ps1](../scripts/release-ram/set-brightness.ps1) | Optional: built-in display to near black; `-Restore` puts it back. |

### Run it

1. Check that nobody uses an emulator: ask the other sessions, look at `C:/w/heavy.lock` (the shared lock, it names the
   holder) and at `adb devices`.
2. Dry run (changes nothing, lists what would happen):

   ```powershell
   pwsh -File ./release-ram.ps1
   ```

3. Do it. `-Force` restarts an emulator even when it looks busy (see below), `-Keep` protects emulators of other sessions:

   ```powershell
   pwsh -File ./release-ram.ps1 -Apply -Force -Keep emulator-5556
   ```

   Useful switches: `-RestartShell` (also restart `explorer.exe`, the taskbar flickers for about two seconds),
   `-SkipEmulators`, `-StopEmulatorsOnly`, `-Platform android|harmonyos|both` (default both), `-DimDisplay`.

4. Each step can be run alone, for example only the emulator step:

   ```powershell
   pwsh -File ./scripts/release-ram/restart-emulators.ps1 -Platform android -Force
   pwsh -File ./scripts/release-ram/restart-emulators.ps1 -Platform harmonyos -Force
   ```

   Defaults: Android AVD `CYL_Second_API_37` on port 5558 (serial `emulator-5558`), HarmonyOS instance `Mate 70 Pro`.
   Change them with `-Avd`, `-Port`, `-HvdName`. `-Headless` starts the Android emulator without a window (use it when a
   windowed start hangs).

### Restarting an emulator that is in use

The emulator step does not give up when the emulator is busy or hung. It stops it in three steps:

1. the polite stop: `adb -s emulator-<port> emu kill` (HarmonyOS: close the emulator window),
2. after 20 s, `taskkill /T /F` on the emulator process tree (also when the emulator is suspended and does not answer adb),
3. it removes the stale lock files of the AVD (`*.lock` in `%USERPROFILE%\.android\avd\<AVD>.avd`), because a killed
   emulator leaves them and the next start is refused ("already running").

Without `-Force` the script refuses to stop an emulator that looks busy and says why: a held `C:/w/heavy.lock`, an
instrumentation or `uiautomator` process, a running Gradle `connected*AndroidTest`, an `hdc` shell running `aa test`, or an
emulator that does not answer adb. With `-Force` it stops it anyway. Only the emulator named by `-Avd`/`-Port`/`-HvdName`
is touched; an emulator listed in `-Keep` is never stopped.

### Limits

- External monitors cannot be dimmed by `set-brightness.ps1`: Windows has no built-in command for DDC/CI. Use the monitor
  buttons or a tool such as Monitorian or ControlMyMonitor. The script handles the built-in panel of a laptop only.
- The script does not message other sessions.
- Closing Chrome, Edge, Obsidian and Android Studio asks the app to close first, so an app can still show a "save changes"
  dialog; after 8 s it is killed, unsaved work is lost.

### After the run

Tell every session on Windows and on macOS (cross-session message): "The emulators were restarted; if you were waiting for an
emulator to debug, start the emulator debugging again."

### Test record (2026-11-26, Windows)

Run on this machine with the Android AVD `CYL_Second_API_37`, headless:

| Case | Result |
|:---|:---|
| Not running: the script starts the emulator and waits for `sys.boot_completed` | pass |
| Busy (held lock file) without `-Force` | refused, exit code 1, the emulator keeps running |
| Busy with `-Force` | emulator killed, stale locks removed, started again and booted (7 s with a snapshot) |
| Hung emulator (qemu suspended, adb does not answer) with `-Force` | polite stop failed, `taskkill /T /F` killed the process tree after 20 s, restarted, booted (44 s) |
| `-Keep emulator-5558` | refused to stop it |
| `-StopOnly` | stopped, not started |
| `emulator-5556` of another session | untouched in every case |
| `stop-apps.ps1` (tested on Notepad), `close-explorer-windows.ps1` (a window opened for the test) | pass |
| `set-brightness.ps1` | dry run only: this machine has no built-in display with WMI brightness control |
| HarmonyOS part, Obsidian, Android Studio, Chrome, Edge, `-RestartShell` | dry run only: another session's emulator and the owner's apps were running, nothing was closed |

## macOS

Not written yet. A macOS session fills this section: the same steps for macOS (close the mini program devtools, the HarmonyOS
emulator, watchman, Gradle, Obsidian, Android Studio, the Android emulator, Chrome, Finder windows, Bionic, opencode, MiniMax
Code and TextExpander; shut down the inactive iOS simulators and Android emulators; lower the brightness of every display;
then tell the other sessions), as shell scripts under [scripts/release-ram](../scripts/release-ram) with an entry script in
the repository root, and a run description here like the Windows section.
