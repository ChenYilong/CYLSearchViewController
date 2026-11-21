//
//  CYLSearchControllerLifecycleTests.swift
//  CYLSearchExampleTests
//
//  The rows of docs/qmui-search-controller.md that concern the life cycle of CYLSearchController: the presentation
//  context (E1), the leaks of #1541 (E2, E3), obscuring (E4), the system view (E5), Cancel (E6), the results table (E7),
//  the empty view (E8, E9), the text (E10), the bar's bottom edge (E16, E17), forwarded appearance (E20), #680 (E21),
//  the status bar (E22), and B7 to B9 again with CYLSearchController.
//

import ObjectiveC
import UIKit
import XCTest
@testable import CYLSearchViewController
@testable import CYLSearchExample

final class CYLSearchControllerLifecycleTests: CYLSearchExampleTestCase {

    // MARK: - API

    /// A member of the new classes must never take the selector of a private method of its superclass (a Swift @objc member
    /// with the same selector would silently override it): every own method is checked against the superclass chain.
    func testNoSelectorOverridesAPrivateSuperclassMethod() {
        func collisions(of subclass: AnyClass, against superclass: AnyClass, intended: Set<String>) -> [String] {
            var count: UInt32 = 0
            let methods = class_copyMethodList(subclass, &count)
            defer { free(methods) }
            var found: [String] = []
            for index in 0..<Int(count) {
                guard let method = methods?[index] else { continue }
                let selector = method_getName(method)
                let name = NSStringFromSelector(selector)
                if intended.contains(name) || name.hasPrefix(".") || name.hasPrefix("init") || name == "dealloc" { continue }
                if superclass.instancesRespond(to: selector) { found.append(name) }
            }
            return found
        }
        XCTAssertEqual(collisions(of: CYLSearchController.self, against: UIViewController.self,
                                  intended: ["viewDidLoad", "initWithCoder:", "initWithNibName:bundle:"]), [])
        XCTAssertEqual(collisions(of: CYLSystemSearchController.self, against: UISearchController.self,
                                  intended: ["searchBar", "showsSearchResultsController", "setShowsSearchResultsController:",
                                             "viewWillAppear:", "viewDidLayoutSubviews", "prefersStatusBarHidden",
                                             "preferredStatusBarStyle"]), [])
        XCTAssertEqual(collisions(of: CYLSearchResultsTableViewController.self, against: UITableViewController.self,
                                  intended: ["viewDidLoad", "viewDidLayoutSubviews"]), [])
        XCTAssertEqual(collisions(of: CYLSearchPresentationGuard.self, against: UIViewController.self,
                                  intended: ["loadView", "viewWillAppear:", "viewDidAppear:", "viewWillDisappear:",
                                             "viewDidDisappear:"]), [])
        // The Objective-C names of QMUI: isActive / setActive:, not setIsActive:.
        XCTAssertTrue(CYLSearchController.instancesRespond(to: NSSelectorFromString("isActive")))
        XCTAssertTrue(CYLSearchController.instancesRespond(to: NSSelectorFromString("setActive:")))
        XCTAssertFalse(CYLSearchController.instancesRespond(to: NSSelectorFromString("setIsActive:")))
        XCTAssertTrue(CYLSearchController.instancesRespond(to: NSSelectorFromString("setActive:animated:")))
    }

    /// The wrapper's search bar is a CYLSearchBar, the one of the system controller, wired to it.
    func testSearchBarIsACYLSearchBarOfTheSystemController() {
        let contents = UIViewController()
        let search = CYLSearchController(contentsViewController: contents)
        XCTAssertTrue(search.searchBar === search.searchController.searchBar)
        XCTAssertTrue(search.searchController.searchBar is CYLSearchBar)
        XCTAssertTrue(search.searchBar.searchController === search.searchController)
        XCTAssertTrue(search.searchController.searchResultsController is UITableViewController)
        XCTAssertNotNil(search.tableView)
        XCTAssertTrue(search.hidesNavigationBarDuringPresentation)
        XCTAssertFalse(search.isActive)
    }

