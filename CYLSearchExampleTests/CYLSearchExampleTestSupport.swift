//
//  CYLSearchExampleTestSupport.swift
//  CYLSearchExampleTests
//
//  The shared base class, recorders and view helpers of the example's tests (translated from CYLSearchExampleTests.m,
//  docs/swift-migration.md, step 4).
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
 * The base class of the example's test cases: every test starts from an empty default suggestion cache and an empty
 * example cache (the cache persists by design, a local database, docs/core-todo.md), so a query submitted by one test
 * never shows in another.
 */
class CYLSearchExampleTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        for name in ["CYLSearchView", "MaterialSearchView"] {
            let searchView = CYLSearchView(frame: .zero)
            searchView.suggestionCacheName = name
            searchView.suggestionCache?.removeAllQueries()
        }
    }
}

/**
 * Records the items a CYLSearchBarView reports as selected.
 */
final class CYLSearchItemRecorder: NSObject, CYLSearchBarViewDelegate {
    var items: [CYLSearchBarItem] = []

    func searchBarView(_ searchBarView: CYLSearchBarView, didSelect item: CYLSearchBarItem) {
        items.append(item)
    }
}

/**
 * Records the text changes, the Search key and Cancel of a CYLSearchBarView.
 */
final class CYLSearchBarRecorder: NSObject, CYLSearchBarViewDelegate {
    var events: [String] = []

    func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) { events.append("text " + text) }
    func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) { events.append("search") }
    func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) { events.append("cancel") }
}

/**
 * Records the parity events of CYLSearchBarView (one field and several searches) and CYLSearchView, and refuses
 * submissions while `refuseSubmit` is true.
 */
final class CYLParityRecorder: NSObject, CYLSearchBarViewDelegate, CYLSearchViewDelegate {
    var events: [String] = []
    var refuseSubmit = false
    var handleSubmit = false
    var refuseEditing = false

    func searchBarViewSearchButtonClicked(_ searchBarView: CYLSearchBarView) { events.append("search " + (searchBarView.text ?? "")) }
    func searchBarView(_ searchBarView: CYLSearchBarView, shouldSubmitText text: String) -> Bool { !refuseSubmit }
    func searchBarViewNavigationButtonClicked(_ searchBarView: CYLSearchBarView) { events.append("navigation") }
    func searchBarViewShouldBeginEditing(_ searchBarView: CYLSearchBarView) -> Bool { !refuseEditing }
    func searchBarViewDidTapWhileNotEditable(_ searchBarView: CYLSearchBarView) { events.append("tapped") }
    func searchBarViewVoiceButtonClicked(_ searchBarView: CYLSearchBarView) { events.append("voice") }
    func searchBarView(_ searchBarView: CYLSearchBarView, didChangeIconified iconified: Bool) { events.append(iconified ? "iconified" : "expanded") }
    func searchViewDidShow(_ searchView: CYLSearchView) { events.append("shown") }
    func searchViewDidClose(_ searchView: CYLSearchView) { events.append("closed") }
    func searchView(_ searchView: CYLSearchView, textDidChange text: String) { events.append("change " + text) }
    func searchView(_ searchView: CYLSearchView, didSubmitText text: String) -> Bool { events.append("submit " + text); return handleSubmit }
    func searchView(_ searchView: CYLSearchView, didSelectSuggestion suggestion: String, at index: UInt) { events.append("suggestion \(index) \(suggestion)") }
    func searchBarView(_ view: CYLSearchBarView, textDidChange text: String, at index: Int) { events.append("typed \(index) \(text)") }
    func searchBarView(_ view: CYLSearchBarView, didCompleteSearch text: String, at index: Int) { events.append("complete \(index) \(text)") }
    func searchBarView(_ view: CYLSearchBarView, didRemoveSearchAt index: Int) { events.append("removed \(index)") }
    func searchBarView(_ view: CYLSearchBarView, didSelectSearch text: String, at index: Int) { events.append("selected \(index) \(text)") }
}

/**
 * Results for CYLSearchView: [42] for an empty query (the Issue #1317 page lists everything then), [42, 7] for "4",
 * nothing for any other query. Also the delegate that records the selected result.
 */
final class CYLSearchNumberDataSource: NSObject, CYLSearchViewDataSource, CYLSearchViewDelegate {
    var selectedResult: Any?
    var queryCount = 0

    func searchView(_ searchView: CYLSearchView, resultsForQuery query: String) -> [Any] {
        queryCount += 1
        if query.isEmpty { return [42] }
        return query == "4" ? [42, 7] : []
    }

    func searchView(_ searchView: CYLSearchView, configureResultCell cell: UITableViewCell, withResult result: Any) {
        cell.textLabel?.text = String(describing: result)
    }

    func searchView(_ searchView: CYLSearchView, didSelectResult result: Any) {
        selectedResult = result
    }
}

/**
 * A refresh that completes at once and counts its calls.
 */
