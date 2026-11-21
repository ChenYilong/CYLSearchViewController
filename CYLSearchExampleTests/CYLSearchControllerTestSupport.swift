//
//  CYLSearchControllerTestSupport.swift
//  CYLSearchExampleTests
//
//  The fixtures of the CYLSearchController tests (docs/qmui-search-controller.md, rows E1 to E22): a contents table view
//  controller that records what the controller tells it, a pushed screen, a results controller that records its
//  appearance calls, and helpers that open a window and activate the search.
//

import CYLSearchViewController
import UIKit
import XCTest
@testable import CYLSearchExample

/**
 * A table view controller with a `CYLSearchController`, as QMUI's demo has: ten keywords, the matching ones in the
 * results, and a record of every delegate call.
 */
final class CYLSearchTestContents: UITableViewController, CYLSearchControllerDelegate {

    static let keywords = ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat", "Metabolism",
                           "Nuturally"]

    var search: CYLSearchController?
    var usesHeader = true
    var resultsController: UIViewController?
    var showsEmptyViewWithoutMatch = true
    var pushesOnSelect = false
    var matches: [String] = []
    var updates: [String] = []
    var events: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let controller: CYLSearchController
        if let resultsController {
            controller = CYLSearchController(contentsViewController: self, resultsViewController: resultsController)
        } else {
            controller = CYLSearchController(contentsViewController: self)
        }
        controller.searchResultsDelegate = self
        search = controller
        if usesHeader {
            controller.installSearchBar(asHeaderOf: tableView)
        } else {
            controller.install(in: navigationItem)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView === self.tableView ? Self.keywords.count : matches.count * 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = tableView === self.tableView ? Self.keywords[indexPath.row] : matches[indexPath.row / 20]
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pushesOnSelect { navigationController?.pushViewController(CYLSearchPushedController(), animated: false) }
    }

    func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        updates.append(searchString)
        matches = searchString.isEmpty ? [] : Self.keywords.filter { $0.range(of: searchString) != nil }
        searchController.tableView?.reloadData()
        if matches.isEmpty && showsEmptyViewWithoutMatch {
            searchController.showEmptyView(text: "No matching results", detailText: nil, buttonTitle: nil, buttonAction: nil)
        } else {
            searchController.hideEmptyView()
        }
    }

    func willPresentSearchController(_ searchController: CYLSearchController) { events.append("willPresent") }
    func didPresentSearchController(_ searchController: CYLSearchController) { events.append("didPresent") }
    func willDismissSearchController(_ searchController: CYLSearchController) { events.append("willDismiss") }
    func didDismissSearchController(_ searchController: CYLSearchController) { events.append("didDismiss") }

    func searchController(_ searchController: CYLSearchController, didLoad tableView: UITableView) {
        events.append("didLoadTableView")
    }

    func searchController(_ searchController: CYLSearchController, willShow emptyView: UIView) {
        events.append("willShowEmptyView")
    }
}

/**
 * A screen pushed from the contents or from the results.
 */
final class CYLSearchPushedController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Pushed"
    }
}

/**
 * A results table view controller that records its appearance calls.
 */
final class CYLAppearanceRecordingResults: UITableViewController {
    var calls: [String] = []

    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); calls.append("viewWillAppear") }
    override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); calls.append("viewDidAppear") }
    override func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear(animated); calls.append("viewWillDisappear") }
    override func viewDidDisappear(_ animated: Bool) { super.viewDidDisappear(animated); calls.append("viewDidDisappear") }
}

/**
 * A window with a navigation controller around a `CYLSearchTestContents`.
 */
struct CYLSearchRun {
    let window: UIWindow
    let navigation: UINavigationController
    let contents: CYLSearchTestContents
    var search: CYLSearchController { contents.search! }
}

/**
 * Opens a window (402 x 874) with the contents in a navigation controller and waits for the first layout.
 */
func CYLMakeSearchRun(usesHeader: Bool = true, resultsController: UIViewController? = nil,
                      configure: ((CYLSearchTestContents) -> Void)? = nil) -> CYLSearchRun {
    let contents = CYLSearchTestContents(style: .plain)
    contents.usesHeader = usesHeader
    contents.resultsController = resultsController
    configure?(contents)
    let navigation = UINavigationController(rootViewController: contents)
    let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
    window.rootViewController = navigation
    window.makeKeyAndVisible()
    CYLRunLoop(0.3)
    return CYLSearchRun(window: window, navigation: navigation, contents: contents)
}

/**
 * Enters the search without animation, sets the text if given, and waits for the presentation.
 */
func CYLActivateSearch(_ run: CYLSearchRun, text: String? = nil) {
    run.search.setActive(true, animated: false)
    CYLRunLoop(0.6)
    if let text {
        run.search.searchBar.text = text
        CYLRunLoop(0.4)
    }
}

/**
 * Removes the window's content so nothing outlives the test.
 */
func CYLTearDownSearchRun(_ run: CYLSearchRun) {
    run.window.rootViewController = nil
    run.window.isHidden = true
}
