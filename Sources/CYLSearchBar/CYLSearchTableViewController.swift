/**
 * Tencent is pleased to support the open source community by making QMUI_iOS available.
 * Copyright (C) 2016-2021 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */


// Ported to Swift for CYLSearchViewController, 2026.
//
//  CYLSearchTableViewController.swift
//  CYLSearchViewController
//
//  QMUICommonTableViewController (Search) of QMUISearchController.m as a UITableViewController subclass: showsSearchBar,
//  searchController, searchBar, hidesSearchBarWhenEmptyViewShowing, clearing the results' selection, the empty view that
//  takes the header away and puts it back (issue #128). QMUI extends its table view controller by swizzling in +load; here
//  the class is its own base class. docs/qmui-search-controller.md, "Public API" and phase 3.
//

import CYLTableViewPlaceHolder
import UIKit

/**
 * A table view controller that can show a `CYLSearchBar` as its table header, with the `CYLSearchController` that drives
 * it (QMUI's `QMUICommonTableViewController (Search)`). Set `showsSearchBar`; configure the bar in `setUpSearchBar()`;
 * override `searchController(_:updateResultsFor:)` and the table view data source methods (the results table view uses the
 * same data source and delegate: tell the two tables apart by `tableView === self.tableView`).
 */
@objc(CYLSearchTableViewController)
open class CYLSearchTableViewController: UITableViewController, CYLSearchControllerDelegate {

    // MARK: - Public properties

    /**
     * Whether the search bar is shown as the table header (QMUI `shouldShowSearchBar`, default `false`). The controller and
     * the bar are created, or removed, once the view is loaded: a value set before `viewDidLoad` takes effect in
     * `viewDidLoad`. Turning it off removes the header, the bar and the controller (`searchController` and `searchBar` are
     * `nil` again).
     */
    @objc public var showsSearchBar = false {
        didSet {
            guard showsSearchBar != oldValue else { return }
            if showsSearchBar { installSearchController() } else { removeSearchController() }
        }
    }

    /**
     * The search controller, `nil` while `showsSearchBar` is off or the view is not loaded (QMUI `searchController`).
     */
    @objc public private(set) var searchController: CYLSearchController?

    /**
     * The search bar that is the table header, `nil` while `showsSearchBar` is off or the view is not loaded (QMUI
     * `searchBar`).
     */
    @objc public private(set) var searchBar: CYLSearchBar?

    /**
     * Whether the search bar leaves the table header while an empty view shows and returns when it is hidden (QMUI
     * `shouldHideSearchBarWhenEmptyViewShowing`, default `false`).
     */
    @objc public var hidesSearchBarWhenEmptyViewShowing = false

    /**
     * Whether the table is scrolled so that the search bar is out of sight when it is first shown (QMUI
     * `shouldHideTableHeaderViewInitial`, default `false`), and again each time the bar returns after an empty view.
     */
    @objc public var hidesSearchBarInitially = false

    /**
     * Whether the empty view is on screen.
     */
    @objc public var isEmptyViewShowing: Bool { emptyViewSlot.isShowing }

    // MARK: - Private state

    private let emptyViewSlot = CYLSearchEmptyViewSlot()
    private var hasHiddenSearchBarInitially = false

