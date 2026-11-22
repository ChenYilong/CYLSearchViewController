//
//  CYLSearchControllerDemoTests.swift
//  CYLSearchExampleTests
//
//  The "Search controller" screen (a replica of QMUI's QDSearchViewController): the keywords, the core's launch view of
//  recent searches (configured through API only), the results with the match in the tint color, the empty view, and the
//  strings in four languages.
//

import UIKit
import XCTest
@testable import CYLSearchViewController
@testable import CYLSearchExample

final class CYLSearchControllerDemoTests: CYLSearchExampleTestCase {

    private func shown() -> (UIWindow, CYLSearchControllerDemoViewController, CYLSearchController) {
        let screen = CYLSearchControllerDemoViewController(style: .plain)
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = UINavigationController(rootViewController: screen)
        window.makeKeyAndVisible()
        CYLRunLoop(0.3)
        guard let search = screen.cylSearchController else { fatalError("the screen creates its search controller") }
        return (window, screen, search)
    }

    func testScreenIsSetUpLikeQMUI() {
        let (window, screen, search) = shown()
        XCTAssertEqual(screen.tableView(screen.tableView, numberOfRowsInSection: 0), 10, "the ten keywords")
        XCTAssertTrue(screen.tableView.tableHeaderView === search.searchBar, "the bar is the table header")
        XCTAssertTrue(search.searchBar.usedAsTableHeaderView)
        XCTAssertTrue(search.supportsSwipeToDismissSearch)
        XCTAssertTrue(search.showsSuggestionsLaunchView, "the core's launch view, no view of the example")
        XCTAssertTrue(search.launchView is CYLSearchSuggestionsLaunchView)
        XCTAssertEqual(search.suggestions, ["Helps", "Maintain", "Liver", "Health", "Function", "Supports", "Healthy", "Fat"], "QMUI's eight")
        XCTAssertNotNil(search.historyStore)
        XCTAssertTrue(search.searchResultsDelegate === screen)
        window.isHidden = true
    }

    func testResultsAreTwentyRowsPerMatchWithTheMatchInTheTintColor() throws {
        let (window, screen, search) = shown()
        search.setActive(true, animated: false)
        CYLRunLoop(0.5)
        search.searchBar.text = "Heal"
        CYLRunLoop(0.4)
        let table = try XCTUnwrap(search.tableView)
        XCTAssertEqual(table.numberOfRows(inSection: 0), 2 * 20, "Health and Healthy, twenty rows each")
        let cell = screen.tableView(table, cellForRowAt: IndexPath(row: 0, section: 0))
        let text = try XCTUnwrap(cell.textLabel?.attributedText)
        XCTAssertEqual(text.string, "Health")
        let tint = try XCTUnwrap(screen.view.tintColor)
        XCTAssertEqual(text.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor, tint, "the match is tinted")
        XCTAssertEqual(text.attribute(.foregroundColor, at: 5, effectiveRange: nil) as? UIColor, UIColor.label, "the rest is not")
        XCTAssertFalse(search.isEmptyViewShowing)
        search.searchBar.text = "zzz"
        CYLRunLoop(0.4)
        XCTAssertEqual(table.numberOfRows(inSection: 0), 0)
        XCTAssertTrue(search.isEmptyViewShowing, "No matching results")
        search.setActive(false, animated: false)
        window.isHidden = true
    }

