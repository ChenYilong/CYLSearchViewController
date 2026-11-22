//
//  CYLSearchExampleSearchTests.swift
//  CYLSearchExampleTests
//
//  The search view, refresh, overlay, resources and placeholder tests of the example (translated from
//  CYLSearchExampleTests.m, docs/swift-migration.md, step 4).
//

import CYLAnimatedItem
import CYLSearchViewController
import CYLTabBarController
import CYLTableViewPlaceHolder
import CollectionViewClassifyMenu
import UIKit
import XCTest
@testable import CYLSearchExample

/**
 * The search view, pull to refresh, overlay, packaged resources and placeholder tests of the example.
 */
final class CYLSearchExampleSearchTests: CYLSearchExampleTestCase {

    func testLocalPodsConfigureSearchAndRefresh() throws {
        let source = CYLSearchExampleDataSource()
        let controller = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        controller.loadViewIfNeeded()
        XCTAssertFalse(controller.navigationItem.hidesSearchBarWhenScrolling)
        XCTAssertNotNil(controller.tableView.cyl_header)
        XCTAssertEqual(controller.searchResults.count, 40)
        controller.searchController.searchBar.text = "not a result"
        controller.reloadResults()
        XCTAssertEqual(controller.searchResults.count, 0)
        let placeholders = { controller.tableView.subviews.filter { $0.accessibilityIdentifier == "CYLSearchEmptyState" } }
        XCTAssertEqual(placeholders().count, 1)
        controller.searchController.searchBar.text = ""
        controller.reloadResults()
        XCTAssertEqual(placeholders().count, 0)

        let toggle = try XCTUnwrap(controller.navigationItem.rightBarButtonItem)
        let toggleAction = try XCTUnwrap(toggle.action)
        UIApplication.shared.sendAction(toggleAction, to: toggle.target, from: toggle, for: nil)
        XCTAssertTrue(controller.navigationItem.hidesSearchBarWhenScrolling)
        XCTAssertEqual(toggle.title, CYLSearchResources.localizedString(forKey: "repro.on"))
        XCTAssertTrue(controller.overlaySearchView.resultsDataSource === source, "the overlay searches the same data")
        UIApplication.shared.sendAction(toggleAction, to: toggle.target, from: toggle, for: nil)
        XCTAssertFalse(controller.navigationItem.hidesSearchBarWhenScrolling)
    }