    // MARK: - View life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        installSearchController()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The results table is the one that opened a screen from a result: its selection goes when the screen returns.
        guard let results = searchController?.searchResultsController, results.isViewLoaded,
              let table = searchController?.tableView, !table.allowsMultipleSelection else { return }
        for indexPath in table.indexPathsForSelectedRows ?? [] { table.deselectRow(at: indexPath, animated: animated) }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideSearchBarInitiallyIfNeeded(force: false)
        layoutEmptyView()
    }

    // MARK: - Search controller

    /**
     * Called once after the search controller and the bar are created and before the bar becomes the table header: set
     * the bar's style, margins and accessory views here (QMUI `initSearchController`, which subclasses extend).
     */
    @objc open func setUpSearchBar() {}

    /**
     * Called with every text change of the search, also with "" (QMUI `searchController:updateResultsForSearchString:`);
     * does nothing by default.
     */
    @objc(searchController:updateResultsForSearchString:)
    open func searchController(_ searchController: CYLSearchController, updateResultsFor searchString: String) {}

    private func installSearchController() {
        guard isViewLoaded, showsSearchBar, searchController == nil else { return }
        let controller = CYLSearchController(contentsViewController: self, resultsTableViewStyle: tableView.style)
        controller.searchResultsDelegate = self
        searchController = controller
        searchBar = controller.searchBar
        setUpSearchBar()
        controller.installSearchBar(asHeaderOf: tableView)
    }

    private func removeSearchController() {
        guard let controller = searchController else { return }
        controller.removeSearchBarHeader(from: tableView)
        controller.searchBar.removeFromSuperview()
        controller.searchResultsDelegate = nil
        searchBar = nil
        searchController = nil
    }

    // MARK: - Hidden initially

    /**
     * Scrolls the table so that the header is out of sight (QMUI `hideTableHeaderViewInitialIfCanWithAnimated:force:`).
     * Returning from an empty view needs `force`: setting the header again undid the first hiding (issue #128).
     */
    private func hideSearchBarInitiallyIfNeeded(force: Bool, animated: Bool = false) {
        guard hidesSearchBarInitially, let header = tableView.tableHeaderView, header === searchBar,
              force || !hasHiddenSearchBarInitially, header.bounds.height > 0 else { return }
        hasHiddenSearchBarInitially = true
        let offset = CGPoint(x: tableView.contentOffset.x,
                             y: -tableView.adjustedContentInset.top + header.frame.height)
        tableView.setContentOffset(offset, animated: animated)
    }

    // MARK: - Empty view

    /**
     * Shows CYLTableViewPlaceHolder's placeholder with a title and an optional detail over the table (QMUI
     * `showEmptyViewWithText:detailText:buttonTitle:buttonAction:`, without the button). With
     * `hidesSearchBarWhenEmptyViewShowing` the search bar leaves the header.
     */
    @objc public func showEmptyView(text: String?, detailText: String?) {
        present(emptyView: CYLSearchEmptyView.message(text: text, detailText: detailText))
    }

    /**
     * Shows one of CYLTableViewPlaceHolder's scenarios over the table (the placeholder `CYLSearchView` shows for empty
     * results).
     */
    @objc public func showEmptyView(scenario: CYLPlaceholderScenario) {
        present(emptyView: CYLSearchEmptyView.scenario(scenario))
    }

    /**
     * Removes the empty view; with `hidesSearchBarWhenEmptyViewShowing` the search bar returns to the header, hidden
     * again if `hidesSearchBarInitially` is on (issue #128).
     */
    @objc public func hideEmptyView() {
        emptyViewSlot.remove()
        if showsSearchBar, hidesSearchBarWhenEmptyViewShowing, tableView.tableHeaderView == nil {
            installSearchController()
            tableView.tableHeaderView = searchBar
            searchController?.headerSnapper?.refresh()
            hideSearchBarInitiallyIfNeeded(force: true)
        }
    }

    private func present(emptyView newView: UIView) {
        emptyViewSlot.adopt(newView)
        newView.backgroundColor = .systemBackground
        emptyViewSlot.show(in: tableView)
        if hidesSearchBarWhenEmptyViewShowing, let bar = searchBar, tableView.tableHeaderView === bar {
            tableView.tableHeaderView = nil
            searchController?.headerSnapper?.refresh()
        }
        layoutEmptyView()
    }

    private func layoutEmptyView() {
        guard let emptyView = emptyViewSlot.view, emptyView.superview === tableView else { return }
        // Under the header, over the rows: the empty view fills what the table shows below the search bar.
        let top = tableView.tableHeaderView?.frame.maxY ?? 0
        let inset = tableView.adjustedContentInset
        let height = max(0, tableView.bounds.height - inset.top - inset.bottom - top)
        emptyView.frame = CGRect(x: 0, y: top, width: tableView.bounds.width, height: height)
        tableView.bringSubviewToFront(emptyView)
    }
}
