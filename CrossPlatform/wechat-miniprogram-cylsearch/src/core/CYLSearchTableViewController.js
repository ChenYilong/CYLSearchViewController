// CYLSearchTableViewController.swift for the mini program: a list screen that shows the search bar as its header, with the
// `CYLSearchController` that drives it (QMUI's `QMUICommonTableViewController (Search)`). `<cyl-search showsSearchBar>` draws it;
// this class owns the state and the hooks of a page.
'use strict';

const { CYLSearchController } = require('./CYLSearchController');

/**
 * A list screen that can show a search bar as its header (iOS `CYLSearchTableViewController`). Set `showsSearchBar` and call
 * `viewDidLoad()` once the page is ready (the controller and the bar are created or removed then); configure the bar in
 * `setUpSearchBar()`; override `searchControllerUpdateResultsFor(searchController, text)` for the results.
 */
class CYLSearchTableViewController {
  /**
   * A list screen without a search bar. `storage` is the suggestion cache's storage of the search view.
   */
  constructor(storage) {
    this.storage = storage;
    /** Whether the search bar is the list's header (default false); applied by `viewDidLoad()`. */
    this.showsSearchBar = false;
    this.controller = undefined;
    this.viewLoaded = false;
  }

  /**
   * The search controller, undefined while `showsSearchBar` is off or the view is not loaded.
   */
  get searchController() {
    return this.controller;
  }

  /**
   * The search bar that is the list's header, undefined while `showsSearchBar` is off or the view is not loaded.
   */
  get searchBar() {
    return this.controller ? this.controller.searchBar : undefined;
  }

  /**
   * Whether the search bar leaves the header while an empty view shows and returns when it is hidden (default false).
   */
  get hidesSearchBarWhenEmptyViewShowing() {
    return this.controller ? this.controller.searchView.hidesSearchBarWhenEmptyViewShowing : !!this.hidesWhenEmpty;
  }

  set hidesSearchBarWhenEmptyViewShowing(value) {
    this.hidesWhenEmpty = !!value;
    if (this.controller) this.controller.searchView.hidesSearchBarWhenEmptyViewShowing = !!value;
  }

  /**
   * Whether the list is scrolled so that the search bar is out of sight when it is first shown (default false).
   */
  get hidesSearchBarInitially() {
    return this.controller ? this.controller.searchView.hidesSearchBarInitially : !!this.hidesInitially;
  }

  set hidesSearchBarInitially(value) {
    this.hidesInitially = !!value;
    if (this.controller) this.controller.searchView.hidesSearchBarInitially = !!value;
  }

  /**
   * Whether the empty view is on screen.
   */
  get isEmptyViewShowing() {
    return this.controller ? this.controller.isEmptyViewShowing : false;
  }

  /**
   * The view is loaded: creates the search controller and the bar when `showsSearchBar` is on, removes them when it is off.
   */
  viewDidLoad() {
    this.viewLoaded = true;
    if (this.showsSearchBar && !this.controller) {
      const controller = new CYLSearchController(this.storage);
      controller.searchResultsDelegate = {
        searchControllerUpdateResultsForSearchString: (owner, text) => this.searchControllerUpdateResultsFor(owner, text),
      };
      this.controller = controller;
      controller.searchView.hidesSearchBarWhenEmptyViewShowing = !!this.hidesWhenEmpty;
      controller.searchView.hidesSearchBarInitially = !!this.hidesInitially;
      this.setUpSearchBar();
      controller.installSearchBar();
    } else if (!this.showsSearchBar && this.controller) {
      this.controller.searchView.showsSearchBar = false;
      this.controller = undefined;
    }
  }

  /**
   * Called once after the controller and the bar are created and before the bar becomes the header: set the bar's style,
   * margins and accessories here. Does nothing by default.
   */
  setUpSearchBar() {}

  /**
   * Called with every text change of the search, also with "" (iOS `searchController(_:updateResultsFor:)`). Does nothing
   * by default.
   */
  searchControllerUpdateResultsFor() {}

  /**
   * Shows an empty view with a title and an optional detail over the list; with `hidesSearchBarWhenEmptyViewShowing` the
   * bar leaves the header.
   */
  showEmptyView(text, detailText) {
    if (!this.controller) return false;
    return this.controller.searchView.showEmptyView(text, detailText);
  }

  /**
   * Shows one of CYLTableViewPlaceHolder's scenarios over the list (iOS `showEmptyView(scenario:)`).
   */
  showEmptyViewForScenario(scenario) {
    return this.controller ? this.controller.showEmptyViewForScenario(scenario) : false;
  }

  /**
   * Removes the empty view; with `hidesSearchBarWhenEmptyViewShowing` the bar returns to the header.
   */
  hideEmptyView() {
    if (this.controller) this.controller.hideEmptyView();
  }
}

module.exports = { CYLSearchTableViewController };
