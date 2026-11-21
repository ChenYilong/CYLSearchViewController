//
//  CYLSearchTableViewControllerTests.swift
//  CYLSearchExampleTests
//
//  CYLSearchTableViewController (QMUICommonTableViewController (Search)): showsSearchBar, searchController, searchBar,
//  hidesSearchBarWhenEmptyViewShowing (issue #128), the selection cleared in viewWillAppear, setUpSearchBar().
//

import CYLSearchViewController
import UIKit
import XCTest
@testable import CYLSearchExample

/**
 * A subclass of the core class that records what the base class does, with five rows.
 */
final class CYLSearchTableRecorder: CYLSearchTableViewController {
    var setUpCount = 0
    var headerWhenSetUp: UIView?
    var barWhenSetUp: UIView?
    var updates: [String] = []

    override func setUpSearchBar() {
        setUpCount += 1
        headerWhenSetUp = tableView.tableHeaderView
        barWhenSetUp = searchBar
    }

    override func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {
        updates.append(searchString)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 5 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "Row \(indexPath.row)"
        return cell
    }
}

final class CYLSearchTableViewControllerTests: CYLSearchExampleTestCase {

    private func open(_ controller: UIViewController) -> UIWindow {
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UINavigationController(rootViewController: controller)
        window.makeKeyAndVisible()
        CYLRunLoop(0.4)
        return window
    }

    /// The names of QMUI's category, with Objective-C selectors.
    func testObjectiveCNamesAndDefaults() {
        for name in ["showsSearchBar", "setShowsSearchBar:", "searchController", "searchBar", "hidesSearchBarWhenEmptyViewShowing",
                     "setHidesSearchBarWhenEmptyViewShowing:", "setUpSearchBar", "searchController:updateResultsForSearchString:",
                     "showEmptyViewWithText:detailText:", "hideEmptyView"] {
            XCTAssertTrue(CYLSearchTableViewController.instancesRespond(to: NSSelectorFromString(name)), name)
        }
        let controller = CYLSearchTableViewController(style: .plain)
        XCTAssertFalse(controller.showsSearchBar, "default off, as QMUI's shouldShowSearchBar")
        XCTAssertFalse(controller.hidesSearchBarWhenEmptyViewShowing)
        XCTAssertNil(controller.searchController)
        XCTAssertNil(controller.searchBar)
        // The default update does nothing.
        controller.searchController(CYLSearchController(contentsViewController: controller), updateResultsFor: "x")
    }

    /// showsSearchBar set before the view loads waits for viewDidLoad; set after, it acts at once.
    func testShowsSearchBarWaitsForViewDidLoad() throws {
        let screen = CYLSearchTableRecorder(style: .plain)
        screen.showsSearchBar = true
        XCTAssertFalse(screen.isViewLoaded)
        XCTAssertNil(screen.searchController, "nothing is created before the view is loaded")
        XCTAssertNil(screen.searchBar)
        XCTAssertEqual(screen.setUpCount, 0)
        screen.loadViewIfNeeded()
        let search = try XCTUnwrap(screen.searchController)
        let bar = try XCTUnwrap(screen.searchBar)
        XCTAssertTrue(bar === search.searchBar)
        XCTAssertTrue(screen.tableView.tableHeaderView === bar)
        XCTAssertTrue(bar.usedAsTableHeaderView)
        XCTAssertTrue(search.searchResultsDelegate === screen)
        XCTAssertTrue(screen.definesPresentationContext)
        XCTAssertEqual(screen.setUpCount, 1, "setUpSearchBar runs once")
        XCTAssertNil(screen.headerWhenSetUp, "before the bar becomes the header")
        XCTAssertTrue(screen.barWhenSetUp === bar, "with the bar already there")
        XCTAssertEqual(search.tableView?.style, screen.tableView.style, "the results table has the table's style")

        let late = CYLSearchTableRecorder(style: .grouped)
        late.loadViewIfNeeded()
        XCTAssertNil(late.searchController)
        late.showsSearchBar = true
        XCTAssertNotNil(late.searchController, "after the view loaded, it acts at once")
        XCTAssertEqual(late.searchController?.tableView?.style, .grouped)
        XCTAssertTrue(late.tableView.tableHeaderView === late.searchBar)
    }

    /// Turning showsSearchBar off removes the header, the bar and the controller (and releases the wrapper); on again makes
    /// new ones.
    func testTurningShowsSearchBarOffRemovesEverything() throws {
        weak var weakSearch: CYLSearchController?
        let screen = CYLSearchTableRecorder(style: .plain)
        autoreleasepool {
            screen.showsSearchBar = true
            screen.loadViewIfNeeded()
            weakSearch = screen.searchController
            XCTAssertNotNil(weakSearch)
            screen.showsSearchBar = false
            XCTAssertNil(screen.tableView.tableHeaderView)
            XCTAssertNil(screen.searchBar)
            XCTAssertNil(screen.searchController)
        }
        XCTAssertNil(weakSearch, "the wrapper is released, the table no longer retains it")
        XCTAssertEqual(screen.tableView.contentInset.bottom, 0)
        screen.showsSearchBar = true
        XCTAssertNotNil(screen.searchBar)
        XCTAssertTrue(screen.tableView.tableHeaderView === screen.searchBar)
        XCTAssertEqual(screen.setUpCount, 2)
    }

