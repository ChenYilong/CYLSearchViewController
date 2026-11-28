> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# Flutter plugin: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `CrossPlatform/flutter_cylsearch/analysis_options.yaml` | 14 |
| `CrossPlatform/flutter_cylsearch/android/build.gradle.kts` | 87 |
| `CrossPlatform/flutter_cylsearch/android/settings.gradle.kts` | 1 |
| `CrossPlatform/flutter_cylsearch/android/src/main/AndroidManifest.xml` | 3 |
| `CrossPlatform/flutter_cylsearch/android/src/main/kotlin/com/cyl/search/flutter_cylsearch/FlutterCylsearchPlugin.kt` | 871 |
| `CrossPlatform/flutter_cylsearch/ios/flutter_cylsearch.podspec` | 27 |
| `CrossPlatform/flutter_cylsearch/ios/flutter_cylsearch/Sources/flutter_cylsearch/FlutterCylsearchPlugin.swift` | 1114 |
| `CrossPlatform/flutter_cylsearch/lib/flutter_cylsearch.dart` | 8 |
| `CrossPlatform/flutter_cylsearch/lib/src/cyl_search_list_view.dart` | 149 |
| `CrossPlatform/flutter_cylsearch/lib/src/cyl_search_view.dart` | 1588 |
| `CrossPlatform/flutter_cylsearch/pubspec.yaml` | 72 |

## `CrossPlatform/flutter_cylsearch/android/build.gradle.kts`

The Android side of flutter_cylsearch. It depends on the `cylsearch` module of android/merged by its coordinates (com.cyl.search:cylsearch); the app's settings.gradle.kts includes android/merged as a composite build that substitutes it (see example/android/settings.gradle.kts), so the core is built from source with its pinned sub-repositories. A composite build allows one Android Gradle plugin ver

## `CrossPlatform/flutter_cylsearch/android/src/main/kotlin/com/cyl/search/flutter_cylsearch/FlutterCylsearchPlugin.kt`

- L48 `class FlutterCylsearchPlugin : FlutterPlugin` — Registers the platform views of CYLSearchViewController for Flutter: `cyl_search/search_view` (`CYLSearchView`), `cyl_search/search_bar_view` (`CYLSearchBarView`) of the `cylsearch` module and `cyl_search/tag_list_view` (CollectionViewClassifyMenu's `CYLTagLis
- L50 `override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding)`
- L66 `override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) = Unit`
- L73 `override fun create(context: Context, viewId: Int, args: Any?): PlatformView`
- L226 `override fun searchViewWillShow(searchView: CYLSearchView)`
- L230 `override fun searchViewWillClose(searchView: CYLSearchView)`
- L234 `override fun searchViewDidShow(searchView: CYLSearchView)`
- L238 `override fun getView(): View = container`
- L240 `override fun dispose()`
- L244 `override fun searchViewTextDidChange(searchView: CYLSearchView, text: String)`
- L248 `override fun searchViewDidSubmitText(searchView: CYLSearchView, text: String): Boolean`
- L254 `override fun searchViewDidSelectSuggestion(searchView: CYLSearchView, suggestion: String, index: Int)`
- L258 `override fun searchViewDidClose(searchView: CYLSearchView)`
- L262 `override fun searchViewDidSelectResult(searchView: CYLSearchView, result: Any)`
- L278 `var results: List<String> = emptyList()`
- L280 `override fun searchViewResultsForQuery(searchView: CYLSearchView, query: String): List<Any> =`
- L283 `override fun searchViewConfigureResultCell(searchView: CYLSearchView, cell: CYLSearchSuggestionCell, result: Any)`
- L499 `fun rect(value: Any?): Rect`
- L512 `override fun searchBarViewDidSelectItem(searchBarView: CYLSearchBarView, item: CYLSearchBarItem)`
- L516 `override fun getView(): View = toolbar ?: bar`
- L518 `override fun dispose()`
- L522 `override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String)`
- L526 `override fun searchBarViewSearchButtonClicked(searchBarView: CYLSearchBarView)`
- L532 `override fun searchBarViewCancelButtonClicked(searchBarView: CYLSearchBarView)`
- L536 `override fun searchBarViewTextDidChange(searchBarView: CYLSearchBarView, text: String, index: Int)`
- L540 `override fun searchBarViewDidCompleteSearch(searchBarView: CYLSearchBarView, text: String, index: Int)`
- L544 `override fun searchBarViewDidRemoveSearchAtIndex(searchBarView: CYLSearchBarView, index: Int)`
- L549 `override fun searchBarViewDidSelectSearch(searchBarView: CYLSearchBarView, text: String, index: Int)`
- L584 `override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int)`
- L715 `override fun numberOfSectionsInMenu() = 1`
- L716 `override fun menuNumberOfItemsInSection(section: Int) = titles.size`
- L717 `override fun menuTitleForSection(section: Int) = sectionTitle`
- L718 `override fun menuTitleForItemAtIndexPath(indexPath: CYLIndexPath) = titles.getOrElse(indexPath.item) { "" }`
- L719 `override fun menuSubtitleForItemAtIndexPath(indexPath: CYLIndexPath): String? =`
- L721 `override fun menuIdentifierForItemAtIndexPath(indexPath: CYLIndexPath): String = idAt(indexPath.item)`
- L722 `override fun menuShowsClearButtonForSection(section: Int) = showsClearButton && !showsRefreshButton`
- L723 `override fun menuShowsMoreButtonInSection(section: Int) = showsRefreshButton`
- L724 `override fun menuAccessibilityLabelForMoreButtonInSection(section: Int) = CYLSearchTagListHeader.refreshLabel(appContext)`
- L725 `override fun menuImageForItemAtIndexPath(indexPath: CYLIndexPath): android.graphics.drawable.Drawable?`
- L735 `override fun supportsRenamingItems() = supportsRenaming`
- L736 `override fun menuRenameItemAtIndexPath(indexPath: CYLIndexPath, title: String) = Unit`
- L737 `override fun supportsMovingItems() = true`
- L738 `override fun menuMoveItemAtIndexPath(sourceIndexPath: CYLIndexPath, toIndexPath: CYLIndexPath)`
- L745 `override fun menuRemoveItemAtIndexPath(indexPath: CYLIndexPath)`
- L755 `override fun menuDidSelectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath)`
- L763 `override fun menuDidDeselectItemAtIndexPath(menu: Any, indexPath: CYLIndexPath)`
- L770 `override fun menuDidTapClearButtonInSection(menu: Any, section: Int)`
- L773 `override fun menuDidTapMoreButtonInSection(menu: Any, section: Int)`
- L776 `override fun menuDidChangeContentHeight(menu: Any, height: Float) = reportHeight()`
- L777 `override fun menuDidChangeExpanded(menu: Any, expanded: Boolean, inSection: Int) = reportHeight()`
- L778 `override fun menuDidChangeEditing(menu: Any, editing: Boolean) = reportHeight()`
- L786 `override fun menuDidChangeReordering(menu: Any, reordering: Boolean)`
- L791 `override fun menuDidChangeSmearing(menu: Any, smearing: Boolean)`
- L814 `override fun getView(): View = tagListView`
- L816 `override fun dispose()`
- L847 `override fun getView(): View = container`
- L849 `override fun dispose()`

## `CrossPlatform/flutter_cylsearch/ios/flutter_cylsearch.podspec`

The Flutter plugin of CYLSearchViewController: the native CYLSearchView and CYLSearchBarView as platform views. In this repository the example uses the local pod (example/ios/Podfile: pod 'CYLSearchViewController', :path), and pins the core's sub-repositories by commit.

## `CrossPlatform/flutter_cylsearch/ios/flutter_cylsearch/Sources/flutter_cylsearch/FlutterCylsearchPlugin.swift`

CYLTableViewPlaceHolder: the core's placeholder sub-dependency; imported for `CYLPlaceholderScenario`, the type of `CYLSearchView.emptyResultsScenario` (Swift does not see a dependency's types through the core).

