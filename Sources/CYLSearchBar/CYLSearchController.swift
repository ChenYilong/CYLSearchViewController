/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

// Ported to Swift for CYLSearchViewController, 2026.// Ported to Swift for CYLSearchViewController, 2026.
//
//  CYLSearchController.swift
//  CYLSearchViewController
//
//  QMUISearchController, QMUISearchResultsTableViewController and the members of UISearchController (QMUI) as a wrapper
//  view controller around a private UISearchController subclass. QMUI hooks private classes and selectors and swizzles
//  UIViewController globally; here the subclass overrides viewWillAppear / viewDidLayoutSubviews, an own dimming view
//  replaces UIDimmingView, and an invisible child view controller of the contents view controller replaces the swizzles
//  of #1541 and of the appearance forwarding. docs/qmui-search-controller.md, rows E1 to E22.
//

import CYLTableViewPlaceHolder
import ObjectiveC
import UIKit

// MARK: - Delegate

/**
 * What a `CYLSearchController` asks of its owner (QMUI `QMUISearchControllerDelegate`): the search results (called on
 * every text change) and the data source and delegate of the results table view, plus optional life cycle callbacks.
 */
@objc(CYLSearchControllerDelegate)
public protocol CYLSearchControllerDelegate: UITableViewDataSource, UITableViewDelegate {

    /**
     * Called when the text of the search bar changes, also with "" (the first activation, all text deleted, the clear
     * button), as UIKit does. Reload `searchController.tableView` here.
     */
    @objc(searchController:updateResultsForSearchString:)
    func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String)

    /**
     * Called before the search is presented.
     */
    @objc optional func willPresentSearchController(_ searchController: CYLSearchController)

    /**
     * Called after the search is presented.
     */
    @objc optional func didPresentSearchController(_ searchController: CYLSearchController)

    /**
     * Called before the search is dismissed.
     */
    @objc optional func willDismissSearchController(_ searchController: CYLSearchController)

    /**
     * Called after the search is dismissed.
     */
    @objc optional func didDismissSearchController(_ searchController: CYLSearchController)

    /**
     * Called once when the results table view is created, to register cells or change its style.
     */
    @objc(searchController:didLoadSearchResultsTableView:)
    optional func searchController(_ searchController: CYLSearchController, didLoad tableView: UITableView)

    /**
     * Called before the empty view is shown, to change its look.
     */
    @objc(searchController:willShowEmptyView:)
    optional func searchController(_ searchController: CYLSearchController, willShow emptyView: UIView)
}

// MARK: - CYLSearchController

/**
 * A search controller with the shape of QMUI's `QMUISearchController`: it wraps a `UISearchController` (whose
 * `searchBar` is a `CYLSearchBar`) and adds a launch view while the text is empty (recent searches), a dimming color,
 * an empty view, swipe to dismiss, and the fixes for the leaks and layout quirks of `UISearchController`. The wrapper
 * is not a `UISearchController`: assign `searchController` (or call `install(in:)`) to a navigation item. Keep a strong
 * reference to the wrapper, as a property of the contents view controller.
 */
@objc(CYLSearchController)
open class CYLSearchController: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate {

    // MARK: Public properties

    /**
     * The owner of the results: its data source and delegate drive the results table view, and it is told about the
     * text and the life cycle. Held weakly.
     */
    @objc public weak var searchResultsDelegate: CYLSearchControllerDelegate? {
        didSet {
            guard let table = tableView else { return }
            table.dataSource = searchResultsDelegate
            table.delegate = searchResultsDelegate
        }
    }

    /**
     * The system `UISearchController` inside (a private subclass), for `navigationItem.searchController`.
     */
    @objc public var searchController: UISearchController { systemController }

    /**
     * The view controller that shows the results (`searchController.searchResultsController`): a table view controller
     * unless the controller was created with `init(contentsViewController:resultsViewController:)`.
     */
    @objc public var searchResultsController: UIViewController? { systemController.searchResultsController }

    /**
     * The search bar, a `CYLSearchBar`; use it as a table header or in a navigation item.
     */
    @objc public var searchBar: CYLSearchBar { systemController.cylSearchBar }

