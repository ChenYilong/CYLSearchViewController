# Sub-repositories

Sibling projects in the same local folder that this library uses. Rules: `AGENTS.md`, "Sub-repositories"; skill
`cyl-sub-repositories`.

| Sub-repository | What it adds | Status |
|:---|:---|:---|
| CollectionViewClassifyMenu | Suggestions as tags (`CYLSearchSuggestionStyle`); `CYLTagButton`, which draws every search bar item and the example's SVGA demo | Tags: Android done (`eb3590e`); iOS `TODO` ([tag-view-suggestions.md](tag-view-suggestions.md)). `CYLTagButton`: every platform, pinned at `71562ca` on HarmonyOS (`harmonyos/oh-package.json5` `collectionViewClassifyMenuCommit`, `harmonyos/vendor/classifymenu`, with CYLTabBarController's `cylanimateditem` in `harmonyos/vendor/cylanimateditem`) and the mini program (`package.json` `collectionViewClassifyMenuCommit`) ([animated-icon-component.md](animated-icon-component.md)) |
| CYLTableViewPlaceHolder | The placeholder sub-dependency: the empty-content placeholder (`CYLPlaceholderView` scenarios shown by `CYLSearchView`) when a search has no results, and the pull-to-refresh header inside `CYLSearchView`'s refresh API; pinned at `62e40c0` (its newest commit, on `CYLAnimatedItem`) on every platform | Done on iOS, Android, HarmonyOS, the mini program, React Native and Flutter ([search-core-merge.md](search-core-merge.md)) |

## DONE (2026-11-16; TODO 2026-11-12): CYLTableViewPlaceHolder as a sub-repository, empty search results on every platform (iOS, Android, Flutter, React Native, mini programs; HarmonyOS through `cylplaceholder`, run on the Mate 70 Pro emulator: the empty placeholder in `harmonyos-search-empty-cache-emulator-unsigned.jpeg`, touches checked 2026-11-16)

- Context:
  - The requirements for CollectionViewClassifyMenu as a sub-repository ([tag-view-suggestions.md](tag-view-suggestions.md))
    are written into `AGENTS.md`, `instructions.md` and the skills as general sub-repository rules (2026-11-12),
    with this requirement appended.
  - iOS today: the example already shows an empty state through CYLTableViewPlaceHolder
    (`CYLSearchExampleViewController`: `cyl_reloadData`, `makePlaceHolderView` returning a
    `CYLSearchPlaceholderView`), but the Podfile uses `pod 'CYLTableViewPlaceHolder', :path =>
    '../CYLTableViewPlaceHolder'`, a local path the rule forbids in a commit, and the core does not offer the empty
    state as an option.
  - Android today: `android/merged` shows `CYLSearchPlaceholderView` itself in the search example; CYLTableViewPlaceHolder
    has no Android library yet (its `docs/Android-Port.md` is a TODO), so the Android part waits for it or adds it
    there first (the rule: add the missing interface in the sub-repository, push, then pin).
  - Newest CYLTableViewPlaceHolder commit on any branch when this was logged: `47a4ed7` (branch `ci-screenshots`).
  - React Native, Flutter, HarmonyOS and mini programs: no version of this library yet (the cross-platform TODO in
    [android-and-cross-platform.md](android-and-cross-platform.md)); each gets this requirement when it is built.
- Requirements:
  1. Integrate CYLTableViewPlaceHolder as a sub-repository under every CollectionViewClassifyMenu requirement:
     iOS through its root podspec as a sub-dependency at the newest commit (no local path in a commit), other
     platforms by commit; the feature in the core through an enum or a parameter; missing interfaces added in
     CYLTableViewPlaceHolder, pushed, then pinned here; the example shows it and passes only data, styles and taps.
  2. When a search has no results (the content is empty), show CYLTableViewPlaceHolder's empty-content placeholder
     style.
  3. The same on every platform: iOS, Android, React Native, Flutter, HarmonyOS, mini programs.
  4. Screenshots per platform, labeled per AGENTS.md; mark this TODO done.
