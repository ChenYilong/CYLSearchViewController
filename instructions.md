# Folder Instructions

This repository contains an Objective-C search UI sample and the Issue #1317
reproduction for `UISearchController` with `CYLTableViewPlaceHolder` refresh.
Read this file and `AGENTS.md` before changing project files.

## Naming

- Write all instruction and skill files in English.
- Prefix every new project-owned class, protocol, enum, type, function, and
  constant with `CYL`. Name a class file after its primary type.
- Name UIKit category files `<SystemClass>+CYL<Feature>.h` and `.m`; prefix
  every new category method and property with `cyl_`.
- Apply these rules to copied or newly introduced code. Remove unrelated
  third-party prefixes from new code and retain source attribution.
- Do not rename existing project APIs or vendor code as part of unrelated
  changes.

## Swift

- Write Swift by `docs/swift-coding-standard.md` and the Swift skills in `.agents/skills` (pinned third-party
  copies listed in `.agents/skills.json`; do not edit them).
- The core is being translated to Swift; record each step and its score in `docs/swift-migration.md`.
- Keep Objective-C class names and selectors with `@objc(...)`; change the example only where Objective-C cannot use
  the Swift class directly (for example an Objective-C subclass of a core class).

## Comments on public API

- All comment formats follow the official documentation rules of their
  language. The rules below choose among the officially allowed forms; where
  one contradicts an official rule, the official rule wins.
- A multi-line comment on a public declaration is one documentation block,
  never stacked single-line comments, right above the declaration.
- The format requirements above for multi-line public API comments also apply
  to single-line public API comments. Where the block form is officially
  allowed, a one-line comment is written on three lines above the declaration
  (`/*!`, ` * Text.`, ` */`). Never write it on one line (`/*! Text. */`), and
  never add a trailing `/**< */`, `/*!< */`, `///<` or `//` after a
  declaration or an enum value.
- In a file that contains public API, keep the comment format uniform: one
  format for long and short comments.
- This applies to all platforms and all languages:
  - Objective-C `/*! */`.
  - Swift, Kotlin, Java, TypeScript and JavaScript `/** */`.
  - Python: PEP 257 docstrings.
  - Go `//`, C# `///` with XML tags, Rust `///`, Dart `///`: these are the
    official forms.

  A language with no block form uses its only documentation comment form
  throughout the file. Full rule and sources: `AGENTS.md`, "Comments on
  public API".

## Xcode and dependencies

- Keep `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`.
- Keep explicit project file references; do not use synchronized folder groups.
- For any Xcode project, inspect the Podfile before building or changing
  project settings. Its top section must declare the iOS 15.0 platform, Swift
  5, and the `.xcodeproj` file in the same directory:

  ```ruby
  platform :ios, '15.0'

  ENV['SWIFT_VERSION'] = '5'

  project '<projectname>.xcodeproj'
  ```

- Ensure the Podfile ends with this `post_install` hook. Add it at the bottom
  only if it is missing; do not add duplicate hooks:

  ```ruby
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings["IPHONEOS_DEPLOYMENT_TARGET"] = "15.0"
      end
    end
  end
  ```

- Keep all app and test Xcode deployment targets at iOS 15.0 to match the
  Podfile and generated Pods project.
- Check that the app target has a populated AppIcon asset set and a launch
  screen storyboard/image configured through `UILaunchStoryboardName`. If
  either is missing, copy the icon and custom launch image from
  `CYLTabBarController/Example/Images.xcassets` and wire them into the target.
- Install dependencies with CocoaPods and open the generated workspace.
- Import the dependency's public umbrella header. Do not access its private
  implementation.
- Keep sample behavior behind protocols or public configuration rather than
  coupling library code to this app, `AppDelegate`, or a concrete data source.

## Search bar placement

- A search bar never covers any view, at any time: not a view controller's
  view (`self.view`), not a sibling, a background view or a bar item; for a
  navigation-item search controller, `CYLSearchBarView` and the overlay; in
  every state and at every Dynamic Type size. Views of search screens do not
  extend under the top bar (`edgesForExtendedLayout` without
  `UIRectEdgeTop`); a `CYLSearchBarView` is laid out against the safe area,
  beside the content, never on top of it, and a colored area behind it ends
  where the bar begins. `testSearchBarsCoverNoView` checks every search bar
  with `CYLViewsCoveredByView`; add each new one there.

