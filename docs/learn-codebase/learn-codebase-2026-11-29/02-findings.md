> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. No finding was reproduced. R items are unverified.

# Findings

2026-11-29. **Everything here comes from reading and searching code. Nothing was built, run or tested, and nothing was fixed.**
Level: **S** = re-checked with a targeted search or a second look at the lines (still not reproduced); **R (not re-checked)** = from the first full read only, **unverified**. Statements about what would happen at run time are unverified under either label.

## iOS core
- **S** `CYLSearchController.swift`: history is recorded only through `searchFieldSubmitted` (wired near line 303) and `submitSuggestion` → `recordSubmittedQuery` (store call near line 365). The controller has no `searchBarViewSearchButtonClicked`, so the bar's **default search button does not save the query**. Tests cover only the return key and tag taps.
- **R (not re-checked)** `searchButtonItem` doc says the tint is kept on rebuild; `rebuildSearchButton` copies only the accessibility id.
- **R (not re-checked)** Public comments damaged by find-and-replace ("QMthe system search controller", "qmui_styledAsQMthe system search bar", a class `CYLSearchBar` that does not exist; the API fence test header and alignment scripts name it too). A duplicated "Ported to Swift" header line in `CYLSearchController.swift`.

## Android core
- **S** `CYLSearchBarView.kt:752-759` uses `isNullOrBlank`: spaces-only text tells the delegate; iOS does not (see architecture table).
- **R (not re-checked)** `SearchButtonStyle.Text` KDoc says it is the default; the default is Icon.
- **R (not re-checked)** Two stacked KDoc blocks before `keyboardOverlapHandler` orphan the `pinToKeyboard` doc.
- **R (not re-checked)** Default `contentInsets` are (12,6,12,6); iOS uses 16 horizontal.
- **R (not re-checked)** `CYLSearchTagListStyle.isNight` uses `uiMode`; the bar's `isNight` uses theme background luminance. They could disagree.
- **R (not re-checked)** `noResultsText` rebuilds the placeholder (and calls `willShowEmptyView`) on every refilter.

## HarmonyOS core
- **R (not re-checked)** `alwaysShowsSearchResultsController` is only stored (`CYLSearchController.ets` near 220 and 365-373) and never reaches `CYLSearchView`.
- **R (not re-checked)** `searchButtonHandler` runs after submit/delegate, while `docs/harmonyos-api-alignment.md:131` says "INSTEAD".
- **R (not re-checked)** `applyBackgroundStyle` sets style flags only; no clear glass fills.
- **R (not re-checked)** Leftover `'testTag'` logs in `CYLSearchView.ets` (near 1652 and 1659).

## WeChat mini program core
- **R (not re-checked)** `submit()` rejects only length 0; the search page ignores blank.
- **S** `src/core/CYLSearchResources.js:394`: history trims with `max(0, maximumCount)`; iOS, Android and HarmonyOS keep at least 1.
- **R (not re-checked)** Model-only `$r(app.color.cyl_search_navigation_field_fill)` falls back to #8e8e93 (the component uses CSS, so it is unaffected).
- **R (not re-checked)** `cyl-search-bar` rebuilds all items on change; `cyl-search` calls `submitted()` for any 'text' item tap (not compared with iOS).

## Flutter plugin
- **R (not re-checked)** iOS `CYLFlutterTagListContainer.apply` ignores `tagSubtitles` and `titleMaxLines`; Android applies them.
- **R (not re-checked)** iOS reads `searchButtonImage`, which Dart never sends.
- **R (not re-checked)** The iOS bar bridge applies text only when non-empty, so Dart cannot clear it with `""`.
- **R (not re-checked)** `cylFlutterAssetImage` sits between `cylFoldControl`'s doc comment and its function.
- **S** `ios/RunnerTests/RunnerTests.swift:19` calls `handle`/`getPlatformVersion`, which the plugin does not have.
- **S** `README.md:63` says AGP 8.11.1 and Kotlin 2.2.20; the build files use AGP 9.2.1, and the example uses Kotlin 2.4.0.
- **S** `CHANGELOG.md` says the iOS pod no longer declares CYLTableViewPlaceHolder; `ios/flutter_cylsearch.podspec:22` depends on `CYLTableViewPlaceHolder/Core`.

## React Native
- **S** iOS does not handle `animatesBackButton` (no match under `ios/`; Android does).
- **S** (earlier in this pass) iOS ignores `tagSubtitles`, `titleMaxLines`, `hidesSearchBarWhenEmptyViewShowing`; Android handles them.
- **R (not re-checked)** `onSelectResult` reports the first matching index, wrong for duplicate results.
- **S** Nested `CrossPlatform/react-native-cylsearch/.github/workflows/ci.yml` is never run by this repository's GitHub Actions (only root `.github/workflows` is).

