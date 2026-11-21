//
//  CYLSearchBarStyleTests.swift
//  CYLSearchExampleTests
//
//  One test per row B1 to B13 of the edge-case table in docs/qmui-search-controller.md (a row dropped with a reason keeps
//  a check of the reason), plus the checks that QMUI's category members became public API of CYLSearchBar.
//

import ObjectiveC
import XCTest
import CYLSearchViewController
@testable import CYLSearchExample

final class CYLSearchBarStyleTests: CYLSearchExampleTestCase {

    // MARK: - Helpers

    private func makeWindow(_ controller: UIViewController) -> UIWindow {
        let window = CYLTestWindow(CGRect(x: 0, y: 0, width: 402, height: 874))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        return window
    }

    /// A bar 390 pt wide in a window, below the safe area, laid out.
    private func shownBar(_ bar: CYLSearchBar = CYLSearchBar(frame: CGRect(x: 0, y: 0, width: 390, height: 56)),
                          in controller: UIViewController = UIViewController()) -> (CYLSearchBar, UIWindow) {
        bar.frame = CGRect(x: 0, y: 100, width: 390, height: 56)
        let window = makeWindow(controller)
        controller.view.addSubview(bar)
        settle(bar)
        return (bar, window)
    }

    private func settle(_ view: UIView, _ seconds: TimeInterval = 0.3) {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
        view.layoutIfNeeded()
    }

    private func placeholderLabel(of bar: UISearchBar) -> UILabel? {
        bar.searchTextField.subviews.compactMap { $0 as? UILabel }.first
    }

    private func color(of label: UILabel) -> UIColor? {
        if let text = label.attributedText, text.length > 0,
           let color = text.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor { return color }
        return label.textColor
    }

    private func isSame(_ lhs: UIColor?, _ rhs: UIColor?) -> Bool {
        guard let lhs, let rhs else { return lhs == nil && rhs == nil }
        var a: (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0), b = a
        lhs.getRed(&a.0, green: &a.1, blue: &a.2, alpha: &a.3)
        rhs.getRed(&b.0, green: &b.1, blue: &b.2, alpha: &b.3)
        return abs(a.0 - b.0) < 0.01 && abs(a.1 - b.1) < 0.01 && abs(a.2 - b.2) < 0.01 && abs(a.3 - b.3) < 0.01
    }

    private func fieldFrame(_ bar: UISearchBar) -> CGRect { bar.searchTextField.frame }

    private func cancel(_ bar: CYLSearchBar) -> UIButton? { bar.cancelButton }

    // MARK: - API and initialization

    /// A member of CYLSearchBar must never take the selector of a private UISearchBar method (QMUI read cancelButton,
    /// _backgroundView, _searchController and scopeBar of UISearchBar through KVC): a Swift @objc member with the same
    /// selector would silently override it. Every own method of CYLSearchBar is checked against its superclass chain.
    func testNoSelectorOverridesAPrivateUISearchBarMethod() {
        let intended: Set<String> = ["layoutSubviews", "didMoveToWindow", "placeholder", "setPlaceholder:", "text", "setText:",
                                     "initWithFrame:", "initWithCoder:", ".cxx_destruct", "barTintColor", "setBarTintColor:",
                                     "setBackgroundImage:forBarPosition:barMetrics:"]
        var count: UInt32 = 0
        let methods = class_copyMethodList(CYLSearchBar.self, &count)
        defer { free(methods) }
        var collisions: [String] = []
        for index in 0..<Int(count) {
            guard let method = methods?[index] else { continue }
            let selector = method_getName(method)
            if intended.contains(NSStringFromSelector(selector)) { continue }
            if UISearchBar.instancesRespond(to: selector) { collisions.append(NSStringFromSelector(selector)) }
        }
        XCTAssertEqual(collisions, [], "selectors that UISearchBar already answers")
        // UIKit's own cancelButton is untouched, and ours has its own name.
        let uikit = NSSelectorFromString("cancelButton")
        XCTAssertEqual(class_getMethodImplementation(CYLSearchBar.self, uikit), class_getMethodImplementation(UISearchBar.self, uikit))
        XCTAssertTrue(CYLSearchBar.instancesRespond(to: NSSelectorFromString("cyl_cancelButton")))
    }

