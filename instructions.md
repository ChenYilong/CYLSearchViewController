# Folder Instructions

This repository contains the CYLSearchViewController search library, its ports and examples, and the Issue #1317
reproduction for `UISearchController` with `CYLTableViewPlaceHolder` refresh. Read this file and `AGENTS.md` before
changing project files; both keep the same tags.

The content is grouped by tag. Every category below has a short summary; its full text is in
`docs/instructions/<tag>.md`: read that file whenever the task touches the tag (tag: `meta`).

## Behavioral guidelines: read in full first (tag: `behavioral`)

- **You must read this file in full, every line, before any task:**
  [docs/instructions/behavioral.md](docs/instructions/behavioral.md). Its rules (think before coding, simplicity first,
  surgical changes, goal-driven execution) apply to every task, together with the rest of this file.

## Skills (tag: `skills`)

`.agents/skills` holds the skills (`.claude/skills` points there). Details: [docs/instructions/skills.md](docs/instructions/skills.md).

| Skill | Use it when |
|:---|:---|
| `cyl-tabbar-integration` | Adding or changing a `CYLTabBarController` in the example (configuration file, plus child view controller, latest commit) |
| `cyl-plus-button` | Writing or changing the plus button: configuration keys, title alignment, Liquid Glass limits |
| `cyl-new-project` | Creating or extending an example project |
| `cyl-api-map` | Finding the public API of `CYLTableViewPlaceHolder` and `CYLTabBarController` |
| `cyl-xcode-compat` | Touching the `.xcodeproj`, Podfile or deployment targets |
| `cyl-sub-repositories` | Adding or updating a sibling project as a sub-repository (CollectionViewClassifyMenu, CYLTableViewPlaceHolder): commit pin, core option, example, every platform |
| `cyl-license` | Any package published to a registry (CocoaPods, Maven/Gradle, npm, pub, ohpm): the MIT `LICENSE` inside its resource bundle, the manifest field, the check |
| `cyl-task-start` | Starting, scoring and finishing any task: check other sessions, `TODO` and branch at the top, the `docs/` entry with acceptance criteria, scoring until it passes, missing points as `TODO`s at the end; restarting a hung emulator |
| `cyl-docs` | Editing `README.md` or `docs/` |
| `cyl-verify` | Building, testing, running the simulator; real pointer input for scrolling and drag gestures |
| `cyl-api-parity` | Comparing two platforms' APIs: the parity table (source API, description, target counterpart, `TODO` by default), its score, and the loop to 100 |
| `cyl-fix-in-core` | Fixing any issue or bug: in the core (code published to a package registry) first; example-layer fixes only after asking, with the reason documented; the content below the search bar and its scrolling belong to the core |
| `cyl-naming` | Adding or renaming any type, function, member, constant or component: when `CYL` / `cyl_` is required, and the SonarCloud naming rules |
| `cyl-commit` | Writing any commit message: `git cz` style, English only, the author line, the checks before committing |
| `cyl-accessibility-i18n` | Screen readers and localization in any code; writing UI tests that find controls by their labels |
| `cyl-harmonyos-setup` | Preparing DevEco Studio and the HarmonyOS emulator: SDK paths, virtualization, Huawei ID, region `CN` in `country.region.xml` |
| `swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture` | Writing or translating Swift (third-party, pinned in `.agents/skills.json`) |
| `uikit`, `uikit-layouting` | UIKit views, controllers and layout in Swift (third-party) |

## How these files are organized (tag: `meta`)

- Instruction files stay within 200 lines; one always-visible heading per category with its tag; full text in
  `docs/instructions/<tag>.md`, read when the task touches the tag. New rules: full text in the tag file, one line here.
- Details: [docs/instructions/meta.md](docs/instructions/meta.md).

## Task workflow (scenario: every task) (tag: `workflow`)

- Before a task: `git pull`, read what changed in the rules since the session began, check the other sessions
  (`ListAgents`) and keep out of their files; Mac sessions take iOS, Win sessions the other platforms.
- First reply lines: `TODO (branch <branch>): <task>`. Write the task into `docs/` (the feature's document, else
  `docs/task-log.md`) as `## TODO (YYYY-MM-DD)` with Context, Requirements, Prompt (verbatim + English), Acceptance
  (100 and 60) and Status; commit and push it before the work.
