//
//  CYLSearchControllerLaunchViewTests.swift
//  CYLSearchExampleTests
//
//  Rows E15 (launch view), E18 (always visible results) and E19 (dimming view) of docs/qmui-search-controller.md.
//

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
