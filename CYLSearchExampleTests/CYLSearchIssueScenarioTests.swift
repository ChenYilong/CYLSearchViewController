//
//  CYLSearchIssueScenarioTests.swift
//  CYLSearchExampleTests
//
//  The owner's issues of docs/qmui-search-controller.md ("The owner's issues"): #1319 (I1), #1251 (I2), #1229 (I3), #1160 (I4,
//  also B10 / #1207) and #1313 (I5), each on the example screen that rebuilds its scenario.
//

@testable import CYLSearchViewController
import UIKit
import XCTest
@testable import CYLSearchExample

/**
 * Calls `body` on every display refresh until stopped (the frames of an animation are sampled between run loop passes).
 */
final class CYLFrameSampler: NSObject {
    private var link: CADisplayLink?
    private let body: () -> Void

    init(_ body: @escaping () -> Void) {
        self.body = body
        super.init()
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    @objc private func tick() { body() }

    func stop() {
        link?.invalidate()
        link = nil
    }
}

final class CYLSearchIssueScenarioTests: CYLSearchExampleTestCase {

    private func open(_ controller: UIViewController) -> (window: UIWindow, navigation: UINavigationController) {
        let navigation = UINavigationController(rootViewController: controller)
        let window = testWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = navigation
        window.makeKeyAndVisible()
        runLoop(0.4)
        return (window, navigation)
    }

    /// The bar's frame in the window as drawn at this moment (the presentation layer follows an animation).
    private func drawnFrame(of view: UIView, in window: UIWindow) -> CGRect {
        // The core never animates the field's position any more, so the model frame is the drawn frame.
        view.convert(view.bounds, to: window)
    }

    // MARK: - I1 (#1319)

    /// I1: with the navigation bar kept (`hidesNavigationBarDuringPresentation = false`) the bar does not jump vertically
    /// while the search is entered with animation: every frame of the animation is within 0.5 pt of where it started.
    func testI1BarDoesNotJumpOnActivation() throws {
        let screen = CYLSearchControllerDemoViewController(style: .plain)
        let (window, navigation) = open(screen)
        let search = try XCTUnwrap(screen.cylSearchController)
        let bar = search.searchBar
        let start = drawnFrame(of: bar, in: window)
        XCTAssertGreaterThan(start.height, 0)
        XCTAssertGreaterThanOrEqual(start.minY, navigation.navigationBar.frame.maxY - 0.5)
        var samples: [CGRect] = []
        let sampler = CYLFrameSampler { samples.append(self.drawnFrame(of: bar, in: window)) }
        search.setActive(true, animated: true)
        runLoop(1.2)
        sampler.stop()
        XCTAssertTrue(search.isActive)
        XCTAssertGreaterThan(samples.count, 10, "the animation was sampled")
        let worst = samples.map { abs($0.minY - start.minY) }.max() ?? 0
        XCTAssertLessThanOrEqual(worst, 0.5, "the bar's top edge moved \(worst) pt during activation (start \(start))")
        search.setActive(false, animated: true)
        runLoop(1.0)
        let end = drawnFrame(of: bar, in: window)
        XCTAssertEqual(end.minY, start.minY, accuracy: 0.5, "and it is back where it was after Cancel")
        window.isHidden = true
    }

    // MARK: - I2 (#1251)

