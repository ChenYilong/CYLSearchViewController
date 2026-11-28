//
//  CYLSearchControllerLaunchViewTests.swift
//  CYLSearchExampleTests
//
//  Rows E15 (launch view), E18 (always visible results) and E19 (dimming view) of docs/qmui-search-controller.md.
//

import CollectionViewClassifyMenu
import CYLTableViewPlaceHolder
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
        let run = makeSearchRun()
        let launch = makeLaunchView()
        run.search.launchView = launch
        activateSearch(run)
        let results = try XCTUnwrap(run.search.searchResultsController)
        let container = try XCTUnwrap(launch.superview)
        XCTAssertTrue(container === results.view.superview, "the launch view sits next to the results")
        XCTAssertTrue(results.view.isHidden, "the results are hidden while the text is empty")
        XCTAssertFalse(launch.isHidden)
        XCTAssertNotNil(launch.window)
        func check(_ message: String) {
            let barMaxY = run.search.searchBarMaxY
            XCTAssertGreaterThan(barMaxY, 0)
            XCTAssertEqual(launch.frame.minY, container.convert(CGPoint(x: 0, y: barMaxY), from: nil).y,
                           accuracy: 0.5, "\(message): starts under the bar")
            XCTAssertEqual(launch.frame.maxY, container.bounds.maxY, accuracy: 0.5, "\(message): ends at the bottom")
            XCTAssertEqual(launch.frame.width, container.bounds.width, accuracy: 0.5, "\(message): full width")
        }
        check("on activation")
        let barBottom = run.search.searchBar.convert(run.search.searchBar.bounds, to: run.window).maxY
        XCTAssertGreaterThanOrEqual(launch.convert(launch.bounds, to: run.window).minY, barBottom - 0.5, "not under the bar")

        run.window.frame = CGRect(x: 0, y: 0, width: 330, height: 640)
        runLoop(0.7)
        check("after a resize")

        run.search.searchBar.text = "H"
        runLoop(0.4)
        XCTAssertFalse(results.view.isHidden, "the results show once text is entered")
        let subviews = container.subviews
        let launchIndex = try XCTUnwrap(subviews.firstIndex(of: launch))
        let resultsIndex = try XCTUnwrap(subviews.firstIndex(of: results.view))
        XCTAssertLessThan(launchIndex, resultsIndex, "the launch view is behind the results")

        run.search.searchBar.text = ""
        runLoop(0.4)
        XCTAssertTrue(results.view.isHidden, "all text deleted: the launch view shows again")

        run.search.launchView = nil
        XCTAssertNil(launch.superview, "a removed launch view leaves the search view")
        tearDownSearchRun(run)
    }

    /// A launch view set after the search view exists is added at once.
    func testLaunchViewSetAfterTheViewIsLoadedIsAdded() {
        let run = makeSearchRun()
        activateSearch(run)
        let launch = makeLaunchView()
        run.search.launchView = launch
        XCTAssertNotNil(launch.superview)
        let other = makeLaunchView()
        run.search.launchView = other
        XCTAssertNil(launch.superview, "the replaced launch view is removed")
        XCTAssertNotNil(other.superview)
        tearDownSearchRun(run)
    }

    // MARK: - E18

    /// E18: alwaysShowsSearchResultsController shows the results at once, clears the launch view and the obscuring, and
    /// turning it off restores the obscuring.
    func testE18AlwaysShowsSearchResultsController() throws {
        let run = makeSearchRun()
        run.search.launchView = makeLaunchView()
        run.search.alwaysShowsSearchResultsController = true
        XCTAssertNil(run.search.launchView, "the launch view is cleared")
        XCTAssertTrue(run.search.alwaysShowsSearchResultsController)
        activateSearch(run)
        let results = try XCTUnwrap(run.search.searchResultsController)
        XCTAssertFalse(results.view.isHidden, "the results show with empty text")
        run.search.setActive(false, animated: true)
        runLoop(0.8)
        run.search.alwaysShowsSearchResultsController = false
        activateSearch(run)
        XCTAssertTrue(results.view.isHidden, "the results hide again with empty text")
        tearDownSearchRun(run)
    }

    // MARK: - E19

    /// E19: the own dimming view has the color, sits under the bar, shows while the text is empty, and a tap leaves the
    /// search; it is ignored when a launch view is set.
    func testE19DimmingViewColorPlacementAndTap() throws {
        let run = makeSearchRun()
        let color = UIColor.red.withAlphaComponent(0.4)
        run.search.dimmingColor = color
        activateSearch(run)
        let dimming = try XCTUnwrap(viewWithAccessibilityIdentifier(try XCTUnwrap(run.search.activePageView), "CYLSearchDimmingView"))
        XCTAssertEqual(dimming.backgroundColor, color)
        XCTAssertFalse(dimming.isHidden, "shown while the text is empty")
        let barBottom = run.search.searchBar.convert(run.search.searchBar.bounds, to: run.window).maxY
        XCTAssertGreaterThanOrEqual(dimming.convert(dimming.bounds, to: run.window).minY, barBottom - 0.5, "under the bar")
        XCTAssertEqual(dimming.convert(dimming.bounds, to: run.window).maxY, run.window.bounds.maxY, accuracy: 0.5)
        XCTAssertNotNil(dimming as? CYLSearchDimmingView, "the overlay that CYLSearchView's scrim is too")
        XCTAssertEqual((dimming as? UIControl)?.allTargets.count, 1, "a tap target")

        run.search.searchBar.text = "H"
        runLoop(0.4)
        XCTAssertTrue(dimming.isHidden, "hidden once the results show")
        run.search.searchBar.text = ""
        runLoop(0.4)
        XCTAssertFalse(dimming.isHidden)

        run.search.dimmingView.sendActions(for: .touchUpInside)
        runLoop(0.9)
        XCTAssertFalse(run.search.isActive, "a tap on the dimming view leaves the search")

        run.search.launchView = makeLaunchView()
        activateSearch(run)
        XCTAssertTrue(dimming.isHidden, "ignored while a launch view is set")
        run.search.dimmingColor = nil
        XCTAssertNil(dimming.superview)
        tearDownSearchRun(run)
    }
}

/**
 * The built-in launch view of CYLSearchController (`showsSuggestionsLaunchView`, `suggestions`, `historyStore`): the
 * suggestion area of CYLSearchView shown under the bar (docs/qmui-search-controller.md, "Merge phase 2 log").
 */
