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
| `cyl-docs` | Editing `README.md` or `docs/` |
| `cyl-verify` | Building, testing, running the simulator |

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

## Comments on public API

Adapted from CYLTabBarController's `AGENTS.md`, "Comments on public API"
(commit `63c0edc`, branch `feat/cross-platform-components`). Callers read a
public API's comment through the IDE's documentation (Xcode Quick Help, the
generated Swift interface, Android Studio, editor hovers), and only a
documentation comment gets there whole.

- **Multi-line comments on public API are one documentation block, never
  stacked single-line comments**, placed right before the declaration with
  nothing in between:
  - **iOS, Objective-C public headers**: `/*! … */`, one `*` per line
    (` * …`).
  - **iOS, public API written in Swift**: `/** … */` or `///` lines (Swift
    Markup); Swift does not read `/*!` as documentation.
  - **Android (Kotlin / Java)**: KDoc / Javadoc `/** … */`.
  - **React Native (TypeScript / JavaScript)**: TSDoc / JSDoc `/** … */`.
  - **Flutter (Dart)**: `///` lines, as Effective Dart requires.
- **Single-line comments on public API follow the same format.** The format
  rules above for multi-line public API comments also apply to single-line
  public API comments: a one-line comment on an Objective-C public
  declaration is `/*! … */`, not `//` or `///`, and so on for each language.
  **In a file that contains public API, keep the comment format uniform**:
  every documentation comment in that file uses the one format of its
  language. This applies to all platforms and all languages.

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
`docs/CYLTabBarController-Integration.md` for the source and the TODO list.

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

## Verification

Run `pod install`, validate the project with Xcodeproj/CocoaPods, build and
analyze the shared scheme, and run tests when available. Do not claim a visual
reproduction or fix without launching the sample on a simulator.

## Commit readiness

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/hooks/NO_AUTO_SYNC
  ```

- **On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking
  for confirmation.** On `master` or `main`, ask first.

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
