# Sub-repositories and CYLTabBarController (tag: `dependencies`)

Details of the `dependencies` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

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
  Exception: A pull request branch that is already merged into the newest branch does not count, even when it gets a newer commit afterwards: pin the newest branch's tip, and move once that newer commit is merged there (owner's decision, 2026-11-17: `9a54e26`, the merge of PR #814 into PR #788, not `47aec88`). CYLSearchViewController and CollectionViewClassifyMenu pin the same commit.
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

## CYLTabBarController (instructions.md wording)

Adapted from CYLTabBarController's instruction files at its latest commit
(`caf3c92`, branch `feat/cross-platform-components`). Details and the status
(the example integration is done): `docs/CYLTabBarController-Integration.md`.

- Pin: the newest commit on any branch, by timestamp. A pull request branch that is already merged into the newest branch does not count, even when it gets a newer commit afterwards: pin the newest branch's tip, and move once that newer commit is merged there (owner's decision, 2026-11-17: `9a54e26`, the merge of PR #814 into PR #788, not `47aec88`). CYLSearchViewController and CollectionViewClassifyMenu pin the same commit.

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
every platform: iOS, Android, React Native, Flutter, HarmonyOS and mini programs. CYLTableViewPlaceHolder is the
placeholder sub-dependency: `CYLSearchView` shows its `CYLPlaceholderView` / `CYLPlaceholderStackView` for empty
results and empty suggestions, and wraps its pull-to-refresh header in the refresh API; every platform pins the
same commit, `62e40c0` (its newest commit, on `CYLAnimatedItem`). Status: done on iOS, Android, HarmonyOS, the mini program, React Native and Flutter. Tracked in `docs/sub-repositories.md` and `docs/search-core-merge.md`. Use
the `cyl-sub-repositories` skill.

## Sub-repositories (CollectionViewClassifyMenu, CYLTableViewPlaceHolder) (instructions.md wording)

- A sibling project in the same local folder used by this library is a sub-repository. The requirements set for
  CollectionViewClassifyMenu apply to all of them: iOS depends on its root podspec as a sub-dependency; other
  platforms depend by commit (or build the commit from source); pin the newest commit on any branch; a local path
  only while developing, never committed; add the feature to the core with an enum or a parameter (add missing
  interfaces in the sub-repository, push them, then update the pin); the example shows every style and passes only
  data, style parameters and click handling.
- CollectionViewClassifyMenu: suggestions as tags (`docs/tag-view-suggestions.md`).
- CYLTableViewPlaceHolder is integrated as a sub-repository under all the requirements above: when a search has no
  results, show its empty-content placeholder style, on every platform (iOS, Android, React Native, Flutter,
  HarmonyOS, mini programs). It is the placeholder sub-dependency, pinned at `62e40c0` (its newest commit, on `CYLAnimatedItem`) on every platform:
  `CYLSearchView` shows its `CYLPlaceholderView` scenarios and wraps its pull-to-refresh header. Done on iOS, Android, HarmonyOS, the mini program, React Native and Flutter
  (`docs/sub-repositories.md`). Full rule: `AGENTS.md`, same section; skill `cyl-sub-repositories`.
