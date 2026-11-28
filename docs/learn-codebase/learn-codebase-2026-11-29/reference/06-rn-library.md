> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# React Native library: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `CrossPlatform/react-native-cylsearch/android/build.gradle` | 40 |
| `CrossPlatform/react-native-cylsearch/android/src/main/AndroidManifest.xml` | 2 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchBarView.kt` | 365 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchBarViewManager.kt` | 199 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchListView.kt` | 143 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchListViewManager.kt` | 101 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchPlaceholderView.kt` | 35 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchPlaceholderViewManager.kt` | 44 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchSupport.kt` | 171 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchTagListView.kt` | 235 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchTagListViewManager.kt` | 145 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchView.kt` | 156 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchViewManager.kt` | 133 |
| `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchViewPackage.kt` | 17 |
| `CrossPlatform/react-native-cylsearch/babel.config.mjs` | 12 |
| `CrossPlatform/react-native-cylsearch/Cylsearch.podspec` | 26 |
| `CrossPlatform/react-native-cylsearch/eslint.config.mjs` | 29 |
| `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchResults.h` | 17 |
| `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchResults.mm` | 27 |
| `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchSupport.h` | 131 |
| `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchSupport.mm` | 36 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchBarView.h` | 8 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchBarView.mm` | 504 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.h` | 8 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.mm` | 306 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchPlaceholderView.h` | 12 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchPlaceholderView.mm` | 133 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchTagListView.h` | 8 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchTagListView.mm` | 429 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchView.h` | 8 |
| `CrossPlatform/react-native-cylsearch/ios/CylsearchView.mm` | 203 |
| `CrossPlatform/react-native-cylsearch/package.json` | 203 |
| `CrossPlatform/react-native-cylsearch/src/CylsearchBarViewNativeComponent.ts` | 268 |
| `CrossPlatform/react-native-cylsearch/src/CylsearchListViewNativeComponent.ts` | 148 |
| `CrossPlatform/react-native-cylsearch/src/CylsearchPlaceholderViewNativeComponent.ts` | 22 |
| `CrossPlatform/react-native-cylsearch/src/CYLSearchProps.ts` | 338 |
| `CrossPlatform/react-native-cylsearch/src/CylsearchTagListViewNativeComponent.ts` | 177 |
| `CrossPlatform/react-native-cylsearch/src/CylsearchViewNativeComponent.ts` | 133 |
| `CrossPlatform/react-native-cylsearch/src/index.tsx` | 443 |
| `CrossPlatform/react-native-cylsearch/tsconfig.json` | 33 |

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchBarView.kt`

CYLSearchBarView of the `cylsearch` module (a final class), filling the component.

- L24 `class CylsearchBarView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext), CYLSearchBarViewDelegate` — CYLSearchBarView of the `cylsearch` module (a final class), filling the component.
- L26 `var bar = CYLSearchBarView(reactContext)`
- L40 `var embedsInNavigationBar: Boolean = false` — `embedsInNavigationBar`: the bar sits in a toolbar (the Android navigation bar) the view creates and the core sizes it (CYLSearchBarView.embedInToolbar): the bar fills the width beside the back arrow, with no width or margin from here.
- L49 `var showsBackButton: Boolean = false` — `showsBackButton` (with `embedsInNavigationBar`): the toolbar's navigation icon is the back arrow; a tap sends `onBackButtonTap`.
- L77 `var pushesOnTap: Boolean = false` — `pushesOnTap` (first-level page): a tap on the field brings the back button in (the core) and sends `onFirstLevelTap`.
- L84 `var animatesBackButton: Boolean = true` — `animatesBackButton`: the back button of `showsBackButton` slides in (and out) with the width following; false: at once.
- L99 `val previous = shownBack`
- L113 `var actionTitle: String = ""` — The editing bar's action title ("Add", "Done"), kept for a bar made later.
- L123 `fun setEditingBar(editing: Boolean)` — `editingBar`: the core's editing bar (CYLSearchBarView.editingBar) in place of the search bar, its submit sent as `onEditingSubmit` (the trimmed text) and the field cleared after it; false brings a search bar back.
- L125 `val placeholder = bar.placeholder`
- L138 `override fun requestLayout()`
- L149 `fun sendSearchButtonTap(text: String) = emit("topSearchButtonTap", "text" to text)` — The default search button was tapped while the host handles it (`onSearchButtonTap`).
- L156 `override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) =`
- L159 `override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String, index: Int) =`
- L162 `override fun searchBarViewDidCompleteSearch(searchBarView: CYLSearchBarView, text: String, index: Int)`
- L166 `override fun searchBarViewDidRemoveSearchAtIndex(searchBarView: CYLSearchBarView, index: Int)`
- L170 `override fun searchBarViewDidSelectSearch(searchBarView: CYLSearchBarView, text: String, index: Int)`
- L174 `override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView)`
- L181 `override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) = emit("topCancel")`
- L183 `override fun searchBarViewDidBeginEditing(searchBarView: CYLSearchBarView) = emitActive(true)`
- L185 `override fun searchBarViewDidEndEditing(searchBarView: CYLSearchBarView) = emitActive(false)`
- L193 `var usesDefaultAppearance = false` — The QMUI options (iOS: CYLSearchBar members, Android: CYLSearchBarView members). They are kept here and applied together after each prop update, so the default appearance never overwrites what JavaScript set after it.
- L194 `var centersPlaceholder = false`
- L195 `var placeholderProp: String? = null`
- L196 `var placeholderColor: String? = null`
- L197 `var textColor: String? = null`
- L198 `var fieldMargins: List<Double> = emptyList()`
- L199 `var searchingFieldMargins: List<Double> = emptyList()`
- L200 `var cancelMargins: List<Double> = emptyList()`
- L201 `var searchingCancelMargins: List<Double> = emptyList()`
- L202 `var animatesChanges = true`
- L203 `var leadingViewJSON: String? = null`
- L204 `var trailingAccessoryViewsJSON: String? = null`
- L205 `var showsLeadingView = false`
- L206 `var showsTrailingAccessoryViews = false`
- L207 `var appearanceStyleJSON: String? = null`
- L208 `var cancelButtonFontJSON: String? = null`
- L209 `var showsCancel = false`
- L211 `var navigationFieldStyle = false` — The core navigation field preset (`CYLSearchBarView.applyNavigationFieldStyle()`), applied last in `applyQMUIStyle`.
- L220 `fun applyQMUIStyle()` — Called once per prop update (the manager's onAfterUpdateTransaction).
- L221 `val appearance = usesDefaultAppearance to appearanceStyleJSON`
- L231 `val field = rect(fieldMargins)`
- L232 `val fieldActive = rect(searchingFieldMargins)`
- L233 `val cancel = rect(cancelMargins)`
- L234 `val cancelActive = rect(searchingCancelMargins)`
- L282 `val spec = runCatching { JSONObject(json) }.getOrNull() ?: return null`
- L283 `val density = resources.displayMetrics.density`
- L284 `val size = (spec.optDouble("size", 30.0) * density).toInt()`
- L285 `val view = View(context)`
- L299 `override fun searchBarViewDidSelectItem(searchBarView: CYLSearchBarView, item: CYLSearchBarItem) =`
- L307 `fun setItemsJSON(value: String?)` — Rebuilds the items when JavaScript sends other ones, so a re-render keeps the native selection.
- L308 `val json = value.orEmpty()`
- L311 `val array = runCatching { JSONArray(json) }.getOrNull()`
- L317 `fun restartItemAnimation(index: Int)` — The `restartItemAnimation` command: plays the animation of the item at `index` again from the start.
- L325 `fun goBack()` — The `goBack` command (for the hardware back key): what a tap on the back arrow does, the arrow slides out first (animated with `animatesBackButton`), then `onBackButtonTap`; without a back arrow the event is sent at once.
- L335 `fun setMode(value: String?)` — The `mode` prop: "multiple" shows several searches side by side; turning it on applies the `searches` prop again.
- L336 `val mode = if (value == "multiple") CYLSearchBarMode.Multiple else CYLSearchBarMode.Single`
- L346 `fun setSearches(value: List<String>)` — The `searches` prop: replaces the native searches only when JavaScript sends another list, so a re-render keeps the searches typed natively.

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchBarViewManager.kt`