    /**
     * The results table view; `nil` unless the results controller is a `UITableViewController`.
     */
    @objc public var tableView: UITableView? { (searchResultsController as? UITableViewController)?.tableView }

    /**
     * A view shown while the text is empty, for example the recent searches; it fills the space under the search bar
     * (QMUI `launchView`). While it is set the system's obscuring of the background is off.
     */
    @objc public var launchView: UIView? {
        didSet { systemController.launchView = launchView }
    }

    /**
     * The color over the contents while the keyboard is up and the text is empty; `nil` keeps the system's. Ignored
     * when a `launchView` is set (QMUI `dimmingColor`).
     */
    @objc public var dimmingColor: UIColor? {
        didSet { systemController.dimmingColor = dimmingColor }
    }

    /**
     * Whether the search is active, changed without animation (QMUI `active`).
     */
    @objc public var isActive: Bool {
        @objc(isActive) get { systemController.isActive }
        @objc(setActive:) set { setActive(newValue, animated: false) }
    }

    /**
     * Whether the contents view controller's navigation bar is pushed away while searching. Default `true`.
     */
    @objc public var hidesNavigationBarDuringPresentation: Bool {
        get { systemController.hidesNavigationBarDuringPresentation }
        set { systemController.hidesNavigationBarDuringPresentation = newValue }
    }

    /**
     * Whether the results are shown even while the text is empty (QMUI `alwaysShowSearchResultsController`). Turning it
     * on clears `launchView` and the obscuring of the background; turning it off restores the obscuring.
     */
    @objc public var alwaysShowsSearchResultsController: Bool {
        get { systemController.showsSearchResultsController }
        set {
            if newValue { launchView = nil }
            systemController.showsSearchResultsController = newValue
        }
    }

    /**
     * Whether the appearance transitions of the contents view controller are passed on to the active search controller,
     * so a results controller hears `viewWillDisappear` when the contents push a screen and `viewDidAppear` when it
     * returns (QMUI `forwardAppearanceMethodsFromPresentingController`). Default `false`.
     */
    @objc public var forwardsAppearanceFromContentsViewController = false

    /**
     * Whether a swipe from the left screen edge leaves the search while the results or the launch view show (QMUI
     * `supportsSwipeToDismissSearch`). Default `false`. It uses a snapshot of the window, so rotation is not supported.
     */
    @objc public var supportsSwipeToDismissSearch = false

    /**
     * The swipe gesture, created when the search is presented with `supportsSwipeToDismissSearch` on.
     */
    @objc public private(set) var swipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    /**
     * The bottom edge of the search bar in `searchController.view` coordinates; 0 while the bar is not in that view.
     */
    @objc public var searchBarMaxY: CGFloat { systemController.searchBarMaxY }

    /**
     * Returns whether the status bar is hidden while searching (QMUI `qmui_prefersStatusBarHiddenBlock`).
     */
    @objc public var prefersStatusBarHiddenProvider: (() -> Bool)? {
        didSet { systemController.prefersStatusBarHiddenProvider = prefersStatusBarHiddenProvider }
    }

    /**
     * Returns the status bar style while searching (QMUI `qmui_preferredStatusBarStyleBlock`).
     */
    @objc public var preferredStatusBarStyleProvider: (() -> UIStatusBarStyle)? {
        didSet { systemController.preferredStatusBarStyleProvider = preferredStatusBarStyleProvider }
    }

    /**
     * Whether the empty view is on screen.
     */
    @objc public var isEmptyViewShowing: Bool { emptyView?.superview != nil }

    // MARK: Internal state

    let systemController: CYLSystemSearchController
    let presentationGuard = CYLSearchPresentationGuard()
    private(set) weak var contentsViewController: UIViewController?
    private(set) var emptyView: UIView?
    private(set) var snapshotView: UIView?
    private(set) var snapshotMaskView: UIView?
    private var dismissBySwipe = false
    private var hasSetShowsCancelButton = false
    private weak var swipeWindow: UIWindow?
    private weak var lockedWindow: UIWindow?
    private var forwardedAppearancePending = false
    private static let snapshotInitialX: CGFloat = -112

    // MARK: - Initializers

