> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

# C. API parity tables and the HarmonyOS cross-platform document

Digest of five documents, read from the working tree on 2026-11-29 (branch `feat/harmonyos-parity`, HEAD `ad32984`).
Short names: **IOS** = `docs/ios-api-alignment.md`, **MP** = `docs/miniprogram-api-alignment.md`, **HM** =
`docs/harmonyos-api-alignment.md`, **AND** = `docs/android-api-alignment.md`, **XP** = `docs/harmonyos-cross-platform.md`.
"File:N" is a line number.

Evidence labels: **[claim]** = a document says so (no build, test, emulator, simulator or DevTools run was done for this
digest). **[checked]** = read-only `git` / `git grep` done for this digest, or a count computed from the table rows. A grep
hit shows only that a name occurs, not that the behavior works. The searches were targeted, not an API audit.

## 1. The four parity tables at a glance

| Doc | Direction (source -> target) | Rows | Stated score | Open TODO | N/A | Generator script (as stated) |
|:--|:--|--:|:--|--:|--:|:--|
| IOS | Android core (+ ClassifyMenu Android libs) -> iOS | 1002 (A 389, B 613) | 96/100 (971 matched) (IOS:99) | 31, all in A (A 92; B 100) | 1 cell | `android/merged/scripts/ios-alignment.mjs` |
| AND | iOS `Sources/CYLSearchBar` -> `android/merged/cylsearch` | 437 | 100/100 (409 DONE, 28 N/A) (AND:54) | 0 | 28 | `android/merged/scripts/api-alignment.py` |
| HM | iOS -> HarmonyOS ArkTS | 437 | 100/100, **working tree only** (HM:31) | 0 | 45 cells starting `TODO: N/A` | `scripts/harmonyos-api-alignment.py` |
| MP | iOS -> WeChat mini program | 437 | 97/100 (427 implemented or N/A) (MP:254) | 10 | 49 | script not named in what the block says; the entry says it follows the HarmonyOS script (MP:33) |

- [checked] Row counts and TODO / N/A counts above match a parse of the table blocks. AND, HM and MP list the same set of
  iOS API names (437).
- [checked] Last commits: IOS, MP, HM `115ef09` (2026-11-27, "regenerate the four API alignment tables"); AND `d958f73`
  (2026-11-27); XP `b9e7c41` (2026-11-25).
- Scoring everywhere: rows whose target column is not `TODO` / rows x 100, rounded down; no TODO = 100, all TODO = 0.
  A score measures **declarations / names matched**, not behavior. HM:9 and XP:174 say this ("by declarations", "by implementation").
- In HM and XP, a cell beginning with the literal text `TODO: N/A on HarmonyOS: <reason>` counts as **handled**. A plain
  grep for "TODO" therefore miscounts: HM's header says "TODO 0" while 45 of its cells start with "TODO".
- Generated blocks are between `<!-- ...:begin -->` / `end` markers; do not hand-edit them. For HM the documented loop is:
  replace a row's TODO, run the script (regenerates rows from Swift sources, keeps column 3, prints the score) (HM:11-13).
  Hand mappings live in the scripts (IOS: `MANUAL` map; AND: `ALIASES`; HM: `MANUAL`, `VIEW_OBJECTS`).
- Description cells are clipped in the source files themselves (MP / HM end in "…"; IOS cells are cut mid-word with no
  mark, e.g. IOS:221 ends "above the keyboar |" [checked]).
- Text artifact in MP / HM / AND descriptions: `UISearchBar` / `UISearchController` appear to have been blindly
  replaced by "the system search bar / controller", giving "qmui_styledAsQMthe system search bar",
  "`QMthe system search controllerDelegate`", "delete the system's `the system bar background`". The cause is inference.

### Common type and naming mappings (useful for porting)

- **Android** (AND:19-22): colors `@ColorInt Int` (null = theme default), images `Drawable`, sizes dp, durations seconds,
  `UIFont` = `font: Typeface` + `fontSize` (sp), `UIKeyboardType` = `InputType` class, `UIReturnKeyType` =
  `EditorInfo.IME_ACTION_*`, `NSNotFound` = -1, view controllers = fragments. Delegate methods are named after the ObjC
  selector (`searchBarViewTextDidChange`); enum cases are PascalCase.
- **Android class merges**: iOS `CYLSearchController` and `CYLSearchView` -> Android `CYLSearchView`;
  `CYLSearchControllerDelegate` -> `CYLSearchViewDelegate`; `CYLSearchTableViewController` -> `CYLSearchListView`;
  AND:39 also says iOS `CYLSearchBar` is `CYLSearchBarView`.
- Android renames: `searchIconImage`->`searchIcon`, `clearIconImage`->`clearIcon`, `textFieldBackgroundColor`->
  `fieldBackgroundColor`, `textFieldBorderColor`->`fieldBorderColor`, `textFieldCornerRadius`->`fieldCornerRadius`,
  `item(dictionary:)`->`fromMap`, `automaticCornerRadius`->`AUTOMATIC_CORNER_RADIUS`, `historyStore`->
  `suggestionCache`, `historyDidChangeNotification`->`addHistoryDidChangeListener` (view) / `observeHistoryDidChange`
  (resources), `embedInNavigationBar`->`embedInToolbar`, `standardHeight`->`STANDARD_HEIGHT`,
  `refreshAccessibilityLabel`->`refreshLabel`, `becomeFirstResponder`->`requestFocus()`, `resign...`->`clearFocus()`,
  `encode/decodeRestorableState`->`onSave/onRestoreInstanceState`, `accessibilityPerformEscape`->back key via
  `OnBackPressedCallback`, `updateResultsFor`->`updateResultsForSearchString`, `attach(to:)`->`attachToMenuItem`.
- **HarmonyOS / mini program**: mostly the iOS names without argument labels; initializers are `new X(…)`;
  overloads collapse (`closeSearch`); `searchOpen`->`isSearchOpen`; `install(in:)`->`installInView` (HM);
  `image(named:)`->`imageNamed`; `suggestionCacheTitleLabel`->`suggestionCacheTitle`; `clearSuggestionCacheButton`->
  `clearSuggestionCache()` (the header button calls it).

## 2. IOS table (Android core -> iOS)

### History (as stated in the document)

- Task 2026-11-17 (IOS:7-38): table of Android APIs, TODO by default, score to 100, implement what iOS lacks (core first,
  then example copying Android), then keep the reverse table (AND) at 100. Example given by the user: tag dragging and a
  tag with icon + title + always-present delete icon, with deletion shown in the tag-list demo. Rule: AGENTS.md "API
  parity tables"; skill `cyl-api-parity`.
