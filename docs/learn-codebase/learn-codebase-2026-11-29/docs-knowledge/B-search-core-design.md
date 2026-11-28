> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Written by a subagent: its claims and contradictions were NOT re-checked (only items marked S in 02-findings.md were). What the source documents report as done or passing is their claim.

# B. Design documents of the search core (knowledge digest)

Digest date: 2026-11-29. Source: working tree of CYLSearchViewController, files under `docs/`. Everything below is what the documents CLAIM
(builds, tests, scores, screenshots were NOT run or verified for this digest) unless a line says "checked in code".
Citations are `file:line` (all files in `docs/`). Short names: NSS = no-system-searchbar.md, MERGE = search-core-merge.md,
CMP = search-api-comparison.md, SBV = search-bar-view.md, QMUI = qmui-search-controller.md.

## 0. Timeline of the design (read this first)

| Date | Event | Source |
|:--|:--|:--|
| 2026-11-12 | Feature parity with 5 Android search libraries (Objective-C core), Swift ports of their examples; later the "Default" sample puts the bar inside the navigation bar | CMP:7, CMP:292 |
| 2026-11-12..14 | CYLSearchBarView built; large-text/VoiceOver behavior; "iPhone Duo" 10 pt overlap fix; FlatDesign-style item API (58/58) | SBV:19-109, SBV:111-273 |
| 2026-11-17 | Core merge: iOS Sources/CYLSearchBar, 3 files, 4 public classes; all platforms; CYLSearchController removed | MERGE:3, MERGE:152-165 |
| 2026-11-19..21 | Verification statuses of the merge updated (Windows and macOS sessions) | MERGE:102-145 |
| 2026-11-21..23 (mostly 11-22; design 11-21, last fixes 11-23) | QMUI port: new CYLSearchBar (UISearchBar subclass), CYLSearchController (UISearchController wrapper), CYLSearchTableViewController | CMP:338-344, SBV:275-280 |
| 2026-11-26 | Owner order: no system search bar on any platform; CYLSearchBar removed, CYLSearchController re-backed by CYLSearchBarView (newest direction) | NSS:3-39 |

## 1. No system search bar (NSS; newest, 2026-11-26)