## Issue #1317 reproduction

- The sample combines a navigation-item `UISearchController` with a
  `CYLRefreshNormalHeader`.
- Keep `navigationItem.hidesSearchBarWhenScrolling = NO` in the safe default
  reproduction. Setting it to `YES` is the documented trigger to investigate;
  it may cause repeated inset updates on affected UIKit versions.
- End refresh on every completion path and avoid strong captures of view
  controllers in refresh blocks.

## CYLTabBarController

Adapted from CYLTabBarController's instruction files at its latest commit
(`caf3c92`, branch `feat/cross-platform-components`). Details and the status
(the example integration is done): `docs/CYLTabBarController-Integration.md`.

- This project integrates CYLTabBarController by default. Unless a task says
  otherwise, every `CYLTabBarController` in the example layer:
  1. is created from a local configuration file shipped in the app bundle,
     with `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]`;
  2. has a plus button declared in that file under
     `CYLTabBarControllerPlusButton`, whose `CYLTabBarItemPageIdentifier`
     resolves to the plus child view controller;
  3. gets its pages from providers registered in `CYLTabBarPageRegistry` for
     each `CYLTabBarItemPageIdentifier`, not from a hard-coded array.
- Keep an even number of normal tabs so the plus button sits in the middle;
  set `CYLPlusButtonIndexInTabBar` otherwise. The plus button is not counted
  in the tab items.
- Give the plus button a title when titles are aligned with the tab titles.
- Depend on the newest CYLTabBarController commit on any branch:
  `scripts/latest-cyl-commit.sh --podfile` prints the Podfile line
  (`:git => …, :commit => '<sha>'`). Refresh it before every build; never use
  a version number, branch or tag.
- Import only `<CYLTabBarController/CYLTabBarController.h>`.
- Put search pages inside a `UINavigationController` tab so the
  navigation-item search controller and its Issue #1317 workaround still
  apply.
- Example layer, raised plus button: when an example demonstrates a plus button, always prefer the raised effect, where the top of the plus button rises above the top edge of the tab bar (for example `CYLPlusButtonCenterYMultiplier` below 0.5 with a button taller than half the bar, or `CYLPlusButtonCenterYOffset`); keep it fully tappable (`touchableRect`) and never let it cover the page content above the bar.
- Follow the `cyl-tabbar-integration` and `cyl-plus-button` skills.

## Sub-repositories (CollectionViewClassifyMenu, CYLTableViewPlaceHolder)

- A sibling project in the same local folder used by this library is a sub-repository. The requirements set for
  CollectionViewClassifyMenu apply to all of them: iOS depends on its root podspec as a sub-dependency; other
  platforms depend by commit (or build the commit from source); pin the newest commit on any branch; a local path
  only while developing, never committed; add the feature to the core with an enum or a parameter (add missing
  interfaces in the sub-repository, push them, then update the pin); the example shows every style and passes only
  data, style parameters and click handling.
- CollectionViewClassifyMenu: suggestions as tags (`docs/tag-view-suggestions.md`).
- CYLTableViewPlaceHolder is integrated as a sub-repository under all the requirements above: when a search has no
  results, show its empty-content placeholder style, on every platform (iOS, Android, React Native, Flutter,
  HarmonyOS, mini programs). Status `TODO` in `docs/sub-repositories.md`. Full rule: `AGENTS.md`, same section;
  skill `cyl-sub-repositories`.

## Verification

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

## Task log before every task

