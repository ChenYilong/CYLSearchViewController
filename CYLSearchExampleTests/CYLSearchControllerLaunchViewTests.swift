//
//  CYLSearchControllerLaunchViewTests.swift
//  CYLSearchExampleTests
//
//  Rows E15 (launch view), E18 (always visible results) and E19 (dimming view) of docs/qmui-search-controller.md.
//

import CollectionViewClassifyMenu
import UIKit
import XCTest
@testable import CYLSearchViewController
@testable import CYLSearchExample

final class CYLSearchControllerLaunchViewTests: CYLSearchExampleTestCase {

    private func makeLaunchView() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemYellow
        view.accessibilityIdentifier = "TestLaunchView"
        return view
    }

    // MARK: - E15

    /// E15: the launch view fills the space under the bar while the text is empty, is laid out again after a resize, and
    /// sits behind the results once text is entered.
    func testE15LaunchViewFillsTheSpaceUnderTheBar() throws {
        let run = CYLMakeSearchRun()
        let launch = makeLaunchView()
        run.search.launchView = launch
        CYLActivateSearch(run)
        let results = try XCTUnwrap(run.search.searchResultsController)
        let container = try XCTUnwrap(launch.superview)
        XCTAssertTrue(container === results.view.superview, "the launch view sits next to the results")
        XCTAssertTrue(results.view.isHidden, "the results are hidden while the text is empty")
        XCTAssertFalse(launch.isHidden)
        XCTAssertNotNil(launch.window)
        func check(_ message: String) {
            let barMaxY = run.search.searchBarMaxY
            XCTAssertGreaterThan(barMaxY, 0)
            XCTAssertEqual(launch.frame.minY, container.convert(CGPoint(x: 0, y: barMaxY), from: run.search.searchController.view).y,
                           accuracy: 0.5, "\(message): starts under the bar")
            XCTAssertEqual(launch.frame.maxY, container.bounds.maxY, accuracy: 0.5, "\(message): ends at the bottom")
            XCTAssertEqual(launch.frame.width, container.bounds.width, accuracy: 0.5, "\(message): full width")
        }
        check("on activation")
        let barBottom = run.search.searchBar.convert(run.search.searchBar.bounds, to: run.window).maxY
        XCTAssertGreaterThanOrEqual(launch.convert(launch.bounds, to: run.window).minY, barBottom - 0.5, "not under the bar")

        run.window.frame = CGRect(x: 0, y: 0, width: 330, height: 640)
        CYLRunLoop(0.7)
        check("after a resize")

        run.search.searchBar.text = "H"
        CYLRunLoop(0.4)
        XCTAssertFalse(results.view.isHidden, "the results show once text is entered")
        let subviews = container.subviews
        let launchIndex = try XCTUnwrap(subviews.firstIndex(of: launch))
        let resultsIndex = try XCTUnwrap(subviews.firstIndex(of: results.view))
        XCTAssertLessThan(launchIndex, resultsIndex, "the launch view is behind the results")

        run.search.searchBar.text = ""
        CYLRunLoop(0.4)
        XCTAssertTrue(results.view.isHidden, "all text deleted: the launch view shows again")

        run.search.launchView = nil
        XCTAssertNil(launch.superview, "a removed launch view leaves the search view")
        CYLTearDownSearchRun(run)
    }

    /// A launch view set after the search view exists is added at once.
    func testLaunchViewSetAfterTheViewIsLoadedIsAdded() {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run)
        let launch = makeLaunchView()
        run.search.launchView = launch
        XCTAssertNotNil(launch.superview)
        let other = makeLaunchView()
        run.search.launchView = other
        XCTAssertNil(launch.superview, "the replaced launch view is removed")
        XCTAssertNotNil(other.superview)
        CYLTearDownSearchRun(run)
    }

    // MARK: - E18

    /// E18: alwaysShowsSearchResultsController shows the results at once, clears the launch view and the obscuring, and
    /// turning it off restores the obscuring.
    func testE18AlwaysShowsSearchResultsController() throws {
        let run = CYLMakeSearchRun()
        run.search.launchView = makeLaunchView()
        run.search.alwaysShowsSearchResultsController = true
        XCTAssertNil(run.search.launchView, "the launch view is cleared")
        XCTAssertTrue(run.search.alwaysShowsSearchResultsController)
        XCTAssertFalse(run.search.searchController.obscuresBackgroundDuringPresentation)
        CYLActivateSearch(run)
        let results = try XCTUnwrap(run.search.searchResultsController)
        XCTAssertFalse(results.view.isHidden, "the results show with empty text")
        run.search.setActive(false, animated: true)
        CYLRunLoop(0.8)
        run.search.alwaysShowsSearchResultsController = false
        XCTAssertTrue(run.search.searchController.obscuresBackgroundDuringPresentation)
        CYLActivateSearch(run)
        XCTAssertTrue(results.view.isHidden, "the results hide again with empty text")
        CYLTearDownSearchRun(run)
    }

    // MARK: - E19

    /// E19: the own dimming view has the color, sits under the bar, shows while the text is empty, and a tap leaves the
    /// search; it is ignored when a launch view is set.
    func testE19DimmingViewColorPlacementAndTap() throws {
        let run = CYLMakeSearchRun()
        let color = UIColor.red.withAlphaComponent(0.4)
        run.search.dimmingColor = color
        XCTAssertFalse(run.search.searchController.obscuresBackgroundDuringPresentation, "the own view replaces the system's")
        CYLActivateSearch(run)
        let system = run.search.searchController
        let dimming = try XCTUnwrap(CYLViewWithAccessibilityIdentifier(system.view, "CYLSearchDimmingView"))
        XCTAssertEqual(dimming.backgroundColor, color)
        XCTAssertFalse(dimming.isHidden, "shown while the text is empty")
        let barBottom = run.search.searchBar.convert(run.search.searchBar.bounds, to: run.window).maxY
        XCTAssertGreaterThanOrEqual(dimming.convert(dimming.bounds, to: run.window).minY, barBottom - 0.5, "under the bar")
        XCTAssertEqual(dimming.convert(dimming.bounds, to: run.window).maxY, run.window.bounds.maxY, accuracy: 0.5)
        XCTAssertEqual(dimming.gestureRecognizers?.count, 1, "a tap recognizer")

        run.search.searchBar.text = "H"
        CYLRunLoop(0.4)
        XCTAssertTrue(dimming.isHidden, "hidden once the results show")
        run.search.searchBar.text = ""
        CYLRunLoop(0.4)
        XCTAssertFalse(dimming.isHidden)

        run.search.systemController.dimmingViewTapped()
        CYLRunLoop(0.9)
        XCTAssertFalse(run.search.isActive, "a tap on the dimming view leaves the search")

        run.search.launchView = makeLaunchView()
        CYLActivateSearch(run)
        XCTAssertTrue(dimming.isHidden, "ignored while a launch view is set")
        run.search.dimmingColor = nil
        XCTAssertNil(dimming.superview)
        CYLTearDownSearchRun(run)
    }
}

