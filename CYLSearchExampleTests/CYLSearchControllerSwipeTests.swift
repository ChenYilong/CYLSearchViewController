//
//  CYLSearchControllerSwipeTests.swift
//  CYLSearchExampleTests
//
//  Rows E11 to E14 of docs/qmui-search-controller.md: swipe from the left edge to leave the search. XCTest cannot make a
//  screen edge touch, so the gesture's action is driven through the controller's begin / change / end methods that the
//  recognizer calls.
//

import UIKit
import XCTest
@testable import CYLSearchViewController
@testable import CYLSearchExample

final class CYLSearchControllerSwipeTests: CYLSearchExampleTestCase {

    private func makeSwipeRun() -> CYLSearchRun {
        let run = CYLMakeSearchRun()
        run.search.supportsSwipeToDismissSearch = true
        let launch = UIView()
        launch.backgroundColor = .systemYellow
        run.search.launchView = launch
        CYLActivateSearch(run)
        return run
    }

    // MARK: - E11

    /// E11: the gesture lives on the window and begins only for a touch inside the search view.
    func testE11GestureBeginsOnlyInsideTheSearchView() throws {
        let run = makeSwipeRun()
        let search = run.search
        let gesture = try XCTUnwrap(search.swipeGestureRecognizer)
        XCTAssertEqual(gesture.edges, .left)
        XCTAssertTrue(gesture.view === run.window)
        XCTAssertTrue(gesture.delegate === search)
        XCTAssertTrue(search.swipeMayBegin(from: search.searchBar))
        XCTAssertTrue(search.swipeMayBegin(from: search.launchView))
        XCTAssertFalse(search.swipeMayBegin(from: run.contents.view), "a touch on the contents behind does not begin")
        XCTAssertFalse(search.swipeMayBegin(from: nil))
        let toast = UIView(frame: CGRect(x: 0, y: 400, width: 100, height: 40))
        run.window.addSubview(toast)
        XCTAssertFalse(search.swipeMayBegin(from: toast), "a toast on the window does not begin")
        XCTAssertTrue(search.gestureRecognizerShouldBegin(UITapGestureRecognizer()), "other recognizers are not judged")
        toast.removeFromSuperview()
        CYLTearDownSearchRun(run)
    }

