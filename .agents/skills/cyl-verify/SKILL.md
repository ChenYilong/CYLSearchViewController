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
