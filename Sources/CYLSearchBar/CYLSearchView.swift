import CollectionViewClassifyMenu
import CYLTableViewPlaceHolder
import UIKit

/**
 * How the suggestions are shown under the search bar (`CYLSearchView.suggestionStyle`).
 */
@objc(CYLSearchSuggestionStyle)
public enum CYLSearchSuggestionStyle: Int {
    /**
     * One suggestion per row with its icon, in `suggestionsTableView`.
     */
    case list
    /**
     * Tags that wrap like words, in `suggestionsTagView` (CollectionViewClassifyMenu's `CYLTagListView`).
     */
    case tags
}

/**
 * Events of a `CYLSearchView`: opening and closing, the query, focus, suggestions and the voice button.
 */
@objc(CYLSearchViewDelegate)
public protocol CYLSearchViewDelegate: NSObjectProtocol {
    /**
     * The search view is about to open, before the animation starts (`CYLSearchControllerDelegate`'s
     * `willPresentSearchController:`).
     */
    @objc(searchViewWillShow:)
    optional func searchViewWillShow(_ searchView: CYLSearchView)

    /**
     * The search view is about to close, before the animation starts (`CYLSearchControllerDelegate`'s
     * `willDismissSearchController:`).
     */
    @objc(searchViewWillClose:)
    optional func searchViewWillClose(_ searchView: CYLSearchView)

    /**
     * The search view finished opening (MaterialSearchView `onSearchViewShown`).
     */
    @objc(searchViewDidShow:)
    optional func searchViewDidShow(_ searchView: CYLSearchView)

    /**
     * The search view finished closing (MaterialSearchView `onSearchViewClosed`).
     */
    @objc(searchViewDidClose:)
    optional func searchViewDidClose(_ searchView: CYLSearchView)

    /**
     * The query changed (`onQueryTextChange`).
     */
    @objc(searchView:textDidChange:)
    optional func searchView(_ searchView: CYLSearchView, textDidChange text: String)

    /**
     * The query was submitted (`onQueryTextSubmit`). Return YES when you handled it and the search view stays open;
     * return NO (or leave this method out) to let the search view close.
     */
    @objc(searchView:didSubmitText:)
    optional func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool

    /**
     * The field started or stopped editing (lapism `OnFocusChangeListener`).
     */
    @objc(searchView:didChangeFocus:)
    optional func searchView(_ searchView: CYLSearchView, didChangeFocus focused: Bool)

    /**
     * A suggestion was tapped (MaterialSearchView `setOnItemClickListener`). The field shows it first, and it is
     * submitted when `submitsOnSuggestionSelection` is YES.
     */
    @objc(searchView:didSelectSuggestion:atIndex:)
    optional func searchView(_ searchView: CYLSearchView, didSelectSuggestion suggestion: String, at index: UInt)

    /**
     * The voice button was tapped. Start speech recognition and pass the result to `-setQuery:submit:`.
     */
    @objc(searchViewVoiceButtonClicked:)
    optional func searchViewVoiceButtonClicked(_ searchView: CYLSearchView)

    /**
     * The navigation button (the back arrow by default) was tapped. Without this method it closes the search view.
     */
    @objc(searchViewNavigationButtonClicked:)
    optional func searchViewNavigationButtonClicked(_ searchView: CYLSearchView)

    /**
     * A row of `resultsTableView` was tapped (was `-searchResultsViewController:didSelectResult:`).
     */
    @objc(searchView:didSelectResult:)
    optional func searchView(_ searchView: CYLSearchView, didSelectResult result: Any)
}

/**
 * Supplies the results of a `CYLSearchView` and configures their cells (was `CYLSearchResultsDataSource`). While it is
 * set and the query is not empty, `resultsTableView` lists the results under the search bar instead of the
 * suggestions.
 */
@objc(CYLSearchViewDataSource)
public protocol CYLSearchViewDataSource: NSObjectProtocol {
    /**
     * The results for `query` (never empty: an empty query shows the suggestions instead).
     */
    @objc(searchView:resultsForQuery:)
    func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any]

    /**
     * Shows `result` in `cell`, a row of `resultsTableView`.
     */
    @objc(searchView:configureResultCell:withResult:)
    func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any)
}

/**
 * A search page that opens over its host view: a `CYLSearchBarView` at the top of the safe area, a divider, a list
 * of suggestions filtered as you type, the results of `resultsDataSource`, and an optional content view of yours
 * below (MiguelCatalan and lapism `MaterialSearchView`). It also owns the pull-to-refresh of the search screens
 * (`refreshHandler`, and the class methods for a scroll view of yours), built on CYLTableViewPlaceHolder. The page is
 * opaque, so the bar never covers a view of the host.
 */
@objc(CYLSearchView)
public final class CYLSearchView: UIView, CYLSearchBarViewDelegate, UITableViewDataSource, UITableViewDelegate {

    private static let cellIdentifier = "CYLSearchSuggestionCell"
    private static let resultCellIdentifier = "CYLSearchResultCell"

    /**
     * Receives the events of the search view.
     */
    @objc public weak var delegate: CYLSearchViewDelegate?

    /**
     * The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button).
     */
    @objc public let searchBarView = CYLSearchBarView(frame: .zero)

    /**
     * The line under the search bar.
     */
    @objc public let dividerView = UIView()

    /**
     * The table that lists the suggestions.
     */
    @objc public let suggestionsTableView = UITableView(frame: .zero, style: .plain)

    /**
     * The tags that show the suggestions when `suggestionStyle` is `CYLSearchSuggestionStyleTags`
     * (CollectionViewClassifyMenu's `CYLTagListView`). Style it directly: `style`, spacing, rows, colors.
     */
    @objc public var suggestionsTagView: CYLTagListView { suggestionArea.tagView }

    // The tags and the history header, one implementation shared with `CYLSearchController`'s launch view.
    private let suggestionArea = CYLSearchSuggestionArea()

    /**
     * The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`). An inline chevron as
     * the last tag by default, as in the example's Discover page: tap it to show every row, again to fold. Position
     * `CYLMenuFoldControlPositionNone` shows every tag without a control.
     */
    @objc public var suggestionsFoldControl: CYLMenuFoldControl {
        get { suggestionsTagView.foldControl }
        set {
            suggestionsTagView.foldControl = newValue
            updateSuggestionsVisibility()
        }
    }

