//
//  CYLSearchShortListDemoViewController.swift
//  CYLSearchExample
//
//  The "Short list" screen (QMUI issue #1160 and #1207, rows I4 and B10): three rows under a header search bar. UIKit let
//  the header stay half visible after a drag, and with so few rows it could not be scrolled out of sight at all. The core's
//  `installSearchBar(asHeaderOf:)` turns the estimated heights off, adds the bottom inset the header needs and settles
//  the header fully shown or fully hidden when a drag ends. QMUI's own project for the issue (issues1160-TestSearchBar) is
//  an empty Xcode template: this screen rebuilds the scenario from the issue text.
//

import CYLSearchViewController
import UIKit

/**
 * Three rows below a search bar that is the table header (`CYLSearchTableViewController` with `showsSearchBar`).
 */
@objc(CYLSearchShortListDemoViewController)
public final class CYLSearchShortListDemoViewController: CYLSearchTableViewController {

    static let rows: [String] = (1...3).map { String(format: cylDemoText("issue.row"), $0) }
    private var matches: [String] = []

    public override func viewDidLoad() {
        showsSearchBar = true
        super.viewDidLoad()
        navigationItem.title = cylDemoText("demo.shortList")
    }

    // MARK: - Table

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === self.tableView ? Self.rows.count : matches.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLSearchShortListCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLSearchShortListCell")
        cell.textLabel?.text = (tableView === self.tableView ? Self.rows : matches)[indexPath.row]
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        return cell
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Search

    public override func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        matches = searchString.isEmpty ? [] : Self.rows.filter { $0.range(of: searchString, options: .caseInsensitive) != nil }
        searchController.tableView?.reloadData()
        if matches.isEmpty && !searchString.isEmpty {
            searchController.showEmptyView(text: cylDemoText("controller.noResults"), detailText: nil, buttonTitle: nil,
                                           buttonAction: nil)
        } else {
            searchController.hideEmptyView()
        }
    }
}