    /// I2: a bar that is a plain subview stays inside the safe area, under the navigation bar that stays visible, at rest and
    /// while searching, and does not move when the search starts.
    func testI2PlainSubviewBarStaysInTheSafeArea() throws {
        let screen = CYLSearchBarInViewDemoViewController()
        let (window, navigation) = open(screen)
        let search = try XCTUnwrap(screen.cylSearchController)
        let bar = search.searchBar
        XCTAssertTrue(bar.superview === screen.view, "a plain subview")
        let start = bar.convert(bar.bounds, to: window)
        XCTAssertGreaterThanOrEqual(start.minY, navigation.navigationBar.frame.maxY - 0.5)
        var samples: [CGRect] = []
        let sampler = CYLFrameSampler { samples.append(self.drawnFrame(of: bar, in: window)) }
        search.setActive(true, animated: true)
        runLoop(1.2)
        sampler.stop()
        XCTAssertTrue(search.isActive)
        XCTAssertFalse(navigation.navigationBar.isHidden, "the navigation bar stays")
        let worst = samples.map { abs($0.minY - start.minY) }.max() ?? 0
        // Row I2 (docs/qmui-search-controller.md): UIKit put the container it moves the bar into at the bar's window y inside a
        // presentation that starts at the contents view, one navigation bar height too low (116 pt on iOS 27.2). The core puts
        // the bar back: it stays where it was through the whole animation.
        XCTAssertLessThanOrEqual(worst, 1, "the bar moved \(worst) pt")
        let active = bar.convert(bar.bounds, to: window)
        XCTAssertEqual(active.minY, start.minY, accuracy: 0.5, "the bar stays at its rest position while searching")
        // The results start at the bar's bottom edge, not 116 pt lower.
        let table = try XCTUnwrap(search.tableView)
        let resultsTop = table.convert(table.bounds, to: window).minY + table.adjustedContentInset.top
        XCTAssertEqual(resultsTop, active.maxY, accuracy: 0.5, "the results start under the bar")
        // A real tap run (docs/qmui-search-controller.md, phase 4) found the bar 0 pt wide while searching when it was laid out
        // with Auto Layout constraints to the screen's view: UIKit moves the bar into its own container and drops them.
        XCTAssertEqual(active.width, window.bounds.width, accuracy: 0.5, "the bar keeps its width while searching")
        XCTAssertLessThanOrEqual(active.maxY, window.bounds.maxY)
        // Leaving the search starts from the corrected place: no slide on the way back either.
        var leaving: [CGRect] = []
        let leaveSampler = CYLFrameSampler { leaving.append(self.drawnFrame(of: bar, in: window)) }
        search.setActive(false, animated: true)
        runLoop(1.0)
        leaveSampler.stop()
        let worstLeaving = leaving.map { abs($0.minY - start.minY) }.max() ?? 0
        XCTAssertLessThanOrEqual(worstLeaving, 1, "the bar moved \(worstLeaving) pt while leaving")
        window.isHidden = true
    }

    /// I2 with the contents view under the navigation bar (UIKit's default; the demo screen removes `.top`): the bar laid out
    /// at the safe area top stays there while searching.
    func testI2PlainBarInAnExtendedViewStaysInPlace() throws {
        let screen = UIViewController()
        screen.view.backgroundColor = .systemBackground
        let search = CYLSearchController(contentsViewController: screen)
        let bar = search.searchBar
        bar.sizeToFit()
        screen.view.addSubview(bar)
        let (window, navigation) = open(screen)
        bar.frame = CGRect(x: 0, y: screen.view.safeAreaInsets.top, width: screen.view.bounds.width, height: bar.frame.height)
        let start = bar.convert(bar.bounds, to: window)
        XCTAssertEqual(start.minY, navigation.navigationBar.frame.maxY, accuracy: 0.5)
        var samples: [CGRect] = []
        let sampler = CYLFrameSampler { samples.append(self.drawnFrame(of: bar, in: window)) }
        search.setActive(true, animated: true)
        runLoop(1.2)
        sampler.stop()
        XCTAssertTrue(search.isActive)
        let worst = samples.map { abs($0.minY - start.minY) }.max() ?? 0
        XCTAssertLessThanOrEqual(worst, 1, "the bar moved \(worst) pt")
        search.setActive(false, animated: false)
        window.isHidden = true
    }

    // MARK: - I3 (#1229)