    /// hidesSearchBarWhenEmptyViewShowing: the header goes while the empty view shows and returns after, hidden again
    /// when hidesSearchBarInitially is on (issue #128: setting the header again undid the first hiding). Off by default.
    func testHidesSearchBarWhenEmptyViewShowing() throws {
        let screen = CYLSearchTableRecorder(style: .plain)
        screen.showsSearchBar = true
        screen.hidesSearchBarInitially = true
        let window = open(screen)
        let bar = try XCTUnwrap(screen.searchBar)
        let table: UITableView = screen.tableView
        let hiddenOffset = { -table.adjustedContentInset.top + bar.bounds.height }
        XCTAssertEqual(table.contentOffset.y, hiddenOffset(), accuracy: 0.5, "hidden initially")

        // Off by default: the empty view leaves the header.
        screen.showEmptyView(text: "Nothing", detailText: nil)
        XCTAssertTrue(screen.isEmptyViewShowing)
        XCTAssertTrue(table.tableHeaderView === bar, "the header stays when the switch is off")
        screen.hideEmptyView()
        XCTAssertFalse(screen.isEmptyViewShowing)

        screen.hidesSearchBarWhenEmptyViewShowing = true
        screen.showEmptyView(text: "Nothing", detailText: "Try another word")
        CYLRunLoop(0.2)
        XCTAssertTrue(screen.isEmptyViewShowing)
        XCTAssertNil(table.tableHeaderView, "the bar leaves the header while the empty view shows")
        XCTAssertNotNil(screen.searchBar, "the bar and the controller live on")
        table.setContentOffset(CGPoint(x: 0, y: -table.adjustedContentInset.top), animated: false)
        screen.hideEmptyView()
        CYLRunLoop(0.3)
        XCTAssertTrue(table.tableHeaderView === bar, "the bar returns")
        XCTAssertEqual(table.contentOffset.y, hiddenOffset(), accuracy: 0.5, "and is hidden initially again (#128 force)")

        // Without hidesSearchBarInitially the bar returns shown.
        screen.hidesSearchBarInitially = false
        screen.showEmptyView(scenario: .noSearchResults)
        XCTAssertNil(table.tableHeaderView)
        table.setContentOffset(CGPoint(x: 0, y: -table.adjustedContentInset.top), animated: false)
        screen.hideEmptyView()
        CYLRunLoop(0.3)
        XCTAssertTrue(table.tableHeaderView === bar)
        XCTAssertEqual(table.contentOffset.y, -table.adjustedContentInset.top, accuracy: 0.5)
        window.isHidden = true
    }

    /// The selection of the results table is cleared in viewWillAppear, unless it allows multiple selection.
    func testViewWillAppearClearsTheResultsSelection() throws {
        let screen = CYLSearchTableRecorder(style: .plain)
        screen.showsSearchBar = true
        let window = open(screen)
        let search = try XCTUnwrap(screen.searchController)
        search.setActive(true, animated: false)
        CYLRunLoop(0.6)
        let results = try XCTUnwrap(search.tableView)
        results.reloadData()
        results.layoutIfNeeded()
        results.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none)
        XCTAssertNotNil(results.indexPathForSelectedRow)
        screen.viewWillAppear(false)
        XCTAssertNil(results.indexPathForSelectedRow, "cleared")
        results.allowsMultipleSelection = true
        results.selectRow(at: IndexPath(row: 2, section: 0), animated: false, scrollPosition: .none)
        screen.viewWillAppear(false)
        XCTAssertNotNil(results.indexPathForSelectedRow, "kept when multiple selection is allowed")
        search.setActive(false, animated: false)
        window.isHidden = true
    }

    /// The text reaches the subclass's override through the Objective-C selector of the protocol.
    func testUpdateResultsReachesTheSubclass() throws {
        let screen = CYLSearchTableRecorder(style: .plain)
        screen.showsSearchBar = true
        let window = open(screen)
        let search = try XCTUnwrap(screen.searchController)
        search.setActive(true, animated: false)
        CYLRunLoop(0.5)
        search.searchBar.text = "Ro"
        CYLRunLoop(0.3)
        XCTAssertEqual(screen.updates.last, "Ro")
        search.setActive(false, animated: false)
        window.isHidden = true
    }
}
