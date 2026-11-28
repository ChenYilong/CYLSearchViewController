> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

<!-- 02-android-core: part 2 of 2 -->
_Part 2 of 2. Previous: [part 1](02-android-core.md)._

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchResources.kt`

Images and localized strings of this library (iOS `CYLSearchResources`, the `CYLSearchViewController.bundle`). The iOS bundle is imported by `scripts/import-ios-resources.py`: `CYLSearchNoResults` becomes the drawable `cyl_search_no_results`, the key `search.cancel` the string `cyl_search_cancel`.

- L21 `object CYLSearchResources` — Images and localized strings of this library (iOS `CYLSearchResources`, the `CYLSearchViewController.bundle`). The iOS bundle is imported by `scripts/import-ios-resources.py`: `CYLSearchNoResults` becomes the drawable `cyl_search_no_results`, the key `search.c
- L30 `fun resourceBundle(context: Context): Resources = context.resources` — The resources that hold the images and strings (iOS `resourceBundle`): the app's resources, which include this library's.
- L38 `fun observeHistoryDidChange(cache: CYLSearchSuggestionCache, listener: () -> Unit): () -> Unit =` — Calls `listener` after the history of `cache` changed (iOS `historyDidChangeNotification`): a query was added or removed, or the history cleared, whoever changed it. The same policy and name is the same history, so a screen sees the changes of another one. Ret
- L45 `fun imageNamed(context: Context, name: String): Drawable?` — An image of this library by its iOS name ("CYLSearchNoResults"), or null (logged) when it is missing.
- L59 `fun localizedString(context: Context, key: String): String = localizedString(context, key, null)` — The text of `key` in the language the app shows, English when the key has no translation, or the key itself (logged) when it is missing everywhere.
- L66 `fun localizedString(context: Context, key: String, language: String?): String` — The text of `key` in `language` (for example "zh-Hans"), or in the app's language when `language` is null or empty.
- L88 `enum class CYLSearchSuggestionCachePolicy` — Where the suggestion cache keeps the submitted queries (iOS `CYLSearchSuggestionCachePolicy`). More policies can be added later; an app can also plug in its own store through [CYLSearchSuggestionCache].
- L113 `interface CYLSearchSuggestionCache` — A store of submitted queries, newest first (iOS `CYLSearchSuggestionCache`).
- L117 `fun cachedQueries(): List<String>` — The cached queries, newest first.
- L122 `fun addQuery(query: String)` — Adds `query` at the front; an equal query already cached moves to the front instead of being repeated.
- L127 `fun removeQuery(query: String)` — Removes `query`.
- L132 `fun removeAllQueries()` — Removes every cached query.
- L144 `val name: String = name.ifEmpty { "CYLSearchView" }` — Separates the caches of different search screens: the database key, the preferences key or the file name.
- L149 `var maximumCount = 20` — The largest number of queries kept; the oldest go first. 20 by default.
- L155 `override fun cachedQueries(): List<String> = when (policy)`
- L163 `override fun addQuery(query: String)`
- L170 `override fun removeQuery(query: String)`
- L175 `override fun removeAllQueries()`
- L239 `override fun onCreate(db: SQLiteDatabase)`
- L243 `override fun onUpgrade(db: SQLiteDatabase, oldVersion: Int, newVersion: Int) = Unit`
- L263 `fun cacheWithPolicy(context: Context, policy: CYLSearchSuggestionCachePolicy, name: String): CYLSearchSuggestionStore? =` — The store for `policy` and `name`; null for [CYLSearchSuggestionCachePolicy.None] (iOS `+cacheWithPolicy:name:`).
- L283 `fun observe(cache: CYLSearchSuggestionCache, listener: () -> Unit): () -> Unit` — Calls `listener` whenever the history of `cache` changes; returns the function that stops it.
- L292 `fun post(cache: CYLSearchSuggestionCache)` — Tells the observers of the history of `cache` that it changed.

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchResultsComponent.kt`

The one holder of an empty view (iOS `CYLSearchEmptyViewSlot`): the placeholders of `CYLSearchView` (`emptyResultsView`, `emptySuggestionsView`, the view of `showEmptyView`) and of `CYLSearchListView` are all kept, shown and removed here. `index` is where it goes in `host`, -1 for the top; `bottomPadding` is the part of the host the keyboard covers, so the placeholder is centred in what stays visi

- L25 `var view: CYLPlaceholderStackView? = null` — The placeholder that the slot holds, or null.
- L31 `fun adopt(newView: CYLPlaceholderStackView, background: Int? = null)` — Puts `newView` in the host in place of the held one.
- L42 `fun setShowing(showing: Boolean, create: () -> CYLPlaceholderStackView)` — Shows or hides the held placeholder, made by `create` the first time it is shown.
- L52 `fun refreshPadding()` — Reads the keyboard's part of the host again.
- L59 `fun remove()` — Takes the placeholder out of the host.
- L75 `fun fold(text: String): String =` — `text` in lower case and without diacritics (the rule of the suggestion filter and of the highlight).
- L82 `fun firstMatch(text: CharSequence, query: String): IntRange?` — The range of the first match of the trimmed `query` in `text`, in the characters of `text`; null for no match or an empty query.
- L115 `fun apply(label: TextView, query: String, color: Int)` — Gives the first match of `query` in the text of `label` `color`, keeping the spans the text already has.

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchTagListHeader.kt`