final class CYLSearchControllerSuggestionsLaunchTests: CYLSearchExampleTestCase {

    private func makeRun(suggestions: [String], store: CYLSearchSuggestionCache? = nil) -> CYLSearchRun {
        let run = makeSearchRun()
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
        let run = makeSearchRun()
        XCTAssertFalse(run.search.showsSuggestionsLaunchView, "off by default: the launch view stays nil")
        XCTAssertNil(run.search.launchView)
        let custom = UIView()
        run.search.launchView = custom
        XCTAssertFalse(run.search.showsSuggestionsLaunchView)
        run.search.showsSuggestionsLaunchView = false
        XCTAssertTrue(run.search.launchView === custom, "off does not touch a custom view")
        activateSearch(run)
        XCTAssertNotNil(custom.window, "the custom view is the launch view")
        run.search.showsSuggestionsLaunchView = true
        XCTAssertTrue(run.search.launchView is CYLSearchSuggestionsLaunchView, "on replaces a custom view")
        XCTAssertNil(custom.superview)
        run.search.launchView = custom
        XCTAssertFalse(run.search.showsSuggestionsLaunchView, "a custom view turns the built-in one off")
        run.search.showsSuggestionsLaunchView = true
        run.search.alwaysShowsSearchResultsController = true
        XCTAssertNil(run.search.launchView, "always visible results clear it too")
        tearDownSearchRun(run)
    }

    func testTagsAreFoldedAndTheFoldControlIsLast() throws {
        let run = makeRun(suggestions: many)
        activateSearch(run)
        let area = try launch(run).area
        XCTAssertEqual(area.titles, many)
        XCTAssertTrue(area.headerView.isHidden, "no history: no header")
        XCTAssertEqual(area.tagView.foldControl.position, CYLMenuFoldControlPosition.tail)
        XCTAssertFalse(area.tagView.isSectionExpanded(0), "folded at start")
        let folded = orderedTagCells(of: area.tagView)
        XCTAssertTrue(folded.last?.cell is CYLTagFoldCell, "folded: the fold control is the last tag")
        XCTAssertEqual(folded.filter { $0.cell is CYLTagFoldCell }.count, 1)
        XCTAssertEqual(Set(folded.map { Int($0.cell.frame.minY.rounded()) }).count, 2, "two rows")
        tapTag(at: folded.last!.indexPath.item, in: area.tagView)
        XCTAssertTrue(area.tagView.isSectionExpanded(0), "a tap on the control unfolds")
        let unfolded = orderedTagCells(of: area.tagView)
        XCTAssertTrue(unfolded.last?.cell is CYLTagFoldCell, "unfolded: still the last tag")
        XCTAssertGreaterThan(unfolded.count, folded.count)
        tearDownSearchRun(run)
    }

    func testLaunchContentIsNeverCoveredByTheBar() throws {
        let run = makeRun(suggestions: many)
        activateSearch(run)
        let launch = try launch(run)
        let area = launch.area
        func check(_ state: String) {
            let bar = run.search.searchBar.convert(run.search.searchBar.bounds, to: run.window).maxY
            XCTAssertGreaterThanOrEqual(launch.convert(launch.bounds, to: run.window).minY, bar - 0.5, "\(state): launch view under the bar")
            XCTAssertGreaterThanOrEqual(area.tagView.convert(area.tagView.bounds, to: run.window).minY, bar - 0.5, "\(state): tags under the bar")
            XCTAssertEqual(tagCollectionView(in: area.tagView)?.adjustedContentInset.top ?? -1, 0, accuracy: 0.5, "\(state): no inset pushes the tags")
            let first = orderedTagCells(of: area.tagView).map { area.tagView.convert($0.cell.bounds, from: $0.cell).minY }.min() ?? 0
            XCTAssertGreaterThanOrEqual(first, -0.5, "\(state): the first row is inside the list")
            if #available(iOS 26.0, *) {
                var scrollers: [UIScrollView] = []
                func collect(_ view: UIView) { if let s = view as? UIScrollView { scrollers.append(s) }; view.subviews.forEach(collect) }
                collect(area.tagView)
                XCTAssertTrue(!scrollers.isEmpty && scrollers.allSatisfy { $0.topEdgeEffect.isHidden }, "\(state): no edge blur")
            }
        }
        check("active")
        tapTag(at: orderedTagCells(of: area.tagView).last!.indexPath.item, in: area.tagView)
        check("unfolded")
        run.search.searchBar.text = "S"
        runLoop(0.4)
        run.search.searchBar.text = ""
        runLoop(0.4)
        check("after typing and clearing")
        run.window.frame = CGRect(x: 0, y: 0, width: 330, height: 640)
        runLoop(0.7)
        check("after a resize")
        tearDownSearchRun(run)
    }

    func testHistoryChangesOfOneNameReachTheLaunchContentOnScreen() throws {
        let name = uniqueName()
        let store = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .userDefaults, name: name))
        defer { store.removeAllQueries() }
        let run = makeRun(suggestions: ["a", "b"], store: store)
        activateSearch(run)
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
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: host.view.bounds)
        host.view.addSubview(searchView)
        searchView.suggestionCachePolicy = .userDefaults
        searchView.suggestionCacheName = name
        searchView.showSearch(animated: false)
        searchView.setQuery("from search view", submit: true)
        runLoop(0.3)
        XCTAssertEqual(area.titles.first, "from search view", "one signal for both classes")
        searchView.removeFromSuperview()
        window.isHidden = true
        tearDownSearchRun(run)
    }

    func testAStoreOfTheAppsOwnIsCoveredToo() throws {
        let store = CYLMemoryHistory()
        let run = makeRun(suggestions: ["a"], store: store)
        activateSearch(run)
        let area = try launch(run).area
        run.search.searchBar.text = "mine"
        run.search.searchBar.textField.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(store.cachedQueries(), ["mine"])
        XCTAssertEqual(area.titles, ["mine"], "announced by the core: the store cannot post")
        area.clearButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(area.titles, ["a"])
        tearDownSearchRun(run)
    }
}

// MARK: - Merge phase 3

/**
 * Results for `CYLSearchView`: the words that contain the query, shown as plain text.
 */
final class CYLSearchWordDataSource: NSObject, CYLSearchViewDataSource {
    static let words = ["Kotlin", "Swift", "Android", "Café"]
    var queryCount = 0

    func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any] {
        queryCount += 1
        return Self.words.filter { $0.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil }
    }

    func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any) {
        cell.textLabel?.text = result as? String
    }
}

