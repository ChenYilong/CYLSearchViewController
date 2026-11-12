# Agent Instructions

This repository is an Objective-C iOS search sample. It uses
`CYLTableViewPlaceHolder` to demonstrate the interaction between a
navigation-item search controller and pull-to-refresh. Read `instructions.md`
and the applicable skill in `.agents/skills/` before making changes.

## Skills

`.agents/skills` holds the skills; `.claude/skills` only points there.

| Skill | Use it when |
|:---|:---|
| `cyl-tabbar-integration` | Adding or changing a `CYLTabBarController` in the example (configuration file, plus child view controller, latest commit) |
| `cyl-plus-button` | Writing or changing the plus button: configuration keys, title alignment, Liquid Glass limits |
| `cyl-new-project` | Creating or extending an example project |
| `cyl-api-map` | Finding the public API of `CYLTableViewPlaceHolder` and `CYLTabBarController` |
| `cyl-xcode-compat` | Touching the `.xcodeproj`, Podfile or deployment targets |
| `cyl-sub-repositories` | Adding or updating a sibling project as a sub-repository (CollectionViewClassifyMenu, CYLTableViewPlaceHolder): commit pin, core option, example, every platform |
| `cyl-docs` | Editing `README.md` or `docs/` |
| `cyl-verify` | Building, testing, running the simulator |
| `swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture` | Writing or translating Swift (third-party, pinned in `.agents/skills.json`) |
| `uikit`, `uikit-layouting` | UIKit views, controllers and layout in Swift (third-party) |

Every new integration rule updates, in the same change, `AGENTS.md`,
`instructions.md` and the affected skills.

## Project rules

- New project-owned types and identifiers use the `CYL` prefix. New UIKit
  category files use `+CYL`; category methods and properties use `cyl_`.
- Do not rename existing APIs or vendor symbols in a task that does not require
  it. Keep original copyright and attribution when adapting third-party code.
- The public integration surface of `CYLTableViewPlaceHolder` is its umbrella
  header. The example must not depend on private headers or implementation
  details.
- Keep the sample configurable through protocols or public properties. Avoid
  dependencies on `AppDelegate`, global state, or concrete model types.
- Keep all instructions and skill files in English.

## Swift

The core moves from Objective-C to Swift (`docs/swift-migration.md`, scored after every commit). All Swift code
follows `docs/swift-coding-standard.md` and the Swift skills in `.agents/skills` (`swift-api-design-guidelines`,
`swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`, `uikit`, `uikit-layouting`; third-party,
pinned in `.agents/skills.json`, never edited by hand). Public Swift API keeps the Objective-C class names and
selectors (`@objc(...)`), so Objective-C callers keep working; documentation comments are three-line `/** */`
blocks.

## Comments on public API

Callers read a public API's comment through the IDE's documentation (Xcode
Quick Help, the generated Swift interface, Android Studio, editor hovers).
Only a documentation comment gets there whole. The multi-line rule is adapted
from CYLTabBarController's `AGENTS.md`, "Comments on public API" (commit
`63c0edc`). The rules below are this project's own and win over upstream.

- **The official rules decide.** Every comment format follows the official
  documentation rules of its language. The rules below choose among the forms
  an official rule allows. Where a rule below contradicts an official rule,
  the official rule wins.
- **Multi-line comments on public API are one documentation block**, never
  stacked single-line comments, right above the declaration with nothing in
  between.
- **Single-line comments use the block format too.** The format requirements
  for multi-line public API comments also apply to single-line public API
  comments. In a language whose block form is officially allowed, a one-line
  comment is still three lines above the declaration:

  ```objc
  /*!
   * Text.
   */
  - (void)example;
  ```

  - Never put the block on one line (`/*! Text. */`).
  - Never add a trailing comment after a declaration or an enum value:
    no `/**< */`, `/*!< */`, `///<` or `//`.
- **One comment format per public file.** In a file that contains public API,
  every documentation comment uses the same format, long or short.
