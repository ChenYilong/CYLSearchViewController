# Testing and verification (tag: `testing`)

Details of the `testing` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Verification

Run `pod install`, validate the project with Xcodeproj/CocoaPods, build and
analyze the shared scheme, and run tests when available. Do not claim a visual
reproduction or fix without launching the sample on a simulator.

- **CI/CD**: `.github/workflows/ios.yml`, modeled on CYLTabBarController's
  `ios.yml`. It runs shellcheck, the public API comment check,
  `pod lib lint`, the example build and analyzer (warnings in `Sources/` fail
  it) and the unit tests. The default macOS runner is `macos-26`; the
  `MACOS_RUNNER` variable changes it. Run the same scripts locally before
  pushing; see `docs/CI-CD.md`.
- A script added under `scripts/` must pass `shellcheck`. A workflow change
  must pass `actionlint`.

## Verification (instructions.md wording)

- Validate the CocoaPods integration, parse the Xcode project, and build the
  shared scheme for an installed simulator.
- Run static analysis when supported. Report simulator behavior as unverified
  unless the app was actually launched and exercised.
- Preserve the existing project's license and third-party notices.
- CI runs `.github/workflows/ios.yml` (see `docs/CI-CD.md`). Before pushing,
  run the same scripts locally: `scripts/ci-checkout-dependencies.sh`,
  `scripts/check-public-api-comments.sh`, `scripts/pod-lint.sh lib`,
  `scripts/ci-build-example.sh build|analyze` and `scripts/unit-tests.sh`.
- Keep `scripts/*.sh` clean under `shellcheck` and workflows clean under
  `actionlint`.

## Emulators and simulators: restart when hung (added 2026-11-18)

User's rule (2026-11-18): restarting is the first remedy, and needs no
question to the user.

- **An emulator that stays hung until it is restarted** (for example `adb`
  answers `shell echo` but `pm`, `am` and installs time out; `hdc` commands
  hang): tell the other sessions first (a message to each session that uses it:
  what hangs, that you restart it now), then restart it.
- **An emulator or simulator that does not open, or does not finish booting**:
  restart it first, before any other diagnosis.
- **Restart from the command line, without asking the user**, for example
  `adb -s emulator-5556 reboot` (or `adb -s emulator-5556 emu kill`, then
  `emulator -avd <name> -no-snapshot-load`), `hdc -t 127.0.0.1:5555 shell reboot`,
  `xcrun simctl shutdown <udid> && xcrun simctl boot <udid>`. Tell the other
  sessions again when it is back.

## Emulators and simulators: restart when hung (added 2026-11-18) (instructions.md wording)

- An emulator that stays hung until restarted: tell the other sessions first,
  then restart it.
- An emulator or simulator that does not open: restart it first.
- Restart from the command line without asking the user (`adb -s <serial>
  reboot`, `hdc -t <target> shell reboot`, `xcrun simctl shutdown` + `boot`).
  Full rule: `AGENTS.md`, "Emulators and simulators: restart when hung".

## Simulator and emulator runs: read the rules first, stop everything afterwards (added 2026-11-25)

Owner's rule (2026-11-25). Before you run a simulator or an emulator you must read this section (or the skill
`cyl-simulator-run`, or the short text in the root `AGENTS.md` / `instructions.md`).

- After a simulator test or screenshot run ends, immediately terminate the app and stop the simulator process. Start them
  again when you need them. Do not leave the app running or the simulator booted after the run, or after the task is done.
- Stop only what you started: `xcrun simctl terminate <udid> <bundle id>` then `xcrun simctl shutdown <udid>` (iOS);
  `adb -s <serial> shell am force-stop <package>` then `adb -s <serial> emu kill` (Android); stop the HarmonyOS emulator
  from DevEco Studio's Device Manager. Never `xcrun simctl shutdown all` and never stop another session's device.
- Write the code first and test once in one batch (`static-code-then-one-test-batch`), so a device boots once per batch.
- Check afterwards: `xcrun simctl list devices booted` (iOS), `adb devices` (Android).