    /**
     * Creates a search controller for `contentsViewController` that shows its results in `resultsViewController` (QMUI
     * `initWithContentsViewController:resultsViewController:`). The contents view controller defines the presentation
     * context, so the bar does not stay on its navigation bar after a push from the results.
     */
    @objc public init(contentsViewController: UIViewController, resultsViewController: UIViewController) {
        systemController = CYLSystemSearchController(searchResultsController: resultsViewController)
        self.contentsViewController = contentsViewController
        super.init(nibName: nil, bundle: nil)
        // Two effects (QMUI): the bar does not stay on the navigation bar after a push from the results, and the
        // results
        // table's top inset fits the bar.
        contentsViewController.definesPresentationContext = true
        systemController.owner = self
        systemController.searchResultsUpdater = self
        systemController.delegate = self
        systemController.cylSearchBar.searchController = systemController
        systemController.hidesNavigationBarDuringPresentation = true
        systemController.updateObscuring()
        presentationGuard.owner = self
        contentsViewController.addChild(presentationGuard)
        presentationGuard.didMove(toParent: contentsViewController)
        attachGuardViewIfPossible()
    }

    /**
     * Creates a search controller whose results are a table view of `resultsTableViewStyle` (QMUI
     * `initWithContentsViewController:resultsTableViewStyle:`).
     */
    @objc public convenience init(contentsViewController: UIViewController, resultsTableViewStyle: UITableView.Style) {
        let results = CYLSearchResultsTableViewController(style: resultsTableViewStyle)
        self.init(contentsViewController: contentsViewController, resultsViewController: results)
        results.owner = self
    }

    /**
     * Creates a search controller with a plain results table view (QMUI `initWithContentsViewController:`).
     */
    @objc public convenience init(contentsViewController: UIViewController) {
        self.init(contentsViewController: contentsViewController, resultsTableViewStyle: .plain)
    }

    /**
     * Not available: create the controller with its contents view controller.
     */
    @objc public required init?(coder: NSCoder) {
        return nil
    }

    deinit {
        presentationGuard.detach()
    }

