//
//  CYLSearchControllerDemoTests.swift
//  CYLSearchExampleTests
//
//  The "Search controller" screen (a replica of QMUI's QDSearchViewController): the keywords, the launch view of recent
//  searches, the results with the match in the tint color, the empty view, and the strings in four languages.
//

import CollectionViewClassifyMenu
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
        XCTAssertTrue(search.launchView is CYLRecentSearchLaunchView)
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
        let launch = CYLRecentSearchLaunchView(frame: CGRect(x: 0, y: 0, width: 402, height: 700))
        launch.layoutIfNeeded()
        XCTAssertEqual(launch.titleLabel.text, CYLSearchResources.localizedString(forKey: "controller.recent"))
        XCTAssertEqual(launch.menuNumberOfItems(inSection: 0), 8)
        XCTAssertEqual(launch.menuTitleForItem(at: IndexPath(item: 0, section: 0)), "Helps")
        XCTAssertEqual(launch.titleLabel.frame.minX, 26, accuracy: 0.5, "26 pt padding")
        XCTAssertEqual(launch.tagListView.frame.minY, launch.titleLabel.frame.maxY + 8 + 20, accuracy: 0.5, "20 pt under the title")
        XCTAssertEqual(launch.tagListView.frame.maxY, launch.bounds.maxY, accuracy: 0.5)
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