final class CYLSearchImmediateRefresh: NSObject, CYLSearchExampleRefreshing {
    var refreshCount = 0

    func reload(completion: @escaping (Error?) -> Void) {
        refreshCount += 1
        completion(nil)
    }
}

/**
 * Pushes without animation and remembers the last pushed view controller.
 */
final class CYLSearchTestNavigationController: UINavigationController {
    var lastPushedController: UIViewController?

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        lastPushedController = viewController
        super.pushViewController(viewController, animated: false)
    }
}

/**
 * A window in the host app's scene: with the scene life cycle, a window without a scene is never shown, and the search
 * bars of its navigation items are never installed.
 */
func testWindow(_ frame: CGRect) -> UIWindow {
    let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first
    let window = scene.map { UIWindow(windowScene: $0) } ?? UIWindow(frame: frame)
    window.frame = frame
    return window
}

/**
 * The text fields of the searches of a bar in `.multiple` mode, in order (the bar's own field excluded).
 */
func searchFields(_ bar: CYLSearchBarView) -> [UITextField] {
    var fields: [UITextField] = []
    func visit(_ view: UIView) {
        if let field = view as? UITextField, field !== bar.textField { fields.append(field) }
        view.subviews.forEach(visit)
    }
    visit(bar)
    return fields
}

/**
 * What a navigation-item search controller shows: its search bar, or on iOS 26, where the navigation bar hosts the field
 * without the bar, the search text field.
 */
func visibleSearchView(_ searchBar: UISearchBar) -> UIView {
    searchBar.window != nil ? searchBar : searchBar.searchTextField
}

/**
 * The first view in `root` (itself included) with the accessibility identifier, depth first.
 */
func viewWithAccessibilityIdentifier(_ root: UIView, _ identifier: String) -> UIView? {
    if root.accessibilityIdentifier == identifier { return root }
    for subview in root.subviews {
        if let found = viewWithAccessibilityIdentifier(subview, identifier) { return found }
    }
    return nil
}

/**
 * The first view in `root` (itself included) of the class, depth first.
 */
func viewOfClass<T: UIView>(_ root: UIView, _ viewClass: T.Type) -> T? {
    if let match = root as? T { return match }
    for subview in root.subviews {
        if let found = viewOfClass(subview, viewClass) { return found }
    }
    return nil
}

/**
 * Views that `view` covers: visible views under `root` (its window when nil) whose frames intersect `view`'s frame in
 * window coordinates, after clipping by ancestors that clip their bounds. Not counted: `view`'s subviews, the views that
 * contain it, system bar backgrounds, and plain leaf views that draw nothing. Counted: labels, images, controls, text,
 * scroll views, view controllers' views, and leaf views with a background, contents or a border. Each entry is
 * "<class> <frame> in <superview>".
 */
func viewsCoveredByView(_ view: UIView, _ root: UIView?) -> [String] {
    guard let window = view.window else { return ["not in a window"] }
    let frame = view.convert(view.bounds, to: window).insetBy(dx: 0.5, dy: 0.5)
    var ancestors = Set<ObjectIdentifier>()
    var parent = view.superview
    while let current = parent {
        ancestors.insert(ObjectIdentifier(current))
        parent = current.superview
    }
    var covered: [String] = []
    func visit(_ candidate: UIView) {
        if candidate === view || candidate.isHidden || candidate.alpha <= 0.01 { return }
        let name = NSStringFromClass(type(of: candidate))
        if name.contains("BarBackground") { return }
        var content = candidate is UILabel || candidate is UIControl || candidate is UITextView || candidate is UIScrollView
            || candidate.next is UIViewController
        if let imageView = candidate as? UIImageView { content = imageView.image != nil }
        if !content && candidate.subviews.isEmpty && !name.hasPrefix("_") {
            content = (candidate.backgroundColor?.cgColor.alpha ?? 0) > 0.01 || candidate.layer.contents != nil
                || candidate.layer.borderWidth > 0
        }
        if content && !ancestors.contains(ObjectIdentifier(candidate)) {
            // Only the part left visible by ancestors that clip (a scroll view hides what lies outside it).
            var other = candidate.convert(candidate.bounds, to: window)
            var clip = candidate.superview
            while let current = clip, current !== window {
                if current.clipsToBounds { other = other.intersection(current.convert(current.bounds, to: window)) }
                clip = current.superview
            }
            if !other.isNull && other.width > 0 && other.height > 0 && frame.intersects(other) {
                let superName = candidate.superview.map { NSStringFromClass(type(of: $0)) } ?? "nil"
                covered.append("\(name) \(NSCoder.string(for: other)) in \(superName)")
            }
        }
        candidate.subviews.forEach(visit)
    }
    (root ?? window).subviews.forEach(visit)
    return covered
}

/**
 * Runs the main run loop for `seconds`, as the Objective-C tests did with `-runUntilDate:`.
 */
func runLoop(_ seconds: TimeInterval) {
    RunLoop.main.run(until: Date(timeIntervalSinceNow: seconds))
}
