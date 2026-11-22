//
//  CYLSearchBarInViewDemoViewController.swift
//  CYLSearchExample
//
//  The "Bar in a view" screen (QMUI issue #1251, row I2): the search bar is a plain subview of the view controller's view,
//  not a table header or a navigation item. UIKit animates only those two places, so with a plain subview the controller
//  must not hide the navigation bar (`hidesNavigationBarDuringPresentation = false`): the bar then stays where it is, inside
//  the safe area, and covers nothing.
//

import CYLSearchViewController
import UIKit

/**
 * A search bar above a table, both subviews of the view; the bar is laid out against the safe area and the table starts
 * at the bar's bottom edge, so the bar covers no view.
 */
@objc(CYLSearchBarInViewDemoViewController)
public final class CYLSearchBarInViewDemoViewController: UIViewController, CYLSearchControllerDelegate {

    private(set) var cylSearchController: CYLSearchController?
    private(set) var contentsTableView = UITableView(frame: .zero, style: .plain)
    private var matches: [String] = []
    private var barWidth: NSLayoutConstraint?

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = cylDemoText("demo.barInView")
        view.backgroundColor = .systemBackground
        // The view starts below the navigation bar: the presentation fills this view, so the bar it holds is placed right
        // under the navigation bar (with the view under the bar, UIKit put it at the top of the screen, row I1 / #1319).
        edgesForExtendedLayout.remove(.top)
        let search = CYLSearchController(contentsViewController: self)
        search.searchResultsDelegate = self
        search.noResultsText = cylDemoText("controller.noResults")
        // A bar that is neither a header nor in a navigation item: UIKit cannot animate it away, so the navigation bar stays.
        search.hidesNavigationBarDuringPresentation = false
        cylSearchController = search

        let bar = search.searchBar
        bar.translatesAutoresizingMaskIntoConstraints = false
        // While the search is presented UIKit moves the bar into its own container and drops the constraints to this view
        // (a real tap on iOS 27.2 left the bar 0 pt wide). A width constraint that names no other view survives the move;
        // it is optional (750) so the leading and trailing constraints win when the width changes.
        barWidth = bar.widthAnchor.constraint(equalToConstant: view.bounds.width)
        barWidth?.priority = .defaultHigh
        barWidth?.isActive = true
        contentsTableView.translatesAutoresizingMaskIntoConstraints = false
        contentsTableView.dataSource = self
        contentsTableView.delegate = self
        view.addSubview(contentsTableView)
        view.addSubview(bar)
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentsTableView.topAnchor.constraint(equalTo: bar.bottomAnchor),
            contentsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if barWidth?.constant != view.bounds.width { barWidth?.constant = view.bounds.width }
    }

    // MARK: - CYLSearchControllerDelegate

    public func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        matches = searchString.isEmpty ? [] : CYLSearchControllerDemoViewController.keywords.filter {
            $0.range(of: searchString, options: .caseInsensitive) != nil
        }
        searchController.tableView?.reloadData()
    }
}

extension CYLSearchBarInViewDemoViewController {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === contentsTableView ? CYLSearchControllerDemoViewController.keywords.count : matches.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CYLSearchBarInViewCell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "CYLSearchBarInViewCell")
        let keywords = tableView === contentsTableView ? CYLSearchControllerDemoViewController.keywords : matches
        cell.textLabel?.text = keywords[indexPath.row]
        cell.textLabel?.adjustsFontForContentSizeCategory = true
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