- Score after each milestone; below 60 keep working; mark `DONE (YYYY-MM-DD)` with evidence; end the final reply with
  `TODO (n points): …` lines for every missing point. Skill: `cyl-task-start`.
- Details: [docs/instructions/workflow.md](docs/instructions/workflow.md) (Task log before every task; Sessions by platform: Mac for iOS, Win for the other platforms).

## Git, commits and pull requests (tag: `git`)

- **Before any git operation, read [docs/instructions/git.md](docs/instructions/git.md) in full** (every line; again
  when it changed); then run it. Read-only commands (`status`, `log`, `diff`) excepted.
- Every branch with commits has an open pull request (base: the previously active PR's branch, else `master`); more
  than two open PRs: ask first. On a branch other than `master` / `main`, commit and push without asking.
- Messages: `git cz` style `<type>(<scope>): <emoji> <subject>`, 3 to 64 characters, English only, the author line
  `By  @ChenYilong <luohanchenyilong@163.com>`; check with `scripts/check-commit-message.sh`; `touch
  .git/hooks/NO_AUTO_SYNC` first. Track unfinished items as `TODO` in `docs/`. Skill: `cyl-commit`.
- Details: [docs/instructions/git.md](docs/instructions/git.md) (Commit readiness; Commitizen commits; Committing on branches; Pull requests for new branches).

## Core architecture and fix-in-core (tag: `core`)

- The search core is `CYLSearchBar` (iOS `Sources/CYLSearchBar`; the same classes on every platform). The core is all
  code published to a registry; fix every bug there first, the example layer last and only after asking.
- The core creates and owns the content page below the search bar and its scrolling (no example lookup of it).
- Focus alone changes nothing below the search bar. Examples adapt to the Swift core. New core images live in folder
  bundles. Skill: `cyl-fix-in-core`.
- Details: [docs/instructions/core.md](docs/instructions/core.md) (Fix issues in the core first; The core owns the content below the search bar and its scrolling; Project rules; Swift core: examples adapt to the core; Core behavior: focus alone changes nothing below the search bar; Image resources: folder bundles; Search core).

## Sub-repositories and CYLTabBarController (tag: `dependencies`)

- CYLTabBarController is integrated by default (configuration file, plus button with a plus child view controller,
  raised plus button) and pinned by commit: the newest commit on any branch, the same commit ClassifyMenu pins.
- Sub-repositories (CollectionViewClassifyMenu, CYLTableViewPlaceHolder): pinned by commit on every platform; missing
  interfaces are added there first, then pinned. Skills: `cyl-tabbar-integration`, `cyl-plus-button`,
  `cyl-sub-repositories`.
- Details: [docs/instructions/dependencies.md](docs/instructions/dependencies.md) (CYLTabBarController; Sub-repositories (CollectionViewClassifyMenu, CYLTableViewPlaceHolder)).

## Animated components (tag: `animation`)

- Bugs of the animated components: record, screenshot, then fix in CYLTabBarController (never in the example).
- Animation example pages offer Play all, a speed slider and a loop switch.
- Details: [docs/instructions/animation.md](docs/instructions/animation.md) (Bugs of the animated components: record, screenshot, fix in CYLTabBarController; Animation examples: playback controls).

## Testing and verification (tag: `testing`)

- Build, test and launch before claiming a fix; CI is `.github/workflows/ios.yml`; scripts pass `shellcheck`, workflows
  `actionlint`. Test scrolling and drags with real pointer input.
- A hung or unbooted emulator is restarted from the command line without asking (tell the other sessions first).
  Skill: `cyl-verify`.
- Details: [docs/instructions/testing.md](docs/instructions/testing.md) (Verification; Emulators and simulators: restart when hung).

## Documentation, screenshots and parity tables (tag: `docs`)

- Every screenshot goes through the stitching tool with a header and a footer, lives in `docs/assets`, is shown by a
  document whose line names platform, device, OS, SDK/IDE, host, commits and date; `sh scripts/check-screenshot-labels.sh`.
- Parity tables: source API, description, target counterpart (`TODO` by default); score until 100. Projects we
  translate: their open PRs and an open-issues table. Skills: `cyl-docs`, `cyl-api-parity`.
- Details: [docs/instructions/docs.md](docs/instructions/docs.md) (API parity tables; Screenshots of builds and CI/CD; Open pull requests and issues of projects we translate).

## macOS-only: iOS, Xcode, CocoaPods (tag: `macos`)

- Xcode project format 46, iOS 15.0 everywhere, the Podfile header and one `post_install` hook; never commit `Pods/`.
- Search bars never cover a view (`testSearchBarsCoverNoView`). Issue #1317: the core's refresh API with
  `hidesSearchBarWhenScrolling = NO`. On macOS run scripts with bash, not zsh. Skill: `cyl-xcode-compat`.
- Details: [docs/instructions/macos.md](docs/instructions/macos.md) (Xcode project; Search bar placement; Issue #1317; Running scripts: prefer bash; Xcode and dependencies; Issue #1317 reproduction).

## Windows-only: HarmonyOS emulator host (tag: `windows`)

- HarmonyOS builds run from an ASCII mirror (`C:\cylbuild\harmonyos`); DevEco Studio 6.0.1, region `CN`, no signing.
- The x86_64 emulator gets the `entry@emulator` target and `-p buildMode=emulatorTest` (no arm64-only Rive and PAG
  libraries); owner of the plan: CYLTabBarController's `cylanimateditem`. Skill: `cyl-harmonyos-setup`.
- Details: [docs/instructions/windows.md](docs/instructions/windows.md) (HarmonyOS: IDE preparation and emulator prerequisites; HarmonyOS: HAPs for the x86_64 emulator leave out the arm64-only Rive and PAG libraries).

## HarmonyOS (tag: `harmonyos`)

- API and example 1:1 with iOS, internals ported from the Android Kotlin sources; HarmonyOS 6.0.1 (API 21), ArkUI V2.
- Rive and PAG tests that need arm64: plan 1 (x86_64 builds in `cylanimateditem`, debug guard until the user approves
  removing it), else plan 2 (the macOS session). Skill: `cyl-harmonyos-setup`.
- Details: [docs/instructions/harmonyos.md](docs/instructions/harmonyos.md) (HarmonyOS: API and example 1:1 with iOS, internals from the Android Kotlin sources; HarmonyOS: Rive and PAG tests that need arm64, two plans).

## WeChat mini program (tag: `miniprogram`)

- The example is a 1:1 copy of the iOS example (texts, data and images imported from the iOS bundles); the core
  components take what the example needs. Use `wechatide-skill` for every build, run, automation and screenshot.
- Details: [docs/instructions/miniprogram.md](docs/instructions/miniprogram.md) (Mini program example: a 1:1 copy of the iOS example).

## Accessibility and localization (tag: `accessibility-i18n`)

- All code supports screen readers and is localized from localization files; fix a gap first. UI tests find
  controls by accessibility label or localized text before ids and coordinates. Skill: `cyl-accessibility-i18n`.
- Details: [docs/instructions/accessibility-i18n.md](docs/instructions/accessibility-i18n.md) (HarmonyOS: screen readers and localization; Accessibility, localization and UI automation by label; Accessibility and localization on every platform; UI tests locate controls through them).

## Licenses in published packages (tag: `licenses`)

- Every published package ships the MIT `LICENSE` (Copyright (c) 2015 ChenYilong) inside its resource bundle;
  check with `bash scripts/check-licenses.sh`. Skill: `cyl-license`.
- Details: [docs/instructions/licenses.md](docs/instructions/licenses.md) (Licenses in published packages).

## Code style: naming, Swift, API comments (tag: `code-style`)

- `CYL` prefix for new types, `+CYL` / `cyl_` for categories; do not rename existing APIs. Swift follows
  `docs/swift-coding-standard.md`. Public API comments are one three-line documentation block in the language's official
  form (`/*!` Objective-C, `/**` Swift, Kotlin, Java, TS, JS); `scripts/check-public-api-comments.sh`.
- Details: [docs/instructions/code-style.md](docs/instructions/code-style.md) (Swift; Comments on public API; Naming).