- **All platforms and all languages.** Use the official documentation form of
  each language:

  | Language | Format | Official source |
  |:---|:---|:---|
  | Objective-C, C, C++ headers | `/*!` … ` * ` … ` */` | Xcode Quick Help / HeaderDoc (Apple) |
  | Swift | `/**` … ` * ` … ` */` (Swift does not read `/*!`) | Swift Markup, DocC (allows `///` and `/** */`) |
  | Kotlin | `/**` … ` * ` … ` */` | KDoc (kotlinlang.org) |
  | Java | `/**` … ` * ` … ` */` | Javadoc (Oracle) |
  | TypeScript | `/**` … ` * ` … ` */` | TSDoc |
  | JavaScript | `/**` … ` * ` … ` */` | JSDoc |
  | Python | Triple double-quoted docstring as PEP 257 says: a one-line docstring keeps its quotes on the same line; a multi-line docstring is a summary line, a blank line, then the closing `"""` on its own line | PEP 257 |
  | Go | `//` line comments right above the declaration, no blank line | Effective Go, go.dev/doc/comment |
  | C# | `///` lines with XML tags (`<summary>`, `<param>`, `<returns>`) | Microsoft Learn, XML documentation comments |
  | Rust | `///` (outer) and `//!` (inner) doc comments | Rust Style Guide, rustdoc book |
  | Dart | `///` lines | Effective Dart, "DO use `///` doc comments" |

  A language with no block documentation form, or whose official guide
  requires line doc comments (Go, C#, Rust, Dart above), uses that one form
  throughout the file. A short comment is then a single doc-comment line, and
  a long one is consecutive lines of the same form.

## Xcode project

- Preserve Xcode project format 46, compatibility version Xcode 3.2, explicit
  file lists, and a shared scheme.
- The Podfile top declares `platform :ios, '15.0'`,
  `ENV['SWIFT_VERSION'] = '5'`, and this directory's `.xcodeproj`.
- The Podfile ends with one `post_install` hook that sets every Pods target's
  `IPHONEOS_DEPLOYMENT_TARGET` to `"15.0"`. Append it at the bottom if missing;
  never add duplicate hooks.
- Keep Xcode app and test deployment targets at iOS 15.0 and use the local
  sibling `CYLTableViewPlaceHolder` pod for this reproduction.
- Verify that the AppIcon asset set contains actual icon files and that the
  launch storyboard/image is configured in the app target. If either is
  missing, reuse the icon and custom launch image from
  `CYLTabBarController/Example/Images.xcassets`.
- Never commit `Pods/`, generated workspace state, or AppleDouble `._*` files.

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

## Issue #1317

The reproduction uses `UISearchController` in `navigationItem.searchController`
and a `CYLRefreshNormalHeader`. Pinning the search bar with
`hidesSearchBarWhenScrolling = NO` is the known workaround for repeated inset
updates on affected iOS versions. Refresh callbacks must not retain their
controller strongly and must always stop the refresh control.

## CYLTabBarController

This project integrates CYLTabBarController by default. Rules adapted from
CYLTabBarController's `AGENTS.md` and `cyl-*` skills at its latest commit
(`caf3c92`, branch `feat/cross-platform-components`, 2026-11-11); see
`docs/CYLTabBarController-Integration.md` for the source and the status.

- **Default integration in the example layer.** Unless a task says otherwise,
  every `CYLTabBarController` in the example (`CYLSearchExample/`) is created
  from a **local configuration file** in the app bundle, and has a **plus
  button with a plus child view controller**. Never write tabs, the plus
  button or a `CYLPlusButton` subclass only in code for the default demo.
  - The file (for example `CYLSearchExample/CYLTabBarConfiguration.json`) holds
    `CYLTabBarControllerTabBarItemsAttributes` (an even number of tabs, each
    with `CYLTabBarItemIdentifier` / `CYLTabBarItemPageIdentifier`) and
    `CYLTabBarControllerPlusButton` with `CYLTabBarItemTitle`,
    `CYLTabBarItemImage` and `CYLTabBarItemPageIdentifier`. The page found for
    the plus button's page ID becomes the plus child view controller.
  - Register a page provider for every page ID in
    `CYLTabBarPageRegistry.sharedRegistry` (or a registry passed as
    `CYLTabBarControllerPageRegistry`), then create the controller with
    `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]`.
    Handle the error: never leave the window without a root view controller.
  - Plus button taps that need code use `CYLTabBarControllerPlusButtonAction`
    (code only); read the configuration with
    `+configurationWithContentsOfFile:error:` and add the action before
    `-initWithConfiguration:`.
  - Full recipe: the `cyl-tabbar-integration` skill. Plus button limits: the
    `cyl-plus-button` skill.
- **Depend on the latest commit, through CocoaPods.** Before every build, run
  `scripts/latest-cyl-commit.sh --podfile`; it prints the newest commit on any
  branch by commit timestamp. Put that line into the Podfile:
  `pod 'CYLTabBarController', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<sha>'`.
  Never a version number, branch or tag. Run `pod install`, then build. Name
  the commit (sha, date, branch) in the report; if it cannot be fetched, say
  so and keep the sha already in the Podfile.
- **Imports.** The example imports only
  `#import <CYLTabBarController/CYLTabBarController.h>`, like the other pods'
  umbrella headers.
- **Search inside tabs.** A tab page that shows search embeds its view
  controller in a `UINavigationController`, so
  `navigationItem.searchController` and the Issue #1317 workaround keep
  working. Do not put the search bar on the tab bar controller itself.
- **Reading CYLTabBarController docs.** Its `docs/` and comments are
  bilingual: read the `[EN]` part and skip the `[CN]` part; in a
  `中文 | English` table read the right column. Code wins over `docs/`, and
  `docs/` over `README.md`.
- **Accessibility.** Tabs, the plus button, badges and every control in the
  example have meaningful accessibility labels; tests find elements by label
  or identifier before coordinates.
- **Clean builds.** Build into an empty derived data folder after a
  dependency change, so the app does not run stale pod code.

- **Raised plus button.** Example layer, raised plus button: when an example demonstrates a plus button, always prefer the raised effect, where the top of the plus button rises above the top edge of the tab bar (for example `CYLPlusButtonCenterYMultiplier` below 0.5 with a button taller than half the bar, or `CYLPlusButtonCenterYOffset`); keep it fully tappable (`touchableRect`) and never let it cover the page content above the bar.

## Sub-repositories (CollectionViewClassifyMenu, CYLTableViewPlaceHolder)

Sibling projects in the same local folder (`../<Name>`) that this library uses are sub-repositories. The rules were
set for CollectionViewClassifyMenu (the tag-view suggestion style, `docs/tag-view-suggestions.md`) and apply to every
sub-repository:

- **Dependency.** iOS: through the sub-repository's root podspec, as a sub-dependency of this pod (podspec
  `s.dependency`, Podfile `:git` + `:commit`). Android and the other platforms: through their package manager by
  commit; when that is not possible, the build checks out that commit and builds the module from source
  (`android/merged/settings.gradle.kts`, `pinnedCheckout`).
