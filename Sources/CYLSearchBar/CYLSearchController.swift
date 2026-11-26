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
//  QMthe system search controller as a view controller over the core's search field (`CYLSearchBarView`): no the system search controller and no
//  the system search bar. The field sits where the owner puts it (a table header or a navigation item); while the search is active an
//  own page (dimming view, launch view, results view controller, empty view) covers the contents below the field, the Cancel
//  button shows, and leaving removes the page again. docs/no-system-searchbar.md, docs/qmui-search-controller.md.
//

import CYLDeallocBlockExecutor
import CYLTableViewPlaceHolder
import ObjectiveC
import UIKit

// MARK: - Delegate

/**
 * What a `CYLSearchController` asks of its owner (QMUI `QMthe system search controllerDelegate`): the search results (called on
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
 * A search over `contentsViewController`: the core's search field `searchBar` (`CYLSearchBarView`), and, while the search is
 * active, a page below the field with the launch view (recent searches or suggestions) while the text is empty, the results
 * view controller (a table view driven by `searchResultsDelegate`) while there is text, and an empty view. The owner keeps
 * this controller (the contents view controller keeps it when it is installed with `install(in:)` or as a table header).
 */
@objc(CYLSearchController)
open class CYLSearchController: UIViewController, CYLSearchBarViewDelegate {

    // MARK: Public properties

    /**
     * The owner of the results: its data source and delegate drive the results table view, and it is told about the
     * text and the life cycle. Held weakly.
     */
    @objc public weak var searchResultsDelegate: CYLSearchControllerDelegate? {
        didSet { connectResultsTable() }
    }

    /**
     * The view controller that shows the results: a table view controller unless the controller was created with
     * `init(contentsViewController:resultsViewController:)`.
     */
    @objc public let searchResultsController: UIViewController