    // MARK: - E1

    /// E1: the contents view controller defines the presentation context, the results table starts under the bar, and
    /// after a push from the results the bar does not stay on the navigation bar.
    func testE1PresentationContextAndResultsInsetFitTheBar() throws {
        let run = CYLMakeSearchRun { $0.pushesOnSelect = true }
        XCTAssertTrue(run.contents.definesPresentationContext)
        CYLActivateSearch(run, text: "H")
        let search = run.search
        let table = try XCTUnwrap(search.tableView)
        let barMaxY = search.searchBarMaxY
        XCTAssertGreaterThan(barMaxY, 0)
        XCTAssertGreaterThanOrEqual(table.contentInset.top, barMaxY - 0.5, "the results' top inset fits the bar")
        let first = try XCTUnwrap(table.cellForRow(at: IndexPath(row: 0, section: 0)))
        let barBottom = search.searchBar.convert(search.searchBar.bounds, to: run.window).maxY
        XCTAssertGreaterThanOrEqual(first.convert(first.bounds, to: run.window).minY, barBottom - 0.5, "no row under the bar")

        let pushed = CYLSearchPushedController()
        run.navigation.pushViewController(pushed, animated: false)
        CYLRunLoop(0.8)
        XCTAssertFalse(search.searchBar.isDescendant(of: pushed.view), "the bar is not in the pushed screen")
        XCTAssertFalse(search.searchBar.isDescendant(of: run.navigation.navigationBar), "the bar did not stay on the navigation bar")
        CYLTearDownSearchRun(run)
    }

    // MARK: - E2, E3 (#1541)

    /// E2: popped by popToRootViewController while searching: contents, wrapper and system controller are released.
    func testE2PopToRootWhileSearchingReleasesContents() {
        weak var weakContents: UIViewController?
        weak var weakSearch: CYLSearchController?
        weak var weakSystem: UISearchController?
        autoreleasepool {
            let contents = CYLSearchTestContents(style: .plain)
            let nav = UINavigationController(rootViewController: UIViewController())
            let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
            window.rootViewController = nav
            window.makeKeyAndVisible()
            nav.pushViewController(contents, animated: false)
            CYLRunLoop(0.3)
            contents.search?.setActive(true, animated: false)
            CYLRunLoop(0.6)
            XCTAssertEqual(contents.search?.isActive, true)
            weakContents = contents
            weakSearch = contents.search
            weakSystem = contents.search?.searchController
            nav.popToRootViewController(animated: false)
            CYLRunLoop(0.6)
            window.rootViewController = nil
            window.isHidden = true
        }
        CYLRunLoop(0.6)
        XCTAssertNil(weakContents, "contents leaked")
        XCTAssertNil(weakSearch, "wrapper leaked")
        XCTAssertNil(weakSystem, "system search controller leaked")
    }

    /// E3: window.rootViewController replaced while searching: everything is released.
    func testE3ReplacingRootWhileSearchingReleasesContents() {
        weak var weakContents: UIViewController?
        weak var weakSearch: CYLSearchController?
        autoreleasepool {
            let contents = CYLSearchTestContents(style: .plain)
            let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
            window.rootViewController = UINavigationController(rootViewController: contents)
            window.makeKeyAndVisible()
            CYLRunLoop(0.3)
            contents.search?.setActive(true, animated: false)
            CYLRunLoop(0.6)
            XCTAssertEqual(contents.search?.isActive, true)
            weakContents = contents
            weakSearch = contents.search
            window.rootViewController = UIViewController()
            CYLRunLoop(0.6)
            window.rootViewController = nil
            window.isHidden = true
        }
        CYLRunLoop(0.6)
        XCTAssertNil(weakContents, "contents leaked")
        XCTAssertNil(weakSearch, "wrapper leaked")
    }

