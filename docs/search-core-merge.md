# Search Core Merge (CYLSearchBar)

## TODO (2026-11-17): merge the search core into the fewest classes, on every platform

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
- **Status**: logged; design next (section "Target design").

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
| `CYLSearchPlaceholderView` (+ kind, style, message enums) | removed: duplicate of CYLTableViewPlaceHolder's placeholder, already exposed by `CYLSearchView.emptyResultsView` / `emptySuggestionsView` and their scenarios |
| `CYLSearchSuggestionStore` | private default store; `CYLSearchView.suggestionCachePolicy` / `suggestionCacheName` create it, `suggestionCache` takes a custom `CYLSearchSuggestionCache` |

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
| React Native | `CrossPlatform/react-native-cylsearch` (`src/`, `ios/`, `android/`) | components follow the classes: a search bar (with `mode`), a search view (with results and refresh), the tag list (CollectionViewClassifyMenu, unchanged) |
| Flutter | `CrossPlatform/flutter_cylsearch` (`lib/`, `ios/`, `android/`) | same as React Native |
| HarmonyOS | `harmonyos/cylsearch` | `CYLSearchBarView.ets`, `CYLSearchView.ets`, `CYLSearchResources.ets` |
| Mini program | `CrossPlatform/wechat-miniprogram-cylsearch` packages | a search bar component (with `mode`), a search view component (with results and refresh), the resources module |