- **Newest commit.** Pin the newest commit on any branch (`git fetch` then `git log --remotes -1`); it may not be on
  `main` or `master`. A local path is allowed only while developing: remove it before committing and commit the
  commit-based dependency.
- **Core first.** Add the feature to this library's core with an enum or a parameter that chooses it. When the
  sub-repository lacks an interface, add it there, commit and push it there, then update this repository's pinned
  commit and continue.
- **Example.** The example shows every style the option offers; it passes only data, style parameters and click
  handling.

CollectionViewClassifyMenu shows the suggestions under the search bar as tags instead of a list
(`CYLSearchSuggestionStyle`; Android done, iOS `TODO` in `docs/tag-view-suggestions.md`).

CYLTableViewPlaceHolder is integrated as a sub-repository under all the requirements above. Requirement: when a search
has no results (the content is empty), show CYLTableViewPlaceHolder's empty-content placeholder style. This applies to
every platform: iOS, Android, React Native, Flutter, HarmonyOS and mini programs. Status: `TODO`, tracked in
`docs/sub-repositories.md`. Use the `cyl-sub-repositories` skill.

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

### Screenshots of builds and CI/CD

- **Where they go.** Every screenshot, local build and run screenshots and CI/CD screenshots alike (a GitHub Actions
  run, a job log, an artifact), is committed to this repository and shown in the related document in `docs/`, with
  the image in `docs/assets/` and the shortest relative link. When no document fits, create one.
- **Clear originals.** Use the original pixels (`xcrun simctl io <device> screenshot`, an emulator's own capture,
  a full-resolution browser capture); crop to the detail, never scale below the original size.
- **Labels.** Next to every screenshot (its caption or table row) write:
  - the platform: iOS, Android, Flutter, React Native, HarmonyOS or mini program;
  - the environment: the host OS version and build, the simulator or emulator (device and OS version), and the
    platform SDK version (Xcode and iOS SDK; Android SDK and API level; Flutter SDK; React Native; HarmonyOS SDK and
    API version; the mini program base library);
  - this repository's version number or commit link;
  - the date and time it was taken, with the time zone.
- **Key milestones.** Take and publish screenshots at key milestones: when a `TODO` or `Linux` note can be removed,
  when a pull request can be merged, or when the result works as expected with no known bug and no open issue.
- **README.** At such a milestone, when the result is as expected, update the screenshot section of `README.md`
  (create it if missing) with the latest images and the labels above. Show the key details, cropped; capture the
  full screen only when it is needed. Combine several details into one stitched image
  (`scripts/stitch-screenshots.swift`), laid out in this order of preference:
  1. stacked top to bottom, one image per row (easiest to read on a phone);
  2. two columns over several rows;
  3. one horizontal row of at most three images.

  Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.

## Open pull requests and issues of projects we translate

When a document of this project links to another project's GitHub repository (not this project) because its code
is translated, ported or merged into ours (for example the Kotlin transcriptions in `android/`), the work covers
that project's open pull requests and open issues, not only its default branch. The same rule applies on every
platform (iOS, Android, Flutter, React Native, HarmonyOS, mini programs).