Before starting any task, find the most suitable document in `docs/` (the
feature's own document, else `docs/task-log.md`) and add the task there as
`TODO`: the detailed context, every requirement the user gave, and the user's
prompt quoted verbatim with an English translation, plus a status line. Commit
and push it, then start. When the task ends, change `TODO` to
`DONE (YYYY-MM-DD)` with the result and the evidence. The purpose: an
interrupted task never loses its context. Full rule: `AGENTS.md`, "Task log
before every task".

## Screenshots of builds and CI/CD

- Commit every screenshot (local builds and runs, CI/CD runs) and show it in the related `docs/` document (images in
  `docs/assets/`; create a document when none fits). Use clear original pixels, cropped to the detail.
- Label each one with the platform (iOS, Android, Flutter, React Native, HarmonyOS, mini program), the environment
  (host OS version, simulator or emulator and its OS version, platform SDK version), this repository's version or
  commit link, and the date and time with the time zone.
- At key milestones (a `TODO` or `Linux` note can be removed, a PR can be merged, the result works with no known
  bug or open issue), update the screenshot section of `README.md` (create it if missing) with cropped key details
  stitched into one image: stacked top to bottom first, then two columns, then one row of at most three.
- Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.
- Full rule: `AGENTS.md`, "Screenshots of builds and CI/CD".

## Open pull requests and issues of projects we translate

- When a document links to another project's GitHub repository whose code we translate or port (for example
  `android/`), also take its open pull requests: merge them before translating, or translate and merge them when
  the translation is already done.
- List that project's open issues in a `docs/` table (issue link, description, fix status `TODO`), fix each one in
  our code (`DONE` with the commit, or `N/A` with the reason), and score after every fix until 100. A translation
  that has not started begins once the issue score reaches 60. Every platform follows this rule.
- Full rule: `AGENTS.md`, "Open pull requests and issues of projects we translate".

## Commit readiness

- Before every commit, review the changed scope and related issue, comparison,
  and implementation-status documents. Record every unfinished or unverified
  item from the commit under a `TODO` heading in the most relevant existing
  document under `docs/`.
- A TODO must state the current status or score, remaining work, implementation
  constraints, known defects or optimization opportunities, API design and
  compatibility concerns, and verification required for completion. Reserved
  keys, stubs, and compilation alone are not evidence of completion.
- Every commit message body carries the author line
  `By  @ChenYilong <luohanchenyilong@163.com>` (two spaces after `By`), after
  the description and before trailers.
- Use an English Conventional Commit subject compatible with Commitizen.
  Summarize completed work in the subject and keep details and remaining work
  in the body. If the detailed description exceeds 50 characters, create or
  update a suitable document under `docs/` and link it from the commit body.
  Reuse relevant documents and avoid duplicate trackers.

### Commitizen defaults

- Use `{type}{scope}: {emoji}{subject}` with emojis enabled. Omit an unnecessary
  scope; no scopes are preconfigured. The configured message length is 3–64
  characters. In readable subjects, separate the emoji and subject with a
  space as shown in the project examples below.
- The interactive type choices, in order, are `test`, `feat`, `fix`, `chore`,
  `docs`, `refactor`, `style`, `ci`, and `perf`. `release` has a type definition
  but is not an interactive choice; use it only for an intentional release.
- Default meanings and emojis: `chore` (build or auxiliary-tool changes, 🤖),
  `ci` (CI changes, 🎡), `docs` (documentation only, ✏️), `feat` (new feature,
  🎸), `fix` (bug fix, 🐛), `perf` (performance improvement, ⚡️), `refactor`
  (neither a feature nor a fix, 💡), `style` (markup or formatting only, 💄),
  `test` (adding missing tests, 💍), and `release` (release commit, 🏹).
- The question sequence is `type`, `scope`, `subject`, `body`, `breaking`,
  `issues`, and `lerna`. Prompts request the type, optional scope, short
  imperative subject, longer description, breaking changes, issues closed
  (for example `#123`), and affected packages.
- Respect established repository history when it uses project-specific
  mappings. CYLTabBarController examples include `feat: ✨`, `fix: 🐛`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`. Commit text must remain English.

### Commit-message hook before Commitizen commits

Before a Commitizen-style commit, run the following from the repository root:

```sh
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/sh
tmpfile="$1"
if grep -qi "Co-Authored-By:" "$tmpfile" 2>/dev/null; then
  tmp_clean=$(mktemp)
  grep -vi "Co-Authored-By:" "$tmpfile" > "$tmp_clean"
  cat "$tmp_clean" > "$tmpfile"
  rm -f "$tmp_clean"