    /// E23: a bar created with an empty frame is sized with sizeToFit.
    func testEmptyFrameIsSizedOnInit() {
        let bar = CYLSearchBar(frame: .zero)
        XCTAssertGreaterThan(bar.frame.width, 0)
        XCTAssertGreaterThan(bar.frame.height, 0)
        XCTAssertTrue(CYLSearchBar().frame.height > 0)
        let given = CYLSearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        XCTAssertEqual(given.frame.width, 200, "a given frame is kept")
    }

    func testDefaults() {
        let bar = CYLSearchBar(frame: .zero)
        XCTAssertFalse(bar.usedAsTableHeaderView)
        XCTAssertFalse(bar.centersPlaceholder)
        XCTAssertTrue(bar.alwaysEnablesCancelButton)
        XCTAssertTrue(bar.showsLeadingAccessoryView)
        XCTAssertTrue(bar.showsTrailingAccessoryView)
        XCTAssertNil(bar.searchController)
        XCTAssertNil(bar.cancelButton, "UIKit has not created Cancel yet")
        XCTAssertNil(bar.segmentedControl)
        XCTAssertEqual(bar.textFieldMargins, .zero)
    }

    // MARK: - B1

    /// B1 (#830): the placeholder color survives the bar moving to a window, a changed placeholder and a second window.
    func testB1PlaceholderColorSurvivesWindowAndPlaceholderChange() {
        let bar = CYLSearchBar(frame: CGRect(x: 0, y: 0, width: 390, height: 56))
        bar.placeholderColor = .red
        bar.placeholder = "Find"
        let (shown, window) = shownBar(bar)
        XCTAssertNotNil(shown.window)
        XCTAssertTrue(isSame(color(of: try! XCTUnwrap(placeholderLabel(of: shown))), .red), "after moving to a window")
        shown.placeholder = "Find again"
        settle(shown)
        XCTAssertTrue(isSame(color(of: try! XCTUnwrap(placeholderLabel(of: shown))), .red), "after changing the placeholder")
        shown.removeFromSuperview()
        let second = makeWindow(UIViewController())
        second.rootViewController?.view.addSubview(shown)
        settle(shown)
        XCTAssertTrue(isSame(color(of: try! XCTUnwrap(placeholderLabel(of: shown))), .red), "after moving to another window")
        window.isHidden = true
        second.isHidden = true
    }

    // MARK: - B2

    /// B2: the magnifier and the placeholder are centered at rest and lead while editing; never a negative width.
    func testB2CenteredPlaceholder() throws {
        let (bar, window) = shownBar()
        bar.placeholder = "Search"
        settle(bar)
        let field = bar.searchTextField
        let leadingIcon = try XCTUnwrap(field.leftView).frame.minX
        bar.centersPlaceholder = true
        settle(bar)
        let icon = try XCTUnwrap(field.leftView)
        let label = try XCTUnwrap(placeholderLabel(of: bar))
        XCTAssertGreaterThan(icon.frame.minX, leadingIcon + 20, "the icon moved to the middle")
        let text = ("Search" as NSString).size(withAttributes: [.font: field.font ?? UIFont.preferredFont(forTextStyle: .body)])
        let contentMid = icon.frame.minX + (label.frame.minX - icon.frame.minX + text.width) / 2
        XCTAssertEqual(contentMid, field.bounds.width / 2, accuracy: 3, "icon and text are centered in the field")

        // A field of no width (an intermediate state) is skipped, and the layout recovers.
        bar.frame.size.width = 0
        bar.layoutIfNeeded()
        bar.frame.size.width = 390
        settle(bar)
        XCTAssertGreaterThanOrEqual(bar.positionAdjustment(for: .search).horizontal, 0)
        XCTAssertEqual(contentMidX(bar), field.bounds.width / 2, accuracy: 3)

        // Editing: the icon leads again.
        XCTAssertTrue(field.becomeFirstResponder())
        settle(bar)
        XCTAssertEqual(try XCTUnwrap(field.leftView).frame.minX, leadingIcon, accuracy: 1)
        XCTAssertEqual(bar.positionAdjustment(for: .search), .zero)
        field.resignFirstResponder()
        settle(bar)
        XCTAssertGreaterThan(try XCTUnwrap(field.leftView).frame.minX, leadingIcon + 20, "centered again at rest")

        // Typed text keeps it leading, and switching the option off restores UIKit's place.
        bar.text = "abc"
        settle(bar)
        XCTAssertEqual(try XCTUnwrap(field.leftView).frame.minX, leadingIcon, accuracy: 1)
        bar.text = nil
        bar.centersPlaceholder = false
        settle(bar)
        XCTAssertEqual(try XCTUnwrap(field.leftView).frame.minX, leadingIcon, accuracy: 1)
        window.isHidden = true
    }

