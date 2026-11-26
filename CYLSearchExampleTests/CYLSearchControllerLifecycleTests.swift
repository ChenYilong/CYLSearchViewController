//
//  CYLSearchControllerLifecycleTests.swift
//  CYLSearchExampleTests
//
//  The rows of docs/qmui-search-controller.md that concern the life cycle of CYLSearchController after the rebuild on the
//  core search field (docs/no-system-searchbar.md): the field, the leaks of #1541 (E2, E3), the empty view (E8, E9), the text
//  (E10), the bar's bottom edge (E16, E17), the history and the delegate order. The rows that only exist because of
//  UISearchController (E1, E4 to E7, E20 to E22, B7 to B9) are gone with it; each removal is listed in the task log.
//

import UIKit
import XCTest
@testable import CYLSearchViewController
@testable import CYLSearchExample

final class CYLSearchControllerLifecycleTests: CYLSearchExampleTestCase {

    // MARK: - API

    /// The search field is the core's `CYLSearchBarView` with the shared navigation field look; the results are a table view
    /// controller; no `UISearchController` exists.
    func testSearchBarIsTheCoreField() {
        let search = CYLSearchController(contentsViewController: UIViewController())
        XCTAssertTrue(type(of: search.searchBar) == CYLSearchBarView.self)
        XCTAssertEqual(search.searchBar.searchBarStyle, .bordered)
        XCTAssertEqual(search.searchBar.fieldCornerRadius, 18)
        XCTAssertNil(search.searchBar.searchIcon)
        XCTAssertTrue(search.searchResultsController is UITableViewController)
        XCTAssertTrue(search.tableView === (search.searchResultsController as? UITableViewController)?.tableView)
        XCTAssertFalse(search.isActive)
    }

    // MARK: - E2, E3

    /// E2: popped (`popToRootViewController`) while searching leaks nothing.
    func testE2PopToRootWhileSearchingReleasesContents() {
        weak var weakContents: UIViewController?
        weak var weakSearch: CYLSearchController?
        autoreleasepool {
            let contents = CYLSearchTestContents(style: .plain)
            let nav = UINavigationController(rootViewController: UIViewController())
            let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
            window.rootViewController = nav
            window.makeKeyAndVisible()
            nav.pushViewController(contents, animated: false)
            runLoop(0.3)
            contents.search?.setActive(true, animated: false)
            runLoop(0.6)
            XCTAssertEqual(contents.search?.isActive, true)
            weakContents = contents
            weakSearch = contents.search
            nav.popToRootViewController(animated: false)
            runLoop(0.6)
            window.rootViewController = nil
            window.isHidden = true
        }
        runLoop(0.6)
        XCTAssertNil(weakContents, "contents leaked")
        XCTAssertNil(weakSearch, "search controller leaked")
    }

    /// E3: `window.rootViewController` replaced while searching: everything is released.
    func testE3ReplacingRootWhileSearchingReleasesContents() {
        weak var weakContents: UIViewController?
        weak var weakSearch: CYLSearchController?
        autoreleasepool {
            let contents = CYLSearchTestContents(style: .plain)
            let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
            window.rootViewController = UINavigationController(rootViewController: contents)
            window.makeKeyAndVisible()
            runLoop(0.3)
            contents.search?.setActive(true, animated: false)
            runLoop(0.6)
            XCTAssertEqual(contents.search?.isActive, true)
            weakContents = contents
            weakSearch = contents.search
            window.rootViewController = UIViewController()
            runLoop(0.6)
            window.rootViewController = nil
            window.isHidden = true
        }
        runLoop(0.6)
        XCTAssertNil(weakContents, "contents leaked")
        XCTAssertNil(weakSearch, "search controller leaked")
    }

    // MARK: - Empty view

    /// E8: the empty view is not shown for empty text; it is shown and hidden on request with text.
    func testE8EmptyViewIsNotShownForEmptyText() {
        let run = makeSearchRun { $0.showsEmptyViewWithoutMatch = false }
        activateSearch(run)
        run.search.showEmptyView(text: "Nothing", detailText: nil, buttonTitle: nil, buttonAction: nil)
        XCTAssertFalse(run.search.isEmptyViewShowing)
        run.search.showEmptyView(scenario: .noSearchResults)
        XCTAssertFalse(run.search.isEmptyViewShowing)
        XCTAssertFalse(run.contents.events.contains("willShowEmptyView"))
        run.search.searchBar.text = "zzz"
        run.search.searchBarView(run.search.searchBar, textDidChange: "zzz")
        runLoop(0.4)
        run.search.showEmptyView(text: "Nothing", detailText: "Try again", buttonTitle: "Retry", buttonAction: {})
        XCTAssertTrue(run.search.isEmptyViewShowing)
        XCTAssertTrue(run.contents.events.contains("willShowEmptyView"))
        run.search.hideEmptyView()
        XCTAssertFalse(run.search.isEmptyViewShowing)
        run.search.showEmptyView(scenario: .noSearchResults)
        XCTAssertTrue(run.search.isEmptyViewShowing)
        tearDownSearchRun(run)
    }