- Owner order (tags `core`, `example-demos`; skill `cyl-search-field`): no platform may use a system search bar. For the iOS QMUI port the owner chose "Rebuild on CYLSearchBarView". Task log: `docs/task-log.md` (NSS:3-4).
- ORIGINAL design (NSS:6-12): CYLSearchController becomes a thin view-controller facade over one CYLSearchView (which already owns CYLSearchBarView, launch/suggestions view, results table, scrim, highlighting, empty states, refresh, swipe-to-dismiss); contents VC as child; delegate (results update + results table data source/delegate) adapted to the view's table; no UISearchController / UISearchBar / UISearchTextField; CYLSearchTableViewController keeps its API.
- SHIPPED design supersedes that (NSS:29-39, "Status 2026-11-26", says iOS steps 1-7 done and grep clean):
  - CYLSearchController does NOT sit on CYLSearchView. It hosts CYLSearchBarView (`searchBar`) and, while active, one page below the field (dimming view, launch view, results VC's view, empty view) over the navigation controller's view (or the window). Results table is the caller's; `searchResultsDelegate` keeps the full UITableViewDataSource/Delegate.
  - Kept, re-backed: `searchResultsController` (now `let`), `searchBar` (type CYLSearchBarView), `searchBarMaxY`, `alwaysShowsSearchResultsController`, `supportsSwipeToDismissSearch` (page slides; no window snapshot).
  - Removed (breaking): `CYLSearchBar`, `searchController`, `hidesNavigationBarDuringPresentation`, `forwardsAppearanceFromContentsViewController`, `prefersStatusBarHiddenProvider`, `preferredStatusBarStyleProvider`, UISearchResultsUpdating/UISearchControllerDelegate conformance, CYLSearchBarAppearance's system-bar probe.
  - Text assigned in code (`searchBar.text = ...`) updates results through internal `CYLSearchBarView.textAssignedHandler`.

### 1.1 Planned API map (NSS:16-25; the "Fate" column is the plan; where NSS:29-39 differs, NSS:29-39 wins)

| Member(s) | Planned fate | Backed by |
|:--|:--|:--|
| `CYLSearchBar` | removed, breaking; deliberately NO `typealias CYLSearchBar = CYLSearchBarView` (it would hide the change) | CYLSearchBarView |
| appearanceStyle, placeholderColor, textColor, font, textFieldMargins(Provider), centersPlaceholder, cancelButtonFont, cancelButtonMarginsProvider, alwaysEnablesCancelButton, backgroundView, leading/trailingAccessoryView + margins + setShows…Animated | kept | same names on CYLSearchBarView |
| usedAsTableHeaderView, segmentedControl, cancelButton, barTintColor, setBackgroundImage(_:for:), searchController back reference | removed or replaced | fieldBackgroundImage, fieldBackgroundColor |
| CYLSearchController(contentsViewController:resultsViewController:) + 2 convenience inits | kept | facade; resultsViewController must be a table view controller |
| searchResultsDelegate, tableView, searchBar, highlightsResultMatches, resultMatchHighlightColor, launchView, showsSuggestionsLaunchView, suggestions, dimmingColor, isActive, setActive(_:animated:), showSearch, closeSearch, searchOpen, supportsSwipeToDismissSearch, swipeGestureRecognizer, isEmptyViewShowing, showEmptyView(...), hideEmptyView, noResultsText, historyStore, historyDidChangeNotification | kept | planned: CYLSearchView (resultsTableView, scrimColor, suggestions, searchOpen) |
| searchController (UISearchController), searchResultsController, hidesNavigationBarDuringPresentation, alwaysShowsSearchResultsController, forwardsAppearanceFromContentsViewController, searchBarMaxY, prefersStatusBarHiddenProvider, preferredStatusBarStyleProvider, UIKit conformances | planned removed (shipped: searchResultsController, alwaysShowsSearchResultsController, searchBarMaxY were KEPT, NSS:34-35) | none |
| installSearchBar(asHeaderOf:), install(in: UINavigationItem), snapsHeaderSearchBar | kept | header CYLSearchBarView / embedInNavigationBar(of:), CYLSearchView.setSnapsHeader |
| CYLSearchTableViewController (showsSearchBar, searchController, searchBar, hidesSearchBarWhenEmptyViewShowing, hidesSearchBarInitially, isEmptyViewShowing, setUpSearchBar, searchController(_:updateResultsFor:), empty-view API) | kept; searchBar becomes CYLSearchBarView? | facade |

### 1.2 Work list (NSS:41-49; items 1-5 still say "TODO" although NSS:29 says steps 1-7 done)
1. Facade CYLSearchController + CYLSearchTableViewController. 2. Remove CYLSearchBar and UISearchBar/UISearchController paths of CYLSearchHeaderSnapper, CYLSearchPresentationState, CYLSearchBarAppearance. 3. Demos (Search controller, Navigation item, Collection view, Original, Lapis, Reveal, Yechaoa, search bar styles) use the core field. 4. `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.mm` (UISearchBar). 5. Rewrite or delete (reason in task log) UIKit-only test assertions (obscuresBackgroundDuringPresentation, automaticallyShowsCancelButton, searchResultsController is UITableViewController, swipe on system controller); update CYLSearchAPIFenceTests and CYLSearchCoreObjectiveCSmokeTests.m. 6. Mark QMUI rows E1-E22 kept/replaced/dropped. 7. Done when `grep -rnE "UISearchBar|UISearchController|UISearchTextField" Sources CYLSearchExample CrossPlatform/*/ios` has no hit outside Pods and vendor.

## 2. Core merge (MERGE; DONE 2026-11-17)

### 2.1 Requirements and user decisions
- Starting state (MERGE:5-14): branch feat/harmonyos-parity, PR #11. iOS core had 9 files / 15 public types with overlapping roles (3 search screens, 2 bars, items, placeholder, resources, suggestion store). Example called CYLTableViewPlaceHolder refresh directly. Android declared search-lapism / search-materialsearchview / search-multisearchview as `api` deps and used none.
- Requirements (MERGE:15-25): fewest classes, one iOS folder CYLSearchBar; duplicate APIs kept once, APIs differing by a parameter become one API with the parameter; refresh interfaces live in the core and example uses only them; CYLSearch is the only search kernel (CollectionViewClassifyMenu excluded, not search); apply to all platforms; example code may change freely.
- User decisions (MERGE:26-27): 3 files with 4 classes; core wraps pull-to-refresh (CYLTableViewPlaceHolder inside); all platforms in one go.
- Status claim (MERGE:38-53): merged on every platform. Commits: design d2ed553; generators/CI f5f1775; placeholder pin f488e2f d01d290; iOS 40c22c6; Android 28fdfc7, 14fedf9; HarmonyOS f6f5af8; mini program 457a21d; parity tables bf20104, 21eca39 (all 100); RN 8c425de; Flutter 80c66ae, 5126cb7 (the stale "Flutter in progress" row was removed, corrected 2026-11-19).

### 2.2 Target design: files and classes (MERGE:149-165; "single source of truth for every platform", iOS names)

| iOS file in Sources/CYLSearchBar | Public classes | Other public | Private helpers |
|:--|:--|:--|:--|
| CYLSearchBarView.swift | CYLSearchBarView, CYLSearchBarItem | CYLSearchBarViewDelegate; CYLSearchBarMode (new), CYLSearchBarItemStyle, CYLSearchBarStyle, CYLSearchBarNavigationIcon, CYLSearchBarIconPosition, CYLSearchBarExpansionAnimation | item view, multi-search content |
| CYLSearchView.swift | CYLSearchView | CYLSearchViewDelegate, CYLSearchViewDataSource; CYLSearchSuggestionStyle | results list |
| CYLSearchResources.swift | CYLSearchResources | CYLSearchSuggestionCache, CYLSearchSuggestionCachePolicy | default cache store |

- Podspec reads `Sources/CYLSearchBar/**/*.swift`; module name stays CYLSearchViewController; bundle CYLSearchViewController.bundle keeps all files because other platforms import its images/strings (MERGE:160-165).
- Removed public types (MERGE:160-164): CYLMultiSearchView(+Delegate), CYLSearchBarItemView, CYLSearchController(+Delegate) (name later reused by the QMUI port), CYLSearchResultsViewController, CYLSearchResultsDataSource, CYLSearchPlaceholderView (+Kind/Style/Message), CYLSearchSuggestionStore.

### 2.3 Old to new API (MERGE:172-193): multi-search -> CYLSearchBarView with mode = .multiple

| CYLMultiSearchView | CYLSearchBarView |
|:--|:--|
| class | mode: CYLSearchBarMode (.single default / .multiple) |
| delegate (CYLMultiSearchViewDelegate) | delegate (CYLSearchBarViewDelegate) |
| multiSearchView(_:textDidChange:at:) | searchBarView(_:textDidChange:at:) optional, .multiple only; .single keeps searchBarView(_:textDidChange:) |
| didCompleteSearch / didRemoveItemAt / didSelectItem | searchBarView(_:didCompleteSearch:at:) / (_:didRemoveSearchAt:) / (_:didSelectSearch:at:), all optional |
| searchTexts | searches: [String] |
| selectedIndex, noSelection | selectedSearchIndex (NSNotFound; Android -1) |
| isInSearchMode / searchButton / search() | isEditingNewSearch / newSearchButton / beginNewSearch() |
| completeSearch() / addSearchText / selectItem(at:) / removeItem(at:) | completeSearch() / addSearch(_:) / selectSearch(at:) / removeSearch(at:) |
| placeholder, font, textColor, placeholderColor, returnKeyType, keyboardType, autocapitalizationType | the bar's properties of same name |
| maximumTextLength, minimumTextLength | same; minimumTextLength applies to completeSearch() |
| indicatorColor, unselectedItemAlpha, searchFieldWidth, searchImage, removeImage, animationDuration | searchIndicatorColor, unselectedSearchAlpha, searchFieldWidth, newSearchImage, removeSearchImage, animationDuration |

### 2.4 Overlay and results list -> CYLSearchView (MERGE:197-215)

| Old | New |
|:--|:--|
| CYLSearchController(searchDataSource:) | CYLSearchView() + resultsDataSource (weak) |
| show(in:) | showSearch(in:animated: = true) (installs the view in the VC's view if needed) |
| hide(_:) | closeSearch(animated: = true, completion: = nil) |
| isPresented | isSearchOpen |
| searchControllerDidCancel | CYLSearchViewDelegate.searchViewDidClose(_:) |
| resultsViewController | resultsTableView (public read-only UITableView) |
| CYLSearchResultsDataSource | CYLSearchViewDataSource: searchView(_:resultsForQuery:) -> [Any]; searchView(_:configureResultCell:withResult:) |
| didSelectResult | searchView(_:didSelectResult:) optional |
| searchDataSource / searchResults | resultsDataSource / searchResults: [Any] read-only |
| reloadSearchResults(), reloadResultsTableView() | one reloadResults() (re-queries data source for current query, reloads table) |
| searchController (UISearchController) | removed from core; navigation-item search was then plain UIKit in the example |

Behavior contract (MERGE:212-215): with resultsDataSource set and a non-empty query, resultsTableView shows results below the bar and suggestions hide; otherwise suggestions behave as before. Empty placeholder (showsEmptyResultsPlaceholder, emptyResultsScenario, emptyResultsView) also covers an empty result list. "Focus alone changes nothing below the search bar" still holds.

### 2.5 Refresh API: only refresh API, CYLTableViewPlaceHolder inside (MERGE:217-227)
- `refreshHandler`: non-nil adds pull-to-refresh (PlaceHolder normal header) to resultsTableView; nil removes it.
- `beginRefreshing()`, `endRefreshing()`, `isRefreshing`; endRefreshing() MUST be called on every completion path.
- `static setRefreshHandler(_:for: UIScrollView)` plus static `beginRefreshing(in:)`, `endRefreshing(in:)`, `isRefreshing(in:)` for other scroll views (e.g. the Issue #1317 table).
- Example must not call CYLRefreshNormalHeader / cyl_header / PlaceHolder endRefreshing directly. Handlers must not strongly retain their controller.

### 2.6 Placeholder, cache, dependencies (MERGE:229-262)
- CYLSearchPlaceholderView removed because CYLTableViewPlaceHolder already has the same thing as CYLPlaceholderView (CYLPlaceholderStyle, same styles and images) on iOS, Android, HarmonyOS (cylplaceholder) and mini program (cyl-placeholder). Core shows it via emptyResultsView / emptySuggestionsView.
- Suggestion store is private; suggestionCachePolicy / suggestionCacheName create it; suggestionCache takes a custom CYLSearchSuggestionCache.
- PlaceHolder is the placeholder sub-dependency, pinned like ClassifyMenu to one commit on every platform; AS OF 2026-11-17: f488e2fb0ca175f96daabf5814739832a2cfd1ce (branch feat/android-refresh-port-followup). Previous pins: iOS/RN/Flutter c202b8c, Android 6d8b264, HarmonyOS 76762c6, mini program 8ee7013. Later pins quoted: e984868 and c84fce9 (MERGE:104-131), so f488e2f is history.
- Pin locations: Podfile, both CrossPlatform example Podfiles (:git + :commit), podspec s.dependency 'CYLTableViewPlaceHolder/Core' (no animation engine in core; example Podfiles add Lottie, docs/animated-icon-component.md); android/merged/gradle.properties cyl.placeholder.commit (pinnedCheckout); harmonyos/oh-package.json5 and mini program package.json cylTableViewPlaceHolderCommit.
- Only-kernel rule: iOS depends only on CollectionViewClassifyMenu (tags) and CYLTableViewPlaceHolder; Android cylsearch dropped the three api(project(":search-*")) (sample modules showing upstream libs keep them); other platforms depend on no other search library.

### 2.7 Per-platform layout (MERGE:263-272)
| Platform | Core | Files/components |
|:--|:--|:--|
| iOS | Sources/CYLSearchBar | CYLSearchBarView.swift, CYLSearchView.swift, CYLSearchResources.swift |
| Android | android/merged/cylsearch (com.cyl.search) | same three .kt |
| React Native | CrossPlatform/react-native-cylsearch (src, ios, android) | search bar (with mode), search view (results+refresh), tag list |
| Flutter | CrossPlatform/flutter_cylsearch (lib, ios, android) | same split as widgets |
| HarmonyOS | harmonyos/cylsearch | three .ets |
| Mini program | CrossPlatform/wechat-miniprogram-cylsearch (src) | cyl-search-bar (mode), cyl-search (results+refresh); src/core/CYLSearchBarView.js, CYLSearchView.js, CYLSearchResources.js |

### 2.8 Platform deviations from the target design (MERGE:55-100)
- iOS: indices are Int with NSNotFound; itemView/itemViews typed CYLTagButton (item view is a private subclass); closeSearch(animated:completion:) has no defaults (closeSearch(), closeSearch(animated:) stay); default suggestion store internal; .multiple APIs do nothing in .single; multiple mode animates with animationDuration (0.3 s), inset by contentInsets; no new localized strings.
- Android: CYLSearchSuggestionCell, CYLLineBreakMode, CYLTextAutocapitalizationType, CYLTextAutocorrectionType, CYLSearchBarItemState, CYLSearchBarItemTextAttributes stay public (UIKit stand-ins); showSearch(activity|viewGroup, animated); closeSearch(animated = true, completion = null); resultsDataSource is STRONG (iOS weak); multi text callback is an overload searchBarViewTextDidChange(bar, text, index); setRefreshHandler needs the scroll view to have a parent; results list has no contentDescription.
- HarmonyOS: static helpers beginRefreshingIn/endRefreshingIn/isRefreshingIn; resultsTableView is the results list Scroller; other lists get refresh inside CYLSearchRefreshComponent; showSearchIn(context, animated); CYLSearchBarComponent and CYLSearchComponent exported; no newSearchButton, no autocapitalizationType; store via static CYLSearchResources.suggestionCache(...); PlaceHolder V1 cylplaceholder components hosted inside V2; callback searchBarViewTextDidChangeAtIndex.
- Mini program: setResultsDataSource, setRefreshHandler methods, plus results and refresherEnabled properties and bind:refresh; isRefreshing()/isSearchOpen() are component methods; adds inline, showsResultsForEmptyQuery, hidesSearchBarWhenScrolling; enums string-valued; placeholder gallery lists 35 PlaceHolder scenarios.
- React Native: components on the native cores. CYLSearchBarView props mode ('single'|'multiple'), searches, minimumTextLength (default 3); events onCompleteSearch {text,index}, onRemoveSearch {index}, onSelectSearch {text,index}, onTextChange {text,index} (index -1 in single). CYLSearchView props results, showsResults (defaults to whether results given), refreshEnabled, refreshing (true begins, false ends); events onSelectResult {result,index}, onRefresh (user pull only); CYLTagListView unchanged.
- Flutter: CYLSearchView gains results (null = suggestions only), onSelectResult(result,index), refreshEnabled, onRefresh, controller CYLSearchViewWidgetController (beginRefreshing, endRefreshing, isRefreshing, reloadResults). CYLSearchBarView gains mode, searches, onTextChange(text,index), onCompleteSearch, onRemoveSearch(index), onSelectSearch, controller CYLSearchBarWidgetController (beginNewSearch, completeSearch, addSearch, selectSearch, removeSearch, searches(), selectedSearchIndex() -1 when none); onTextChanged stays for single mode. Controllers are Dart-only. iOS plugin imports CYLTableViewPlaceHolder for CYLPlaceholderScenario (core does not re-export).
- Callback naming: Android/HarmonyOS/mini program use searchBarViewDidCompleteSearch, searchBarViewDidSelectSearch, searchBarViewDidRemoveSearchAtIndex (MERGE:97-100).

### 2.9 Verification claims (dated; MERGE:102-145)
- 2026-11-19 status: iOS 35 tests pass at pins CollectionViewClassifyMenu 3af1b7cd, PlaceHolder e984868, CYLTabBarController 5744917d; CI for 37c96d3 and 80a9463 green; Windows session reports Android :cylsearch:testDebugUnitTest and :app:assembleDebug pass, HarmonyOS ohosTest 29/29 (Mate 70 Pro emulator), mini program npm test 52/52; RN and Flutter iOS and Android build.
- The merge session itself compiled nothing (Linux; MERGE:13-14, 125); first compile was iOS CI run 44060850353 (2026-11-17, green).
- Mini program REQUIRES cyl-placeholder-miniprogram: without it DevTools fails "component not found in the path: .../cyl-placeholder-miniprogram/cyl-refresh/index" (checked 2026-11-19, DevTools 2.02.2609250). It stays an optional peer in package.json only so npm does not fetch it (not on the registry); README now says required.
- HarmonyOS pull-to-refresh driven 2026-11-21 (CYLSearchView.endRefreshingIn found its model in a WeakMap), commit 90b3dcf. The same paragraph also keeps the older note that the emulator "does not start today" ("can not read uuid file" without -imageRoot; "No enough space to start Emulator" at 3.3 GB free) (MERGE:115-121).

## 3. API parity with five Android libraries (CMP; 2026-11-12, paths later rewritten to the merged core)

- Task (CMP:9-59): superset of lapism/search (2d55614), MiguelCatalan/MaterialSearchView (53e163c), yechaoa/MaterialDesign (2d6ac57), android-cjj/MaterialSearchView (298db81, sample app only), iammert/MultiSearchView (b37f248). Score = matched/all x 100 (CMP:73). Scores before (estimate) -> now: 41, 22, 58, 33, 0 -> all 100 (CMP:259-267). Core first: example passes data/style and handles taps.
- Branch feat/search-api-parity from master 55022ba, PR #7. Claim: 19/19 tests, Xcode 27.2, iPhone 17 sim iOS 26.1. Tests named: testSearchBarViewParityOptions, testSearchViewSuggestionsOpenAndClose, testMultiSearchViewFlow, testSwiftPortsOfOtherLibrariesLoad. Bugs fixed: two magnifiers in lapism bar; cjj button not centered (new iconPosition); gray suggestion icons on colored theme (new suggestionImageTintColor); yechaoa field losing focus on open. Not verified: speech recognition in Voice sample (needs mic; otherwise shows "Speech recognition is not available." by design).
- Mapping convention: Android XML attributes -> iOS properties (code or IB) (CMP:71). Selectors are written in ObjC form.
- Screenshots of the ports: commit 63825b0, 2026-11-12, assets/port-*.png (CMP:269-290).

### 3.1 lapism/search (CMP:79-123)
| lapism | ours |
|:--|:--|
| MaterialSearchBar(context, attrs) | CYLSearchBarView initWithFrame:/initWithCoder: |
| getToolbar() | fieldView |
| setText / setHint | text / placeholder |
| foregroundColor, strokeWidth, strokeColor, radius | fieldBackgroundColor, fieldBorderWidth, fieldBorderColor, fieldCornerRadius (negative = capsule) |
| navigationIconCompat NONE/ARROW/SEARCH | navigationIcon None/Arrow/Search |
| navigation icon, contentDescription, click, elevation, background | navigationImage, navigationAccessibilityLabel, searchBarViewNavigationButtonClicked: + navigationHandler, navigationShadowOpacity, navigationBackgroundColor |
| bar onClick opens search view | searchBarViewShouldBeginEditing: returns NO + searchBarViewDidTapWhileNotEditable: |
| ScrollingViewBehavior | host navigationItem.hidesSearchBarWhenScrolling (UIKit) |
| search_margins* | contentInsets |
| MaterialSearchView ctor / addView | CYLSearchView / contentView |
| clearIcon, imeOptions, inputType | searchBarView.clearImage, returnKeyType, keyboardType+autocapitalizationType+autocorrectionType |
| textClearOnBackPressed / OnClearFocus | clearsTextOnCancel / clearsTextOnEndEditing |
| getTextQuery / setTextQuery(q, submit) | query / setQuery:submit: |
| typeface, hint, hintColor, textColor | searchBarView.font, placeholder, placeholderColor, textColor |
| dividerColor / dividerResource / scrimColor / background | dividerColor / dividerView / scrimColor / backgroundColor |
| focus listener, onQueryTextChange, onQueryTextSubmit | searchView:didChangeFocus:, searchView:textDidChange:, searchView:didSubmitText: |
| show/hideKeyboard; requestFocus/clearFocus | showKeyboard/hideKeyboard; showSearch/closeSearch |
| save/restore instance state | encode/decodeRestorableStateWithCoder: (bar and search view) |
| MaterialSearchToolbar setTitle/Subtitle/Elevation (upstream no-ops) | not needed |
| toolbar a11y | textField.accessibilityLabel "Search", text as value |

### 3.2 MiguelCatalan/MaterialSearchView (CMP:133-172)
| Miguel | ours |
|:--|:--|
| setMenuItem | attachToBarButtonItem: |
| showSearch(animate) / closeSearch(animate) / isSearchOpen / setAnimationDuration | showSearchAnimated: / closeSearchAnimated: / isSearchOpen / animationDuration |
| onQueryTextSubmit (true = handled) | searchView:didSubmitText: (YES = handled, STAYS OPEN) |
| onQueryTextChange; shown/closed | searchView:textDidChange:; searchViewDidShow:/DidClose: |
| setQuery; setSuggestions; show/dismissSuggestions | setQuery:submit:; suggestions; showSuggestions/dismissSuggestions |
| setAdapter | suggestionCellConfiguration, suggestionFilter, suggestionsTableView |
| item click / setSubmitOnClick | searchView:didSelectSuggestion:atIndex: / submitsOnSuggestionSelection |
| suggestion icon/background/ellipsize | suggestionImage(+TintColor), suggestionBackgroundColor, suggestionLineBreakMode |
| voice search/icon/result | searchBarView.showsVoiceButton, voiceImage, searchViewVoiceButtonClicked: (host starts SFSpeechRecognizer) then setQuery:submit: |
| close/back icon, colors, hint, inputType(textPassword), cursor, keyboard | searchBarView.clearImage, navigationImage, textColor, placeholderColor, placeholder, keyboardType+secureTextEntry, cursorColor, show/hideKeyboard |
| SearchAdapter.getFilter / getCount,getItem,getItemId / onFilterComplete | suggestionFilter (default case- and diacritic-insensitive contains) / filteredSuggestions + index / filteredSuggestions.count |

### 3.3 yechaoa (androidx SearchView) (CMP:181-194)
actionViewClass menu item -> bar as navigationItem.titleView or CYLSearchView+attachToBarButtonItem:; setIconifiedByDefault -> iconifiedByDefault; isIconified -> iconified, setIconified:animated:; isSubmitButtonEnabled -> showsSubmitButton, submitButton, submitImage; imeOptions -> returnKeyType; focus -> showKeyboard; queryHint -> placeholder; submit -> searchBarViewSearchButtonClicked: with searchBarView:shouldSubmitText:; change -> searchBarView:textDidChange:; empty text -> textDidChange with "" + showsEmptyResultsPlaceholder.

### 3.4 android-cjj sample (CMP:203-217)
FAB -> iconButton while iconified; centered -> iconPosition Center; circular reveal -> expansionAnimation CircularReveal; reverse -> setIconified:YES animated:YES; duration -> animationDuration; interpolator -> ease-in-out; magnifier translation -> icon fades into searchIconView; card color/radius -> fieldBackgroundColor/fieldCornerRadius; hint/textColor -> placeholder/textColor; singleLine -> UITextField; open state -> iconified, searchBarView:didChangeIconified:.

### 3.5 iammert/MultiSearchView (CMP:225-247)
listener -> delegate; onTextChanged/onSearchComplete/onSearchItemRemoved/onItemSelected -> textDidChange:atIndex:/didCompleteSearch:atIndex:/didRemoveSearchAtIndex:/didSelectSearch:atIndex:; search() -> beginNewSearch; completeSearch (drops searches shorter than 3 chars) -> completeSearch + minimumTextLength 3; isInSearchMode -> isEditingNewSearch; icons -> newSearchButton, newSearchImage, removeSearchImage, removeSearchAtIndex:; indicator -> searchIndicatorColor; unselected half opacity -> unselectedSearchAlpha 0.5; searchTextStyle attrs -> placeholder, font, textColor, placeholderColor, maximumTextLength, returnKeyType, keyboardType/autocapitalizationType; msv_size_* -> searchFieldWidth.

Beyond all five (CMP:251-257): results via resultsDataSource, refresh API, PlaceHolder empty states, suggestion cache with policies, trailing/leading views, localized Cancel, Dynamic Type growing field, large content viewer, VoiceOver labels, 4 languages, searchBarView:shouldSubmitText:.

### 3.6 "Default" sample: whole bar inside the navigation bar (CMP:292-336; DONE 2026-11-12, e358ebd)
Opening the search hides the navigation bar and the search view starts at the safe-area top, so the bar row replaces title and bar buttons; closing (back arrow, submit, Cancel) or leaving the page restores the navigation bar; the five other MaterialSearchView samples share the layout. Android does the same with the sample toolbar (CYLMaterialSearchSampleFragment). The bar still covers no view. Classes: CYLMaterialSearchSampleViewController (sample .standard). Claim 19/19 on iPhone 17.

## 4. CYLSearchBarView (SBV)

### 4.1 Scope and API (SBV:5-37)
- Custom UIView field: rounded field, magnifier, text, clear button, host views inside the field after text (camera, "Search"), a leading view, optional localized Cancel. mode .single (default) / .multiple (searches, selectedSearchIndex, beginNewSearch, completeSearch, addSearch, selectSearch, removeSearch). CYLSearchView hosts it. One of the four public classes; used by ClassifyMenu examples for every search box.
- Appearance API: text, placeholder, font, colors; field height, insets, corner radius (negative = capsule), border, shadow, magnifier. Delegate: begin/end editing, text changes, Search key, Cancel. search.cancel and search.field localized in en, zh-Hans, zh-Hant, ja.
- CONSTRAINT (SBV:73-81): the bar does not manage results; host connects searchBarView:textDidChange: to a CYLSearchView or own list. "It is unreleased, so the API has no compatibility promise yet."

### 4.2 Accessibility and large-text contract (SBV:28-43)
- Field is read as "Search" even after the placeholder disappears; magnifier decorative; default font follows Dynamic Type (custom fonts: host passes a UIFontMetrics font); field grows past fieldHeight and bar remeasures on text-size change.
- At largest sizes text keeps >= 40% of bar width; Cancel title shrinks (down to half size, at most 30% of bar) and trailing accessories scale as a whole (down to a quarter) BEFORE the text field shrinks; VoiceOver and large content viewer read the whole Cancel title.
- Gotcha (2026-11-12): UITextField's own placeholder shrank to 1/4 size when it did not fit (53 pt text, 14 pt placeholder). The bar draws `placeholderLabel` at text size with ellipsis; the text field keeps a clear-colored placeholder for VoiceOver.
- Demo: "Search bar" row (demo.searchBar) in CYLSearchDemoMenuViewController; launch arg -CYLDemoRow 2. Tests: testSearchBarViewLayoutStyleAndEvents, testSearchBarViewSupportsVoiceOverAndDynamicType, testSearchBarDemoRow; 15/15 claim (iPhone 17 Pro, iOS 26.1). No device VoiceOver session recorded (SBV:82-84).

### 4.3 "iPhone Duo" overlap (SBV:86-109; DONE 2026-11-14)
- Symptom: testSearchBarNeverCoversTheViewControllersView and testSearchBarsCoverNoView failed on the "iPhone Duo" simulator: Issue #1317 results view y=112 while nav bar + stacked search bar ends at 121.5 (bar frame {{0,68},{402,54}}).
- Cause: UIKit lays the VC view out as if the stacked search bar were 44 pt though it is 54 pt there: 10 pt overlap not corrected later (iOS 26.3.1).
- Fix (core, in the then-classes CYLSearchResultsViewController and CYLSearchController): viewDidLayoutSubviews -> cylKeepViewBelowNavigationBar() moves view down and shortens by covered height; no-op where UIKit is right. scripts/unit-tests.sh now prefers "iPhone 17". A float-rounding test now allows 0.01 pt. Claim: Duo tests pass (6 assertions failed before), iPhone 17 26/26.
- Standing requirement: a search bar never covers a view, on every device (AGENTS.md "Search bar placement").

### 4.4 Items API modeled on CYLTabBarController FlatDesign tab bar (SBV:111-273; DONE 2026-11-14)
- Why: Flutter Discover bar lacked the border and spacing of the Android reference; each example assembled camera/divider/Search itself via trailingAccessoryViews so platforms differed. Requirement: fix in core, fixed style enum, field is permanent, other elements are appended items, one view component per element, items expose icon/action; parity table with TODO default until none left.
- Score history: 0/58, then 58/58 on 2026-11-14 (53 matched, 5 N/A: respectsVerticalStatusBarSafeArea, context, -hasPlusChildViewController, layoutCentered, lottieURL as listed at SBV:151-152). iOS<->Android alignment (android/merged/scripts/api-alignment.py) 394 rows 100/100.

| FlatDesign tab bar item API | Search bar item API (iOS) |
|:--|:--|
| CYLFlatDesignTabBarDelegate; tabBar:didSelectItem: | CYLSearchBarViewDelegate; searchBarView:didSelectItem: |
| CYLFlatDesignTabBar; delegate; items; tabBarItems | CYLSearchBarView; delegate; items; itemViews |
| addItemWithTitle:...index: | addItemWithStyle:title:image:index:handler:, addItem:, insertItem:atIndex:, removeItem:, removeAllItems |
| selectedItem / selectedIndex / tabBarButtons | selectedItem (isSelectable item that is on) / selectedIndex / itemViews (read only) |
| standardAppearance / tintColor / barTintColor / backgroundImage / shadowImage / useLayoutSafeAreaInsets | searchBarStyle (.plain/.bordered) / itemTintColor / fieldBackgroundColor / fieldBackgroundImage / fieldBorderColor, fieldBorderWidth, fieldShadowOpacity / contentInsets |
| respectsVerticalStatusBarSafeArea / context | N/A (host places bar) / N/A (one bar per view; itemAccessibilityIdentifier) |
| hasPlusButton / hasPlusChildViewController | hasItemOfStyle: / N/A (handler decides) |
| CYLFlatDesignTabBarItem | CYLSearchBarItem |
| initWithTitle:image: (+selectedImage, +index) | initWithTitle:image:, iconItemWithImage:title:handler:, textItemWithTitle:handler:, dividerItem, initWithTitle:image:selectedImage:, initWithStyle:title:image: |
| tabBarButton, enabled, index, title, image, selectedImage, childViewController | itemView, isEnabled, index (NSNotFound outside a bar), title, image, selectedImage, handler |
| badgeValue, badgeColor, owning controller | badgeValue (empty string = dot), badgeColor, searchBarView (weak) |
| titlePositionAdjustment, item standardAppearance | titlePositionAdjustment, style (.icon/.divider/.text) |
| title/badge text attribute setters and getters | same names (forState:) |
| badgeSize, badgeContentInset, badgePositionAdjustment, imagePositionAdjustment | badgeSize, badgeContentInsets, badgePositionAdjustment, imagePositionAdjustment |
| layoutCentered | N/A |
| backgroundColor, selectedBackgroundColor, imageInsets | backgroundColor, selectedBackgroundColor, contentInsets |
| lottieURL / lottieFilePath / lottieSizeValue | animationURL (file URL; Lottie/PAG/Rive/SVGA/GIF) / animationURL, frames as animatedImage / imageSize |
| actualBadgeSuperView | actualBadgeSuperView |
| CYLFlatDesignTabBarButton | CYLTagButton (ClassifyMenu); initWithTabBarItem: -> created lazily by item (itemView); tabBarItem -> private item link; imageView; titleLabel |

(The table's lottieURL row maps to animationURL although SBV:152 lists lottieURL among the 5 N/A rows; see Contradictions.)
- Android forms (CYLSearchBarItem.kt, SBV:217-222): PascalCase enum cases; CYLSearchBarItemTextAttributes(color, sizeSp, typeface) per CYLSearchBarItemState Normal/Selected/Disabled; dp sizes, FloatArray insets; index/selectedIndex -1; itemView(context); delegate.searchBarViewDidSelectItem(bar, item).
- Rendering (SBV:223-229): all items drawn by CYLTagButton per state; text item shows title (icon before), icon item only icon (title read by VoiceOver/TalkBack), divider a line; animationURL (iOS URL, Android Uri) plays on each tap via CYLTabBarController's animation engine; new animation types go only into CYLTagButton. HarmonyOS and mini program draw items themselves (TODO in docs/animated-icon-component.md).
- Usage: bar.searchBarStyle = .bordered; addItem(iconItem(camera)); addItem(divider()); addItem(textItem("Search")). Used by iOS CYLSearchDiscoverViewController and Android CYLSearchDiscoverFragment.
- Behavior order (test list SBV:234-236): items after the text and inside the field, 36 pt/dp camera, divider hidden from screen readers, delegate THEN handler, disabled and selectable items, badge, attributes, tint, bordered, removal.
- Wrappers (SBV:237-249): +[CYLSearchBarItem itemWithDictionary:] / CYLSearchBarItem.fromMap(context, map) with keys style, title, image (camera|mic|search|back drawn by core, else app image), accessibilityIdentifier, isEnabled, isSelectable, isSelected, badgeValue; Android gained cyl_search_ic_camera. Flutter: CYLSearchBarView(searchBarStyle:, showsSearchIcon:, items:, onItemSelected:), CYLSearchBarItem.icon/text/divider, onTap; native rebuilds items only when Dart sends different ones; reports didSelectItem (index, selected). RN: searchBarStyle="bordered" showsSearchIcon={false} items=[...] onItemSelect; Fabric prop itemsJSON (one string, same on both platforms).
- Verification claim (2026-11-14, 7d254d6): iOS 26/26, Android 16/16 (JDK 17, Robolectric SDK 34), Android example, Flutter APK, RN release APK, Dart 8/8, flutter analyze clean, tsc clean. "Open" line (SBV:250-251: running Flutter/RN on devices + screenshots, host load ~900) is followed by DONE status with screenshots (SBV:255-273).

## 5. QMUI search port (QMUI): QMUISearchBar / QMUISearchController in Swift, then the merge

READ WITH SECTION 1: the QMUI doc's newest dated statement is 2026-11-23 (QMUI:417-446). It does NOT mention the 2026-11-26 removal of system search bars, so everything about `CYLSearchBar` (UISearchBar subclass), `CYLSystemSearchController`, `install(in:)` of a system controller and the "adapter" role is HISTORY on iOS. Edge-case knowledge (UIKit bugs, behavior contracts) and the other platforms' designs remain useful.

### 5.1 Origin, scope, status (QMUI:7-69)
- Source: Vibe-Coding-Projects/QMUI_iOS-fixed (fork of Tencent/QMUI_iOS, imported at 792c9dda): QMUISearchBar.{h,m}, QMUISearchController.{h,m}, UISearchBar+QMUI, UISearchController+QMUI. Demos QDSearchViewController.m and QDSearchBarViewController.m from QMUI/QMUIDemo_iOS 018ca3a3 (QMUI:72-80). issues1160-TestSearchBar is only an empty Xcode template, so the #1160 scenario was rebuilt from the issue text.
- Owner requirements: design doc first, code by the default Sonnet model; rename to project naming (CYL prefix, cyl_ category members), then Swift; merge into a fitting class else new class, merging our code into it; replicate the QMUI search bar example; read QMUI's comments and keep reasoning + edge cases ("their classes are production proven, ours is a draft"); handle issues #1319 #1251 #1229 #1313 #1160 (QMUI:18-39). Legacy ObjC app files CYLSearchViewController/Class/CYLSearchBar and Class/Controller/CYLSearchController are not compiled by any target and stay untouched as history (QMUI:103-105).
- Phases (all 2026-11-22): 1 (1ffabb0 core, 96ad416; 62 tests) CYLSearchBar + Appearance, rows B1-B13, E23; 2 (a9f59e6, 1f33609; 101 tests) CYLSearchController, E1-E22; 3 (611ada8, 1c95bbe, a9f927e, 41a8747; 119) CYLSearchTableViewController, header snapping, issue screens I1-I5; 4 (6351389, 28cb7d9, 72c45bf; 122) E21 fix, historyStore, licenses, screenshots, score 94/100 (QMUI:40, 327-409). All on iOS 27.2 simulator.
- License rule: each ported file starts with Tencent's MIT notice + "Ported to Swift for CYLSearchViewController, 2026"; docs/licenses.md, pod notices, LICENSE.QMUI, NOTICE; scripts/check-licenses.sh "OK (9 files)" (QMUI:113-115, 376-377).

### 5.2 Original decisions (QMUI:82-115)
1. Target core Sources/CYLSearchBar, PR #11 (owner choice, to avoid three open PRs).
2. No existing class fit a merge (CYLSearchBarView is a custom UIView, CYLSearchView a custom overlay), so new UIKit-wrapping classes (later revised by the merge design, then by NSS).
3. Names: QMUISearchBar->CYLSearchBar; UISearchBar(QMUI)->members of CYLSearchBar (subclass overrides layoutSubviews, so no swizzling) + CYLSearchBarAppearance (QMUI configuration-table values); QMUISearchController->CYLSearchController (UIViewController wrapper); UISearchController(QMUI)->private UISearchController subclass CYLSystemSearchController; delegate->CYLSearchControllerDelegate (@objc, UITableViewDataSource & Delegate); results VC->internal CYLSearchResultsTableViewController; QMUICommonTableViewController(Search)->CYLSearchTableViewController; QMUIEmptyView->CYLTableViewPlaceHolder.
4. iOS 15 floor, NO private API, NO global swizzling. QMUI's private hooks (_UISearchControllerView, UIDimmingView, _updateVisibilityOfSearchResultsForSearchBar:, _updateInsetsForTableView:, _UISearchBarLayout, _modalSourceViewController) replaced by public API / own subclass overrides, or dropped with a reason + test. beginIgnoringInteractionEvents -> window.isUserInteractionEnabled=false; delegate window -> contentsVC.view.window (scene apps); iOS 8-12 code dropped.
5. Every public member @objc with a three-line /** */ comment.

### 5.3 Phase 1-3 public API (historical block, QMUI:117-209)
- CYLSearchBar: UISearchBar: applyDefaultAppearance, appearanceStyle, usedAsTableHeaderView, centersPlaceholder, placeholderColor, textColor, font, textFieldMargins (on top of UIKit (10,8,10,8)), textFieldMarginsProvider(bar, active) (wins), cancelButton/Font/MarginsProvider, alwaysEnablesCancelButton (default true, only without a search controller), backgroundView, segmentedControl, leading/trailingAccessoryView + shows + animated setters + margins, weak searchController, textFieldBackgroundImage(color:), backgroundImage(color:borderColor:).
- CYLSearchControllerDelegate: required searchController(_:updateResultsFor:) (selector searchController:updateResultsForSearchString:), "called on every text change, also with ''" (first activation, all deleted, clear button); optional will/didPresent, will/didDismiss, didLoadSearchResultsTableView, willShowEmptyView.
- CYLSearchController: init(contentsViewController:resultsViewController:) designated; convenience (resultsTableViewStyle:) and (contentsViewController:); searchResultsDelegate, searchController, searchResultsController, searchBar, tableView, launchView, dimmingColor, isActive, setActive(_:animated:), hidesNavigationBarDuringPresentation (default true), alwaysShowsSearchResultsController, forwardsAppearanceFromContentsViewController, supportsSwipeToDismissSearch (false), swipeGestureRecognizer, searchBarMaxY (in searchController.view coords), status bar providers, showEmptyView(text:detailText:buttonTitle:buttonAction:), showEmptyView(scenario:), hideEmptyView, isEmptyViewShowing, installSearchBar(asHeaderOf:), install(in: navigationItem), snapsHeaderSearchBar (true). Later added: historyStore, historyDidChangeNotification, highlightsResultMatches, resultMatchHighlightColor, searchOpen, showSearch/closeSearch(animated:), showsSuggestionsLaunchView, suggestions, noResultsText.
- CYLSearchTableViewController: showsSearchBar (default false; acts once view is loaded), searchController, searchBar, hidesSearchBarWhenEmptyViewShowing, hidesSearchBarInitially (QMUI shouldHideTableHeaderViewInitial), setUpSearchBar() hook (after bar exists, before it is header; removing/renaming breaks subclass screens, QMUI:341), empty updateResults by default, clears results selection in viewWillAppear unless allowsMultipleSelection (QMUI:49-52), empty-view API. Removing the header while an empty view shows and putting it back hidden-initially follows #128 "force".

### 5.4 UIKit edge cases: behavior contracts and findings (QMUI:218-255; "done" = doc claim with named test)
| Row | UIKit behavior / bug | Handling and measured finding |
|:--|:--|:--|
| E1 | definesPresentationContext on contents VC so the bar leaves with a push; results top inset | with contentInsetAdjustmentBehavior=.never UIKit left rows under the bar (first row y 18 vs bar bottom 117), so results controller sets top inset from the bar's bottom (safe area if bar not in a window) |
| E2/E3 | #1541 leaks: popToRoot or replacing window.rootViewController while searching | invisible child CYLSearchPresentationGuard dismisses without animation when contents leave every window; both leak without it on 27.2. Covered-by-push and full-screen modal must NOT dismiss: contents count as alive if the top of ancestors is rootViewController of the window the guard was last in (QMUI:353) |
| E4 | iOS 15 changed obscuresBackgroundDuringPresentation default to NO | set true; false with launchView or alwaysShows... |
| E5 | system controller must loadViewIfNeeded in viewDidLoad | else dealloc loads view and warns (log not readable from XCTest) |
| E6 | setActive(false, animated:false) leaves Cancel shown (reproduced, plain UIKit) | hide and restore automaticallyShowsCancelButton at next willPresent |
| E7 | #1473 | results .never inset behavior + keyboardDismissMode .onDrag |
| E8/E9 | empty view not shown while text empty (would sit on dimming); re-laid out in results viewDidLayoutSubviews; hidden on dismiss | same contract on all platforms |
| E10 | updateResults also receives "" | searchBar.text ?? "" |
| E11-E14 | window-level swipe: only begins inside search view; snapshot behind with mask alpha following finger; dismiss if > 1/4 width and rightward velocity else spring back; interaction off during animations; snapshot moved to top to hide flicker, removed 0.15 s later; clear snapshot after cancelled swipe + clear/cancel | UIKit's "" update during swipe-leave must not clear the cover (skip while swipe dismisses) |
| E15-E19 | launchView fills below bar while text empty (re-laid out, animated); stays behind results; searchBarMaxY via searchBar.convert (no private container view); setActive(true, animated:false) needs results setNeedsLayout; alwaysShows uses public showsSearchResultsController, exclusive with launchView and obscuring; dimming is our own view behind results while text empty, tap cancels, ignored with launchView | |
| E20 | appearance forwarding: UIKit forwards NOTHING to results controller on 27.2 | guard child forwards begin/endAppearanceTransition (viewWill/DidDisappear on push, Will/DidAppear on pop) |
| E21 | #680 cancelled pop then push | QMUI's flash not reproduced (touch run). Phase 4 found a UIKit bug: slow cancelled interactive pop while searching leaves a stale nav bar (contents title) over the blank pushed screen, also with plain UISearchController. Public workaround (6351389): on cancelled transition toggle setNavigationBarHidden twice without animation (setViewControllers with same array does not help). Earlier "blank page after a slow COMPLETED pop" was a misreading: it was cancelled (QMUI:379) |
| E22 | status bar providers forwarded + setNeedsStatusBarAppearanceUpdate | |
| E23 | empty frame -> sizeToFit | 402x64 on iOS 27 |
| B1 | #830 placeholder color reset on window move | reapply in didMoveToWindow |
| B2 | centered placeholder via setPositionAdjustment(for:.search) in layoutSubviews; use bounds.size.width (widths can go negative mid-animation); reset while editing | measured: iOS 27 left inset 12 (QMUI assumed 6) |
| B3 | field margins on UIKit frame | UIKit sets field/Cancel frames again AFTER layoutSubviews: KVO on both frames, track last set frame so margins apply exactly once |
| B4 | Cancel created lazily | find among descendants; iOS 26+ draws xmark UIButton.Configuration with no title (font invisible; localized title is a11y label) |
| B5 | UIKit disables Cancel when editing ends | re-enable via KVO when no search controller |
| B6 | accessories 8 pt gap, centered, state flag (not isHidden) against fast toggling | |
| B7, B8 | Cancel jitter; #233 header y while searching | not reproduced on 27.2 (tests kept) |
| B9 | #950 1 px gap | not on 27.2/26.5; REAL on iOS 17.5 (background container at y=1 px, clipsToBounds): fillTopEdge paints bar layer below iOS 26 (QMUI:738). Separately hand-set background image/barTintColor was invisible while searching (appearance re-applied; image for .default only): explicit values now kept for all metrics, nil returns to appearance (611ada8) |
| B10 | #1207 short header bar invisible | handled with I4; iOS 27.2 pads short content itself (3 rows: content 780) |
| B11 | beta font height bug | dropped; but nil font/textColor/search icon/clear icon assigned together made field 62 pt on iOS 27, so never assign nil to UIKit |
| B12 | index bar moves header bar | dropped (needs private API) |
| B13 | default styling; background image instead of barTintColor so the border color can change | |
Other findings (QMUI:334-341, 351-356, 366-370): UISearchBar answers private cancelButton/setCancelButton:, so the ObjC name is cyl_cancelButton and a test compares selectors with superclasses; iOS 27 field height 44 (QMUI assumed 36), no Auto Layout inside the bar; overriding UISearchController.searchBar in a subclass works on 27.2 (UIKit makes itself delegate); a bar owned by a UISearchController has delegate nil, so history is captured via searchTextField .primaryActionTriggered (QMUI:383); legacy CYLSearchBar put RGB(187,186,193) on bar background, design puts it on the field (dark RGB 58,58,60); navigation-item case: overlays start at safe area (topEdge(in:)); results table frame spans the whole screen; plain-subview bar needs edgesForExtendedLayout without .top; iOS 26+ floats navigation-item bar at the bottom on iPhone (demo uses .stacked, toolbar integration off).

### 5.5 Owner issues I1-I5 (QMUI:259-265, 415-431)
- I1 #1319 bar jumps on activation: definesPresentationContext + consistent edgesForExtendedLayout; test: every frame within 0.5 pt with hidesNavigationBarDuringPresentation=false.
- I2 #1251 plain-subview bar misplaced: UIKit still moved it to y 0 unless .top removed. Real taps found two defects tests missed: bar 0 pt wide while searching (UIKit drops constraints; fixed 28cb7d9 with a self-contained width constraint) and 116 pt too low (UIKit places its container at the bar's window y inside a presentation view that already starts at y 116: counted twice). FIXED 0a7deab (2026-11-23): keep rest frame in willPresent, system controller moves the container by the difference in viewDidLayoutSubviews; claim 188 tests 0 failures on 27.2/26.5/17.5.
- I3 #1229 wrapper assigned to navigationItem.searchController crashes: install(in:) assigns the system controller and associates the wrapper with contents VC. Black band behind bar while searching (default style hides bar background, black behind) FIXED bfbee55: nav-item bar draws systemBackground; 125 tests.
- I4 #1160 header does not snap with short content (QMUI answer: no estimated heights, avoid the four header/footer methods): estimated heights 0; retained CYLSearchHeaderSnapper adds only the needed bottom inset (KVO contentSize/bounds, subtracting its own) and settles shown/hidden using the pan recognizer target (.ended, velocity projected with decelerationRate, only inside header band) so the table delegate is never replaced. Real drag: 64 pt header, 32 pt threshold (20/25 pt shown; 40/50/60 hidden).
- I5 #1313 bar in collection header jitters after cancel: keep the bar in an owned container (CYLSearchBarContainerView) or navigation item, never a reusable view.
- Testing lessons (QMUI:381-383): unit tests sampling frames need width and absolute position checks; axe drags need a settled screen (5 s after launch, 2.5 s after drag); use a throwaway plain UIKit screen as control.

### 5.6 History, launch view, placeholder merges (phase 1-4 of QMUI port; QMUI:269-286)
- Legacy defaults (field RGB 187/186/193, tint RGB 0/104/248, "搜索" and "取消" now localized) -> CYLSearchBarAppearance.default. History store is the existing CYLSearchSuggestionStore (database/NSUserDefaults/file; newest first, no duplicates) via CYLSearchResources.suggestionCache(policy:name:); historyStore receives trimmed non-blank submitted queries. Launch tags use ClassifyMenu CYLTagListView, empty view uses CYLTableViewPlaceHolder.
- Example screens (QMUI:290-306): "Search controller" (10 keywords Helps, Maintain, Liver, Health, Function, Supports, Healthy, Fat, Metabolism, Nuturally; results = matching keywords x 20; "No matching results"; 8 launch suggestions); "Search bar styles" (Placeholder, Layout margins (0,32,0,32) at rest / zero active, Cancel (0,-16,0,0) active, AccessoryView 30x30 squares margins 8 hidden first); four issue screens. Requirements: en+zh strings, Dynamic Type, dark mode, bar never covers a view (testSearchBarsCoverNoView).

### 5.7 QMUI port score and leftover items (iOS; QMUI:398-446)
- 94/100 (pass 60) on 2026-11-22; issue-row criterion later 15/15 (QMUI:404), total not restated. Acceptance weights: API 15, edge rows 30, issues 15, example 15, merge table 10, suite+screenshots 10, license/doc 5 (QMUI:315-325).
- 2026-11-23: Podfile.lock committed in sync (CYLTabBarController and CYLAnimatedItem c4a1f8fd, ClassifyMenu 04b39e26, PlaceHolder f4cf978) (QMUI:444-446). History refresh DONE 0b3cbcf (historyDidChangeNotification).

### 5.8 Cross-platform parity of the port (2026-11-22; QMUI:449-484)
Rule: put behavior into the class it belongs to (parameter/mode before new class, new class only for a new concept); I1-I3, I5 are UIKit defects = N/A elsewhere; score 100 = all rows done/N/A, both replica screens, test or labelled screenshot per screen, checks green. Order: native cores (Android, HarmonyOS, mini program) then wrappers.

| iOS concept | Android | HarmonyOS | Mini program | React Native | Flutter |
|:--|:--|:--|:--|:--|:--|
| bar style knobs | CYLSearchBarView props, CYLSearchBarAppearance.kt | CYLSearchBarView.ets + CYLSearchBarAppearance (opt-in) | cyl-search-bar props + setters (closures via setXProvider methods) | props (providers become rest/searching prop pairs) | widget params |
| controller | CYLSearchView ("active" = field focused) | CYLSearchView | cyl-search | CYLSearchListView / CylsearchListView | CYLSearchView |
| table controller | new CYLSearchListView | new CYLSearchTableView + CYLSearchTableComponent | cyl-search mode showsSearchBar+showsContent | CylsearchListView | new CYLSearchListView (Dart) |
| swipe | predictive back (no own recognizer) | system back (later own 24 vp pan, phase 5) | edge touch handlers + page-container back | per native core | Dart edge strip, later native core |
Port scores (first pass): Android 92 (QMUI:488), HarmonyOS 90 (QMUI:573), mini program 79/85 without 15 device points (QMUI:698), RN 72 with iOS TODO (QMUI:755), Flutter 86 (QMUI:870).
Android core bugs found/fixed (QMUI:545-555): hideKeyboard kept focus (focus sink added; itself a TODO: invisible Tab stop); delegate refusing edit looped requestFocus -> StackOverflowError; accessory touched field (8 dp gap); Back from a detail page over open search closed the hidden search (fix CYLSearchView.isCovered / passBackThrough); caret on idle header bar. Android env: JDK 17.0.21 required (JDK 21/25 break Robolectric 4.14.1), Gradle 9.4.1 via "sh ./gradlew", AGP 9.2.1, Kotlin 2.2.20.
HarmonyOS env/commands (QMUI:573-577, 621-626): HarmonyOS 6.0.1 API 21, DevEco 6.0.1; hvigorw assembleHap and ohosTest after deleting build, .hvigor, oh_modules; checks host-logic-test.mjs, check-ios-parity.mjs, check-accessibility-i18n.mjs, hypium via aa test.
Mini program: npm test in CrossPlatform/wechat-miniprogram-cylsearch; device testing belongs to the Windows session; miniprogram-api-alignment output not committed (adds 94 TODO rows; baseline 75/100 on 385 rows) (QMUI:691-694).

### 5.9 iOS 17.5 / 26.5 verification (QMUI:732-750)
Before fix: 26.5 one failed assertion, 17.5 eleven in 6 tests; after: 123/0 on 17.5, 26.5, 27.2. Real core fix only B9 on 17.5; the others were test tolerances (B7 1.5 pt; one-frame bar detach on 26.5; E21 search view leaves window later on 17.5, wait 4 s; visibility check later showed it is never on top, QMUI:938). iOS 15/16 cannot run on macOS 27.3; 18-25 unverified. CI-like command: xcodebuild test with new derived data, CODE_SIGNING_ALLOWED=NO.

### 5.10 "Merge design: one implementation per concept" (QMUI:797-865): the architecture decision of 2026-11-22
- Evaluation: "ours" (CYLSearchBarView/CYLSearchView) runs on six platforms with one API table, own field, suggestions, results, refresh; QMUI classes are iOS-only with strong UIKit fixes (presentation, header snapping, list screen).
- DECISION: ours is the base; QMUI strengths become parameters/modes of our classes; public names CYLSearchBar/CYLSearchController/CYLSearchTableViewController stay but lose own logic; CYLSearchBar remained only as the UISearchController adapter because navigationItem.searchController needs a UISearchBar (that "one limit" was removed by the 2026-11-26 owner order, section 1). Owner stated the same to RN/Flutter agents: iOS wrappers bridge only CYLSearchBarView/CYLSearchView, never host CYLSearchController (QMUI:757, 871).
- Pair decisions: one appearance helper; centersPlaceholder new on CYLSearchBarView (shared math); contentInsets = resting margins, provider wins per active state; cancel margins/font and setShowsCancelButton added; accessories animate the EXISTING leadingView/trailingAccessoryViews (QMUI names only forward on CYLSearchBar); launchView = CYLSearchView suggestion area; scrimColor canonical, dimmingColor forwards; one results+placeholder component and highlight as core option; one history store and one change signal matched by cache name (cache(policy:name:) returns a new instance each call); one active state + event source; swipe also on CYLSearchView; snapper shared for any header; QMUI tag size 69x29 needs ClassifyMenu CYLMenuStyle.minimumItemSize + pin move (phase 6).
- Rules: core first; old public API keeps compiling (@available(*, deprecated, renamed:)); API fence (Swift test + ObjC smoke test touching every public member) committed before phase 1, must compile unchanged; examples call API only; tags only via ClassifyMenu CYLTagListView; each phase ends green on iOS 17.5/26.5/27.2 with before/after screenshots.
- API fence mechanics (QMUI:920-936): CYLSearchAPIFenceTests.swift (no @testable; writable props via key path; typed function references; subclasses open classes) and a section of CYLSearchCoreObjectiveCSmokeTests.m (-Wundeclared-selector as error, respondsToSelector, protocol_getMethodDescription). New public member needs a line in BOTH. No negative test; ObjC generator not committed.



_Continues in [part 2](B-search-core-design-part2.md)._