/**
 * The built-in launch view of CYLSearchController (`showsSuggestionsLaunchView`, `suggestions`, `historyStore`): the
 * suggestion area of CYLSearchView shown under the bar (docs/qmui-search-controller.md, "Merge phase 2 log").
 */
final class CYLSearchControllerSuggestionsLaunchTests: CYLSearchExampleTestCase {

    private func makeRun(suggestions: [String], store: CYLSearchSuggestionCache? = nil) -> CYLSearchRun {
        let run = CYLMakeSearchRun()
        run.search.historyStore = store
        run.search.suggestions = suggestions
        run.search.showsSuggestionsLaunchView = true
        return run
    }

    private func launch(_ run: CYLSearchRun) throws -> CYLSearchSuggestionsLaunchView {
        try XCTUnwrap(run.search.launchView as? CYLSearchSuggestionsLaunchView)
    }

    private func uniqueName() -> String { "CYLSuggestionsLaunchTests-\(UUID().uuidString)" }

    private let many = (1...14).map { "Suggestion number \($0)" }

    func testTheCustomLaunchViewPathStillWorks() throws {
        let run = CYLMakeSearchRun()
        XCTAssertFalse(run.search.showsSuggestionsLaunchView, "off by default: the launch view stays nil")
        XCTAssertNil(run.search.launchView)
        let custom = UIView()
        run.search.launchView = custom
        XCTAssertFalse(run.search.showsSuggestionsLaunchView)
        run.search.showsSuggestionsLaunchView = false
        XCTAssertTrue(run.search.launchView === custom, "off does not touch a custom view")
        CYLActivateSearch(run)
        XCTAssertNotNil(custom.window, "the custom view is the launch view")
        run.search.showsSuggestionsLaunchView = true
        XCTAssertTrue(run.search.launchView is CYLSearchSuggestionsLaunchView, "on replaces a custom view")
        XCTAssertNil(custom.superview)
        run.search.launchView = custom
        XCTAssertFalse(run.search.showsSuggestionsLaunchView, "a custom view turns the built-in one off")
        run.search.showsSuggestionsLaunchView = true
        run.search.alwaysShowsSearchResultsController = true
        XCTAssertNil(run.search.launchView, "always visible results clear it too")
        CYLTearDownSearchRun(run)
    }

    func testTagsAreFoldedAndTheFoldControlIsLast() throws {
        let run = makeRun(suggestions: many)
        CYLActivateSearch(run)
        let area = try launch(run).area
        XCTAssertEqual(area.titles, many)
        XCTAssertTrue(area.headerView.isHidden, "no history: no header")
        XCTAssertEqual(area.tagView.foldControl.position, CYLMenuFoldControlPosition.tail)
        XCTAssertFalse(area.tagView.isSectionExpanded(0), "folded at start")
        let folded = CYLOrderedTagCells(of: area.tagView)
        XCTAssertTrue(folded.last?.cell is CYLTagFoldCell, "folded: the fold control is the last tag")
        XCTAssertEqual(folded.filter { $0.cell is CYLTagFoldCell }.count, 1)
        XCTAssertEqual(Set(folded.map { Int($0.cell.frame.minY.rounded()) }).count, 2, "two rows")
        CYLTapTag(at: folded.last!.indexPath.item, in: area.tagView)
        XCTAssertTrue(area.tagView.isSectionExpanded(0), "a tap on the control unfolds")
        let unfolded = CYLOrderedTagCells(of: area.tagView)
        XCTAssertTrue(unfolded.last?.cell is CYLTagFoldCell, "unfolded: still the last tag")
        XCTAssertGreaterThan(unfolded.count, folded.count)
        CYLTearDownSearchRun(run)
    }