    // MARK: - View life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        // Load the system controller's view now, else its dealloc would load it and log a warning.
        systemController.loadViewIfNeeded()
    }

    // MARK: - Activation

    /**
     * Enters or leaves the search (QMUI `setActive:animated:`). Leaving without animation also hides the Cancel button,
     * which UIKit leaves on screen.
     */
    @objc public func setActive(_ active: Bool, animated: Bool) {
        if animated {
            systemController.isActive = active
            return
        }
        UIView.performWithoutAnimation {
            systemController.isActive = active
            // UIKit keeps Cancel after setActive(false) without animation: hide it by hand. Changing showsCancelButton
            // turns automaticallyShowsCancelButton off, so it is restored in the next willPresent.
            if !active && systemController.automaticallyShowsCancelButton {
                systemController.searchBar.showsCancelButton = false
                hasSetShowsCancelButton = true
            }
        }
    }

    // MARK: - Installing

    /**
     * Shows the search bar as the table view's header (QMUI `qmui_usedAsTableHeaderView`) and keeps the wrapper alive
     * as long as the table view lives.
     */
    @objc public func installSearchBar(asHeaderOf tableView: UITableView) {
        searchBar.usedAsTableHeaderView = true
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        objc_setAssociatedObject(tableView, &CYLSearchController.retainKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        attachGuardViewIfPossible()
    }

    /**
     * Installs the system search controller on a navigation item (the wrapper itself is not a `UISearchController`,
     * #1229) and keeps the wrapper alive as long as the navigation item lives.
     */
    @objc(installInNavigationItem:)
    public func install(in navigationItem: UINavigationItem) {
        searchBar.usedAsTableHeaderView = false
        navigationItem.searchController = systemController
        objc_setAssociatedObject(navigationItem, &CYLSearchController.retainKey, self,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        attachGuardViewIfPossible()
    }

    private static var retainKey = 0

    // MARK: - Empty view

    /**
     * Shows CYLTableViewPlaceHolder's placeholder with a title, an optional detail and an optional button in the
     * results (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`). Does nothing while the search text
     * is empty: the dimming view or the launch view is there then.
     */
    @objc public func showEmptyView(text: String?, detailText: String?, buttonTitle: String?,
                                    buttonAction: (() -> Void)?) {
        guard !(searchBar.text ?? "").isEmpty else { return }
        var components = [CYLPlaceholderComponent(bundledAnimation: "CYLPlaceholderNoResults.json",
                                                  fallbackStyle: .noResults, title: text,
                                                  size: CGSize(width: 96, height: 96), action: nil)]
        if let detailText, !detailText.isEmpty { components.append(CYLPlaceholderComponent.hint(text: detailText)) }
        var handlers: [CYLPlaceholderAction: CYLPlaceholderActionHandler] = [:]
        if let buttonTitle, !buttonTitle.isEmpty {
            components.append(CYLPlaceholderComponent.button(title: buttonTitle, style: .outlined, action: .retry))
            handlers[.retry] = { _, _ in buttonAction?() }
        }
        present(emptyView: CYLPlaceholderStackView(components: components, actions: handlers))
    }

    /**
     * Shows one of CYLTableViewPlaceHolder's scenarios in the results (the same placeholder `CYLSearchView` shows for
     * empty results). Does nothing while the search text is empty.
     */
    @objc public func showEmptyView(scenario: CYLPlaceholderScenario) {
        guard !(searchBar.text ?? "").isEmpty else { return }
        present(emptyView: CYLPlaceholderStackView(scenario: scenario, actions: nil))
    }

    /**
     * Removes the empty view (the search leaving always does).
     */
    @objc public func hideEmptyView() {
        emptyView?.removeFromSuperview()
        emptyView = nil
    }

    private func present(emptyView newView: UIView) {
        emptyView?.removeFromSuperview()
        emptyView = newView
        newView.backgroundColor = .systemBackground
        searchResultsDelegate?.searchController?(self, willShow: newView)
        guard let superview = searchResultsController?.view else { return }
        superview.addSubview(newView)
        layoutEmptyView()
    }

    func layoutEmptyView() {
        guard let emptyView, let superview = emptyView.superview else { return }
        // Under the search bar: the bar never sits on a view.
        let top = superview.convert(CGPoint(x: 0, y: searchBarMaxY), from: systemController.view).y
        let bounds = superview.bounds
        let minY = max(bounds.minY, top)
        emptyView.frame = CGRect(x: bounds.minX, y: minY, width: bounds.width, height: max(0, bounds.maxY - minY))
        superview.bringSubviewToFront(emptyView)
    }

    func resultsTableViewDidLoad(_ tableView: UITableView) {
        tableView.dataSource = searchResultsDelegate
        tableView.delegate = searchResultsDelegate
        searchResultsDelegate?.searchController?(self, didLoad: tableView)
    }

    // MARK: - UISearchResultsUpdating

    /**
     * Passes the search bar's text (also "") to the delegate; a swipe that was begun and abandoned leaves no snapshot
     * when the text is cleared.
     */
    @objc public func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text ?? ""
        // Swipe back, then cancel it, then clear the list with the x of the bar: the snapshot behind goes too.
        if supportsSwipeToDismissSearch && text.isEmpty && !alwaysShowsSearchResultsController && !dismissBySwipe {
            resetSnapshotObjects()
        }
        systemController.refreshOverlays()
        searchResultsDelegate?.searchController(self, updateResultsFor: text)
    }

    // MARK: - UISearchControllerDelegate

    /**
     * Prepares the swipe gesture and the Cancel button, then tells the delegate.
     */
    @objc public func willPresentSearchController(_ searchController: UISearchController) {
        attachGuardViewIfPossible()
        if supportsSwipeToDismissSearch { createSnapshotObjects() }
        // setActive(false, animated: false) had to change showsCancelButton by hand: let the system manage it again.
        if hasSetShowsCancelButton {
            systemController.automaticallyShowsCancelButton = true
            hasSetShowsCancelButton = false
        }
        if systemController.hasStatusBarProviders { systemController.setNeedsStatusBarAppearanceUpdate() }
        searchResultsDelegate?.willPresentSearchController?(self)
    }

    /**
     * Tells the delegate.
     */
    @objc public func didPresentSearchController(_ searchController: UISearchController) {
        searchResultsDelegate?.didPresentSearchController?(self)
    }

    /**
     * Tells the delegate and removes the swipe snapshot unless the swipe is what dismisses the search.
     */
    @objc public func willDismissSearchController(_ searchController: UISearchController) {
        if systemController.hasStatusBarProviders { systemController.setNeedsStatusBarAppearanceUpdate() }
        searchResultsDelegate?.willDismissSearchController?(self)
        // A swipe was begun and abandoned, then the Cancel button leaves the search: no snapshot may stay behind.
        if !dismissBySwipe { cleanSnapshotObjects() }
    }

    /**
     * Hides the empty view (leaving the search always does) and tells the delegate.
     */
    @objc public func didDismissSearchController(_ searchController: UISearchController) {
        hideEmptyView()
        searchResultsDelegate?.didDismissSearchController?(self)
        if supportsSwipeToDismissSearch && !dismissBySwipe { cleanSnapshotObjects() }
    }

    // MARK: - Swipe to dismiss

    private var swipeIsAvailable: Bool {
        if launchView != nil { return true }
        guard let results = searchResultsController, results.isViewLoaded else { return false }
        return !results.view.isHidden
    }

    private var delegateWindow: UIWindow? {
        systemController.viewIfLoaded?.window ?? contentsViewController?.viewIfLoaded?.window
    }

    private func createSnapshotObjects() {
        guard let window = delegateWindow ?? contentsViewController?.viewIfLoaded?.window else { return }
        let mask = snapshotMaskView ?? UIView()
        mask.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        snapshotMaskView = mask
        let snapshot = window.snapshotView(afterScreenUpdates: false) ?? UIView(frame: window.bounds)
        snapshot.accessibilityIdentifier = "CYLSearchSwipeSnapshot"
        mask.frame = snapshot.bounds
        snapshot.addSubview(mask)
        snapshotView = snapshot
        let gesture: UIScreenEdgePanGestureRecognizer
        if let existing = swipeGestureRecognizer {
            gesture = existing
        } else {
            gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
            gesture.edges = .left
            gesture.delegate = self
            swipeGestureRecognizer = gesture
        }
        window.addGestureRecognizer(gesture)
        swipeWindow = window
    }

    func resetSnapshotObjects() {
        snapshotView?.transform = .identity
        snapshotView?.removeFromSuperview()
    }

    func cleanSnapshotObjects() {
        snapshotView?.removeFromSuperview()
        snapshotMaskView?.removeFromSuperview()
        snapshotView = nil
        if let gesture = swipeGestureRecognizer { swipeWindow?.removeGestureRecognizer(gesture) }
    }

    @objc private func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began: swipeBegan()
        case .changed: swipeChanged(translationX: gesture.translation(in: gesture.view).x)
        case .ended: swipeEnded(velocityX: gesture.velocity(in: gesture.view).x)
        case .cancelled, .failed: swipeCancelled()
        default: break
        }
    }

    private var swipeContainerWidth: CGFloat { systemController.view.superview?.bounds.width ?? 0 }

    func swipeBegan() {
        guard swipeIsAvailable, let snapshot = snapshotView else { return }
        systemController.view.endEditing(true)
        systemController.view.superview?.insertSubview(snapshot, belowSubview: systemController.view)
        snapshot.transform = CGAffineTransform(translationX: Self.snapshotInitialX, y: 0)
        snapshotMaskView?.alpha = 1
    }

    func swipeChanged(translationX: CGFloat) {
        guard swipeIsAvailable, snapshotView?.superview != nil else { return }
        let width = swipeContainerWidth
        guard width > 0 else { return }
        let shift = min(max(0, translationX), width)
        systemController.view.transform = CGAffineTransform(translationX: shift, y: 0)
        let percent = shift / width
        snapshotView?.transform = CGAffineTransform(translationX: Self.snapshotInitialX * (1 - percent), y: 0)
        snapshotMaskView?.alpha = 1 - percent
    }

    func swipeEnded(velocityX: CGFloat) {
        guard swipeIsAvailable, snapshotView?.superview != nil else { return }
        let width = swipeContainerWidth
        let minX = systemController.view.frame.minX
        if width > 0 && minX > width / 4 && velocityX > 0 {
            completeSwipe(width: width, minX: minX)
        } else {
            swipeCancelled()
        }
    }

    private func completeSwipe(width: CGFloat, minX: CGFloat) {
        lockInteraction()
        let duration = 0.2 * TimeInterval((width - minX) / width)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.systemController.view.transform = CGAffineTransform(translationX: width, y: 0)
            self.snapshotView?.transform = .identity
            self.snapshotMaskView?.alpha = 0
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.dismissBySwipe = true
            // On top of the window: it hides the flicker while the search is leaving.
            if let snapshot = self.snapshotView, let window = self.delegateWindow ?? self.swipeWindow {
                snapshot.removeFromSuperview()
                window.addSubview(snapshot)
            }
            self.setActive(false, animated: false)
            self.systemController.view.transform = .identity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                guard let self else { return }
                self.cleanSnapshotObjects()
                self.dismissBySwipe = false
                self.unlockInteraction()
            }
        })
    }

    func swipeCancelled() {
        guard swipeIsAvailable || snapshotView?.superview != nil else { return }
        lockInteraction()
        let width = max(swipeContainerWidth, 1)
        let duration = 0.2 * TimeInterval(systemController.view.frame.minX / width)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.systemController.view.transform = .identity
            self.snapshotView?.transform = CGAffineTransform(translationX: Self.snapshotInitialX, y: 0)
            self.snapshotMaskView?.alpha = 1
        }, completion: { [weak self] _ in
            self?.unlockInteraction()
        })
    }

    private func lockInteraction() {
        lockedWindow?.isUserInteractionEnabled = true
        lockedWindow = delegateWindow ?? swipeWindow
        lockedWindow?.isUserInteractionEnabled = false
    }

    private func unlockInteraction() {
        lockedWindow?.isUserInteractionEnabled = true
        lockedWindow = nil
    }

    /**
     * Whether a swipe that starts on `touchedView` may begin: only a touch inside the search view (the gesture lives on
     * the window, so it would otherwise fire over a toast or a presented screen).
     */
    func swipeMayBegin(from touchedView: UIView?) -> Bool {
        guard let touchedView else { return false }
        return touchedView.isDescendant(of: systemController.view)
    }

    // MARK: - Presentation guard (issue 1541) and appearance forwarding

    private func attachGuardViewIfPossible() {
        guard let contents = contentsViewController, contents.isViewLoaded else { return }
        presentationGuard.attachView(to: contents.view)
    }

    /**
     * #1541: the contents view controller left every window while the search is presented (popped by
     * `popToRootViewController`, or its window's root replaced): the presentation and the contents hold each other, so
     * the search is dismissed without animation.
     */
    func dismissPresentationIfOrphaned() {
        guard let contents = contentsViewController,
              systemController.presentingViewController === contents,
              contents.presentedViewController === systemController,
              !isAlive(contents) else { return }
        contents.dismiss(animated: false)
    }

    /**
     * Whether the contents view controller is still part of a window's view controller hierarchy: one of its ancestors has a
     * view in a window, or the top of its ancestors is the root view controller of the window the guard was last in (a
     * full-screen modal over the root takes the root's view out of the window, but the contents are only covered).
     */
    private func isAlive(_ controller: UIViewController) -> Bool {
        var current: UIViewController? = controller
        var top = controller
        while let candidate = current {
            if candidate.isViewLoaded && candidate.view.window != nil { return true }
            top = candidate
            current = candidate.parent ?? candidate.presentingViewController
        }
        return presentationGuard.lastWindow?.rootViewController === top
    }

    func contentsAppearanceTransition(isAppearing: Bool, began: Bool, animated: Bool) {
        guard forwardsAppearanceFromContentsViewController else { return }
        if began {
            guard systemController.isActive else { return }
            if forwardedAppearancePending { systemController.endAppearanceTransition() }
            systemController.beginAppearanceTransition(isAppearing, animated: animated)
            forwardedAppearancePending = true
        } else if forwardedAppearancePending {
            systemController.endAppearanceTransition()
            forwardedAppearancePending = false
        }
    }
}