/**
 * Records the four moments of `CYLSearchViewDelegate`.
 */
final class CYLSearchLifecycleRecorder: NSObject, CYLSearchViewDelegate {
    var events: [String] = []

    func searchViewWillShow(_ searchView: CYLSearchView) { events.append("willShow") }
    func searchViewDidShow(_ searchView: CYLSearchView) { events.append("didShow") }
    func searchViewWillClose(_ searchView: CYLSearchView) { events.append("willClose") }
    func searchViewDidClose(_ searchView: CYLSearchView) { events.append("didClose") }
}

/**
 * Merge phase 3 (docs/qmui-search-controller.md, "Merge phase 3 log"): the results and empty-view component, the match
 * highlight, the one dimming overlay, the history signal in `CYLSearchView`, the one active state and the edge swipe of
 * `CYLSearchView`.
 */
final class CYLSearchMergePhase3Tests: CYLSearchExampleTestCase {

    private func openSearchView(configure: ((CYLSearchView) -> Void)? = nil)
        -> (view: CYLSearchView, window: UIWindow, host: UIViewController) {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: .zero)
        searchView.suggestionCachePolicy = .none
        searchView.animationDuration = 0
        configure?(searchView)
        searchView.showSearch(in: host, animated: false)
        searchView.layoutIfNeeded()
        return (searchView, window, host)
    }

    private func foreground(_ text: NSAttributedString?, at index: Int) -> UIColor? {
        text?.attribute(.foregroundColor, at: index, effectiveRange: nil) as? UIColor
    }

    // MARK: - 1. The results and empty-view component

    /// Every screen shows the same CYLTableViewPlaceHolder placeholder, built by one factory.
    func testEveryScreenShowsTheSamePlaceholderClass() throws {
        // CYLSearchView: a scenario placeholder.
        let source = CYLSearchWordDataSource()
        let open = openSearchView {
            $0.showsEmptyResultsPlaceholder = true
            $0.resultsDataSource = source
        }
        open.view.setQuery("zzz", submit: false)
        XCTAssertNotNil(open.view.emptyResultsView)
        XCTAssertEqual(open.view.emptyResultsView?.scenario, .noSearchResults)
        XCTAssertEqual(open.view.emptyResultsView?.accessibilityIdentifier, "CYLSearchEmptyResults")
        open.window.isHidden = true

        // CYLSearchController: a text placeholder and a scenario placeholder.
        let run = makeSearchRun()
        activateSearch(run, text: "zzz")
        run.search.showEmptyView(text: "Nothing", detailText: "Try another word", buttonTitle: "Retry", buttonAction: nil)
        XCTAssertTrue(run.search.emptyView is CYLPlaceholderStackView)
        XCTAssertTrue(run.search.isEmptyViewShowing)
        run.search.showEmptyView(scenario: .noContent)
        XCTAssertEqual((run.search.emptyView as? CYLPlaceholderStackView)?.scenario, .noContent)
        run.search.hideEmptyView()
        XCTAssertFalse(run.search.isEmptyViewShowing)
        XCTAssertNil(run.search.emptyView)
        tearDownSearchRun(run)

        // CYLSearchTableViewController: the same two.
        let table = CYLSearchTableViewController(style: .plain)
        table.showsSearchBar = true
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = table
        window.makeKeyAndVisible()
        table.showEmptyView(text: "Nothing", detailText: nil)
        XCTAssertTrue(table.isEmptyViewShowing)
        XCTAssertNotNil(viewOfClass(table.tableView, CYLPlaceholderStackView.self))
        table.showEmptyView(scenario: .noSearchResults)
        XCTAssertEqual(table.tableView.subviews.compactMap { $0 as? CYLPlaceholderStackView }.count, 1, "the previous one left")
        table.hideEmptyView()
        XCTAssertFalse(table.isEmptyViewShowing)
        window.isHidden = true
    }

    /// The factory builds the button and its action, and the slot adopts, shows, hides and removes a view.
    func testEmptyViewFactoryAndSlot() throws {
        func count(_ view: UIView) -> Int { 1 + view.subviews.map(count).reduce(0, +) }
        let plain = CYLSearchEmptyView.message(text: "Nothing", detailText: nil)
        let withDetail = CYLSearchEmptyView.message(text: "Nothing", detailText: "Hint")
        let withButton = CYLSearchEmptyView.message(text: "Nothing", detailText: "Hint", buttonTitle: "Retry") {}
        XCTAssertGreaterThan(count(withDetail), count(plain), "a detail adds a hint")
        XCTAssertGreaterThan(count(withButton), count(withDetail), "a button title adds a button")
        XCTAssertEqual(count(CYLSearchEmptyView.message(text: "Nothing", detailText: "", buttonTitle: "")), count(plain), "empty strings add nothing")
        XCTAssertEqual(CYLSearchEmptyView.scenario(.noContent, identifier: "X").accessibilityIdentifier, "X")
        XCTAssertEqual(CYLSearchEmptyView.scenario(.noContent).scenario, .noContent)

        let slot = CYLSearchEmptyViewSlot()
        let container = UIView()
        XCTAssertFalse(slot.isShowing)
        let first = UIView()
        slot.adopt(first)
        XCTAssertFalse(slot.isShowing, "adopted, not in a container yet")
        slot.show(in: container)
        XCTAssertTrue(slot.isShowing)
        slot.hide()
        XCTAssertFalse(slot.isShowing)
        XCTAssertTrue(first.superview === container, "hiding keeps the view in place")
        slot.show(in: container)
        XCTAssertFalse(first.isHidden)
        let second = UIView()
        slot.adopt(second)
        XCTAssertNil(first.superview, "adopting another view takes the previous one out")
        slot.show(in: container)
        slot.remove()
        XCTAssertNil(slot.view)
        XCTAssertNil(second.superview)
    }

    /// The empty view of CYLSearchController ends at the keyboard, as CYLSearchView's does; the tables hide the top edge effect.
    func testControllerEmptyViewEndsAtTheKeyboard() throws {
        let run = makeSearchRun()
        activateSearch(run, text: "zzz")
        let empty = try XCTUnwrap(run.search.emptyView)
        // The field of the active search takes focus, so a real keyboard may be up: measure the full height without one.
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: nil)
        runLoop(0.2)
        let full = empty.frame.height
        XCTAssertGreaterThan(full, 0)
        let keyboard = CGRect(x: 0, y: 874 - 336, width: 402, height: 336)
        let screenKeyboard = run.window.convert(keyboard, to: run.window.screen.coordinateSpace)
        NotificationCenter.default.post(name: UIResponder.keyboardWillChangeFrameNotification, object: nil,
                                        userInfo: [UIResponder.keyboardFrameEndUserInfoKey: NSValue(cgRect: screenKeyboard)])
        runLoop(0.2)
        XCTAssertLessThanOrEqual(empty.convert(empty.bounds, to: run.window).maxY, keyboard.minY + 0.5, "ends at the keyboard")
        XCTAssertLessThan(empty.frame.height, full)
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: nil)
        runLoop(0.2)
        XCTAssertEqual(empty.frame.height, full, accuracy: 0.5, "the keyboard gone, full height again")
        tearDownSearchRun(run)
    }

    func testSearchViewTablesHideTheTopEdgeEffect() {
        let open = openSearchView()
        if #available(iOS 26.0, *) {
            XCTAssertTrue(open.view.resultsTableView.topEdgeEffect.isHidden, "the first result is not blurred under the bar")
            XCTAssertTrue(open.view.suggestionsTableView.topEdgeEffect.isHidden)
        }
        open.window.isHidden = true
    }

    // MARK: - 2. The match highlight

    func testHighlightIsOffByDefaultAndMarksTheFirstMatchInCYLSearchView() throws {
        let source = CYLSearchWordDataSource()
        let open = openSearchView {
            $0.resultsDataSource = source
        }
        XCTAssertFalse(open.view.highlightsResultMatches)
        XCTAssertNil(open.view.resultMatchHighlightColor)
        open.view.setQuery("OT", submit: false)
        let first = IndexPath(row: 0, section: 0)
        var cell = open.view.tableView(open.view.resultsTableView, cellForRowAt: first)
        XCTAssertEqual(cell.textLabel?.text, "Kotlin")
        XCTAssertNotEqual(foreground(cell.textLabel?.attributedText, at: 1), cell.tintColor, "off: plain text")

        open.view.highlightsResultMatches = true
        cell = open.view.tableView(open.view.resultsTableView, cellForRowAt: first)
        let text = try XCTUnwrap(cell.textLabel?.attributedText)
        XCTAssertEqual(text.string, "Kotlin")
        XCTAssertEqual(foreground(text, at: 1), cell.tintColor, "the match (case-insensitive) takes the tint color")
        XCTAssertEqual(foreground(text, at: 2), cell.tintColor)
        XCTAssertEqual(foreground(text, at: 0), .label, "the rest keeps the text color")
        XCTAssertEqual(foreground(text, at: 3), .label)

        open.view.resultMatchHighlightColor = .systemRed
        cell = open.view.tableView(open.view.resultsTableView, cellForRowAt: first)
        XCTAssertEqual(foreground(cell.textLabel?.attributedText, at: 1), .systemRed, "a color of its own")

        open.view.setQuery("cafe", submit: false)
        cell = open.view.tableView(open.view.resultsTableView, cellForRowAt: first)
        XCTAssertEqual(foreground(cell.textLabel?.attributedText, at: 0), .systemRed, "diacritics are ignored")
        open.window.isHidden = true
    }

    /// A list content configuration is highlighted too; an empty query and the option off change nothing.
    func testHighlightWorksOnListContentConfigurationsAndKeepsItsRules() throws {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var content = UIListContentConfiguration.cell()
        content.text = "Swift"
        cell.contentConfiguration = content
        var highlight = CYLSearchResultHighlight()
        highlight.apply(to: cell, query: "wi")
        XCTAssertNil((cell.contentConfiguration as? UIListContentConfiguration)?.attributedText, "off")
        highlight.isEnabled = true
        highlight.color = .systemGreen
        highlight.apply(to: cell, query: "  ")
        XCTAssertNil((cell.contentConfiguration as? UIListContentConfiguration)?.attributedText, "an empty query")
        highlight.apply(to: cell, query: "wi")
        let text = try XCTUnwrap((cell.contentConfiguration as? UIListContentConfiguration)?.attributedText)
        XCTAssertEqual(foreground(text, at: 1), .systemGreen)
        XCTAssertNotEqual(foreground(text, at: 0), .systemGreen)
        highlight.apply(to: cell, query: "nomatch")
        XCTAssertEqual((cell.contentConfiguration as? UIListContentConfiguration)?.attributedText?.string, "Swift", "no match, no change")
    }

    /// A reused label: UIKit synced its text color to a highlight at the first character; the next row's rest is not drawn in it.
    func testHighlightDoesNotLeakIntoAReusedLabel() throws {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        var highlight = CYLSearchResultHighlight()
        highlight.isEnabled = true
        highlight.color = .systemPurple
        cell.textLabel?.text = "Kotlin"
        highlight.apply(to: cell, query: "Ko")
        XCTAssertEqual(foreground(cell.textLabel?.attributedText, at: 0), .systemPurple)
        cell.textLabel?.text = "Swift"
        highlight.apply(to: cell, query: "wi")
        let text = try XCTUnwrap(cell.textLabel?.attributedText)
        XCTAssertEqual(foreground(text, at: 0), .label, "the rest is drawn in the label color, not the earlier highlight")
        XCTAssertEqual(foreground(text, at: 1), .systemPurple)
        // A data source that colors its rows itself keeps its color.
        cell.textLabel?.textColor = .systemGray
        cell.textLabel?.text = "Swift"
        highlight.apply(to: cell, query: "wi")
        XCTAssertEqual(foreground(cell.textLabel?.attributedText, at: 0), .systemGray)
    }

    func testHighlightInCYLSearchControllerThroughAForwardingDataSource() throws {
        let run = makeSearchRun()
        let search = run.search
        XCTAssertFalse(search.highlightsResultMatches)
        search.highlightsResultMatches = true
        activateSearch(run, text: "ea")
        let table = try XCTUnwrap(search.tableView)
        let dataSource = try XCTUnwrap(table.dataSource)
        XCTAssertFalse(dataSource === run.contents, "a proxy stands in front while the option is on")
        XCTAssertTrue(table.delegate === run.contents, "the delegate is the owner")
        for selector in [#selector(UITableViewDataSource.numberOfSections(in:)),
                         #selector(UITableViewDataSource.tableView(_:titleForHeaderInSection:)),
                         #selector(UITableViewDataSource.tableView(_:canEditRowAt:))] {
            XCTAssertEqual(dataSource.responds(to: selector), run.contents.responds(to: selector), "\(selector) is forwarded")
        }
        XCTAssertEqual(table.numberOfRows(inSection: 0), 40, "Health and Healthy, twenty rows each")
        let cell = dataSource.tableView(table, cellForRowAt: IndexPath(row: 0, section: 0))
        let text = try XCTUnwrap(cell.textLabel?.attributedText)
        XCTAssertEqual(text.string, "Health")
        XCTAssertEqual(foreground(text, at: 1), cell.tintColor)
        XCTAssertEqual(foreground(text, at: 2), cell.tintColor)
        XCTAssertNotEqual(foreground(text, at: 0), cell.tintColor)

        search.resultMatchHighlightColor = .systemOrange
        let again = dataSource.tableView(table, cellForRowAt: IndexPath(row: 20, section: 0))
        XCTAssertEqual(foreground(again.textLabel?.attributedText, at: 1), .systemOrange)

        search.highlightsResultMatches = false
        XCTAssertTrue(table.dataSource === run.contents, "off: the owner's data source again")
        tearDownSearchRun(run)
    }

    // MARK: - 3. One dimming overlay

    func testScrimAndDimmingColorAreTheSameOverlayAndATapEndsTheSearch() throws {
        let scrim = UIColor.black.withAlphaComponent(0.4)
        let open = openSearchView { $0.scrimColor = scrim }
        let viewOverlay = try XCTUnwrap(viewOfClass(open.view, CYLSearchDimmingView.self))
        XCTAssertEqual(viewOverlay.color, scrim)
        XCTAssertEqual(viewOverlay.backgroundColor, scrim)
        XCTAssertEqual(viewOverlay.accessibilityIdentifier, "CYLSearchDimmingView")
        XCTAssertFalse(viewOverlay.isAccessibilityElement)
        open.view.scrimColor = nil
        XCTAssertEqual(viewOverlay.backgroundColor, .clear)
        open.view.scrimColor = scrim
        viewOverlay.sendActions(for: .touchUpInside)
        XCTAssertFalse(open.view.searchOpen, "a tap ends the search in CYLSearchView")
        XCTAssertTrue(open.view.isHidden)
        open.window.isHidden = true

        let run = makeSearchRun()
        run.search.dimmingColor = scrim
        activateSearch(run)
        let controllerOverlay = run.search.dimmingView
        XCTAssertEqual(controllerOverlay.color, scrim)
        XCTAssertEqual(controllerOverlay.accessibilityIdentifier, viewOverlay.accessibilityIdentifier, "the same overlay class")
        controllerOverlay.sendActions(for: .touchUpInside)
        runLoop(0.9)
        XCTAssertFalse(run.search.isActive, "a tap ends the search in CYLSearchController")
        tearDownSearchRun(run)
    }

    // MARK: - 4. The history signal in CYLSearchView

    func testSearchViewRefreshesWhileOpenWhenAnotherViewChangesTheHistory() throws {
        let name = "CYLMergePhase3History\(UUID().uuidString)"
        let source = CYLSearchWordDataSource()
        let open = openSearchView {
            $0.suggestionCachePolicy = .userDefaults
            $0.suggestionCacheName = name
            $0.suggestions = ["Kotlin"]
            $0.showsSuggestionsForEmptyQuery = true
            $0.resultsDataSource = source
        }
        defer { open.view.suggestionCache?.removeAllQueries(); open.window.isHidden = true }
        XCTAssertEqual(open.view.filteredSuggestions, ["Kotlin"])
        // Another instance of the same history, as another search screen has: the open view reads it again.
        let other = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .userDefaults, name: name))
        other.addQuery("kiwi")
        XCTAssertEqual(open.view.filteredSuggestions, ["kiwi"], "the history replaces the suggestions while the query is empty")
        XCTAssertTrue(open.view.suggestionCacheHeaderView.isHidden == false)
        other.removeAllQueries()
        XCTAssertEqual(open.view.filteredSuggestions, ["Kotlin"], "cleared elsewhere, cleared here")

        // Another name is another history.
        CYLSearchResources.suggestionCache(policy: .userDefaults, name: name + "x")?.addQuery("nope")
        XCTAssertEqual(open.view.filteredSuggestions, ["Kotlin"])
        CYLSearchResources.suggestionCache(policy: .userDefaults, name: name + "x")?.removeAllQueries()

        // Its own submit does not run the results again (the signal is for changes made elsewhere).
        open.view.setQuery("Swift", submit: false)
        let count = source.queryCount
        open.view.searchBarView.submit()
        XCTAssertEqual(source.queryCount, count, "a submit of this view asks the data source nothing new")

        // Closed, it does not refresh.
        open.view.closeSearch()
        let closedCount = source.queryCount
        other.addQuery("papaya")
        XCTAssertEqual(source.queryCount, closedCount, "a closed view does not read the history")
    }

    /// One place decides history, else suggestions: the launch view's reload and the filtered list agree.
    func testSuggestionAreaResolvesHistoryElseSuggestions() {
        let memory = CYLMemoryHistory()
        let suggestions = ["Kotlin", "Swift", "Android"]
        var resolution = CYLSearchSuggestionArea.resolve(cache: memory, suggestions: suggestions, query: "", showsForEmptyQuery: true)
        XCTAssertEqual(resolution.titles, suggestions)
        XCTAssertFalse(resolution.showsHistory)
        resolution = CYLSearchSuggestionArea.resolve(cache: memory, suggestions: suggestions, query: "", showsForEmptyQuery: false)
        XCTAssertEqual(resolution.titles, [], "an empty query lists nothing unless asked to")
        memory.addQuery("Swift")
        resolution = CYLSearchSuggestionArea.resolve(cache: memory, suggestions: suggestions, query: " ", showsForEmptyQuery: false)
        XCTAssertEqual(resolution.titles, ["Swift"])
        XCTAssertTrue(resolution.showsHistory, "the history, newest first, whatever showsForEmptyQuery says")
        resolution = CYLSearchSuggestionArea.resolve(cache: memory, suggestions: suggestions, query: "t", showsForEmptyQuery: false)
        XCTAssertEqual(resolution.titles, ["Swift", "Kotlin"], "typing: cached queries first, then matching suggestions without repeats")
        XCTAssertFalse(resolution.showsHistory)
        resolution = CYLSearchSuggestionArea.resolve(cache: nil, suggestions: suggestions, query: "droid", showsForEmptyQuery: false) { candidate, query in
            candidate.lowercased().hasSuffix(query)
        }
        XCTAssertEqual(resolution.titles, ["Android"], "a filter of its own")

        let area = CYLSearchSuggestionArea()
        area.suggestions = suggestions
        area.cache = memory
        XCTAssertEqual(area.titles, ["Swift"], "reload uses the same choice")
        XCTAssertTrue(area.showsHistory)
        memory.removeAllQueries()
        area.reload()
        XCTAssertEqual(area.titles, suggestions)
        XCTAssertFalse(area.showsHistory)
    }

    // MARK: - 5. One active state

    func testSearchViewActiveStateEventsAndAliases() {
        let recorder = CYLSearchLifecycleRecorder()
        let open = openSearchView { $0.delegate = recorder }
        XCTAssertEqual(recorder.events, ["willShow", "didShow"])
        XCTAssertTrue(open.view.isActive)
        XCTAssertTrue(open.view.searchOpen)
        open.view.setActive(false, animated: false)
        XCTAssertFalse(open.view.isActive)
        XCTAssertFalse(open.view.searchOpen)
        XCTAssertEqual(recorder.events, ["willShow", "didShow", "willClose", "didClose"])
        open.view.isActive = true
        XCTAssertTrue(open.view.searchOpen, "the setter opens without animation")
        open.view.isActive = true
        XCTAssertEqual(recorder.events.count, 6, "no second event for the state it already has")
        open.view.closeSearch(animated: false)
        XCTAssertEqual(recorder.events.suffix(2), ["willClose", "didClose"])
        open.window.isHidden = true
    }

    private func waitForEvent(_ name: String, in recorder: CYLSearchLifecycleRecorder) {
        let deadline = Date(timeIntervalSinceNow: 3)
        while !recorder.events.contains(name) && Date() < deadline {
            runLoop(0.05)
        }
    }

    func testSearchViewActiveStateWithAnimation() {
        let recorder = CYLSearchLifecycleRecorder()
        let open = openSearchView { $0.delegate = recorder }
        open.view.animationDuration = 0.2
        recorder.events = []
        open.view.closeSearch(animated: true)
        XCTAssertEqual(recorder.events, ["willClose"], "will comes before the animation, did after it")
        XCTAssertFalse(open.view.isActive)
        // A slow CI simulator can finish a 0.2 s animation later than 0.6 s: wait up to 3 s for each "did" event.
        waitForEvent("didClose", in: recorder)
        XCTAssertEqual(recorder.events, ["willClose", "didClose"])
        open.view.showSearch(animated: true)
        XCTAssertEqual(recorder.events.suffix(1), ["willShow"])
        waitForEvent("didShow", in: recorder)
        XCTAssertEqual(recorder.events, ["willClose", "didClose", "willShow", "didShow"])
        open.window.isHidden = true
    }

    /// A show during a close: the stale completion must not hide the page again.
    func testShowDuringCloseKeepsTheViewOnScreen() {
        let recorder = CYLSearchLifecycleRecorder()
        let open = openSearchView { $0.delegate = recorder }
        open.view.animationDuration = 0.3
        recorder.events = []
        open.view.closeSearch(animated: true)
        runLoop(0.05)
        open.view.showSearch(animated: true)
        runLoop(0.9)
        // A slow CI simulator can finish the 0.3 s opening later than 0.9 s: wait up to 3 s more for it.
        let deadline = Date(timeIntervalSinceNow: 3)
        while !recorder.events.contains("didShow") && Date() < deadline {
            runLoop(0.05)
        }
        XCTAssertTrue(open.view.searchOpen)
        XCTAssertFalse(open.view.isHidden, "the closing did not win")
        XCTAssertEqual(open.view.alpha, 1, accuracy: 0.01)
        XCTAssertEqual(recorder.events, ["willClose", "willShow", "didShow"], "a closing that was overtaken never finishes")
        open.window.isHidden = true
    }

    func testPresentationStateMovesThroughItsPhases() {
        let state = CYLSearchPresentationState()
        var events: [CYLSearchPresentationEvent] = []
        state.onEvent = { events.append($0) }
        XCTAssertFalse(state.isActive)
        state.send(.willPresent)
        XCTAssertEqual(state.phase, .presenting)
        XCTAssertTrue(state.isActive)
        let generation = state.generation
        state.send(.didPresent)
        XCTAssertEqual(state.phase, .active)
        XCTAssertEqual(state.generation, generation, "did does not start a new moment")
        state.send(.willDismiss)
        XCTAssertEqual(state.phase, .dismissing)
        XCTAssertFalse(state.isActive)
        XCTAssertGreaterThan(state.generation, generation)
        state.send(.didDismiss)
        XCTAssertEqual(state.phase, .inactive)
        XCTAssertEqual(events, [.willPresent, .didPresent, .willDismiss, .didDismiss])
    }

    /// The controller's state follows UIKit's callbacks, and its alias names run the same state.
    func testControllerActiveStateAndAliases() {
        let run = makeSearchRun()
        let search = run.search
        XCTAssertFalse(search.searchOpen)
        XCTAssertEqual(search.presentationState.phase, .inactive)
        search.showSearch(animated: false)
        runLoop(0.6)
        XCTAssertTrue(search.searchOpen)
        XCTAssertEqual(search.searchOpen, search.isActive)
        XCTAssertEqual(search.presentationState.phase, .active)
        XCTAssertEqual(run.contents.events.filter { $0.hasSuffix("Present") }, ["willPresent", "didPresent"])
        search.closeSearch(animated: false)
        runLoop(0.6)
        XCTAssertFalse(search.searchOpen)
        XCTAssertEqual(search.presentationState.phase, .inactive)
        XCTAssertEqual(run.contents.events.filter { $0.hasSuffix("Dismiss") }, ["willDismiss", "didDismiss"])
        XCTAssertEqual(search.presentationState.isActive, search.isActive)
        tearDownSearchRun(run)
    }

    // MARK: - 5b. The edge swipe of CYLSearchView

    func testEdgeSwipeRuleIsShared() {
        XCTAssertTrue(CYLSearchEdgeSwipe.completes(offset: 101, width: 400, velocity: 1))
        XCTAssertFalse(CYLSearchEdgeSwipe.completes(offset: 100, width: 400, velocity: 1), "a quarter exactly stays")
        XCTAssertFalse(CYLSearchEdgeSwipe.completes(offset: 300, width: 400, velocity: 0), "not moving right")
        XCTAssertFalse(CYLSearchEdgeSwipe.completes(offset: 300, width: 0, velocity: 5))
        XCTAssertEqual(CYLSearchEdgeSwipe.duration(distance: 200, width: 400), 0.1, accuracy: 0.0001)
        let gesture = CYLSearchEdgeSwipe.makeGesture(target: self, action: #selector(testEdgeSwipeRuleIsShared))
        XCTAssertEqual(gesture.edges, .left)
    }

    func testSearchViewSwipeToDismiss() throws {
        let open = openSearchView()
        let view = open.view
        let gesture = try XCTUnwrap(view.swipeGestureRecognizer)
        XCTAssertFalse(view.supportsSwipeToDismissSearch, "off by default")
        XCTAssertFalse(gesture.isEnabled)
        XCTAssertTrue(view.gestureRecognizers?.contains(gesture) == true)
        XCTAssertEqual(gesture.edges, .left)
        view.supportsSwipeToDismissSearch = true
        XCTAssertTrue(gesture.isEnabled)

        // Dragged a little, then let go: it comes back.
        view.swipeBegan()
        view.swipeChanged(translationX: 40)
        view.swipeEnded(velocityX: 800)
        runLoop(0.5)
        XCTAssertTrue(view.searchOpen, "a short swipe stays")
        // Past a quarter but not moving right: it comes back.
        view.swipeBegan()
        view.swipeChanged(translationX: 300)
        view.swipeEnded(velocityX: -50)
        runLoop(0.5)
        XCTAssertTrue(view.searchOpen, "a swipe that returns stays")
        XCTAssertFalse(view.isHidden)

        // Past a quarter, moving right: the search ends.
        let recorder = CYLSearchLifecycleRecorder()
        view.delegate = recorder
        view.swipeBegan()
        view.swipeChanged(translationX: 201)
        view.swipeEnded(velocityX: 800)
        runLoop(0.7)
        XCTAssertFalse(view.searchOpen, "the swipe ended the search")
        XCTAssertTrue(view.isHidden)
        XCTAssertEqual(recorder.events, ["willClose", "didClose"])

        // Off again: the gesture does nothing.
        view.showSearch(animated: false)
        view.supportsSwipeToDismissSearch = false
        XCTAssertFalse(gesture.isEnabled)
        open.window.isHidden = true
    }
}