The search bar (`CylsearchBarView` in JavaScript).

- L19 `class CylsearchBarViewManager : SimpleViewManager<CylsearchBarView>(), CylsearchBarViewManagerInterface<CylsearchBarView>` — The search bar (`CylsearchBarView` in JavaScript).
- L22 `override fun getDelegate(): ViewManagerDelegate<CylsearchBarView> = delegate`
- L23 `override fun getName() = NAME`
- L24 `override fun createViewInstance(context: ThemedReactContext) = CylsearchBarView(context)`
- L27 `override fun setPlaceholder(view: CylsearchBarView, value: String?)`
- L33 `override fun setText(view: CylsearchBarView, value: String?)`
- L45 `override fun setShowsCancelButton(view: CylsearchBarView, value: Boolean)`
- L50 `override fun setFieldShadowOpacity(view: CylsearchBarView, value: Double)`
- L55 `override fun setSearchBarStyle(view: CylsearchBarView, value: String?)`
- L60 `override fun setNavigationFieldStyle(view: CylsearchBarView, value: Boolean) { view.navigationFieldStyle = value }`
- L64 `override fun setShowsSearchButton(view: CylsearchBarView, value: Boolean) { view.bar.showsSearchButton = value }` — The core's default search button (iOS and Android `showsSearchButton`, `searchButtonStyle`, `searchButtonTitle`, `searchButtonHandler`).
- L67 `override fun setSearchButtonStyle(view: CylsearchBarView, value: String?)`
- L72 `override fun setSearchButtonTitle(view: CylsearchBarView, value: String?) { view.bar.searchButtonTitle = value?.takeIf { it.isNotEmpty() } }`
- L75 `override fun setHasSearchButtonHandler(view: CylsearchBarView, value: Boolean)`
- L80 `override fun setFocusesOnAppear(view: CylsearchBarView, value: Boolean) { view.bar.focusesOnAppear = value }`
- L83 `override fun setPageDepth(view: CylsearchBarView, value: Int) { view.bar.pageDepth = value.takeIf { it >= 0 } }`
- L86 `override fun setShowsSearchIcon(view: CylsearchBarView, value: Boolean)`
- L91 `override fun setEmbedsInNavigationBar(view: CylsearchBarView, value: Boolean)`
- L96 `override fun setShowsBackButton(view: CylsearchBarView, value: Boolean)`
- L101 `override fun setPushesOnTap(view: CylsearchBarView, value: Boolean) { view.pushesOnTap = value }`
- L104 `override fun setAnimatesBackButton(view: CylsearchBarView, value: Boolean) { view.animatesBackButton = value }`
- L107 `override fun setEditingBar(view: CylsearchBarView, value: Boolean) = view.setEditingBar(value)`
- L110 `override fun setActionTitle(view: CylsearchBarView, value: String?)`
- L115 `override fun setItemsJSON(view: CylsearchBarView, value: String?) = view.setItemsJSON(value)`
- L118 `override fun setMode(view: CylsearchBarView, value: String?) = view.setMode(value)`
- L121 `override fun setSearches(view: CylsearchBarView, value: ReadableArray?) = view.setSearches(value.cylStrings())`
- L124 `override fun setMinimumTextLength(view: CylsearchBarView, value: Int)`
- L129 `override fun setUsesDefaultAppearance(view: CylsearchBarView, value: Boolean) { view.usesDefaultAppearance = value }`
- L132 `override fun setCentersPlaceholder(view: CylsearchBarView, value: Boolean) { view.centersPlaceholder = value }`
- L135 `override fun setPlaceholderColor(view: CylsearchBarView, value: String?) { view.placeholderColor = value }`
- L138 `override fun setTextColor(view: CylsearchBarView, value: String?) { view.textColor = value }`
- L141 `override fun setFieldMargins(view: CylsearchBarView, value: ReadableArray?) { view.fieldMargins = value.cylDoubles() }`
- L144 `override fun setSearchingFieldMargins(view: CylsearchBarView, value: ReadableArray?) { view.searchingFieldMargins = value.cylDoubles() }`
- L147 `override fun setCancelMargins(view: CylsearchBarView, value: ReadableArray?) { view.cancelMargins = value.cylDoubles() }`
- L150 `override fun setSearchingCancelMargins(view: CylsearchBarView, value: ReadableArray?) { view.searchingCancelMargins = value.cylDoubles() }`
- L153 `override fun setAnimatesChanges(view: CylsearchBarView, value: Boolean) { view.animatesChanges = value }`
- L156 `override fun setLeadingViewJSON(view: CylsearchBarView, value: String?) { view.leadingViewJSON = value }`
- L159 `override fun setTrailingAccessoryViewsJSON(view: CylsearchBarView, value: String?) { view.trailingAccessoryViewsJSON = value }`
- L162 `override fun setShowsLeadingView(view: CylsearchBarView, value: Boolean) { view.showsLeadingView = value }`
- L165 `override fun setShowsTrailingAccessoryViews(view: CylsearchBarView, value: Boolean) { view.showsTrailingAccessoryViews = value }`
- L168 `override fun setAppearanceStyleJSON(view: CylsearchBarView, value: String?) { view.appearanceStyleJSON = value }`
- L171 `override fun setCancelButtonFontJSON(view: CylsearchBarView, value: String?) { view.cancelButtonFontJSON = value }`
- L174 `override fun onAfterUpdateTransaction(view: CylsearchBarView)` — Applies the QMUI options together, after every prop of the update is set.
- L180 `override fun setActive(view: CylsearchBarView, active: Boolean)` — The `setActive` command: focus (the keyboard rises) or leave the focus.
- L185 `override fun restartItemAnimation(view: CylsearchBarView, index: Int) = view.restartItemAnimation(index)` — The `restartItemAnimation` command: plays that item's animation again from the start.
- L188 `override fun goBack(view: CylsearchBarView) = view.goBack()` — The `goBack` command: the back arrow slides out, then `onBackButtonTap` (the hardware back key of the app).
- L194 `override fun setColorScheme(view: CylsearchBarView, value: String?) = Unit` — The views use the activity's theme (DayNight), which follows the system like React Native's color scheme.
- L197 `const val NAME = "CylsearchBarView"`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchListView.kt`

The core's `CYLSearchListView` (iOS `CYLSearchTableViewController`: a list whose first item is the search bar) with its `CYLSearchView` as the search. The page is the core's own: its suggestion area is the launch area (the history, else `suggestions`, as folded tags, with the title and the clear button), `scrimColor` the dimming, `noResultsText` the empty view, `highlightsResultMatches` the highli

- L24 `class CylsearchListView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext), CYLSearchViewDelegate` — The core's `CYLSearchListView` (iOS `CYLSearchTableViewController`: a list whose first item is the search bar) with its `CYLSearchView` as the search. The page is the core's own: its suggestion area is the launch area (the history, else `suggestions`, as folde
- L26 `val list = CYLSearchListView(reactContext)`
- L27 `val searchView: CYLSearchView get() = list.searchView`
- L30 `var rows: List<String> = emptyList()`
- L35 `var results: List<String>`
- L40 `var resultsQuery: String`
- L45 `var noResultsText: String = ""`
- L46 `var suggestions: List<String> = emptyList()`
- L47 `var suggestionCachePolicy: String? = null`
- L48 `var suggestionCacheName: String? = null`
- L49 `var scrimColor: String? = null`
- L50 `var placeholder: String? = null`
- L53 `override fun getItemCount() = rows.size`
- L55 `override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder`
- L67 `override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int)`
- L96 `fun applyProps()` — Applies the props that depend on each other, once per update (the manager's onAfterUpdateTransaction).
- L111 `override fun searchViewUpdateResults(searchView: CYLSearchView, searchString: String)` — The text changed (also ""): JavaScript answers with results of that text.
- L115 `override fun searchViewWillShow(searchView: CYLSearchView) = emit("topWillPresent")`
- L116 `override fun searchViewDidShow(searchView: CYLSearchView) = emit("topDidPresent")`
- L117 `override fun searchViewWillClose(searchView: CYLSearchView) = emit("topWillDismiss")`
- L118 `override fun searchViewDidClose(searchView: CYLSearchView) = emit("topDidDismiss")`
- L120 `override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean`
- L125 `override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any)`
- L129 `override fun requestLayout()`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchListViewManager.kt`