- Prompt (verbatim): "在instructions 相关文件，以及skills相关文件中找到 对CollectionViewClassifyMenu 作为子仓库的相关描述，全英文在后面追加以下内容，按照CollectionViewClassifyMenu 作为子仓库 的所有要求，集成CYLTableViewPlaceHolder 作为子仓库。对  CYLTableViewPlaceHolder 的要求是 搜索内容为空时展示 内容为空的 CYLTableViewPlaceHolder  样式。该要求同样适用于 所有平台包括iOS Android react native flutter 鸿蒙 小程序。 标注TODO continue"
- Prompt (English): "In the instruction files and the skill files, find the description of CollectionViewClassifyMenu as
  a sub-repository and append, in English: following all the requirements for CollectionViewClassifyMenu as a
  sub-repository, integrate CYLTableViewPlaceHolder as a sub-repository. The requirement for CYLTableViewPlaceHolder:
  when the search content is empty, show CYLTableViewPlaceHolder's empty-content style. This also applies to every
  platform: iOS, Android, React Native, Flutter, HarmonyOS and mini programs. Mark it TODO. Continue."
- Progress:
  - Rules written (2026-11-12): no instruction or skill file described CollectionViewClassifyMenu as a sub-repository
    yet (only this repository's docs did), so a "Sub-repositories" section now states the CollectionViewClassifyMenu
    requirements and appends the CYLTableViewPlaceHolder requirement: `AGENTS.md`, `instructions.md`, the new
    `cyl-sub-repositories` skill, and pointers in `cyl-xcode-compat`, `cyl-api-map` and `cyl-new-project`.
  - Found while editing the skills: commits `1416a3e` and `2db1bd6` had replaced the contents of all seven `cyl-*`
    skills with the section they meant to append (cyl-docs and cyl-verify lost about 90 and 120 lines, the others
    their whole body). Restored from their last intact versions (`db9991a`, `1416a3e`) with those sections appended.
  - Order: after the open tasks logged before it (the iOS tag-view TODO, the raised plus button rule, the
    HarmonyOS / Flutter / React Native TODO).
- Progress, iOS: DONE (2026-11-13, [`5bb0b58`](https://github.com/ChenYilong/CYLSearchViewController/commit/5bb0b58)).
  - Dependency: `s.dependency 'CYLTableViewPlaceHolder/Core'` in the podspec; the Podfile pins its newest commit
    `a049422` (branch `feat/smartrefresh-parity`) by `:git` + `:commit`, no local path. `scripts/pod-lint.sh` checks
    it out with CollectionViewClassifyMenu; `pod lib lint` passes.
  - Core option: `CYLSearchView.showsEmptyResultsPlaceholder` (off by default, so existing apps keep their behavior)
    and `emptyResultsScenario` (`CYLPlaceholderScenarioNoSearchResults` by default: icon, "No matching results", "Try
    different keywords"; `CYLPlaceholderScenarioNoContent` gives the plain empty state). While a non-empty query
    matches no suggestion, CYLTableViewPlaceHolder's `CYLPlaceholderStackView` for that scenario shows under the
    search bar (`emptyResultsView`), in the list and the tag style; a match, an empty query or a submitted query hides
    it. Choice recorded: "内容为空的样式" was read as the library's empty search results scenario; the scenario is a
    parameter, so the plain "no content" state is one line away.
  - The results screen (`CYLSearchExampleViewController`, Issue #1317) already shows its empty state through
    CYLTableViewPlaceHolder (`cyl_reloadData`); it now comes from the pinned commit instead of the local path.
  - Example: the MaterialSearchView samples (the list ports and the Tag style tab) turn it on.
  - Test: `testEmptyResultsShowTheCYLTableViewPlaceHolderPlaceholder` (off by default; shown for no match in both
    styles; hidden for a match and an empty query; the scenario parameter). 20/20 pass on iPhone 17.
  - Screenshot (original): the Tag style tab's Default sample, "zzz" typed.

    ![Empty search results placeholder](assets/ios-empty-search-results-placeholder.png)

    | Field | Value |
    |:---|:---|
    | Platform | iOS |
    | Host | macOS 27.3 (26C5035r), Xcode 27.2 (27B5028f) |
    | Simulator | iPhone 17, iOS 26.3 |
    | SDK | iOS SDK 27.2, deployment target iOS 15.0 |
    | Repository | [`5bb0b58`](https://github.com/ChenYilong/CYLSearchViewController/commit/5bb0b58) on `feat/swift-core`; CYLTableViewPlaceHolder `a049422` |
    | Taken | 2026-11-13 00:02 NZDT |
- Progress, Android: DONE (2026-11-13, [`062a1a3`](https://github.com/ChenYilong/CYLSearchViewController/commit/062a1a3)).
  - CYLTableViewPlaceHolder had no Android code, so its first Android module was added there (sub-repository rule):
    `android/placeholder` (Kotlin, `com.cyl.placeholder`) with `CYLPlaceholderScenario` and
    `CYLPlaceholderStackView(context, scenario, actions)` for the empty category (NoContent, NoSearchResults,
    EmptyCart, NoOrders, NoFavorites, NoMessages, NoNotifications), images and strings imported from its iOS bundle
    in seven languages, 4 tests;
    [ChenYilong/CYLTableViewPlaceHolder#27](https://github.com/ChenYilong/CYLTableViewPlaceHolder/pull/27), commit
    `8e23581`. Animations and the other categories stay `TODO` in its `docs/Android-Port.md`.
  - Pinned here (`cyl.placeholder.commit`), built from source like the other sub-repositories.
  - `CYLSearchView.showsEmptyResultsPlaceholder` / `emptyResultsScenario` / `emptyResultsView` in Kotlin, the same
    behavior as iOS; the MaterialSearchView samples and the List / Tag style tabs turn it on.
  - Tests: 10/10 `cylsearch` (new empty-results test); the API table now has 302 rows, score 100.
  - Screenshots (originals), top to bottom: List style tab and Tag style tab, "zzz" typed.

    ![Android empty results, list style](assets/android-empty-search-results-list.png)

    ![Android empty results, tag style](assets/android-empty-search-results-tags.png)

    | Field | Value |
    |:---|:---|
    | Platform | Android (Kotlin, `android/merged`) |
    | Host | macOS 27.3 (26C5035r), JDK 17.0.21, Gradle 9.3.1, AGP 8.7.3, Kotlin 2.0.21 |
    | Emulator | `CYL_API35_arm64`, Android 15 (API 35), arm64-v8a |
    | SDK | compileSdk / targetSdk 35, minSdk 23 |
    | Repository | [`062a1a3`](https://github.com/ChenYilong/CYLSearchViewController/commit/062a1a3); CYLTableViewPlaceHolder `8e23581` |
    | Taken | 2026-11-13 00:4x NZDT |
- Next: React Native, Flutter, HarmonyOS and mini programs, when those versions of this library exist (the
  cross-platform TODO in [android-and-cross-platform.md](android-and-cross-platform.md)).
- Flutter and React Native: DONE (2026-11-13 and 2026-11-14). Both wrap the native cores, so they get the same
  placeholder: `showsEmptyResultsPlaceholder` and `emptyResultsScenario` on Flutter's `CYLSearchView` widget and on
  React Native's `CYLSearchView`; each example has an Empty results demo. Pin: CYLTableViewPlaceHolder `bdd78c7` on
  every platform.
- HarmonyOS: the library has `CYLSearchPlaceholderView` with 40 styles as system symbols and the empty-cache and
  empty-results placeholders (`harmonyos/cylsearch`); it does not use CYLTableViewPlaceHolder (no HarmonyOS version of
  it exists). Mini programs: the search page has text placeholders only.
- HarmonyOS (2026-11-16): the example uses both sub-repositories' HarmonyOS libraries, installed into the git-ignored
  `harmonyos/vendor` by `harmonyos/scripts/sync-sub-repositories.py` at the commits in `harmonyos/oh-package.json5`:
  CYLTableViewPlaceHolder `cylplaceholder` at `5bcbdb5` (the newest commit on any branch,
  `feat/android-refresh-port-followup`) for CYLRefreshNormalHeader; CYLTabBarController `cyltabbar` at `ebaed17`
  (`feat/cross-platform-components`, the newest commit on any branch; it contains `ea5b989` and `3ddb96c`, and adds the
  badge centring of its issue #25, 2026-11-16: SVGA tab icons, the badge, icon and
  plus title fixes of `127b8ae8` and `16a19bbf`, the badge border width of PR #805 and the demo translations;
  Scorecard 3 rows 1 to 4, 12 and 13). Before: `94eb7b1`. Their
  minimum is API 21, so the example's `compatibleSdkVersion` is 6.0.1(21).
- Status: `TODO` (iOS, Android, Flutter and React Native done; HarmonyOS uses CYLTableViewPlaceHolder's `cylplaceholder` library
  (above) and compiles, not run yet; mini programs done, see below).
- Progress (2026-11-15): mini programs DONE: the empty results and the empty cache of `cyl-search` play
  CYLTableViewPlaceHolder's `CYLPlaceholderNoResults.json` / `CYLPlaceholderNoDrafts.json` (with their licenses) through
  CYLTabBarController's `cyl-lottie`; screenshot in [miniprogram-api-alignment.md](miniprogram-api-alignment.md).
  Update (2026-11-15, the example as on iOS): CYLTableViewPlaceHolder's mini program package is now the sub-repository
  (`cyl-placeholder-miniprogram`, pinned at `8ee7013` in `package.json`, synced by `scripts/sync-example.js`):
  `cyl-search` has iOS's `emptyResultsScenario` (`NoSearchResults`) and `emptySuggestionsScenario` (`NoContent`), drawn
  by its abstract node `cyl-empty-view`; the example passes `<cyl-placeholder scenario>`, static as iOS
  `CYLPlaceholderStackView`. The Lottie paths are gone. Android
  animated too (`docs/core-todo.md`, CYLTableViewPlaceHolder `6d8b264`). Left: HarmonyOS on the emulator (no signing needed, rule 2026-11-16; waits for the emulator instance, Scorecard 2 rows
  7 to 9 in [harmonyos-cross-platform.md](harmonyos-cross-platform.md)).

## DONE (2026-11-19, iOS pod install pending; TODO 2026-11-17): continue the TODOs, unreleased components by commit

- **Context**: branch `feat/harmonyos-parity` (PR #11). Open items from the CYLAnimatedItem migration
  (`docs/animated-icon-component.md`): CYLTableViewPlaceHolder still pinned at `f488e2f`, before its own move to
  `CYLAnimatedItem`; HarmonyOS and the mini program wait for the component upstream; ClassifyMenu's Android
  `CYLIndexPathButton`, `CYLRightImageButton` and `CYLMultipleFilterHeaderView` are not on `CYLTagButton`.
- **Requirements**: continue fixing the TODOs; import components that are not released yet by commit; do not let
  anything block progress.
- **Prompt (verbatim)**: "continue fix todo还没发布的组件尝试使用commit方式导入。不要阻碍进度"
- **Prompt (English)**: "Continue fixing the TODOs. Try to import components that are not released yet by commit. Do not
  block progress."
- **CYLTableViewPlaceHolder `8dc39c3` pinned (2026-11-19)**, the head of `feat/android-refresh-port-followup` (PR #31): its
  `CYLPlaceholderView` now builds on CYLTabBarController's `CYLAnimatedItem` on every platform (iOS `f0320c8`, Android
  `933ba13`, mini program `bfeb678`, HarmonyOS `0847ffe` + `d54eef1`). It needs CYLTabBarController `4f73209c` or newer;
  our `b376c278` is 18 commits ahead. HarmonyOS keeps one `cylanimateditem`: `cylplaceholder` takes `file:../cylanimateditem`,
  which our vendor layout already provides. The iOS `Lottie` subspec still exists. Checked on Windows: mini program
  `npm test` 52 of 52 and the placeholder catalog and a placeholder page in DevTools with 0 console lines
  ([assets/miniprogram-devtools-20261119-placeholder-at-8dc39c3.png](assets/miniprogram-devtools-20261119-placeholder-at-8dc39c3.png), WeChat DevTools base library 3.6.6, Windows 11, CYLTableViewPlaceHolder 8dc39c3, 2026-11-19 10:02 +13:00,
  2026-11-19 10:02 +13:00); HarmonyOS ohosTest 29 of 29; Android build + unit tests; React Native and Flutter Android
  build. Found: `android/merged`'s pinned checkout ran `git checkout` twice at once on the same folder and both hung on
  `index.lock` for 28 minutes; a manual checkout fixed it (TODO: make `pinnedCheckout` run once per repository).
  iOS `pod install` asked of the macOS session.
- **Status**: started. CYLTableViewPlaceHolder → its newest commit `62e40c0` (branch
  `feat/android-refresh-port-followup`, on `CYLAnimatedItem`); HarmonyOS and mini program component requested from the
  CYLTabBarController session (no upstream code at any commit yet).
- **CYLTableViewPlaceHolder `62e40c0` pinned**: every platform (Podfiles, Gradle, ohpm, mini program `package.json`,
  React Native and Flutter Podfiles). Checked before pinning: the iOS API this core uses is unchanged
  (`CYLPlaceholderStackView(scenario:actions:)`, `CYLPlaceholderScenario`, `CYLRefreshNormalHeader`, `cyl_header`);
  its `Core` depends on `CYLAnimatedItem/Core` and its `Lottie` subspec on `CYLAnimatedItem/LottieSwift`, which the
  Podfiles already name by commit. Android: its `:placeholder-lottie` module is gone (the Lottie animator lives in
  CYLTabBarController's `:cylanimateditem`, already included and substituted), so the build no longer includes it and the
  app adds `libs.lottie` instead. Not compiled here (no Xcode, Android SDK or DevEco): CI is the check.