// MARK: - Merge phase 4

/**
 * Merge phase 4 (docs/qmui-search-controller.md, "Merge phase 4 log"): what the examples used to build by hand and the core
 * now offers: the "no results" empty view of `CYLSearchController`, the clear button below the suggestion list and the
 * header over the results of `CYLSearchView`.
 */
final class CYLSearchMergePhase4Tests: CYLSearchExampleTestCase {

    private func openSearchView(configure: ((CYLSearchView) -> Void)? = nil)
        -> (view: CYLSearchView, window: UIWindow, host: UIViewController) {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: .zero)
        searchView.suggestionCachePolicy = .none
        searchView.animationDuration = 0
        configure?(searchView)
        searchView.showSearch(in: host, animated: false)
        searchView.layoutIfNeeded()
        return (searchView, window, host)
    }

    /// `noResultsText`: the controller shows and hides the empty view by the row count, the delegate does not.
    func testNoResultsTextManagesTheEmptyView() {
        let run = makeSearchRun { $0.showsEmptyViewWithoutMatch = false }
        run.search.noResultsText = "Nothing found"
        activateSearch(run, text: "Zzz")
        XCTAssertTrue(run.search.isEmptyViewShowing, "no row for the text")
        run.search.searchBar.text = "He"
        runLoop(0.4)
        XCTAssertFalse(run.search.isEmptyViewShowing, "rows again")
        run.search.searchBar.text = ""
        runLoop(0.4)
        XCTAssertFalse(run.search.isEmptyViewShowing, "an empty text is never an empty result")
        run.search.noResultsText = nil
        run.search.searchBar.text = "Zzz"
        runLoop(0.4)
        XCTAssertFalse(run.search.isEmptyViewShowing, "without the option the delegate decides")
        tearDownSearchRun(run)
    }

    /// `suggestionCacheFooterTitle`: a text button below the list clears the cache; nil takes it away again.
    func testClearFooterClearsTheCache() throws {
        let open = openSearchView {
            $0.suggestionCachePolicy = .userDefaults
            $0.suggestionCacheName = "CYLMergePhase4Footer"
            $0.suggestionStyle = .list
            $0.showsSuggestionCacheHeader = false
            $0.suggestionCacheFooterTitle = "Clear history"
        }
        let view = open.view
        view.clearSuggestionCache()
        view.suggestionCache?.addQuery("Swift")
        view.setQuery("", submit: false)
        view.layoutIfNeeded()
        let footer = try XCTUnwrap(view.suggestionsTableView.tableFooterView as? CYLSearchClearFooterView)
        XCTAssertEqual(footer.button.title(for: .normal), "Clear history")
        XCTAssertEqual(footer.button.accessibilityIdentifier, "CYLSearchSuggestionCacheFooterButton")
        XCTAssertFalse(view.suggestionsTableView.isHidden)
        XCTAssertEqual(view.suggestionsTableView.numberOfRows(inSection: 0), 1)
        footer.button.sendActions(for: .touchUpInside)
        XCTAssertEqual(view.suggestionsTableView.numberOfRows(inSection: 0), 0, "the text button cleared the history")
        view.suggestionCacheFooterTitle = nil
        XCTAssertNil(view.suggestionsTableView.tableFooterView)
        let own = UIView()
        view.suggestionsTableView.tableFooterView = own
        view.suggestionCacheFooterTitle = nil
        XCTAssertTrue(view.suggestionsTableView.tableFooterView === own, "a footer of the host stays")
        open.window.isHidden = true
    }

    /// `resultsHeaderTitleProvider`: a header over the results, gone with them.
    func testResultsHeaderTitlesTheResults() throws {
        let source = CYLSearchWordDataSource()
        let open = openSearchView {
            $0.resultsDataSource = source
            $0.resultsHeaderTitleProvider = { "About \($0)" }
            $0.resultsHeaderTextColor = .systemTeal
        }
        let view = open.view
        XCTAssertNil(view.resultsTableView.tableHeaderView, "no results yet")
        view.setQuery("Swift", submit: false)
        let header = try XCTUnwrap(view.resultsTableView.tableHeaderView)
        let label = try XCTUnwrap(viewOfClass(header, UILabel.self))
        XCTAssertEqual(label.text, "About Swift")
        XCTAssertEqual(label.textColor, .systemTeal)
        XCTAssertTrue(label.accessibilityTraits.contains(.header))
        view.setQuery("Kot", submit: false)
        XCTAssertEqual(viewOfClass(try XCTUnwrap(view.resultsTableView.tableHeaderView), UILabel.self)?.text, "About Kot")
        view.setQuery("", submit: false)
        XCTAssertNil(view.resultsTableView.tableHeaderView, "the suggestions show again")
        view.resultsHeaderTitleProvider = { _ in nil }
        view.setQuery("Swift", submit: false)
        XCTAssertNil(view.resultsTableView.tableHeaderView, "a nil title shows no header")
        open.window.isHidden = true
    }
}