- Score log (IOS:82-95), all 2026-11-17: 82 (760/917) -> 72 (668/924, remeasured at ClassifyMenu `41aec0d`, Swift core)
  -> 94 (read the sub-repo's own Android->iOS table, `docs/android-ios-api.md` there) -> 99 (`MANUAL` map) -> 98 (38
  sub-repo names missing from Swift sources) -> 99 -> **100 (924/924)** at ClassifyMenu `652e084`.
- **Superseded:** the generated block now has 1002 rows at 96; section B measured at `697e930` (2026-11-19) (IOS:497).
  The score log has no entry for this. Reverse table then was "100, 397 rows" (IOS:52); AND now has 437.
- Lessons stated: the generator checks each bare name taken from the sub-repo table against measured iOS sources
  (`existsInIOS`) because that table lagged its Swift migration; `TagCollectionView/` had to be searched (23 of 38
  misses); 114 name-only matches were reviewed, 2 were wrong (`CYLSearchSuggestionCell.imageView` / `textLabel` had
  matched the placeholder view). A parser bug (skipping Kotlin classes with multi-line primary constructors; 122 rows)
  was fixed in ClassifyMenu `f77cd48` (its tables then 733/733 and 762/762).
- Sub-repo changes [claim]: `a3c2e1f` restored `CYLFilterParamsTool` / `CYLFilterBaseController.settingArray` in Swift;
  `f77cd48` added `CYLTag.resetColors()`.
- Pin bump DONE (2026-11-17, "pending CI") ClassifyMenu `f972416` -> `ec52480` (`feat/harmony`) in Podfile,
  `android/merged/gradle.properties`, both CrossPlatform Podfiles (IOS:62-80). Blocker: `477323d` made ObjC-representable
  `CYLTagListView` members `@objc` again; `ec52480` added ObjC `tagClickHandler` (index, title). Fold positions renamed
  `inline`->`tail`, `bottom`->`footer`, `topTrailing/topLeading`->`headerTrailing/headerLeading` (ObjC factory
  `-initWithPosition:content:`); RN and Flutter wrappers keep the old strings and also accept the new names. RN iOS
  imports `CollectionViewClassifyMenu-Swift.h`. Later note: macOS session's `pod install` and iOS/Flutter/RN builds of
  2026-11-19 verified it ([claim], animated-icon-component.md rows 37-38). The original note says three Podfile.lock
  files still named `f972416`; the later note does not say whether they were updated.

### The 31 TODO rows (Android API with no iOS counterpart in the table)

