import UIKit
import CYLSearchViewController
import CYLTableViewPlaceHolder

/**
 * Reloads the example's data for pull to refresh.
 */
@objc(CYLSearchExampleRefreshing)
public protocol CYLSearchExampleRefreshing: NSObjectProtocol {
    /**
     * Reloads, then calls `completion` with nil or the error.
     */
    @objc(reloadWithCompletion:)
    func reload(completion: @escaping (Error?) -> Void)
}

/**
 * Forty localized sample results, filtered by the query; also the example's refresh provider.
 */
@objc(CYLSearchExampleDataSource)
public final class CYLSearchExampleDataSource: NSObject, CYLSearchViewDataSource, CYLSearchExampleRefreshing {

    private let items: [String] = (1...40).map {
        String(format: CYLSearchResources.localizedString(forKey: "sample.result"), UInt($0))
    }

    /**
     * All items for an empty query, else the items that contain the query (case-insensitive).
     */
    public func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any] {
        query.isEmpty ? items : items.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    /**
     * Shows the result's text.
     */
    public func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any) {
        cell.textLabel?.text = result as? String
    }

    /**
     * Finishes after 0.4 seconds without an error.
     */
    public func reload(completion: @escaping (Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { completion(nil) }
    }
}

/**
 * The results page: the core's one navigation-bar search field (`CYLSearchBarView`, `applyNavigationFieldStyle()`)
 * over a list with pull to refresh and an empty state from CYLTableViewPlaceHolder. The refresh goes through
 * `CYLSearchView`'s class methods (`+setRefreshHandler:forScrollView:`, `+endRefreshingInScrollView:`), so the page
 * never calls CYLTableViewPlaceHolder's refresh API itself. "Overlay" opens a `CYLSearchView` with the same data
 * source (`showSearchInViewController:animated:`).
 */
@objc(CYLSearchExampleViewController)
public final class CYLSearchExampleViewController: UITableViewController, CYLSearchBarViewDelegate, CYLTableViewPlaceHolderDelegate {

    private static let cellIdentifier = "CYLSearchExampleCell"

    private let searchDataSource: CYLSearchViewDataSource
    private let refreshProvider: CYLSearchExampleRefreshing

    /**
     * The search field in the navigation bar: the core's `CYLSearchBarView` with the shared navigation field look.
     */
    @objc public let searchBar = CYLSearchBarView()

    /**
     * The search page opened by "Overlay", with `resultsDataSource` set to the page's data source. The page's own list
     * asks the same data source with this view as the sender.
     */
    @objc public let overlaySearchView = CYLSearchView(frame: .zero)

    /**
     * The results of the current query.
     */
    @objc public private(set) var searchResults: [Any] = []

    /**
     * The search data source and the refresh provider (the same `CYLSearchExampleDataSource` in the app).
     */
    @objc(initWithSearchDataSource:refreshProvider:)
    public init(searchDataSource: CYLSearchViewDataSource, refreshProvider: CYLSearchExampleRefreshing) {
        self.searchDataSource = searchDataSource
        self.refreshProvider = refreshProvider
        super.init(style: .plain)
    }

    /**
     * Not available: use `init(searchDataSource:refreshProvider:)`.
     */
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not available; use init(searchDataSource:refreshProvider:)")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // The view starts below the navigation bar and its search bar: the search bar never covers this view.
        edgesForExtendedLayout.remove(.top)
        // navigationItem.title, not title: a view controller's title also renames its tab item, whose title comes
        // from CYLTabBarConfiguration.json.
        navigationItem.title = CYLSearchResources.localizedString(forKey: "search.title")
        searchBar.applyNavigationFieldStyle()
        searchBar.placeholder = CYLSearchResources.localizedString(forKey: "search.placeholder")
        searchBar.accessibilityIdentifier = "CYLSearchResultsField"
        searchBar.delegate = self
        embedSearchBarIfPossible()
        definesPresentationContext = true
        tableView.tableFooterView = UIView()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: CYLSearchResources.localizedString(forKey: "action.overlay"),
                                                           style: .plain, target: self, action: #selector(showOverlay))
        navigationItem.leftBarButtonItem?.accessibilityIdentifier = "CYLSearchOverlayButton"
        overlaySearchView.resultsDataSource = searchDataSource
        overlaySearchView.showsEmptyResultsPlaceholder = true
        // The core dims the host below the short results and highlights the match in each row.
        overlaySearchView.scrimColor = UIColor.black.withAlphaComponent(0.4)
        overlaySearchView.highlightsResultMatches = true
        installRefresh()
        reloadResults()
    }

    /**
     * The field goes into the navigation bar once the page sits in a navigation controller (at load, or when it first
     * appears).
     */
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        embedSearchBarIfPossible()
    }

    private func embedSearchBarIfPossible() {
        guard navigationController != nil, navigationItem.titleView !== searchBar else {
            return
        }
        searchBar.embedInNavigationBar(of: self)
    }

    /**
     * Pull to refresh through the core: the handler captures the page and its table weakly, and every completion path
     * ends the refresh.
     */
    private func installRefresh() {
        let table: UITableView = tableView
        CYLSearchView.setRefreshHandler({ [weak self, weak table] in
            guard let self else {
                if let table {
                    CYLSearchView.endRefreshing(in: table)
                }
                return
            }
            self.refreshProvider.reload { [weak self, weak table] error in
                DispatchQueue.main.async {
                    if let table {
                        CYLSearchView.endRefreshing(in: table)
                    }
                    guard let self else {
                        return
                    }
                    if let error {
                        let alert = UIAlertController(title: CYLSearchResources.localizedString(forKey: "refresh.error"),
                                                      message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: CYLSearchResources.localizedString(forKey: "action.ok"), style: .default))
                        self.present(alert, animated: true)
                    } else {
                        self.reloadResults()
                    }
                }
            }
        }, for: table)
    }

    /**
     * Asks the data source again for the search bar's text and reloads the list (with its empty state).
     */
    @objc public func reloadResults() {
        let query = searchBar.text ?? ""
        searchResults = searchDataSource.searchView(overlaySearchView, resultsForQuery: query)
        tableView.cyl_reloadData()
    }

    /**
     * Requeries the results when the search text changes.
     */
    public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        reloadResults()
    }

    @objc private func showOverlay() {
        // Over the navigation controller's view: the page is opaque and has its own search bar at the top of the safe
        // area, so it covers the list and the navigation bar as one page.
        overlaySearchView.showSearch(in: navigationController ?? self, animated: true)
    }

    // MARK: - Table

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellIdentifier)
        searchDataSource.searchView(overlaySearchView, configureResultCell: cell, withResult: searchResults[indexPath.row])
        return cell
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - CYLTableViewPlaceHolderDelegate

    /**
     * The empty state: CYLTableViewPlaceHolder's `CYLPlaceholderView`, "No matching results".
     */
    public func makePlaceHolderView() -> UIView {
        let placeholder = CYLPlaceholderView(style: .noResults, message: .noResults)
        placeholder.accessibilityIdentifier = "CYLSearchEmptyState"
        return placeholder
    }

    /**
     * The list keeps scrolling (and refreshing) while the empty state shows.
     */
    public func enableScrollWhenPlaceHolderViewShowing() -> Bool {
        true
    }
}