    func testPackagedResourcesAndLocalization() {
        let bundle = CYLSearchResources.resourceBundle
        XCTAssertNotNil(bundle)
        XCTAssertNotNil(CYLSearchResources.image(named: "CYLSearchEmpty"))
        XCTAssertNotNil(CYLSearchResources.image(named: "CYLSearchNoResults"))
        XCTAssertNotNil(CYLSearchResources.image(named: "CYLSearchError"))
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "placeholder.search", language: "en"), "No matching results")
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "placeholder.search", language: "zh-Hans"), "没有匹配的结果")
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "placeholder.search", language: "zh-Hant"), "沒有符合的結果")
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "placeholder.search", language: "ja"), "一致する結果がありません")
        XCTAssertEqual(CYLSearchResources.localizedString(forKey: "placeholder.search", language: "xx-XX"), "No matching results")
        // The empty states themselves are CYLTableViewPlaceHolder's CYLPlaceholderView (the former CYLSearchPlaceholderView).
        let styles: [CYLPlaceholderStyle] = [.empty, .noResults, .error]
        let messages: [CYLPlaceholderMessage] = [.empty, .noResults, .error]
        for index in 0..<styles.count {
            let view = CYLPlaceholderView(style: styles[index], message: messages[index])
            XCTAssertNotNil(view.imageView.image)
            XCTAssertGreaterThan((view.textLabel.text ?? "").count, 0)
        }
    }

    func testIndependentPlaceholderStylesAndMessages() throws {
        // CYLTableViewPlaceHolder's CYLPlaceholderView: every style has its own image, every message its own text.
        let messages: [CYLPlaceholderMessage] = [.empty, .noResults, .noInternet, .error]
        var names = Set<String>()
        for rawStyle in 0..<CYLPlaceholderStyle.count.rawValue {
            let style = try XCTUnwrap(CYLPlaceholderStyle(rawValue: rawStyle))
            let name = try XCTUnwrap(CYLPlaceholderView.imageName(for: style))
            XCTAssertFalse(names.contains(name))
            names.insert(name)
            XCTAssertNotNil(CYLPlaceholderView.image(for: style), name)
            for message in messages {
                let view = CYLPlaceholderView(style: style, message: message)
                XCTAssertNotNil(view.imageView.image)
                XCTAssertEqual(view.textLabel.text, CYLPlaceholderView.localizedText(for: message))
            }
        }
        let image = UIImage(systemName: "heart.fill")
        let both = CYLPlaceholderView(image: image, text: "Custom")
        XCTAssertIdentical(both.imageView.image, image)
        XCTAssertEqual(both.textLabel.text, "Custom")
        XCTAssertEqual(CYLPlaceholderView(style: .error, text: "Custom").textLabel.text, "Custom")
    }

    func testPlaceholderMessagesAreLocalized() {
        let expected: [String: String] = [
            "en": "Check your internet connection",
            "zh-Hans": "请检查网络连接",
            "zh-Hant": "請檢查網路連線",
            "ja": "インターネット接続を確認してください",
            "xx-XX": "Check your internet connection",
        ]
        for (language, text) in expected {
            XCTAssertEqual(CYLSearchResources.localizedString(forKey: "placeholder.network", language: language), text)
        }
    }

    func testPlaceholderGalleryNavigation() throws {
        let menu = CYLSearchDemoMenuViewController(style: .grouped)
        let navigation = CYLSearchTestNavigationController(rootViewController: menu)
        menu.loadViewIfNeeded()
        XCTAssertIdentical(menu.navigationController, navigation)
        XCTAssertEqual(menu.tableView(menu.tableView, numberOfRowsInSection: 0), 13,
                       "reproduction, styles, search bar, ports of other libraries, the SVGA tab bar in SwiftUI, contact tags, the original demo, search bar styles, search controller")
        menu.tableView(menu.tableView, didSelectRowAt: IndexPath(row: 7, section: 0))
        XCTAssertTrue(navigation.lastPushedController is CYLSearchBarStylesViewController, "the QMUI search bar styles screen")
        navigation.popViewController(animated: false)
        menu.tableView(menu.tableView, didSelectRowAt: IndexPath(row: 8, section: 0))
        XCTAssertTrue(navigation.lastPushedController is CYLSearchControllerDemoViewController, "the QMUI search controller screen")
        navigation.popViewController(animated: false)
        menu.tableView(menu.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        let gallery = try XCTUnwrap(navigation.lastPushedController as? UITableViewController)
        XCTAssertNotIdentical(gallery, menu)
        gallery.loadViewIfNeeded()
        let styleCount = CYLPlaceholderStyle.count.rawValue
        XCTAssertEqual(gallery.numberOfSections(in: gallery.tableView), styleCount + 1)
        for section in 0...styleCount {
            let count = gallery.tableView(gallery.tableView, numberOfRowsInSection: section)
            XCTAssertEqual(count, section == styleCount ? 3 : 4)
            for row in 0..<count {
                let indexPath = IndexPath(row: row, section: section)
                gallery.tableView(gallery.tableView, didSelectRowAt: indexPath)
                let detail = try XCTUnwrap(navigation.lastPushedController)
                XCTAssertNotIdentical(detail, gallery)
                XCTAssertTrue(detail.view.subviews.first is CYLPlaceholderView)
                navigation.popViewController(animated: false)
            }
        }
    }

    func testSearchViewShowsResultsOfItsDataSource() throws {
        // docs/search-core-merge.md, "Results behavior": with a results data source and a query, resultsTableView lists the
        // results instead of the suggestions; reloadResults asks again; no result shows the empty-results placeholder.
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        let host = UIViewController()
        window.rootViewController = host
        window.makeKeyAndVisible()
        let source = CYLSearchNumberDataSource()
        let searchView = CYLSearchView(frame: .zero)
        searchView.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.none
        searchView.animationDuration = 0
        searchView.suggestions = ["42 apples", "Kotlin"]
        searchView.resultsDataSource = source
        searchView.delegate = source
        searchView.showSearch(in: host, animated: false)
        XCTAssertTrue(searchView.superview === host.view)
        XCTAssertTrue(searchView.searchOpen)
        XCTAssertTrue(searchView.resultsTableView.isHidden, "an empty query shows the suggestions, not the results")
        XCTAssertEqual(searchView.searchResults.count, 0)

        searchView.setQuery("4", submit: false)
        searchView.layoutIfNeeded()
        XCTAssertFalse(searchView.resultsTableView.isHidden)
        XCTAssertTrue(searchView.suggestionsTableView.isHidden, "the results replace the suggestions")
        XCTAssertEqual(searchView.searchResults as NSArray, [42, 7] as NSArray)
        XCTAssertEqual(searchView.resultsTableView.numberOfRows(inSection: 0), 2)
        XCTAssertGreaterThanOrEqual(searchView.resultsTableView.frame.minY, searchView.searchBarView.frame.maxY)
        let first = IndexPath(row: 0, section: 0)
        let cell = searchView.tableView(searchView.resultsTableView, cellForRowAt: first)
        XCTAssertEqual(cell.textLabel?.text, "42")
        searchView.tableView(searchView.resultsTableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(source.selectedResult as? Int, 7)

        let queries = source.queryCount
        searchView.reloadResults()
        XCTAssertEqual(source.queryCount, queries + 1, "reloadResults asks the data source again")

        searchView.showsEmptyResultsPlaceholder = true
        searchView.setQuery("zzz", submit: false)
        searchView.layoutIfNeeded()
        XCTAssertEqual(searchView.searchResults.count, 0)
        XCTAssertNotNil(searchView.emptyResultsView)
        XCTAssertFalse(try XCTUnwrap(searchView.emptyResultsView).isHidden, "no result shows the placeholder")
        searchView.setQuery("4", submit: false)
        XCTAssertTrue(try XCTUnwrap(searchView.emptyResultsView).isHidden)

        // Focus alone changes nothing below the search bar.
        let before: NSArray = [searchView.resultsTableView.isHidden, searchView.searchResults]
        searchView.searchBarView.textField.becomeFirstResponder()
        searchView.searchBarView.textField.resignFirstResponder()
        XCTAssertEqual([searchView.resultsTableView.isHidden, searchView.searchResults] as NSArray, before)

        // Without a data source the suggestions come back.
        searchView.resultsDataSource = nil
        searchView.setQuery("Kot", submit: false)
        XCTAssertTrue(searchView.resultsTableView.isHidden)
        XCTAssertEqual(searchView.filteredSuggestions, ["Kotlin"])

        let closed = expectation(description: "closeSearchAnimated:completion: calls back")
        searchView.closeSearch(animated: false) {
            XCTAssertFalse(searchView.searchOpen)
            closed.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
        let already = expectation(description: "An already closed search calls back at once")
        searchView.closeSearch(animated: true) { already.fulfill() }
        waitForExpectations(timeout: 2, handler: nil)
        window.isHidden = true
    }

    func testSearchViewRefreshWrapsThePullToRefresh() throws {
        // The only refresh API of the core: refreshHandler on resultsTableView, and the class methods for another table.
        let searchView = CYLSearchView(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        XCTAssertNil(searchView.resultsTableView.cyl_header, "no pull-to-refresh by default")
        XCTAssertFalse(searchView.isRefreshing)
        var calls = 0
        searchView.refreshHandler = { calls += 1 }
        XCTAssertNotNil(searchView.resultsTableView.cyl_header, "a handler installs the header")
        XCTAssertTrue(searchView.resultsTableView.cyl_header is CYLRefreshNormalHeader)
        try XCTUnwrap(searchView.resultsTableView.cyl_header?.refreshingBlock)()
        XCTAssertEqual(calls, 1, "the header calls the handler")
        searchView.beginRefreshing()
        XCTAssertTrue(searchView.isRefreshing)
        searchView.endRefreshing()
        // The header may hold its result for its finishDuration before it is idle again.
        expectation(for: NSPredicate { _, _ in
            !searchView.isRefreshing
        }, evaluatedWith: searchView, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        searchView.refreshHandler = nil
        XCTAssertNil(searchView.resultsTableView.cyl_header, "nil removes the header")

        // The class methods on a table of the app (the Issue #1317 page).
        let table = UITableView(frame: CGRect(x: 0, y: 0, width: 390, height: 600), style: .plain)
        var tableCalls = 0
        CYLSearchView.setRefreshHandler({ tableCalls += 1 }, for: table)
        XCTAssertNotNil(table.cyl_header)
        try XCTUnwrap(table.cyl_header?.refreshingBlock)()
        XCTAssertEqual(tableCalls, 1)
        CYLSearchView.beginRefreshing(in: table)
        XCTAssertTrue(CYLSearchView.isRefreshing(in: table))
        CYLSearchView.endRefreshing(in: table)
        expectation(for: NSPredicate { _, _ in
            !CYLSearchView.isRefreshing(in: table)
        }, evaluatedWith: table, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        CYLSearchView.setRefreshHandler(nil, for: table)
        XCTAssertNil(table.cyl_header)
        XCTAssertFalse(CYLSearchView.isRefreshing(in: table), "no header: not refreshing")
    }

    func testRefreshBlockDoesNotRetainController() throws {
        weak var weakController: CYLSearchExampleViewController?
        var header: CYLRefreshHeader?
        autoreleasepool {
            let source = CYLSearchExampleDataSource()
            let controller = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
            controller.loadViewIfNeeded()
            header = controller.tableView.cyl_header
            weakController = controller
        }
        XCTAssertNil(weakController)
        XCTAssertNotNil(header?.refreshingBlock)
        try XCTUnwrap(header?.refreshingBlock)()
    }

    func testRefreshReloadsSearchResults() throws {
        let source = CYLSearchNumberDataSource()
        let refresh = CYLSearchImmediateRefresh()
        let controller = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: refresh)
        controller.loadViewIfNeeded()
        XCTAssertEqual(controller.searchResults.count, 1)
        controller.searchController.searchBar.text = "empty"
        try XCTUnwrap(controller.tableView.cyl_header?.refreshingBlock)()
        let finished = expectation(description: "Refresh completion updates the search results")
        DispatchQueue.main.async {
            XCTAssertEqual(refresh.refreshCount, 1)
            XCTAssertEqual(controller.searchResults.count, 0)
            finished.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testOverlayOpensACYLSearchViewWithTheSameData() throws {
        // "Overlay" of the Issue #1317 page (was CYLSearchController): a CYLSearchView over the navigation controller.
        let source = CYLSearchExampleDataSource()
        let controller = CYLSearchExampleViewController(searchDataSource: source, refreshProvider: source)
        let navigation = UINavigationController(rootViewController: controller)
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        controller.loadViewIfNeeded()
        let overlay = controller.overlaySearchView
        let recorder = CYLParityRecorder()
        overlay.delegate = recorder
        overlay.animationDuration = 0
        let openItem = try XCTUnwrap(controller.navigationItem.leftBarButtonItem)
        let openAction = try XCTUnwrap(openItem.action)
        UIApplication.shared.sendAction(openAction, to: openItem.target, from: openItem, for: nil)
        XCTAssertTrue(overlay.searchOpen)
        XCTAssertTrue(overlay.superview === navigation.view)
        overlay.setQuery("1", submit: false)
        XCTAssertGreaterThan(overlay.searchResults.count, 0)
        XCTAssertFalse(overlay.resultsTableView.isHidden)
        overlay.searchBarView.navigationButton.sendActions(for: .touchUpInside)
        XCTAssertFalse(overlay.searchOpen, "the back arrow closes it")
        XCTAssertEqual(recorder.events.last, "closed")
        window.isHidden = true
    }
}