    /// The guard must not fire while the contents are only covered: a push from the results keeps the presentation.
    func testGuardDoesNotDismissWhileTheContentsAreCovered() {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run, text: "H")
        run.navigation.pushViewController(CYLSearchPushedController(), animated: false)
        CYLRunLoop(0.8)
        XCTAssertTrue(run.search.isActive, "the search stays presented under the pushed screen")
        run.navigation.popViewController(animated: false)
        CYLRunLoop(0.8)
        XCTAssertTrue(run.search.isActive)
        CYLTearDownSearchRun(run)
    }

    /// A full-screen modal over the root takes the root's view out of the window: the contents are covered, not gone, so the
    /// guard must keep the presentation (the search is still there when the modal closes).
    func testGuardKeepsTheSearchUnderAFullScreenModal() {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run, text: "H")
        let modal = CYLSearchPushedController()
        modal.modalPresentationStyle = .fullScreen
        run.navigation.present(modal, animated: false)
        CYLRunLoop(0.8)
        XCTAssertTrue(run.search.isActive, "the search stays presented under the modal")
        run.navigation.dismiss(animated: false)
        CYLRunLoop(0.8)
        XCTAssertTrue(run.search.isActive, "and when the modal closes")
        XCTAssertEqual(run.contents.updates.last, "H")
        CYLTearDownSearchRun(run)
    }

    // MARK: - E4, E5

    /// E4: obscuring is on by default (iOS 15 made it off), and off while a launch view, a dimming color or the always
    /// visible results take its place; it comes back when they go.
    func testE4ObscuringDefaultAndSwitches() {
        let search = CYLSearchController(contentsViewController: UIViewController())
        let system = search.searchController
        XCTAssertTrue(system.obscuresBackgroundDuringPresentation)
        search.launchView = UIView()
        XCTAssertFalse(system.obscuresBackgroundDuringPresentation)
        search.launchView = nil
        XCTAssertTrue(system.obscuresBackgroundDuringPresentation)
        search.alwaysShowsSearchResultsController = true
        XCTAssertFalse(system.obscuresBackgroundDuringPresentation)
        search.alwaysShowsSearchResultsController = false
        XCTAssertTrue(system.obscuresBackgroundDuringPresentation)
        search.dimmingColor = .red
        XCTAssertFalse(system.obscuresBackgroundDuringPresentation)
        search.dimmingColor = nil
        XCTAssertTrue(system.obscuresBackgroundDuringPresentation)
    }

    /// E5: the wrapper loads the system controller's view with its own, a wrapper that is never shown is released, and an
    /// unloaded system controller is released without a crash.
    func testE5SystemViewIsLoadedWithTheWrapper() {
        weak var weakShown: CYLSearchController?
        weak var weakNeverShown: CYLSearchController?
        weak var weakSystem: UISearchController?
        autoreleasepool {
            let shown = CYLSearchController(contentsViewController: UIViewController())
            XCTAssertFalse(shown.searchController.isViewLoaded, "init does not load the system view")
            shown.loadViewIfNeeded()
            XCTAssertTrue(shown.searchController.isViewLoaded, "the wrapper's viewDidLoad loads the system view")
            weakShown = shown
            let neverShown = CYLSearchController(contentsViewController: UIViewController())
            weakNeverShown = neverShown
            weakSystem = neverShown.searchController
        }
        CYLRunLoop(0.3)
        XCTAssertNil(weakShown)
        XCTAssertNil(weakNeverShown)
        XCTAssertNil(weakSystem)
    }

    // MARK: - E6

    /// E6: leaving without animation hides Cancel (UIKit leaves it), and the next activation shows it again like the first.
    func testE6DeactivateWithoutAnimationHidesCancel() {
        let run = CYLMakeSearchRun()
        let bar = run.search.searchBar
        CYLActivateSearch(run)
        let shownFirst = bar.showsCancelButton
        run.search.setActive(false, animated: false)
        CYLRunLoop(0.5)
        XCTAssertFalse(bar.showsCancelButton, "Cancel is hidden after setActive(false, animated: false)")
        XCTAssertFalse(run.search.isActive)
        CYLActivateSearch(run)
        XCTAssertEqual(bar.showsCancelButton, shownFirst, "the next activation shows Cancel as the first did")
        XCTAssertTrue(run.search.searchController.automaticallyShowsCancelButton, "UIKit manages Cancel again")
        run.search.setActive(false, animated: true)
        CYLRunLoop(0.8)
        XCTAssertFalse(run.search.isActive)
        CYLTearDownSearchRun(run)
    }

    // MARK: - E7

    /// E7: the results table keeps no automatic inset and dismisses the keyboard on drag; its inset does not change over a
    /// push from the results and back.
    func testE7ResultsTableKeepsItsInsetAcrossPushAndBack() throws {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run, text: "H")
        let table = try XCTUnwrap(run.search.tableView)
        XCTAssertEqual(table.contentInsetAdjustmentBehavior, .never)
        XCTAssertEqual(table.keyboardDismissMode, .onDrag)
        let before = table.contentInset
        run.navigation.pushViewController(CYLSearchPushedController(), animated: false)
        CYLRunLoop(0.6)
        run.navigation.popViewController(animated: false)
        CYLRunLoop(0.8)
        XCTAssertEqual(table.contentInset.top, before.top, accuracy: 0.5)
        XCTAssertEqual(table.contentInset.bottom, before.bottom, accuracy: 0.5)
        CYLTearDownSearchRun(run)
    }

    // MARK: - E8, E9, E10

    /// E8: no empty view while the text is empty (the dimming view or the launch view is there); with text it shows.
    func testE8EmptyViewIsNotShownForEmptyText() {
        let run = CYLMakeSearchRun { $0.showsEmptyViewWithoutMatch = false }
        CYLActivateSearch(run)
        run.search.showEmptyView(text: "Nothing", detailText: nil, buttonTitle: nil, buttonAction: nil)
        XCTAssertFalse(run.search.isEmptyViewShowing)
        run.search.showEmptyView(scenario: .noSearchResults)
        XCTAssertFalse(run.search.isEmptyViewShowing)
        XCTAssertFalse(run.contents.events.contains("willShowEmptyView"))
        run.search.searchBar.text = "zzz"
        CYLRunLoop(0.4)
        run.search.showEmptyView(text: "Nothing", detailText: "Try again", buttonTitle: "Retry", buttonAction: {})
        XCTAssertTrue(run.search.isEmptyViewShowing)
        XCTAssertTrue(run.contents.events.contains("willShowEmptyView"))
        run.search.hideEmptyView()
        XCTAssertFalse(run.search.isEmptyViewShowing)
        run.search.showEmptyView(scenario: .noSearchResults)
        XCTAssertTrue(run.search.isEmptyViewShowing)
        CYLTearDownSearchRun(run)
    }

    /// E9: the empty view fills the results under the bar, is laid out again when the results are, and is gone after the
    /// search is left.
    func testE9EmptyViewIsLaidOutAgainAndHiddenOnDismiss() throws {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run, text: "zzz")
        XCTAssertTrue(run.search.isEmptyViewShowing, "no match shows the empty view")
        let results = try XCTUnwrap(run.search.searchResultsController)
        let empty = try XCTUnwrap(run.search.emptyView)
        XCTAssertTrue(empty.superview === results.view)
        func check(_ message: String) {
            let bounds = results.view.bounds
            XCTAssertEqual(empty.frame.width, bounds.width, accuracy: 0.5, message)
            XCTAssertEqual(empty.frame.maxY, bounds.maxY, accuracy: 0.5, message)
            let barBottom = run.search.searchBar.convert(run.search.searchBar.bounds, to: results.view).maxY
            XCTAssertGreaterThanOrEqual(empty.frame.minY, barBottom - 0.5, "\(message): under the bar")
        }
        check("after presentation")
        run.window.frame = CGRect(x: 0, y: 0, width: 330, height: 600)
        CYLRunLoop(0.6)
        check("after a resize")
        run.search.setActive(false, animated: true)
        CYLRunLoop(0.9)
        XCTAssertFalse(run.search.isEmptyViewShowing, "hidden on dismiss")
        XCTAssertNil(empty.superview)
        CYLTearDownSearchRun(run)
    }

    /// E10: the delegate also receives "" (the first activation, all text deleted).
    func testE10UpdateResultsAlsoReceivesEmptyText() {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run)
        XCTAssertEqual(run.contents.updates.first, "", "the first activation sends \"\"")
        run.search.searchBar.text = "H"
        CYLRunLoop(0.3)
        XCTAssertEqual(run.contents.updates.last, "H")
        run.search.searchBar.text = ""
        CYLRunLoop(0.3)
        XCTAssertEqual(run.contents.updates.last, "", "deleting all text sends \"\"")
        CYLTearDownSearchRun(run)
    }

    // MARK: - E16, E17

    /// E16: searchBarMaxY is the bar's bottom edge in the search view (0 while the bar is not there).
    func testE16SearchBarMaxYIsTheBarsBottomInTheSearchView() {
        let run = CYLMakeSearchRun()
        XCTAssertEqual(run.search.searchBarMaxY, 0, "the bar is in the table header")
        CYLActivateSearch(run)
        let system = run.search.searchController
        XCTAssertTrue(run.search.searchBar.isDescendant(of: system.view))
        let expected = run.search.searchBar.convert(run.search.searchBar.bounds, to: system.view).maxY
        XCTAssertGreaterThan(expected, 0)
        XCTAssertEqual(run.search.searchBarMaxY, expected, accuracy: 0.01)
        CYLTearDownSearchRun(run)
    }

    /// E17: activating without animation lays the results out with the right searchBarMaxY.
    func testE17ActivateWithoutAnimationLaysTheResultsOut() throws {
        let run = CYLMakeSearchRun()
        run.search.setActive(true, animated: false)
        CYLRunLoop(0.6)
        let results = try XCTUnwrap(run.search.searchResultsController as? CYLSearchResultsTableViewController)
        XCTAssertGreaterThan(run.search.searchBarMaxY, 0)
        XCTAssertEqual(results.lastLayoutSearchBarMaxY, run.search.searchBarMaxY, accuracy: 0.5)
        CYLTearDownSearchRun(run)
    }

    // MARK: - E20

    /// E20: with forwardsAppearanceFromContentsViewController the results controller hears viewWillDisappear when the
    /// contents push a screen and viewWillAppear / viewDidAppear when it returns. Without the option the calls are recorded
    /// as well (what UIKit does by itself on this system).
    func testE20ForwardedAppearanceReachesTheResultsController() {
        var recorded: [Bool: [String]] = [:]
        for forwards in [true, false] {
            let recorder = CYLAppearanceRecordingResults(style: .plain)
            let run = CYLMakeSearchRun(resultsController: recorder)
            run.search.forwardsAppearanceFromContentsViewController = forwards
            CYLActivateSearch(run, text: "H")
            recorder.calls.removeAll()
            run.navigation.pushViewController(CYLSearchPushedController(), animated: false)
            CYLRunLoop(0.6)
            let afterPush = recorder.calls
            recorder.calls.removeAll()
            run.navigation.popViewController(animated: false)
            CYLRunLoop(0.8)
            recorded[forwards] = afterPush + ["|"] + recorder.calls
            if forwards {
                XCTAssertTrue(afterPush.contains("viewWillDisappear"), "after the push: \(afterPush)")
                XCTAssertTrue(recorder.calls.contains("viewWillAppear"), "after the pop: \(recorder.calls)")
                XCTAssertTrue(recorder.calls.contains("viewDidAppear"), "after the pop: \(recorder.calls)")
            }
            CYLTearDownSearchRun(run)
        }
        print("E20 appearance calls (push | pop), forwarding on: \(recorded[true] ?? []), off: \(recorded[false] ?? [])")
    }

    // MARK: - E21

    /// E21 (#680): the results of the contents' search must not show over a screen pushed on top of the contents. The real
    /// reproduction needs a cancelled interactive pop (a touch), which XCTest cannot make; this runs the closest sequence:
    /// push, push again, pop and push, and checks that no search view is in the window while a pushed screen is on top.
    func testCancelledPopThenPushShowsNoResults() {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run, text: "H")
        let system = run.search.searchController
        let first = CYLSearchPushedController()
        run.navigation.pushViewController(first, animated: false)
        CYLRunLoop(0.6)
        XCTAssertNil(system.view.window, "no search view over the pushed screen")
        run.navigation.popViewController(animated: true)
        CYLRunLoop(0.05)
        run.navigation.pushViewController(CYLSearchPushedController(), animated: true)
        CYLRunLoop(0.9)
        XCTAssertNil(system.view.window, "no search view over the screen pushed after the pop")
        XCTAssertNil(run.search.tableView?.window, "no results over the pushed screen")
        CYLTearDownSearchRun(run)
    }

    // MARK: - E22

    /// E22: the status bar providers reach the system controller, which is told to update when it is presented.
    func testE22StatusBarProvidersReachTheSystemController() {
        let search = CYLSearchController(contentsViewController: UIViewController())
        let system = search.searchController
        var hidden = true
        var style = UIStatusBarStyle.lightContent
        search.prefersStatusBarHiddenProvider = { hidden }
        search.preferredStatusBarStyleProvider = { style }
        XCTAssertTrue(system.prefersStatusBarHidden)
        XCTAssertEqual(system.preferredStatusBarStyle, .lightContent)
        hidden = false
        style = .darkContent
        XCTAssertFalse(system.prefersStatusBarHidden)
        XCTAssertEqual(system.preferredStatusBarStyle, .darkContent)
        search.prefersStatusBarHiddenProvider = nil
        search.preferredStatusBarStyleProvider = nil
        XCTAssertEqual(system.preferredStatusBarStyle, .default)
    }

    // MARK: - Delegate order

    /// The delegate hears willPresent / didPresent / willDismiss / didDismiss in order, and the results table once.
    func testDelegateLifecycleOrder() {
        let run = CYLMakeSearchRun()
        CYLActivateSearch(run, text: "H")
        run.search.setActive(false, animated: true)
        CYLRunLoop(0.9)
        let events = run.contents.events.filter { $0 != "willShowEmptyView" }
        XCTAssertEqual(events.filter { $0 == "didLoadTableView" }.count, 1)
        XCTAssertEqual(events.filter { $0 != "didLoadTableView" }, ["willPresent", "didPresent", "willDismiss", "didDismiss"])
        CYLTearDownSearchRun(run)
    }

    // MARK: - B7 to B9 with CYLSearchController

    private func presentationFrame(_ view: UIView?, in window: UIWindow) -> CGRect? {
        guard let layer = view?.layer.presentation() else { return nil }
        return layer.convert(layer.bounds, to: window.layer)
    }

    private func sample(for seconds: TimeInterval, _ body: () -> Void) {
        let start = Date()
        while Date().timeIntervalSince(start) < seconds {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.03))
            body()
        }
    }

    private func headerRun() -> CYLSearchRun {
        let run = CYLMakeSearchRun { contents in
            contents.tableView.backgroundColor = .red
        }
        let system = run.search.searchController
        system.automaticallyShowsCancelButton = false
        run.search.searchBar.showsCancelButton = true
        // A bar background in blue through the appearance (a background image set by hand is replaced by the appearance when
        // the bar first lays out): the red table behind must not show through its top rows (B9).
        let style = run.search.searchBar.appearanceStyle
        style.barBackgroundColor = .blue
        run.search.searchBar.appearanceStyle = style
        run.search.searchBar.sizeToFit()
        CYLRunLoop(0.4)
        return run
    }

    /// B7 again, with CYLSearchController: Cancel stays level with the field and moves one way while the bar leaves search.
    func testB7WithCYLSearchControllerCancelDoesNotJitter() {
        let run = headerRun()
        let bar = run.search.searchBar
        run.search.setActive(true, animated: true)
        CYLRunLoop(0.8)
        run.search.setActive(false, animated: true)
        var offsets: [CGFloat] = []
        var cancelY: [CGFloat] = []
        sample(for: 0.6) {
            guard let button = bar.cancelButton,
                  let buttonFrame = self.presentationFrame(button, in: run.window),
                  let fieldFrame = self.presentationFrame(bar.searchTextField, in: run.window) else { return }
            offsets.append(buttonFrame.minY - fieldFrame.minY)
            cancelY.append(buttonFrame.minY)
        }
        XCTAssertFalse(offsets.isEmpty, "Cancel was visible while leaving search")
        // The offset may settle by one point at the end of the animation (6 to 7 on iOS 27.2); a jitter is a back and forth.
        let spread = (offsets.max() ?? 0) - (offsets.min() ?? 0)
        XCTAssertLessThanOrEqual(spread, 1.5, "level with the field: \(offsets)")
        let steps = zip(cancelY, cancelY.dropFirst()).map { $1 - $0 }
        XCTAssertFalse(steps.contains { $0 > 0.5 } && steps.contains { $0 < -0.5 }, "one direction only: \(cancelY)")
        CYLTearDownSearchRun(run)
    }

    /// B8 again: the header bar sits below the status bar while searching, never at a negative y.
    func testB8WithCYLSearchControllerHeaderBarFrame() {
        let run = headerRun()
        let bar = run.search.searchBar
        let top = run.window.windowScene?.statusBarManager?.statusBarFrame.maxY ?? 0
        run.search.setActive(true, animated: true)
        var minY = CGFloat.greatestFiniteMagnitude
        sample(for: 0.8) {
            if let frame = self.presentationFrame(bar, in: run.window) { minY = min(minY, frame.minY) }
        }
        XCTAssertGreaterThanOrEqual(minY, top - 0.5, "the active bar sits below the status bar (\(top))")
        run.search.setActive(false, animated: true)
        minY = .greatestFiniteMagnitude
        sample(for: 0.8) {
            if let frame = self.presentationFrame(bar, in: run.window) { minY = min(minY, frame.minY) }
        }
        XCTAssertGreaterThanOrEqual(minY, -0.5, "no negative y while dismissing")
        CYLTearDownSearchRun(run)
    }

    private func pixels(_ window: UIWindow, at points: [CGPoint]) -> [[UInt8]] {
        let scale = window.screen.scale
        let width = Int(window.bounds.width * scale), height = Int(window.bounds.height * scale)
        var data = [UInt8](repeating: 0, count: width * height * 4)
        guard let space = CGColorSpace(name: CGColorSpace.sRGB),
              let context = CGContext(data: &data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                                      space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return [] }
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: scale, y: -scale)
        UIGraphicsPushContext(context)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        UIGraphicsPopContext()
        return points.map { point in
            let offset = (Int(point.y * scale) * width + Int(point.x * scale)) * 4
            return Array(data[offset..<offset + 4])
        }
    }

    /// B9 again: no 1 px gap showing the table's red background above the blue header bar, at rest and while searching.
    func testB9WithCYLSearchControllerNoGapAboveTheHeaderBar() {
        let run = headerRun()
        let bar = run.search.searchBar
        let pixel = 1 / run.window.screen.scale
        let control = pixels(run.window, at: [CGPoint(x: 200, y: 700)])[0]
        XCTAssertGreaterThan(control[0], 200, "the control pixel reads red: \(control)")
        for state in ["rest", "searching"] {
            if state == "searching" {
                run.search.setActive(true, animated: true)
                CYLRunLoop(0.8)
            }
            let frame = bar.convert(bar.bounds, to: run.window)
            let rows = pixels(run.window, at: [CGPoint(x: 5, y: frame.minY), CGPoint(x: 5, y: frame.minY + pixel)])
            for row in rows {
                XCTAssertLessThan(row[0], 100, "\(state): the bar's top rows show no red background: \(row)")
                XCTAssertGreaterThan(row[2], 100, "\(state): blue: \(row)")
            }
        }
        CYLTearDownSearchRun(run)
    }
}