1. **Open pull requests.**
   - Translation not started yet: merge the project's open pull requests into the code you translate first.
   - Translation already done: translate each open pull request's changes separately and merge them into our
     translated code.
2. **Open issues table.** In the related `docs/` document (create one when none fits), list every open issue of
   that project in a table: first column the issue link, second column the issue description, third column the fix
   status, `TODO` by default. Record the date the list was read.
3. **Fix them in our code.** For each issue, find its counterpart in our code and try to fix it there; set the
   status to `DONE` with the commit (or `N/A` with the reason when the issue does not apply to our code, for example
   a feature we do not have).
4. **Score.** Score = issues `DONE` or `N/A` / all listed issues × 100. Score again after every fixed issue and
   continue until 100.
5. **Order.** When the translation has not started: merge the open pull requests, then work on the open issues;
   start translating once the issue score reaches 60; after translating, fix the remaining issues until 100. When
   the translation is done: translate and merge the open pull requests, then fix the issues on the translated code
   until 100.

## Task log before every task

Sessions can stop in the middle of a task (context limits, restarts, another
session taking over the branch or the simulator). So that the next session can
pick the task up, every task is written down in `docs/` before any work starts:

1. **Find the most suitable document in `docs/`**: the feature's own document
   (for example `docs/search-bar-view.md`, `docs/CI-CD.md`,
   `docs/CYLTabBarController-Integration.md`). When none fits, use
   `docs/task-log.md`.
2. **Add the task there as `TODO`, before the first change**, under a heading
   such as `## TODO (YYYY-MM-DD): <task>`, with:
   - **Context**: the background, the branch, the related PRs, issues,
     commits and files, and what is already known;
   - **Requirements**: every requirement the user gave, as a list;
   - **Prompt**: the user's prompt quoted verbatim in its original language,
     followed by an English translation;
   - **Status**: where the work stands; update it at each milestone (commit,
     push, CI result).
   Commit and push this entry before starting the work.
3. **When the task ends, mark it done**: change `TODO` to `DONE (YYYY-MM-DD)`
   and add the result and the evidence (commits, PRs, test results,
   screenshots). An interrupted task keeps `TODO` with its current status.

An open `TODO` of a task in progress is not a stale note: the "stale notes
before every commit" search skips it, and the session that finishes the task
marks it `DONE`.

## Commit readiness

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/hooks/NO_AUTO_SYNC
  ```

- **On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking
  for confirmation.** On `master` or `main`, ask first.

- **Every new branch gets a pull request right away, without asking.** As soon as a branch is created and first
  pushed, open its pull request (`gh pr create`). The base (target) branch is the branch the new one was created from
  (its source branch); use `master` or `main` only when that is the source, or when the source branch no longer exists
  on the remote. Never ask for confirmation first. Name the base in the reply.

- Every commit message carries the author line
  `By  @ChenYilong <luohanchenyilong@163.com>` (exactly as written, two spaces
  after `By`) in its body, after the description and before trailers such as
  `Claude-Session:`. Check it with `git log -1 --format=%B` before pushing.
- Before a Commitizen-style commit, follow the commit-message hook instructions
  in `instructions.md`; inspect an existing hook before replacing it.
- Before every commit, review the changed scope and its related issue,
  comparison, and implementation-status documentation.
- Track each unfinished or unverified item from the commit under a `TODO`
  heading in the most relevant existing `docs/` document. Include remaining
  work, implementation constraints, known defects, verification steps, and API
  design or compatibility risks. Reserved keys, stubs, and compilation alone
  do not prove completion.
- Use an English Conventional Commit subject compatible with Commitizen. Put
  detailed completion and pending-work summaries in the body. If the detailed
  description exceeds 50 characters, create or update a suitable `docs/` note
  and link it from the commit body; reuse existing tracking documents.
- Follow the Commitizen defaults: `{type}{scope}: {emoji}{subject}`, emojis
  enabled, no predefined scopes, and a 3–64 character message. The interactive
  format examples separate the emoji from the subject with a space. The
  type list is `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`,
  `ci`, `perf`; `release` is defined but not listed. Default emojis are
  `chore` 🤖, `ci` 🎡, `docs` ✏️, `feat` 🎸, `fix` 🐛, `perf` ⚡️,
  `refactor` 💡, `style` 💄, `test` 💍, and `release` 🏹. Follow the established
  project emoji where it differs (e.g. CYLTabBarController uses `feat: ✨`,
  `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`). The question sequence is
  `type`, `scope`, `subject`, `body`, `breaking`, `issues`, and `lerna`;
  prompts cover optional scope, imperative subject, longer description,
  breaking changes, issue references, and affected packages.
