//
//  CYLSearchNavigationItemDemoViewController.swift
//  CYLSearchExample
//
//  The "Navigation item" screen (QMUI issue #1229, docs/qmui-search-controller.md, row I3): a CYLSearchController is
//  installed on the navigation item. QMUI's wrapper is not the system search controller, so assigning it to
//  `navigationItem.searchController` crashed; `install(in:)` assigns the system controller inside and keeps the wrapper
//  alive, so this screen holds no strong reference of its own.
//

import CYLSearchViewController
import UIKit

/**
 * A list of ten keywords with the search in the navigation bar (`install(in:)`). The screen keeps the wrapper only weakly:
 * the contents view controller retains it, which is what #1229 needed.
 */
@objc(CYLSearchNavigationItemDemoViewController)
public final class CYLSearchNavigationItemDemoViewController: UITableViewController, CYLSearchControllerDelegate {

    /// The wrapper, held weakly: `install(in:)` keeps it alive.
    private(set) weak var cylSearchController: CYLSearchController?
    /// Every text the controller handed over, as the delegate received it.
    private(set) var searchStrings: [String] = []
    private var matches: [String] = []

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = cylDemoText("demo.navigationItem")
        let search = CYLSearchController(contentsViewController: self)
        search.searchResultsDelegate = self
        search.noResultsText = cylDemoText("controller.noResults")
        search.install(in: navigationItem)
        navigationItem.hidesSearchBarWhenScrolling = false
        // The bar stays in the navigation bar, under the title: on iOS 26 an iPhone would float it at the bottom of the screen,
        // over the list, and a search bar never covers a view.
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        if #available(iOS 26.0, *) {
            navigationItem.searchBarPlacementAllowsToolbarIntegration = false
        }
        cylSearchController = search
    }

    // MARK: - Table

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === self.tableView ? CYLSearchControllerDemoViewController.keywords.count : matches.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLSearchNavigationItemCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLSearchNavigationItemCell")
        let keywords = tableView === self.tableView ? CYLSearchControllerDemoViewController.keywords : matches
        cell.textLabel?.text = keywords[indexPath.row]
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - CYLSearchControllerDelegate

    public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        searchStrings.append(searchString)
        matches = searchString.isEmpty ? [] : CYLSearchControllerDemoViewController.keywords.filter {
            $0.range(of: searchString, options: .caseInsensitive) != nil
        }
        searchController.tableView?.reloadData()
    }
}