    /**
     * The rows of tag suggestions shown while folded. 2 by default; 0 shows every row.
     */
    @objc public var suggestionsFoldedRowCount: UInt {
        get { UInt(suggestionsTagView.defaultVisibleRows) }
        set {
            suggestionsTagView.defaultVisibleRows = Int(newValue)
            updateSuggestionsVisibility()
        }
    }

    /**
     * How the suggestions are shown: tags (`CYLSearchSuggestionStyleTags`, the default, folded to
     * `suggestionsFoldedRowCount` rows with the fold control as the last tag) or a list
     * (`CYLSearchSuggestionStyleList`). A tapped tag works like a tapped row.
     */
    @objc public var suggestionStyle: CYLSearchSuggestionStyle = .tags { didSet { updateSuggestionsVisibility() } }

    /**
     * Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty
     * query matches no suggestion, in both suggestion styles, or `resultsDataSource` returns no result. NO by default.
     */
    @objc public var showsEmptyResultsPlaceholder = false { didSet { refilter() } }

    /**
     * The title of the empty results placeholder, with the bundled "no results" animation (the component
     * `CYLSearchController.noResultsText` shows). A text that is not empty also turns the placeholder on, as
     * `showsEmptyResultsPlaceholder` does; nil (the default) keeps `emptyResultsScenario`.
     */
    @objc public var noResultsText: String? {
        didSet {
            emptyResultsSlot.remove()
            refilter()
        }
    }

    // Whether the placeholder for empty results is on: its switch, or a text of its own.
    private var showsEmptyResults: Bool { showsEmptyResultsPlaceholder || !(noResultsText ?? "").isEmpty }

    /**
     * The CYLTableViewPlaceHolder scenario of that placeholder. `CYLPlaceholderScenarioNoSearchResults` (an icon, a
     * title and a hint) by default; `CYLPlaceholderScenarioNoContent` shows the plain empty state.
     */
    @objc public var emptyResultsScenario: CYLPlaceholderScenario = .noSearchResults {
        didSet {
            emptyResultsSlot.remove()
            refilter()
        }
    }

    // The empty views of both placeholders, one component shared with `CYLSearchController` and
    // `CYLSearchTableViewController`.
    private let emptyResultsSlot = CYLSearchEmptyViewSlot()
    private let emptySuggestionsSlot = CYLSearchEmptyViewSlot()

    /**
     * The placeholder shown for empty results (CYLTableViewPlaceHolder's `CYLPlaceholderStackView`), created the first
     * time it is shown; nil before. Style it after it appears, or change `emptyResultsScenario`.
     */
    @objc public var emptyResultsView: CYLPlaceholderStackView? { emptyResultsSlot.view as? CYLPlaceholderStackView }

    // MARK: - Results

    /**
     * Supplies the results (was `CYLSearchController`'s and `CYLSearchResultsViewController`'s `searchDataSource`).
     * While it is set and the query is not empty, `resultsTableView` lists them under the search bar and the
     * suggestions are hidden; an empty result list shows the empty-results placeholder when
     * `showsEmptyResultsPlaceholder` is YES. Nil (the default) keeps the suggestions only.
     */
    @objc public weak var resultsDataSource: CYLSearchViewDataSource? { didSet { refilter() } }

    /**
     * The table that lists `searchResults` (was `CYLSearchResultsViewController.tableView`). Style it directly; its
     * data source and delegate are the search view.
     */
    @objc public let resultsTableView = UITableView(frame: .zero, style: .plain)

    /**
     * The results of the current query, from `resultsDataSource`; empty while the suggestions are shown.
     */
    @objc public private(set) var searchResults: [Any] = []

    private var resultHighlight = CYLSearchResultHighlight() { didSet { resultsTableView.reloadData() } }

    /**
     * Gives the first match of the query in each result row `resultMatchHighlightColor` (the tint color by default), after
     * `resultsDataSource` configured the row; the text label and a list content configuration are both highlighted.
     * `CYLSearchController` has the same option. NO by default.
     */
    @objc public var highlightsResultMatches: Bool {
        get { resultHighlight.isEnabled }
        set { resultHighlight.isEnabled = newValue }
    }

    /**
     * The color of the highlighted match. Nil (the default) uses the tint color.
     */
    @objc public var resultMatchHighlightColor: UIColor? {
        get { resultHighlight.color }
        set { resultHighlight.color = newValue }
    }

    private var resultsVisible = false

    /**
     * Titles the results: while results show, a header above the first row says what this closure returns for the query
     * (a footnote, `resultsHeaderTextColor`, a header trait for VoiceOver); nil from the closure, or no closure (the
     * default), shows none.
     */
    @objc public var resultsHeaderTitleProvider: ((String) -> String?)? { didSet { updateResultsHeader() } }

    /**
     * The color of the results header text. Nil (the default) is the secondary label color.
     */
    @objc public var resultsHeaderTextColor: UIColor? { didSet { updateResultsHeader() } }

    private let resultsHeaderView = CYLSearchResultsHeaderView()

    private func updateResultsHeader() {
        let query = searchBarView.text ?? ""
        guard resultsVisible, let title = resultsHeaderTitleProvider?(query) else {
            if resultsTableView.tableHeaderView === resultsHeaderView { resultsTableView.tableHeaderView = nil }
            return
        }
        resultsHeaderView.configure(title: title, color: resultsHeaderTextColor ?? .secondaryLabel)
        resultsHeaderView.frame.size = CGSize(width: resultsTableView.bounds.width, height: CYLSearchResultsHeaderView.height)
        resultsTableView.tableHeaderView = resultsHeaderView
    }

    // MARK: - Refresh

    /**
     * Pull-to-refresh of `resultsTableView` (CYLTableViewPlaceHolder's normal header inside): non-nil adds it, nil
     * removes it. Call `-endRefreshing` on every completion path, and do not capture the view controller strongly.
     */
    @objc public var refreshHandler: (() -> Void)? {
        didSet { Self.setRefreshHandler(refreshHandler, for: resultsTableView) }
    }