fi
HOOKEOF
chmod +x .git/hooks/commit-msg
```

This overwrites the existing `commit-msg` hook and removes every line containing
`Co-Authored-By:`, case-insensitively, including other authors' attribution.
Inspect any existing hook before replacing it. The command assumes `.git` is
a directory and Git uses its default hooks path; linked worktrees and custom
`core.hooksPath` require the appropriate hooks path instead.

## Commitizen commits

Before every Commitizen-style (`git cz`) commit, run this first in the repository root:

```sh
touch .git/hooks/NO_AUTO_SYNC
```

Rule (added 2026-11-16): every commit is a `git cz` (Commitizen) style commit, and the whole commit message (subject,
body and trailers) is in English: no Chinese characters (or any other non-English text) are allowed anywhere in it. Check a message with
`scripts/check-commit-message.sh <file>` (or `git log -1 --format=%B | scripts/check-commit-message.sh -`). Skill:
`cyl-commit`. Full rule: `AGENTS.md`, "Commit readiness".

## Committing on branches

On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking for
confirmation. On `master` or `main`, ask first.

## Pull requests for new branches

- **Every branch with commits has an open pull request (added 2026-11-16).** Never create a branch and keep committing
  to it without a pull request: commits on a branch without a pull request are ignored, they are never reviewed or
  merged.
  - Before every commit, check that the branch has an open pull request (`gh pr list --head <branch> --state open`).
    If it has none, open one.
  - Target (base) of a new pull request: the pull request that was active before this one (its head branch) first;
    `master` only when there is none.
  - When more than two pull requests are already open, stop and ask the user whether to create a new branch with a
    pull request or keep committing on the current branch: more than two open branches make merging hard and leave no
    sensible target branch for each.
  - At the end of every exchange (one question and its answer), when the current branch is not `master` / `main`,
    commit and push without asking: the work is always on a branch, never pushed to `master` / `main`, so pushing is
    safe and carries no risk to worry about.

Every time a branch is created, open its pull request automatically as soon as the branch is first pushed
(`gh pr create`), without asking. The base (target) branch is the branch it was created from (its source branch) by
preference; use `master` or `main` only when that is the source, or when the source branch no longer exists on the
remote. Name the base branch in the reply.

## HarmonyOS: API and example 1:1 with iOS, internals from the Android Kotlin sources (added 2026-11-16)

- HarmonyOS version: HarmonyOS NEXT, target HarmonyOS 6.0.1 (API 21), compatible from HarmonyOS 6.0.1 (API 21; the minimum of CYLTableViewPlaceHolder's cylplaceholder);
  ArkTS with ArkUI state management V2; DevEco Studio 6.0.1 and its bundled SDK.
- The API of `harmonyos/cylsearch` matches the iOS public API; the example `harmonyos/entry` replicates
  `CYLSearchExample` one to one (tabs, pages, texts, data, images, interactions; resources imported by
  `harmonyos/scripts/import-ios-resources.py`). The internals are migrated from the Android Kotlin sources
  (`android/`), not written anew. Full rule: `AGENTS.md`, same section; scorecard: `docs/harmonyos-cross-platform.md`.

## HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)

- Before the first HarmonyOS build or run on a machine, follow the `cyl-harmonyos-setup` skill.
- IDE: DevEco Studio 6.0.1 with its bundled SDK (API 21), signed in with a Huawei ID; for command-line builds set
  `DEVECO_SDK_HOME` and put `jbr\bin` and `sdk\default\openharmony\toolchains` (`hdc`) on `PATH`; build from an
  ASCII path without spaces (hvigor).
- Emulator prerequisites: 64-bit Windows 10 or 11 (or Apple silicon); CPU virtualization on; Hyper-V, Windows
  Hypervisor Platform and Virtual Machine Platform on; 16 GB RAM at least; Huawei ID sign-in; region China.
- Region: the developer is in New Zealand, but the emulator needs the region China. With DevEco Studio closed,
  `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml` must say `<countryregion name="CN"/>` (not `NZ`);
  check it before creating an emulator. Full rule: `AGENTS.md`, same section.
- Signing: emulator runs and tests need no signing. Install the unsigned HAPs with `hdc install`; do not configure
  `signingConfigs` or ask for a certificate unless the user asks for a device or release build (2026-11-16).

## HarmonyOS: screen readers and localization (added 2026-11-16)

- Every tappable element of the library has a screen-reader label in the app's language, touch areas are at least
  44 vp, list items read their position and selected state, and state changes are announced.
- No English text in the library's UI code. en, ja, zh-Hans and zh-Hant come from iOS; other languages are copied
  from CYLTabBarController's string table, filtered to the texts this project uses
  (`harmonyos/scripts/import-cyltabbar-localizations.mjs`). Check with `harmonyos/scripts/check-accessibility-i18n.mjs`.
  Full rule: `AGENTS.md`, same section.

## Accessibility, localization and UI automation by label (added 2026-11-16)

- All code of this project supports visual assistance and blind users (screen readers) and is internationalized
  and localized with localization files, the HarmonyOS code included.
- When something is not supported, support it first.
- In automated UI tests, locate controls by those features first: their accessibility labels and localized texts,
  read from the app's string resources in the device language (an id only when a control has no label). Use them
  to trigger taps, complex flows and continuous operations.
- Skill: `cyl-accessibility-i18n`. Full rule: `AGENTS.md`, same section.

## Mini program example: a 1:1 copy of the iOS example (added 2026-11-15)

- The mini program example replicates `CYLSearchExample` one to one (tabs, pages, texts in en/ja/zh-Hans/zh-Hant,
  data, images, interactions), with the iOS resources imported by `scripts/import-ios-resources.js`. A change to the
  iOS example changes the mini program example in the same task; missing behavior goes into the core components.
  Full rule: `AGENTS.md`, same section; mapping and platform differences: `docs/miniprogram-api-alignment.md`.

## Swift core: examples adapt to the core (added 2026-11-13)

- When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides.

## Core behavior: focus alone changes nothing below the search bar (added 2026-11-13)

- Focusing the search field (cursor shown, keyboard up) without typing changes nothing below the search bar: the area under it (the cached queries and their header, the suggestions, the empty placeholder) looks exactly as it does while the field is not focused. That area is updated only when the person changes the text (typing, deleting, pasting, the clear button, a selected suggestion) or when its data changes (a submitted query, the cache cleared). Rule list: `docs/core-todo.md`, "Core behavior rules".

## Accessibility and localization on every platform; UI tests locate controls through them (added 2026-11-16)

- All code of this project (the core, every port and every example, HarmonyOS included) supports visual accessibility
  and screen readers for blind users (VoiceOver, TalkBack, HarmonyOS ScreenReader), and internationalization /
  localization through localization files. Every control a user can tap or read has an accessibility label (and a hint
  where the action is not obvious), tappable rows are one accessibility element, and every user-facing text comes from
  a localization file, never a hard-coded string (HarmonyOS: `$r('app.string.…')` in `resources/<locale>/element/string.json`;
  translations shared with CYLTabBarController are copied from its `CYLTabBarController.bundle/*.lproj`).
- If something turns out not to support them, add the support first, then continue the task.
- In automated UI tests, locate controls through these features first: accessibility identifiers / labels (iOS
  `accessibilityIdentifier` / `accessibilityLabel`, Android `contentDescription`, HarmonyOS `.id()` /
  `accessibilityText`, `ON.id` / `ON.accessibilityText`), then localized text. Use them to trigger taps, complex flows and
  series of actions; coordinates are the last resort.

## Running scripts: prefer bash (added 2026-11-16)

- Run scripts with bash first: write them as `#!/usr/bin/env bash` files and run them with `bash script.sh`, or pipe
  a heredoc to `bash` (`bash <<'EOF' … EOF`), instead of typing them straight into the interactive shell.
- Reason: the default shell here is zsh, and zsh does not split an unquoted variable into words. For example, with
  `box="10 20 30 40"`, `sips --cropOffset $box …` passes one argument in zsh but four in bash. The error this rule
  avoids: "zsh doesn't split $box into words either. Running the same measurement as a bash script."
- In zsh, when a script cannot be used, split explicitly (`${=box}`) or use an array; never rely on word splitting.