The list with a search bar and its search (`CylsearchListView` in JavaScript): the core's `CYLSearchListView` and `CYLSearchView`.

- L17 `class CylsearchListViewManager : SimpleViewManager<CylsearchListView>(), CylsearchListViewManagerInterface<CylsearchListView>` — The list with a search bar and its search (`CylsearchListView` in JavaScript): the core's `CYLSearchListView` and `CYLSearchView`.
- L20 `override fun getDelegate(): ViewManagerDelegate<CylsearchListView> = delegate`
- L21 `override fun getName() = NAME`
- L22 `override fun createViewInstance(context: ThemedReactContext) = CylsearchListView(context)`
- L25 `override fun setRows(view: CylsearchListView, value: ReadableArray?) { view.rows = value.cylStrings() }`
- L28 `override fun setPlaceholder(view: CylsearchListView, value: String?) { view.placeholder = value }`
- L31 `override fun setCentersPlaceholder(view: CylsearchListView, value: Boolean)`
- L37 `override fun setShowsSearchBar(view: CylsearchListView, value: Boolean) { view.list.showsSearchBar = value }`
- L40 `override fun setHidesSearchBarInitially(view: CylsearchListView, value: Boolean) { view.list.hidesSearchBarInitially = value }`
- L43 `override fun setHidesSearchBarWhenEmptyViewShowing(view: CylsearchListView, value: Boolean) { view.list.hidesSearchBarWhenEmptyViewShowing = value }`
- L46 `override fun setSnapsHeaderSearchBar(view: CylsearchListView, value: Boolean) { view.list.snapsHeaderSearchBar = value }`
- L49 `override fun setResults(view: CylsearchListView, value: ReadableArray?) { view.results = value.cylStrings() }`
- L52 `override fun setResultsQuery(view: CylsearchListView, value: String?) { view.resultsQuery = value.orEmpty() }`
- L55 `override fun setNoResultsText(view: CylsearchListView, value: String?) { view.noResultsText = value.orEmpty() }`
- L58 `override fun setSuggestions(view: CylsearchListView, value: ReadableArray?) { view.suggestions = value.cylStrings() }`
- L61 `override fun setSubmitsOnSuggestionSelection(view: CylsearchListView, value: Boolean) { view.searchView.submitsOnSuggestionSelection = value }`
- L64 `override fun setSuggestionCachePolicy(view: CylsearchListView, value: String?) { view.suggestionCachePolicy = value }`
- L67 `override fun setSuggestionCacheName(view: CylsearchListView, value: String?) { view.suggestionCacheName = value }`
- L70 `override fun setScrimColor(view: CylsearchListView, value: String?) { view.scrimColor = value }`
- L73 `override fun setHighlightsResultMatches(view: CylsearchListView, value: Boolean) { view.searchView.highlightsResultMatches = value }`
- L76 `override fun setResultMatchHighlightColor(view: CylsearchListView, value: String?) { view.searchView.resultMatchHighlightColor = cylParseColor(value) }`
- L79 `override fun setSupportsSwipeToDismissSearch(view: CylsearchListView, value: Boolean) { view.searchView.supportsSwipeToDismissSearch = value }`
- L83 `override fun setColorScheme(view: CylsearchListView, value: String?) = Unit` — The views use the activity's theme (DayNight), which follows the system like React Native's color scheme.
- L85 `override fun onAfterUpdateTransaction(view: CylsearchListView)`
- L90 `override fun setActive(view: CylsearchListView, active: Boolean, animated: Boolean)`
- L94 `override fun clearHistory(view: CylsearchListView)`
- L99 `const val NAME = "CylsearchListView"`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchPlaceholderView.kt`

CYLTableViewPlaceHolder's CYLPlaceholderView in the component (`CylsearchPlaceholderView`): the image of a `CYLPlaceholderStyle` above a text, at its content size, centred.

- L13 `class CylsearchPlaceholderView(reactContext: ThemedReactContext) : FrameLayout(reactContext)` — CYLTableViewPlaceHolder's CYLPlaceholderView in the component (`CylsearchPlaceholderView`): the image of a `CYLPlaceholderStyle` above a text, at its content size, centred.
- L15 `var styleName: String = "empty"`
- L16 `var text: String = ""`
- L19 `fun rebuild()` — Builds the placeholder for the current style and text ("noResults" -> NoResults; unknown -> Empty).
- L21 `val style = CYLPlaceholderStyle.entries.firstOrNull { it.name.equals(styleName, ignoreCase = true) } ?: CYLPlaceholderStyle.Empty`
- L22 `val placeholder = CYLPlaceholderView(context, style, text).apply { reportsContentSize = true }`
- L26 `override fun requestLayout()`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchPlaceholderViewManager.kt`

The placeholder (`CylsearchPlaceholderView` in JavaScript): rebuilt once a batch of props is applied.

- L15 `class CylsearchPlaceholderViewManager : SimpleViewManager<CylsearchPlaceholderView>(),` — The placeholder (`CylsearchPlaceholderView` in JavaScript): rebuilt once a batch of props is applied.
- L19 `override fun getDelegate(): ViewManagerDelegate<CylsearchPlaceholderView> = delegate`
- L20 `override fun getName() = NAME`
- L21 `override fun createViewInstance(context: ThemedReactContext) = CylsearchPlaceholderView(context)`
- L24 `override fun setPlaceholderStyle(view: CylsearchPlaceholderView, value: String?)`
- L29 `override fun setText(view: CylsearchPlaceholderView, value: String?)`
- L34 `override fun setColorScheme(view: CylsearchPlaceholderView, value: String?) = Unit`
- L36 `override fun onAfterUpdateTransaction(view: CylsearchPlaceholderView)`
- L42 `const val NAME = "CylsearchPlaceholderView"`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchSupport.kt`

The strings of a JavaScript array.

- L52 `override fun getEventName() = name`
- L53 `override fun getEventData(): WritableMap = data`
- L85 `val policy = when (policyName)`
- L92 `val cacheName = name?.takeIf { it.isNotEmpty() } ?: defaultName`
- L106 `var results: List<String> = emptyList()`
- L107 `var resultsQuery: String? = null`
- L109 `override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> =`
- L112 `override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any)`
- L123 `val spec = json?.takeIf { it.isNotEmpty() }?.let { runCatching { org.json.JSONObject(it) }.getOrNull() }`
- L129 `val weight = when (spec.optString("weight"))`
- L145 `fun cylLoadImage(context: android.content.Context, location: String, onLoaded: (android.graphics.drawable.Drawable?) -> Unit)` — Loads the image of `location` and reports it on the main thread (null when it cannot be read): a URL (the Metro server in debug builds), a file URI, or a drawable resource name (what a release build resolves a required asset to). A "@3x" / "@2x" suffix gives t
- L146 `val main = android.os.Handler(android.os.Looper.getMainLooper())`
- L147 `fun finish(drawable: android.graphics.drawable.Drawable?) { main.post { onLoaded(drawable) } }`
- L148 `fun bitmapDrawable(bitmap: android.graphics.Bitmap?): android.graphics.drawable.Drawable?`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchTagListView.kt`