    /**
     * The search field, the core's `CYLSearchBarView`; use it as a table header or in a navigation item.
     */
    @objc public let searchBar = CYLSearchBarView(frame: .zero)

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
     * color by default), after `searchResultsDelegate` configured the row. While it is on, the table's `dataSource` is a
     * forwarding proxy of `searchResultsDelegate`. `CYLSearchView` has the same option. NO by default.
     */
    @objc public var highlightsResultMatches: Bool {
        get { resultHighlight.isEnabled }
        set { resultHighlight.isEnabled = newValue }
    }

    /**
     * The color of the highlighted match; nil uses the tint color.
     */
    @objc public var resultMatchHighlightColor: UIColor? {
        get { resultHighlight.color }
        set { resultHighlight.color = newValue }
    }

    /**
     * A view shown over the contents below the field while the search is active and the text is empty (QMUI
     * `launchView`); nil shows none.
     */
    @objc public var launchView: UIView? {
        didSet {
            if oldValue !== launchView { oldValue?.removeFromSuperview() }
            if isActive { refreshPage() }
        }
    }

    /**
     * Whether `launchView` is the built-in one (the recent searches of `historyStore`, else `suggestions`, as tags).
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
     * The suggestions of the built-in launch view.
     */
    @objc public var suggestions: [String] = [] {
        didSet { suggestionsLaunchView.area.suggestions = suggestions }
    }

    /**
     * The color of a dimming view over the contents while the search is active and the text is empty (no launch view);
     * a tap on it leaves the search. nil shows none.
     */
    @objc public var dimmingColor: UIColor? {
        didSet {
            dimmingView.color = dimmingColor
            if dimmingColor == nil { dimmingView.removeFromSuperview() }
            if isActive { refreshPage() }
        }
    }

    /**
     * Whether the search is active; setting it does not animate.
     */
    @objc public var isActive: Bool {
        @objc(isActive) get { presentationState.isActive }
        @objc(setActive:) set { setActive(newValue, animated: false) }
    }

    /**
     * Shows the results view controller even while the text is empty (QMUI `qmui_alwaysShowsSearchResultsController`); the
     * launch view is dropped.
     */
    @objc public var alwaysShowsSearchResultsController = false {
        didSet {
            if alwaysShowsSearchResultsController { launchView = nil }
            if isActive { refreshPage() }
        }
    }

    /**
     * Whether a swipe from the left screen edge leaves the search while it is active. NO by default.
     */
    @objc public var supportsSwipeToDismissSearch = false {
        didSet { swipeGestureRecognizer?.isEnabled = supportsSwipeToDismissSearch }
    }

    /**
     * The recognizer of the swipe; nil until the search was first active with `supportsSwipeToDismissSearch`.
     */
    @objc public private(set) var swipeGestureRecognizer: UIScreenEdgePanGestureRecognizer?

    /**
     * The bottom edge of the search field in the coordinates of its window; 0 while it is not in a window.
     */
    @objc public var searchBarMaxY: CGFloat {
        guard searchBar.window != nil else { return 0 }
        return searchBar.convert(searchBar.bounds, to: nil).maxY
    }

    /**
     * Whether an empty view is showing.
     */
    @objc public var isEmptyViewShowing: Bool { emptyViewSlot.isShowing }

    /**
     * The text of the empty view `CYLSearchController` shows by itself when the text is not empty and the results table
     * has no row; nil shows none.
     */
    @objc public var noResultsText: String?

    private func updateNoResultsEmptyView(for text: String) {
        guard let noResultsText else { return }
        let rowCount = tableView.map { table in
            (0..<table.numberOfSections).reduce(0) { $0 + table.numberOfRows(inSection: $1) }
        } ?? 0
        if !text.isEmpty && rowCount == 0 {
            showEmptyView(text: noResultsText, detailText: nil, buttonTitle: nil, buttonAction: nil)
        } else {
            hideEmptyView()
        }
    }

    /**
     * The history of submitted queries the built-in launch view shows; a return key or a tapped tag submits.
     */
    @objc public var historyStore: CYLSearchSuggestionCache? {
        didSet { suggestionsLaunchView.area.cache = historyStore }
    }

    /**
     * Posted when a submitted query is added to `historyStore`; `userInfo["query"]` is the query.
     */
    @objc public static let historyDidChangeNotification = Notification.Name("CYLSearchControllerHistoryDidChange")

    // MARK: Internal state

    private(set) weak var contentsViewController: UIViewController?
    private let pageView = UIView()
    lazy var dimmingView: CYLSearchDimmingView = {
        let view = CYLSearchDimmingView()
        view.onTap = { [weak self] in self?.setActive(false, animated: true) }
        return view
    }()
    private lazy var suggestionsLaunchView: CYLSearchSuggestionsLaunchView = {
        let view = CYLSearchSuggestionsLaunchView()
        view.area.cache = historyStore
        view.area.suggestions = suggestions
        view.area.onSelect = { [weak self] _, title in self?.submitSuggestion(title) }
        return view
    }()
    private let emptyViewSlot = CYLSearchEmptyViewSlot()
    private lazy var keyboard = CYLSearchKeyboardOverlap(host: { [weak self] in self?.pageView }, changed: { [weak self] in self?.layoutPage() })
    var emptyView: UIView? { emptyViewSlot.view }
    // The page over the contents while the search is active (nil otherwise): what the covering tests check against.
    var activePageView: UIView? { pageView.superview != nil && !pageView.isHidden ? pageView : nil }
    let presentationState = CYLSearchPresentationState()
    private(set) var headerSnapper: CYLSearchHeaderSnapper?
    private weak var hostTableView: UITableView?
    private var savedScrollEnabled = true
    private weak var swipeHost: UIView?
    private static var retainKey = 0
    private static let leaveOnDisappearKey = "CYLSearchControllerLeaveOnDisappear"

    // MARK: - Initializers

    /**
     * Creates a search controller for `contentsViewController` that shows its results in `resultsViewController` (QMUI
     * `initWithContentsViewController:resultsViewController:`).
     */
    @objc public init(contentsViewController: UIViewController, resultsViewController: UIViewController) {
        searchResultsController = resultsViewController
        self.contentsViewController = contentsViewController
        super.init(nibName: nil, bundle: nil)
        contentsViewController.definesPresentationContext = true
        searchBar.applyNavigationFieldStyle()
        searchBar.placeholder = CYLSearchBarAppearance.defaultCopy().placeholder
        searchBar.delegate = self
        searchBar.textAssignedHandler = { [weak self] in
            guard let self else { return }
            self.textChanged(self.searchBar.text ?? "")
        }
        searchBar.returnKeyType = .search
        searchBar.textField.addTarget(self, action: #selector(searchFieldSubmitted(_:)), for: .primaryActionTriggered)
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
        pageView.backgroundColor = .clear
        pageView.isHidden = true
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

    // The return key of the keyboard: the query goes to the history store.
    @objc private func searchFieldSubmitted(_ field: UITextField) {
        recordSubmittedQuery(field.text ?? "")
    }

    // A tapped tag of the built-in launch view: it becomes the query and is submitted like the return key does.
    private func submitSuggestion(_ title: String) {
        searchBar.text = title
        recordSubmittedQuery(title)
        searchBar.hideKeyboard()
    }

    private func recordSubmittedQuery(_ text: String) {
        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        guard let historyStore else { return }
        historyStore.addQuery(query)
        CYLSearchSuggestionStore.announceChange(of: historyStore)
        NotificationCenter.default.post(name: Self.historyDidChangeNotification, object: self, userInfo: ["query": query])
    }

    // MARK: - Activation

    /**
     * Enters or leaves the search (QMUI `setActive:animated:`).
     */
    @objc public func setActive(_ active: Bool, animated: Bool) {
        if active { activate(animated: animated) } else { deactivate(animated: animated) }
    }

    /**
     * Whether the search is active (`CYLSearchView.searchOpen`); the same as `isActive`.
     */
    @objc(isSearchOpen) public var searchOpen: Bool { isActive }

    /**
     * Starts the search with animation (`CYLSearchView.showSearch(animated:)`); `setActive(true, animated:)`.
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

    private var hostView: UIView? {
        if let navigation = contentsViewController?.navigationController, navigation.viewIfLoaded?.window != nil {
            return navigation.view
        }
        return contentsViewController?.viewIfLoaded?.window ?? contentsViewController?.viewIfLoaded
    }

    private func activate(animated: Bool) {
        guard !presentationState.isActive, let host = hostView else { return }
        presentationState.send(.willPresent)
        if pageView.superview !== host {
            host.addSubview(pageView)
        }
        host.bringSubviewToFront(pageView)
        if let table = headerTable() {
            // The field stays at the top of its table while the search is active: the table does not scroll.
            hostTableView = table
            savedScrollEnabled = table.isScrollEnabled
            table.setContentOffset(CGPoint(x: 0, y: -table.adjustedContentInset.top), animated: false)
            table.isScrollEnabled = false
        }
        installResultsViewController()
        searchBar.setShowsCancelButton(true, animated: animated)
        pageView.isHidden = false
        refreshPage()
        installSwipe(in: host)
        leaveWhenContentsLeave()
        if animated {
            pageView.alpha = 0
            UIView.animate(withDuration: 0.25, animations: { self.pageView.alpha = 1 }, completion: { _ in
                self.presentationState.send(.didPresent)
            })
        } else {
            pageView.alpha = 1
            presentationState.send(.didPresent)
        }
        if !searchBar.textField.isFirstResponder { searchBar.showKeyboard() }
        searchResultsDelegate?.searchController(self, updateResultsFor: searchBar.text ?? "")
    }

    private func deactivate(animated: Bool) {
        guard presentationState.isActive else { return }
        presentationState.send(.willDismiss)
        searchBar.hideKeyboard()
        searchBar.setShowsCancelButton(false, animated: animated)
        let finish = { [weak self] in
            guard let self else { return }
            self.pageView.isHidden = true
            self.pageView.alpha = 1
            self.pageView.transform = .identity
            self.hideEmptyView()
            self.hostTableView?.isScrollEnabled = self.savedScrollEnabled
            self.hostTableView = nil
            self.headerSnapper?.refresh()
            self.removePage()
            self.presentationState.send(.didDismiss)
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: { self.pageView.alpha = 0 }, completion: { _ in finish() })
        } else {
            finish()
        }
    }

    // The contents page leaves for good (it or a parent is popped or dismissed): the search ends, so its page does not stay on
    // the navigation controller's view or the window (handover bug I1). A push from the contents keeps the search.
    private func leaveWhenContentsLeave() {
        contentsViewController?.cylAddLifecycleCallback(for: .viewDidDisappear, key: Self.leaveOnDisappearKey) { [weak self] contents, _, _ in
            var current: UIViewController? = contents
            while let controller = current {
                if controller.isMovingFromParent || controller.isBeingDismissed {
                    self?.setActive(false, animated: false)
                    return
                }
                current = controller.parent
            }
        }
    }

    // Takes the page and the swipe recognizer out of the host and stops watching the contents page.
    private func removePage() {
        pageView.removeFromSuperview()
        if let gesture = swipeGestureRecognizer { gesture.view?.removeGestureRecognizer(gesture) }
        swipeHost = nil
        contentsViewController?.cylCancelLifecycleCallback(key: Self.leaveOnDisappearKey)
    }

    deinit {
        pageView.removeFromSuperview()
        if let gesture = swipeGestureRecognizer { gesture.view?.removeGestureRecognizer(gesture) }
    }

    private func headerTable() -> UITableView? {
        var view: UIView? = searchBar.superview
        while let current = view {
            if let table = current as? UITableView, table.tableHeaderView === searchBar || searchBar.isDescendant(of: table.tableHeaderView ?? UIView()) { return table }
            view = current.superview
        }
        return nil
    }

    // The results view is a subview of the page; the results view controller is not a child of any view controller (the
    // page lives in the navigation controller's view or the window, so UIKit would find a different parent).
    private func installResultsViewController() {
        let results = searchResultsController
        if results.view.superview !== pageView { pageView.addSubview(results.view) }
    }

    // MARK: - Page

    // The page shows: the launch view (or the dimming view) while the text is empty, the results otherwise.
    private func refreshPage() {
        guard presentationState.isActive else { return }
        let empty = (searchBar.text ?? "").isEmpty
        let resultsVisible = !empty || alwaysShowsSearchResultsController
        let results = searchResultsController.view
        results?.isHidden = !resultsVisible
        if let launchView, launchView.superview !== pageView { pageView.insertSubview(launchView, at: 0) }
        launchView?.isHidden = resultsVisible
        if dimmingColor != nil, dimmingView.superview !== pageView { pageView.insertSubview(dimmingView, at: 0) }
        dimmingView.color = dimmingColor
        dimmingView.isHidden = !(dimmingColor != nil && launchView == nil && !resultsVisible)
        layoutPage()
    }

    func layoutPage() {
        guard let host = pageView.superview, presentationState.isActive else { return }
        let bounds = host.bounds
        let minY = topEdge(in: host)
        let overlap = keyboard.overlap
        pageView.frame = CGRect(x: bounds.minX, y: minY, width: bounds.width, height: max(0, bounds.maxY - minY))
        let local = pageView.bounds
        let visible = CGRect(x: local.minX, y: local.minY, width: local.width, height: max(0, local.height - overlap))
        for subview in [launchView, dimmingView, searchResultsController.view] {
            subview?.frame = local
        }
        searchResultsController.view.frame = local
        if let table = tableView {
            var insets = table.contentInset
            insets.bottom = max(overlap, host.safeAreaInsets.bottom)
            table.contentInset = insets
            table.verticalScrollIndicatorInsets = insets
        }
        if let emptyView = emptyViewSlot.view, emptyView.superview != nil { emptyView.frame = visible }
    }

    // The top of the page: the bottom edge of the field (the field never sits on the page).
    func topEdge(in container: UIView) -> CGFloat {
        guard searchBar.window != nil else { return container.bounds.minY + container.safeAreaInsets.top }
        let bottom = container.convert(searchBar.bounds, from: searchBar).maxY
        return max(container.bounds.minY, bottom)
    }

    func layoutEmptyView() {
        layoutPage()
    }

    // MARK: - Installing

    /**
     * Shows the search field as the table view's header (QMUI `qmui_usedAsTableHeaderView`) and keeps this controller alive
     * as long as the table view lives. It also sets the table's estimated row, header and footer heights to 0, adds the
     * bottom inset the header needs to scroll out of sight above a short list, and settles the header fully shown or
     * fully hidden when a drag ends; the table view's delegate is not replaced.
     */
    @objc public func installSearchBar(asHeaderOf tableView: UITableView) {
        searchBar.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: searchBar.intrinsicContentSize.height)
        searchBar.autoresizingMask = [.flexibleWidth]
        tableView.tableHeaderView = searchBar
        objc_setAssociatedObject(tableView, &CYLSearchController.retainKey, self, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        headerSnapper?.detach()
        let snapper = CYLSearchHeaderSnapper(tableView: tableView, searchBar: searchBar) { [weak self] in
            self?.isActive == true
        }
        snapper.isEnabled = snapsHeaderSearchBar
        headerSnapper = snapper
    }

    /**
     * Puts the search field into `navigationItem` as its title view (`embedInNavigationBar(of:)` of the core), and keeps this
     * controller alive with the contents view controller (a caller who drops its own reference does not crash on the
     * first search, #1229).
     */
    @objc(installInNavigationItem:)
    public func install(in navigationItem: UINavigationItem) {
        searchBar.fieldHeight = 36
        searchBar.contentInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        searchBar.isEmbeddedInNavigationBar = true
        navigationItem.titleView = searchBar
        objc_setAssociatedObject(contentsViewController ?? navigationItem, &CYLSearchController.retainKey, self,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    /**
     * Whether a header search field settles fully shown or fully hidden when a drag ends. YES by default.
     */
    @objc public var snapsHeaderSearchBar = true {
        didSet { headerSnapper?.isEnabled = snapsHeaderSearchBar }
    }

    func removeSearchBarHeader(from tableView: UITableView) {
        headerSnapper?.detach()
        headerSnapper = nil
        if tableView.tableHeaderView === searchBar { tableView.tableHeaderView = nil }
        objc_setAssociatedObject(tableView, &CYLSearchController.retainKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    // MARK: - Empty view

    /**
     * Shows an empty view with a text, a detail text and a button over the results (QMUI
     * `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`); nothing happens while the text is empty.
     */
    @objc public func showEmptyView(text: String?, detailText: String?, buttonTitle: String?,
                                    buttonAction: (() -> Void)?) {
        guard !(searchBar.text ?? "").isEmpty else { return }
        present(emptyView: CYLSearchEmptyView.message(text: text, detailText: detailText, buttonTitle: buttonTitle,
                                                      buttonAction: buttonAction))
    }

    /**
     * Shows one of CYLTableViewPlaceHolder's scenarios over the results; nothing happens while the text is empty.
     */
    @objc public func showEmptyView(scenario: CYLPlaceholderScenario) {
        guard !(searchBar.text ?? "").isEmpty else { return }
        present(emptyView: CYLSearchEmptyView.scenario(scenario))
    }

    /**
     * Removes the empty view.
     */
    @objc public func hideEmptyView() {
        emptyViewSlot.remove()
    }

    private func present(emptyView newView: UIView) {
        emptyViewSlot.adopt(newView)
        newView.backgroundColor = .systemBackground
        searchResultsDelegate?.searchController?(self, willShow: newView)
        emptyViewSlot.show(in: pageView)
        layoutPage()
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

    // MARK: - CYLSearchBarViewDelegate

    /**
     * The field began editing: the search becomes active.
     */
    public func searchBarViewDidBeginEditing(_ searchBarView: CYLSearchBarView) {
        setActive(true, animated: true)
    }

    /**
     * The text changed: the results update.
     */
    public func searchBarView(_ searchBarView: CYLSearchBarView, textDidChange text: String) {
        textChanged(text)
    }

    /**
     * Cancel was tapped: the search ends.
     */
    public func searchBarViewCancelButtonClicked(_ searchBarView: CYLSearchBarView) {
        setActive(false, animated: true)
    }

    private func textChanged(_ text: String) {
        refreshPage()
        searchResultsDelegate?.searchController(self, updateResultsFor: text)
        updateNoResultsEmptyView(for: text)
    }

    // MARK: - Swipe to dismiss

    private func installSwipe(in host: UIView) {
        guard supportsSwipeToDismissSearch else { return }
        let gesture: UIScreenEdgePanGestureRecognizer
        if let existing = swipeGestureRecognizer {
            gesture = existing
        } else {
            gesture = CYLSearchEdgeSwipe.makeGesture(target: self, action: #selector(handleSwipe(_:)), delegate: self)
            swipeGestureRecognizer = gesture
        }
        gesture.isEnabled = true
        if gesture.view !== host { host.addGestureRecognizer(gesture) }
        swipeHost = host
    }

    @objc private func handleSwipe(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard presentationState.isActive, let host = swipeHost else { return }
        switch gesture.state {
        case .began:
            searchBar.hideKeyboard()
        case .changed:
            pageView.transform = CGAffineTransform(translationX: min(max(0, gesture.translation(in: host).x), host.bounds.width), y: 0)
        case .ended:
            let width = host.bounds.width
            let offset = pageView.transform.tx
            if CYLSearchEdgeSwipe.completes(offset: offset, width: width, velocity: gesture.velocity(in: host).x) {
                UIView.animate(withDuration: CYLSearchEdgeSwipe.duration(distance: width - offset, width: width), delay: 0,
                               options: .curveEaseInOut, animations: {
                    self.pageView.transform = CGAffineTransform(translationX: width, y: 0)
                }, completion: { _ in self.setActive(false, animated: false) })
            } else {
                resetSwipe()
            }
        case .cancelled, .failed:
            resetSwipe()
        default:
            break
        }
    }

    private func resetSwipe() {
        UIView.animate(withDuration: 0.2) { self.pageView.transform = .identity }
    }
}

extension CYLSearchController: UIGestureRecognizerDelegate {

    /**
     * The swipe begins only while the search is active.
     */
    @objc public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer !== swipeGestureRecognizer || presentationState.isActive
    }

    /**
     * The navigation controller's pop gestures wait for the search swipe to fail.
     */
    @objc public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === swipeGestureRecognizer,
              let navigation = contentsViewController?.navigationController else { return false }
        if otherGestureRecognizer === navigation.interactivePopGestureRecognizer { return true }
        if #available(iOS 26.0, *), otherGestureRecognizer === navigation.interactiveContentPopGestureRecognizer { return true }
        return false
    }
}

// MARK: - Results table view controller

/**
 * The table view controller the search controller creates for its results.
 */
final class CYLSearchResultsTableViewController: UITableViewController {

    weak var owner: CYLSearchController?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.keyboardDismissMode = .onDrag
        owner?.resultsTableViewDidLoad(tableView)
    }
}