    /// E9: the empty view fills the page under the bar and is gone after the search is left.
    func testE9EmptyViewFillsThePageUnderTheBarAndIsHiddenOnDismiss() throws {
        let run = makeSearchRun()
        activateSearch(run, text: "zzz")
        run.search.searchBarView(run.search.searchBar, textDidChange: "zzz")
        runLoop(0.3)
        XCTAssertTrue(run.search.isEmptyViewShowing, "no match shows the empty view")
        let page = try XCTUnwrap(run.search.activePageView)
        let empty = try XCTUnwrap(run.search.emptyView)
        XCTAssertTrue(empty.superview === page)
        let barBottom = run.search.searchBar.convert(run.search.searchBar.bounds, to: page).maxY
        XCTAssertGreaterThanOrEqual(empty.frame.minY, barBottom - 0.5, "under the bar")
        run.search.setActive(false, animated: false)
        runLoop(0.3)
        XCTAssertFalse(run.search.isEmptyViewShowing, "hidden on dismiss")
        XCTAssertNil(empty.superview)
        tearDownSearchRun(run)
    }

    // MARK: - Text, bar edge

    /// E10: the delegate also receives "" (the first activation, all text deleted).
    func testE10UpdateResultsAlsoReceivesEmptyText() {
        let run = makeSearchRun()
        activateSearch(run)
        XCTAssertEqual(run.contents.updates.first, "", "the first activation sends \"\"")
        run.search.searchBar.text = "H"
        run.search.searchBarView(run.search.searchBar, textDidChange: "H")
        XCTAssertEqual(run.contents.updates.last, "H")
        run.search.searchBar.text = ""
        run.search.searchBarView(run.search.searchBar, textDidChange: "")
        XCTAssertEqual(run.contents.updates.last, "", "deleting all text sends \"\"")
        tearDownSearchRun(run)
    }

    /// E16: `searchBarMaxY` is the bar's bottom edge in the window (0 while the bar is not in one).
    func testE16SearchBarMaxYIsTheBarsBottomInTheWindow() {
        let run = makeSearchRun()
        XCTAssertGreaterThan(run.search.searchBarMaxY, 0, "the bar is the table header, in the window")
        let expected = run.search.searchBar.convert(run.search.searchBar.bounds, to: nil).maxY
        XCTAssertEqual(run.search.searchBarMaxY, expected, accuracy: 0.01)
        tearDownSearchRun(run)
    }

    /// E17: activating without animation lays the page out below the bar at once.
    func testE17ActivateWithoutAnimationLaysThePageOutBelowTheBar() throws {
        let run = makeSearchRun()
        run.search.setActive(true, animated: false)
        runLoop(0.4)
        let page = try XCTUnwrap(run.search.activePageView)
        let host = try XCTUnwrap(page.superview)
        let barBottom = host.convert(run.search.searchBar.bounds, from: run.search.searchBar).maxY
        XCTAssertEqual(page.frame.minY, barBottom, accuracy: 0.5)
        XCTAssertEqual(page.frame.maxY, host.bounds.maxY, accuracy: 0.5)
        tearDownSearchRun(run)
    }

    // MARK: - History, delegate order

    private final class MemoryHistory: NSObject, CYLSearchSuggestionCache {
        var queries: [String] = []
        func cachedQueries() -> [String] { queries }
        func addQuery(_ query: String) { queries.removeAll { $0 == query }; queries.insert(query, at: 0) }
        func removeQuery(_ query: String) { queries.removeAll { $0 == query } }
        func removeAllQueries() { queries = [] }
    }