The built-in look of a tag list section header (docs/animated-icon-component.md, "Refresh, hot data and navigation bar contract", A): the refresh action is an icon, never the three dots of ClassifyMenu's More button and never text. The icon is a resource of this library (`cyl_search_ic_refresh`, the Material "refresh" icon) and its label is localized (`cyl_search_tagList_refresh`: Refresh, 更新, 刷新,

- L17 `object CYLSearchTagListHeader` — The built-in look of a tag list section header (docs/animated-icon-component.md, "Refresh, hot data and navigation bar contract", A): the refresh action is an icon, never the three dots of ClassifyMenu's More button and never text. The icon is a resource of th
- L23 `fun refreshImage(context: Context): Drawable? = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_refresh)` — The refresh icon, the Material "refresh" icon of this library (iOS `refreshImage`, the SF Symbol "arrow.clockwise").
- L30 `fun applyRefreshIcon(context: Context, style: CYLMenuStyle)` — Puts the refresh icon on the More button of the header of `style` (`CYLMenuStyle.moreButtonImage`). The data source still decides which sections show the button (`menuShowsMoreButtonInSection`).
- L39 `fun applyRefreshIcon(list: CYLTagListView)` — Sets the refresh icon as the icon of `list`'s header More button, in place of the three dots (iOS `applyRefreshIcon(to:)`); the list's other style values stay.
- L49 `fun refreshLabel(context: Context): String = context.getString(R.string.cyl_search_tagList_refresh)` — The localized accessibility label of the refresh icon, for `menuAccessibilityLabelForMoreButtonInSection`.

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchTagListStyle.kt`

The search bar core's default style of a tag list, the look of the iOS example's recent searches and discover topics: capsule tags with a light border, a bold section header, one 16 dp inset (docs/animated-icon-component.md, "Default layout contract"). It is set here, in the search bar core, through the public API of ClassifyMenu's `CYLMenuStyle`; the tag list itself is not changed. The Flutter an

- L22 `object CYLSearchTagListStyle` — The search bar core's default style of a tag list, the look of the iOS example's recent searches and discover topics: capsule tags with a light border, a bold section header, one 16 dp inset (docs/animated-icon-component.md, "Default layout contract"). It is s
- L29 `const val CAPSULE_CORNER_RADIUS: Float = 1000f` — The corner radius of a capsule: the corners are as round as the tag's height allows (ClassifyMenu limits a radius to half the height). The one named constant for it: pass it, never the literal 1000. 0 is square corners; no other value has a special meaning.
- L32 `const val TAG_CONTENT_HORIZONTAL_INSET: Float = 14f` — The default horizontal inner inset of a tag, in dp (the iOS 14 of a drawn Liquid Glass tag), on the list and the grid style.
- L58 `var tagCornerRadius: Float = CAPSULE_CORNER_RADIUS` — The corner radius of every tag, in dp. The default `CAPSULE_CORNER_RADIUS` is a capsule, as in the iOS example's recent searches; 0 is square corners; another value is a rounded rectangle.
- L64 `var styleCustomizer: ((CYLMenuStyle) -> Unit)? = null` — Called with the style after the defaults are set, to change any value of it. null by default.
- L71 `var tagBackgroundStyle: CYLTagBackgroundStyle = CYLTagBackgroundStyle.CYLTagBackgroundStyleFlat` — The background of every tag, handed to CollectionViewClassifyMenu's `CYLMenuStyle.backgroundStyle`: flat by default (the tag's own colors), Liquid Glass for the glass background (flat below Android 12; iOS `tagBackgroundStyle`).
- L87 `fun applyDefaults(style: CYLMenuStyle, context: Context? = null)` — Sets the defaults on `style`: white tags with a 1 dp light border and `tagCornerRadius`, 17 sp text, 36 dp high, 12 dp apart, a 16 dp section inset and a bold 20 sp section header, then calls `styleCustomizer`. Values the defaults do not name (for example a tr
- L126 `fun applyDefaultStyle(list: CYLTagListView)` — Sets the defaults on `list`'s style (a copy, so the list's other values stay), and the refresh icon of its header (`CYLSearchTagListHeader`; iOS `applyDefaultStyle(to:)`).
- L140 `fun applyBackgroundStyle(name: String, list: CYLTagListView)` — Sets the background of every tag of `list` by name (iOS `applyBackgroundStyle(named:to:)`): "liquidGlass" (any case) is Liquid Glass, any other name, "" and "flat" too, is flat. Where the device draws no glass (below Android 12, `CYLMenuStyle.resolvedBackgroun
- L149 `fun applyBackgroundStyle(name: String, style: CYLMenuStyle)` — `applyBackgroundStyle(name, list)` on a style: the background style by name and, for glass, the glass fills.
- L166 `fun backgroundStyleNamed(name: String): CYLTagBackgroundStyle =` — The background style for `name`: Liquid Glass for "liquidGlass" (any case), flat for any other name.
- L177 `fun applyGrid(style: CYLMenuStyle, context: Context? = null)` — Turns `style` (made by `CYLMenuStyle.gridStyleWithNumberOfItemsPerRow(columns)`) into the discover topics' look: 17 sp medium titles, 36 dp rows 16 dp apart, a tag's own image at its own size, and the section header of `applyDefaults`; then calls `styleCustomi

## `android/merged/cylsearch/src/main/kotlin/com/cyl/search/CYLSearchView.kt`

- L53 `enum class CYLLineBreakMode` — How a long suggestion is cut (iOS `NSLineBreakMode`).
- L88 `enum class CYLSearchSuggestionStyle` — How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`).
- L105 `interface CYLSearchViewDelegate` — Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button. Every method is optional.
- L110 `fun searchViewDidShow(searchView: CYLSearchView) {}` — The search view finished opening (MaterialSearchView `onSearchViewShown`).
- L115 `fun searchViewDidClose(searchView: CYLSearchView) {}` — The search view finished closing (MaterialSearchView `onSearchViewClosed`).
- L120 `fun searchViewWillShow(searchView: CYLSearchView) {}` — The search view is about to open (iOS `willPresentSearchController`).
- L125 `fun searchViewWillClose(searchView: CYLSearchView) {}` — The search view is about to close (iOS `willDismissSearchController`).
- L131 `fun searchViewUpdateResults(searchView: CYLSearchView, searchString: String) {}` — Update the results for `searchString`: called on every text change, also with "" (the first opening, all text deleted, the clear button, the close with `clearsQueryOnClose`), as UIKit does (iOS `updateResultsFor`).
- L136 `fun searchViewWillShowEmptyView(searchView: CYLSearchView, emptyView: View) {}` — `showEmptyView` is about to put its placeholder under the bar (QMUI `willShowEmptyView`).
- L142 `fun searchViewDidLoadResultsTableView(searchView: CYLSearchView, tableView: RecyclerView) {}` — Called once, before the first opening or results, when `resultsTableView` is ready to be configured: set its layout manager, decorations or an adapter wrapper here (iOS `searchController(_:didLoadSearchResultsTableView:)`).
- L147 `fun searchViewTextDidChange(searchView: CYLSearchView, text: String) {}` — The query changed (`onQueryTextChange`).
- L153 `fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean = false` — The query was submitted (`onQueryTextSubmit`). Return true when you handled it and the search view stays open; return false (the default) to let the search view close.
- L158 `fun searchViewDidChangeFocus(searchView: CYLSearchView, focused: Boolean) {}` — The field started or stopped editing (lapism `OnFocusChangeListener`).
- L164 `fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int) {}` — A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is submitted when `submitsOnSuggestionSelection` is true.
- L169 `fun searchViewVoiceButtonClicked(searchView: CYLSearchView) {}` — The voice button was tapped. Start speech recognition and pass the result to `setQuery(query, submit)`.
- L174 `fun searchViewNavigationButtonClicked(searchView: CYLSearchView)` — The navigation button (the back arrow by default) was tapped. By default it closes the search view.
- L181 `fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any) {}` — A result of `resultsDataSource` was tapped in `resultsTableView`.
- L188 `interface CYLSearchViewDataSource` — Supplies the results a `CYLSearchView` lists in `resultsTableView` and configures their cells (was `CYLSearchResultsDataSource`).
- L194 `fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any>` — The results for `query`, the current text of the search bar (never blank: a blank query shows the suggestions).
- L199 `fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any)` — Shows `result` in `cell`, a row of `resultsTableView` (its icon is hidden by default).
- L206 `class CYLSearchSuggestionCell(context: Context) : LinearLayout(context)` — A suggestion row of a `CYLSearchView`: an icon and a text (iOS `UITableViewCell` with a list content configuration).
- L211 `val imageView: ImageView = ImageView(context)` — The icon before the text (`suggestionImage`).
- L216 `val textLabel: TextView = TextView(context)` — The suggestion text.
- L246 `class CYLSearchView @JvmOverloads constructor(` — A search page that opens over its host view (iOS `CYLSearchView`; MiguelCatalan and lapism `MaterialSearchView`): a `CYLSearchBarView` below the status bar, a divider, a list of suggestions filtered as you type, the results of `resultsDataSource` in `resultsTa
- L271 `override fun handleOnBackPressed()`
- L279 `override fun handleOnBackStarted(backEvent: BackEventCompat)`
- L283 `override fun handleOnBackProgressed(backEvent: BackEventCompat)`
- L290 `override fun handleOnBackCancelled()`
- L298 `var delegate: CYLSearchViewDelegate? = null` — Receives the events of the search view.
- L303 `val searchBarView: CYLSearchBarView = CYLSearchBarView(context)` — The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button).
- L308 `val dividerView: View = View(context)` — The line under the search bar.
- L313 `val suggestionsTableView: RecyclerView = RecyclerView(context)` — The list of suggestions (iOS `suggestionsTableView`).
- L319 `val suggestionsTagView: CYLTagListView = CYLTagListView(context)` — The tags that show the suggestions when `suggestionStyle` is `Tags` (CollectionViewClassifyMenu's `CYLTagListView`). Style it directly: colors (`colorTheme`), spacing, rows, the tag style.
- L326 `var suggestionsFoldControl: CYLMenuFoldControl` — The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`; iOS `suggestionsFoldControl`). An inline chevron as the last tag by default: tap it to show every row, again to fold. Position `None` shows every tag without a control.
- L336 `var suggestionsFoldedRowCount: Int` — The rows of tag suggestions shown while folded (iOS `suggestionsFoldedRowCount`). 2 by default; 0 shows every row.
- L347 `var suggestionStyle: CYLSearchSuggestionStyle = CYLSearchSuggestionStyle.Tags` — How the suggestions are shown: tags (`Tags`, the default, folded to `suggestionsFoldedRowCount` rows with the fold control as the last tag) or a list (`List`).
- L357 `var showsEmptyResultsPlaceholder: Boolean = false` — Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty query matches no suggestion, in both suggestion styles. False by default.
- L367 `var emptyResultsScenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoSearchResults` — The CYLTableViewPlaceHolder scenario of that placeholder. `NoSearchResults` (an icon, a title and a hint) by default; `NoContent` shows the plain empty state.
- L378 `val emptyResultsView: CYLPlaceholderStackView?` — The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first time it is shown; null before.
- L391 `var suggestionCachePolicy: CYLSearchSuggestionCachePolicy = CYLSearchSuggestionCachePolicy.Database` — Where submitted queries are cached for the suggestion list (iOS `suggestionCachePolicy`): `Database`, a local SQLite database, by default. While the query is empty the list shows the cached queries, newest first, under a header whose delete button clears them;
- L400 `var suggestionCacheName: String = "CYLSearchView"` — Separates the caches of different search screens. "CYLSearchView" by default.
- L410 `var suggestionCache: CYLSearchSuggestionCache? =` — The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy). Null when the policy is `None`.
- L423 `val suggestionCacheHeaderView = LinearLayout(context)` — The header above the cached queries: a title and, at its end, `clearSuggestionCacheButton`.
- L428 `val suggestionCacheTitleLabel = TextView(context)` — The title of `suggestionCacheHeaderView` ("Recent searches").
- L433 `val clearSuggestionCacheButton = ImageButton(context)` — Clears the whole cache (a delete icon at the top right of the suggestion list).
- L439 `var showsEmptySuggestionsPlaceholder = true` — Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache holds nothing. True by default.
- L448 `var emptySuggestionsScenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoContent` — The scenario of that placeholder. `NoContent` by default.
- L458 `val emptySuggestionsView: CYLPlaceholderStackView?` — The placeholder shown for an empty cache, created the first time it is shown; null before.
- L466 `var focusesSearchFieldOnShow = true` — Focuses the search field when the search opens, which raises the keyboard (iOS `focusesSearchFieldOnShow`). True by default. False opens the search with the suggestion list (or the empty placeholder) and the keyboard down; the field is focused when the person 
- L473 `var showsSuggestionCacheHeader = true` — Shows `suggestionCacheHeaderView` (the title and `clearSuggestionCacheButton`) above the cached queries (iOS `showsSuggestionCacheHeader`). True by default. False takes the header away, for a host that clears the history with its own control that calls `clearS
- L486 `var dividerColor: Int? = null` — The color of `dividerView` (lapism `setDividerColor`). The theme's divider color when null; transparent hides it.
- L496 `var contentView: View? = null` — A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history, anything. Null by default.
- L512 `var scrimColor: Int? = null` — The color behind the page while it is open (lapism `setScrimColor`). Null (none) by default: the page fills the view. With a scrim and no content view, the page is only as tall as the suggestions and the scrim (tapping it closes the search) shows below.
- L521 `var pageBackgroundColor: Int? = null` — The page background. The theme's window background when null.
- L532 `var suggestions: List<String> = emptyList()` — The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`).
- L542 `var suggestionFilter: ((String, String) -> Boolean)? = null` — Decides whether a suggestion matches the query: `(suggestion, query) -> Boolean`. Null uses a case- and diacritic-insensitive "contains" test. An empty query matches nothing unless `showsSuggestionsForEmptyQuery`.
- L551 `var showsSuggestionsForEmptyQuery: Boolean = false` — Lists every suggestion while the query is empty. False by default.
- L560 `var filteredSuggestions: List<String> = emptyList()` — The suggestions that match the current query, in their original order.
- L567 `var suggestionImage: Drawable? = ContextCompat.getDrawable(context, R.drawable.cyl_search_ic_search)` — The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). A magnifier by default; null shows none.
- L576 `var suggestionImageTintColor: Int? = null` — The tint of `suggestionImage`. The theme's secondary text color when null.
- L585 `var suggestionBackgroundColor: Int? = null` — The background of the suggestion rows (`setSuggestionBackground`). Null keeps the page background.
- L595 `var suggestionTextColor: Int? = null` — The color of the suggestion text. The theme's primary text color when null.
- L605 `var suggestionLineBreakMode: CYLLineBreakMode = CYLLineBreakMode.WordWrapping` — How a long suggestion is cut (MaterialSearchView `setEllipsize`). `WordWrapping` by default (whole text on several lines); `TruncatingTail` keeps one line with an ellipsis.
- L615 `var submitsOnSuggestionSelection: Boolean = false` — Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). False by default: the field shows it and the person can edit it.
- L620 `var suggestionCellConfiguration: ((CYLSearchSuggestionCell, String, Int) -> Unit)? = null` — Configures each suggestion cell after the defaults (a custom adapter's `getView`): `(cell, suggestion, index)`.
- L633 `var resultsDataSource: CYLSearchViewDataSource? = null` — Supplies the results (was `CYLSearchController(searchDataSource:)` and `searchDataSource`). While it is set and the query is not blank, `resultsTableView` lists its results below the bar instead of the suggestions; null (the default) keeps the suggestions only
- L643 `val resultsTableView: RecyclerView = RecyclerView(context)` — The list of results (was the results controller's `tableView`). Style it directly; its rows are `CYLSearchSuggestionCell`s configured by `resultsDataSource`.
- L648 `var searchResults: List<Any> = emptyList()` — The results of the current query, as `resultsDataSource` returned them; empty while the query is blank.
- L655 `fun reloadResults() = refilter()` — Queries `resultsDataSource` again for the current query and reloads `resultsTableView` (was `reloadSearchResults()` and `reloadResultsTableView()`).
- L664 `var refreshHandler: (() -> Unit)?` — Non-null adds pull-to-refresh to `resultsTableView` (CYLTableViewPlaceHolder's `CYLRefreshNormalHeader`); null removes it. Call `endRefreshing()` on every completion path, and do not capture the screen that owns the search view strongly.
- L673 `val isRefreshing: Boolean` — True while `resultsTableView` shows its refresh indicator.
- L679 `fun beginRefreshing() = resultsRefreshLayout.beginHeaderRefreshing()` — Shows the refresh indicator of `resultsTableView` and calls `refreshHandler`, like a pull.
- L684 `fun endRefreshing() = resultsRefreshLayout.endHeaderRefreshing()` — Hides the refresh indicator of `resultsTableView`.
- L691 `var isSearchOpen: Boolean = false` — True while the search view is open (MaterialSearchView `isSearchOpen`).
- L697 `var animationDuration: Double = 0.25` — The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default.
- L704 `var launchView: View? = null` — A view of yours under the search bar while the query is empty (QMUI `launchView`): recent searches, hot topics. It fills the space under the bar, replaces the cached-query list and the empty placeholders while it shows, and is hidden as soon as the person type
- L724 `var dimmingColor: Int?` — The same overlay as `scrimColor` (QMUI `dimmingColor`): one view dims the host below the page for the whole time the search is open, and a tap on it ends the search.
- L736 `var highlightsResultMatches: Boolean = false` — Gives the first match of the query in the text of each result row `resultMatchHighlightColor` (the tint color by default), after `searchViewConfigureResultCell` configured the row (iOS `highlightsResultMatches`). The match ignores case and diacritics, like the
- L745 `var resultMatchHighlightColor: Int? = null` — The color of the highlighted match (iOS `resultMatchHighlightColor`). Null uses the tint color of the bar.
- L757 `var noResultsText: String? = null` — The text of the "no results" empty view that the search view manages itself (iOS `noResultsText`): after each update of the results it shows the empty view with this text while the query is not empty and nothing is listed, and hides it otherwise. Null (the def
- L767 `var clearsQueryOnClose: Boolean = false` — Clears the query when the search view closes and reports the empty text to `searchViewUpdateResults`, as `UISearchController` does when Cancel is tapped. False by default.
- L774 `var supportsSwipeToDismissSearch: Boolean = false` — Lets the back swipe (predictive back, API 34 and later with `android:enableOnBackInvokedCallback`) drag the page sideways and ends the search when it is completed (QMUI `supportsSwipeToDismissSearch`); cancelling it springs the page back. The back key and the 
- L792 `var showsSuggestionsLaunchView: Boolean = false` — Whether the built-in launch view is the launch view: the suggestion area (the tags folded to `suggestionsFoldedRowCount` rows with the fold control as the last tag, and, over the submitted queries of `suggestionCache`, the title "Recent searches" with its clea
- L814 `var hidesNavigationBarDuringPresentation: Boolean = true` — Whether the activity's action bar is hidden while the search is open (iOS `hidesNavigationBarDuringPresentation`); it comes back when the search closes. True by default; only an `AppCompatActivity`'s action bar is touched.
- L821 `var alwaysShowsSearchResultsController: Boolean = false` — Whether the results are listed even while the query is empty (iOS `alwaysShowsSearchResultsController`). Turning it on clears `launchView` and `showsSuggestionsLaunchView`; `searchViewResultsForQuery` is then also called with an empty query.
- L835 `var prefersStatusBarHiddenProvider: (() -> Boolean)? = null` — Returns whether the status bar is hidden while the search is open (iOS `prefersStatusBarHiddenProvider`); null (the default) leaves the status bar alone. Read each time the search opens.
- L842 `var preferredStatusBarStyleProvider: (() -> Boolean)? = null` — Returns whether the status bar icons are dark while the search is open, for a light status bar background (iOS `preferredStatusBarStyleProvider`, `darkContent`); null (the default) leaves them alone. Read each time the search opens; the previous style comes ba
- L849 `var snapsHeaderSearchBar: Boolean = true` — Whether a header search bar of `installSearchBar` is kept scrollable out of sight, even above a short list, and settles fully shown or fully hidden when scrolling ends (iOS `snapsHeaderSearchBar`, QMUI issues #1160 and #1207). True by default; false takes the 
- L860 `var resultsHeaderTitleProvider: ((String) -> String?)? = null` — Titles the results: while results show, a header above the first row says what this function returns for the query (a footnote in `resultsHeaderTextColor`, a heading for TalkBack); null from the function, or no function (the default), shows none.
- L869 `var resultsHeaderTextColor: Int? = null` — The color of the results header text. Null (the default) is the theme's secondary text color.
- L880 `var suggestionCacheFooterTitle: String? = null` — A text button under the cached queries and the suggestions of the list style that clears the cache, with this title (a bordered footnote button centered below the last row). Null (the default) shows none; with it, set `showsSuggestionCacheHeader` to false to h
- L892 `fun installSearchBar(recyclerView: RecyclerView): CYLSearchBarView` — Makes this search view the search of `recyclerView`: a search bar becomes the first item of its list (iOS `installSearchBar(asHeaderOf:)`), `usedAsTableHeaderView` is true, and a tap on it opens this search view. Call it after the list's adapter is set; with `
- L907 `val header = object : RecyclerView.Adapter<RecyclerView.ViewHolder>()`
- L930 `fun setSnapsHeader(snaps: Boolean, header: View, recyclerView: RecyclerView)` — Keeps `header`, the first item of `recyclerView` (a search bar), scrollable out of sight above a short list and settles it fully shown or fully hidden when scrolling ends, while this search view is not open (iOS `setSnapsHeader(_:for:in:)`, QMUI issues #1160 a
- L1014 `val isActive: Boolean` — True while the search view is open (iOS `isActive`); the same as `isSearchOpen`.
- L1020 `fun setActive(active: Boolean, animated: Boolean)` — Opens or closes the search view (iOS `setActive(_:animated:)`): `showSearch` and `closeSearch`.
- L1027 `val searchBarMaxY: Int` — The bottom edge of the search bar in this view, in pixels (iOS `searchBarMaxY`): the content starts here.
- L1037 `val emptyView: CYLPlaceholderStackView?` — The placeholder shown by `showEmptyView`, or null (iOS `emptyView`).
- L1043 `val isEmptyViewShowing: Boolean` — True while `showEmptyView` has put its placeholder under the bar (iOS `isEmptyViewShowing`).
- L1053 `fun showEmptyView(text: String?, detailText: String? = null, buttonTitle: String? = null, buttonAction: (() -> Unit)? = null)` — Shows CYLTableViewPlaceHolder's placeholder with a title, an optional detail and an optional button under the bar, over the results (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`). Does nothing while the query is empty (the launch view or t
- L1064 `fun showEmptyView(scenario: CYLPlaceholderScenario)` — Shows one of CYLTableViewPlaceHolder's scenarios under the bar (the placeholder of `emptyResultsScenario`). Does nothing while the query is empty.
- L1074 `fun hideEmptyView()` — Removes the placeholder of `showEmptyView` (closing the search view always does).
- L1120 `fun addHistoryDidChangeListener(listener: (CYLSearchView) -> Unit)` — Calls `listener` after the history changed (iOS `historyDidChangeNotification`): a submitted query went into the suggestion cache, the cache was cleared, or another search view changed the same history (same policy and name). A view that stays on screen while 
- L1127 `fun removeHistoryDidChangeListener(listener: (CYLSearchView) -> Unit)` — Stops calling `listener`.
- L1134 `var closesOnSubmit: Boolean = true` — Closes the search view after a submitted query that the delegate did not handle. True by default.
- L1139 `var query: String?` — The current query (lapism `getTextQuery`). Setting it does not submit.
- L1146 `override fun setBackgroundColor(color: Int)` — Sets the page background (iOS `backgroundColor`; the view itself only shows the scrim).
- L1351 `fun installInView(view: ViewGroup)` — Adds the search view over `view` (filling it) without opening it. `showSearch` calls it with the activity's content view when the search view has no parent.
- L1373 `fun showSearch() = showSearch(true)` — Opens the search view with animation and starts editing (`showSearch`).
- L1378 `fun showSearch(animated: Boolean)` — Opens the search view and starts editing (`showSearch(animate)`).
- L1428 `fun showSearch(activity: Activity, animated: Boolean = true)` — Installs the search view over the content of `activity` (its `android.R.id.content`, filling it) and opens it (iOS `showSearch(in: UIViewController, animated:)`; was `CYLSearchController.showInViewController`). An activity is the Android host of a whole screen
- L1438 `fun showSearch(view: ViewGroup, animated: Boolean = true)` — Installs the search view over `view` (filling it) and opens it: the host for a search inside part of a screen, such as a fragment's root view.
- L1448 `fun closeSearch(animated: Boolean = true, completion: (() -> Unit)? = null)` — Closes the search view and ends editing; `completion` runs once it is gone, after `searchViewDidClose`, and right away when it is not open (was `CYLSearchController.hide(completion)`).
- L1497 `fun attachToMenuItem(item: MenuItem)` — Makes a toolbar menu item open the search view (`setMenuItem`; iOS `attachToBarButtonItem:`).
- L1504 `override fun onAttachedToWindow()`
- L1511 `override fun onDetachedFromWindow()`
- L1520 `override fun onSaveInstanceState(): Parcelable = Bundle().apply`
- L1527 `override fun onRestoreInstanceState(state: Parcelable?)`
- L1539 `override fun dispatchSaveInstanceState(container: SparseArray<Parcelable>) = dispatchFreezeSelfOnly(container)`
- L1541 `override fun dispatchRestoreInstanceState(container: SparseArray<Parcelable>) = dispatchThawSelfOnly(container)`
- L1548 `fun setQuery(query: String?, submit: Boolean)` — Sets the query and submits it when `submit` is true (`setQuery`, `setTextQuery`).
- L1612 `fun showSuggestions() = refilter()` — Lists the suggestions that match the current query (`showSuggestions`).
- L1617 `fun dismissSuggestions()` — Hides the suggestions (`dismissSuggestions`).
- L1663 `fun clearSuggestionCache()` — Removes every cached query (the delete button of `suggestionCacheHeaderView`) and shows the list again (iOS `clearSuggestionCache`).
- L1689 `override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String) = queryChanged(text)`
- L1691 `override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView)`
- L1701 `override fun searchBarViewNavigationButtonClicked(searchBarView: CYLSearchBarView)`
- L1705 `override fun searchBarViewVoiceButtonClicked(searchBarView: CYLSearchBarView)`
- L1709 `override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView) = closeSearch()`
- L1711 `override fun searchBarViewDidBeginEditing(searchBarView: CYLSearchBarView)`
- L1715 `override fun searchBarViewDidEndEditing(searchBarView: CYLSearchBarView)`
- L1764 `override fun getItemCount(): Int = (if (suggestionsVisible) filteredSuggestions.size else 0) + (if (cacheFooterShown) 1 else 0)`
- L1766 `override fun getItemViewType(position: Int): Int = if (cacheFooterShown && position == itemCount - 1) VIEW_TYPE_EXTRA else 0`
- L1768 `override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =`
- L1777 `override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int)`
- L1809 `override fun getItemCount(): Int = (if (resultsVisible) searchResults.size else 0) + headerCount()`
- L1811 `override fun getItemViewType(position: Int): Int = if (position < headerCount()) VIEW_TYPE_EXTRA else 0`
- L1813 `override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder =`
- L1822 `override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int)`
- L1883 `fun beginHeaderRefreshing()` — Starts the header's refresh, like a pull; the header then calls the action.
- L1893 `fun endHeaderRefreshing()` — Ends the header's refresh.
- L1912 `fun emptyPlaceholder(context: Context, text: String?, detailText: String? = null, buttonTitle: String? = null, buttonAction: (() -> Unit)? = null): CYLPlaceholderStackView` — CYLTableViewPlaceHolder's "no results" placeholder with a title, an optional detail and an optional button: the view of `showEmptyView`, also used by `CYLSearchListView`.
- L1938 `fun setRefreshHandler(handler: (() -> Unit)?, scrollView: View)` — Adds pull-to-refresh to `scrollView` (a `RecyclerView`, `ScrollView`, `ListView` or `NestedScrollView` that already has a parent), calling `handler` on each pull; null removes it. The view moves into a CYLTableViewPlaceHolder `CYLRefreshLayout` (with a `CYLRef
- L1973 `fun beginRefreshing(scrollView: View)` — Shows the refresh indicator of `scrollView` and calls its handler, like a pull.
- L1981 `fun endRefreshing(scrollView: View)` — Hides the refresh indicator of `scrollView`.
- L1989 `fun isRefreshing(scrollView: View): Boolean = (scrollView.parent as? CYLRefreshContainer)?.isHeaderRefreshing == true` — True while `scrollView` shows its refresh indicator.
