import UIKit

/**
 * Supplies the results of a `CYLSearchResultsViewController` and configures their cells.
 */
@objc(CYLSearchResultsDataSource)
public protocol CYLSearchResultsDataSource: NSObjectProtocol {
    /**
     * The results for `query` (an empty string while nothing is typed).
     */
    @objc(searchResultsViewController:resultsForQuery:)
    func searchResultsViewController(_ controller: CYLSearchResultsViewController, resultsForQuery query: String) -> [Any]

    /**
     * Shows `result` in `cell`.
     */
    @objc(searchResultsViewController:configureCell:withResult:)
    func searchResultsViewController(_ controller: CYLSearchResultsViewController, configureCell cell: UITableViewCell, withResult result: Any)

    /**
     * A result was tapped.
     */
    @objc(searchResultsViewController:didSelectResult:)
    optional func searchResultsViewController(_ controller: CYLSearchResultsViewController, didSelectResult result: Any)
}

/**
 * A table of search results with a search bar in its navigation item, driven by a `CYLSearchResultsDataSource`.
 * The search bar stays pinned under the title, and the view starts below it, so the bar never covers the list.
 */
@objc(CYLSearchResultsViewController)
open class CYLSearchResultsViewController: UITableViewController, UISearchResultsUpdating {

    private static let cellIdentifier = "CYLSearchResultsCell"

    /**
     * The data source given at creation.
     */
    @objc public let searchDataSource: CYLSearchResultsDataSource

    /**
     * The search controller installed in the navigation item.
     */
    @objc public let searchController: UISearchController

    /**
     * The results of the last query.
     */
    @objc public private(set) var searchResults: [Any] = []

    /**
     * Creates the controller with its data source (plain table style).
     */
    @objc(initWithSearchDataSource:)
    public init(searchDataSource: CYLSearchResultsDataSource) {
        self.searchDataSource = searchDataSource
        searchController = UISearchController(searchResultsController: nil)
        super.init(style: .plain)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
    }

    /**
     * Not available: use `init(searchDataSource:)`.
     */
    @available(*, unavailable)
    override public init(style: UITableView.Style) {
        fatalError("init(style:) is not available; use init(searchDataSource:)")
    }

    /**
     * Not available: use `init(searchDataSource:)`.
     */
    @available(*, unavailable)
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("init(nibName:bundle:) is not available; use init(searchDataSource:)")
    }

    /**
     * Not available: use `init(searchDataSource:)`.
     */
    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not available; use init(searchDataSource:)")
    }

    /**
     * Keeps the view below the navigation bar and its search bar after every layout (a search bar never covers a
     * view): on some devices ("iPhone Duo") UIKit places the view 10 pt under the stacked search bar.
     */
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cylKeepViewBelowNavigationBar()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        // The view starts below the navigation bar and its search bar: the search bar never covers this view.
        edgesForExtendedLayout.remove(.top)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        // The search bar stays in the navigation bar, under the title. On iOS 26 an iPhone would otherwise float it
        // at the bottom of the screen, over the list: a search bar never covers a view.
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        if #available(iOS 26.0, *) {
            navigationItem.searchBarPlacementAllowsToolbarIntegration = false
        }
        definesPresentationContext = true
        reloadSearchResults()
    }

    /**
     * Requeries the data source using the current search text and reloads the table.
     */
    @objc open func reloadSearchResults() {
        let query = searchController.searchBar.text ?? ""
        searchResults = searchDataSource.searchResultsViewController(self, resultsForQuery: query)
        reloadResultsTableView()
    }

    /**
     * Override to integrate a custom table reload, such as an empty-state provider.
     */
    @objc open func reloadResultsTableView() {
        tableView.reloadData()
    }

    /**
     * Requeries the results when the search text changes.
     */
    open func updateSearchResults(for searchController: UISearchController) {
        reloadSearchResults()
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        searchResults.count
    }

    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)
            ?? UITableViewCell(style: .default, reuseIdentifier: Self.cellIdentifier)
        searchDataSource.searchResultsViewController(self, configureCell: cell, withResult: searchResults[indexPath.row])
        return cell
    }

    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchDataSource.searchResultsViewController?(self, didSelectResult: searchResults[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UIViewController {
    /**
     * Moves the view down, and shortens it, by the height the navigation bar (with a stacked search bar) covers.
     * Nothing changes when the view already starts at the bar's bottom edge or lower.
     */
    func cylKeepViewBelowNavigationBar() {
        guard let bar = navigationController?.navigationBar, !bar.isHidden, bar.window != nil,
              let container = viewIfLoaded?.superview else {
            return
        }
        let barBottom = container.convert(bar.bounds, from: bar).maxY
        let overlap = barBottom - view.frame.minY
        guard overlap > 0.5 else {
            return
        }
        var frame = view.frame
        frame.origin.y += overlap
        frame.size.height = max(0, frame.height - overlap)
        view.frame = frame
    }
}