| Group (grouping is this digest's) | n | Members |
|:--|--:|:--|
| QMUI accessory-view aliases ("the same as leadingView / trailingAccessoryViews") | 8 | `CYLSearchBarView.`leadingAccessoryView, showsLeadingAccessoryView, leadingAccessoryViewMargins, trailingAccessoryView, showsTrailingAccessoryView, trailingAccessoryViewMargins, setShowsLeadingAccessoryView, setShowsTrailingAccessoryView (IOS:277-282, 292-293) |
| UISearchBar-shaped members on `CYLSearchBarView` | 6 | textFieldMargins, showsCancelButtonWhenEditing, usedAsTableHeaderView, alwaysEnablesCancelButton, backgroundView, segmentedControl (IOS:267-287). Inference: AND maps iOS `CYLSearchBar` onto `CYLSearchBarView`, and no such iOS class is in `Sources/` now |
| Android back button / predictive back / safe area | 5 | backButtonHandler, backButtonDrawable, respectsSafeArea, setBackButtonProgress, backPressedCallback (IOS:303-311) |
| Keyboard | 1 | keyboardOverlapHandler (after `pinToKeyboard`: how much the keyboard covers) (IOS:221) |
| `CYLSearchListView` internals | 5 | adapter, opensSearchViewOnTap, footerHeight, searchBarHiddenHeight, settleSearchBar (IOS:334-345) |
| `CYLSearchTagListStyle` | 2 | TAG_CONTENT_HORIZONTAL_INSET, backgroundStyleNamed (IOS:371, 378) |
| `CYLSearchView` presentation | 4 | clearsQueryOnClose, hidesNavigationBarDuringPresentation, prefersStatusBarHiddenProvider, preferredStatusBarStyleProvider (IOS:464-470) |

[checked] No hits under `Sources/` for keyboardOverlapHandler, showsCancelButtonWhenEditing (searched in
`Sources/CYLSearchBar`), alwaysEnablesCancelButton, backgroundView, segmentedControl, respectsSafeArea,
hidesNavigationBarDuringPresentation, prefersStatusBarHiddenProvider, or a `textFieldMargins` whole word
(`textFieldMarginsProvider` does exist, CYLSearchBarView.swift:417). The other TODO names were not searched.

**N/A cell (1):** `CYLFilterParamsTool.filesDir` (IOS:829); see section 8.

### Section B (ClassifyMenu): 613/613, 100

Almost 1:1 names. What the table shows about that API (from its descriptions):
- Types: `CYLTagListView` (sections or flat `CYLTag`s; data source `CYLMenuDataSource`, delegate `CYLMenuDelegate`;
  fold control, selection modes, reordering with long press 0.5 s / sensitivity, delete, JSON/plist configuration),
  `CYLTagButton` (built on CYLTabBarController's `CYLAnimatedItemView`; badge nil hides, "" dot), `CYLTagListCell`,
  `CYLTagDataSource`, `CYLMenuStyle` / `CYLTagAppearance`, `CYLMenuFoldControl` (positions NONE/FOOTER/HEADER_TRAILING/
  HEADER_LEADING/TAIL), `CYLTagView`/`CYLTagGroup`, `CYLClassifyMenuViewController`, filter controllers
  (`CYLMultipleFilterController`), image tags (`CYLImageTagView`, `CYLImageTagGroupView`, at most six tags per dot),
  `CYLMenuResources`.
- Swift renames of selectors: `deleteItem(at:)`, `scroll(toSection:animated:)`, `tag.style(basedOn:)`,
  `UIColor.cylMenuColor(from:)` ("#RRGGBBAA", alpha last), `CYLTagMetrics.tagHeight(for:minimumHeight:)`,
  `URL.cylAddingAnimationOptions(_:)`, multiple filter state = `selectedIndexPaths()` / `setSelectedIndexPaths(_:)`.
- Android draws default icons in code; iOS uses bundle images `cyl_fold_chevron`, `cyl_tag_plus`, `cyl_more`.
  Android stand-ins (`CYLEdgeInsets`, `CYLRect`, `CYLIndexPath`, `CYLFont`, `CYLColor`...) map to UIKit/CoreGraphics.
  App tint = RGB 42,185,160. Default badge red `#FF3B30`.

### Section A behaviors recorded in descriptions (cross-platform core knowledge)

- Classes: `CYLSearchBarView`, `CYLSearchBarItem`, `CYLSearchView`, `CYLSearchResources`, `CYLSearchListView`,
  `CYLSearchNavigationBar`, `CYLSearchBarAppearance`, `CYLSearchTagListHeader/Style`.
- Navigation field preset (`applyNavigationFieldStyle`) is the one look for every navigation/page-header search field.
- Default search button shown by default (not for editing bars or multiple mode); default style is the filled-capsule
  icon; `text` is opt-in. Items: icon (36 dp touch), divider (no taps, skipped by TalkBack), text.
- First-level page bar: tap pushes (`onFirstLevelTap`, `pushesOnTap`, back button progress 0..1, 0.25 s).
- Suggestion cache policies: none, database (SQLite, default), user defaults / SharedPreferences, sandbox JSON file;
  newest first, no duplicates. Suggestion style default = tags, folded with fold control as the last tag.
- Refresh and "no results" placeholder come from CYLTableViewPlaceHolder; tag views from ClassifyMenu. Section header
  refresh is an icon, not text. Tag list defaults: 17 sp, 36 dp high, 12 dp apart, 16 dp inset, bold 20 sp header,
  1 dp light border; Liquid Glass by name "liquidGlass", anything else flat.
- `usedAsTableHeaderView`, `snapsHeaderSearchBar` (QMUI #1160/#1207), `hidesSearchBarWhenEmptyViewShowing` (QMUI #128).

## 3. AND table (iOS -> Android)

- Done 2026-11-12 for steps 4-5; score log (AND:29-39): 11, 33, 68, 83, 91, 100; 299, 302, 323 rows at 100
  (11-12/13); 11-17: 397 rows (two `viewDidLayoutSubviews()` N/A rows). 2026-11-24: regenerated against the Swift core of
  PR #11: 443 rows, started at 83 (71 TODO), ended 100. Current block: 437 rows.
- 2026-11-24 additions listed (AND:39): `CYLSearchNavigationBar`, internal `CYLSearchHeaderSnapper`, appearance fields
  (field/bar background images, bar border, `hidesBarBackground`), `usedAsTableHeaderView`, `alwaysEnablesCancelButton`,
  `backgroundView`, `segmentedControl`/`scopeButtonTitles`, many `CYLSearchView` presentation/header members,
  `observeHistoryDidChange`, tag header/style methods. "N/A (9...)" new rows: no system search controller, appearance
  transitions, gesture recognizers, `UITableView.Style`, Liquid Glass, navigation-bar UIKit conformances.
- [claim] 2026-11-24 entry: **"Not compiled or run (no JDK 17 for AGP on this Mac)"**; host tests are in
  `CYLSearchControllerAlignmentTest`. Whether later work built it is not recorded here.
- [claim, older] `cylsearch/src/test/kotlin/com/cyl/search/CYLSearchBehaviorTest.kt`: Robolectric, 9 tests, all pass
  (filtering, submit/close rules, navigation button, suggestion tap, blank refusal, silent programmatic text,
  max length, iconified, multi-search selection rules, placeholders/localization) (AND:44-48). It dates from when multi-search was
  the separate `CYLMultiSearchView` class.
- Per-step scores were "replayed with `--only=`" on final sources.
- Second column = upstream API cited by the iOS doc comment (QMUI, MaterialSearchView, lapism, iammert), but it often
  just holds any backticked text from the comment (see section 8).

**28 N/A rows by reason** [checked count]:

| Reason | n | Rows |
|:--|--:|:--|
| Framework override | 7 | bar: traitCollectionDidChange, tintColorDidChange, intrinsicContentSize, sizeThatFits, layoutSubviews; view: layoutSubviews, safeAreaInsetsDidChange |
| Internal listener (UIKit protocol conformance) | 17 | 5 `UITextFieldDelegate` rows of the bar; 7 `searchBarView...` + 3 `tableView...` rows of `CYLSearchView`; `CYLSearchNavigationBar.navigationBar(_:shouldPop:)` and `position(for:)` |
| No gesture recognizers (system back gesture / `OnBackPressedCallback`) | 2 | controller swipeGestureRecognizer, gestureRecognizerShouldBegin |
| No `UITableView.Style` (one `RecyclerView`) | 1 | `init(contentsViewController:resultsTableViewStyle:)` |
| Unavailable on iOS too | 1 | `CYLSearchController.init(coder:)` |

(`CYLSearchView.init(coder:)` and the bar's `init(coder:)` are DONE on Android as the XML constructor.)

## 4. HM table (iOS -> HarmonyOS)

- History: 2026-11-13 score 0; 2026-11-14 100 "compiled, not run"; heading DONE 2026-11-16: 100 by declarations, example
  runs on the Mate 70 Pro emulator since 11-16 (HM:9-17). Rule: study Applib-HarmonyOS/FlexibleSearchBar before the
  search bar and note what is reused (HM:15); neither HM nor XP records the outcome.
- Score log 2026-11-16 (HM:26): "UIKit-only rows relabeled `TODO: N/A` (67 rows)". Current table has **45** such rows.
- **Uncommitted change (important):** [checked] `git diff` shows 5 changed lines: header 433/437, TODO 4, 99/100 ->
  437/437, TODO 0, 100/100, and four rows going TODO -> mapped: `performFirstLevelTap()` (HM:205),
  `dismissesKeyboardOnOutsideTouch` (HM:210), `automaticCornerRadius` (HM:247),
  `CYLSearchNavigationBar.applyNavigationFieldStyle()` (HM:324). The matching code is **also uncommitted**:
  `harmonyos/cylsearch/src/main/ets/CYLSearchBarView.ets` (adds static `automaticCornerRadius`, `barId`,
  outside-touch dismissal through `UIObserver` `willClick` / `scrollEvent` only while editing and never for an editing bar,
  and `performFirstLevelTap()`) and `scripts/harmonyos-api-alignment.py` (MANUAL entry for
  `applyNavigationFieldStyle`; the method itself already appears in the file at CYLSearchBarView.ets:1856). So committed
  state is 99, the working tree 100. No build or test of these edits is recorded in HM/XP, and HM's score log has no entry
  for either the drop to 99 or the return to 100. Possibly another session's work in progress (inference).

**45 `TODO: N/A` rows by reason** [checked count]:

| Reason | n | Rows |
|:--|--:|:--|
| ArkUI has no view objects (the component draws it from properties) | 14 | bar: fieldView, searchIconView, cancelButton, placeholderLabel, navigationButton, voiceButton, submitButton, iconButton, newSearchButton; item actualBadgeSuperView; view: dividerView, suggestionsTableView, suggestionsTagView, suggestionCacheHeaderView (`CYLSearchComponent.cacheHeader`) |
| `TextInput` lacks the trait | 2 | autocapitalizationType, autocorrectionType |
| No archives (state restored by `decodeRestorableState`) | 3 | the three `init(coder:)` |
| System colors follow mode/theme | 2 | traitCollectionDidChange, tintColorDidChange |
| ArkUI measures / lays out / keeps safe area itself | 4 | sizeThatFits, two layoutSubviews, safeAreaInsetsDidChange |
| UIKit protocol conformance | 18 | 5 text field, 3 controller `searchBarView...`, 10 view |
| Gesture is a declared `PanGesture` in `CYLSearchComponent` | 1 | swipeGestureRecognizer |
| Page draws its own header (title + `CYLSearchRefreshButton`); use `refreshImage` | 1 | `CYLSearchTagListHeader.applyRefreshIcon(to:)` |

Non-trivial HM mappings: `trailingAccessoryViews` / `leadingView` are `@BuilderParam`s of `CYLSearchBarComponent`;
`historyDidChangeNotification` (controller) -> `observeHistoryDidChange`; `showEmptyView(scenario:)` ->
`showEmptyViewScenario`; `applyNavigationFieldStyle` -> `CYLSearchBarView.applyNavigationFieldStyle()`.

## 5. MP document (WeChat mini program)

### Table: 10 TODO rows (MP:426-433, 470, 547)

All are newer navigation / focus / corner-radius APIs. [checked] grep for each name in
`CrossPlatform/wechat-miniprogram-cylsearch/src`:

| TODO row | Name hits in src | Note |
|:--|:--|:--|
| pushesOnTap, onFirstLevelTap | yes | `cyl-search-bar/index.js` (property, event `firstleveltap`) and `core/CYLSearchNavigationBar.js:82-120` |
| focusesOnAppear | yes (10 lines) | `cyl-search-bar/index.js:46-50, 269-277` |
| backButtonProgress | yes (2 lines) | not inspected |
| automaticCornerRadius | yes (1 line) | not inspected |
| CYLSearchNavigationBar.applyNavigationFieldStyle | yes | method on the bar model `core/CYLSearchBarView.js:848` and component method `index.js:304`; the row is filed under the navigation bar (same parser issue HM patched with a MANUAL entry) |
| performFirstLevelTap, isBackButtonShown, pageDepth, dismissesKeyboardOnOutsideTouch | 0 hits | appear genuinely absent under these names |

So at least some TODOs may be generator-matching gaps (member not on the class the script looks at), not missing
features. This was not verified behaviorally.

**49 N/A rows by reason** [checked count]: no view objects 18 (textField, the 8 bar subviews, itemViews,
newSearchButton, item itemView and actualBadgeSuperView, controller tableView, view dividerView /
suggestionsTableView / suggestionsTagView / suggestionCacheHeaderView); no view controllers 1
(searchResultsController); `<input>` has no autocorrection trait 1; no archives 3; colors / inherited tint 2; measure,
layout, safe area 4; UIKit protocol conformances 18; no gesture recognizers 1 (but
`gestureRecognizerShouldBegin` is mapped); WeChat custom navigation bar already reaches under the status bar 1
(`position(for:)`).

Notable MP mappings: `pinToKeyboard` -> `<cyl-search-bar pinsToKeyboard>` (fixed bottom, lifted by
`wx.onKeyboardHeightChange`); accessory views -> slots `leading` / `trailing`; `CYLSearchController.install(in:)` and
`CYLSearchView.install(in:)` -> `<cyl-search inline>`; `embedInNavigationBar` -> `<cyl-search-navigation-bar>` (page needs
`"navigationStyle": "custom"`, a bar cannot be added at run time); item views drawn by ClassifyMenu `<cyl-tag-button>` from
`CYLSearchBarItem.tagButtonProperties()`; empty views are `cyl-placeholder`; results sit inside `cyl-refresh`;
`autocapitalizationType` is mapped (HM marks it N/A).

### Dated entries (all 2026-11-15; each keeps the names of its time, MP:8). Numbered in document order

Chronology (inferred from branches and Node test counts: 14 at MP:35, 17 at MP:234, 26 at MP:210, 30 at MP:139, 31 at
MP:93): item 1 is the oldest, then 5, 4, 3; item 2 is the newest.

1. **Core aligned + example + CYLTabBarController tab bar** (PR #8, `feat/swift-core`) (MP:10-56). Core = HarmonyOS ArkTS
   models ported to CommonJS (UI structs cut, types stripped by tsc, hand edits). Storage: `wx.setStorageSync` (database:
   key per cache; user defaults: one shared key), sandbox file via `wx.getFileSystemManager()`; `CYLSearchResources`/`$r`
   on generated string tables and SVGs; `CYLSearchPlatform` supplies ArkUI names. Then 397/397 = 100 and Node 14/14
   [claim]; **superseded** (437 rows, 97). Five tab pages + plus page (max five tab pages); tab bar pinned
   CYLTabBarController `a8e5305` via `scripts/sync-example.js`. DevTools screenshots with base library 3.6.6. Lottie
   placeholders added, **later removed** by entry "as on iOS". Context also records: HarmonyOS project moved to
   `~/develop/CYLSearchViewController-swift-core/harmonyos` for DevEco.
2. **As on iOS before npm publish** (PR #9, `feat/swift-core-next`) (MP:58-99): static placeholders
   (`emptyResultsScenario` NoSearchResults, `emptySuggestionsScenario` NoContent) through abstract node `cyl-empty-view`
   (default draws the library's own placeholder so the package has no dependency); pull-to-refresh =
   CYLTableViewPlaceHolder `cyl-refresh`; dark mode needs `"darkmode": true` + `theme.json` (media rules never applied
   before). Pins: placeholder `8ee7013`, tab bar `c006143`. Removed Lottie placeholder props and nodes. [claim] Node 31/31,
   18 pages + 11 interactions, no console errors; **dark appearance not verified**.
3. **Package as an npm library** `cyl-search-miniprogram` (MP:101-154). Pattern: `project.config.json` at package root with
   sync hooks, git-ignored `project.private.config.json` for AppID, `package.json` `miniprogram: "src"`, MIT LICENSE
   (user's choice 2026-11-15; iOS podspec then said "All rights reserved"). Lessons from consuming via `npm pack` +
   DevTools Build npm: (a) `main` must be `src/index.js`; (b) mini programs do not resolve a folder to `index.js`;
   (c) DevTools "filter unused files" misses a `require` inside object spread, use `Object.assign`. Same faults fixed in
   CYLTableViewPlaceHolder PR #32 (`a72ff3f`). DevTools runs project hooks only after approval in its window, so run
   `npm run sync-example` when driving by CLI. [claim] 106 files, 41 exports, Node 30/30.
4. **1:1 copy of the iOS example** (`d19e0bb`) (MP:156-216): same four tabs + plus page, texts (en, ja, zh-Hans, zh-Hant),
   data, images; imports via `scripts/import-ios-resources.js`; page-by-page iOS->mini program map is in the document.
   Platform differences: WeChat capsule button stays top trailing (custom bars center on it and end before it,
   `cyl_navigation_metrics.js`); speech recognition needs a plugin (Voice sample says unavailable; hold-to-ask only
   changes the hint); Discover camera opens a modal. Open warning: "21 listeners of event ThemeChange" from
   CYLTabBarController's `cyl-tab-bar`, not fixed. [claim] Node 26/26.
5. **Playback controls + DevTools Skills** (second oldest) (MP:217-252): controls (speed 0.25-3 in 0.25 steps, loop, play all).
   Its Update says List style tab removed and controls moved to MaterialSearchView samples; entry 2 later removed the
   animations and controls. `sync-example.js` uses sparse checkout (full checkout failed on Windows "Filename too long").
   `wechatide-skill` 0.3.11 ships with DevTools 2.02.2609250; on Windows call
   `C:\Program Files (x86)\Tencent\微信web开发者工具\wechatide.cmd` (not on PATH; the skill's install check reports
   `cli_unavailable` because of the unquoted path); needs the service port enabled and a logged-in DevTools. [claim] Node 17/17.

Environment in screenshots: Windows 11 Pro 10.0.22631, WeChat DevTools 2.02.2609250, base library 3.6.6.

**Stale vs tree** [checked with `git ls-files`]: `src/` now has `core/`, `cyl-search/`, `cyl-search-bar/`,
`cyl-search-navigation-bar/`, `cyl-search-refresh-button/`, `images/`, `index.js`, `LICENSE`. The path table
(MP:138-154) still lists `src/cyl_search.js`, `cyl-search-bar-item`, `cyl-search-controller`, `cyl-multi-search`,
`cyl-search-placeholder`, `cyl-search-animation-placeholder`, `cyl-search/*.js` helpers and `images/placeholder/`, none
present. `package.json` pins now: tab bar `08343e9f76d6...`, placeholder `f4cf978567e4...`.

## 6. XP (HarmonyOS cross-platform)

### Basics

- Intro (XP:3-9): the core on every platform is CYLSearchBar; "four public classes" `CYLSearchBarView` (mode
  single/multiple), `CYLSearchBarItem`, `CYLSearchView` (suggestions, results, placeholders, the only refresh API),
  `CYLSearchResources`. Library `harmonyos/cylsearch`, example `harmonyos/entry`. Other platforms:
  android-and-cross-platform.md, search-core-merge.md. [checked] `harmonyos/cylsearch/Index.ets` also exports "QMUI-shaped
  fronts" `CYLSearchBar`, `CYLSearchController`, `CYLSearchTableViewController`, `CYLSearchNavigationBar`, tag style.
- Version (XP:14-21): HarmonyOS NEXT, target and minimum 6.0.1 (API 21; minimum forced by `cylplaceholder`), ArkTS,
  ArkUI state V2 (`@ComponentV2`), DevEco Studio 6.0.1 + bundled SDK, hvigor, ohpm; Mate 70 Pro emulator, **unsigned
  HAP**, `hdc install`. Bundle/ability: `com.cyl.search.harmonyos` / `EntryAbility`.
- Principles (XP:135-142): API matches iOS, example is a 1:1 copy, internals migrated from Android Kotlin.

### How to build and run (as documented)

- hvigor rejects paths with spaces or non-ASCII: mirror `harmonyos/` to an ASCII path (e.g. `C:\cylbuild\harmonyos`),
  set `DEVECO_SDK_HOME` to DevEco's `sdk`, put its `jbr\bin` on PATH,
  `hvigorw assembleHap --mode module -p module=entry@default -p product=default` (XP:145-147).
- Before building: `python3 harmonyos/scripts/sync-sub-repositories.py` (fills `harmonyos/vendor` with cyltabbar and
  cylplaceholder at pinned commits); then `hvigorw clean`.
- x86_64 emulator: Rive/PAG packages (`@ohos/rive` 1.0.4, `@tencent/libpag` 4.5.102) ship arm64-v8a only ("Abi type"
  install failure). Use `-p module=entry@emulator` (excludes `**/arm64-v8a/*.so`; 28.7 MB vs 38.4 MB HAP) and for
  ohosTest `-p buildMode=emulatorTest`; Rive/PAG animations unavailable there (row 25, XP:70). Emulator start failures
  seen: "can not read uuid file" (started without `-imageRoot`), "No enough space to start Emulator" (3.3 GB free).
- Launch a tab: `aa start -b com.cyl.search.harmonyos -a EntryAbility --pi CYLDemoTab <n>` where n counts like iOS
  `viewControllers`: 0 Search, 1 Examples, 2 plus page, 3 Tag style, 4 Discover. Also `CYLDemoTabIconSource 1`.
- IDE prep (DONE 2026-11-16, XP:109-125): region file `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml`
  must contain `<countryregion name="CN"/>` (original NZ kept as `.bak-NZ`); hypervisor present; build
  `DS-243.24978.46.36.601251`; image `phone_all_x86` in `%LOCALAPPDATA%\Huawei\Sdk`. Skill `cyl-harmonyos-setup`.
- Host checks without an emulator: `node harmonyos/scripts/host-logic-test.mjs` (pure logic in `CYLSearchLogic.ets`),
  `check-ios-parity.mjs` (357 resource strings/images), `check-accessibility-i18n.mjs`,
  `import-cyltabbar-localizations.mjs` (29 extra languages; en, ja, zh-Hans, zh-Hant curated),
  `import-ios-resources.py`; score scripts `scripts/harmonyos-scorecard.py`, `scripts/harmonyos-api-alignment.py`.
  [checked] `Sources/CYLSearchBar` file list and the `.ets` file list differ; whether all scripts still exist was not checked.

### Technical lessons

- Text badge wrapping: one line + measured width **including border width** (`cylTextBadgeWidth()`); badge anchors to the
  drawn icon, icon box follows drawn icon (`cylIconHeight`); plus title shares the other titles' top
  (`tabBarHeight - 17`). Later cyltabbar `ebaed17` centers badges on the icon corner (`markAnchor` 50 %).
- Raised plus button must not cover content: library now exposes `cyl_plusButtonOverhang` (cyltabbar PR #811,
  `b2ec2f3`, user decision 2026-11-17 "Fix in CYLTabBarController"); example applies it as
  `contentEndOffset(CYL_PLUS_OVERHANG)` on long full-height lists only (not short card lists: white strip, row 24);
  page padding caused a white band (rows 20, 26); Discover uses a grey filler row.
- `List` card: `.height('auto').flexShrink(1)`, not `layoutWeight(1)`.
- Keyboard: window does not resize (`KeyboardAvoidMode.OFFSET`); fixed **in core**: `CYLSearchComponent` pads by the
  keyboard-covered height (`keyboardHeightChange`); example's `RESIZE` mode removed (row 7).- `Path` commands are px and not scaled: build from measured width (row 18); `Path` has a default black stroke (row 22).
- `fillColor` tints SVG only; PNG needs `ColorFilter` (row 21, #8E8E93).
- Launch parameters need `EntryAbility` to copy `want.parameters` to AppStorage in `onCreate` and `onNewWant` (row 16).
- "Ignores every touch" (row 17): cyltabbar `9fb874c` exclusive long-press+tap gesture group; fixed by `onClick` +
  parallel long press in `3ddb96c`.
- uitest on API 21 does not report `accessibilityText`: `findByLabel` falls back to the id for icon-only controls;
  icon-only controls need `accessibilityGroup(true)`; the emulator keyboard's first-run privacy screen had to be accepted
  (user agreed 11-17); submitting closes the search page, so one Back only.
- Core-vs-example table (XP:93-105): rows 1-4, 7, 10, 12-15, 20 fixed in a core library; 5, 6, 8, 16, 18, 21, 22, 24
  example only; 25 open in sub-repo cores.

### Scorecard 3: screenshot issues (26/26, "100"; DONE 2026-11-16, XP:23-108)

Rule: TODO by default; "TODO need 模拟器截图验证" counted as non-TODO until a screenshot made it DONE. All 26 Status cells now
say DONE [claim]. By repository:
- cyltabbar library/demo: 1 badge wrap, 2 icon centering, 3 plus title baseline, 4 badge position, 11 list bottom inset,
  12 border clipping (upstream PR #805; the "my duplicate PR #801 was closed" remark belongs to row 1), 13 untranslated strings (33 languages), 14 nav bar
  centerline, 15 English subtitles in Chinese UI.
- Example/core here: 5 raised blue plus (imageSize 56), 6 Examples card, 7 keyboard (core), 8 tab icons, 9 Discover (no
  change), 10 plus overhang, 16 launch tab, 17 touch (library), 18 curve, 19 no change (rows have no tap action on iOS
  either), 20 white band, 21 grey icons, 22 curve stroke, 23 SVGA header (old build), 24 card strip, 26 Discover strip.
- **Row 25** DONE for the workaround only: x86_64 Rive/PAG support is **still open upstream** in CYLTabBarController and
  CYLTableViewPlaceHolder. [claim 2026-11-21 23:01 +13:00] emulator target installs and runs; hypium **29/29** with
  `buildMode=emulatorTest`; Mate 70 Pro 127.0.0.1:5557, HarmonyOS **6.0.0.112** (API 21), DevEco 6.0.1.251, `efb3b78`.
- Review notes: third review (11-16 15:10) could not run code locally (no emulator instance). "Next screenshot run"
  note (16:22) lists expected screens per row (historical).

### Kotlin parity of internals (2026-11-16, XP:149-166; tests in `entry/src/ohosTest/ets/test/CYLSearchCore.test.ets`)

- `CYLSearchView`: query trimmed for emptiness, accent-folded matching; placeholders use trimmed query; refilter shows
  suggestions again, handled submit dismisses them; `setQuery` / tapped suggestion set text silently, report once, submit
  through the bar (`shouldSubmit`, blank refused, untrimmed text to delegate); didShow/didClose fire after animation;
  `showSearch` on an open view refocuses; changing a scenario replaces the placeholder.
- `CYLSearchBarView`: `setText` silent; `submit` refuses whitespace; `iconifiedByDefault` folds empty field on end editing.
- Default store: keeps at least one query, empty name = `CYLSearchView`, safe file name, `none` keeps nothing.
- Multiple mode: nothing selected while typing, text not trimmed, `addSearch` completes the one being typed and reports
  nothing, removal selects next as Kotlin does.

### Scorecard 2: remaining work (100: 16 DONE + 1 N/A; XP:168-218)

Full-score standard: DONE with evidence; compile-only counts only for compile rows; behavior needs emulator/device.
User N/A rule (11-16): rows impossible without emulator are `TODO: N/A on HarmonyOS` and must be run later.
Rows: (1) inline fold control as last tag (`cylFoldedTagCount`); (2) fold position `none = 2`; (3) "Recent searches
cleared" announcement; (4) delayed focus for iconified bar (`showKeyboardWhenDrawn`, up to 30 frames); (5) one fold
measurement; (6) app and test HAPs compile; (7) emulator exists (127.0.0.1:5555, 6.0.1.112, API 21, x86_64);
(8) hypium on emulator: first 21/22 with 1 error, after fixes **22/22** (2026-11-17, cyltabbar `b2ec2f3`; newer: 29/29 on 2026-11-21, row 25);
(9) **`TODO: N/A`: launch all 25 demos, check 1:1 with iOS, labeled screenshots, rows 1-4 on screen**;
(10) database policy is real SQLite (`relationalStore`, `cyl_search_suggestions.db`, table `queries(cache, query, time)`,
old preferences migrated once, in-memory mirror, queued writes, `whenStored()`); (11) no compiler warnings
(`UIContext.animateTo` via `cylAnimate`); (12-13) pure logic host tests 14/14 then 23/23; (14) resource parity 357/357;
(15) screen-reader labels, 44 vp targets, multi-search position (not heard on a device); (16) localization;
(17) UI tests find by label (31 tappable elements, 0 problems).
Score log 66 -> 72 -> 75 -> 100 (the jump to 100 came from marking rows 7-9 N/A).

### "Score" section, Table 1, Table 2

- Combined score (XP:226): 100/100, 468 rows = API 443/443 + demos 25/25. Log: 94 -> 100 -> back to 99 (tab bar and
  refresh header drawn in the example, no speech recognizer) -> 99 (CoreSpeechKit) -> 100 (cyltabbar + cylplaceholder
  libraries; minimum raised to API 21).
- Table 1 (443 rows, 48 `TODO: N/A`) is meant to copy HM's third column (rule 1, XP:136-138) but is **stale** [checked]:
  - 37 names only in Table 1: all 27 `CYLSearchBar` rows (class, appearance, margins, cancel button, scope control,
    accessory views, image generators) and 10 controller rows (searchController, hidesNavigationBarDuringPresentation,
    forwardsAppearanceFromContentsViewController, two status bar providers, updateSearchResults(for:), four
    will/did present/dismiss methods). `git grep` finds no `CYLSearchListView`, `hidesNavigationBarDuringPresentation`
    or `forwardsAppearanceFromContentsViewController` under `Sources/`, and the listing of its public classes has no
    `CYLSearchBar`.
  - 31 names only in HM: SearchButtonStyle (3) + 5 search button members; pushesOnTap, onFirstLevelTap,
    performFirstLevelTap, isBackButtonShown, backButtonProgress, focusesOnAppear, pageDepth,
    dismissesKeyboardOnOutsideTouch; item automaticCornerRadius, cornerRadius, borderColor, borderWidth, itemHeight;
    3 controller `searchBarView...` conformances; `applyNavigationFieldStyle`; `CYLSearchBarPreset` (6).
  - Table 1's 48 N/A also include `CYLSearchBar` rows (cancelButton, backgroundView, segmentedControl, init(coder:), two
    image generators: "ArkUI draws from colors, no resizable image"; no scope titles, a page uses `SegmentButton`).
- Table 2: 25 demos, all mapped. Key files: `pages/Index.ets`, `demos/SearchExample.ets` (Issue #1317 repro with
  `CYLSearchRefreshComponent` + `setRefreshHandler`/`endRefreshingIn`), `demos/ExamplesMenu.ets`, placeholder gallery
  (41 styles x 4 messages + Custom) and detail, `demos/SearchBarDemo.ets`, `demos/Ports.ets`, `demos/MaterialSearch.ets`
  (six samples; `tags: true` for Tag style tab), `demos/Discover.ets` (rawfile `discover/<language>.json`),
  `common/SpeechRecognizer.ets` (CoreSpeechKit, mic permission, **zh-CN only**), `common/DemoCommon.ets` snackbar,
  RevealPage (core `iconButtonBackgroundColor`/`iconButtonTintColor`), languages base/ja_JP/zh_CN/zh_TW, `sys.color.*` +
  `resources/dark`. Table 2 cites cyltabbar `94eb7b1` and cylplaceholder `5bcbdb5` (older than pins in later entries).
  It cites iOS `.m` files for three rows; [checked] the tracked files are `.swift`
  (`CYLSearchExampleAppDelegate.swift`, `CYLSearchDemoMenuViewController.swift`, `CYLSearchBarDemoViewController.swift`).

### Pins and evidence runs by date (as stated; not checked against the current tree)

- cyltabbar: `94eb7b1` (demo table) ; `9fb874c` (issue fixes) ; `3ddb96c` ; `ea5b989` (third review, 11-16 15:10) ;
  `ebaed17` (11-16 16:22 and first emulator check) ; `eba8c44` (later 11-16 run, then "newest on any branch") ;
  `b2ec2f3` (11-17). cylplaceholder: `5bcbdb5`, `76762c6`.
- 11-16 emulator check (zh-CN, base `4cdf9c9`): screenshots `docs/assets/harmonyos-sc3-*.png`. 11-16 second run (base
  `ca9bc61`): `harmonyos-eba8c44-*.png`, 11 screens reached by launch parameters and taps. Then
  `harmonyos-discover-row24-fixed.png` and `harmonyos-row7-keyboard.png` (11-17). Rows evidence also in
  `harmonyos-mate70pro-api21-20261117-*.png`.

## 7. Behavior differences across platforms (collected)

| Topic | Android | HarmonyOS | Mini program |
|:--|:--|:--|:--|
| Internal view objects (fieldView, cancelButton...) | exposed (DONE) | N/A, but `textField`, `itemViews`, `item.itemView`, `resultsTableView`, `emptyResultsView` mapped | also N/A for textField, itemViews, item.itemView, controller tableView / searchResultsController; `resultsTableView`, `emptyResultsView` map to `<cyl-search>` descriptions |
| autocapitalization / autocorrection | both DONE | both N/A | capitalization mapped, autocorrection N/A |
| Swipe to dismiss | system back gesture, predictive back (API 34+ with `enableOnBackInvokedCallback`) | `PanGesture` in component | touch events + `cylEdgeSwipeBegins` |
| Tag list header refresh icon | `applyRefreshIcon` | N/A (`CYLSearchRefreshButton`) | mapped |
| Voice | not covered here | CoreSpeechKit, zh-CN only | needs plugin; sample says unavailable |
| Navigation bar | `Toolbar`; position(for:) N/A | mapped | custom navigation style, declared in page; capsule button |
| Liquid Glass | AND:39 lists it among N/A reasons, yet tag background style rows exist | tag style API mapped (rendering not described) | tag style API mapped (rendering not described) |
| Animated tag engines | - | Rive/PAG not on x86_64 emulator | Lottie placeholders removed; static as on iOS |

## 8. Contradictions and rows that look wrong

### Across / within documents

1. IOS narrative "100 (924/924)" (IOS:50-52, 95) vs generated "96 (1002, 31 TODO)" (IOS:99). The generated block is newer
   (commit `115ef09`, B measured 2026-11-19); no log entry records the drop.
2. HM committed 99 (4 TODO) vs working tree 100, depending on uncommitted code (section 4). HM:26 "67 rows" vs 45.
3. XP Table 1 (443 rows) vs HM (437): 37 / 31 names differ, against XP's own rule 1. XP "API 443/443" is stale.
4. XP:222 "none has run yet (no emulator on the Windows machine)" vs emulator runs 11-16 to 11-21 in the same file
   (rows 7, 8, 25; screenshot sections). XP:174-176 "nothing has run on a device" is the older starting state.
5. XP scorecard 2 row 9 keeps reason "needs an emulator" although row 7 reports one; partial screen checks exist
   (scorecard 3 and 11-16 runs) but no recorded full 25-demo 1:1 check, ScreenReader included.
6. HM table score log and XP's score logs end 2026-11-16 although tables changed later. HM:16 "compiled, not run" is
   superseded by HM:9.
7. HarmonyOS image version: 6.0.1.112 (XP:192) vs 6.0.0.112 (XP row 25, 11-21), with version table saying 6.0.1; ports
   5555 vs 5557 (may be a different instance).
8. XP row 11 is DONE but its Fix cell still quotes the upstream status "TODO need 模拟器截图验证" (DONE evidence is in Status).
9. XP intro "four public classes" vs Index.ets exporting more (QMUI fronts, tag style, enums).
10. AND:38 (11-17 row) lacks its score cell; AND:39 (11-24) has an extra cell ("100 | 100") and speaks of 443 rows vs 437
    now; "N/A (9...)" counts only the new ones (28 total).
11. MP: "397/397, 100" (MP:35) superseded by 437 / 97; pins and component path table stale (section 5); entry 1 and 5's
    Lottie / playback features removed by entry 2; test counts (14, 17, 26, 30, 31) are per-entry snapshots.
12. MP / HM / AND list `applyNavigationFieldStyle` under `CYLSearchNavigationBar`; [checked] it is declared in an
    `extension CYLSearchBarView` in `CYLSearchNavigationBar.swift` (extensions at :88, :128, :176; method :137). Parser
    attribution issue; HM's uncommitted MANUAL entry says so. The same may explain neighboring misfiled members (inference).
13. MP lists `pushesOnTap`, `focusesOnAppear` etc. as TODO although the names exist in mini program source (section 5).

### Suspicious table rows

IOS:
- IOS:356-359: iOS cells `CYLSearchSuggestionCachePolicy.None / .Database / ...` use Kotlin casing. [checked] Swift has
  `case none`, `case database` (CYLSearchResources.swift:104-108). Likely from case-insensitive enum matching.
- IOS:390 interface `CYLSearchViewDelegate` -> "protocol CYLSearchControllerDelegate", but its members map to
  `CYLSearchViewDelegate.*` (that protocol exists, CYLSearchView.swift:24). Some members instead map to
  `CYLSearchControllerDelegate`.
- Class `CYLSearchView` (IOS:411) -> `CYLSearchController`, and many members point at the controller although iOS
  `CYLSearchView` is a class (CYLSearchView.swift:124) with its own: [checked] `delegate` (:132, row IOS:412 maps to
  `CYLSearchController.searchResultsDelegate`), `searchBarView` (:137, mapped to `searchBar`), `resultsTableView`
  (:246, IOS:450 maps to `searchResultsController`), `install(in:)`, `showSearch(animated:)`.
- IOS:339 `snapsHeaderSearchBar` maps to `CYLSearchListView.snapsHeaderSearchBar`. [checked] No `CYLSearchListView` under
  `Sources/`; it is the Android class (CYLSearchListView.kt:23). Wrong cell.
- IOS:829 `CYLFilterParamsTool.filesDir` N/A "CYLFilterParamsTool was removed in the Swift migration (`70dcc816`)", while
  sibling rows (about IOS:821-828) map to `CYLFilterParamsTool.*` and IOS:55 says it was restored by `a3c2e1f`.
  `filterParamsArray` (IOS:825) maps to the index-path API. The N/A reason looks stale.
- IOS:566-577: `cyl_generalStyle`/`cyl_chengNiStyle` -> `UIButton.cylApply(_:)` but `cyl_homeStyle`/`cyl_redStyle` -> bare
  enum `CYLCollectionCellButtonStyle` (weaker match).
- `CYLSearchView.showEmptyView` (title/detail/button on Android) -> `showEmptyView(scenario:)`; button support on iOS is
  doubtful (MP/HM docs say the table controller variant has no button). `cancelButtonMargins` -> the *Provider*.
- IOS:286 (`scopeButtonTitles`, cell names `CYLSearchBar.segmentedControl`) and the `CYLSearchBarAppearance.applyTo` row
  (cell names `CYLSearchBar.appearanceStyle`) point at an iOS `CYLSearchBar` class that was not found under `Sources/`.
- Section B rows whose iOS cell is only the same bare name ("same name in the iOS core") are name-only evidence.
  `resetBackgroundColor/TextColor/Font` map to `default...` properties, not reset methods.

AND:
- AND:334-336: controller `searchBarViewDidBeginEditing`, `searchBarView(_:textDidChange:)`,
  `searchBarViewCancelButtonClicked` are DONE (the second as `CYLSearchView.searchBarView`, which in IOS is the bar
  **property**: apparent false name match), while the same kind of conformances elsewhere are N/A.
- AND second column is not always an upstream name: class `CYLSearchBarView` shows only "iammert MultiSearchView"
  (AND:116); class `CYLSearchController` shows "`CYLSearchBarView`" (AND:301); others show fragments like "36 pt field".

HM / XP:
- Mixed policy: "no view objects" N/A for several members while `textField`, `itemViews`, `itemView`, `tableView`,
  `resultsTableView` are claimed as members; whether these are real objects was not checked.

## 9. Open TODOs and unfinished work (as of these documents)

1. HM: commit (and build/test) the uncommitted CYLSearchBarView.ets + script + HM table changes; until then HEAD is 99.
2. HM/XP: regenerate XP Table 1 (`python3 scripts/harmonyos-scorecard.py`) and fix its stale "Score" prose and score logs.
3. XP scorecard 2 row 9: full on-emulator 1:1 check of the 25 demos with labeled screenshots; ScreenReader check of the
   announcement and labels.
4. XP row 25: x86_64 builds (or optional dependency) for `@ohos/rive` / `@tencent/libpag` in CYLTabBarController and
   CYLTableViewPlaceHolder.
5. IOS: 31 Android APIs without iOS counterpart (section 2); fix the suspicious cells; add a score log entry. Per the
   user's process, implement in core first, then examples.
6. MP: 10 TODO rows (4 names with no source hits; 6 need matching or behavior check); stale narrative path table/pins.
   Dark mode never visually verified [as of 11-15]; "21 listeners of ThemeChange" warning (CYLTabBarController) unfixed;
   voice recognition unavailable; Lottie animation motion once "not measured" (feature since removed).
7. AND: the 2026-11-24 alignment was recorded as not compiled/run; confirm elsewhere whether it was built later.
8. HM:15: no record of the FlexibleSearchBar study outcome in HM or XP.
9. MP (library task): publishing to npm was to follow the example parity; no publish is recorded in this file.

## Coverage

| Assigned file | Lines | Ranges read (tool) | Skipped / unread |
|:--|--:|:--|:--|
| docs/ios-api-alignment.md | 1116 | 1-216, 217-370, 371-521, 522-727, 728-945, 946-1116 (Read, offset/limit) | none |
| docs/miniprogram-api-alignment.md | 695 | 1-267, 268-407, 408-546, 547-668, 669-695 | none |
| docs/harmonyos-api-alignment.md (working tree) | 472 | 1-160, 161-303, 304-423, 424-472 | none |
| docs/android-api-alignment.md | 495 | 1-252, 253-494, 495 | none |
| docs/harmonyos-cross-platform.md | 747 | 1-97, 98-328, 329-612, 613-747 | none |

Notes: each Read returned the requested number of lines; no truncation marker appeared; the longest line (1933 chars)
is under the Read per-line cap. Cut-off table descriptions are in the source files. Row counts, set differences and line
numbers were computed afterwards by script from the same files. Linked screenshots and other documents were not opened.
Code was not read in full: only targeted `git grep`, `git diff` of the three HarmonyOS-related uncommitted files (HM table, CYLSearchBarView.ets, the
alignment script), `git ls-files`, `git log`.