    /// I3: install(in:) with no other strong reference: the wrapper lives (the contents retain it), the search activates, the
    /// delegate receives the typed text, Cancel leaves, and nothing crashes. When the screen goes, the wrapper goes too.
    func testI3NavigationItemInstallSurvivesASearch() throws {
        weak var weakSearch: CYLSearchController?
        weak var weakScreen: CYLSearchNavigationItemDemoViewController?
        autoreleasepool {
            let screen = CYLSearchNavigationItemDemoViewController(style: .plain)
            weakScreen = screen
            let (window, navigation) = open(screen)
            weakSearch = screen.cylSearchController
            XCTAssertNotNil(weakSearch, "the contents view controller keeps the wrapper")
            XCTAssertTrue(navigation.topViewController?.navigationItem.titleView === weakSearch?.searchBar)
            runLoop(0.2)
            weakSearch?.setActive(true, animated: true)
            runLoop(0.9)
            XCTAssertEqual(weakSearch?.isActive, true)
            for text in ["H", "He", "zzz", ""] {
                weakSearch?.searchBar.text = text
                runLoop(0.3)
                XCTAssertEqual(screen.searchStrings.last, text, "the delegate got \"\(text)\"")
            }
            XCTAssertNotNil(weakSearch, "still alive while searching")
            weakSearch?.setActive(false, animated: true)
            runLoop(0.9)
            XCTAssertEqual(weakSearch?.isActive, false)
            window.rootViewController = nil
            window.isHidden = true
        }
        runLoop(0.6)
        XCTAssertNil(weakScreen, "the screen leaked")
        XCTAssertNil(weakSearch, "the wrapper leaked")
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

    // MARK: - I4 (#1160, B10)

    /// I4 / B10: with three rows the header scrolls out of sight, settles fully shown or fully hidden when a drag ends, the bar
    /// is never left half visible or invisible, and the table's delegate is not replaced.
    func testI4ShortListHeaderSettlesFullyShownOrHidden() throws {
        let screen = CYLSearchShortListDemoViewController(style: .plain)
        let (window, navigation) = open(screen)
        let table: UITableView = screen.tableView
        let bar = try XCTUnwrap(screen.searchBar)
        let snapper = try XCTUnwrap(screen.searchController?.headerSnapper)
        XCTAssertEqual(table.estimatedRowHeight, 0)
        XCTAssertEqual(table.estimatedSectionHeaderHeight, 0)
        XCTAssertEqual(table.estimatedSectionFooterHeight, 0)
        XCTAssertTrue(table.delegate === screen, "the table's delegate is not replaced")
        XCTAssertEqual(table.numberOfRows(inSection: 0), 3)
        let height = bar.bounds.height
        let shown = -table.adjustedContentInset.top
        let hidden = shown + height
        func maxOffset() -> CGFloat { table.contentSize.height + table.adjustedContentInset.bottom - table.bounds.height }
        XCTAssertGreaterThanOrEqual(maxOffset(), hidden - 0.5, "the header can scroll fully out of sight above three rows")
        XCTAssertEqual(table.contentOffset.y, shown, accuracy: 0.5, "the bar is shown at first (B10)")
        let barFrame = bar.convert(bar.bounds, to: window)
        XCTAssertGreaterThanOrEqual(barFrame.minY, navigation.navigationBar.frame.maxY - 0.5, "the bar is below the navigation bar")

        let insetBefore = table.contentInset.bottom
        for _ in 0..<3 { snapper.refresh() }
        XCTAssertEqual(table.contentInset.bottom, insetBefore, accuracy: 0.5, "the inset does not feed itself")
        print("I4 on this system: contentSize \(table.contentSize), inset \(table.contentInset), hidden offset \(hidden), largest offset \(maxOffset())")

        // Half of the header away, released with no speed: the nearer edge wins.
        table.contentOffset = CGPoint(x: 0, y: shown + height / 2 - 6)
        XCTAssertTrue(snapper.settle(velocityY: 0))
        runLoop(0.7)
        XCTAssertEqual(table.contentOffset.y, shown, accuracy: 0.5, "fully shown")
        table.contentOffset = CGPoint(x: 0, y: shown + height / 2 + 6)
        XCTAssertTrue(snapper.settle(velocityY: 0))
        runLoop(0.7)
        XCTAssertEqual(table.contentOffset.y, hidden, accuracy: 0.5, "fully hidden")
        let hiddenFrame = bar.convert(bar.bounds, to: window)
        XCTAssertLessThanOrEqual(hiddenFrame.maxY, navigation.navigationBar.frame.maxY + 0.5, "the bar is out of sight")
        // Released moving down: the speed decides where it would come to rest.
        table.contentOffset = CGPoint(x: 0, y: shown + height / 2 + 6)
        XCTAssertEqual(snapper.settleOffsetY(from: table.contentOffset.y, velocityY: 30), shown)
        XCTAssertEqual(snapper.settleOffsetY(from: table.contentOffset.y, velocityY: -30), hidden)
        XCTAssertNil(snapper.settleOffsetY(from: table.contentOffset.y, velocityY: 5000), "a flick past the band is left to UIKit")
        XCTAssertNil(snapper.settleOffsetY(from: hidden, velocityY: 0), "nothing to settle at the edge")
        // Back down: the bar is visible again, it never stays invisible (B10).
        table.setContentOffset(CGPoint(x: 0, y: shown), animated: false)
        runLoop(0.2)
        let shownFrame = bar.convert(bar.bounds, to: window)
        XCTAssertGreaterThanOrEqual(shownFrame.minY, navigation.navigationBar.frame.maxY - 0.5)
        XCTAssertGreaterThan(shownFrame.height, 0)

        // Turned off: UIKit's own behavior, and the inset goes.
        screen.searchController?.snapsHeaderSearchBar = false
        XCTAssertEqual(table.contentInset.bottom, 0, accuracy: 0.5)
        XCTAssertFalse(snapper.settle(velocityY: 0))
        window.isHidden = true
    }

    /// The control for #1160: a plain table view controller with three rows and a plain UISearchBar as the header, estimated
    /// heights as UIKit has them by default. Records what this system does (the numbers go to the test log and the design
    /// document); nothing is asserted about UIKit itself.
    func testI4ControlPlainTableOnThisSystem() {
        final class Rows: UITableViewController {
            override func numberOfSections(in tableView: UITableView) -> Int { 1 }
            override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 3 }
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                UITableViewCell(style: .default, reuseIdentifier: nil)
            }
        }
        let controller = Rows(style: .plain)
        let bar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 402, height: 56))
        controller.tableView.tableHeaderView = bar
        let (window, _) = open(controller)
        let table: UITableView = controller.tableView
        let hidden = -table.adjustedContentInset.top + bar.bounds.height
        let largest = table.contentSize.height + table.adjustedContentInset.bottom - table.bounds.height
        print("I4 control, plain UIKit: estimatedRowHeight \(table.estimatedRowHeight), contentSize \(table.contentSize), hidden offset \(hidden), largest offset \(largest), can hide the header \(largest >= hidden - 0.5)")
        window.isHidden = true
    }

    /// A table whose content size UIKit does not pad (here a fixed short height): the snapper adds exactly the bottom inset that
    /// lets the header scroll out of sight, does not feed itself, follows the content size, and takes the inset away when it is
    /// turned off or the bar is no longer the header. On iOS 27.2 UIKit pads the content size of a short list by itself (the
    /// test above prints the numbers), so the inset is the fallback for systems that do not.
    func testI4BottomInsetFillsWhatUIKitDoesNotPad() throws {
        final class ShortTable: UITableView {
            var forcedHeight: CGFloat?
            override var contentSize: CGSize {
                get { forcedHeight.map { CGSize(width: super.contentSize.width, height: $0) } ?? super.contentSize }
                set { super.contentSize = newValue }
            }
        }
        let table = ShortTable(frame: CGRect(x: 0, y: 0, width: 402, height: 874), style: .plain)
        let controller = UIViewController()
        controller.view = table
        let (window, _) = open(controller)
        let search = CYLSearchController(contentsViewController: controller)
        table.forcedHeight = 196
        search.installSearchBar(asHeaderOf: table)
        let bar = search.searchBar
        let snapper = try XCTUnwrap(search.headerSnapper)
        snapper.refresh()
        let height = bar.bounds.height
        func maxOffset() -> CGFloat { table.contentSize.height + table.adjustedContentInset.bottom - table.bounds.height }
        let hidden = -table.adjustedContentInset.top + height
        XCTAssertGreaterThan(table.contentInset.bottom, 0, "inset \(table.contentInset), size \(table.contentSize), bounds \(table.bounds)")
        XCTAssertEqual(maxOffset(), hidden, accuracy: 1, "exactly enough to hide the header")
        let inset = table.contentInset.bottom
        for _ in 0..<3 { snapper.refresh() }
        XCTAssertEqual(table.contentInset.bottom, inset, accuracy: 0.5, "no feedback")
        // A taller list needs less, a long one none.
        table.forcedHeight = 600
        snapper.refresh()
        XCTAssertLessThan(table.contentInset.bottom, inset)
        XCTAssertGreaterThanOrEqual(maxOffset(), hidden - 1)
        table.forcedHeight = 3000
        snapper.refresh()
        XCTAssertEqual(table.contentInset.bottom, 0, accuracy: 0.5)
        // The owner's own bottom inset is kept as the base.
        table.forcedHeight = 196
        table.contentInset.bottom = 20
        snapper.refresh()
        XCTAssertGreaterThan(table.contentInset.bottom, 20)
        XCTAssertGreaterThanOrEqual(maxOffset(), hidden - 1)
        search.snapsHeaderSearchBar = false
        XCTAssertEqual(table.contentInset.bottom, 20, accuracy: 0.5, "turned off: only the owner's inset is left")
        search.snapsHeaderSearchBar = true
        XCTAssertGreaterThan(table.contentInset.bottom, 20)
        table.tableHeaderView = nil
        snapper.refresh()
        XCTAssertEqual(table.contentInset.bottom, 20, accuracy: 0.5, "without the bar as the header the inset goes")
        window.isHidden = true
    }

    // MARK: - I5 (#1313)

    /// I5: a bar in a container the screen owns is back at the frame it had after Cancel, and is again the container's
    /// subview.
    func testI5BarInContainerReturnsToItsFrameAfterCancel() throws {
        let screen = CYLSearchCollectionViewDemoViewController()
        let (window, _) = open(screen)
        let search = try XCTUnwrap(screen.cylSearchController)
        let bar = search.searchBar
        let container = try XCTUnwrap(screen.searchContainer)
        XCTAssertTrue(bar.superview === container)
        XCTAssertEqual(screen.collectionView?.numberOfItems(inSection: 0), CYLSearchCollectionViewDemoViewController.itemCount)
        let before = bar.convert(bar.bounds, to: window)
        XCTAssertGreaterThan(before.height, 0)
        for round in 1...2 {
            search.setActive(true, animated: true)
            runLoop(0.9)
            // Row I5: while searching the bar stays where it was (it landed 116 pt lower before the core put it back).
            XCTAssertEqual(drawnFrame(of: bar, in: window).minY, before.minY, accuracy: 1, "round \(round): searching")
            search.searchBar.text = "1"
            runLoop(0.3)
            var leaving: [CGRect] = []
            let sampler = CYLFrameSampler { leaving.append(self.drawnFrame(of: bar, in: window)) }
            search.setActive(false, animated: true)
            runLoop(1.0)
            runLoop(0.1)
            sampler.stop()
            // #1313 is a jitter after Cancel: no frame of the way back leaves the rest position.
            let worst = leaving.map { abs($0.minY - before.minY) }.max() ?? 0
            XCTAssertLessThanOrEqual(worst, 1, "round \(round): the bar moved \(worst) pt after Cancel")
            let after = bar.convert(bar.bounds, to: window)
            XCTAssertEqual(after.minX, before.minX, accuracy: 0.5, "round \(round)")
            XCTAssertEqual(after.minY, before.minY, accuracy: 0.5, "round \(round)")
            XCTAssertEqual(after.width, before.width, accuracy: 0.5, "round \(round)")
            XCTAssertEqual(after.height, before.height, accuracy: 0.5, "round \(round)")
            XCTAssertTrue(bar.superview === container, "round \(round): the bar is the container's subview again")
        }
        window.isHidden = true
    }
}