    func testLaunchContentIsNeverCoveredByTheBar() throws {
        let run = makeRun(suggestions: many)
        CYLActivateSearch(run)
        let launch = try launch(run)
        let area = launch.area
        func check(_ state: String) {
            let bar = run.search.searchBar.convert(run.search.searchBar.bounds, to: run.window).maxY
            XCTAssertGreaterThanOrEqual(launch.convert(launch.bounds, to: run.window).minY, bar - 0.5, "\(state): launch view under the bar")
            XCTAssertGreaterThanOrEqual(area.tagView.convert(area.tagView.bounds, to: run.window).minY, bar - 0.5, "\(state): tags under the bar")
            XCTAssertEqual(CYLTagCollectionView(in: area.tagView)?.adjustedContentInset.top ?? -1, 0, accuracy: 0.5, "\(state): no inset pushes the tags")
            let first = CYLOrderedTagCells(of: area.tagView).map { area.tagView.convert($0.cell.bounds, from: $0.cell).minY }.min() ?? 0
            XCTAssertGreaterThanOrEqual(first, -0.5, "\(state): the first row is inside the list")
            if #available(iOS 26.0, *) {
                var scrollers: [UIScrollView] = []
                func collect(_ view: UIView) { if let s = view as? UIScrollView { scrollers.append(s) }; view.subviews.forEach(collect) }
                collect(area.tagView)
                XCTAssertTrue(!scrollers.isEmpty && scrollers.allSatisfy { $0.topEdgeEffect.isHidden }, "\(state): no edge blur")
            }
        }
        check("active")
        CYLTapTag(at: CYLOrderedTagCells(of: area.tagView).last!.indexPath.item, in: area.tagView)
        check("unfolded")
        run.search.searchBar.text = "S"
        CYLRunLoop(0.4)
        run.search.searchBar.text = ""
        CYLRunLoop(0.4)
        check("after typing and clearing")
        run.window.frame = CGRect(x: 0, y: 0, width: 330, height: 640)
        CYLRunLoop(0.7)
        check("after a resize")
        CYLTearDownSearchRun(run)
    }

    func testHistoryChangesOfOneNameReachTheLaunchContentOnScreen() throws {
        let name = uniqueName()
        let store = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .userDefaults, name: name))
        defer { store.removeAllQueries() }
        let run = makeRun(suggestions: ["a", "b"], store: store)
        CYLActivateSearch(run)
        let area = try launch(run).area
        XCTAssertEqual(area.titles, ["a", "b"])
        // Another instance of the same history (cache(policy:name:) returns a new one on each call).
        let other = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .userDefaults, name: name))
        other.addQuery("first")
        XCTAssertEqual(area.titles, ["first"], "matched by name")
        XCTAssertFalse(area.headerView.isHidden)
        // The history of another name does not reach it.
        let stranger = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .userDefaults, name: uniqueName()))
        defer { stranger.removeAllQueries() }
        stranger.addQuery("elsewhere")
        XCTAssertEqual(area.titles, ["first"])
        // The same name under another policy is another history.
        let file = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .sandboxFile, name: name))
        defer { file.removeAllQueries() }
        file.addQuery("file")
        XCTAssertEqual(area.titles, ["first"])
        // A submit of a CYLSearchView with the same history reaches the controller's launch content too.
        let host = UIViewController()
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: host.view.bounds)
        host.view.addSubview(searchView)
        searchView.suggestionCachePolicy = .userDefaults
        searchView.suggestionCacheName = name
        searchView.showSearch(animated: false)
        searchView.setQuery("from search view", submit: true)
        CYLRunLoop(0.3)
        XCTAssertEqual(area.titles.first, "from search view", "one signal for both classes")
        searchView.removeFromSuperview()
        window.isHidden = true
        CYLTearDownSearchRun(run)
    }

    func testAStoreOfTheAppsOwnIsCoveredToo() throws {
        let store = CYLMemoryHistory()
        let run = makeRun(suggestions: ["a"], store: store)
        CYLActivateSearch(run)
        let area = try launch(run).area
        run.search.searchBar.text = "mine"
        run.search.searchBar.searchTextField.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(store.cachedQueries(), ["mine"])
        XCTAssertEqual(area.titles, ["mine"], "announced by the core: the store cannot post")
        area.clearButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(area.titles, ["a"])
        CYLTearDownSearchRun(run)
    }
}