// MARK: - Gesture delegate

extension CYLSearchController: UIGestureRecognizerDelegate {

    /**
     * The swipe begins only when the touch is inside the search view.
     */
    @objc public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === swipeGestureRecognizer else { return true }
        let touched = gestureRecognizer.view?.hitTest(gestureRecognizer.location(in: gestureRecognizer.view), with: nil)
        return swipeMayBegin(from: touched)
    }
}

// MARK: - Results table view controller

/**
 * The results table: no automatic content inset (#1473) and the keyboard goes away on drag; it lays the empty view out
 * again.
 */
final class CYLSearchResultsTableViewController: UITableViewController {

    weak var owner: CYLSearchController?
    private(set) var lastLayoutSearchBarMaxY: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // A search bar used as a table header leaves a large blank above the results if UIKit adjusts the inset, and
        // the
        // inset jumps while the results push a screen whose navigation bar shows (#1473).
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.keyboardDismissMode = .onDrag
        owner?.resultsTableViewDidLoad(tableView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lastLayoutSearchBarMaxY = owner?.searchBarMaxY ?? 0
        fitInsetToSearchBar()
        if let owner, owner.isEmptyViewShowing { owner.layoutEmptyView() }
    }

    /**
     * The first row starts right under the search bar (a bar in a window), else below the safe area. UIKit's own top
     * inset leaves the first rows under the bar on iOS 27 once the automatic adjustment is off (#1473), so the inset is
     * set from the bar's bottom edge.
     */
    private func fitInsetToSearchBar() {
        guard let owner, let superview = view.superview else { return }
        let top: CGFloat
        if owner.searchBar.window != nil {
            let barBottom = owner.searchBar.convert(owner.searchBar.bounds, to: nil).maxY
            top = max(0, barBottom - superview.convert(view.frame.origin, to: nil).y)
        } else {
            // iOS 26 and later put the field of a navigation item's search bar at the bottom: the safe area is enough.
            top = view.safeAreaInsets.top
        }
        guard abs(tableView.contentInset.top - top) > 0.5 else { return }
        let wasAtTop = tableView.contentOffset.y <= -tableView.contentInset.top + 0.5
        tableView.contentInset.top = top
        tableView.verticalScrollIndicatorInsets.top = top
        if wasAtTop { tableView.contentOffset.y = -top }
    }
}