- L15 `public final class FlutterCylsearchPlugin: NSObject, FlutterPlugin` — Registers the platform views of CYLSearchViewController for Flutter: `cyl_search/search_view` (`CYLSearchView`), `cyl_search/search_bar_view` (`CYLSearchBarView`, or its editing bar), `cyl_search/tag_list_view` (CollectionViewClassifyMenu's `CYLTagListView`) a
- L20 `public static func register(with registrar: FlutterPluginRegistrar)` — Called by the Flutter engine when the app starts.

## `CrossPlatform/flutter_cylsearch/lib/flutter_cylsearch.dart`

CYLSearchViewController for Flutter: the native search page and search bar of the CYLSearchBar core (iOS Swift, Android `cylsearch`) as widgets: `CYLSearchView` (suggestions, results, pull-to-refresh, the empty results placeholder) with `CYLSearchViewWidgetController`, `CYLSearchBarView` (single or multiple searches) with `CYLSearchBarWidgetController`, and CollectionViewClassifyMenu's `CYLTagList

## `CrossPlatform/flutter_cylsearch/lib/src/cyl_search_list_view.dart`

A list whose first item is a search bar (iOS `CYLSearchTableViewController` with `showsSearchBar`, Android `CYLSearchListView`): the bar scrolls with the rows, can start hidden, can give way to an empty view, and a bar dragged half way settles fully shown or fully hidden, also above a list too short to scroll it out (QMUI issue #1160, iOS `snapsHeaderSearchBar`). Pass a [CYLSearchBarView] as [sear

- L11 `class CYLSearchListView extends StatefulWidget` — A list whose first item is a search bar (iOS `CYLSearchTableViewController` with `showsSearchBar`, Android `CYLSearchListView`): the bar scrolls with the rows, can start hidden, can give way to an empty view, and a bar dragged half way settles fully shown or f
- L29 `final Widget searchBar;` — The bar, the list's first item; give it no height of its own, [searchBarHeight] sets it.
- L32 `final double searchBarHeight;` — The height of the bar's row.
- L35 `final int itemCount;` — The number of rows under the bar.
- L38 `final IndexedWidgetBuilder itemBuilder;` — Builds a row.
- L41 `final bool showsSearchBar;` — Whether the bar is the first item (iOS `showsSearchBar`); false removes it.
- L44 `final bool hidesSearchBarInitially;` — Scrolls the bar out of sight at first, so a pull down shows it (iOS `hidesSearchBarInitially`).
- L48 `final bool hidesSearchBarWhenEmptyViewShowing;` — Takes the bar away while [emptyView] shows, and puts it back hidden when the empty view goes (iOS `hidesSearchBarWhenEmptyViewShowing`).
- L51 `final Widget? emptyView;` — A widget that replaces the rows, such as a placeholder (iOS `showEmptyView`); null shows the rows.
- L55 `final bool snapsHeaderSearchBar;` — Settles the bar fully shown or hidden when scrolling ends, and lets a short list scroll it out (iOS `snapsHeaderSearchBar`, issue #1160).
- L58 `final VoidCallback? onSearchBarTap;` — The bar was tapped (Android `opensSearchViewOnTap`); the bar's own field then does not take the tap.
- L61 `final ScrollController? controller;` — The scroll controller of the list; optional.
- L64 `State<CYLSearchListView> createState() => _CYLSearchListViewState();`
- L76 `void didUpdateWidget(CYLSearchListView oldWidget)`
- L86 `void dispose()`
- L110 `Widget build(BuildContext context)`

## `CrossPlatform/flutter_cylsearch/lib/src/cyl_search_view.dart`

How the suggestions are shown under the search bar (iOS `CYLSearchSuggestionStyle`).

- L9 `enum CYLSearchSuggestionStyle` — How the suggestions are shown under the search bar (iOS `CYLSearchSuggestionStyle`).
- L18 `enum CYLSearchBarMode` — What a [CYLSearchBarView] holds (iOS and Android `CYLSearchBarMode`).
- L28 `enum CYLPlaceholderScenario` — The CYLTableViewPlaceHolder scenario of the empty results placeholder (iOS `CYLPlaceholderScenario`).
- L37 `enum CYLSearchSuggestionCachePolicy` — Where the search page caches submitted queries for its suggestion list (iOS `CYLSearchSuggestionCachePolicy`).
- L52 `enum CYLTagFoldControlPosition` — Where a tag list's fold control is (CollectionViewClassifyMenu's `CYLMenuFoldControlPosition`).
- L76 `enum CYLTagFoldControlContent` — What a tag list's fold control shows (CollectionViewClassifyMenu's `CYLMenuFoldControlContent`).
- L88 `enum CYLTagSelectionMode` — Whether taps on a tag list select tags (CollectionViewClassifyMenu's `CYLMenuSelectionMode`).
- L97 `enum CYLPlaceholderStyle` — The image of a [CYLPlaceholderView] (CYLTableViewPlaceHolder's `CYLPlaceholderStyle`).
- L110 `class CYLSearchViewTypes` — The view types the platform side registers.
- L126 `static String channel(int id) => 'cyl_search/view_$id';` — The channel of the platform view with `id`.
- L135 `void attach(MethodChannel? channel) => _channel = channel;` — Connects the controller to the channel of its widget's native view, or disconnects it (null).
- L138 `bool get isAttached => _channel != null;` — True while a native view is connected.
- L149 `class CYLSearchViewWidgetController extends _CYLPlatformViewController with ChangeNotifier` — Drives a [CYLSearchView] from code (iOS and Android `CYLSearchView` methods): the refresh of its results and their reload. Pass it as [CYLSearchView.controller]; one controller serves one search view at a time.
- L160 `bool get isActive => _isActive;` — Whether the search is active, that is open (iOS `isActive`, Android `isActive`): true from the moment the page opens until a Cancel, the back arrow or [setActive] closes it. Listen to this controller to follow it.
- L164 `Future<void> setActive(bool active, {bool animated = true}) async` — Opens or closes the search from code (iOS `setActive(_:animated:)`, Android `setActive`). Closing ends with [CYLSearchView.onClose] (pop the route there); opening again shows the page as it was.
- L171 `Future<void> setQuery(String? query, {bool submit = false}) =>` — Sets the query and, with [submit], submits it (iOS `setQuery(_:submit:)`, Android `setQuery`): the results follow through [CYLSearchView.onTextChanged], and a submit goes into the history and [CYLSearchView.onSubmitted]. A tapped recent tag does this natively 
- L176 `Future<List<String>> history() async =>` — The submitted queries kept in the search page's cache, newest first (iOS `historyStore.cachedQueries()`); empty with [CYLSearchSuggestionCachePolicy.none].
- L180 `Future<void> clearHistory() => _invoke<void>('clearHistory');` — Clears that cache (iOS `historyStore.removeAllQueries()`); [CYLSearchView.onHistoryChanged] reports the empty list.
- L184 `Future<void> beginRefreshing() => _invoke<void>('beginRefreshing');` — Starts the refresh of the results, as a pull would; the native view then calls [CYLSearchView.onRefresh] (iOS and Android `beginRefreshing()`).
- L188 `Future<void> endRefreshing() => _invoke<void>('endRefreshing');` — Stops the refresh of the results (iOS and Android `endRefreshing()`). Call it on every completion path of [CYLSearchView.onRefresh].
- L191 `Future<bool> isRefreshing() async => await _invoke<bool>('isRefreshing') ?? false;` — Whether the results refresh (iOS and Android `isRefreshing`); false before the native view exists.
- L195 `Future<void> reloadResults() => _invoke<void>('reloadResults');` — Queries the results again for the current query and reloads their list (iOS and Android `reloadResults()`). A new [CYLSearchView.results] list reloads them already.
- L200 `class CYLSearchBarWidgetController extends _CYLPlatformViewController with ChangeNotifier` — Drives a [CYLSearchBarView] in [CYLSearchBarMode.multiple] from code (iOS and Android `CYLSearchBarView`). Pass it as [CYLSearchBarView.controller]; one controller serves one search bar at a time.
- L207 `Future<void> setShowsCancelButton(bool shows, {bool animated = true}) =>` — Shows or hides Cancel, with an animation when [animated] is true (iOS `setShowsCancelButton(_:animated:)`, Android `setShowsCancelButton`). The last call decides: two quick calls end in the state of the second.
- L211 `Future<void> showKeyboard() => _invoke<void>('showKeyboard');` — Focuses the field and raises the keyboard (iOS and Android `showKeyboard()`).
- L215 `Future<void> restartItemAnimation(int index) => _invoke<void>('restartItemAnimation', <String, Object?>{'index': index});` — Plays the animation of the item at [index] of [CYLSearchBarView.items] again from the start (iOS and Android `CYLSearchBarItem.restartAnimation()`); nothing happens for an item without [CYLSearchBarItem.animationURL].
- L219 `void setShowsLeadingView(bool shows, {bool animated = true})` — Shows or hides [CYLSearchBarView.leadingView], with an animation when [animated] is true (iOS `setShowsLeadingView(_:animated:)`). The last call decides.
- L227 `void setShowsTrailingAccessoryViews(bool shows, {bool animated = true})` — Shows or hides [CYLSearchBarView.trailingAccessoryViews], with an animation when [animated] is true (iOS `setShowsTrailingAccessoryViews(_:animated:)`). The last call decides.
- L234 `Future<void> beginNewSearch() => _invoke<void>('beginNewSearch');` — Starts a new search and shows the keyboard (`beginNewSearch()`).
- L238 `Future<void> completeSearch() => _invoke<void>('completeSearch');` — Completes the search being typed (`completeSearch()`): it becomes the selected search, or is dropped when it is too short.
- L241 `Future<void> addSearch(String text) => _invoke<void>('addSearch', <String, Object?>{'text': text});` — Adds a completed search without typing it, and selects it (`addSearch(_:)`).
- L244 `Future<void> selectSearch(int index) => _invoke<void>('selectSearch', <String, Object?>{'index': index});` — Selects a search, like a tap on it (`selectSearch(at:)`).
- L247 `Future<void> removeSearch(int index) => _invoke<void>('removeSearch', <String, Object?>{'index': index});` — Removes a search, like a tap on its remove button (`removeSearch(at:)`).
- L250 `Future<List<String>> searches() async =>` — The texts of the searches, completed searches first, then the one being typed (`searches`).
- L254 `Future<int> selectedSearchIndex() async => await _invoke<int>('selectedSearchIndex') ?? -1;` — The index of the selected search, or -1 when none is selected (`selectedSearchIndex`; iOS `NSNotFound`).
- L325 `class CYLSearchView extends StatefulWidget` — The search page of CYLSearchViewController (iOS `CYLSearchView`, Android `CYLSearchView`) as a widget: its native search bar at the top of the safe area, the suggestions filtered as the user types (a list or tags), and CYLTableViewPlaceHolder's placeholder for
- L375 `final Color? scrimColor;` — The color of the scrim under the bar while the query is empty (iOS `scrimColor`): the page below the bar is dimmed with it, and a tap on it ends the search. Null shows no scrim. The native overlay, one view for every platform.
- L379 `final bool supportsSwipeToDismissSearch;` — Lets a swipe from the left edge drag the page sideways and end the search when it passes a quarter of the width (iOS `supportsSwipeToDismissSearch`, the native gesture); a shorter swipe springs back. False by default.
- L383 `final bool highlightsResultMatches;` — Colors the first part of each result that matches the query, ignoring case and diacritics ("e" matches "É"), in [resultMatchHighlightColor] (iOS `highlightsResultMatches`). False lists plain texts.
- L386 `final Color? resultMatchHighlightColor;` — The color of the highlighted match (iOS `resultMatchHighlightColor`); null uses the tint color.
- L390 `final String? noResultsText;` — The title of the empty results placeholder (iOS `CYLSearchController.noResultsText`): shown with [showsEmptyResultsPlaceholder] while a query has no result. Null keeps the placeholder's own title.
- L394 `final VoidCallback? onWillShow;` — The search is about to open (iOS `searchViewWillShow(_:)`): when the page is built, and when [CYLSearchViewWidgetController.setActive] opens it again.
- L397 `final VoidCallback? onDidShow;` — The search is open (iOS `searchViewDidShow(_:)`): the native page exists, or was opened again.
- L401 `final VoidCallback? onWillClose;` — The search is about to close (iOS `searchViewWillClose(_:)`): [CYLSearchViewWidgetController.setActive] with false, Cancel, the back arrow or a swipe. [onClose] follows it.
- L405 `final ValueChanged<List<String>>? onHistoryChanged;` — The submitted queries changed (iOS `historyDidChangeNotification`): after a submit and after [CYLSearchViewWidgetController.clearHistory], with the history, newest first. Also once when the page opens.
- L408 `final CYLSearchViewWidgetController? controller;` — Calls the native view's refresh and results methods; optional.
- L414 `final List<String>? results;` — The results of the current query, one row each (iOS and Android `resultsDataSource`, `searchResults`). Non-null lists them in `resultsTableView` while the query is not empty, instead of the suggestions; an empty list shows the empty results placeholder when [s
- L421 `final bool refreshEnabled;` — Adds pull-to-refresh to the results list (iOS and Android `refreshHandler`, CYLTableViewPlaceHolder's normal header). A pull, or [CYLSearchViewWidgetController.beginRefreshing], calls [onRefresh].
- L425 `final VoidCallback? onRefresh;` — The results list was pulled to refresh (iOS and Android `refreshHandler`). Call [CYLSearchViewWidgetController.endRefreshing] on every completion path.
- L428 `final List<String> suggestions;` — The suggestions to filter as the text changes (iOS `suggestions`).
- L431 `final CYLSearchSuggestionStyle suggestionStyle;` — How the suggestions are shown (iOS `suggestionStyle`): tags by default.
- L434 `final String? placeholder;` — The search bar's placeholder (iOS `searchBarView.placeholder`).
- L437 `final String? query;` — The query to start with (iOS `query`).
- L440 `final bool showsSuggestionsForEmptyQuery;` — Lists every suggestion while the query is empty (iOS `showsSuggestionsForEmptyQuery`).
- L443 `final bool submitsOnSuggestionSelection;` — Submits a suggestion as soon as it is tapped (iOS `submitsOnSuggestionSelection`).
- L446 `final bool showsEmptyResultsPlaceholder;` — Shows CYLTableViewPlaceHolder's placeholder while a query matches nothing (iOS `showsEmptyResultsPlaceholder`).
- L449 `final CYLPlaceholderScenario emptyResultsScenario;` — The scenario of that placeholder (iOS `emptyResultsScenario`).
- L453 `final CYLSearchSuggestionCachePolicy suggestionCachePolicy;` — Where submitted queries are cached (iOS `suggestionCachePolicy`): an empty query lists them, newest first, under a header whose delete button clears them. A local database by default.
- L456 `final String suggestionCacheName;` — Separates the caches of different search pages (iOS `suggestionCacheName`).
- L460 `final bool focusesSearchFieldOnShow;` — Focuses the search field when the page opens, which raises the keyboard (iOS `focusesSearchFieldOnShow`). False shows the suggestion list (or an empty placeholder) with the keyboard down until the field is tapped.
- L464 `final bool showsSuggestionCacheHeader;` — Shows the header above the cached queries: the title and the trash button (iOS `showsSuggestionCacheHeader`). False takes it away, for a page that clears the history with its own control.
- L468 `final CYLTagFoldControlPosition suggestionsFoldControlPosition;` — Where the tag suggestions' fold control is (iOS `suggestionsFoldControl.position`): a chevron as the last tag by default.
- L471 `final CYLTagFoldControlContent suggestionsFoldControlContent;` — What that control shows (iOS `suggestionsFoldControl.content`).
- L474 `final int suggestionsFoldedRowCount;` — The rows of tag suggestions shown while folded (iOS `suggestionsFoldedRowCount`); 0 shows every row.
- L477 `final ValueChanged<String>? onTextChanged;` — The query changed (iOS `searchView(_:textDidChange:)`).
- L480 `final ValueChanged<String>? onSubmitted;` — The query was submitted (iOS `searchView(_:didSubmitText:)`); the page stays open.
- L487 `final VoidCallback? onClose;` — The search closed, by the back arrow, Cancel, a swipe or [CYLSearchViewWidgetController.setActive] (iOS `searchViewDidClose(_:)`): pop the route here.
- L490 `State<CYLSearchView> createState() => _CYLSearchViewState();`
- L503 `void initState()`
- L549 `void didUpdateWidget(CYLSearchView oldWidget)`
- L561 `void didChangeDependencies()`
- L568 `void dispose()`
- L576 `Widget build(BuildContext context)`
- L600 `enum CYLSearchBarItemStyle` — How an item appended to a search bar looks (iOS and Android `CYLSearchBarItemStyle`).
- L612 `enum CYLSearchBarSearchButtonStyle` — What the default search button of a bar shows (iOS and Android `CYLSearchBarSearchButtonStyle`).
- L621 `enum CYLSearchBarStyle` — The fixed look of the whole bar (iOS and Android `CYLSearchBarStyle`).
- L632 `class CYLSearchBarItem` — One element after the text of a [CYLSearchBarView] (iOS and Android `CYLSearchBarItem`, like the FlatDesign tab bar's items). The field stays; the bar only appends items.
- L680 `final CYLSearchBarItemStyle style;` — The look (iOS `style`).
- L683 `final String? title;` — The text of a text item, and the screen reader label of an icon item (iOS `title`).
- L687 `final String? image;` — The icon: `camera`, `mic`, `search` or `back` (drawn by the core on both platforms), else an image of the app (an iOS asset or SF Symbol name, an Android drawable name).
- L690 `final String? accessibilityIdentifier;` — A test identifier of the item view (iOS `itemAccessibilityIdentifier`).
- L693 `final bool isEnabled;` — False dims the item and ignores taps (iOS `isEnabled`).
- L696 `final bool isSelectable;` — Each tap toggles [isSelected] on the native side (iOS `isSelectable`).
- L699 `final bool isSelected;` — The selected state (iOS `isSelected`).
- L702 `final String? badgeValue;` — The badge text; an empty string draws a dot (iOS `badgeValue`).
- L706 `final String? animationURL;` — The animated file of the icon (iOS and Android `animationURL`): Lottie `.json`, `.pag`, `.riv`, `.svga` or `.gif`, with `#` options; null shows [image] still. It plays on each tap, and again after each pass with [animationLoops].
- L709 `final bool animationLoops;` — Whether [animationURL] plays again after each pass (iOS and Android `animationLoops`); false plays once on each tap.
- L712 `final double animationSpeed;` — The playback speed of [animationURL] (iOS and Android `animationSpeed`); 1 is the file's own.
- L715 `final ValueChanged<bool>? onTap;` — Called on each tap with the selected state after the tap (iOS `handler`).
- L718 `Map<String, Object?> toMap() => <String, Object?>` — The parameters the native view builds the item from.
- L736 `class CYLSearchBarAppearance` — The merged default style of a [CYLSearchBarView] (iOS `CYLSearchBarAppearance`, Android `CYLSearchBarAppearance`): the field's colors and corners, the tint and the Cancel title. A null value leaves the native default of that property.
- L748 `final Color? fieldBackgroundColor;` — The field's background (iOS `textFieldBackgroundColor`).
- L751 `final Color? fieldBorderColor;` — The field's border (iOS `textFieldBorderColor`).
- L754 `final double? fieldCornerRadius;` — The field's corner radius; negative makes a capsule (iOS `textFieldCornerRadius`).
- L757 `final Color? tintColor;` — The color of Cancel and of the cursor (iOS `tintColor`).
- L760 `final Color? barBackgroundColor;` — The color behind the whole bar (iOS `barBackgroundColor`).
- L763 `final String? cancelTitle;` — The Cancel button's title (iOS `cancelTitle`).
- L766 `Map<String, Object?> toMap() => <String, Object?>` — The parameters the native view applies.
- L782 `class CYLSearchBarView extends StatefulWidget` — The search bar of CYLSearchViewController (iOS and Android `CYLSearchBarView`) as a widget: a rounded field with a magnifier, the text, a clear button, appended [items] and an optional Cancel button. With [mode] set to [CYLSearchBarMode.multiple] it holds seve
- L838 `final Color? placeholderColor;` — The placeholder's color (iOS `placeholderColor`); null keeps the native default.
- L841 `final Color? textColor;` — The text's color (iOS `textColor`); null keeps the native default.
- L844 `final double? fontSize;` — The text and placeholder size in logical pixels (iOS `font`); null keeps the native default.
- L848 `final bool centersPlaceholder;` — Draws the magnifier and the placeholder in the middle of the field while the bar is not edited and has no text, and at the start otherwise (iOS `centersPlaceholder`, QMUI `qmui_centerPlaceholder`).
- L851 `final EdgeInsets textFieldMargins;` — The space around the field at rest, on top of the native margins (iOS `textFieldMargins`).
- L855 `final EdgeInsets? activeTextFieldMargins;` — The space around the field while the bar is active, that is edited (iOS `textFieldMarginsProvider(bar, true)`); null uses [textFieldMargins] in both states.
- L859 `final EdgeInsets cancelButtonMargins;` — The space around the Cancel button at rest (iOS `cancelButtonMarginsProvider(bar, false)`). A negative left value pulls Cancel toward the field.
- L863 `final EdgeInsets? activeCancelButtonMargins;` — The space around the Cancel button while the bar is active (iOS `cancelButtonMarginsProvider(bar, true)`); null uses [cancelButtonMargins].
- L866 `final double? cancelButtonFontSize;` — The Cancel button's text size (iOS `cancelButtonFont`); null uses the text's.
- L869 `final CYLSearchBarAppearance? appearance;` — The merged default style (iOS `appearanceStyle`); null keeps the native default.
- L875 `final Widget? leadingView;` — A widget of yours beside the field, before it (iOS `leadingView`), centered on the field. Dart only, on purpose: the native `leadingView` is a native view, and a platform view cannot host a Flutter widget, so the bar lays this widget out in a row with the nati
- L878 `final bool showsLeadingView;` — Whether [leadingView] is shown (iOS `showsLeadingView`); true by default.
- L881 `final EdgeInsets leadingViewMargins;` — The space around [leadingView] (iOS `leadingViewMargins`).
- L884 `final List<Widget> trailingAccessoryViews;` — Widgets of yours beside the field, after it, in order (iOS `trailingAccessoryViews`); Dart only like [leadingView].
- L887 `final bool showsTrailingAccessoryViews;` — Whether [trailingAccessoryViews] is shown (iOS `showsTrailingAccessoryViews`); true by default.
- L890 `final EdgeInsets trailingAccessoryViewsMargins;` — The space around [trailingAccessoryViews] (iOS `trailingAccessoryViewsMargins`).
- L896 `final bool editingBar;` — The core's editing bar (iOS and Android `CYLSearchBarView.editingBar`) in place of the search bar: a field and an action button ("Add", "Done") to put above the keyboard. Read when the native view is created; give the widget another key to switch. Given a new 
- L899 `final String? actionTitle;` — [editingBar]: the action button's title.
- L903 `final ValueChanged<String>? onEditingSubmitted;` — [editingBar]: the action button or the return key, with the trimmed text; the field is cleared after it and [onSubmitted] is not called.
- L906 `final CYLSearchBarWidgetController? controller;` — Calls the native bar's multiple-search methods; optional.
- L909 `final CYLSearchBarMode mode;` — One field, or several searches side by side (iOS and Android `mode`).
- L914 `final List<String> searches;` — [CYLSearchBarMode.multiple]: the completed searches (iOS and Android `searches`, filled with `addSearch(_:)`). The native bar takes a list that differs from its own completed searches, unless a search is being typed; keep it in sync through [onCompleteSearch] 
- L926 `final ValueChanged<int>? onRemoveSearch;` — [CYLSearchBarMode.multiple]: a search was removed by its remove button or [CYLSearchBarWidgetController.removeSearch] (iOS `searchBarView(_:didRemoveSearchAt:)`).
- L933 `final CYLSearchBarStyle searchBarStyle;` — The fixed look of the bar (iOS `searchBarStyle`).
- L936 `final bool showsSearchIcon;` — Draws the magnifier at the start of the field (iOS `searchIcon` set or nil).
- L941 `final bool navigationFieldStyle;` — The core navigation field preset (iOS `applyNavigationFieldStyle()`): bordered capsule radius 18, soft shadow 0.06, no magnifier, 16 text that scales, an opaque white (light) or black (dark) fill. It wins over [searchBarStyle], [fieldShadowOpacity] and [showsS
- L946 `final bool showsSearchButton;` — The core's default search button after the field and the items (iOS and Android `showsSearchButton`): true by default; an editing bar ([editingBar]) and [CYLSearchBarMode.multiple] never show it. A tap submits the text ([onSubmitted]), also when the text is em
- L949 `final CYLSearchBarSearchButtonStyle searchButtonStyle;` — Whether the default search button shows an icon in a filled capsule (the default) or a title (`searchButtonStyle`).
- L952 `final String? searchButtonTitle;` — The title of the default search button; null is the localized "Search" (`searchButtonTitle`).
- L955 `final ValueChanged<String>? searchButtonHandler;` — Called with the text instead of the default submit when the default search button is tapped (`searchButtonHandler`).
- L963 `final bool focusesOnAppear;` — The field focuses itself (and the keyboard shows) every time the bar appears on screen, like a `viewDidAppear`: the first entry, a tab switch, a push and pop and the return from the background. The native core handles attach, visibility and resume; this widget
- L968 `final bool embedsInNavigationBar;` — The bar sits in a navigation bar the core creates (`CYLSearchNavigationBar`, 44 pt high, the field 36 pt) instead of being a plain view: the page always has its search bar in a navigation bar. Place it as the `Scaffold.appBar` of a `PreferredSize` 44 pt high. 
- L973 `final bool showsBackButton;` — With [embedsInNavigationBar]: the navigation bar has the back button of a second-level page on its leading side and the search bar takes the width that is left; a tap calls [onBackPressed]. Read when the platform view is created. Default false.
- L976 `final VoidCallback? onBackPressed;` — The back button of the navigation bar was tapped ([showsBackButton]): pop the route.
- L981 `final bool animatesBackButton;` — With [showsBackButton]: the bar starts whole (no back button) and the back button slides in while the width shrinks, the continuation of the first-level bar that pushed this page (native `CYLSearchBarView.showBackButton(animated)`); a later change of [showsBac
- L986 `final bool pushesOnTap;` — First-level page (with [embedsInNavigationBar]): the bar is shown whole and a tap on its field does not edit. The native core brings the back button in (animated) and calls [onFirstLevelTap], where the page pushes the second-level search page, whose bar sets [
- L989 `final VoidCallback? onFirstLevelTap;` — The first-level field was tapped ([pushesOnTap]): push the second-level search page.
- L992 `final List<CYLSearchBarItem> items;` — The items appended after the text, in order (iOS `addItem(_:)`).
- L998 `final String? placeholder;` — The placeholder (iOS `placeholder`).
- L1001 `final String? text;` — The text (iOS `text`); null keeps what the user typed.
- L1004 `final bool showsCancelButton;` — Shows Cancel after the field (iOS `showsCancelButton`).
- L1007 `final double fieldShadowOpacity;` — The field's shadow, 0 to 1 (iOS `fieldShadowOpacity`).
- L1010 `final ValueChanged<String>? onTextChanged;` — [CYLSearchBarMode.single]: the text changed (iOS `searchBarView(_:textDidChange:)`).
- L1013 `final ValueChanged<String>? onSubmitted;` — The search key or the submit button (iOS `searchBarViewSearchButtonClicked(_:)`), with the text.
- L1016 `final VoidCallback? onCancel;` — Cancel was tapped (iOS `searchBarViewCancelButtonClicked(_:)`).
- L1019 `State<CYLSearchBarView> createState() => _CYLSearchBarViewState();`
- L1031 `void initState()`
- L1039 `void didChangeAppLifecycleState(AppLifecycleState state)` — focusesOnAppear: the return from the background.
- L1104 `void didUpdateWidget(CYLSearchBarView oldWidget)`
- L1119 `void didChangeDependencies()`
- L1127 `void dispose()`
- L1147 `Widget build(BuildContext context) => Row(`
- L1292 `class CYLTagListView extends StatefulWidget` — CollectionViewClassifyMenu's tag list (iOS and Android `CYLTagListView`, the view of `CYLSearchView`'s tag style) as a widget: the tags wrap like words. It takes the height its tags need at its width, so put it in a scrolling or unbounded column.
- L1326 `final List<String> tagIds;` — The tags' ids, one per title (iOS `menuIdentifierForItem(at:)`): kept by renaming and reordering, and reported by the callbacks. Empty: the titles are the ids.
- L1330 `final List<String> tagSubtitles;` — The subtitle of each tag, parallel to [tags] ('' none). A long press on a tag with one shows it in a small callout with an arrow (CollectionViewClassifyMenu's `longPressAction` callout, `menuSubtitleForItem`); a tap is unchanged.
- L1334 `final int titleMaxLines;` — The most lines a tag's title may wrap onto: [cylTagTitleSingleLine] (default, one line, truncated), [cylTagTitleUnlimited], or a count (ClassifyMenu's `titleMaxLines`).
- L1337 `final List<String> selectedIds;` — The ids of the selected tags ([CYLTagSelectionMode.multiple]).
- L1340 `final CYLTagSelectionMode selectionMode;` — Whether taps select tags (`selectionMode`).
- L1343 `final String sectionTitle;` — The section's header title; with [showsClearButton] or a title, the header shows.
- L1347 `final int columns;` — More than 0 shows the tags as a grid of that many plain titles per row (CollectionViewClassifyMenu's `gridStyle(itemsPerRow:)`, the iOS example's discover topics); 0 (default) is the flowing capsule tags.
- L1352 `final String backgroundStyle;` — The background of every tag: 'liquidGlass' is the Liquid Glass material (flat where the system draws none), '' or 'flat' (default) the tag's own colors. The one parameter that turns a list into Liquid Glass tags (CollectionViewClassifyMenu's `backgroundStyle`)
- L1356 `final List<String> tagImages;` — An image after each tag's title, one Flutter asset key per tag ('' for none), shown at its own size: the discover topics' hot icon. The 2.0x and 3.0x variants beside the asset are used as Flutter does.
- L1360 `final List<String> tagImageLabels;` — The accessibility label of each tag's image, localized, parallel to [tagImages] ('' for none): VoiceOver and TalkBack read it as the tag's value (for the hot icon, "Hot").
- L1363 `final bool showsClearButton;` — A trash button in the header (iOS `menuShowsClearButton(forSection:)`): [onClearButtonTapped].
- L1368 `final bool showsRefreshButton;` — A refresh icon (the SF Symbol "arrow.clockwise", a localized VoiceOver label) at the trailing end of the header, in place of the three dots of the More button: [onRefreshButtonTapped]. One header action: it wins over [showsClearButton].
- L1371 `final bool editing;` — Editing mode (iOS `setEditing(_:animated:)`): a cross on each tag ([onTagDeleted]) and dragging ([onTagMoved]).
- L1375 `final bool supportsRenaming;` — While [editing], an edit icon before each cross; it and a title tap call [onRenameRequested] (rename by id and send the new [tags]).
- L1390 `final VoidCallback? onClearButtonTapped;` — The header's clear button was tapped.
- L1393 `final VoidCallback? onRefreshButtonTapped;` — The refresh icon of the header was tapped ([showsRefreshButton]).
- L1398 `final ValueChanged<bool>? onDraggingChanged;` — A drag of a tag or a smear selection started (true) or ended or was cancelled (false), the counterpart of the mini program's `reorderingchange` and `smearingchange`. The list already keeps an ancestor scroll view from scrolling with the drag (a long press wins
- L1401 `final List<String> tags;` — The titles of the tags (`setTagsWithTitles`).
- L1404 `final CYLTagFoldControlPosition foldControlPosition;` — Where the fold control is (`foldControl.position`): a chevron as the last tag by default.
- L1407 `final CYLTagFoldControlContent foldControlContent;` — What the fold control shows (`foldControl.content`).
- L1410 `final int foldedRowCount;` — The rows shown while folded (`defaultVisibleRows`); 0 shows every row.
- L1416 `State<CYLTagListView> createState() => _CYLTagListViewState();`
- L1443 `void didUpdateWidget(CYLTagListView oldWidget)`
- L1468 `void didChangeDependencies()`
- L1474 `void dispose()`
- L1480 `Widget build(BuildContext context) => SizedBox(`
- L1541 `class CYLPlaceholderView extends StatefulWidget` — CYLTableViewPlaceHolder's placeholder (iOS and Android `CYLPlaceholderView`): the image of a [CYLPlaceholderStyle] above a text, centred in the size it is given.
- L1546 `final CYLPlaceholderStyle placeholderStyle;` — The image.
- L1549 `final String text;` — The text under the image.
- L1552 `State<CYLPlaceholderView> createState() => _CYLPlaceholderViewState();`
- L1568 `void didUpdateWidget(CYLPlaceholderView oldWidget)`
- L1576 `void didChangeDependencies()`
- L1582 `Widget build(BuildContext context) => _platformView(CYLSearchViewTypes.placeholderView, _parameters, _created);`
