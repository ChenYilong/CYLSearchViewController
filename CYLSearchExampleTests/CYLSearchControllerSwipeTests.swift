//
//  CYLSearchControllerSwipeTests.swift
//  CYLSearchExampleTests
//
//  Rows E11 to E14 of docs/qmui-search-controller.md after the rebuild on the core search field (docs/no-system-searchbar.md):
//  the swipe from the left edge leaves the search; there is no window snapshot any more, the page itself slides. XCTest
//  cannot make a screen edge touch, so only the recognizer's presence and the option are checked here.
//

import UIKit
import XCTest
@testable import CYLSearchViewController
@testable import CYLSearchExample

final class CYLSearchControllerSwipeTests: CYLSearchExampleTestCase {

    /// No recognizer without the option, even while the search is active.
    func testNoGestureWithoutTheOption() {
        let run = makeSearchRun()
        activateSearch(run)
        XCTAssertNil(run.search.swipeGestureRecognizer)
        run.search.setActive(false, animated: false)
    }

    /// The option installs the screen-edge recognizer on activation; turning it off disables it.
    func testGestureExistsWithTheOption() {
        let run = makeSearchRun()
        run.search.supportsSwipeToDismissSearch = true
        activateSearch(run)
        let gesture = run.search.swipeGestureRecognizer
        XCTAssertNotNil(gesture)
        XCTAssertEqual(gesture?.edges, .left)
        XCTAssertEqual(gesture?.isEnabled, true)
        run.search.supportsSwipeToDismissSearch = false
        XCTAssertEqual(gesture?.isEnabled, false)
        run.search.setActive(false, animated: false)
    }
}
