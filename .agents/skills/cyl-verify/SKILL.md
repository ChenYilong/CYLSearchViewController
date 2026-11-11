---
name: cyl-verify
description: "Install, build, analyze, and test the search sample and its local CocoaPods dependency."
---

# Verify

1. Run `pod install` from the repository root.
2. Parse the project using `ruby -rxcodeproj -e 'Xcodeproj::Project.open(ARGV[0])' CYLSearchExample.xcodeproj`.
3. Build the shared scheme from the generated workspace. Confirm the app and
   tests use iOS 15.0, and the Podfile post-install hook sets all Pods targets
   to iOS 15.0.
4. Run `xcodebuild analyze` and the test action when available.
   Check the public API comments (`AGENTS.md`, "Comments on public API"):
   every comment on a public declaration in `Sources/**/*.h` is a three-line
   `/*!` / ` * …` / ` */` block above it, one-line comments included; none is
   written on one line; there is no trailing `/**< */`, `/*!< */`, `///<` or
   `//`; and each public file uses one format. Quick check:
   `grep -nE '///|/\*[*!]<|/\*!.*\*/|;\s*//|,\s*//' Sources/CYLSearchViewController/*.h`
   must print nothing.
5. Launch and exercise the sample before claiming that the UI reproduces the
   issue or verifies its workaround.

Report build warnings, unavailable simulator checks, and any toolchain override
plainly. Do not commit generated Pods or `._*` files.

## CYLTabBarController

Adapted from CYLTabBarController's `cyl-verify` skill (commit `caf3c92`).

- Before every build, run `scripts/latest-cyl-commit.sh` again. The Podfile
  must pin exactly that sha (`:git => …, :commit => '<sha>'`); update it and
  run `pod install` when it changed. Name the sha, date and branch in the
  report; if the fetch fails, say so and keep the pinned sha.
- Build into an empty derived data folder (delete it or pass a new
  `-derivedDataPath`) after a dependency change; check a new symbol with
  `strings <app>/<binary> | grep <symbol>` when in doubt.
- Static analysis must report no warnings.
- On a simulator, check that the tabs and the plus button come from the
  configuration file, the plus button opens the plus child view controller,
  and VoiceOver reads every tab and the plus button. Report it as unverified
  when no simulator was run.

| Symptom | Cause | Fix |
|:---|:---|:---|
| A tab is missing | Its page ID has no registered provider | Register it before creating the controller; read the returned `NSError` |
| No plus child view controller | `CYLTabBarItemPageIdentifier` missing in `CYLTabBarControllerPlusButton`, or no provider | Add both |
| `cannot find ... in scope` after a pod update | Stale `Pods/` | `pod install` |
| `pod install`: `Unicode Normalization not appropriate for ASCII-8BIT` | No UTF-8 locale | `LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 pod install` |
| `-[UIApplication statusBarStyle] ... no-op` | `UIViewControllerBasedStatusBarAppearance = NO` | Remove the key |
| Simulator taps do nothing | Simulator input stuck | Shut down, boot, retry |