// MARK: - Merge phase 5b

/**
 * Merge phase 5b (docs/qmui-search-controller.md, "Merge phase 5b log"): the gaps of the core that the React Native and
 * Flutter wrappers worked around: `noResultsText` of `CYLSearchView`, the public history notification with its
 * `userInfo`, the header snapping through `CYLSearchView`, and `textDidChange` for a tapped suggestion.
 */
final class CYLSearchMergePhase5bTests: CYLSearchExampleTestCase {

    private final class EventRecorder: NSObject, CYLSearchViewDelegate {
        var events: [String] = []
        func searchView(_ searchView: CYLSearchView, textDidChange text: String) { events.append("text:\(text)") }
        func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool {
            events.append("submit:\(text)")
            return true
        }
    }

    private func openSearchView(configure: ((CYLSearchView) -> Void)? = nil)
        -> (view: CYLSearchView, window: UIWindow, host: UIViewController) {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let searchView = CYLSearchView(frame: .zero)
        searchView.suggestionCachePolicy = .none
        searchView.animationDuration = 0
        configure?(searchView)
        searchView.showSearch(in: host, animated: false)
        searchView.layoutIfNeeded()
        return (searchView, window, host)
    }

    /// `noResultsText` of the search view: the same placeholder component as the controller's, with that title.
    func testSearchViewNoResultsTextTitlesTheEmptyResultsPlaceholder() throws {
        let source = CYLSearchWordDataSource()
        let open = openSearchView { $0.resultsDataSource = source }
        let view = open.view
        view.setQuery("Zzz", submit: false)
        XCTAssertNil(view.emptyResultsView, "off by default")
        view.noResultsText = "Nothing found"
        let placeholder = try XCTUnwrap(view.emptyResultsView, "a text turns the placeholder on")
        XCTAssertEqual(placeholder.titleLabel.text, "Nothing found")
        XCTAssertFalse(placeholder.isHidden)
        view.setQuery("Swift", submit: false)
        XCTAssertTrue(view.emptyResultsView?.isHidden ?? true, "rows again")
        view.setQuery("Qqq", submit: false)
        XCTAssertEqual(view.emptyResultsView?.titleLabel.text, "Nothing found")
        view.setQuery("", submit: false)
        XCTAssertTrue(view.emptyResultsView?.isHidden ?? true, "an empty text is never an empty result")
        view.noResultsText = nil
        view.setQuery("Zzz", submit: false)
        XCTAssertNil(view.emptyResultsView, "nil and no switch: no placeholder")
        view.showsEmptyResultsPlaceholder = true
        XCTAssertNotNil(view.emptyResultsView, "the switch keeps its scenario placeholder")
        open.window.isHidden = true
    }