// MARK: - System search controller

/**
 * The `UISearchController` the wrapper owns: its search bar is a `CYLSearchBar`, and it hosts the launch view, the
 * dimming view and the layout fixes (QMUI's `UISearchController (QMUI)`).
 */
final class CYLSystemSearchController: UISearchController {

    let cylSearchBar = CYLSearchBar(frame: .zero)
    weak var owner: CYLSearchController?
    var prefersStatusBarHiddenProvider: (() -> Bool)?
    var preferredStatusBarStyleProvider: (() -> UIStatusBarStyle)?
    private(set) lazy var dimmingView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "CYLSearchDimmingView"
        view.isAccessibilityElement = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        view.addGestureRecognizer(tap)
        return view
    }()

    var launchView: UIView? {
        didSet {
            if oldValue !== launchView { oldValue?.removeFromSuperview() }
            updateObscuring()
            if isViewLoaded { addOverlaysIfNeeded() }
        }
    }

    var dimmingColor: UIColor? {
        didSet {
            updateObscuring()
            if dimmingColor == nil { dimmingView.removeFromSuperview() } else if isViewLoaded { addOverlaysIfNeeded() }
        }
    }

    override var searchBar: UISearchBar { cylSearchBar }

    override var showsSearchResultsController: Bool {
        didSet { updateObscuring() }
    }

    var hasStatusBarProviders: Bool {
        prefersStatusBarHiddenProvider != nil || preferredStatusBarStyleProvider != nil
    }

    // MARK: Obscuring

    /**
     * iOS 15 made the default NO; QMUI wants YES, except while an own view (launch view, dimming view) or the always
     * visible results take its place.
     */
    func updateObscuring() {
        let replaced = launchView != nil || showsSearchResultsController || dimmingColor != nil
        obscuresBackgroundDuringPresentation = !replaced
    }

    // MARK: Overlays

    private var overlayContainer: UIView? {
        searchResultsController?.view.superview ?? (isViewLoaded ? view : nil)
    }

    private var showsDimming: Bool {
        dimmingColor != nil && launchView == nil && !showsSearchResultsController && (cylSearchBar.text ?? "").isEmpty
    }

    func addOverlaysIfNeeded() {
        guard let container = overlayContainer else { return }
        if let launchView, launchView.superview !== container {
            container.insertSubview(launchView, at: 0)
        }
        if dimmingColor != nil, dimmingView.superview !== container {
            container.insertSubview(dimmingView, at: 0)
        }
        layoutOverlays()
    }

    func refreshOverlays() {
        guard isViewLoaded else { return }
        addOverlaysIfNeeded()
    }

    private func layoutOverlays() {
        guard isViewLoaded else { return }
        dimmingView.backgroundColor = dimmingColor
        dimmingView.isHidden = !showsDimming
        for overlay in [launchView, dimmingColor == nil ? nil : dimmingView] {
            guard let overlay, let container = overlay.superview else { continue }
            let top = container.convert(CGPoint(x: 0, y: searchBarMaxY), from: view).y
            let bounds = container.bounds
            let minY = max(bounds.minY, top)
            overlay.frame = CGRect(x: bounds.minX, y: minY, width: bounds.width, height: max(0, bounds.maxY - minY))
        }
    }

    @objc func dimmingViewTapped() {
        isActive = false
    }

    // MARK: Layout

    /**
     * The bottom edge of the search bar in this controller's view; 0 while the bar is not in the view.
     */
    var searchBarMaxY: CGFloat {
        guard isViewLoaded, cylSearchBar.isDescendant(of: view) else { return 0 }
        return cylSearchBar.convert(cylSearchBar.bounds, to: view).maxY
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addOverlaysIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Some paths (setActive(true, animated: false)) lay this view out without laying the results out: the results
        // would read a wrong searchBarMaxY.
        if let results = searchResultsController, results.isViewLoaded { results.view.setNeedsLayout() }
        if launchView != nil || dimmingColor != nil {
            UIView.animate(withDuration: CATransaction.animationDuration()) { self.layoutOverlays() }
        }
    }

    // MARK: Status bar

    override var prefersStatusBarHidden: Bool {
        prefersStatusBarHiddenProvider?() ?? super.prefersStatusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        preferredStatusBarStyleProvider?() ?? super.preferredStatusBarStyle
    }
}

