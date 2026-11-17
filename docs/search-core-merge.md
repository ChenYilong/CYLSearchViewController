# Search Core Merge (CYLSearchBar)

## DONE (2026-11-17): merge the search core into the fewest classes, on every platform

- **Context**: branch `feat/harmonyos-parity` (PR #11). The iOS core (`Sources/CYLSearchViewController`, Swift) has 9
  files and 15 public types: three search screens with overlapping roles (`CYLSearchView` suggestions page,
  `CYLSearchController` overlay, `CYLSearchResultsViewController` results table), two search bars (`CYLSearchBarView`,
  `CYLMultiSearchView`), `CYLSearchBarItem` / `CYLSearchBarItemView`, `CYLSearchPlaceholderView`,
  `CYLSearchResources` and the suggestion cache (`CYLSearchSuggestionStore`). The example calls
  CYLTableViewPlaceHolder's pull-to-refresh directly (`CYLRefreshNormalHeader`, `cyl_header`, `endRefreshing`). The
  Android core `android/merged/cylsearch` declares `search-lapism`, `search-materialsearchview` and
  `search-multisearchview` as `api` dependencies but uses none of them. The other platforms (React Native, Flutter,
  HarmonyOS, mini program) port the same classes. Nothing can be compiled in this session (Linux: no Xcode, no Android
  SDK); iOS CI on PR #11 is the only automatic check.
- **Requirements**:
  1. Merge every search-related component of the core into the fewest classes. On iOS, move every search file into
     one folder, `CYLSearchBar`, and merge classes with similar features and similar APIs into suitable files.
  2. Merge the search-related APIs of the other core folders. An API that duplicates another is kept once. An API
     that differs only by a parameter becomes one API with the new parameter, in the suitable file.
  3. Refresh interfaces live in the `CYLSearchBar` component; change the example's refresh calls that do not go
     through the core.
  4. CYLSearch is the only search kernel: it must not depend on another search kernel. CollectionViewClassifyMenu is
     excluded (it is not search-related).
  5. Then apply the same to Android and the other platforms.
  6. Example code may change freely; its current usage need not be kept.
- **Decisions (user, 2026-11-17)**: 3 files with 4 classes; the core wraps pull-to-refresh (one refresh API that uses
  CYLTableViewPlaceHolder inside, the example uses only that API); all platforms in one go.
- **Prompt (verbatim)**: "先将项目中所有core里面的search相关的组件进行merge 到最少的类。在iOS端重构core 核心代码，merge所有与search相关的文件夹文件进入CYLSearchBar文件夹， merge类似功能类似API进入合适的文件， ，merge其他core文件夹里的search相关api。，如果其他文件夹里的文件的API与它重复，那么仅仅保留一个的api。如果不重复仅仅api新增参数就能实现，那么找到文件夹里的合适文件，复制某一api并新增参数。并修改example的非core相关的刷新api。修改完成后同样的要求作用于android端与其他端。保证刷新接口聚合在CYLSearchBar组件内。要求CYLSearch  为唯一kernel，不能依赖其他search类kernel。collectview除外他不是search相关。example代码可以随便改，无须考虑example用法。"
- **Prompt (English)**: "First merge all search-related components in the project's core into the fewest classes. On
  iOS, refactor the core: merge all search-related folders and files into a CYLSearchBar folder, merge classes with
  similar features and APIs into suitable files, and merge the search-related APIs of other core folders. If an API
  in another folder duplicates one, keep only one. If it does not duplicate but can be done by adding a parameter,
  find the suitable file in the folder, copy that API and add the parameter. Also change the example's refresh APIs
  that are not core. When done, apply the same requirements to Android and the other platforms. Make sure the refresh
  interfaces are aggregated in the CYLSearchBar component. CYLSearch must be the only kernel and must not depend on
  other search kernels; the collection view is excluded, it is not search-related. Example code may change freely,
  regardless of its current usage."
- **Status** (2026-11-17): merged on iOS, Android, HarmonyOS, the mini program and React Native; Flutter is being
  moved onto the merged core (in progress), so the task stays `TODO`.

  | Part | State | Commits |
  | :--- | :--- | :--- |
  | Design | DONE: "Target design" below | `d2ed553` |
  | Generators and CI on `Sources/CYLSearchBar` | DONE | `f5f1775` |
  | Placeholder sub-dependency: CYLTableViewPlaceHolder `f488e2f` on every platform | DONE | `d01d290` |
  | iOS: `Sources/CYLSearchBar`, 3 files, 4 public classes; the example refreshes only through `CYLSearchView` | DONE | `40c22c6` |
  | Android: `android/merged/cylsearch`, 3 files; no `search-*` dependency; refresh from `:placeholder-refresh` | DONE | `28fdfc7`, `14fedf9` |
  | HarmonyOS: `harmonyos/cylsearch`, 3 files | DONE | `f6f5af8` |
  | Mini program: `cyl-search-bar`, `cyl-search`, `src/core/` 3 modules | DONE | `457a21d` |
  | Parity tables regenerated on the merged API, all 100 | DONE | `bf20104`, `21eca39` |
  | Documentation on the merged API (README, AGENTS.md, instructions, skills, docs) | DONE | this commit |
  | React Native (`CrossPlatform/react-native-cylsearch`): the components follow the classes on the native cores | DONE | `8c425de` |
  | Flutter (`CrossPlatform/flutter_cylsearch`): the widgets follow the classes on the native cores | DONE | `80c66ae`, `5126cb7` |
  | Flutter (`CrossPlatform/flutter_cylsearch`) | TODO: in progress | |

### Deviations by platform

What each platform did differently from the target design below.

- **iOS**: indices are `Int` with `NSNotFound` for none; `CYLSearchBarItem.itemView` / `itemViews` are typed
  `CYLTagButton` (CollectionViewClassifyMenu; the item view is a private subclass of it); `closeSearch(animated:completion:)` has no default values
  (`closeSearch()` and `closeSearch(animated:)` stay as the short forms); the default suggestion store is `internal`;
  `mode = .multiple` APIs do nothing in `.single`, the multiple mode animates with the bar's `animationDuration`
  (0.3 s) and is inset by `contentInsets`; no new localized strings.
- **Android**: `CYLSearchSuggestionCell`, `CYLLineBreakMode`, `CYLTextAutocapitalizationType`,
  `CYLTextAutocorrectionType`, `CYLSearchBarItemState` and `CYLSearchBarItemTextAttributes` stay public as stand-ins
  for UIKit types; `showSearch(activity | viewGroup, animated)`; `closeSearch(animated = true, completion = null)`
  replaces `closeSearch()` / `closeSearch(animated)`; `resultsDataSource` is a strong reference; the multi-search text
  callback is an overload, `searchBarViewTextDidChange(bar, text, index)`; `setRefreshHandler` needs the scroll view
  to have a parent; the results list has no `contentDescription`.
- **HarmonyOS**: the static refresh helpers are `beginRefreshingIn` / `endRefreshingIn` / `isRefreshingIn`;
  `resultsTableView` is the results list's `Scroller`, and other lists get pull-to-refresh inside
  `CYLSearchRefreshComponent`; `showSearchIn(context, animated)`; the drawing components `CYLSearchBarComponent` and
  `CYLSearchComponent` stay exported; no `newSearchButton` and no `autocapitalizationType`; the suggestion store
  through the static `CYLSearchResources.suggestionCache(...)`; CYLTableViewPlaceHolder's V1 `cylplaceholder`
  components are hosted inside V2 components; the multi-search text callback is `searchBarViewTextDidChangeAtIndex`.
- **Mini program**: the data source and the refresh handler are set by methods (`setResultsDataSource`,
  `setRefreshHandler`), next to the properties `results` and `refresherEnabled` and the event `bind:refresh`;
  `isRefreshing()` and `isSearchOpen()` are component methods; additions `inline`, `showsResultsForEmptyQuery` and
  `hidesSearchBarWhenScrolling`; enums are string-valued; the placeholder gallery lists CYLTableViewPlaceHolder's 35
  scenarios; `cyl-placeholder-miniprogram` is an optional peer dependency.
- **React Native**: components, not classes, on the native cores: `CYLSearchBarView` props `mode` (`'single'` |
  `'multiple'`, type `CYLSearchBarMode`), `searches`, `minimumTextLength` (default 3) and events
  `onCompleteSearch {text, index}`, `onRemoveSearch {index}`, `onSelectSearch {text, index}`,
  `onTextChange {text, index}` (index -1 in single mode); `CYLSearchView` props `results`, `showsResults` (defaults to
  whether `results` is given), `refreshEnabled`, `refreshing` (`true` calls `beginRefreshing`, `false`
  `endRefreshing`) and events `onSelectResult {result, index}`, `onRefresh` (only when the person pulls);
  `CYLTagListView` (CollectionViewClassifyMenu) as before.
- **Flutter**: widgets on the native cores: `CYLSearchView` gains `results` (`null` means suggestions only),
  `onSelectResult(result, index)`, `refreshEnabled`, `onRefresh` and a `controller`
  (`CYLSearchViewWidgetController`: `beginRefreshing()`, `endRefreshing()`, `isRefreshing()`, `reloadResults()`);
  `CYLSearchBarView` gains `mode` (`CYLSearchBarMode`), `searches`, `onTextChange(text, index)`,
  `onCompleteSearch(text, index)`, `onRemoveSearch(index)`, `onSelectSearch(text, index)` (multiple mode;
  `onTextChanged` stays for single mode) and a `controller` (`CYLSearchBarWidgetController`: `beginNewSearch`,
  `completeSearch`, `addSearch`, `selectSearch`, `removeSearch`, `searches()`, `selectedSearchIndex()`, -1 when none).
  The two controllers are Dart-only classes for the imperative calls of the native views. The iOS plugin imports
  CYLTableViewPlaceHolder for `CYLPlaceholderScenario` (the core does not re-export it).
- **Naming of the multi-search callbacks across platforms**: Android, HarmonyOS and the mini program use
  `searchBarViewDidCompleteSearch`, `searchBarViewDidSelectSearch` and `searchBarViewDidRemoveSearchAtIndex`; the
  text callback is an overload of `searchBarViewTextDidChange` on Android and `searchBarViewTextDidChangeAtIndex` on
  HarmonyOS and the mini program.

### TODO: not verified yet

- Nothing was compiled in this session: no Xcode, no Android SDK, no DevEco Studio, no WeChat DevTools (Linux).
- iOS CI on PR #11 is the first compile of `Sources/CYLSearchBar` and the example.
- The three `Podfile.lock` files still name the old commits (the CocoaPods CDN is unreachable here); CI's
  `pod install` resolves them again.
- iOS read CYLTableViewPlaceHolder from a cached copy; its API was not checked at `f488e2f`.
- HarmonyOS: mixing V1 `cylplaceholder` components into V2 components, and the `WeakMap` used by the refresh
  helpers, are untested on a device or emulator.
- Mini program: the default path of the component generics (no `cyl-placeholder-miniprogram` installed) is untested.
- Android: the timing of the refresh tests under Robolectric is unverified.
- React Native: the native code (iOS and Android bridges) was not compiled (no Xcode, no Android SDK); TypeScript
  type-checks and its 5 jest tests pass.
- Flutter: the native code (iOS and Android plugins) was not compiled; `flutter analyze` (3 existing deprecation
  notices) and `flutter test` (13 plugin tests, 3 example tests) pass.

## Target design

The single source of truth for every platform. Names are the iOS (Swift, with `@objc` Objective-C names) names;
the other platforms use the same names in their language's conventions, as their ports already do.

### Files and public classes (iOS: `Sources/CYLSearchBar/`, 3 files, 4 public classes)

| File | Public classes | Also public (not classes) | Private helpers (implementation only) |
| :--- | :--- | :--- | :--- |
| `CYLSearchBarView.swift` | `CYLSearchBarView`, `CYLSearchBarItem` | `CYLSearchBarViewDelegate`; enums `CYLSearchBarMode` (new), `CYLSearchBarItemStyle`, `CYLSearchBarStyle`, `CYLSearchBarNavigationIcon`, `CYLSearchBarIconPosition`, `CYLSearchBarExpansionAnimation` | the item view (was `CYLSearchBarItemView`), the multi-search content (was `CYLMultiSearchView`) |
| `CYLSearchView.swift` | `CYLSearchView` | `CYLSearchViewDelegate`, `CYLSearchViewDataSource` (new, was `CYLSearchResultsDataSource`); enum `CYLSearchSuggestionStyle` | the results list (was `CYLSearchResultsViewController`) |
| `CYLSearchResources.swift` | `CYLSearchResources` | `CYLSearchSuggestionCache` (protocol), enum `CYLSearchSuggestionCachePolicy` | the default cache store (was `CYLSearchSuggestionStore`) |

The podspec reads `Sources/CYLSearchBar/**/*.swift`; the module stays `CYLSearchViewController`. Removed public
types: `CYLMultiSearchView`, `CYLMultiSearchViewDelegate`, `CYLSearchBarItemView`, `CYLSearchController`,
`CYLSearchControllerDelegate`, `CYLSearchResultsViewController`, `CYLSearchResultsDataSource`,
`CYLSearchPlaceholderView` and its enums (`CYLSearchPlaceholderKind`, `CYLSearchPlaceholderStyle`,
`CYLSearchPlaceholderMessage`), `CYLSearchSuggestionStore`. The bundle `CYLSearchViewController.bundle` keeps all its
files (the other platforms import its images and strings).

### Old API → new API

Rule of the merge: an API that duplicates another is kept once (the kept one is named in the right column); an API
that differs only by a parameter is copied with the new parameter (default value where the language has them).

**Multi-search → `CYLSearchBarView` with `mode = .multiple`**

| Old (`CYLMultiSearchView`) | New (`CYLSearchBarView`) |
| :--- | :--- |
| the class | `mode: CYLSearchBarMode` (`.single` default, `.multiple`) |
| `delegate` (`CYLMultiSearchViewDelegate`) | `delegate` (`CYLSearchBarViewDelegate`) |
| `multiSearchView(_:textDidChange:at:)` | `searchBarView(_:textDidChange:at:)` (new, optional; `.multiple` only; `.single` keeps `searchBarView(_:textDidChange:)`) |
| `multiSearchView(_:didCompleteSearch:at:)` | `searchBarView(_:didCompleteSearch:at:)` (new, optional) |
| `multiSearchView(_:didRemoveItemAt:)` | `searchBarView(_:didRemoveSearchAt:)` (new, optional) |
| `multiSearchView(_:didSelectItem:at:)` | `searchBarView(_:didSelectSearch:at:)` (new, optional) |
| `searchTexts` | `searches: [String]` |
| `selectedIndex`, `noSelection` | `selectedSearchIndex` (`NSNotFound` / Android `-1` when none) |
| `isInSearchMode` | `isEditingNewSearch` |
| `searchButton` | `newSearchButton` |
| `search()` | `beginNewSearch()` |
| `completeSearch()` | `completeSearch()` |
| `addSearchText(_:)` | `addSearch(_:)` |
| `selectItem(at:)` | `selectSearch(at:)` |
| `removeItem(at:)` | `removeSearch(at:)` |
| `placeholder`, `font`, `textColor`, `placeholderColor`, `returnKeyType`, `keyboardType`, `autocapitalizationType` | the bar's own properties of the same name (duplicates; added to the bar where it lacks one) |
| `maximumTextLength`, `minimumTextLength` | same names on the bar (`minimumTextLength` applies to `completeSearch()`) |
| `indicatorColor`, `unselectedItemAlpha`, `searchFieldWidth`, `searchImage`, `removeImage`, `animationDuration` | `searchIndicatorColor`, `unselectedSearchAlpha`, `searchFieldWidth`, `newSearchImage`, `removeSearchImage`, `animationDuration` (bar) |

**Overlay and results list → `CYLSearchView`**

| Old | New (`CYLSearchView`) |
| :--- | :--- |
| `CYLSearchController(searchDataSource:)` | `CYLSearchView()` + `resultsDataSource` |
| `CYLSearchController.show(in: UIViewController)` | `showSearch(in: UIViewController, animated: Bool = true)` (copy of `showSearch(animated:)` with the controller; installs the view in the controller's view when needed) |
| `CYLSearchController.hide(_ completion:)` | `closeSearch(animated: Bool = true, completion: (() -> Void)? = nil)` (copy of `closeSearch(animated:)` with the completion) |
| `CYLSearchController.isPresented` | `isSearchOpen` |
| `CYLSearchControllerDelegate.searchControllerDidCancel(_:)` | `CYLSearchViewDelegate.searchViewDidClose(_:)` |
| `CYLSearchController.resultsViewController` | `resultsTableView` (public, read-only `UITableView`) |
| `CYLSearchResultsDataSource` | `CYLSearchViewDataSource`: `searchView(_:resultsForQuery:) -> [Any]`, `searchView(_:configureResultCell:withResult:)` |
| `searchResultsViewController(_:didSelectResult:)` | `CYLSearchViewDelegate.searchView(_:didSelectResult:)` (optional) |
| `searchDataSource` | `resultsDataSource` (weak) |
| `searchResults` | `searchResults: [Any]` (read-only) |
| `reloadSearchResults()`, `reloadResultsTableView()` | `reloadResults()` (one API: queries the data source for the current query and reloads `resultsTableView`) |
| `searchController` (`UISearchController`) | removed from the core; a navigation-item search is plain UIKit in the example |

Results behavior: when `resultsDataSource` is set and the query is not empty, `resultsTableView` shows the results
in the area below the bar (the suggestions are hidden); otherwise the suggestions behave as before. The empty-results
placeholder (`showsEmptyResultsPlaceholder`, `emptyResultsScenario`, `emptyResultsView`) also covers an empty result
list. The rule "focus alone changes nothing below the search bar" still holds.

**Refresh → `CYLSearchView` (the only refresh API; CYLTableViewPlaceHolder's pull-to-refresh inside)**

| API | What it does |
| :--- | :--- |
| `refreshHandler: (() -> Void)?` | Non-nil adds pull-to-refresh to `resultsTableView` (CYLTableViewPlaceHolder's normal header); nil removes it. |
| `beginRefreshing()`, `endRefreshing()`, `isRefreshing` | Start, stop and read the refresh of `resultsTableView`; `endRefreshing()` must be called on every completion path. |
| `static setRefreshHandler(_:for: UIScrollView)` | The same pull-to-refresh on another scroll view (copy of `refreshHandler` with the scroll view), e.g. the Issue #1317 page's table. |
| `static beginRefreshing(in:)`, `static endRefreshing(in:)`, `static isRefreshing(in:)` | The same calls for that scroll view. |

The example calls only these: no `CYLRefreshNormalHeader`, `cyl_header` or `endRefreshing` of CYLTableViewPlaceHolder
in example code. Handlers must not retain their controller strongly.

**Placeholder and cache**

| Old | New |
| :--- | :--- |
| `CYLSearchPlaceholderView` (+ kind, style, message enums) | removed from the core: CYLTableViewPlaceHolder already contains it as `CYLPlaceholderView` (`CYLPlaceholderStyle`: the same styles, `WifiOff`, `SignalWifiOff`, `CloudOff`…, and the same images), on iOS, Android, HarmonyOS (`cylplaceholder`) and the mini program (`cyl-placeholder`). The core shows it through `CYLSearchView.emptyResultsView` / `emptySuggestionsView`; apps and the example use `CYLPlaceholderView` directly |
| `CYLSearchSuggestionStore` | private default store; `CYLSearchView.suggestionCachePolicy` / `suggestionCacheName` create it, `suggestionCache` takes a custom `CYLSearchSuggestionCache` |

### CYLTableViewPlaceHolder: the placeholder sub-dependency (user, 2026-11-17)

- Prompt (verbatim): "fix placeholder duplicates our CYLSearchPlaceholderView. 将CYLSearchPlaceholderView作为子依赖库。处理所有平台的依赖，增加子依赖，与CollectionView 的子依赖项一致。并修改内置刷新方法，使用调用CYLSearchPlaceholderView的方法。该修改适用于所有平台的core代码。如有必要修改example调用演示"
- Prompt (English): "Fix: the placeholder duplicates our CYLSearchPlaceholderView. Make CYLSearchPlaceholderView a
  sub-dependency library. Handle the dependencies on every platform and add the sub-dependency, consistent with the
  CollectionView (CollectionViewClassifyMenu) sub-dependency. Change the built-in refresh methods to call
  CYLSearchPlaceholderView's methods. This applies to the core of every platform; change the example demos if needed."
- Reading: CYLTableViewPlaceHolder is the library that contains CYLSearchPlaceholderView (as `CYLPlaceholderView`) and the
  pull-to-refresh headers, so it is the placeholder sub-dependency. Like CollectionViewClassifyMenu, every platform pins
  the same commit, its newest on any branch: `f488e2fb0ca175f96daabf5814739832a2cfd1ce` (2026-11-17,
  `feat/android-refresh-port-followup`). Before: iOS, React Native and Flutter `c202b8c`, Android `6d8b264`, HarmonyOS
  `76762c6`, mini program `8ee7013`.
- Pins: `Podfile`, both CrossPlatform example Podfiles (`:git` + `:commit`), the podspec's `s.dependency
  'CYLTableViewPlaceHolder/Core'` (no animation engine in the core; the example Podfiles add `Lottie`,
  docs/animated-icon-component.md); `android/merged/gradle.properties` `cyl.placeholder.commit` (`pinnedCheckout`);
  `harmonyos/oh-package.json5` and the mini program `package.json` `cylTableViewPlaceHolderCommit`.
- The core's refresh API (above) calls CYLTableViewPlaceHolder's refresh header on every platform.

### The only search kernel

- iOS: the pod depends on CollectionViewClassifyMenu (tags, not search) and CYLTableViewPlaceHolder (placeholder and
  refresh, not search) only.
- Android: `cylsearch` drops its `api(project(":search-lapism"))`, `api(project(":search-materialsearchview"))` and
  `api(project(":search-multisearchview"))` (unused by its code). The sample modules that show those upstream
  libraries are example code and keep them.
- Every other platform: its search package depends on no other search library.

### Per platform

| Platform | Core | Files after the merge |
| :--- | :--- | :--- |
| iOS | `Sources/CYLSearchBar` | `CYLSearchBarView.swift`, `CYLSearchView.swift`, `CYLSearchResources.swift` |
| Android | `android/merged/cylsearch` (`com.cyl.search`) | `CYLSearchBarView.kt`, `CYLSearchView.kt`, `CYLSearchResources.kt` |
| React Native | `CrossPlatform/react-native-cylsearch` (`src/`, `ios/`, `android/`) | done; components follow the classes: a search bar (with `mode`), a search view (with results and refresh), the tag list (CollectionViewClassifyMenu, unchanged) |
| Flutter | `CrossPlatform/flutter_cylsearch` (`lib/`, `ios/`, `android/`) | done; the same split as React Native: a search bar widget (with `mode`), a search view widget (with results and refresh), the tag list widget (CollectionViewClassifyMenu, unchanged) |
| HarmonyOS | `harmonyos/cylsearch` | `CYLSearchBarView.ets`, `CYLSearchView.ets`, `CYLSearchResources.ets` |
| Mini program | `CrossPlatform/wechat-miniprogram-cylsearch` (`src/`) | components `cyl-search-bar` (with `mode`) and `cyl-search` (with results and refresh); core modules `src/core/CYLSearchBarView.js`, `CYLSearchView.js`, `CYLSearchResources.js` |
