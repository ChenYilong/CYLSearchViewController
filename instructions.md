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

## Committing on branches

On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking for
confirmation. On `master` or `main`, ask first.

## Pull requests for new branches

Every time a branch is created, open its pull request automatically as soon as the branch is first pushed
(`gh pr create`), without asking. The base (target) branch is the branch it was created from (its source branch) by
preference; use `master` or `main` only when that is the source, or when the source branch no longer exists on the
remote. Name the base branch in the reply.