    private func contentMidX(_ bar: UISearchBar) -> CGFloat {
        guard let icon = bar.searchTextField.leftView, let label = placeholderLabel(of: bar) else { return -1 }
        let font = bar.searchTextField.font ?? UIFont.preferredFont(forTextStyle: .body)
        let text = ((bar.placeholder ?? "") as NSString).size(withAttributes: [.font: font])
        return icon.frame.minX + (label.frame.minX - icon.frame.minX + text.width) / 2
    }

    // MARK: - B3

    /// B3: the field's margins on top of UIKit's, one set per state; a provider wins over the value.
    func testB3TextFieldMargins() {
        let (plain, window) = shownBar()
        let base = fieldFrame(plain)
        let (bar, other) = shownBar(CYLSearchBar(frame: .zero), in: UIViewController())
        XCTAssertEqual(fieldFrame(bar), base)
        bar.textFieldMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 6)
        XCTAssertEqual(fieldFrame(bar).minX, base.minX + 10, accuracy: 0.5)
        XCTAssertEqual(fieldFrame(bar).maxX, base.maxX - 6, accuracy: 0.5)
        settle(bar)
        XCTAssertEqual(fieldFrame(bar).minX, base.minX + 10, accuracy: 0.5, "applied once, not again after another layout")
        bar.textFieldMarginsProvider = { _, active in
            active ? .zero : UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)
        }
        settle(bar)
        XCTAssertEqual(fieldFrame(bar).minX, base.minX + 32, accuracy: 0.5, "the provider wins at rest")
        XCTAssertEqual(fieldFrame(bar).width, base.width - 64, accuracy: 0.5)
        XCTAssertTrue(bar.searchTextField.becomeFirstResponder())
        settle(bar, 0.6)
        XCTAssertEqual(fieldFrame(bar).minX, base.minX, accuracy: 0.5, "no margins while searching")
        bar.searchTextField.resignFirstResponder()
        bar.textFieldMarginsProvider = nil
        bar.textFieldMargins = .zero
        settle(bar)
        XCTAssertEqual(fieldFrame(bar), base, "removing the margins restores UIKit's frame")
        window.isHidden = true
        other.isHidden = true
    }

    /// B3 and B6 against UIKit setting frames again: the margins stay applied once, never twice, after Cancel is shown with
    /// animation, after the bar's width changes (rotation) and after editing begins and ends.
    func testMarginsSurviveUIKitRelayouts() {
        let (plain, window) = shownBar()
        let (bar, other) = shownBar(CYLSearchBar(frame: .zero), in: UIViewController())
        bar.textFieldMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 6)
        bar.leadingAccessoryView = accessory()
        bar.leadingAccessoryViewMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        func check(_ state: String) {
            settle(plain, 0.6)
            settle(bar, 0.6)
            let reference = fieldFrame(plain)
            let adjusted = fieldFrame(bar)
            XCTAssertEqual(adjusted.minX, reference.minX + 10 + 38, accuracy: 0.5, "\(state): left")
            XCTAssertEqual(adjusted.maxX, reference.maxX - 6, accuracy: 0.5, "\(state): right")
            XCTAssertEqual(adjusted.height, reference.height, accuracy: 0.5, "\(state): height")
            XCTAssertEqual(adjusted.midY, reference.midY, accuracy: 0.5, "\(state): vertical")
        }
        check("rest")
        plain.setShowsCancelButton(true, animated: true)
        bar.setShowsCancelButton(true, animated: true)
        check("Cancel shown with animation")
        plain.setShowsCancelButton(false, animated: true)
        bar.setShowsCancelButton(false, animated: true)
        check("Cancel hidden with animation")
        plain.frame.size.width = 320
        bar.frame.size.width = 320
        check("narrower")
        plain.frame.size.width = 390
        bar.frame.size.width = 390
        check("wider again")
        XCTAssertTrue(plain.searchTextField.becomeFirstResponder())
        XCTAssertTrue(bar.searchTextField.becomeFirstResponder())
        check("editing")
        plain.searchTextField.resignFirstResponder()
        bar.searchTextField.resignFirstResponder()
        check("editing ended")
        window.isHidden = true
        other.isHidden = true
    }

    // MARK: - B4

    /// B4: the Cancel button is created lazily; its font and margins are applied when it exists.
    func testB4CancelButtonFontAndMargins() throws {
        let (plain, window) = shownBar()
        let (bar, other) = shownBar(CYLSearchBar(frame: .zero), in: UIViewController())
        bar.cancelButtonFont = .boldSystemFont(ofSize: 21)
        bar.cancelButtonMarginsProvider = { _, active in
            active ? UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0) : .zero
        }
        XCTAssertNil(bar.cancelButton, "created lazily")
        for current in [plain, bar] { current.showsCancelButton = true }
        settle(plain)
        settle(bar)
        let button = try XCTUnwrap(bar.cancelButton)
        let reference = try XCTUnwrap(plain.cancelButton)
        XCTAssertEqual(button.titleLabel?.font.pointSize, 21, "the font reaches a button created after it was set")
        XCTAssertEqual(button.frame, reference.frame, "no margins at rest")
        XCTAssertTrue(plain.searchTextField.becomeFirstResponder())
        XCTAssertTrue(bar.searchTextField.becomeFirstResponder())
        settle(plain, 0.6)
        settle(bar, 0.6)
        let active = try XCTUnwrap(bar.cancelButton)
        let activeReference = try XCTUnwrap(plain.cancelButton)
        XCTAssertEqual(active.frame.minX, activeReference.frame.minX - 16, accuracy: 0.5, "a negative left margin moves Cancel left")
        XCTAssertEqual(active.frame.width, activeReference.frame.width + 16, accuracy: 0.5, "and widens it")
        XCTAssertEqual(active.accessibilityLabel, CYLSearchResources.localizedString(forKey: "search.cancel"))
        window.isHidden = true
        other.isHidden = true
    }

    // MARK: - B5

    /// B5: UIKit disables Cancel while the bar is not editing; a bar without a search controller keeps it enabled.
    func testB5AlwaysEnablesCancelButton() throws {
        let (plain, window) = shownBar(CYLSearchBar(frame: .zero))
        plain.alwaysEnablesCancelButton = false
        plain.showsCancelButton = true
        settle(plain)
        XCTAssertFalse(try XCTUnwrap(plain.cancelButton).isEnabled, "UIKit disables Cancel at rest (the quirk)")

        let (bar, other) = shownBar(CYLSearchBar(frame: .zero), in: UIViewController())
        bar.showsCancelButton = true
        settle(bar)
        XCTAssertTrue(try XCTUnwrap(bar.cancelButton).isEnabled)
        XCTAssertTrue(bar.searchTextField.becomeFirstResponder())
        settle(bar)
        bar.searchTextField.resignFirstResponder()
        settle(bar, 0.6)
        XCTAssertTrue(try XCTUnwrap(bar.cancelButton).isEnabled, "still enabled after editing ends")
        bar.alwaysEnablesCancelButton = false
        bar.searchTextField.becomeFirstResponder()
        bar.searchTextField.resignFirstResponder()
        settle(bar, 0.6)
        XCTAssertFalse(try XCTUnwrap(bar.cancelButton).isEnabled, "UIKit's behavior again when the option is off")
        window.isHidden = true
        other.isHidden = true
    }

    // MARK: - B6

    private func accessory(width: CGFloat = 30) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 30))
        view.backgroundColor = .systemRed
        return view
    }

    /// B6: accessory views take their width and gap from the field, centered on it; fast toggling ends in the last state.
    func testB6AccessoryViews() throws {
        let (bar, window) = shownBar()
        let base = fieldFrame(bar)
        let leading = accessory()
        let trailing = accessory()
        bar.leadingAccessoryViewMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        bar.trailingAccessoryViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        bar.leadingAccessoryView = leading
        bar.trailingAccessoryView = trailing
        settle(bar)
        let field = fieldFrame(bar)
        XCTAssertEqual(field.minX, base.minX + 38, accuracy: 0.5, "the field gives up the accessory width plus margins")
        XCTAssertEqual(field.maxX, base.maxX - 38, accuracy: 0.5)
        XCTAssertFalse(leading.isHidden)
        XCTAssertTrue(leading.superview === bar.searchTextField.superview)
        XCTAssertEqual(leading.frame.midY, field.midY, accuracy: 0.5, "centered on the field")
        XCTAssertEqual(trailing.frame.midY, field.midY, accuracy: 0.5)
        XCTAssertLessThanOrEqual(leading.frame.maxX, field.minX, "the leading view does not cover the field")
        XCTAssertGreaterThanOrEqual(trailing.frame.minX, field.maxX, "the trailing view does not cover the field")

        // Hidden without animation: the field is back to UIKit's.
        bar.showsLeadingAccessoryView = false
        bar.showsTrailingAccessoryView = false
        settle(bar)
        XCTAssertTrue(leading.isHidden)
        XCTAssertEqual(fieldFrame(bar), base)

        // Toggling twice quickly with animation: the last request wins, also for isHidden.
        bar.setShowsLeadingAccessoryView(true, animated: true)
        bar.setShowsLeadingAccessoryView(false, animated: true)
        bar.setShowsLeadingAccessoryView(true, animated: true)
        bar.setShowsTrailingAccessoryView(true, animated: true)
        bar.setShowsTrailingAccessoryView(false, animated: true)
        settle(bar, 0.8)
        XCTAssertTrue(bar.showsLeadingAccessoryView)
        XCTAssertFalse(leading.isHidden)
        XCTAssertEqual(leading.transform, .identity)
        XCTAssertFalse(bar.showsTrailingAccessoryView)
        XCTAssertTrue(trailing.isHidden)
        XCTAssertEqual(trailing.alpha, 1)
        XCTAssertEqual(fieldFrame(bar).minX, base.minX + 38, accuracy: 0.5)
        XCTAssertEqual(fieldFrame(bar).maxX, base.maxX, accuracy: 0.5)

        // Replacing a view removes the old one.
        let replacement = accessory(width: 20)
        bar.leadingAccessoryView = replacement
        settle(bar)
        XCTAssertNil(leading.superview)
        XCTAssertEqual(fieldFrame(bar).minX, base.minX + 28, accuracy: 0.5)
        window.isHidden = true
    }

    // MARK: - B7 to B9 (UIKit table header quirks: checked on this system, no fix needed)

    private struct HeaderRun {
        let window: UIWindow
        let controller: UISearchController
        let table: UITableViewController
    }

    private func headerRun() -> HeaderRun {
        let table = UITableViewController(style: .plain)
        let controller = UISearchController(searchResultsController: UITableViewController(style: .plain))
        controller.obscuresBackgroundDuringPresentation = true
        controller.automaticallyShowsCancelButton = false
        controller.searchBar.showsCancelButton = true
        controller.searchBar.sizeToFit()
        controller.searchBar.barTintColor = .blue
        table.tableView.tableHeaderView = controller.searchBar
        table.tableView.backgroundColor = .red
        table.definesPresentationContext = true
        let window = makeWindow(UINavigationController(rootViewController: table))
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        return HeaderRun(window: window, controller: controller, table: table)
    }

    private func presentationFrame(_ view: UIView?, in window: UIWindow) -> CGRect? {
        guard let layer = view?.layer.presentation() else { return nil }
        return layer.convert(layer.bounds, to: window.layer)
    }

    private func sample(_ run: HeaderRun, for seconds: TimeInterval, _ body: () -> Void) {
        let start = Date()
        while Date().timeIntervalSince(start) < seconds {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.03))
            body()
        }
    }

    /// B7: iOS 13 let Cancel jitter when a header bar with showsCancelButton already on left search. Sampled on the
    /// presentation layer at 30 ms: Cancel stays level with the field and only moves one way.
    func testB7CancelDoesNotJitterWhenLeavingSearch() {
        let run = headerRun()
        let bar = run.controller.searchBar
        run.controller.isActive = true
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.8))
        run.controller.isActive = false
        var offsets: [CGFloat] = []
        var cancelY: [CGFloat] = []
        sample(run, for: 0.6) {
            guard let button = bar.searchTextField.superview?.subviews.compactMap({ $0 as? UIButton }).first,
                  let buttonFrame = self.presentationFrame(button, in: run.window),
                  let fieldFrame = self.presentationFrame(bar.searchTextField, in: run.window) else { return }
            offsets.append(buttonFrame.minY - fieldFrame.minY)
            cancelY.append(buttonFrame.minY)
        }
        XCTAssertFalse(offsets.isEmpty, "Cancel was visible while leaving search")
        XCTAssertTrue(offsets.allSatisfy { abs($0 - offsets[0]) < 0.5 }, "level with the field: \(offsets)")
        let steps = zip(cancelY, cancelY.dropFirst()).map { $1 - $0 }
        XCTAssertFalse(steps.contains { $0 > 0.5 } && steps.contains { $0 < -0.5 }, "one direction only: \(cancelY)")
        run.window.isHidden = true
    }

    /// B8 (#233): the header bar's frame while searching: below the status bar, never at a negative y, not shifted up.
    func testTableHeaderBarFrameWhileSearching() {
        let run = headerRun()
        let bar = run.controller.searchBar
        let top = run.window.windowScene?.statusBarManager?.statusBarFrame.maxY ?? 0
        run.controller.isActive = true
        var minY = CGFloat.greatestFiniteMagnitude
        sample(run, for: 0.8) {
            if let frame = self.presentationFrame(bar, in: run.window) { minY = min(minY, frame.minY) }
        }
        XCTAssertGreaterThanOrEqual(minY, top - 0.5, "the active bar sits below the status bar (\(top))")
        run.controller.isActive = false
        minY = .greatestFiniteMagnitude
        sample(run, for: 0.8) {
            if let frame = self.presentationFrame(bar, in: run.window) { minY = min(minY, frame.minY) }
        }
        XCTAssertGreaterThanOrEqual(minY, -0.5, "no negative y while dismissing")
        XCTAssertGreaterThanOrEqual(bar.convert(bar.bounds, to: run.window).minY, run.window.safeAreaInsets.top, "back under the navigation bar")
        run.window.isHidden = true
    }

    private func pixels(_ window: UIWindow, at points: [CGPoint]) -> [[UInt8]] {
        let scale = window.screen.scale
        let width = Int(window.bounds.width * scale), height = Int(window.bounds.height * scale)
        var data = [UInt8](repeating: 0, count: width * height * 4)
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let context = CGContext(data: &data, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
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

    /// B9 (#950): no 1 px gap that shows the table's background (red) at the top of a header bar (blue), at rest and while
    /// searching. A control pixel proves the reader: the table's own area reads red.
    func testB9NoGapAboveTheHeaderBar() {
        let run = headerRun()
        let bar = run.controller.searchBar
        let pixel = 1 / run.window.screen.scale
        let control = pixels(run.window, at: [CGPoint(x: 200, y: 600)])[0]
        XCTAssertGreaterThan(control[0], 200, "the control pixel reads red: \(control)")
        XCTAssertLessThan(control[2], 50)
        for state in ["rest", "searching"] {
            if state == "searching" {
                run.controller.isActive = true
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.8))
            }
            let frame = bar.convert(bar.bounds, to: run.window)
            let rows = pixels(run.window, at: [CGPoint(x: 5, y: frame.minY), CGPoint(x: 5, y: frame.minY + pixel)])
            for row in rows {
                XCTAssertLessThan(row[0], 100, "\(state): the bar's top rows show no red background: \(row)")
                XCTAssertGreaterThan(row[2], 100, "\(state): blue: \(row)")
            }
        }
        run.window.isHidden = true
    }

    // MARK: - B10 to B12

    /// B10 (#1207, a short list hides the header bar) is covered by the "Short list" scenario of phase 3 (I4).
    /// B11: dropped (iOS 14 beta font change); changing the font keeps the field's height.
    func testB11FontChangeKeepsFieldHeight() {
        let (bar, window) = shownBar()
        let height = fieldFrame(bar).height
        bar.font = .systemFont(ofSize: 28, weight: .bold)
        settle(bar)
        XCTAssertEqual(fieldFrame(bar).height, height, accuracy: 0.5)
        XCTAssertEqual(bar.searchTextField.font?.pointSize, 28)
        window.isHidden = true
    }

    /// B12: dropped (the index bar switch needs the private _updateInsetsForTableView:). The bar offers no such member.
    func testB12IndexBarSwitchIsNotOffered() {
        XCTAssertFalse(CYLSearchBar.instancesRespond(to: NSSelectorFromString("adjustTextFieldLayoutForIndexBar")))
        XCTAssertFalse(CYLSearchBar.instancesRespond(to: NSSelectorFromString("setAdjustTextFieldLayoutForIndexBar:")))
    }

    // MARK: - B13

    func testB13DefaultAppearanceLandsOnTheBar() throws {
        let (bar, window) = shownBar()
        XCTAssertEqual(bar.placeholder, CYLSearchResources.localizedString(forKey: "search.field"))
        XCTAssertTrue(isSame(bar.tintColor, UIColor(red: 0, green: 104 / 255, blue: 248 / 255, alpha: 1)), "legacy tint")
        let image = try XCTUnwrap(bar.searchFieldBackgroundImage(for: .normal))
        XCTAssertEqual(image.size.width, 60)
        XCTAssertGreaterThanOrEqual(image.size.height, 28)
        XCTAssertEqual(image.size.height, fieldFrame(bar).height, "the image decides the field height")
        XCTAssertNotNil(bar.backgroundImage(for: .any, barMetrics: .default), "an empty image removes the bar background")
        XCTAssertEqual(bar.backgroundImage(for: .any, barMetrics: .default)?.size, .zero)
        XCTAssertEqual(bar.autocorrectionType, .no)
        XCTAssertEqual(bar.autocapitalizationType, .none)
        XCTAssertEqual(bar.searchTextField.layer.cornerRadius, fieldFrame(bar).height / 2, accuracy: 0.5, "the legacy pill")
        XCTAssertEqual(CYLSearchBarAppearance.default.placeholder, CYLSearchResources.localizedString(forKey: "search.field"))
        XCTAssertEqual(CYLSearchBarAppearance.default.cancelTitle, CYLSearchResources.localizedString(forKey: "search.cancel"))
        // The legacy field color 187, 186, 193 in light mode.
        let light = CYLSearchBarAppearance.default.textFieldBackgroundColor?.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
        XCTAssertTrue(isSame(light, UIColor(red: 187 / 255, green: 186 / 255, blue: 193 / 255, alpha: 1)))
        window.isHidden = true
    }

    func testB13EveryAppearanceValueLandsOnTheBar() throws {
        let style = CYLSearchBarAppearance()
        style.font = .italicSystemFont(ofSize: 19)
        style.textColor = .systemGreen
        style.placeholderColor = .systemOrange
        style.placeholder = "Style placeholder"
        style.cancelTitle = "Stop"
        style.tintColor = .systemPink
        let icon = UIGraphicsImageRenderer(size: CGSize(width: 14, height: 14)).image { UIColor.black.setFill(); $0.fill(CGRect(x: 0, y: 0, width: 14, height: 14)) }
        style.searchIconImage = icon
        style.clearIconImage = icon
        style.textFieldBackgroundColor = .systemYellow
        style.textFieldBorderColor = .systemRed
        style.textFieldCornerRadius = 7
        style.barBackgroundColor = .systemTeal
        style.barBorderColor = .systemIndigo
        let bar = CYLSearchBar(frame: CGRect(x: 0, y: 0, width: 390, height: 56))
        bar.appearanceStyle = style
        bar.showsCancelButton = true
        let (shown, window) = shownBar(bar)
        XCTAssertEqual(shown.font, style.font)
        XCTAssertEqual(shown.searchTextField.font, style.font)
        XCTAssertEqual(shown.searchTextField.textColor, .systemGreen)
        XCTAssertTrue(isSame(shown.placeholderColor, .systemOrange))
        XCTAssertTrue(isSame(color(of: try XCTUnwrap(placeholderLabel(of: shown))), .systemOrange))
        XCTAssertEqual(shown.placeholder, "Style placeholder")
        XCTAssertEqual(shown.tintColor, .systemPink)
        XCTAssertNotNil(shown.image(for: .search, state: .normal))
        XCTAssertNotNil(shown.image(for: .clear, state: .normal))
        XCTAssertNotNil(shown.searchFieldBackgroundImage(for: .normal))
        XCTAssertGreaterThan(shown.searchTextField.layer.borderWidth, 0)
        XCTAssertNotNil(shown.searchTextField.layer.borderColor)
        XCTAssertEqual(shown.searchTextField.layer.cornerRadius, 7)
        XCTAssertEqual(shown.backgroundImage(for: .any, barMetrics: .default)?.size, CGSize(width: 10, height: 10))
        XCTAssertEqual(shown.backgroundImage(for: .any, barMetrics: .defaultPrompt)?.size, CGSize(width: 10, height: 10))
        XCTAssertEqual(try XCTUnwrap(shown.cancelButton).accessibilityLabel, "Stop")

        // Copies are independent, and the defaults are not touched by a bar's style.
        let copy = try XCTUnwrap(style.copy() as? CYLSearchBarAppearance)
        copy.placeholder = "Other"
        XCTAssertEqual(style.placeholder, "Style placeholder")
        XCTAssertNotEqual(CYLSearchBarAppearance.default.placeholder, "Style placeholder")
        window.isHidden = true
    }

    func testB13ImageGenerators() {
        XCTAssertNil(CYLSearchBar.textFieldBackgroundImage(color: nil))
        XCTAssertNil(CYLSearchBar.backgroundImage(color: nil, borderColor: nil))
        let field = CYLSearchBar.textFieldBackgroundImage(color: .red)
        XCTAssertEqual(field?.size.width, 60)
        XCTAssertEqual(field?.capInsets, UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        let background = CYLSearchBar.backgroundImage(color: .white, borderColor: .gray)
        XCTAssertEqual(background?.size, CGSize(width: 10, height: 10))
        XCTAssertEqual(background?.capInsets, UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
        XCTAssertNotNil(CYLSearchBar.backgroundImage(color: nil, borderColor: .gray), "white by default")
    }

    func testB13DarkModeDrawsTheFieldColorAgain() {
        let (bar, window) = shownBar()
        let light = bar.searchFieldBackgroundImage(for: .normal)
        window.overrideUserInterfaceStyle = .dark
        settle(bar)
        let dark = bar.searchFieldBackgroundImage(for: .normal)
        XCTAssertNotNil(dark)
        XCTAssertFalse(light === dark, "the image was drawn again for dark mode")
        window.isHidden = true
    }

    // MARK: - Segmented control and background view

    func testBackgroundViewAndSegmentedControl() {
        let (bar, window) = shownBar()
        XCTAssertNotNil(bar.backgroundView)
        XCTAssertFalse(bar.searchTextField.isDescendant(of: bar.backgroundView ?? bar))
        XCTAssertNil(bar.segmentedControl)
        bar.scopeButtonTitles = ["One", "Two"]
        bar.showsScopeBar = true
        bar.frame.size.height = 100
        settle(bar)
        XCTAssertNotNil(bar.segmentedControl)
        XCTAssertEqual(bar.segmentedControl?.numberOfSegments, 2)
        window.isHidden = true
    }

    // MARK: - The "Search bar styles" screen

    func testStylesScreenRowsDriveTheBar() throws {
        let screen = CYLSearchBarStylesViewController(style: .grouped)
        let window = makeWindow(UINavigationController(rootViewController: screen))
        settle(screen.view)
        let bar = screen.searchBar
        XCTAssertTrue(screen.tableView.tableHeaderView === bar)
        XCTAssertTrue(bar.usedAsTableHeaderView)
        XCTAssertEqual(screen.numberOfSections(in: screen.tableView), 3)
        XCTAssertEqual(screen.tableView(screen.tableView, numberOfRowsInSection: 2), 4)
        XCTAssertFalse(bar.showsLeadingAccessoryView, "hidden first, shown by the person")
        XCTAssertFalse(bar.showsTrailingAccessoryView)
        XCTAssertNotNil(bar.leadingAccessoryView)
        XCTAssertEqual(bar.leadingAccessoryViewMargins, UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0))
        XCTAssertEqual(bar.trailingAccessoryViewMargins, UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8))

        func select(_ section: Int, _ row: Int) {
            screen.tableView(screen.tableView, didSelectRowAt: IndexPath(row: row, section: section))
            settle(screen.view, 0.5)
        }
        select(0, 1)
        XCTAssertEqual(bar.placeholder, CYLSearchResources.localizedString(forKey: "styles.longPlaceholder"))
        select(1, 0)
        XCTAssertNotNil(bar.textFieldMarginsProvider)
        XCTAssertEqual(bar.textFieldMarginsProvider?(bar, false), UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32))
        XCTAssertEqual(bar.textFieldMarginsProvider?(bar, true), .zero)
        let toggle = try XCTUnwrap(screen.tableView(screen.tableView, cellForRowAt: IndexPath(row: 0, section: 0)).accessoryView as? UISwitch)
        toggle.isOn = true
        toggle.sendActions(for: .valueChanged)
        XCTAssertTrue(bar.centersPlaceholder)
        let animated = try XCTUnwrap(screen.tableView(screen.tableView, cellForRowAt: IndexPath(row: 0, section: 2)).accessoryView as? UISwitch)
        animated.isOn = false
        animated.sendActions(for: .valueChanged)
        select(2, 2)
        XCTAssertTrue(bar.showsLeadingAccessoryView)
        select(2, 3)
        XCTAssertTrue(bar.showsTrailingAccessoryView)
        select(2, 1)
        XCTAssertTrue(bar.showsCancelButton)
        select(1, 1)
        XCTAssertNotNil(bar.cancelButtonMarginsProvider)
        XCTAssertTrue(bar.isFirstResponder || bar.searchTextField.isFirstResponder, "Adjust Cancel starts searching")
        window.isHidden = true
    }
}
