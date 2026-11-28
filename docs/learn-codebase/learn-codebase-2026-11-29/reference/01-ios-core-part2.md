> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

<!-- 01-ios-core: part 2 of 2 -->
_Part 2 of 2. Previous: [part 1](01-ios-core.md)._

## `Sources/CYLSearchBar/CYLSearchTableViewController.swift`

Tencent is pleased to support the open source community by making QMUI_iOS available. Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved. Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at http://opensource.org/licenses/MIT Unless required by applicable law or agreed t

- L31 `open class CYLSearchTableViewController: UITableViewController, CYLSearchControllerDelegate` — A table view controller that can show a `CYLSearchBarView` as its table header, with the `CYLSearchController` that drives it (QMUI's `QMUICommonTableViewController (Search)`). Set `showsSearchBar`; configure the bar in `setUpSearchBar()`; override `searchCont
- L41 `@objc public var showsSearchBar = false` — Whether the search bar is shown as the table header (QMUI `shouldShowSearchBar`, default `false`). The controller and the bar are created, or removed, once the view is loaded: a value set before `viewDidLoad` takes effect in `viewDidLoad`. Turning it off remov
- L51 `@objc public private(set) var searchController: CYLSearchController?` — The search controller, `nil` while `showsSearchBar` is off or the view is not loaded (QMUI `searchController`).
- L57 `@objc public private(set) var searchBar: CYLSearchBarView?` — The search bar that is the table header, `nil` while `showsSearchBar` is off or the view is not loaded (QMUI `searchBar`).
- L63 `@objc public var hidesSearchBarWhenEmptyViewShowing = false` — Whether the search bar leaves the table header while an empty view shows and returns when it is hidden (QMUI `shouldHideSearchBarWhenEmptyViewShowing`, default `false`).
- L69 `@objc public var hidesSearchBarInitially = false` — Whether the table is scrolled so that the search bar is out of sight when it is first shown (QMUI `shouldHideTableHeaderViewInitial`, default `false`), and again each time the bar returns after an empty view.
- L74 `@objc public var isEmptyViewShowing: Bool { emptyViewSlot.isShowing }` — Whether the empty view is on screen.
- L83 `open override func viewDidLoad()`
- L88 `open override func viewWillAppear(_ animated: Bool)`
- L96 `open override func viewDidLayoutSubviews()`
- L108 `@objc open func setUpSearchBar() {}` — Called once after the search controller and the bar are created and before the bar becomes the table header: set the bar's style, margins and accessory views here (QMUI `initSearchController`, which subclasses extend).
- L115 `open func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {}` — Called with every text change of the search, also with "" (QMUI `searchController:updateResultsForSearchString:`); does nothing by default.
- L158 `@objc public func showEmptyView(text: String?, detailText: String?)` — Shows CYLTableViewPlaceHolder's placeholder with a title and an optional detail over the table (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`, without the button). With `hidesSearchBarWhenEmptyViewShowing` the search bar leaves the header.
- L166 `@objc public func showEmptyView(scenario: CYLPlaceholderScenario)` — Shows one of CYLTableViewPlaceHolder's scenarios over the table (the placeholder `CYLSearchView` shows for empty results).
- L174 `@objc public func hideEmptyView()` — Removes the empty view; with `hidesSearchBarWhenEmptyViewShowing` the search bar returns to the header, hidden again if `hidesSearchBarInitially` is on (issue #128).

## `Sources/CYLSearchBar/CYLSearchTagListHeader.swift`

CYLSearchTagListHeader.swift CYLSearchViewController The section header of a tag list (CollectionViewClassifyMenu's CYLTagListView): its trailing refresh icon. The header's title, the clear (trash) button and the 16 pt inset come from CollectionViewClassifyMenu; the Flutter and React Native bridges call this so that no example draws a header of its own (docs/animated-icon-component.md, "Default la

- L18 `public final class CYLSearchTagListHeader: NSObject` — The refresh icon and text of a tag list's section header, one place for every bridge.
- L23 `@objc public static var refreshImage: UIImage?` — The refresh icon, the SF Symbol "arrow.clockwise": the icon is the default, not a text button.
- L30 `@objc public static var refreshAccessibilityLabel: String` — The VoiceOver label of the refresh icon, in the language the app shows ("Refresh", 更新, 刷新, 重新整理).
- L39 `public static func applyRefreshIcon(to list: CYLTagListView)` — Sets the refresh icon as the icon of `list`'s header More button (`menuShowsMoreButton(inSection:)`), in place of the three dots.

## `Sources/CYLSearchBar/CYLSearchTagListStyle.swift`

CYLSearchTagListStyle.swift CYLSearchViewController The default look of the tag lists that sit with a search bar (recent searches, topics): capsule tags with a light border, a bold section header, one 16 pt inset. It is set here, in the search bar core, through the public API of CollectionViewClassifyMenu's CYLMenuStyle; the tag list itself is not changed. The Flutter and React Native bridges call

- L19 `public final class CYLSearchTagListStyle: NSObject` — The search bar core's default style of a tag list, the look of the iOS example's recent searches.
- L25 `@objc public static var tagCornerRadius: CGFloat = CYLAnimatedItemCornerRadiusCapsule` — The corner radius of every tag, in points. The default `CYLAnimatedItemCornerRadiusCapsule` (CYLAnimatedItem's one named constant, 1000; pass it, never the literal) is a capsule, as in the iOS example's recent searches; 0 is square corners; another value is a 
- L31 `@objc public static var tagBackgroundStyle: CYLTagBackgroundStyle = .flat` — The background of every tag, handed to CollectionViewClassifyMenu's `CYLMenuStyle.backgroundStyle`: `.flat` by default (the tag's own colors), `.liquidGlass` for the glass material (flat below iOS 26).
- L36 `@objc public static var styleCustomizer: ((CYLMenuStyle) -> Void)?` — Called with the style after the defaults are set, to change any value of it. nil by default.
- L44 `public static func applyDefaults(to style: CYLMenuStyle)` — Sets the defaults on `style`: white tags with a 1 pt separator border and `tagCornerRadius`, 17 pt text, 36 pt high, 12 pt apart, a 16 pt section inset, a bold 20 pt section header and a clear list background (the page's color shows through, in dark mode too),
- L82 `public static func applyDefaultStyle(to list: CYLTagListView)` — Sets the defaults on `list`'s style (a copy, so the list's other values stay), and the refresh icon of its header (`CYLSearchTagListHeader`).
- L96 `public static func applyGrid(columns: Int, to list: CYLTagListView)` — Turns `list` into a grid of `columns` plain titles per row (CollectionViewClassifyMenu's `gridStyle(itemsPerRow:)`, 17 pt medium text, 36 pt rows 16 pt apart, a tag's own image at its own size), the look of the iOS example's discover topics, with the section h
- L122 `public static func applyBackgroundStyle(named name: String, to list: CYLTagListView)` — Sets the background of every tag of `list` by name, the one parameter of a Liquid Glass list: "liquidGlass" (case-insensitive) is the glass material (flat below iOS 26), anything else, "" or "flat" is flat. The list's other style values stay. For the Objective

## `Sources/CYLSearchBar/CYLSearchView.swift`

How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`).

- L9 `public enum CYLSearchSuggestionStyle: Int` — How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`).
- L24 `public protocol CYLSearchViewDelegate: NSObjectProtocol` — Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button.
- L102 `public protocol CYLSearchViewDataSource: NSObjectProtocol` — Supplies the results of a `CYLSearchView` and configures their cells (was `CYLSearchResultsDataSource`). While it is set and the query is not empty, `resultsTableView` lists the results under the search bar instead of the suggestions.
- L124 `public final class CYLSearchView: UIView, CYLSearchBarViewDelegate, UITableViewDataSource, UITableViewDelegate` — A search page that opens over its host view: a `CYLSearchBarView` at the top of the safe area, a divider, a list of suggestions filtered as you type, the results of `resultsDataSource`, and an optional content view of yours below (MiguelCatalan and lapism `Mat
- L132 `@objc public weak var delegate: CYLSearchViewDelegate?` — Receives the events of the search view.
- L137 `@objc public let searchBarView = CYLSearchBarView(frame: .zero)` — The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button).
- L142 `@objc public let dividerView = UIView()` — The line under the search bar.
- L147 `@objc public let suggestionsTableView = UITableView(frame: .zero, style: .plain)` — The table that lists the suggestions.
- L153 `@objc public var suggestionsTagView: CYLTagListView { suggestionArea.tagView }` — The tags that show the suggestions when `suggestionStyle` is `CYLSearchSuggestionStyleTags` (CollectionViewClassifyMenu's `CYLTagListView`). Style it directly: `style`, spacing, rows, colors.
- L163 `@objc public var suggestionsFoldControl: CYLMenuFoldControl` — The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`). An inline chevron as the last tag by default, as in the example's Discover page: tap it to show every row, again to fold. Position `CYLMenuFoldControlPositionNone` sho
- L174 `@objc public var suggestionsFoldedRowCount: UInt` — The rows of tag suggestions shown while folded. 2 by default; 0 shows every row.
- L187 `@objc public var suggestionStyle: CYLSearchSuggestionStyle = .tags { didSet { updateSuggestionsVisibility() } }` — How the suggestions are shown: tags (`CYLSearchSuggestionStyleTags`, the default, folded to `suggestionsFoldedRowCount` rows with the fold control as the last tag) or a list (`CYLSearchSuggestionStyleList`). A tapped tag works like a tapped row.
- L193 `@objc public var showsEmptyResultsPlaceholder = false { didSet { refilter() } }` — Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty query matches no suggestion, in both suggestion styles, or `resultsDataSource` returns no result. NO by default.
- L200 `@objc public var noResultsText: String?` — The title of the empty results placeholder, with the bundled "no results" animation (the component `CYLSearchController.noResultsText` shows). A text that is not empty also turns the placeholder on, as `showsEmptyResultsPlaceholder` does; nil (the default) kee
- L214 `@objc public var emptyResultsScenario: CYLPlaceholderScenario = .noSearchResults` — The CYLTableViewPlaceHolder scenario of that placeholder. `CYLPlaceholderScenarioNoSearchResults` (an icon, a title and a hint) by default; `CYLPlaceholderScenarioNoContent` shows the plain empty state.
- L230 `@objc public var emptyResultsView: CYLPlaceholderStackView? { emptyResultsSlot.view as? CYLPlaceholderStackView }` — The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first time it is shown; nil before. Style it after it appears, or change `emptyResultsScenario`.
- L240 `@objc public weak var resultsDataSource: CYLSearchViewDataSource? { didSet { refilter() } }` — Supplies the results (was `CYLSearchController`'s and `CYLSearchResultsViewController`'s `searchDataSource`). While it is set and the query is not empty, `resultsTableView` lists them under the search bar and the suggestions are hidden; an empty result list sh
- L246 `@objc public let resultsTableView = UITableView(frame: .zero, style: .plain)` — The table that lists `searchResults` (was `CYLSearchResultsViewController.tableView`). Style it directly; its data source and delegate are the search view.
- L251 `@objc public private(set) var searchResults: [Any] = []` — The results of the current query, from `resultsDataSource`; empty while the suggestions are shown.
- L260 `@objc public var highlightsResultMatches: Bool` — Gives the first match of the query in each result row `resultMatchHighlightColor` (the tint color by default), after `resultsDataSource` configured the row; the text label and a list content configuration are both highlighted. `CYLSearchController` has the sam
- L268 `@objc public var resultMatchHighlightColor: UIColor?` — The color of the highlighted match. Nil (the default) uses the tint color.
- L280 `@objc public var resultsHeaderTitleProvider: ((String) -> String?)? { didSet { updateResultsHeader() } }` — Titles the results: while results show, a header above the first row says what this closure returns for the query (a footnote, `resultsHeaderTextColor`, a header trait for VoiceOver); nil from the closure, or no closure (the default), shows none.
- L285 `@objc public var resultsHeaderTextColor: UIColor? { didSet { updateResultsHeader() } }` — The color of the results header text. Nil (the default) is the secondary label color.
- L306 `@objc public var refreshHandler: (() -> Void)?` — Pull-to-refresh of `resultsTableView` (CYLTableViewPlaceHolder's normal header inside): non-nil adds it, nil removes it. Call `-endRefreshing` on every completion path, and do not capture the view controller strongly.
- L313 `@objc public var isRefreshing: Bool` — YES while `resultsTableView` refreshes.
- L320 `@objc public func beginRefreshing()` — Starts the refresh of `resultsTableView`, as a pull would; calls `refreshHandler`.
- L327 `@objc public func endRefreshing()` — Stops the refresh of `resultsTableView`.
- L337 `public static func setRefreshHandler(_ handler: (() -> Void)?, for scrollView: UIScrollView)` — The same pull-to-refresh on a scroll view of yours, such as the table of a screen whose navigation item holds a `the system search controller` (the Issue #1317 page): non-nil adds CYLTableViewPlaceHolder's normal header with the handler, nil removes it. The ha
- L349 `public static func beginRefreshing(in scrollView: UIScrollView)` — Starts the refresh of a scroll view set up with `+setRefreshHandler:forScrollView:`.
- L358 `public static func endRefreshing(in scrollView: UIScrollView)` — Stops the refresh of a scroll view set up with `+setRefreshHandler:forScrollView:`. Call it on every completion path of the handler.
- L366 `public static func isRefreshing(in scrollView: UIScrollView) -> Bool` — YES while a scroll view set up with `+setRefreshHandler:forScrollView:` refreshes.
- L383 `@objc public var dividerColor: UIColor!` — The color of `dividerView` (lapism `setDividerColor`). `separatorColor` by default; clear hides it.
- L392 `@objc public var contentView: UIView?` — A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a history, anything. Nil by default.
- L406 `@objc public var scrimColor: UIColor? { didSet { applyStyle() } }` — The color behind the page while it is open (lapism `setScrimColor`). Nil (none) by default; the page itself uses `backgroundColor`, `systemBackgroundColor` by default.
- L413 `@objc public var suggestions: [String] = [] { didSet { refilter() } }` — The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`).
- L419 `@objc public var suggestionFilter: ((String, String) -> Bool)? { didSet { refilter() } }` — Decides whether a suggestion matches the query. Nil uses a case- and diacritic-insensitive "contains" test. An empty query matches nothing unless `showsSuggestionsForEmptyQuery` is YES.
- L424 `@objc public var showsSuggestionsForEmptyQuery = false { didSet { refilter() } }` — Lists every suggestion while the query is empty. NO by default.
- L429 `@objc public private(set) var filteredSuggestions: [String] = []` — The suggestions that match the current query, in their original order.
- L435 `@objc public var suggestionImage: UIImage? = UIImage(systemName: "magnifyingglass") { didSet { suggestionsTableView.reloadData() } }` — The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). `magnifyingglass` by default; nil shows none.
- L440 `@objc public var suggestionImageTintColor: UIColor!` — The tint of `suggestionImage`. `secondaryLabelColor` by default.
- L448 `@objc public var suggestionBackgroundColor: UIColor?` — The background of the suggestion rows (`setSuggestionBackground`). Nil keeps the page background.
- L458 `@objc public var suggestionTextColor: UIColor!` — The color of the suggestion text. `labelColor` by default.
- L467 `@objc public var suggestionLineBreakMode: NSLineBreakMode = .byWordWrapping { didSet { suggestionsTableView.reloadData() } }` — How a long suggestion is cut (MaterialSearchView `setEllipsize`). `NSLineBreakByWordWrapping` by default (whole text on several lines); `NSLineBreakByTruncatingTail` keeps one line with an ellipsis.
- L473 `@objc public var submitsOnSuggestionSelection = false` — Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). NO by default: the field shows it and the person can edit it.
- L478 `@objc public var suggestionCellConfiguration: ((UITableViewCell, String, UInt) -> Void)? { didSet { suggestionsTableView.reloadData() } }` — Configures each suggestion cell after the defaults (a custom adapter's `getView`). Optional.
- L488 `@objc public var suggestionCachePolicy: CYLSearchSuggestionCachePolicy = .database { didSet { rebuildSuggestionCache() } }` — Where submitted queries are cached for the suggestion list (`CYLSearchSuggestionCachePolicyDatabase`, a local SQLite database, by default). While the query is empty, the list shows the cached queries, newest first, under a header whose delete button clears the
- L493 `@objc public var suggestionCacheName = "CYLSearchView" { didSet { rebuildSuggestionCache() } }` — Separates the caches of different search screens. "CYLSearchView" by default.
- L499 `@objc public var suggestionCache: CYLSearchSuggestionCache? { didSet { refilter() } }` — The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy). Nil when the policy is `CYLSearchSuggestionCachePolicyNone`.
- L504 `@objc public var suggestionCacheHeaderView: UIView { suggestionArea.headerView }` — The header above the cached queries: a title and, at its trailing edge, `clearSuggestionCacheButton`.
- L511 `@objc public var showsSuggestionCacheHeader = true { didSet { setNeedsLayout(); refilter() } }` — Whether `suggestionCacheHeaderView` (the title and the trash icon) shows above the cached queries. YES by default; NO takes the header away, for a host that clears the history with its own control, for example a button in `suggestionsTableView.tableFooterView`
- L518 `@objc public var suggestionCacheFooterTitle: String? { didSet { updateSuggestionCacheFooter() } }` — A text button under the cached queries and the suggestions of the list style that clears the cache, with this title (a bordered footnote button centered below the last row). Nil (the default) shows none; with it, set `showsSuggestionCacheHeader` to NO to have 
- L535 `@objc public var suggestionCacheTitleLabel: UILabel { suggestionArea.titleLabel }` — The title of `suggestionCacheHeaderView` ("Recent searches").
- L540 `@objc public var clearSuggestionCacheButton: UIButton { suggestionArea.clearButton }` — Clears the whole cache (a trash icon at the top right of the suggestion list).
- L546 `@objc public var showsEmptySuggestionsPlaceholder = true { didSet { refilter() } }` — Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache holds nothing, so an open search is never a blank page. YES by default.
- L551 `@objc public var emptySuggestionsScenario: CYLPlaceholderScenario = .noContent` — The scenario of that placeholder. `CYLPlaceholderScenarioNoContent` by default.
- L561 `@objc public var emptySuggestionsView: CYLPlaceholderStackView? { emptySuggestionsSlot.view as? CYLPlaceholderStackView }` — The placeholder shown for an empty cache, created the first time it is shown; nil before.
- L568 `@objc public var focusesSearchFieldOnShow = true` — Focuses the search field when the search opens, which raises the keyboard. YES by default. NO opens the search with the suggestion list (or the empty placeholder) and the keyboard down; the field is focused when the person taps it.
- L585 `@objc(isSearchOpen) public var searchOpen: Bool { presentationState.isActive }` — YES while the search view is open (MaterialSearchView `isSearchOpen`).
- L591 `@objc public var isActive: Bool` — Whether the search is active, changed without animation (`CYLSearchController.isActive`); the same state as `searchOpen`: YES opens the search view, NO closes it.
- L600 `@objc public func setActive(_ active: Bool, animated: Bool)` — Opens or closes the search view (`CYLSearchController.setActive(_:animated:)`), like `showSearch(animated:)` and `closeSearch(animated:)`.
- L609 `@objc public var supportsSwipeToDismissSearch = false` — Whether a swipe from the left screen edge leaves the search, as `CYLSearchController.supportsSwipeToDismissSearch` does: the page follows the finger and the search closes when it was dragged past a quarter of the width, moving right. NO by default.
- L622 `@objc public var animationDuration: TimeInterval = 0.25` — The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default.
- L627 `@objc public var closesOnSubmit = true` — Closes the search view after a submitted query that the delegate did not handle. YES by default.
- L632 `@objc public var query: String?` — The current query (lapism `getTextQuery`).
- L640 `override public var backgroundColor: UIColor?` — The page background (the view itself only shows the scrim). `systemBackgroundColor` by default.
- L650 `override public init(frame: CGRect)`
- L658 `public required init?(coder: NSCoder)` — Creates the search view from an archive (a storyboard or a XIB).
- L731 `override public func layoutSubviews()`
- L787 `override public func safeAreaInsetsDidChange()`
- L799 `public func install(in view: UIView)` — Adds the search view over `view` (pinned to its edges) without opening it. `-showSearch` calls it with the key window's root view when the search view has no superview.
- L820 `@objc public func showSearch()` — Opens the search view with animation and starts editing (`showSearch`).
- L828 `public func showSearch(animated: Bool)` — Opens the search view and starts editing (`showSearch(animate)`).
- L878 `public func showSearch(in controller: UIViewController, animated: Bool = true)` — Installs the search view in `controller`'s view when it is elsewhere (pinned to its edges), then opens it like `-showSearchAnimated:` (was `-[CYLSearchController showInViewController:]`). Pass a navigation controller to open the page over its navigation bar.
- L888 `@objc public func closeSearch()` — Closes the search view with animation and ends editing (`closeSearch`).
- L896 `public func closeSearch(animated: Bool)` — Closes the search view and ends editing.
- L905 `public func closeSearch(animated: Bool, completion: (() -> Void)?)` — Closes the search view and ends editing, then calls `completion` once the view is hidden; at once when it is already closed (was `-[CYLSearchController hide:]`).
- L941 `override public func encodeRestorableState(with coder: NSCoder)` — Saves whether the search view is open and its query (`onSaveInstanceState`). UIKit calls it for a view with a `restorationIdentifier` inside a restored view controller.
- L950 `override public func decodeRestorableState(with coder: NSCoder)` — Restores the query and reopens the search view when it was open (`onRestoreInstanceState`).
- L1005 `override public func accessibilityPerformEscape() -> Bool`
- L1014 `public func attach(to item: UIBarButtonItem)` — Makes a bar button item open the search view (`setMenuItem`).
- L1030 `public func setSnapsHeader(_ snaps: Bool, for header: UIView, in tableView: UITableView)` — Keeps `header`, a search bar that is the header of `tableView`, scrollable out of sight above a short list and settles it fully shown or fully hidden when a drag ends, while this search view is not open (what `CYLSearchController.snapsHeaderSearchBar` does for
- L1050 `public func setQuery(_ query: String?, submit: Bool)` — Sets the query and submits it when `submit` is YES (`setQuery`, `setTextQuery`).
- L1093 `@objc public func showSuggestions()` — Lists the suggestions that match the current query (`showSuggestions`).
- L1102 `@objc public func reloadResults()` — Queries `resultsDataSource` again for the current query and reloads `resultsTableView` (was `reloadSearchResults` and `reloadResultsTableView`). Call it when the results changed, for example after a refresh.
- L1109 `@objc public func dismissSuggestions()` — Hides the suggestions and the results (`dismissSuggestions`).
- L1161 `@objc public func clearSuggestionCache()` — Removes every cached query (the delete button of `suggestionCacheHeaderView`) and shows the list again.
- L1180 `public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String)` — Filters the suggestions and reports the change.
- L1187 `public func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView)` — Reports the submitted query and closes unless the delegate handled it.
- L1212 `public func searchBarViewNavigationButtonClicked(_ searchBarView: CYLSearchBarView)` — Reports the navigation button, or closes the search view.
- L1223 `public func searchBarViewVoiceButtonClicked(_ searchBarView: CYLSearchBarView)` — Reports the voice button.
- L1230 `public func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView)` — Cancel closes the search view.
- L1237 `public func searchBarViewDidBeginEditing(_ searchBarView: CYLSearchBarView)` — Reports focus.
- L1244 `public func searchBarViewDidEndEditing(_ searchBarView: CYLSearchBarView)` — Reports the loss of focus.
- L1253 `public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int` — One row per result in `resultsTableView`, one row per matching suggestion while the suggestions are shown.
- L1264 `public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell` — A result row configured by `resultsDataSource`, or a suggestion row: icon, text, background, then `suggestionCellConfiguration`.
- L1296 `public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)` — Reports a tapped result (`-searchView:didSelectResult:`); for a suggestion, fills the field with it, reports it, and submits it when `submitsOnSuggestionSelection` is YES.