## Examples
- **R (not re-checked)** "Done" in Edit Remarks is inert on iOS (nil target and action), Android, HarmonyOS, mini program and React Native. Flutter's works.
- **R (not re-checked)** "+ New Tag" outside Manage does nothing useful on HarmonyOS (an alert with no text field, then an empty tag name). Android is fine: see corrections.
- **S** Entry-page comments on iOS (`CYLSearchDiscoverViewController.swift:589-590`) and Flutter (`discover_page.dart:104-105`) say the first appearance opens Discover at once; no push on creation, `viewDidAppear` or `initState` was found.
- **S** React Native `DiscoverEntry`: the entry tag's `onTagSelect` does nothing (the bar above still opens the page).
- **S** `ja.lproj/search-discover.json` has the same recent searches and topics as English; zh-Hans and zh-Hant are translated.
- **R (not re-checked)** HarmonyOS `SpeechRecognizer.ets` hard-codes zh-CN.
- **R (not re-checked)** Hard-coded English strings in the iOS, Flutter and React Native examples.
- **R (not re-checked)** Mini program: `searchSecond` hand-builds recent/popular lists with its own fold; `discoverSearch` shows two camera items; `cyl-demo-nav` Done has no handler. The hand-built **Discover** recent list is intentional (pinned by tests).
- **R (not re-checked)** `CYLContactTagServer.kt` has a UTF-8 BOM and mojibake in comments (lines 14, 15, 17, 42).

## Tests, scripts, CI
- **R (not re-checked)** HarmonyOS UI tests `tagStyleSampleSearchClosesOnBack` and `searchFlowByLabels` tap tag-list rows by text, although the helper's comment says the list draws no findable text. Likely stale; not run.
- **S** `scripts/ci-checkout-dependencies.sh:5` says the Podfile uses `:path` for CYLTableViewPlaceHolder; it pins `:git` + `:commit`.
- **R (not re-checked)** `scripts/check-commit-message.sh` does not enforce the emoji.

## Upstream port code (vendored, built by `android/merged/search-lapism`; not the CYL core)
- **S** `MaterialSearchView.kt:404-405`: `SavedState.CREATOR.newArray` calls itself, so it would recurse forever if called.
- **S** `MaterialSearchView.kt:108-109` reads `R.styleable.MaterialSearchBar_search_navigationBackgroundColor` from its own `MaterialSearchView` attribute array (wrong index).

## From the documents pass (re-checked by the main session with `git grep`)
- **S** Maven coordinates disagree: `android/merged/cylsearch/build.gradle.kts:73-76` publishes `com.cyl:cylsearch:0.1.0`, but Flutter (`android/build.gradle.kts:85`) and React Native (`android/build.gradle:38`) depend on `com.cyl.search:cylsearch:0.1.0`. The examples substitute the local project, which hides it. **Inference, not tried:** an app using published packages would fail to resolve it.
- **S** HarmonyOS API table: HEAD says 433 of 437 (score 99, 4 TODO); the working tree says 437 of 437 (100). The 100 relies on the uncommitted changes.
- **S** Other generated scores now in the docs: iOS table (Android → iOS) 96 with 31 TODO (`docs/ios-api-alignment.md:99`); mini program 97 with 10 TODO (`docs/miniprogram-api-alignment.md:254`); Android 100.
- **S** `docs/harmonyos-cross-platform.md:227` counts 443 API rows; the current alignment tables have 437, so that part is out of date.
- **S** `docs/no-system-searchbar.md:19` names members that do not exist under those names (`leadingAccessoryView`, `trailingAccessoryView`, `textFieldMargins`, `backgroundView`: no whole-word match in `Sources`). Related ones do exist: `leadingView`, `trailingAccessoryViews`, `textFieldMarginsProvider`.
- **S** `Sources/CYLSearchBar` has 13 Swift files, but these still say three: `README.md:121`, `docs/instructions/core.md:95` and `:133`, `.agents/skills/cyl-api-map/SKILL.md:11`, `cyl-fix-in-core/SKILL.md:22`, `cyl-verify/SKILL.md:17`, `docs/CYLTabBarController-Integration.md:62`.
- **S** HarmonyOS has 30 more language folders that are partial: 7 of 90 strings in the core, 4 of 79 in the example. This follows the import rule, but leaves most UI text untranslated there ([data/localization.md](data/localization.md)).

## From the config pass
- **S** The React Native example's shared Xcode scheme references a `CylsearchExampleTests` target (`CylsearchExample.xcscheme:36-37`); no other file in the example mentions it, and the project's one native target is `CylsearchExample`.
- **S** CYLDeallocBlockExecutor is pinned at `eab21d10` in the iOS Podfiles and `c85c10c0` in `android/merged/gradle/libs.versions.toml:26`. The Android comment ties its commit to CYLTabBarController's Android example; the TODO handover plans `eab21d10` for the non-iOS platforms.

More contradictions and open items, **not** re-checked: see each file in [docs-knowledge/](docs-knowledge/README.md). Examples the digests report: the split tab bar pins break the Flutter Android build (a claim in the task log and handover), and the latest release assessment recorded there is 52/100.

## Corrections: do not repeat these
| Earlier claim | What is true |
|:---|:---|
| claude-mem #497: the iOS Discover entry opens the page on first appearance | That is the code comment; no such call was found. |
| claude-mem #236: mini program `removeSearch` selects the previous item, unlike iOS | Removing the selected item selects the next (previous if it was last), as on iOS. Only difference seen: with nothing selected, iOS selects an item and the mini program does not. |
| claude-mem #239: Android "+ New Tag" shows an alert with no text field | `CYLContactTagsPages.kt:630-642` puts a `CYLSearchBarView` text field in the dialog and creates a tag from its text. |
| Earlier pass: the Android blank-text search button differs from iOS | Same for empty `""`; different only for spaces-only text. |
| A note from this pass: React Native's comment also says Discover opens at once | The React Native comment does not say "first time". |
| A note from this pass: HarmonyOS `oh-package.json5` has the debug log | It has none; the logs are in `EntryAbility.ets` and the core `CYLSearchView.ets`. |