    /// The history notification is public, carries policy and name, and is told apart per history.
    func testHistoryNotificationCarriesPolicyAndName() throws {
        let name = "CYLMerge5bHistory\(UUID().uuidString)"
        var received: [(Int?, String?)] = []
        let token = NotificationCenter.default.addObserver(forName: CYLSearchResources.historyDidChangeNotification,
                                                           object: nil, queue: nil) { note in
            received.append((note.userInfo?["policy"] as? Int, note.userInfo?["name"] as? String))
        }
        defer { NotificationCenter.default.removeObserver(token) }
        let store = try XCTUnwrap(CYLSearchResources.suggestionCache(policy: .userDefaults, name: name))
        defer { store.removeAllQueries() }
        received.removeAll()
        store.addQuery("kiwi")
        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received.first?.0, CYLSearchSuggestionCachePolicy.userDefaults.rawValue)
        XCTAssertEqual(received.first?.1, name)
        store.removeQuery("kiwi")
        store.removeAllQueries()
        XCTAssertEqual(received.map { $0.1 }, [name, name, name], "remove, remove all")
        XCTAssertEqual(CYLSearchResources.historyDidChangeNotification.rawValue, "CYLSearchSuggestionStoreDidChange")
    }

    /// A header search bar of a table view of the host snaps through `CYLSearchView`, with the controller's rules.
    func testSearchViewSnapsAHeaderOfAHostTable() throws {
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let table = UITableView(frame: host.view.bounds, style: .plain)
        host.view.addSubview(table)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 402, height: 56))
        table.tableHeaderView = header
        table.reloadData()
        table.layoutIfNeeded()
        let view = CYLSearchView(frame: .zero)
        view.suggestionCachePolicy = .none
        XCTAssertEqual(table.contentInset.bottom, 0)
        view.setSnapsHeader(true, for: header, in: table)
        XCTAssertGreaterThan(table.contentInset.bottom, 0, "an empty table gets the room the header needs to leave the screen")
        view.setSnapsHeader(false, for: header, in: table)
        XCTAssertEqual(table.contentInset.bottom, 0, "off takes the inset away")
        view.setSnapsHeader(true, for: header, in: table)
        XCTAssertGreaterThan(table.contentInset.bottom, 0)
        window.isHidden = true
    }

    /// A tapped suggestion reports `textDidChange` before the submit, with and without `submitsOnSuggestionSelection`.
    func testTappedSuggestionReportsTextDidChangeBeforeSubmit() {
        for submits in [true, false] {
            let recorder = EventRecorder()
            let open = openSearchView {
                $0.suggestions = ["Swift", "Kotlin"]
                $0.suggestionStyle = .list
                $0.showsSuggestionsForEmptyQuery = true
                $0.submitsOnSuggestionSelection = submits
                $0.closesOnSubmit = false
                $0.delegate = recorder
            }
            let view = open.view
            view.tableView(view.suggestionsTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            XCTAssertEqual(recorder.events, submits ? ["text:Swift", "submit:Swift"] : ["text:Swift"], "submits: \(submits)")
            open.window.isHidden = true
        }
    }
}