    /// Without supportsSwipeToDismissSearch there is no gesture.
    func testNoGestureWithoutTheOption() {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run)
        XCTAssertNil(run.search.swipeGestureRecognizer)
        XCTAssertNil(run.search.snapshotView)
        CYLTearDownSearchRun(run)
    }

    // MARK: - E12

    /// E12: the snapshot sits behind, the search view and the mask follow the finger, a swipe past a quarter of the width
    /// with a rightward velocity leaves the search, and the window takes touches again.
    func testE12SwipeCompletesAndRestoresInteraction() throws {
        let run = makeSwipeRun()
        let search = run.search
        let system = search.searchController
        let snapshot = try XCTUnwrap(search.snapshotView)
        search.swipeBegan()
        XCTAssertTrue(snapshot.superview === system.view.superview, "the snapshot is behind the search view")
        search.swipeChanged(translationX: 201)
        XCTAssertEqual(system.view.transform.tx, 201, accuracy: 0.5)
        XCTAssertEqual(search.snapshotMaskView?.alpha ?? -1, 0.5, accuracy: 0.01)
        XCTAssertEqual(snapshot.transform.tx, -56, accuracy: 0.5)
        search.swipeEnded(velocityX: 800)
        XCTAssertFalse(run.window.isUserInteractionEnabled, "no touches during the animation")
        CYLRunLoop(0.7)
        XCTAssertFalse(search.isActive, "the swipe left the search")
        XCTAssertTrue(run.window.isUserInteractionEnabled, "touches again")
        XCTAssertEqual(system.view.transform, .identity)
        CYLTearDownSearchRun(run)
    }

    /// E12: a short swipe, or one that returns, springs back and the search stays.
    func testE12SwipeCancelsAndRestoresInteraction() {
        let run = makeSwipeRun()
        let search = run.search
        let system = search.searchController
        for (shift, velocity) in [(60.0, 800.0), (250.0, -300.0)] {
            search.swipeBegan()
            search.swipeChanged(translationX: shift)
            search.swipeEnded(velocityX: velocity)
            XCTAssertFalse(run.window.isUserInteractionEnabled)
            CYLRunLoop(0.5)
            XCTAssertTrue(search.isActive, "shift \(shift): the search stays")
            XCTAssertTrue(run.window.isUserInteractionEnabled, "shift \(shift): touches again")
            XCTAssertEqual(system.view.transform.tx, 0, accuracy: 0.5, "shift \(shift): sprung back")
        }
        CYLTearDownSearchRun(run)
    }

    // MARK: - E13

    /// E13: after the swipe the snapshot is moved on top of the window to hide the flicker, then removed with the gesture.
    func testE13SnapshotCoversTheWindowThenIsRemoved() throws {
        let run = makeSwipeRun()
        let search = run.search
        let snapshot = try XCTUnwrap(search.snapshotView)
        let gesture = try XCTUnwrap(search.swipeGestureRecognizer)
        XCTAssertTrue(run.window.gestureRecognizers?.contains(gesture) == true)
        search.swipeBegan()
        search.swipeChanged(translationX: 300)
        search.swipeEnded(velocityX: 900)
        var onTop = false
        let start = Date()
        while Date().timeIntervalSince(start) < 0.8 {
            CYLRunLoop(0.02)
            if snapshot.superview === run.window { onTop = true }
        }
        XCTAssertTrue(onTop, "the snapshot was on top of the window while the search left")
        XCTAssertNil(snapshot.superview, "the snapshot is removed afterwards")
        XCTAssertNil(search.snapshotView)
        XCTAssertFalse(run.window.gestureRecognizers?.contains(gesture) == true, "the gesture is removed")
        XCTAssertTrue(run.window.isUserInteractionEnabled)
        CYLTearDownSearchRun(run)
    }

    // MARK: - E14

    /// E14: a swipe is begun and abandoned, then the text is cleared with the x of the bar: the snapshot goes.
    func testE14ClearingTextAfterACancelledSwipeRemovesTheSnapshot() throws {
        let run = CYLMakeSearchRun()
        run.search.supportsSwipeToDismissSearch = true
        CYLActivateSearch(run, text: "H")
        let search = run.search
        let snapshot = try XCTUnwrap(search.snapshotView)
        search.swipeBegan()
        XCTAssertNotNil(snapshot.superview)
        search.swipeChanged(translationX: 40)
        search.swipeEnded(velocityX: 0)
        CYLRunLoop(0.4)
        XCTAssertNotNil(snapshot.superview, "a cancelled swipe leaves the snapshot behind the search view")
        run.search.searchBar.text = ""
        CYLRunLoop(0.4)
        XCTAssertNil(snapshot.superview, "clearing the text removes it")
        CYLTearDownSearchRun(run)
    }

    /// E14: a swipe is begun and abandoned, then Cancel leaves the search: no snapshot stays in the window.
    func testE14CancelAfterACancelledSwipeLeavesNoSnapshot() throws {
        let run = makeSwipeRun()
        let search = run.search
        let snapshot = try XCTUnwrap(search.snapshotView)
        let gesture = try XCTUnwrap(search.swipeGestureRecognizer)
        search.swipeBegan()
        search.swipeChanged(translationX: 40)
        search.swipeEnded(velocityX: 0)
        CYLRunLoop(0.4)
        XCTAssertNotNil(snapshot.superview)
        search.setActive(false, animated: true)
        CYLRunLoop(0.9)
        XCTAssertFalse(search.isActive)
        XCTAssertNil(snapshot.superview, "no snapshot behind or over the window")
        XCTAssertNil(CYLViewWithAccessibilityIdentifier(run.window, "CYLSearchSwipeSnapshot"))
        XCTAssertFalse(run.window.gestureRecognizers?.contains(gesture) == true)
        CYLTearDownSearchRun(run)
    }

    // MARK: - Real touch (docs/qmui-search-controller.md, "Merge phase 4 log")

    /// UIKit's own edge recognizer never began while a UISearchController was active; the gesture follows the touch itself.
    func testGestureFollowsTheTouchItself() throws {
        let run = makeSwipeRun()
        let gesture = try XCTUnwrap(run.search.swipeGestureRecognizer)
        XCTAssertTrue(gesture is CYLSearchEdgePanGestureRecognizer)
        XCTAssertEqual(gesture.edges, .left)
        XCTAssertEqual(gesture.maximumNumberOfTouches, 1)
        let origin = CGPoint(x: 2, y: 450)
        typealias Rule = CYLSearchEdgePanGestureRecognizer
        XCTAssertEqual(Rule.verdict(from: origin, to: CGPoint(x: 8, y: 450)), .undecided, "inside the slop")
        XCTAssertEqual(Rule.verdict(from: origin, to: CGPoint(x: 40, y: 452)), .begins, "right, mostly horizontal")
        XCTAssertEqual(Rule.verdict(from: origin, to: CGPoint(x: 8, y: 456)), .undecided, "right and down, inside the slop")
        XCTAssertEqual(Rule.verdict(from: origin, to: CGPoint(x: 8, y: 500)), .fails, "down")
        XCTAssertEqual(Rule.verdict(from: origin, to: CGPoint(x: 40, y: 150)), .fails, "up")
        XCTAssertEqual(Rule.verdict(from: CGPoint(x: 20, y: 450), to: CGPoint(x: 2, y: 450)), .fails, "left")
        XCTAssertEqual(Rule.verdict(from: origin, to: CGPoint(x: 60, y: 140)), .fails, "more vertical than horizontal")
        XCTAssertEqual(gesture.translation(in: nil), .zero, "no touch yet")
        CYLTearDownSearchRun(run)
    }

    /// The navigation controller's swipe back waits for this swipe to fail, so the swipe leaves the search first.
    func testNavigationSwipeBackWaitsForTheSearchSwipe() throws {
        let run = makeSwipeRun()
        let search = run.search
        let gesture = try XCTUnwrap(search.swipeGestureRecognizer)
        let pop = try XCTUnwrap(run.navigation.interactivePopGestureRecognizer)
        XCTAssertTrue(search.gestureRecognizer(gesture, shouldBeRequiredToFailBy: pop))
        XCTAssertFalse(search.gestureRecognizer(gesture, shouldBeRequiredToFailBy: UITapGestureRecognizer()))
        if #available(iOS 26.0, *), let content = run.navigation.interactiveContentPopGestureRecognizer {
            XCTAssertTrue(search.gestureRecognizer(gesture, shouldBeRequiredToFailBy: content))
        }
        XCTAssertFalse(search.gestureRecognizer(UITapGestureRecognizer(), shouldBeRequiredToFailBy: pop),
                       "only the search swipe is judged")
        CYLTearDownSearchRun(run)
    }
}
