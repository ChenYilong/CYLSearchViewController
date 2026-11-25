---
name: cyl-simulator-run
description: "Running an iOS simulator or Android/HarmonyOS emulator: read the run rules first, and stop the app and the simulator process when the test or screenshot run ends."
---

# Simulator and emulator runs

Read this before you boot or use any simulator or emulator. Full rule:
`docs/instructions/testing.md`, "Simulator and emulator runs: read the rules first, stop everything afterwards".

## Rule (owner, 2026-11-25)

After a simulator test or screenshot run ends, immediately terminate the app and stop the simulator process. Start them
again when you need them. Never leave the app running or the simulator booted after the run or after the task is done.

## Steps

1. Before the run: read this skill (or the testing rule above); boot only the device you need, by its UDID or serial.
2. Run the tests or take the screenshots in one batch (`static-code-then-one-test-batch`: write the code first, test once).
3. Right after the last screenshot or test result:
   - iOS: `xcrun simctl terminate <udid> <bundle id>`, then `xcrun simctl shutdown <udid>`.
   - Android: `adb -s <serial> shell am force-stop <package>`, then `adb -s <serial> emu kill`.
   - HarmonyOS: `hdc -t <target> shell aa force-stop <bundle name>`, then stop the emulator from DevEco's Device Manager
     (or `hdc -t <target> shell reboot` is NOT a stop; use the emulator's own stop).
4. Check nothing is left: `xcrun simctl list devices booted` (iOS), `adb devices` (Android).
5. Boot again only when the next run needs it.

## Never

- Never `xcrun simctl shutdown all` or kill another session's device: stop only the UDID or serial you started (other
  sessions share the machine; tell them first when one of theirs hangs, see `cyl-task-start`).
- Never leave a booted simulator, a running emulator or an app in the foreground "for later".
