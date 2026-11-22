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
        didSet { connectResultsTable() }
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

    private var resultHighlight = CYLSearchResultHighlight() {
        didSet {
            connectResultsTable()
            tableView?.reloadData()
        }
    }
    private let resultsDataSourceProxy = CYLSearchResultsDataSourceProxy()

    /**
     * Gives the first match of the search text in each row of the results table `resultMatchHighlightColor` (the tint
     * color by default), after `searchResultsDelegate` configured the row; the text label and a list content
     * configuration are both highlighted. While it is on, the table's `dataSource` is a forwarding proxy of
     * `searchResultsDelegate`. `CYLSearchView` has the same option. NO by default.
     */
    @objc public var highlightsResultMatches: Bool {
        get { resultHighlight.isEnabled }
        set { resultHighlight.isEnabled = newValue }
    }

    /**
     * The color of the highlighted match. Nil (the default) uses the tint color.
     */
    @objc public var resultMatchHighlightColor: UIColor? {
        get { resultHighlight.color }
        set { resultHighlight.color = newValue }
    }

    /**
     * A view shown while the text is empty, for example the recent searches; it fills the space under the search bar
     * (QMUI `launchView`). While it is set the system's obscuring of the background is off.
     */
    @objc public var launchView: UIView? {
        didSet { systemController.launchView = launchView }
    }

    /**
     * Whether the built-in launch view is `launchView`: the suggestion area of `CYLSearchView` (CollectionViewClassifyMenu's
     * tags folded to two rows with the fold control as the last tag, and, over the submitted queries of
     * `historyStore`, the title "Recent searches" with a clear button). It shows the history, newest first, or else
     * `suggestions`; it reads the history again whenever a query is submitted. A tapped tag becomes the query and is
     * submitted. Default `false`. Setting it to `true` replaces a custom `launchView`; setting a `launchView` of your own
     * turns it off.
     */
    @objc public var showsSuggestionsLaunchView: Bool {
        get { launchView === suggestionsLaunchView }
        set {
            if newValue {
                launchView = suggestionsLaunchView
            } else if launchView === suggestionsLaunchView {
                launchView = nil
            }
        }
    }

    /**
     * The tags of the built-in launch view while `historyStore` is empty or nil (see `showsSuggestionsLaunchView`). Empty
     * by default.
     */
    @objc public var suggestions: [String] = [] {
        didSet { suggestionsLaunchView.area.suggestions = suggestions }
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
    @objc public var isEmptyViewShowing: Bool { emptyViewSlot.isShowing }

    /**
     * Where the queries the person submits (the return key of the keyboard) are kept, newest first and without
     * duplicates; nil keeps none. The built-in store of `CYLSearchView` comes from `CYLSearchResources`, so the search
     * history is shared code, not a copy (the built-in launch view reads it).
     */
    @objc public var historyStore: CYLSearchSuggestionCache? {
        didSet { suggestionsLaunchView.area.cache = historyStore }
    }

    /**
     * Posted (object: this controller, `userInfo` key `"query"`) after a submitted query went into `historyStore`, so
     * a launch view that stays on screen can read the history again.
     */
    @objc public static let historyDidChangeNotification = Notification.Name("CYLSearchControllerHistoryDidChange")

    // MARK: Internal state

    let systemController: CYLSystemSearchController
    let presentationGuard = CYLSearchPresentationGuard()
    private lazy var suggestionsLaunchView: CYLSearchSuggestionsLaunchView = {
        let view = CYLSearchSuggestionsLaunchView()
        view.area.cache = historyStore
        view.area.suggestions = suggestions
        view.area.onSelect = { [weak self] _, title in self?.submitSuggestion(title) }
        return view
    }()
    private(set) weak var contentsViewController: UIViewController?
    private let emptyViewSlot = CYLSearchEmptyViewSlot()
    private lazy var keyboard = CYLSearchKeyboardOverlap(host: { [weak self] in self?.emptyViewSlot.view?.superview },
                                                         changed: { [weak self] in self?.layoutEmptyView() })
    var emptyView: UIView? { emptyViewSlot.view }
    // The active state, one implementation shared with `CYLSearchView`; it is fed by the `UISearchControllerDelegate`
    // callbacks below, because UIKit alone presents the wrapped controller.
    let presentationState = CYLSearchPresentationState()
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
        systemController.cylSearchBar.searchTextField.addTarget(self, action: #selector(searchFieldSubmitted(_:)),
                                                                 for: .primaryActionTriggered)
        resultsDataSourceProxy.decorate = { [weak self] cell in
            guard let self else { return }
            self.resultHighlight.apply(to: cell, query: self.searchBar.text ?? "")
        }
        _ = keyboard
        presentationState.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .willPresent: self.searchResultsDelegate?.willPresentSearchController?(self)
            case .didPresent: self.searchResultsDelegate?.didPresentSearchController?(self)
            case .willDismiss: self.searchResultsDelegate?.willDismissSearchController?(self)
            case .didDismiss: self.searchResultsDelegate?.didDismissSearchController?(self)
            }
        }
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

    // The return key of the keyboard (iOS 13 and later, public `UITextField` API): the query goes to the history store.
    @objc private func searchFieldSubmitted(_ field: UITextField) {
        recordSubmittedQuery(field.text ?? "")
    }

    // A tapped tag of the built-in launch view: it becomes the query (the results update) and is submitted like the
    // return key does.
    private func submitSuggestion(_ title: String) {
        searchBar.text = title
        recordSubmittedQuery(title)
        searchBar.searchTextField.resignFirstResponder()
    }

    private func recordSubmittedQuery(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        guard let historyStore else { return }
        historyStore.addQuery(query)
        CYLSearchSuggestionStore.announceChange(of: historyStore)
        NotificationCenter.default.post(name: Self.historyDidChangeNotification, object: self, userInfo: ["query": query])
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

    /**
     * Whether the search is presented (`CYLSearchView.searchOpen`); the same as `isActive`.
     */
    @objc(isSearchOpen) public var searchOpen: Bool { isActive }

    /**
     * Presents the search with animation (`CYLSearchView.showSearch(animated:)`); `setActive(true, animated:)`.
     */
    @objc(showSearchAnimated:)
    public func showSearch(animated: Bool) {
        setActive(true, animated: animated)
    }

    /**
     * Leaves the search (`CYLSearchView.closeSearch(animated:)`); `setActive(false, animated:)`.
     */
    @objc(closeSearchAnimated:)
    public func closeSearch(animated: Bool) {
        setActive(false, animated: animated)
    }

    // MARK: - Installing

    /**
     * Shows the search bar as the table view's header (QMUI `qmui_usedAsTableHeaderView`) and keeps the wrapper alive
     * as long as the table view lives. For QMUI issues #1160 and #1207 it also sets the table's estimated row, header and
     * footer heights to 0, adds the bottom inset the header needs to scroll out of sight above a short list, and settles
     * the header fully shown or fully hidden when a drag ends; the table view's delegate is not replaced (the drag is
     * seen through a target on its pan gesture recognizer). `snapsHeaderSearchBar` turns the inset and the settling off.
     */
    @objc public func installSearchBar(asHeaderOf tableView: UITableView) {
        searchBar.usedAsTableHeaderView = true
        searchBar.hostedInNavigationItem = false
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        objc_setAssociatedObject(tableView, &CYLSearchController.retainKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        headerSnapper?.detach()
        let snapper = CYLSearchHeaderSnapper(tableView: tableView, searchBar: searchBar, systemController: systemController)
        snapper.isEnabled = snapsHeaderSearchBar
        headerSnapper = snapper
        attachGuardViewIfPossible()
    }

    /**
     * Installs the system search controller on a navigation item (the wrapper itself is not a `UISearchController`,
     * #1229) and keeps the wrapper alive as long as the contents view controller lives.
     */
    @objc(installInNavigationItem:)
    public func install(in navigationItem: UINavigationItem) {
        searchBar.usedAsTableHeaderView = false
        searchBar.hostedInNavigationItem = true
        navigationItem.searchController = systemController
        // The wrapper is not retained by UIKit (the navigation item holds the system controller only): the contents view
        // controller keeps it, so that a caller who drops its own reference does not crash on the first search (#1229).
        objc_setAssociatedObject(contentsViewController ?? navigationItem, &CYLSearchController.retainKey, self,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        attachGuardViewIfPossible()
    }

    private static var retainKey = 0

    /**
     * Whether a header search bar (`installSearchBar(asHeaderOf:)`) is kept scrollable out of sight, even above a short
     * list, and settles fully shown or fully hidden when a drag ends (QMUI issues #1160 and #1207). Default `true`; turn it
     * off to keep UIKit's own behavior (the inset it added is taken out again).
     */
    @objc public var snapsHeaderSearchBar = true {
        didSet { headerSnapper?.isEnabled = snapsHeaderSearchBar }
    }

    private(set) var headerSnapper: CYLSearchHeaderSnapper?

    /**
     * Takes the bar out of `tableView`'s header and lets the table view go of the wrapper (`CYLSearchTableViewController`
     * does this when `showsSearchBar` is turned off).
     */
    func removeSearchBarHeader(from tableView: UITableView) {
        headerSnapper?.detach()
        headerSnapper = nil
        if tableView.tableHeaderView === searchBar { tableView.tableHeaderView = nil }
        objc_setAssociatedObject(tableView, &CYLSearchController.retainKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - Empty view

    /**
     * Shows CYLTableViewPlaceHolder's placeholder with a title, an optional detail and an optional button in the
     * results (QMUI `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`). Does nothing while the search text
     * is empty: the dimming view or the launch view is there then.
     */
    @objc public func showEmptyView(text: String?, detailText: String?, buttonTitle: String?,
                                    buttonAction: (() -> Void)?) {
        guard !(searchBar.text ?? "").isEmpty else { return }
        present(emptyView: CYLSearchEmptyView.message(text: text, detailText: detailText, buttonTitle: buttonTitle,
                                                      buttonAction: buttonAction))
    }

    /**
     * Shows one of CYLTableViewPlaceHolder's scenarios in the results (the same placeholder `CYLSearchView` shows for
     * empty results). Does nothing while the search text is empty.
     */
    @objc public func showEmptyView(scenario: CYLPlaceholderScenario) {
        guard !(searchBar.text ?? "").isEmpty else { return }
        present(emptyView: CYLSearchEmptyView.scenario(scenario))
    }

    /**
     * Removes the empty view (the search leaving always does).
     */
    @objc public func hideEmptyView() {
        emptyViewSlot.remove()
    }

    private func present(emptyView newView: UIView) {
        emptyViewSlot.adopt(newView)
        newView.backgroundColor = .systemBackground
        searchResultsDelegate?.searchController?(self, willShow: newView)
        guard let superview = searchResultsController?.view else { return }
        emptyViewSlot.show(in: superview)
        layoutEmptyView()
    }

    func layoutEmptyView() {
        guard let emptyView, let superview = emptyView.superview else { return }
        // Under the search bar (the bar never sits on a view) and above the keyboard.
        let bounds = superview.bounds
        let minY = systemController.topEdge(in: superview)
        emptyView.frame = CGRect(x: bounds.minX, y: minY, width: bounds.width,
                                 height: max(0, bounds.maxY - minY - keyboard.overlap))
        superview.bringSubviewToFront(emptyView)
    }

    // The results table takes the owner's data source and delegate (the data source behind a proxy while the match
    // highlight is on).
    private func connectResultsTable() {
        guard let table = tableView else { return }
        resultsDataSourceProxy.target = searchResultsDelegate
        table.dataSource = resultHighlight.isEnabled ? resultsDataSourceProxy : searchResultsDelegate
        table.delegate = searchResultsDelegate
    }

    func resultsTableViewDidLoad(_ tableView: UITableView) {
        connectResultsTable()
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
        presentationState.send(.willPresent)
    }

    /**
     * Tells the delegate.
     */
    @objc public func didPresentSearchController(_ searchController: UISearchController) {
        presentationState.send(.didPresent)
    }

    /**
     * Tells the delegate and removes the swipe snapshot unless the swipe is what dismisses the search.
     */
    @objc public func willDismissSearchController(_ searchController: UISearchController) {
        if systemController.hasStatusBarProviders { systemController.setNeedsStatusBarAppearanceUpdate() }
        presentationState.send(.willDismiss)
        // A swipe was begun and abandoned, then the Cancel button leaves the search: no snapshot may stay behind.
        if !dismissBySwipe { cleanSnapshotObjects() }
    }

    /**
     * Hides the empty view (leaving the search always does) and tells the delegate.
     */
    @objc public func didDismissSearchController(_ searchController: UISearchController) {
        hideEmptyView()
        headerSnapper?.refresh()
        presentationState.send(.didDismiss)
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
            gesture = CYLSearchEdgeSwipe.makeGesture(target: self, action: #selector(handleSwipe(_:)), delegate: self)
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
        if CYLSearchEdgeSwipe.completes(offset: minX, width: width, velocity: velocityX) {
            completeSwipe(width: width, minX: minX)
        } else {
            swipeCancelled()
        }
    }

    private func completeSwipe(width: CGFloat, minX: CGFloat) {
        lockInteraction()
        let duration = CYLSearchEdgeSwipe.duration(distance: width - minX, width: width)
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
        let duration = CYLSearchEdgeSwipe.duration(distance: systemController.view.frame.minX, width: swipeContainerWidth)
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

    /**
     * E21: a cancelled interactive pop (a slow drag from the left edge that comes back) while the search is presented
     * leaves the navigation bar showing the contents' title and back button over the pushed screen, a UIKit bug that
     * a plain `UISearchController` shows too. The navigation bar is put in step again once the cancelled pop ends.
     */
    func contentsWillAppear() {
        guard systemController.isActive, let contents = contentsViewController,
              let coordinator = contents.transitionCoordinator, coordinator.isInteractive else { return }
        coordinator.animate(alongsideTransition: nil) { [weak self] context in
            // The context is only valid inside this block.
            guard context.isCancelled else { return }
            DispatchQueue.main.async { self?.resynchronizeNavigationBar() }
        }
    }

    /**
     * Hides and shows the navigation bar again, without animation and keeping its hidden state, so that it draws the
     * items of the visible view controller (public API only). Does nothing while the search is not presented.
     */
    func resynchronizeNavigationBar() {
        guard systemController.isActive, let navigation = contentsViewController?.navigationController else { return }
        let hidden = navigation.isNavigationBarHidden
        navigation.setNavigationBarHidden(!hidden, animated: false)
        navigation.setNavigationBarHidden(hidden, animated: false)
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
    private(set) lazy var dimmingView: CYLSearchDimmingView = {
        let view = CYLSearchDimmingView()
        view.onTap = { [weak self] in self?.dimmingViewTapped() }
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
        dimmingView.color = dimmingColor
        dimmingView.isHidden = !showsDimming
        for overlay in [launchView, dimmingColor == nil ? nil : dimmingView] {
            guard let overlay, let container = overlay.superview else { continue }
            let bounds = container.bounds
            let minY = topEdge(in: container)
            overlay.frame = CGRect(x: bounds.minX, y: minY, width: bounds.width, height: max(0, bounds.maxY - minY))
        }
    }

    /**
     * The top edge, in `container`'s coordinates, below which own views (the launch view, the dimming view, the empty view)
     * may sit: under the search bar when it lives in this controller's view, and under the safe area otherwise (a bar in a
     * navigation item stays in the navigation bar, which the presentation reaches under).
     */
    func topEdge(in container: UIView) -> CGFloat {
        let bounds = container.bounds
        let barBottom = container.convert(CGPoint(x: 0, y: searchBarMaxY), from: view).y
        return max(bounds.minY, barBottom, bounds.minY + container.safeAreaInsets.top)
    }

    // A tap on the dimming view leaves the search, through the wrapper, as `CYLSearchView`'s scrim does.
    @objc func dimmingViewTapped() {
        if let owner { owner.setActive(false, animated: true) } else { isActive = false }
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
        owner?.contentsWillAppear()
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