    /**
     * YES while `resultsTableView` refreshes.
     */
    @objc public var isRefreshing: Bool {
        Self.isRefreshing(in: resultsTableView)
    }

    /**
     * Starts the refresh of `resultsTableView`, as a pull would; calls `refreshHandler`.
     */
    @objc public func beginRefreshing() {
        Self.beginRefreshing(in: resultsTableView)
    }

    /**
     * Stops the refresh of `resultsTableView`.
     */
    @objc public func endRefreshing() {
        Self.endRefreshing(in: resultsTableView)
    }

    /**
     * The same pull-to-refresh on a scroll view of yours, such as the table of a screen whose navigation item holds a
     * `the system search controller` (the Issue #1317 page): non-nil adds CYLTableViewPlaceHolder's normal header with the
     * handler, nil removes it. The handler must not capture its view controller strongly.
     */
    @objc(setRefreshHandler:forScrollView:)
    public static func setRefreshHandler(_ handler: (() -> Void)?, for scrollView: UIScrollView) {
        guard let handler else {
            scrollView.cyl_header = nil
            return
        }
        scrollView.cyl_header = CYLRefreshNormalHeader(refreshingBlock: handler)
    }

    /**
     * Starts the refresh of a scroll view set up with `+setRefreshHandler:forScrollView:`.
     */
    @objc(beginRefreshingInScrollView:)
    public static func beginRefreshing(in scrollView: UIScrollView) {
        scrollView.cyl_header?.beginRefreshing()
    }

    /**
     * Stops the refresh of a scroll view set up with `+setRefreshHandler:forScrollView:`. Call it on every completion
     * path of the handler.
     */
    @objc(endRefreshingInScrollView:)
    public static func endRefreshing(in scrollView: UIScrollView) {
        scrollView.cyl_header?.endRefreshing()
    }

    /**
     * YES while a scroll view set up with `+setRefreshHandler:forScrollView:` refreshes.
     */
    @objc(isRefreshingInScrollView:)
    public static func isRefreshing(in scrollView: UIScrollView) -> Bool {
        scrollView.cyl_header?.isRefreshing ?? false
    }

    private var emptyResultsVisible = false
    private let pageView = UIView()
    private let scrimView = CYLSearchDimmingView()
    private var suggestionsVisible = false
    private var keyboardOverlap: CGFloat { keyboard?.overlap ?? 0 }
    private var keyboard: CYLSearchKeyboardOverlap?
    private var customDividerColor: UIColor?
    private var customSuggestionTextColor: UIColor?
    private var customSuggestionImageTintColor: UIColor?

    /**
     * The color of `dividerView` (lapism `setDividerColor`). `separatorColor` by default; clear hides it.
     */
    @objc public var dividerColor: UIColor! {
        get { customDividerColor ?? .separator }
        set { customDividerColor = newValue; applyStyle() }
    }

