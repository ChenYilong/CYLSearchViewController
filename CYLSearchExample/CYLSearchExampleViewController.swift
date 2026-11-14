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
public final class CYLSearchExampleDataSource: NSObject, CYLSearchResultsDataSource, CYLSearchExampleRefreshing {

    private let items: [String] = (1...40).map {
        String(format: CYLSearchResources.localizedString(forKey: "sample.result"), UInt($0))
    }

    /**
     * All items for an empty query, else the items that contain the query (case-insensitive).
     */
    public func searchResultsViewController(_ controller: CYLSearchResultsViewController, resultsForQuery query: String) -> [Any] {
        query.isEmpty ? items : items.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    /**
     * Shows the result's text.
     */
    public func searchResultsViewController(_ controller: CYLSearchResultsViewController, configureCell cell: UITableViewCell, withResult result: Any) {
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
 * The Issue #1317 reproduction: a navigation-item search controller over a list with pull to refresh
 * (`CYLRefreshNormalHeader`) and an empty state from CYLTableViewPlaceHolder. "Repro" switches
 * `hidesSearchBarWhenScrolling`; "Overlay" opens `CYLSearchController`. Written in Swift because Objective-C cannot
 * subclass the Swift `CYLSearchResultsViewController`.
 */
@objc(CYLSearchExampleViewController)
public final class CYLSearchExampleViewController: CYLSearchResultsViewController, CYLTableViewPlaceHolderDelegate {

    private let refreshProvider: CYLSearchExampleRefreshing
    private var overlaySearchController: CYLSearchController?

    /**
     * The search data source and the refresh provider (the same `CYLSearchExampleDataSource` in the app).
     */
    @objc(initWithSearchDataSource:refreshProvider:)
    public init(searchDataSource: CYLSearchResultsDataSource, refreshProvider: CYLSearchExampleRefreshing) {
        self.refreshProvider = refreshProvider
        super.init(searchDataSource: searchDataSource)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem.title, not title: a view controller's title also renames its tab item, whose title comes
        // from CYLTabBarConfiguration.json.
        navigationItem.title = CYLSearchResources.localizedString(forKey: "search.title")
        searchController.searchBar.placeholder = CYLSearchResources.localizedString(forKey: "search.placeholder")
        tableView.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: CYLSearchResources.localizedString(forKey: "repro.off"),
                                                            style: .plain, target: self, action: #selector(toggleReproduction))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "CYLIssueReproductionToggle"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: CYLSearchResources.localizedString(forKey: "action.overlay"),
                                                           style: .plain, target: self, action: #selector(showOverlay))
        tableView.cyl_header = CYLRefreshNormalHeader { [weak self] in
            guard let self else { return }
            self.refreshProvider.reload { [weak self] error in
                DispatchQueue.main.async {
                    guard let self else { return }
                    self.tableView.cyl_header?.endRefreshing()
                    if let error {
                        let alert = UIAlertController(title: CYLSearchResources.localizedString(forKey: "refresh.error"),
                                                      message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: CYLSearchResources.localizedString(forKey: "action.ok"), style: .default))
                        self.present(alert, animated: true)
                    } else {
                        self.reloadSearchResults()
                    }
                }
            }
        }
    }

    @objc private func showOverlay() {
        let overlay = overlaySearchController ?? CYLSearchController(searchDataSource: searchDataSource)
        overlaySearchController = overlay
        overlay.show(in: self)
    }

    @objc private func toggleReproduction() {
        let enabled = !navigationItem.hidesSearchBarWhenScrolling
        navigationItem.hidesSearchBarWhenScrolling = enabled
        navigationItem.rightBarButtonItem?.title = CYLSearchResources.localizedString(forKey: enabled ? "repro.on" : "repro.off")
    }

    override public func reloadResultsTableView() {
        tableView.cyl_reloadData()
    }

    /**
     * The empty state: CYLSearchPlaceholderView "No matching results".
     */
    public func makePlaceHolderView() -> UIView {
        let placeholder = CYLSearchPlaceholderView(kind: .noResults)
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
