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
   `//`; each public file uses one format; and the format is the official one
   of its language (table in `AGENTS.md`). Quick check:
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

## CI/CD

`.github/workflows/ios.yml` runs on pull requests, pushes to `master` and
`claude/**`, and manual runs (details: `docs/CI-CD.md`). The same steps run
locally:

```sh
scripts/ci-checkout-dependencies.sh        # sibling CYLTableViewPlaceHolder at ../
scripts/check-public-api-comments.sh       # AGENTS.md, "Comments on public API"
scripts/pod-lint.sh lib --verbose
rm -rf build && scripts/ci-build-example.sh build
scripts/ci-build-example.sh analyze        # warnings in Sources/ fail CI
scripts/unit-tests.sh "iPhone 17"
shellcheck scripts/*.sh && actionlint
```

Name the environment in every report: the GitHub runner (`macos-26` unless
`MACOS_RUNNER` is set) or the local macOS and Xcode versions.

### Screenshots

Every local build or run screenshot and every CI/CD screenshot is committed and shown in the related `docs/`
document (`docs/assets/`, create a document when none fits), as a clear original, labeled with:

- the platform (iOS, Android, Flutter, React Native, HarmonyOS, mini program);
- the environment: host OS version and build, simulator or emulator and its OS version, platform SDK version;
- this repository's version or commit link;
- the date and time, with the time zone.

Take them at key milestones: a `TODO` or `Linux` note can be removed, a PR can be merged, or the result works with
no known bug or open issue. Then update `README.md` (see `cyl-docs`). Stitch with
`swift scripts/stitch-screenshots.swift --columns 1 --out <file> <images…>`. Full rule: `AGENTS.md`, "Screenshots
of builds and CI/CD".

## Search bar placement

A search bar never covers the main view, the view controller's view
(`self.view`), or any other view, at any time: a navigation-item
`UISearchController`, a `CYLSearchBarView` and the overlay, in every state and
at every Dynamic Type size. Full rule: `AGENTS.md`, "Search bar placement".

- Check frames in a window, not in a detached view: `testSearchBarsCoverNoView`
  (`CYLViewsCoveredByView`) runs every search bar with
  `hidesSearchBarWhenScrolling` NO and YES and at the largest text size.
- On the simulator, look at the first rows and the refresh header under the
  search field: nothing may sit behind it.

## Pull requests

Every new branch gets a pull request as soon as it is first pushed, without
asking (`gh pr create`). The base branch is the branch it was created from;
use `master` or `main` only when that is the source or the source branch no
longer exists on the remote. Full rule: `AGENTS.md`, "Commit readiness".

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

## Swift

Swift code follows `docs/swift-coding-standard.md` and the third-party Swift skills in `.agents/skills`
(`swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`,
`uikit`, `uikit-layouting`). The core's translation and its score: `docs/swift-migration.md`.

## Open pull requests and issues of projects we translate

When we translate or port another GitHub project's code (for example `android/`), merge its open pull requests
(before translating, or translate and merge them afterwards), list its open issues in a `docs/` table (issue link,
description, fix status `TODO`), fix them in our code and score after every fix until 100; a translation that has not
started begins at 60. Full rule: `AGENTS.md`, same section.

## Screenshot stitching order

Stitched screenshots: stacked top to bottom first, then two columns over several rows, then one row of at most
three. Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.

## Swift core: examples adapt to the core (added 2026-11-13)

When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides. Rule and context: [docs/swift-migration.md](../../../docs/swift-migration.md).

## HarmonyOS

Before the first HarmonyOS build or emulator run on a machine, follow `cyl-harmonyos-setup`: DevEco Studio 6.0.1
and its SDK paths, the emulator prerequisites (virtualization, Hyper-V, Huawei ID), and the region set to China in
`country.region.xml` (`<countryregion name="CN"/>`, not `NZ`). Report a HarmonyOS run as unverified when no emulator
or device was used.

Without an emulator, run the pure logic of the HarmonyOS core on the host: `node harmonyos/scripts/host-logic-test.mjs`
(Node 22.18 or newer). Keep `harmonyos/cylsearch/src/main/ets/CYLSearchLogic.ets` free of kit imports so it runs there.
Check that the HarmonyOS strings and placeholder images still match iOS after any iOS resource change:
`node harmonyos/scripts/check-ios-parity.mjs` (exit code 1 lists what is missing or different).
Check the HarmonyOS screen-reader labels, touch areas and localization: `node harmonyos/scripts/check-accessibility-i18n.mjs`.
After CYLTabBarController's string table changes, run `node harmonyos/scripts/import-cyltabbar-localizations.mjs` again.
UI tests find controls by their accessibility labels and localized texts first (skill `cyl-accessibility-i18n`); a
control a test cannot find by label is a screen-reader gap to fix in the app first.

## Running scripts: prefer bash (added 2026-11-16)

- Run scripts with bash first: write them as `#!/usr/bin/env bash` files and run them with `bash script.sh`, or pipe
  a heredoc to `bash` (`bash <<'EOF' … EOF`), instead of typing them straight into the interactive shell.
- Reason: the default shell here is zsh, and zsh does not split an unquoted variable into words. For example, with
  `box="10 20 30 40"`, `sips --cropOffset $box …` passes one argument in zsh but four in bash. The error this rule
  avoids: "zsh doesn't split $box into words either. Running the same measurement as a bash script."
- In zsh, when a script cannot be used, split explicitly (`${=box}`) or use an array; never rely on word splitting.