    /// `historyStore` is the shared `CYLSearchSuggestionCache` protocol; the return key adds the trimmed query, a blank one is
    /// ignored, and without a store nothing happens.
    func testHistoryStoreReceivesTheSubmittedQueries() throws {
        let run = makeSearchRun()
        let history = MemoryHistory()
        let field = run.search.searchBar.textField
        run.search.searchBar.text = "Liver"
        field.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(history.queries, [], "no store set: nothing is kept (and nothing crashes)")
        run.search.historyStore = history
        for text in ["  Liver ", "Fat", "   ", ""] {
            run.search.searchBar.text = text
            field.sendActions(for: .primaryActionTriggered)
        }
        XCTAssertEqual(history.queries, ["Fat", "Liver"])
        let builtIn = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .userDefaults, name: "CYLHistoryTest-\(UUID().uuidString)"))
        builtIn.addQuery("a")
        builtIn.addQuery("b")
        builtIn.addQuery("a")
        XCTAssertEqual(builtIn.cachedQueries(), ["a", "b"], "the built-in store: newest first, no duplicates")
        builtIn.removeAllQueries()
        XCTAssertNil(CYLSearchResources.suggestionCache(policy: .none, name: "x"))
        tearDownSearchRun(run)
    }

    /// The delegate hears will / did present and dismiss, in order, and the results table's load once.
    func testDelegateLifecycleOrder() {
        let run = makeSearchRun()
        activateSearch(run, text: "H")
        run.search.setActive(false, animated: true)
        let deadline = Date(timeIntervalSinceNow: 5)
        repeat { runLoop(0.1) } while !run.contents.events.contains("didDismiss") && Date() < deadline
        let events = run.contents.events.filter { $0 != "willShowEmptyView" }
        XCTAssertEqual(events.filter { $0 == "didLoadTableView" }.count, 1)
        XCTAssertEqual(events.filter { $0 != "didLoadTableView" }, ["willPresent", "didPresent", "willDismiss", "didDismiss"])
        tearDownSearchRun(run)
    }


    // MARK: - I1: the page leaves with the contents page

    /// I1: the contents page is popped while the search is active: the page and the swipe recognizer leave the navigation
    /// controller's view, and the search ends.
    func testI1PopWhileSearchingRemovesThePage() {
        let contents = CYLSearchTestContents(style: .plain)
        let nav = UINavigationController(rootViewController: UIViewController())
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = nav
        window.makeKeyAndVisible()
        nav.pushViewController(contents, animated: false)
        runLoop(0.3)
        let search = try! XCTUnwrap(contents.search)
        search.supportsSwipeToDismissSearch = true
        search.setActive(true, animated: false)
        runLoop(0.6)
        let page = try! XCTUnwrap(search.activePageView)
        XCTAssertTrue(page.superview === nav.view)
        XCTAssertTrue(search.swipeGestureRecognizer?.view === nav.view)
        nav.popViewController(animated: false)
        runLoop(0.6)
        XCTAssertNil(page.superview, "the search page stayed on the navigation controller's view")
        XCTAssertNil(search.swipeGestureRecognizer?.view, "the swipe recognizer stayed on the navigation controller's view")
        XCTAssertFalse(search.isActive)
        window.rootViewController = nil
        window.isHidden = true
    }

    /// I1: the navigation controller of the contents is dismissed while the search is active: the page leaves its view.
    func testI1DismissWhileSearchingRemovesThePage() {
        let contents = CYLSearchTestContents(style: .plain)
        let presenter = UIViewController()
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        runLoop(0.3)
        let nav = UINavigationController(rootViewController: contents)
        nav.modalPresentationStyle = .fullScreen
        presenter.present(nav, animated: false)
        runLoop(0.6)
        let search = try! XCTUnwrap(contents.search)
        search.setActive(true, animated: false)
        runLoop(0.6)
        let page = try! XCTUnwrap(search.activePageView)
        XCTAssertTrue(page.superview === nav.view)
        presenter.dismiss(animated: false)
        runLoop(0.6)
        XCTAssertNil(page.superview, "the search page stayed on the dismissed navigation controller's view")
        XCTAssertFalse(search.isActive)
        window.rootViewController = nil
        window.isHidden = true
    }

    /// I1: leaving the search removes the page from its host instead of keeping it there hidden.
    func testI1LeavingTheSearchRemovesThePage() {
        let run = makeSearchRun()
        activateSearch(run)
        let page = try! XCTUnwrap(run.search.activePageView)
        run.search.setActive(false, animated: false)
        runLoop(0.3)
        XCTAssertNil(page.superview, "the hidden search page stayed in its host")
        activateSearch(run)
        XCTAssertTrue(run.search.activePageView === page, "the page comes back on the next search")
        tearDownSearchRun(run)
    }
}
