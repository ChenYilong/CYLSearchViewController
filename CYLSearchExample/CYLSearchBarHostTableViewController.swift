//
//  CYLSearchBarHostTableViewController.swift
//  CYLSearchExample
//
//  A table view controller with a `CYLSearchBar` as its table header, the shape of QMUI's
//  QMUICommonTableViewController (Search): `showsSearchBar`, `searchBar`, and a hook to set the bar up. Phase 3 of
//  docs/qmui-search-controller.md swaps this base class for the core's `CYLSearchTableViewController`, which has the same
//  names, and the screens built on it keep working.
//

import CYLSearchViewController
import UIKit

/**
 * A plain table view controller that shows its `searchBar` as the table header. Subclasses configure the bar in
 * `setUpSearchBar()`.
 */
@objc(CYLSearchBarHostTableViewController)
open class CYLSearchBarHostTableViewController: UITableViewController {

    /**
     * The bar shown as the table header.
     */
    @objc public let searchBar = CYLSearchBar(frame: .zero)

    /**
     * Whether the bar is shown (QMUI `shouldShowSearchBar`); read in `viewDidLoad`.
     */
    @objc public var showsSearchBar = true

    open override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        guard showsSearchBar else { return }
        searchBar.usedAsTableHeaderView = true
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
    }

    /**
     * Called once before the bar is installed; set its style, margins and accessory views here.
     */
    @objc open func setUpSearchBar() {}
}