    /**
     * A view of yours shown under the divider, behind the suggestions (lapism `addView`): a results list, a
     * history, anything. Nil by default.
     */
    @objc public var contentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let contentView {
                pageView.insertSubview(contentView, belowSubview: resultsTableView)
            }
            setNeedsLayout()
        }
    }

    /**
     * The color behind the page while it is open (lapism `setScrimColor`). Nil (none) by default; the page itself
     * uses `backgroundColor`, `systemBackgroundColor` by default.
     */
    @objc public var scrimColor: UIColor? { didSet { applyStyle() } }

    // MARK: - Suggestions

    /**
     * The suggestions to filter as the text changes (MaterialSearchView `setSuggestions`).
     */
    @objc public var suggestions: [String] = [] { didSet { refilter() } }

    /**
     * Decides whether a suggestion matches the query. Nil uses a case- and diacritic-insensitive "contains" test.
     * An empty query matches nothing unless `showsSuggestionsForEmptyQuery` is YES.
     */
    @objc public var suggestionFilter: ((String, String) -> Bool)? { didSet { refilter() } }

    /**
     * Lists every suggestion while the query is empty. NO by default.
     */
    @objc public var showsSuggestionsForEmptyQuery = false { didSet { refilter() } }

    /**
     * The suggestions that match the current query, in their original order.
     */
    @objc public private(set) var filteredSuggestions: [String] = []

    /**
     * The icon before each suggestion (MaterialSearchView `setSuggestionIcon`). `magnifyingglass` by default; nil
     * shows none.
     */
    @objc public var suggestionImage: UIImage? = UIImage(systemName: "magnifyingglass") { didSet { suggestionsTableView.reloadData() } }

    /**
     * The tint of `suggestionImage`. `secondaryLabelColor` by default.
     */
    @objc public var suggestionImageTintColor: UIColor! {
        get { customSuggestionImageTintColor ?? .secondaryLabel }
        set { customSuggestionImageTintColor = newValue; suggestionsTableView.reloadData() }
    }

    /**
     * The background of the suggestion rows (`setSuggestionBackground`). Nil keeps the page background.
     */
    @objc public var suggestionBackgroundColor: UIColor? {
        didSet {
            suggestionsTableView.backgroundColor = suggestionBackgroundColor ?? .clear
            suggestionsTableView.reloadData()
        }
    }

    /**
     * The color of the suggestion text. `labelColor` by default.
     */
    @objc public var suggestionTextColor: UIColor! {
        get { customSuggestionTextColor ?? .label }
        set { customSuggestionTextColor = newValue; suggestionsTableView.reloadData() }
    }

    /**
     * How a long suggestion is cut (MaterialSearchView `setEllipsize`). `NSLineBreakByWordWrapping` by default (whole
     * text on several lines); `NSLineBreakByTruncatingTail` keeps one line with an ellipsis.
     */
    @objc public var suggestionLineBreakMode: NSLineBreakMode = .byWordWrapping { didSet { suggestionsTableView.reloadData() } }

    /**
     * Submits a suggestion as soon as it is tapped (`setSubmitOnClick`). NO by default: the field shows it and the
     * person can edit it.
     */
    @objc public var submitsOnSuggestionSelection = false

    /**
     * Configures each suggestion cell after the defaults (a custom adapter's `getView`). Optional.
     */
    @objc public var suggestionCellConfiguration: ((UITableViewCell, String, UInt) -> Void)? { didSet { suggestionsTableView.reloadData() } }

    // MARK: - Suggestion cache

    /**
     * Where submitted queries are cached for the suggestion list (`CYLSearchSuggestionCachePolicyDatabase`, a local
     * SQLite database, by default). While the query is empty, the list shows the cached queries, newest first, under a
     * header whose delete button clears them; while typing, matching cached queries come before matching
     * `suggestions`. `CYLSearchSuggestionCachePolicyNone` turns the cache off.
     */
    @objc public var suggestionCachePolicy: CYLSearchSuggestionCachePolicy = .database { didSet { rebuildSuggestionCache() } }

    /**
     * Separates the caches of different search screens. "CYLSearchView" by default.
     */
    @objc public var suggestionCacheName = "CYLSearchView" { didSet { rebuildSuggestionCache() } }

    /**
     * The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy).
     * Nil when the policy is `CYLSearchSuggestionCachePolicyNone`.
     */
    @objc public var suggestionCache: CYLSearchSuggestionCache? { didSet { refilter() } }

    /**
     * The header above the cached queries: a title and, at its trailing edge, `clearSuggestionCacheButton`.
     */
    @objc public var suggestionCacheHeaderView: UIView { suggestionArea.headerView }

    /**
     * Whether `suggestionCacheHeaderView` (the title and the trash icon) shows above the cached queries. YES by default;
     * NO takes the header away, for a host that clears the history with its own control, for example a button in
     * `suggestionsTableView.tableFooterView` that calls `clearSuggestionCache()`.
     */
    @objc public var showsSuggestionCacheHeader = true { didSet { setNeedsLayout(); refilter() } }

    /**
     * A text button under the cached queries and the suggestions of the list style that clears the cache, with this
     * title (a bordered footnote button centered below the last row). Nil (the default) shows none; with it, set
     * `showsSuggestionCacheHeader` to NO to have the text button instead of the trash icon.
     */
    @objc public var suggestionCacheFooterTitle: String? { didSet { updateSuggestionCacheFooter() } }

    private func updateSuggestionCacheFooter() {
        guard let title = suggestionCacheFooterTitle else {
            if suggestionsTableView.tableFooterView is CYLSearchClearFooterView { suggestionsTableView.tableFooterView = nil }
            return
        }
        let footer = (suggestionsTableView.tableFooterView as? CYLSearchClearFooterView) ?? CYLSearchClearFooterView()
        footer.button.setTitle(title, for: .normal)
        footer.onTap = { [weak self] in self?.clearSuggestionCache() }
        footer.frame.size = CGSize(width: suggestionsTableView.bounds.width, height: CYLSearchClearFooterView.height)
        suggestionsTableView.tableFooterView = footer
    }

    /**
     * The title of `suggestionCacheHeaderView` ("Recent searches").
     */
    @objc public var suggestionCacheTitleLabel: UILabel { suggestionArea.titleLabel }

    /**
     * Clears the whole cache (a trash icon at the top right of the suggestion list).
     */
    @objc public var clearSuggestionCacheButton: UIButton { suggestionArea.clearButton }

    /**
     * Shows CYLTableViewPlaceHolder's placeholder for `emptySuggestionsScenario` while the query is empty and the cache
     * holds nothing, so an open search is never a blank page. YES by default.
     */
    @objc public var showsEmptySuggestionsPlaceholder = true { didSet { refilter() } }

    /**
     * The scenario of that placeholder. `CYLPlaceholderScenarioNoContent` by default.
     */
    @objc public var emptySuggestionsScenario: CYLPlaceholderScenario = .noContent {
        didSet {
            emptySuggestionsSlot.remove()
            refilter()
        }
    }

    /**
     * The placeholder shown for an empty cache, created the first time it is shown; nil before.
     */
    @objc public var emptySuggestionsView: CYLPlaceholderStackView? { emptySuggestionsSlot.view as? CYLPlaceholderStackView }

    /**
     * Focuses the search field when the search opens, which raises the keyboard. YES by default. NO opens the search
     * with the suggestion list (or the empty placeholder) and the keyboard down; the field is focused when the person
     * taps it.
     */
    @objc public var focusesSearchFieldOnShow = true

    private var showsCachedQueries = false

    /**
     * The height of the cached queries' header: 0 without cached queries or with `showsSuggestionCacheHeader` off.
     */
    private var cacheHeaderHeight: CGFloat {
        suggestionArea.headerHeight(shown: showsCachedQueries && showsSuggestionCacheHeader)
    }
    private var emptySuggestionsVisible = false

    // MARK: - Opening and closing

    /**
     * YES while the search view is open (MaterialSearchView `isSearchOpen`).
     */
    @objc(isSearchOpen) public var searchOpen: Bool { presentationState.isActive }

    /**
     * Whether the search is active, changed without animation (`CYLSearchController.isActive`); the same state as
     * `searchOpen`: YES opens the search view, NO closes it.
     */
    @objc public var isActive: Bool {
        @objc(isActive) get { searchOpen }
        @objc(setActive:) set { setActive(newValue, animated: false) }
    }

    /**
     * Opens or closes the search view (`CYLSearchController.setActive(_:animated:)`), like `showSearch(animated:)` and
     * `closeSearch(animated:)`.
     */
    @objc public func setActive(_ active: Bool, animated: Bool) {
        if active { showSearch(animated: animated) } else { closeSearch(animated: animated) }
    }

    /**
     * Whether a swipe from the left screen edge leaves the search, as `CYLSearchController.supportsSwipeToDismissSearch`
     * does: the page follows the finger and the search closes when it was dragged past a quarter of the width, moving
     * right. NO by default.
     */
    @objc public var supportsSwipeToDismissSearch = false {
        didSet { swipeGestureRecognizer.isEnabled = supportsSwipeToDismissSearch }
    }

    // The active state, one implementation shared with `CYLSearchController`: its events feed `CYLSearchViewDelegate`.
    private let presentationState = CYLSearchPresentationState()
    private var historyObserver: CYLSearchHistoryObserver?
    private var isRecordingHistory = false
    private(set) lazy var swipeGestureRecognizer = CYLSearchEdgeSwipe.makeGesture(target: self, action: #selector(handleSwipe(_:)))

    /**
     * The length of the open and close animations, in seconds (`setAnimationDuration`). 0.25 by default.
     */
    @objc public var animationDuration: TimeInterval = 0.25

    /**
     * Closes the search view after a submitted query that the delegate did not handle. YES by default.
     */
    @objc public var closesOnSubmit = true

    /**
     * The current query (lapism `getTextQuery`).
     */
    @objc public var query: String? {
        get { searchBarView.text }
        set { setQuery(newValue, submit: false) }
    }

    /**
     * The page background (the view itself only shows the scrim). `systemBackgroundColor` by default.
     */
    override public var backgroundColor: UIColor? {
        get { pageView.backgroundColor }
        set {
            super.backgroundColor = .clear
            pageView.backgroundColor = newValue ?? .systemBackground
        }
    }

    // MARK: - Initializers

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /**
     * Creates the search view from an archive (a storyboard or a XIB).
     */
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        isHidden = true
        super.backgroundColor = .clear
        scrimView.onTap = { [weak self] in self?.closeSearch() }
        addSubview(scrimView)
        pageView.backgroundColor = .systemBackground
        pageView.clipsToBounds = true
        addSubview(pageView)
        searchBarView.navigationIcon = .arrow
        searchBarView.fieldBackgroundColor = .clear
        searchBarView.delegate = self
        pageView.addSubview(searchBarView)
        dividerView.isAccessibilityElement = false
        pageView.addSubview(dividerView)
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.keyboardDismissMode = .onDrag
        resultsTableView.tableFooterView = UIView()
        resultsTableView.accessibilityIdentifier = "CYLSearchResults"
        resultsTableView.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.title")
        resultsTableView.isHidden = true
        pageView.addSubview(resultsTableView)
        suggestionsTableView.dataSource = self
        suggestionsTableView.delegate = self
        suggestionsTableView.rowHeight = UITableView.automaticDimension
        suggestionsTableView.estimatedRowHeight = 48
        suggestionsTableView.keyboardDismissMode = .onDrag
        suggestionsTableView.backgroundColor = .clear
        suggestionsTableView.accessibilityLabel = CYLSearchResources.localizedString(forKey: "search.suggestions")
        suggestionsTableView.isHidden = true
        suggestionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
        pageView.addSubview(suggestionsTableView)
        suggestionArea.onHeightChange = { [weak self] in self?.setNeedsLayout() }
        suggestionArea.onSelect = { [weak self] index, _ in self?.selectSuggestion(at: index) }
        suggestionArea.onClear = { [weak self] in self?.clearSuggestionCache() }
        suggestionArea.install(in: pageView)
        rebuildSuggestionCache()
        // The history signal: another view or controller changed the history while this search is open.
        historyObserver = CYLSearchHistoryObserver(cache: { [weak self] in self?.suggestionCache }, changed: { [weak self] in
            guard let self, self.searchOpen, !self.isRecordingHistory else { return }
            self.refilter()
        })
        presentationState.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .willPresent: self.delegate?.searchViewWillShow?(self)
            case .didPresent: self.delegate?.searchViewDidShow?(self)
            case .willDismiss: self.delegate?.searchViewWillClose?(self)
            case .didDismiss: self.delegate?.searchViewDidClose?(self)
            }
        }
        swipeGestureRecognizer.isEnabled = false
        addGestureRecognizer(swipeGestureRecognizer)
        keyboard = CYLSearchKeyboardOverlap(host: { [weak self] in self }, changed: { [weak self] in self?.setNeedsLayout() })
        // iOS 26 softens the top edge of a scroll view with a blur: it would blur the first row under the search bar.
        CYLSearchSuggestionArea.hidesTopEdgeEffect(in: resultsTableView)
        CYLSearchSuggestionArea.hidesTopEdgeEffect(in: suggestionsTableView)
        applyStyle()
    }

    private func applyStyle() {
        dividerView.backgroundColor = dividerColor
        scrimView.color = scrimColor
        setNeedsLayout()
    }

    // MARK: - Layout

    override public func layoutSubviews() {
        super.layoutSubviews()
        let safe = safeAreaInsets
        let width = bounds.width
        let barHeight = searchBarView.intrinsicContentSize.height
        let dividerHeight = 1 / max(1, traitCollection.displayScale)
        let top = safe.top + barHeight + dividerHeight
        let bottom = bounds.height
        // With a scrim, the page is only as tall as its content and the host shows through below it; without one,
        // the page fills the view.
        var pageHeight = bottom
        if scrimColor != nil, contentView == nil {
            suggestionsTableView.layoutIfNeeded()
            let tags = suggestionStyle == .tags
            let emptyHeight = emptyResultsVisible ? (emptyResultsView?.systemLayoutSizeFitting(
                CGSize(width: width - safe.left - safe.right, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height ?? 0) : 0
            let headerHeight = cacheHeaderHeight
            let emptySuggestionsHeight = emptySuggestionsVisible ? (emptySuggestionsView?.systemLayoutSizeFitting(
                CGSize(width: width - safe.left - safe.right, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height ?? 0) : 0
            resultsTableView.layoutIfNeeded()
            let listHeight = emptyResultsVisible ? emptyHeight : resultsVisible ? resultsTableView.contentSize.height
                : emptySuggestionsVisible ? emptySuggestionsHeight : !suggestionsVisible ? 0
                : headerHeight + (tags ? suggestionsTagView.heightThatFitsWidth(width - safe.left - safe.right) : suggestionsTableView.contentSize.height)
            pageHeight = min(bottom, top + listHeight)
        }
        pageView.frame = CGRect(x: 0, y: 0, width: width, height: pageHeight)
        // The scrim lies only below the page, so nothing sits behind the search bar.
        scrimView.frame = CGRect(x: 0, y: pageHeight, width: width, height: max(0, bottom - pageHeight))
        scrimView.isHidden = scrimColor == nil || pageHeight >= bottom
        searchBarView.frame = CGRect(x: safe.left, y: safe.top, width: width - safe.left - safe.right, height: barHeight)
        dividerView.frame = CGRect(x: 0, y: safe.top + barHeight, width: width, height: dividerHeight)
        let below = CGRect(x: safe.left, y: top, width: width - safe.left - safe.right, height: max(0, pageHeight - top))
        contentView?.frame = below
        resultsTableView.frame = below
        // The cached queries' header takes the top of the list area; the list starts under it.
        let headerHeight = cacheHeaderHeight
        let list = suggestionArea.layout(in: below, headerHeight: headerHeight)
        suggestionsTableView.frame = list
        // The keyboard's part over the page: the lists scroll above it, and the placeholders end at it, so they centre in
        // the part the keyboard leaves visible (docs/core-todo.md, "the empty-results placeholder sits under the keyboard").
        let keyboardInset = max(0, keyboardOverlap - (bottom - pageHeight))
        let visible = below.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: min(keyboardInset, below.height), right: 0))
        emptyResultsView?.frame = visible
        emptySuggestionsView?.frame = visible
        var insets = suggestionsTableView.contentInset
        insets.bottom = max(keyboardInset, safe.bottom)
        suggestionsTableView.contentInset = insets
        suggestionsTableView.verticalScrollIndicatorInsets = insets
        var resultInsets = resultsTableView.contentInset
        resultInsets.bottom = insets.bottom
        resultsTableView.contentInset = resultInsets
        resultsTableView.verticalScrollIndicatorInsets = resultInsets
    }

    override public func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        setNeedsLayout()
    }

    // MARK: - Opening and closing

    /**
     * Adds the search view over `view` (pinned to its edges) without opening it. `-showSearch` calls it with the key
     * window's root view when the search view has no superview.
     */
    @objc(installInView:)
    public func install(in view: UIView) {
        if superview !== view {
            view.addSubview(self)
        }
        frame = view.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.bringSubviewToFront(self)
    }

    private func defaultHostView() -> UIView? {
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            if let window = scene.windows.first(where: \.isKeyWindow) {
                return window.rootViewController?.view ?? window
            }
        }
        return nil
    }

    /**
     * Opens the search view with animation and starts editing (`showSearch`).
     */
    @objc public func showSearch() {
        showSearch(animated: true)
    }

    /**
     * Opens the search view and starts editing (`showSearch(animate)`).
     */
    @objc(showSearchAnimated:)
    public func showSearch(animated: Bool) {
        if superview == nil {
            guard let host = defaultHostView() else {
                return
            }
            install(in: host)
        }
        superview?.bringSubviewToFront(self)
        if searchOpen {
            if focusesSearchFieldOnShow {
                searchBarView.showKeyboard()
            }
            return
        }
        presentationState.send(.willPresent)
        isHidden = false
        accessibilityViewIsModal = true
        refilter()
        setNeedsLayout()
        layoutIfNeeded()
        // `focusesSearchFieldOnShow` decides when the keyboard appears: now, or when the person taps the field.
        if focusesSearchFieldOnShow {
            searchBarView.showKeyboard()
        }
        let token = presentationState.generation
        let finish: (Bool) -> Void = { _ in
            // A close that began meanwhile has overtaken this opening.
            guard self.presentationState.generation == token else { return }
            UIAccessibility.post(notification: .screenChanged, argument: self.searchBarView.textField)
            self.presentationState.send(.didPresent)
        }
        guard animated, animationDuration > 0 else {
            alpha = 1
            finish(true)
            return
        }
        alpha = 0
        pageView.transform = CGAffineTransform(translationX: 0, y: -12)
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.pageView.transform = .identity
        }, completion: finish)
    }

    /**
     * Installs the search view in `controller`'s view when it is elsewhere (pinned to its edges), then opens it like
     * `-showSearchAnimated:` (was `-[CYLSearchController showInViewController:]`). Pass a navigation controller to
     * open the page over its navigation bar.
     */
    @objc(showSearchInViewController:animated:)
    public func showSearch(in controller: UIViewController, animated: Bool = true) {
        if superview !== controller.view {
            install(in: controller.view)
        }
        showSearch(animated: animated)
    }

    /**
     * Closes the search view with animation and ends editing (`closeSearch`).
     */
    @objc public func closeSearch() {
        closeSearch(animated: true, completion: nil)
    }

    /**
     * Closes the search view and ends editing.
     */
    @objc(closeSearchAnimated:)
    public func closeSearch(animated: Bool) {
        closeSearch(animated: animated, completion: nil)
    }

    /**
     * Closes the search view and ends editing, then calls `completion` once the view is hidden; at once when it is
     * already closed (was `-[CYLSearchController hide:]`).
     */
    @objc(closeSearchAnimated:completion:)
    public func closeSearch(animated: Bool, completion: (() -> Void)?) {
        guard searchOpen else {
            completion?()
            return
        }
        presentationState.send(.willDismiss)
        searchBarView.hideKeyboard()
        let token = presentationState.generation
        let finish: (Bool) -> Void = { _ in
            // A show that began meanwhile has overtaken this closing: the view stays on screen.
            guard self.presentationState.generation == token else {
                completion?()
                return
            }
            self.isHidden = true
            self.alpha = 1
            self.pageView.transform = .identity
            self.accessibilityViewIsModal = false
            UIAccessibility.post(notification: .screenChanged, argument: nil)
            self.presentationState.send(.didDismiss)
            completion?()
        }
        guard animated, animationDuration > 0 else {
            finish(true)
            return
        }
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.pageView.transform = CGAffineTransform(translationX: 0, y: -12)
        }, completion: finish)
    }

    /**
     * Saves whether the search view is open and its query (`onSaveInstanceState`). UIKit calls it for a view with a
     * `restorationIdentifier` inside a restored view controller.
     */
    override public func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(query ?? "", forKey: "CYLSearchViewQuery")
        coder.encode(searchOpen, forKey: "CYLSearchViewOpen")
    }

    /**
     * Restores the query and reopens the search view when it was open (`onRestoreInstanceState`).
     */
    override public func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let query = coder.decodeObject(of: NSString.self, forKey: "CYLSearchViewQuery") as String? {
            setQuery(query, submit: false)
        }
        if coder.decodeBool(forKey: "CYLSearchViewOpen") {
            showSearch(animated: false)
        }
    }

    // MARK: - Swipe to dismiss

    @objc private func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began: swipeBegan()
        case .changed: swipeChanged(translationX: gesture.translation(in: self).x)
        case .ended: swipeEnded(velocityX: gesture.velocity(in: self).x)
        case .cancelled, .failed: swipeCancelled()
        default: break
        }
    }

    func swipeBegan() {
        guard searchOpen else { return }
        endEditing(true)
    }

    func swipeChanged(translationX: CGFloat) {
        guard searchOpen, bounds.width > 0 else { return }
        pageView.transform = CGAffineTransform(translationX: min(max(0, translationX), bounds.width), y: 0)
    }

    func swipeEnded(velocityX: CGFloat) {
        guard searchOpen else { return }
        let width = bounds.width
        let offset = pageView.transform.tx
        guard CYLSearchEdgeSwipe.completes(offset: offset, width: width, velocity: velocityX) else {
            swipeCancelled()
            return
        }
        UIView.animate(withDuration: CYLSearchEdgeSwipe.duration(distance: width - offset, width: width), delay: 0,
                       options: .curveEaseInOut, animations: {
            self.pageView.transform = CGAffineTransform(translationX: width, y: 0)
        }, completion: { _ in
            self.closeSearch(animated: false)
        })
    }

    func swipeCancelled() {
        UIView.animate(withDuration: CYLSearchEdgeSwipe.duration(distance: pageView.transform.tx, width: bounds.width), delay: 0,
                       options: .curveEaseInOut, animations: {
            self.pageView.transform = .identity
        })
    }

    override public func accessibilityPerformEscape() -> Bool {
        closeSearch()
        return true
    }

    /**
     * Makes a bar button item open the search view (`setMenuItem`).
     */
    @objc(attachToBarButtonItem:)
    public func attach(to item: UIBarButtonItem) {
        item.target = self
        item.action = #selector(showSearch as () -> Void)
    }

    // MARK: - Header snapping

    private static var snapperKey = 0

    /**
     * Keeps `header`, a search bar that is the header of `tableView`, scrollable out of sight above a short list and
     * settles it fully shown or fully hidden when a drag ends, while this search view is not open (what
     * `CYLSearchController.snapsHeaderSearchBar` does for its bar, QMUI issues #1160 and #1207). `snaps` NO takes the
     * inset and the settling away. A table view keeps one such handling, which a second call updates.
     */
    @objc(setSnapsHeader:forHeaderView:inTableView:)
    public func setSnapsHeader(_ snaps: Bool, for header: UIView, in tableView: UITableView) {
        let existing = objc_getAssociatedObject(tableView, &CYLSearchView.snapperKey) as? CYLSearchHeaderSnapper
        if let existing, existing.header === header {
            existing.isEnabled = snaps
            return
        }
        existing?.detach()
        let snapper = CYLSearchHeaderSnapper(tableView: tableView, searchBar: header) { [weak self] in
            self?.searchOpen == true
        }
        snapper.isEnabled = snaps
        objc_setAssociatedObject(tableView, &CYLSearchView.snapperKey, snapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - Query and suggestions

    /**
     * Sets the query and submits it when `submit` is YES (`setQuery`, `setTextQuery`).
     */
    @objc(setQuery:submit:)
    public func setQuery(_ query: String?, submit: Bool) {
        searchBarView.text = query
        queryChanged(query ?? "")
        if submit {
            searchBarView.submit()
        }
    }

    private func refilter() {
        let query = searchBarView.text ?? ""
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        // A results data source and a query: the results replace the suggestions.
        if let resultsDataSource, !trimmed.isEmpty {
            searchResults = resultsDataSource.searchView(self, resultsForQuery: query)
            resultsVisible = true
            showsCachedQueries = false
            filteredSuggestions = []
            suggestionsVisible = false
            emptyResultsVisible = showsEmptyResults && searchResults.isEmpty
            emptySuggestionsVisible = false
            updateSuggestionsVisibility()
            updateResultsHeader()
            return
        }
        searchResults = []
        resultsVisible = false
        updateResultsHeader()
        // An empty query lists the cached queries, newest first, under the header that clears them; the choice is the
        // suggestion area's.
        let resolution = CYLSearchSuggestionArea.resolve(cache: suggestionCache, suggestions: suggestions, query: query,
                                                         showsForEmptyQuery: showsSuggestionsForEmptyQuery,
                                                         filter: suggestionFilter)
        showsCachedQueries = resolution.showsHistory
        filteredSuggestions = resolution.titles
        suggestionsVisible = !filteredSuggestions.isEmpty
        emptyResultsVisible = showsEmptyResults && !trimmed.isEmpty && filteredSuggestions.isEmpty
        emptySuggestionsVisible = showsEmptySuggestionsPlaceholder && suggestionCache != nil && trimmed.isEmpty && filteredSuggestions.isEmpty
        updateSuggestionsVisibility()
    }

    /**
     * Lists the suggestions that match the current query (`showSuggestions`).
     */
    @objc public func showSuggestions() {
        refilter()
    }

    /**
     * Queries `resultsDataSource` again for the current query and reloads `resultsTableView` (was
     * `reloadSearchResults` and `reloadResultsTableView`). Call it when the results changed, for example after a
     * refresh.
     */
    @objc public func reloadResults() {
        refilter()
    }

    /**
     * Hides the suggestions and the results (`dismissSuggestions`).
     */
    @objc public func dismissSuggestions() {
        resultsVisible = false
        suggestionsVisible = false
        emptyResultsVisible = false
        emptySuggestionsVisible = false
        showsCachedQueries = false
        updateSuggestionsVisibility()
    }

    private func updateSuggestionsVisibility() {
        let tags = suggestionStyle == .tags
        suggestionsTableView.isHidden = !suggestionsVisible || tags
        suggestionsTagView.isHidden = !suggestionsVisible || !tags
        if tags {
            suggestionArea.setTitles(suggestionsVisible ? filteredSuggestions : [])
        }
        showOrHide(emptyResultsSlot, visible: emptyResultsVisible, scenario: emptyResultsScenario,
                   identifier: "CYLSearchEmptyResults", text: noResultsText)
        showOrHide(emptySuggestionsSlot, visible: emptySuggestionsVisible, scenario: emptySuggestionsScenario,
                   identifier: "CYLSearchEmptySuggestions")
        suggestionCacheHeaderView.isHidden = !(suggestionsVisible && showsCachedQueries && showsSuggestionCacheHeader)
        resultsTableView.isHidden = !resultsVisible
        resultsTableView.reloadData()
        suggestionsTableView.reloadData()
        setNeedsLayout()
    }

    private func showOrHide(_ slot: CYLSearchEmptyViewSlot, visible: Bool, scenario: CYLPlaceholderScenario, identifier: String,
                            text: String? = nil) {
        guard visible else {
            slot.hide()
            return
        }
        if slot.view == nil {
            if let text, !text.isEmpty {
                let message = CYLSearchEmptyView.message(text: text, detailText: nil)
                message.accessibilityIdentifier = identifier
                slot.adopt(message)
            } else {
                slot.adopt(CYLSearchEmptyView.scenario(scenario, identifier: identifier))
            }
        }
        slot.show(in: pageView, below: suggestionsTableView)
    }

    private func rebuildSuggestionCache() {
        suggestionCache = CYLSearchSuggestionStore.cache(policy: suggestionCachePolicy, name: suggestionCacheName)
    }

    /**
     * Removes every cached query (the delete button of `suggestionCacheHeaderView`) and shows the list again.
     */
    @objc public func clearSuggestionCache() {
        isRecordingHistory = true
        suggestionCache?.removeAllQueries()
        suggestionCache.map(CYLSearchSuggestionStore.announceChange(of:))
        isRecordingHistory = false
        refilter()
        UIAccessibility.post(notification: .announcement, argument: CYLSearchResources.localizedString(forKey: "search.recentCleared"))
    }

    private func queryChanged(_ text: String) {
        refilter()
        delegate?.searchView?(self, textDidChange: text)
    }

    // MARK: - CYLSearchBarViewDelegate

    /**
     * Filters the suggestions and reports the change.
     */
    public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        queryChanged(text)
    }

    /**
     * Reports the submitted query and closes unless the delegate handled it.
     */
    public func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) {
        let text = searchBarView.text ?? ""
        // Every submitted query is cached, so the list shows it the next time.
        isRecordingHistory = true
        suggestionCache?.addQuery(text)
        suggestionCache.map(CYLSearchSuggestionStore.announceChange(of:))
        isRecordingHistory = false
        let handled = delegate?.searchView?(self, didSubmitText: text) ?? false
        if !handled && closesOnSubmit {
            closeSearch()
        } else if !resultsVisible {
            // The results of the query stay; only the suggestions go away.
            dismissSuggestions()
        }
    }

    /**
     * Reports the navigation button, or closes the search view.
     */
    public func searchBarViewNavigationButtonClicked(_ searchBarView: CYLSearchBarView) {
        if let delegate, delegate.responds(to: #selector(CYLSearchViewDelegate.searchViewNavigationButtonClicked(_:))) {
            delegate.searchViewNavigationButtonClicked?(self)
        } else {
            closeSearch()
        }
    }

    /**
     * Reports the voice button.
     */
    public func searchBarViewVoiceButtonClicked(_ searchBarView: CYLSearchBarView) {
        delegate?.searchViewVoiceButtonClicked?(self)
    }

    /**
     * Cancel closes the search view.
     */
    public func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) {
        closeSearch()
    }

    /**
     * Reports focus.
     */
    public func searchBarViewDidBeginEditing(_ searchBarView: CYLSearchBarView) {
        delegate?.searchView?(self, didChangeFocus: true)
    }

    /**
     * Reports the loss of focus.
     */
    public func searchBarViewDidEndEditing(_ searchBarView: CYLSearchBarView) {
        delegate?.searchView?(self, didChangeFocus: false)
    }

    // MARK: - Table

    /**
     * One row per result in `resultsTableView`, one row per matching suggestion while the suggestions are shown.
     */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === resultsTableView {
            return resultsVisible ? searchResults.count : 0
        }
        return suggestionsVisible ? filteredSuggestions.count : 0
    }

    /**
     * A result row configured by `resultsDataSource`, or a suggestion row: icon, text, background, then
     * `suggestionCellConfiguration`.
     */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === resultsTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.resultCellIdentifier)
                ?? UITableViewCell(style: .default, reuseIdentifier: Self.resultCellIdentifier)
            if searchResults.indices.contains(indexPath.row) {
                resultsDataSource?.searchView(self, configureResultCell: cell, withResult: searchResults[indexPath.row])
                resultHighlight.apply(to: cell, query: searchBarView.text ?? "")
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
        let suggestion = filteredSuggestions[indexPath.row]
        var content = UIListContentConfiguration.cell()
        content.text = suggestion
        content.textProperties.color = suggestionTextColor
        content.textProperties.lineBreakMode = suggestionLineBreakMode
        content.textProperties.numberOfLines = suggestionLineBreakMode == .byWordWrapping || suggestionLineBreakMode == .byCharWrapping ? 0 : 1
        content.image = suggestionImage
        content.imageProperties.tintColor = suggestionImageTintColor
        cell.contentConfiguration = content
        var background = UIBackgroundConfiguration.listPlainCell()
        background.backgroundColor = suggestionBackgroundColor ?? .clear
        cell.backgroundConfiguration = background
        cell.accessibilityTraits.insert(.button)
        suggestionCellConfiguration?(cell, suggestion, UInt(indexPath.row))
        return cell
    }

    /**
     * Reports a tapped result (`-searchView:didSelectResult:`); for a suggestion, fills the field with it, reports it,
     * and submits it when `submitsOnSuggestionSelection` is YES.
     */
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView === resultsTableView {
            if searchResults.indices.contains(indexPath.row) {
                delegate?.searchView?(self, didSelectResult: searchResults[indexPath.row])
            }
            return
        }
        selectSuggestion(at: indexPath.row)
    }

    /**
     * A tapped row or tag: fills the field, reports it, and submits it when `submitsOnSuggestionSelection` is YES.
     */
    private func selectSuggestion(at index: Int) {
        guard filteredSuggestions.indices.contains(index) else {
            return
        }
        let suggestion = filteredSuggestions[index]
        searchBarView.text = suggestion
        delegate?.searchView?(self, didSelectSuggestion: suggestion, at: UInt(index))
        // Setting the text in code sends no change from the bar: the results follow the tapped tag, then it is submitted.
        queryChanged(suggestion)
        if submitsOnSuggestionSelection {
            searchBarView.submit()
        }
    }
}