CollectionViewClassifyMenu's CYLTagListView filling the component, one section of tags from JavaScript: their titles and ids, the selection, the header (title and clear button) and editing mode (crosses, dragging, rename requests). It reports the height its tags need at the component's width (`onHeightChange`, in dp), again after folding, unfolding and editing.

- L25 `class CylsearchTagListView(private val reactContext: ThemedReactContext) : CYLTagListView(reactContext), CYLMenuDataSource, CYLMenuDelegate` — CollectionViewClassifyMenu's CYLTagListView filling the component, one section of tags from JavaScript: their titles and ids, the selection, the header (title and clear button) and editing mode (crosses, dragging, rename requests). It reports the height its ta
- L27 `var foldPosition: String? = null`
- L28 `var foldContent: String? = null`
- L32 `var titles: List<String> = emptyList()` — The tags' titles and ids (the titles when no ids are given).
- L34 `var ids: List<String> = emptyList()`
- L37 `var sectionTitle: String = ""`
- L38 `var showsClearButton: Boolean = false`
- L39 `var supportsRenaming: Boolean = false`
- L42 `var showsRefreshButton: Boolean = false` — The header action is the built-in refresh icon (`onRefreshButtonTap`); it wins over the trash (`showsClearButton`).
- L45 `var backgroundStyle: String = ""` — The tag background by name: "liquidGlass", else flat (the spec prop `backgroundStyle`; applied with the list style).
- L48 `var columns: Int = 0` — 0: flowing tags; 2 and more: the grid of that many tags per row (ClassifyMenu's grid style).
- L51 `var tagImages: List<String> = emptyList()` — One image location per tag ('' none): a URL, a file URI or a drawable resource name, loaded once and cached.
- L56 `var tagImageLabels: List<String> = emptyList()` — The screen-reader label of each tag image, parallel to `tagImages` ('' none): TalkBack reads it with the tag (the hot icon says "Hot").
- L59 `var tagSubtitles: List<String> = emptyList()` — The subtitle of each tag ('' none), shown in a callout on a long press (ClassifyMenu `longPressAction`, PR #37).
- L62 `var titleMaxLines: Int = 1` — 1: one line (default), 0: no limit, n: at most n lines (ClassifyMenu `CYLTagTitleMaxLines`, PR #37).
- L80 `fun setTags(titles: List<String>, ids: List<String>)` — Sets the tags (titles and ids) and shows the selection again.
- L86 `fun setSelectedIds(value: List<String>)`
- L91 `fun setSelection(mode: String?)`
- L97 `fun applyListStyle()` — The list's style for `columns` and `showsRefreshButton`; apply it before `reload` (a style assignment replaces the icon).
- L100 `val base = if (columns > 0)` — The search bar core's default tag look (capsule tags, light border, bold header, 16 dp inset), customizable through CYLSearchTagListStyle; the React Native screen shows through the list.
- L117 `fun setTagImages(value: List<String>)`
- L129 `fun reload()`
- L143 `override fun numberOfSectionsInMenu() = 1`
- L144 `override fun menuNumberOfItemsInSection(section: Int) = titles.size`
- L145 `override fun menuTitleForSection(section: Int) = sectionTitle`
- L146 `override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles.getOrElse(indexPath.item) { "" }`
- L147 `override fun menuSubtitleForItemAtIndexPath(indexPath: CYLIndexPath): String? =`
- L149 `override fun menuIdentifierForItemAtIndexPath(indexPath: CYLIndexPath): String = idAt(indexPath.item)`
- L150 `override fun menuShowsClearButtonForSection(section: Int) = showsClearButton && !showsRefreshButton`
- L151 `override fun menuShowsMoreButtonInSection(section: Int) = showsRefreshButton`
- L152 `override fun menuAccessibilityLabelForMoreButtonInSection(section: Int) = CYLSearchTagListHeader.refreshLabel(reactContext)`
- L153 `override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): Drawable?`
- L154 `val image = loadedImages[tagImages.getOrNull(indexPath.item).orEmpty()] ?: return null`
- L155 `val label = tagImageLabels.getOrNull(indexPath.item).orEmpty()`
- L163 `override fun supportsRenamingItems() = supportsRenaming`
- L164 `override fun menuRenameItemAtIndexPath(indexPath: CYLIndexPath, title: String) = Unit`
- L165 `override fun supportsMovingItems() = true`
- L166 `override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath)`
- L167 `val moved = titles.toMutableList().apply { add(toIndexPath.item, removeAt(sourceIndexPath.item)) }`
- L172 `override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath)`
- L173 `val index = indexPath.item`
- L174 `val id = idAt(index)`
- L182 `override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath)`
- L183 `val index = indexPath.item`
- L184 `val id = idAt(index)`
- L185 `val nowSelected = selectionMode == CYLMenuSelectionMode.CYLMenuSelectionModeMultiple`
- L190 `override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath)`
- L191 `val index = indexPath.item`
- L192 `val id = idAt(index)`
- L197 `override fun menuDidTapClearButtonInSection(menu: Any, section: Int) = emit("topClearButtonTap", "section" to section)`
- L198 `override fun menuDidTapMoreButtonInSection(menu: Any, section: Int) = emit("topRefreshButtonTap", "section" to section)`
- L199 `override fun menuDidChangeContentHeight(menu: Any, height: Float) = reportHeight()`
- L200 `override fun menuDidChangeExpanded(menu: Any, expanded: Boolean, inSection: Int) = reportHeight()`
- L201 `override fun menuDidChangeEditing(menu: Any, editing: Boolean) = reportHeight()`
- L202 `override fun menuDidChangeReordering(menu: Any, reordering: Boolean) = emit("topReorderingChange", "reordering" to reordering)`
- L203 `override fun menuDidChangeSmearing(menu: Any, smearing: Boolean) = emit("topSmearingChange", "smearing" to smearing)`
- L205 `override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int)`
- L210 `override fun requestLayout()`
- L220 `fun reportHeight()`
- L221 `val widthDp = width / resources.displayMetrics.density`
- L224 `val height = kotlin.math.ceil(maxOf(heightThatFitsWidth(widthDp), contentHeight))` — The list's own content height includes a folded inline row that `heightThatFitsWidth` can leave out.

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchTagListViewManager.kt`

The tag list (`CylsearchTagListView` in JavaScript). The titles and ids may arrive in either order: the view gets them together once a batch of props is applied (`onAfterUpdateTransaction`).

- L17 `class CylsearchTagListViewManager : SimpleViewManager<CylsearchTagListView>(),` — The tag list (`CylsearchTagListView` in JavaScript). The titles and ids may arrive in either order: the view gets them together once a batch of props is applied (`onAfterUpdateTransaction`).
- L24 `override fun getDelegate(): ViewManagerDelegate<CylsearchTagListView> = delegate`
- L25 `override fun getName() = NAME`
- L26 `override fun createViewInstance(context: ThemedReactContext) = CylsearchTagListView(context)`
- L29 `override fun setTags(view: CylsearchTagListView, value: ReadableArray?)`
- L34 `override fun setTagIds(view: CylsearchTagListView, value: ReadableArray?)`
- L39 `override fun setSelectedIds(view: CylsearchTagListView, value: ReadableArray?)`
- L44 `override fun setSelectionMode(view: CylsearchTagListView, value: String?) = view.setSelection(value)`
- L47 `override fun setSectionTitle(view: CylsearchTagListView, value: String?)`
- L52 `override fun setShowsClearButton(view: CylsearchTagListView, value: Boolean)`
- L57 `override fun setShowsRefreshButton(view: CylsearchTagListView, value: Boolean)`
- L62 `override fun setBackgroundStyle(view: CylsearchTagListView, value: String?)`
- L67 `override fun setColumns(view: CylsearchTagListView, value: Int)`
- L72 `override fun setTagImages(view: CylsearchTagListView, value: ReadableArray?)`
- L77 `override fun setTagImageLabels(view: CylsearchTagListView, value: ReadableArray?)`
- L82 `override fun setTagSubtitles(view: CylsearchTagListView, value: ReadableArray?)`
- L87 `override fun setTitleMaxLines(view: CylsearchTagListView, value: Int)`
- L92 `override fun setEditing(view: CylsearchTagListView, value: Boolean)`
- L97 `override fun setSupportsRenaming(view: CylsearchTagListView, value: Boolean)`
- L102 `override fun setAllowsSmearSelection(view: CylsearchTagListView, value: Boolean)`
- L107 `override fun setFoldControlPosition(view: CylsearchTagListView, value: String?)`
- L113 `override fun setFoldControlContent(view: CylsearchTagListView, value: String?)`
- L119 `override fun setFoldedRowCount(view: CylsearchTagListView, value: Int)`
- L124 `override fun setColorScheme(view: CylsearchTagListView, value: String?) = Unit`
- L126 `override fun onAfterUpdateTransaction(view: CylsearchTagListView)`
- L129 `val titles = pendingTitles.remove(view.id)`
- L130 `val ids = pendingIds.remove(view.id)`
- L135 `override fun onDropViewInstance(view: CylsearchTagListView)`
- L143 `const val NAME = "CylsearchTagListView"`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchView.kt`

CYLSearchView of the `cylsearch` module, open from the start: JavaScript leaves the screen in `onClose`. It is the core's `resultsDataSource` (the `results` prop) and owns its `refreshHandler` (`onRefresh`).

- L16 `class CylsearchView(private val reactContext: ThemedReactContext) : FrameLayout(reactContext), CYLSearchViewDelegate` — CYLSearchView of the `cylsearch` module, open from the start: JavaScript leaves the screen in `onClose`. It is the core's `resultsDataSource` (the `results` prop) and owns its `refreshHandler` (`onRefresh`).
- L18 `val searchView = CYLSearchView(reactContext)`
- L25 `var foldPosition: String? = null` — The fold control's last position and content names, combined into one control.
- L26 `var foldContent: String? = null`
- L35 `override fun onAttachedToWindow()`
- L40 `fun setCachePolicy(policyName: String?, name: String?) =`
- L43 `fun setStyle(value: String?)`
- L47 `fun setScenario(value: String?)`
- L59 `fun setResults(value: List<String>)` — The `results` prop: reloads the results list when JavaScript sends other results.
- L68 `fun setShowsResults(value: Boolean)` — The `showsResults` prop: the view is the core's data source while results are shown.
- L78 `fun setRefreshEnabled(value: Boolean)` — The `refreshEnabled` prop: the core's `refreshHandler`.
- L93 `fun setRefreshing(value: Boolean)` — The `refreshing` prop: `beginRefreshing` when it turns true, `endRefreshing` when it turns false.
- L117 `override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any)`
- L118 `val text = result as? String ?: return`
- L125 `override fun requestLayout()` — A native view laid out by React Native: measure and lay it out again when its content changes.
- L140 `override fun searchViewTextDidChange(searchView: CYLSearchView, text: String) = emit("topTextChange", "text" to text)`
- L142 `override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean`
- L147 `override fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) =`
- L150 `override fun searchViewDidShow(searchView: CYLSearchView)`
- L155 `override fun searchViewDidClose(searchView: CYLSearchView) = emit("topClose")`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchViewManager.kt`

The search page (`CylsearchView` in JavaScript).

- L16 `class CylsearchViewManager : SimpleViewManager<CylsearchView>(), CylsearchViewManagerInterface<CylsearchView>` — The search page (`CylsearchView` in JavaScript).
- L20 `override fun getDelegate(): ViewManagerDelegate<CylsearchView> = delegate`
- L21 `override fun getName() = NAME`
- L22 `override fun createViewInstance(context: ThemedReactContext) = CylsearchView(context)`
- L25 `override fun setSuggestions(view: CylsearchView, value: ReadableArray?)`
- L30 `override fun setSuggestionStyle(view: CylsearchView, value: String?) = view.setStyle(value)`
- L33 `override fun setPlaceholder(view: CylsearchView, value: String?)`
- L38 `override fun setQuery(view: CylsearchView, value: String?)`
- L43 `override fun setShowsSuggestionsForEmptyQuery(view: CylsearchView, value: Boolean)`
- L48 `override fun setSubmitsOnSuggestionSelection(view: CylsearchView, value: Boolean)`
- L53 `override fun setShowsEmptyResultsPlaceholder(view: CylsearchView, value: Boolean)`
- L58 `override fun setEmptyResultsScenario(view: CylsearchView, value: String?) = view.setScenario(value)`
- L61 `override fun setSuggestionCachePolicy(view: CylsearchView, value: String?)`
- L62 `val current = cachePolicies[view.id]`
- L68 `override fun setSuggestionCacheName(view: CylsearchView, value: String?)`
- L69 `val current = cachePolicies[view.id]`
- L75 `override fun setFocusesSearchFieldOnShow(view: CylsearchView, value: Boolean)`
- L80 `override fun setShowsSuggestionCacheHeader(view: CylsearchView, value: Boolean)`
- L85 `override fun setSuggestionsFoldControlPosition(view: CylsearchView, value: String?)`
- L91 `override fun setSuggestionsFoldControlContent(view: CylsearchView, value: String?)`
- L97 `override fun setSuggestionsFoldedRowCount(view: CylsearchView, value: Int)`
- L102 `override fun setResults(view: CylsearchView, value: ReadableArray?) = view.setResults(value.cylStrings())`
- L105 `override fun setHighlightsResultMatches(view: CylsearchView, value: Boolean) { view.searchView.highlightsResultMatches = value }`
- L108 `override fun setResultMatchHighlightColor(view: CylsearchView, value: String?) { view.searchView.resultMatchHighlightColor = cylParseColor(value) }`
- L111 `override fun setShowsResults(view: CylsearchView, value: Boolean) = view.setShowsResults(value)`
- L114 `override fun setRefreshEnabled(view: CylsearchView, value: Boolean) = view.setRefreshEnabled(value)`
- L117 `override fun setRefreshing(view: CylsearchView, value: Boolean) = view.setRefreshing(value)`
- L123 `override fun setColorScheme(view: CylsearchView, value: String?) = Unit` — The views use the activity's theme (DayNight), which follows the system like React Native's color scheme.
- L125 `override fun onDropViewInstance(view: CylsearchView)`
- L131 `const val NAME = "CylsearchView"`

## `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchViewPackage.kt`

- L9 `class CylsearchViewPackage : BaseReactPackage()`
- L10 `override fun createViewManagers(reactContext: ReactApplicationContext): List<ViewManager<*, *>>`
- L14 `override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? = null`
- L16 `override fun getReactModuleInfoProvider() = ReactModuleInfoProvider { emptyMap() }`

## `CrossPlatform/react-native-cylsearch/eslint.config.mjs`

- L9 `const __filename = fileURLToPath(import.meta.url);`
- L10 `const __dirname = path.dirname(__filename);`
- L11 `const compat = new FlatCompat(`

## `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchResults.h`

- L12 `@interface CYLRNSearchResults : NSObject <CYLSearchViewDataSource>` — The results data source of both components (`CylsearchView` and `CylsearchListView`): the `results` of JavaScript and the rows' text; the match highlight is the core's option (`highlightsResultMatches`, `resultMatchHighlightColor`). A `resultsQuery` lists only

## `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchResults.mm`

- L3 `@implementation CYLRNSearchResults`
- L5 `- (instancetype)init`
- L13 `- (NSArray *)searchView:(CYLSearchView *)searchView resultsForQuery:(NSString *)query`
- L18 `- (void)searchView:(CYLSearchView *)searchView configureResultCell:(UITableViewCell *)cell withResult:(id)result`

## `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchSupport.mm`

- L6 `@interface CYLRNSquareView : UIView` — The square's view: its intrinsic size is the spec's, because the bar sizes the views it holds.
- L10 `@implementation CYLRNSquareView`
- L11 `- (CGSize)intrinsicContentSize`
- L15 `- (CGSize)sizeThatFits:(CGSize)size`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchBarView.h`

- L5 `@interface CylsearchBarView : RCTViewComponentView`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchBarView.mm`

- L11 `@interface CylsearchBarView () <CYLSearchBarViewDelegate, RCTCylsearchBarViewViewProtocol>`
- L18 `@implementation CylsearchBarView` — CYLSearchBarView filling the component; with `editingBar`, the core's editing bar (CYLSearchBarView `editingBarWithPlaceholder:actionTitle:`), whose submit is sent as `onEditingSubmit`.
- L36 `+ (ComponentDescriptorProvider)componentDescriptorProvider`
- L41 `- (instancetype)initWithFrame:(CGRect)frame`
- L53 `- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args`
- L61 `- (void)setActive:(BOOL)active` — The `setActive` command: the field takes the focus (the keyboard rises) or gives it up.
- L73 `- (void)restartItemAnimation:(NSInteger)index` — The `restartItemAnimation` command: plays the animation of the item at `index` again from the start.
- L84 `- (void)goBack` — The `goBack` command (the hardware back key of Android): iOS has none, so it sends `onBackButtonTap` as the navigation bar's back button does.
- L92 `- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps`
- L236 `- (void)applyStyleProps:(CylsearchBarViewProps const &)p` — The style options, members of `CYLSearchBarView`: `appearanceStyle` (the default appearance and the values of `appearanceStyleJSON`), `centersPlaceholder`, the colors, `textFieldMarginsProvider` and `cancelButtonMarginsProvider` (from the margins at rest and w
- L323 `- (nullable UIEdgeInsets (^)(CYLSearchBarView *, BOOL))marginsProviderAtRest:(const std::vector<double> &)rest searching:(const std::vector<double> &)searching` — The margins provider (`textFieldMarginsProvider(bar, active)`) of the margins at rest and while searching; nil for none.
- L340 `- (void)useEditingBar:(BOOL)editing placeholder:(NSString *)placeholder actionTitle:(NSString *)actionTitle` — Swaps in the core's editing bar (or a search bar again): its submit goes to `onEditingSubmit` with the trimmed text, and the field is cleared for the next name.
- L367 `- (void)emitEditingSubmit:(NSString *)text`
- L378 `- (void)applySearches:(NSArray<NSString *> *)searches` — Replaces the native searches ("multiple" mode) without sending remove events back to JavaScript.
- L394 `- (void)prepareForRecycle`
- L411 `- (void)searchBarView:(CYLSearchBarView *)searchBarView didSelectItem:(CYLSearchBarItem *)item`
- L419 `- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text`
- L424 `- (void)searchBarView:(CYLSearchBarView *)searchBarView textDidChange:(NSString *)text atIndex:(NSInteger)index`
- L432 `- (void)emitTextChange:(NSString *)text index:(NSInteger)index` — `onTextChange` with the index of the search being typed, -1 in "single" mode.
- L440 `- (void)searchBarView:(CYLSearchBarView *)searchBarView didCompleteSearch:(NSString *)text atIndex:(NSInteger)index`
- L448 `- (void)searchBarView:(CYLSearchBarView *)searchBarView didRemoveSearchAtIndex:(NSInteger)index`
- L456 `- (void)searchBarView:(CYLSearchBarView *)searchBarView didSelectSearch:(NSString *)text atIndex:(NSInteger)index`
- L464 `- (void)searchBarViewSearchButtonClicked:(CYLSearchBarView *)searchBarView`
- L477 `- (void)searchBarViewDidBeginEditing:(CYLSearchBarView *)searchBarView`
- L482 `- (void)searchBarViewDidEndEditing:(CYLSearchBarView *)searchBarView`
- L490 `- (void)emitActive:(BOOL)active` — `onActiveChange`: the field gained or lost the focus.
- L497 `- (void)searchBarViewCancelButtonClicked:(CYLSearchBarView *)searchBarView`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.h`

- L5 `@interface CylsearchListView : RCTViewComponentView`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.mm`

- L12 `@interface CylsearchListView () <RCTCylsearchListViewViewProtocol, CYLSearchViewDelegate, UITableViewDataSource, UITableViewDelegate>`
- L21 `@implementation CylsearchListView` — The list with a search bar and its search: the rows under a bar, and the core's `CYLSearchView` as the search. A tap on the bar opens it; its suggestion area is the launch area (the history, else `suggestions`, as folded tags with the title and the clear butto
- L34 `+ (ComponentDescriptorProvider)componentDescriptorProvider`
- L39 `- (instancetype)initWithFrame:(CGRect)frame`
- L95 `- (void)dealloc`
- L102 `- (void)handleCommand:(const NSString *)commandName args:(const NSArray *)args`
- L110 `- (void)setActive:(BOOL)active animated:(BOOL)animated` — The `setActive` command (`CYLSearchView.setActive(_:animated:)`).
- L118 `- (void)clearHistory` — The `clearHistory` command: the launch area's clear button.
- L123 `- (void)openSearch`
- L128 `- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps`
- L165 `- (void)updateRows:(NSArray<NSString *> *)rows showsSearchBar:(BOOL)shows hidesInitially:(BOOL)hides` — The rows, the bar above them (`showsSearchBar`) and, once, the scroll that hides it (`hidesSearchBarInitially`).
- L179 `- (void)layoutSubviews`
- L192 `- (void)historyChanged:(NSNotification *)note` — `onHistoryChange` with the newest query (empty after a clear) when the history this search keeps changed: the policy and the name of the notification are the ones of this search's cache.
- L207 `- (void)prepareForRecycle`
- L220 `- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section`
- L225 `- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath`
- L232 `- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath`
- L243 `- (void)searchViewWillShow:(CYLSearchView *)searchView`
- L253 `- (void)searchViewDidShow:(CYLSearchView *)searchView`
- L260 `- (void)searchViewWillClose:(CYLSearchView *)searchView`
- L267 `- (void)searchViewDidClose:(CYLSearchView *)searchView`
- L279 `- (void)searchView:(CYLSearchView *)searchView textDidChange:(NSString *)text` — `onUpdateResults` with the text, for each change (a tapped tag too: the core reports it before the submit).
- L287 `- (BOOL)searchView:(CYLSearchView *)searchView didSubmitText:(NSString *)text`
- L296 `- (void)searchView:(CYLSearchView *)searchView didSelectResult:(id)result`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchPlaceholderView.h`

- L9 `@interface CylsearchPlaceholderView : RCTViewComponentView` — CYLTableViewPlaceHolder's CYLPlaceholderView as a React Native Fabric component (`CylsearchPlaceholderView`).

## `CrossPlatform/react-native-cylsearch/ios/CylsearchPlaceholderView.mm`

- L82 `@implementation CylsearchPlaceholderView` — CYLTableViewPlaceHolder's CYLPlaceholderView in the component: the image of a `CYLPlaceholderStyle` above a text, at its content size, centred.
- L88 `+ (ComponentDescriptorProvider)componentDescriptorProvider`
- L93 `- (instancetype)initWithFrame:(CGRect)frame`
- L102 `- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps`
- L121 `- (void)layoutSubviews`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchTagListView.h`

- L5 `@interface CylsearchTagListView : RCTViewComponentView`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchTagListView.mm`

- L11 `@interface CylsearchTagListView () <CYLMenuDataSource, CYLMenuDelegate>`
- L20 `@implementation CylsearchTagListView` — CollectionViewClassifyMenu's CYLTagListView filling the component, one section of tags from JavaScript: their titles and ids, the selection, the header (title and clear button) and editing mode (crosses, dragging, rename requests), as on Android. It reports th
- L37 `+ (ComponentDescriptorProvider)componentDescriptorProvider`
- L42 `- (instancetype)initWithFrame:(CGRect)frame`
- L83 `- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps`
- L145 `- (NSString *)idAtIndex:(NSInteger)index` — The id of the tag at `index`: its entry in `tagIds`, or its title when no id is given.
- L154 `- (NSString *)titleAtIndex:(NSInteger)index`
- L162 `- (void)applySelection` — Shows `selectedIds` as selected ("multiple" mode only).
- L176 `- (BOOL)respondsToSelector:(SEL)selector`
- L187 `- (NSInteger)numberOfSectionsInMenu`
- L192 `- (NSInteger)menuNumberOfItemsInSection:(NSInteger)section`
- L197 `- (NSString *)menuTitleForSection:(NSInteger)section`
- L202 `- (NSString *)menuTitleForItemAtIndexPath:(NSIndexPath *)indexPath`
- L207 `- (NSString *)menuIdentifierForItemAtIndexPath:(NSIndexPath *)indexPath`
- L212 `- (BOOL)menuShowsClearButtonForSection:(NSInteger)section`
- L218 `- (UIImage *)menuImageForItemAtIndexPath:(NSIndexPath *)indexPath`
- L240 `- (BOOL)menuShowsMoreButtonInSection:(NSInteger)section`
- L245 `- (NSString *)menuAccessibilityLabelForMoreButtonInSection:(NSInteger)section`
- L250 `- (void)menuRenameItemAtIndexPath:(NSIndexPath *)indexPath toTitle:(NSString *)title`
- L255 `- (void)menuRemoveItemAtIndexPath:(NSIndexPath *)indexPath`
- L276 `- (void)menuMoveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath`
- L306 `- (void)menu:(id)menu didChangeReordering:(BOOL)reordering` — A tag drag started or ended (CollectionViewClassifyMenu `-menu:didChangeReordering:`), as Android sends it.
- L317 `- (void)menu:(id)menu didChangeSmearing:(BOOL)smearing` — A smear selection started or ended (CollectionViewClassifyMenu `-menu:didChangeSmearing:`), as Android sends it.
- L325 `- (void)menu:(id)menu didSelectItemAtIndexPath:(NSIndexPath *)indexPath`
- L336 `- (void)menu:(id)menu didDeselectItemAtIndexPath:(NSIndexPath *)indexPath`
- L346 `- (void)menu:(id)menu didChangeContentHeight:(CGFloat)height`
- L351 `- (void)menu:(id)menu didChangeExpanded:(BOOL)expanded inSection:(NSInteger)section`
- L356 `- (void)menu:(id)menu didChangeEditing:(BOOL)editing`
- L363 `- (void)layoutSubviews`
- L369 `- (void)reportHeight`
- L383 `- (void)updateEventEmitter:(EventEmitter::Shared const &)eventEmitter`
- L390 `- (void)emitTagSelectAtIndex:(NSInteger)index identifier:(NSString *)identifier selected:(BOOL)selected`
- L402 `- (void)emitRenameRequestAtIndex:(NSInteger)index title:(NSString *)title`
- L413 `- (void)menu:(id)menu didTapMoreButtonInSection:(NSInteger)section`
- L421 `- (void)emitClearButtonTapInSection:(NSInteger)section`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchView.h`

- L5 `@interface CylsearchView : RCTViewComponentView`

## `CrossPlatform/react-native-cylsearch/ios/CylsearchView.mm`

- L13 `@interface CylsearchView () <CYLSearchViewDelegate>`
- L20 `@implementation CylsearchView` — CYLSearchView, open from the start: React Native leaves the screen in `onClose`. It is the core's `resultsDataSource` (the `results` prop, through the one data source of both components) and owns its `refreshHandler` (`onRefresh`).
- L28 `+ (ComponentDescriptorProvider)componentDescriptorProvider`
- L33 `- (instancetype)initWithFrame:(CGRect)frame`
- L50 `- (void)updateProps:(Props::Shared const &)props oldProps:(Props::Shared const &)oldProps`
- L82 `- (void)updateResults:(NSArray<NSString *> *)results shows:(BOOL)shows` — The `results` and `showsResults` props: the view is the core's data source while results are shown.
- L98 `- (void)updateRefreshEnabled:(BOOL)enabled refreshing:(BOOL)refreshing` — The `refreshEnabled` and `refreshing` props: the core's `refreshHandler`, `beginRefreshing` and `endRefreshing`.
- L124 `- (void)refreshStarted` — The refresh handler: a pull sends `onRefresh`; a refresh started by the `refreshing` prop does not.
- L135 `- (void)didMoveToWindow`
- L144 `- (void)prepareForRecycle`
- L159 `- (void)searchView:(CYLSearchView *)searchView textDidChange:(NSString *)text`
- L167 `- (BOOL)searchView:(CYLSearchView *)searchView didSubmitText:(NSString *)text`
- L176 `- (void)searchView:(CYLSearchView *)searchView didSelectSuggestion:(NSString *)suggestion atIndex:(NSUInteger)index`
- L185 `- (void)searchView:(CYLSearchView *)searchView didSelectResult:(id)result`
- L195 `- (void)searchViewDidClose:(CYLSearchView *)searchView`

## `CrossPlatform/react-native-cylsearch/src/CylsearchBarViewNativeComponent.ts`

- L10 `type TextEvent = Readonly<`
- L14 `type IndexedTextEvent = Readonly<`
- L19 `type IndexEvent = Readonly<`
- L23 `type CancelEvent = Readonly<{}>;`
- L25 `type ItemSelectEvent = Readonly<`
- L30 `type ActiveEvent = Readonly<`
- L34 `type BackButtonEvent = Readonly<`
- L38 `export interface NativeProps extends ViewProps`
- L245 `interface NativeCommands`
- L266 `export const Commands = codegenNativeCommands<NativeCommands>(`

## `CrossPlatform/react-native-cylsearch/src/CylsearchListViewNativeComponent.ts`

- L10 `type TextEvent = Readonly<`
- L14 `type PresentationEvent = Readonly<{}>;`
- L16 `type HistoryEvent = Readonly<`
- L20 `type RowSelectEvent = Readonly<`
- L25 `type ResultSelectEvent = Readonly<`
- L30 `export interface NativeProps extends ViewProps`
- L131 `interface NativeCommands`
- L146 `export const Commands = codegenNativeCommands<NativeCommands>(`

## `CrossPlatform/react-native-cylsearch/src/CylsearchPlaceholderViewNativeComponent.ts`

- L7 `export interface NativeProps extends ViewProps`

## `CrossPlatform/react-native-cylsearch/src/CYLSearchProps.ts`

One field (`single`, the default) or several searches side by side (`multiple`): iOS and Android `CYLSearchBarMode`.

- L4 `export type CYLSearchBarMode = 'single' | 'multiple';` — One field (`single`, the default) or several searches side by side (`multiple`): iOS and Android `CYLSearchBarMode`.
- L10 `export type CYLSearchBarItem =` — One element after the text of a search bar (iOS and Android `CYLSearchBarItem`, like the FlatDesign tab bar's items). The field stays; the bar only appends items.
- L64 `export function cylSearchBarItemsJSON(` — The items as the JSON the native bar reads (`CYLSearchBarItem itemWithDictionary:` / `fromMap`), without handlers.
- L74 `export function cylSearchBarSelectedItem(` — The tapped item for a native `onItemSelect` event, after calling its own `onPress`; undefined for an unknown index.
- L87 `export function cylSearchViewShowsResults(` — Whether the search page lists results: the explicit `showsResults`, else whether `results` is given.
- L98 `export function cylSearchViewSuggestionStyle(` — The suggestion style `CYLSearchView` sends to the core: `"tags"` (folded, the fold control as the last tag) unless the app asks for `"list"`, as the core's default.
- L107 `export type CYLEdgeInsets =` — Margins in points (iOS) or dp (Android): `UIEdgeInsets` order.
- L117 `export function cylInsetsArray(insets: CYLEdgeInsets | undefined): number[]` — The margins as the native [top, left, bottom, right] array; undefined sends none.
- L127 `export type CYLSearchBarAccessory =` — A view beside the field (`leadingAccessoryView` / `trailingAccessoryView`): a rounded square with a stroke, drawn by the core's wrapper (QDSearchBarViewController's 30 x 30 accessory).
- L140 `export function cylAccessoryJSON(` — The accessory as the JSON the native bar reads; "" for none.
- L149 `export type CYLSearchBarAppearance =` — `CYLSearchBarAppearance`: the values that are set replace the default style's (colors "#RRGGBB" or "#AARRGGBB").
- L163 `export type CYLFont =` — The font of Cancel's title (`cancelButtonFont`): a size in points / sp and a weight.
- L171 `export function cylFontJSON(font: CYLFont | undefined): string` — The font as the JSON the native bar reads; "" for none.
- L178 `export function cylAccessoriesJSON(` — The views after the text as the JSON array the native bar reads; "" for none.
- L191 `export function cylAppearanceJSON(` — The appearance as the JSON the native bar reads; "" for none.
- L202 `export function cylSplitMatch(` — The text split around the first match of `query`, case and diacritic insensitive like the core's `highlightsResultMatches` (`range(of:options: [.caseInsensitive, .diacriticInsensitive])`): `match` is the text of the result as written, not the query. No match, 
- L239 `export function cylResultsForQuery<T>(` — The results of a text for a list that stands for `resultsQuery`: results of another text are not shown (a late answer never fills the list of a newer text), as the native list does.
- L253 `export function cylBarForwards(props:` — The native values of a bar's accessory, font and appearance props: the iOS names (`leadingView`, `trailingAccessoryViews`, `showsLeadingView`, `showsTrailingAccessoryViews`, `appearanceStyle`) win over the names of the first QMUI port (`leadingAccessory`, `tra
- L290 `export function cylListForwards<Handler>(props:` — The native values of a list's props that were renamed for the iOS names: `noResultsText` (was `emptyViewText`), `scrimColor` (`dimmingColor`), `suggestions` (`launchSuggestions`), `suggestionCachePolicy` (`historyPolicy`) and `suggestionCacheName` (`historyNam
- L324 `export const CYL_TAG_TITLE_SINGLE_LINE = 1;` — `titleMaxLines` of a tag list: one line, the default; a title too wide for its tag is truncated.
- L327 `export const CYL_TAG_TITLE_UNLIMITED = 0;` — `titleMaxLines` of a tag list: no limit, a title wraps onto as many lines as it needs.
- L333 `export function cylTagSubtitles(` — The `tagSubtitles` of a tag list for `count` tags: one entry per tag, "" where a tag has no subtitle, so a list shorter or longer than the tags never misaligns the callouts.

## `CrossPlatform/react-native-cylsearch/src/CylsearchTagListViewNativeComponent.ts`

- L8 `type TagSelectEvent = Readonly<`
- L21 `type ReorderingChangeEvent = Readonly<`
- L29 `type SmearingChangeEvent = Readonly<`
- L36 `type HeightChangeEvent = Readonly<`
- L40 `type TagEvent = Readonly<`
- L45 `type TagMoveEvent = Readonly<`
- L50 `type RenameRequestEvent = Readonly<`
- L56 `type EmptyEvent = Readonly<`
- L60 `export interface NativeProps extends ViewProps`

## `CrossPlatform/react-native-cylsearch/src/CylsearchViewNativeComponent.ts`

- L8 `type TextEvent = Readonly<`
- L12 `type SuggestionSelectEvent = Readonly<`
- L17 `type CloseEvent = Readonly<{}>;`
- L19 `type ResultSelectEvent = Readonly<`
- L24 `type RefreshEvent = Readonly<{}>;`
- L26 `export interface NativeProps extends ViewProps`

## `CrossPlatform/react-native-cylsearch/src/index.tsx`

- L71 `export type SearchViewProps = NativeSearchViewProps;` — The search page's props: the native props, `showsResults` defaulting to whether `results` is given.
- L76 `export type SearchBarProps = Omit<` — The search bar's props: the native props, with `items` in place of their JSON.
- L175 `export function CYLSearchView(` — The search page of CYLSearchViewController (iOS `CYLSearchView`, Android `CYLSearchView`): its search bar at the top, the suggestions (a list or tags, the cached queries first), the `results` of the current query with pull-to-refresh (`refreshEnabled`, `onRefr
- L196 `export function CYLSearchBarView(` — The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`): the field, then the appended `items`, or several searches side by side with `mode="multiple"` (`searches`, `onCompleteSearch`, `onRemoveSearch`, `onSelectSearch`). Give it a height
- L263 `export function CYLTagListView(` — CollectionViewClassifyMenu's tag list (the view of the tag style): it takes the height its tags need, folded to two rows behind a chevron by default.
- L287 `export function CYLPlaceholderView(props: PlaceholderProps & ViewProps)` — CYLTableViewPlaceHolder's placeholder (`CYLPlaceholderView`): the image of `placeholderStyle` ("empty", "noResults", "personOff", …) above `text`, at its content size (give it a height or let flex size it).
- L299 `export type CYLSearchBarHandle =` — What a `CYLSearchBarView` ref offers.
- L318 `export function cylSearchBarHandle<T>(` — The `CYLSearchBarHandle` of a bar: every method sends its command to the native bar, once that exists. `commands` are the bar's native commands (`Commands` of `CylsearchBarViewNativeComponent`).
- L345 `export type CYLSearchListHandle =` — What a `CYLSearchListView` ref offers.
- L360 `export type SearchListProps = NativeListProps &` — The props of the list with a search bar: the native props, with `ref`, and the names of the first QMUI port, which forward to the iOS names.
- L400 `export function CYLSearchListView(` — The list of CYLSearchViewController whose first item is the search bar (iOS: a table under a `CYLSearchBarView` that opens the core's `CYLSearchView`; Android: `CYLSearchListView`) with its search: the `rows`, the `results` of the text (answer `onUpdateResults