// MARK: - Presentation guard

/**
 * An invisible child view controller of the contents view controller. It replaces two of QMUI's global swizzles: when
 * its view leaves the window it asks the wrapper to dismiss an orphaned search presentation (#1541, both paths), and it
 * passes the contents view controller's appearance transitions on to the active search controller.
 */
final class CYLSearchPresentationGuard: UIViewController {

    weak var owner: CYLSearchController?
    var isEnabled = true
    // The window the guard's view was last in: the contents' root is compared with its root view controller.
    private(set) weak var lastWindow: UIWindow?

    private final class GuardView: UIView {
        var onLeaveWindow: (() -> Void)?
        var onEnterWindow: ((UIWindow) -> Void)?

        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let window { onEnterWindow?(window) } else { onLeaveWindow?() }
        }
    }

    override func loadView() {
        let guardView = GuardView(frame: .zero)
        guardView.isUserInteractionEnabled = false
        guardView.isAccessibilityElement = false
        guardView.accessibilityElementsHidden = true
        guardView.accessibilityIdentifier = "CYLSearchPresentationGuard"
        guardView.onLeaveWindow = { [weak self] in self?.scheduleCheck() }
        guardView.onEnterWindow = { [weak self] window in self?.lastWindow = window }
        view = guardView
    }

    func attachView(to parentView: UIView) {
        if view.superview !== parentView { parentView.addSubview(view) }
    }

    func detach() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        if isViewLoaded { view.removeFromSuperview() }
        removeFromParent()
    }

    private func scheduleCheck() {
        guard isEnabled else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isEnabled else { return }
            self.owner?.dismissPresentationIfOrphaned()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        owner?.contentsAppearanceTransition(isAppearing: true, began: true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        owner?.contentsAppearanceTransition(isAppearing: true, began: false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        owner?.contentsAppearanceTransition(isAppearing: false, began: true, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        owner?.contentsAppearanceTransition(isAppearing: false, began: false, animated: animated)
        scheduleCheck()
    }
}