    func testLaunchViewHoldsTheRecentSearchesAsTags() throws {
        CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemoTests-\(UUID().uuidString)"
        defer { CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemo" }
        let (window, _, search) = shown()
        search.setActive(true, animated: false)
        CYLRunLoop(0.5)
        let launch = try XCTUnwrap(search.launchView as? CYLSearchSuggestionsLaunchView)
        XCTAssertEqual(launch.area.titles, CYLSearchControllerDemoViewController.suggestions, "no history: the eight suggestions")
        XCTAssertEqual(launch.area.titleLabel.text, CYLSearchResources.localizedString(forKey: "search.recent"), "Recent searches")
        XCTAssertTrue(launch.area.headerView.isHidden, "no history: no header and no trash button")
        XCTAssertFalse(CYLOrderedTagCells(of: launch.area.tagView).isEmpty, "tags on screen")
        XCTAssertGreaterThanOrEqual(launch.area.tagView.frame.minY, 0)
        XCTAssertEqual(launch.frame.maxY, try XCTUnwrap(launch.superview).bounds.maxY, accuracy: 0.5, "it fills the space under the bar")
        search.setActive(false, animated: false)
        window.isHidden = true
    }

    /// The history of the Search controller screen is CYLSearchResources' store: the return key adds the query, newest
    /// first, no duplicates; the launch view lists it and its trash button clears it.
    func testSubmittedSearchesFormTheHistoryOfTheLaunchView() throws {
        CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemoTests-\(UUID().uuidString)"
        let (window, _, search) = shown()
        let store = try XCTUnwrap(search.historyStore)
        defer { store.removeAllQueries() }
        let launch = try XCTUnwrap(search.launchView as? CYLSearchSuggestionsLaunchView)
        let area = launch.area
        XCTAssertEqual(store.cachedQueries(), [])
        search.setActive(true, animated: false)
        CYLRunLoop(0.5)
        XCTAssertTrue(area.headerView.isHidden, "no history yet: the eight suggestions and no trash button")
        XCTAssertEqual(area.titles.count, 8)
        for text in ["Fat", "Liver", " ", "Fat"] {
            search.searchBar.text = text
            search.searchBar.searchTextField.sendActions(for: .primaryActionTriggered)
        }
        XCTAssertEqual(store.cachedQueries(), ["Fat", "Liver"], "newest first, no duplicates, no blank query")
        XCTAssertNotNil(launch.window, "the launch view stayed on screen")
        XCTAssertEqual(area.titles, ["Fat", "Liver"], "read again without leaving the screen")
        XCTAssertFalse(area.headerView.isHidden)
        area.clearButton.sendActions(for: .touchUpInside)
        XCTAssertEqual(store.cachedQueries(), [])
        XCTAssertEqual(area.titles.count, 8, "the suggestions are back")
        XCTAssertTrue(area.headerView.isHidden)
        search.setActive(false, animated: false)
        window.isHidden = true
        CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemo"
    }

    /// A tapped tag is the query and is submitted (the old demo view did nothing on a tap): the results update, the
    /// history gets it, the launch view on screen lists it first, and the controller announces it.
    func testTappedTagSetsTheQueryAndSubmitsIt() throws {
        CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemoTests-\(UUID().uuidString)"
        defer { CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemo" }
        let (window, _, search) = shown()
        let store = try XCTUnwrap(search.historyStore)
        defer { store.removeAllQueries() }
        let launch = try XCTUnwrap(search.launchView as? CYLSearchSuggestionsLaunchView)
        search.setActive(true, animated: false)
        CYLRunLoop(0.5)
        var posted: [String] = []
        let token = NotificationCenter.default.addObserver(forName: CYLSearchController.historyDidChangeNotification,
                                                           object: search, queue: nil) { posted.append($0.userInfo?["query"] as? String ?? "?") }
        defer { NotificationCenter.default.removeObserver(token) }
        CYLTapTag(at: 3, in: launch.area.tagView)
        XCTAssertEqual(search.searchBar.text, "Health", "the tapped tag is the query")
        XCTAssertEqual(store.cachedQueries(), ["Health"], "and it is submitted")
        XCTAssertEqual(posted, ["Health"])
        XCTAssertEqual(try XCTUnwrap(search.tableView).numberOfRows(inSection: 0), 2 * 20, "Health and Healthy: the results follow the query")
        XCTAssertNotNil(launch.window)
        XCTAssertEqual(launch.area.titles, ["Health"], "the launch view on screen shows the history now")
        XCTAssertFalse(launch.area.headerView.isHidden)
        search.setActive(false, animated: false)
        window.isHidden = true
    }

    /// The core announces each submitted query once it is in the history store (object: the controller), and stays
    /// silent for a blank query or without a store.
    func testSubmittedQueryPostsHistoryDidChange() throws {
        CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemoTests-\(UUID().uuidString)"
        defer { CYLSearchControllerDemoViewController.historyName = "CYLSearchControllerDemo" }
        let (window, _, search) = shown()
        let store = try XCTUnwrap(search.historyStore)
        defer { store.removeAllQueries() }
        search.setActive(true, animated: false)
        CYLRunLoop(0.3)
        var posted: [String] = []
        let token = NotificationCenter.default.addObserver(forName: CYLSearchController.historyDidChangeNotification,
                                                           object: search, queue: nil) { note in
            posted.append(note.userInfo?["query"] as? String ?? "?")
        }
        defer { NotificationCenter.default.removeObserver(token) }
        for text in [" Health ", "  "] {
            search.searchBar.text = text
            search.searchBar.searchTextField.sendActions(for: .primaryActionTriggered)
        }
        XCTAssertEqual(posted, ["Health"], "trimmed, and nothing for a blank query")
        search.historyStore = nil
        search.searchBar.text = "Fat"
        search.searchBar.searchTextField.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual(posted, ["Health"], "no store, no notification")
        search.historyStore = store
        search.setActive(false, animated: false)
        window.isHidden = true
    }

    func testStringsExistInFourLanguages() {
        let expected = [
            "en": ["Search controller", "Recent searches", "No matching results"],
            "zh-Hans": ["搜索控制器", "最近搜索", "没有匹配结果"],
            "zh-Hant": ["搜尋控制器", "最近搜尋", "沒有符合的結果"],
            "ja": ["検索コントローラ", "最近の検索", "一致する結果はありません"],
        ]
        for (language, texts) in expected {
            let keys = ["demo.searchController", "controller.recent", "controller.noResults"]
            for (key, text) in zip(keys, texts) {
                XCTAssertEqual(CYLSearchResources.localizedString(forKey: key, language: language), text, "\(language) \(key)")
            }
        }
    }
}
