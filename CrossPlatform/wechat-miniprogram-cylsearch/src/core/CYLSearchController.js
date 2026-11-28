// CYLSearchController.swift for the mini program: the QMUI `QMUISearchController` shape on top of `CYLSearchView`. The mini
// program's `<cyl-search>` draws a `CYLSearchView`, which already holds the launch view, the dimming color, the empty view and the
// result highlight; this class gives them their iOS names and owner, and forwards to the search view (nothing is kept twice).
'use strict';

const { cylNavigationMetrics } = require('./CYLSearchResources');
const { CYLSearchBar } = require('./CYLSearchBar');
const { CYLSearchView, cylEdgeSwipeBegins } = require('./CYLSearchView');

// Calls an optional delegate method.
function tell(delegate, method, ...args) {
  if (delegate && typeof delegate[method] === 'function') return delegate[method](...args);
  return undefined;
}

/**
 * What a `CYLSearchController` asks of its owner (iOS `CYLSearchControllerDelegate`): the results (called on every text
 * change), and optional life cycle callbacks (`willPresentSearchController`, `didPresentSearchController`,
 * `willDismissSearchController`, `didDismissSearchController`). Every method is optional.
 */
class CYLSearchControllerDelegate {
  /**
   * An empty delegate: set the methods you need.
   */
  constructor() {
    this.searchControllerUpdateResultsForSearchString = undefined;
    this.searchControllerDidLoadSearchResultsTableView = undefined;
    this.searchControllerWillShowEmptyView = undefined;
    this.willPresentSearchController = undefined;
    this.didPresentSearchController = undefined;
    this.willDismissSearchController = undefined;
    this.didDismissSearchController = undefined;
  }
}

/**
 * A search controller with the shape of QMUI's `QMUISearchController` (iOS `CYLSearchController`): a launch view while the
 * text is empty, a dimming color, an empty view with its own text, result highlighting and a history store, over the
 * `CYLSearchView` that `<cyl-search>` draws.
 */
class CYLSearchController {
  /**
   * A controller with its own search view (iOS `init(contentsViewController:resultsViewController:)`,
   * `init(contentsViewController:resultsTableViewStyle:)` and `init(contentsViewController:)`: the contents and the results
   * are the page and `<cyl-search>`'s list). `searchView` wraps one that exists; `storage` is its suggestion cache's.
   */
  constructor(storage, searchView) {
    this.searchView = searchView || new CYLSearchView(storage);
    this.bar = new CYLSearchBar(this.searchView.searchBarView);
    /** The owner of the results: it is told about the text and the life cycle (a `CYLSearchControllerDelegate`). */
    this.searchResultsDelegate = undefined;
    /** The delegate of the search view itself, called for every event the controller does not own. */
    this.viewDelegate = undefined;
    this.loadedResults = false;
    this.searchView.delegate = this.makeViewDelegate();
  }

  // The search view's events: the controller's own callbacks first, then the page's `viewDelegate`.
  makeViewDelegate() {
    const names = ['searchViewDidShow', 'searchViewDidClose', 'searchViewTextDidChange', 'searchViewDidSubmitText',
      'searchViewDidChangeFocus', 'searchViewDidSelectSuggestion', 'searchViewDidSelectResult', 'searchViewVoiceButtonClicked',
      'searchViewNavigationButtonClicked', 'searchViewHistoryDidChange', 'searchViewUpdateResults', 'searchViewWillShow', 'searchViewWillClose'];
    const delegate = {};
    names.forEach((name) => {
      delegate[name] = (...args) => {
        if (name === 'searchViewWillShow') this.willPresentSearchController();
        else if (name === 'searchViewDidShow') this.didPresentSearchController();
        else if (name === 'searchViewWillClose') this.willDismissSearchController();
        else if (name === 'searchViewDidClose') this.didDismissSearchController();
        else if (name === 'searchViewUpdateResults') this.updateSearchResults(args[1]);
        return tell(this.viewDelegate, name, ...args);
      };
    });
    // A delegate without `searchViewNavigationButtonClicked` lets the search view close itself.
    delegate.searchViewNavigationButtonClicked = (...args) => {
      if (this.viewDelegate && typeof this.viewDelegate.searchViewNavigationButtonClicked === 'function') {
        return this.viewDelegate.searchViewNavigationButtonClicked(...args);
      }
      return this.searchView.closeSearch(true);
    };
    return delegate;
  }

  /**
   * The search bar (a `CYLSearchBar` over the search view's bar view).
   */
  get searchBar() {
    return this.bar;
  }

  /**
   * Whether the first match of the text is marked in each result row.
   */
  get highlightsResultMatches() {
    return this.searchView.highlightsResultMatches;
  }

  set highlightsResultMatches(value) {
    this.searchView.highlightsResultMatches = !!value;
  }

  /**
   * The color of the marked match; undefined is the tint color.
   */
  get resultMatchHighlightColor() {
    return this.searchView.resultMatchHighlightColor;
  }

  set resultMatchHighlightColor(value) {
    this.searchView.resultMatchHighlightColor = value;
  }

  /**
   * Whether the page's own view (the slot `launch-view`) shows under the bar while the text is empty.
   */
  get launchView() {
    return this.searchView.showsLaunchView;
  }

  set launchView(value) {
    this.searchView.showsLaunchView = !!value;
  }

  /**
   * Whether the built-in launch view (the suggestions as tags over the history) shows while the text is empty.
   */
  get showsSuggestionsLaunchView() {
    return this.searchView.showsSuggestionsLaunchView;
  }

  set showsSuggestionsLaunchView(value) {
    this.searchView.showsSuggestionsLaunchView = !!value;
  }

  /**
   * The suggestions of the launch view and the list.
   */
  get suggestions() {
    return this.searchView.suggestions;
  }

  set suggestions(value) {
    this.searchView.suggestions = value;
  }

  /**
   * The dimming color under the bar while the text is empty (the search view's `scrimColor`).
   */
  get dimmingColor() {
    return this.searchView.scrimColor;
  }

  set dimmingColor(value) {
    this.searchView.scrimColor = value;
  }

  /**
   * Whether the search is active; assigning changes it without animation.
   */
  get isActive() {
    return this.searchView.isActive;
  }

  set isActive(value) {
    this.setActive(!!value, false);
  }

  /**
   * Whether the results show while the text is empty.
   */
  get alwaysShowsSearchResultsController() {
    return this.searchView.showsResultsForEmptyQuery;
  }

  set alwaysShowsSearchResultsController(value) {
    this.searchView.showsResultsForEmptyQuery = !!value;
  }

  /**
   * Whether a swipe from the left edge leaves the search.
   */
  get supportsSwipeToDismissSearch() {
    return this.searchView.supportsSwipeToDismissSearch;
  }

  set supportsSwipeToDismissSearch(value) {
    this.searchView.supportsSwipeToDismissSearch = !!value;
  }

  /**
   * The bottom edge of the search bar in px from the top of the page: the status bar and the navigation bar above it.
   */
  get searchBarMaxY() {
    const metrics = cylNavigationMetrics();
    return metrics.top + metrics.navigationBarHeight;
  }

  /**
   * Whether the empty view shows.
   */
  get isEmptyViewShowing() {
    return this.searchView.isEmptyViewShowing;
  }

  /**
   * The empty view's text while the text is not empty and the results are empty.
   */
  get noResultsText() {
    return this.searchView.noResultsText;
  }

  set noResultsText(value) {
    this.searchView.noResultsText = value;
    this.searchView.applyNoResultsText();
  }

  /**
   * Where the submitted queries are kept, newest first and without duplicates (a `CYLSearchSuggestionCache`); undefined
   * keeps none. The built-in store is the search view's, shared through `CYLSearchResources`.
   */
  get historyStore() {
    return this.searchView.historyStore;
  }

  set historyStore(value) {
    this.searchView.historyStore = value;
  }

  /**
   * The name of the event that the history changed (iOS `CYLSearchController.historyDidChangeNotification`); the page
   * receives it as `searchViewHistoryDidChange`.
   */
  static get historyDidChangeNotification() {
    return 'CYLSearchControllerHistoryDidChange';
  }

  /**
   * Whether the search is presented (the same as `isActive`).
   */
  get isSearchOpen() {
    return this.searchView.isSearchOpen;
  }

  /**
   * Whether the header bar of a list snaps fully shown or fully hidden when a drag ends.
   */
  get snapsHeaderSearchBar() {
    return this.searchView.snapsHeaderSearchBar;
  }

  set snapsHeaderSearchBar(value) {
    this.searchView.setSnapsHeader(value);
  }

  /**
   * Starts or ends the search, with animation when `animated`.
   */
  setActive(active, animated = true) {
    this.searchView.setActive(active, animated);
  }

  /**
   * Presents the search.
   */
  showSearch(animated = true) {
    this.searchView.showSearch(animated);
  }

  /**
   * Leaves the search.
   */
  closeSearch(animated = true) {
    this.searchView.closeSearch(animated);
  }

  /**
   * Puts the search bar at the top of the list screen as its header (iOS `installSearchBar(asHeaderOf:)`): the search view
   * draws the list screen, with the bar as the first block of the content (`<cyl-search showsSearchBar>`).
   */
  installSearchBar() {
    this.bar.usedAsTableHeaderView = true;
    this.searchView.showsSearchBar = true;
  }

  /**
   * Shows one of CYLTableViewPlaceHolder's scenarios as the results' empty view (iOS `showEmptyView(scenario:)`). Does
   * nothing while the text is empty. Returns whether the placeholder shows.
   */
  showEmptyViewForScenario(scenario) {
    if (this.searchView.query.length === 0) return false;
    tell(this.searchResultsDelegate, 'searchControllerWillShowEmptyView', this, scenario);
    this.searchView.emptyResultsScenario = scenario;
    this.searchView.showsEmptyResultsPlaceholder = true;
    return this.searchView.showsEmptyResults;
  }

  /**
   * Removes the empty view (the search leaving always does).
   */
  hideEmptyView() {
    this.searchView.hideEmptyView();
  }

  /**
   * The text changed (iOS `updateSearchResults(for:)`, also called with the empty text): the delegate gives the results.
   */
  updateSearchResults(text) {
    tell(this.searchResultsDelegate, 'searchControllerUpdateResultsForSearchString', this, text === undefined ? this.searchView.query : text);
    if (!this.loadedResults && this.searchView.showsResults) {
      // Once, when the results list is first drawn: the place to change its look.
      this.loadedResults = true;
      tell(this.searchResultsDelegate, 'searchControllerDidLoadSearchResultsTableView', this, this.searchView.searchResults);
    }
  }

  /**
   * The search is about to be presented.
   */
  willPresentSearchController() {
    tell(this.searchResultsDelegate, 'willPresentSearchController', this);
  }

  /**
   * The search was presented.
   */
  didPresentSearchController() {
    tell(this.searchResultsDelegate, 'didPresentSearchController', this);
  }

  /**
   * The search is about to be dismissed.
   */
  willDismissSearchController() {
    tell(this.searchResultsDelegate, 'willDismissSearchController', this);
  }

  /**
   * The search was dismissed: the empty view is hidden (leaving the search always does) and the next results list is new.
   */
  didDismissSearchController() {
    this.hideEmptyView();
    this.loadedResults = false;
    tell(this.searchResultsDelegate, 'didDismissSearchController', this);
  }

  /**
   * Whether the edge swipe may begin (iOS `gestureRecognizerShouldBegin(_:)`): the swipe is on, the search is open, and the
   * touch that moved by (`deltaX`, `deltaY`) went down at `startX` within the edge band.
   */
  gestureRecognizerShouldBegin(startX, deltaX, deltaY) {
    return this.supportsSwipeToDismissSearch && this.isActive && cylEdgeSwipeBegins(startX, deltaX, deltaY);
  }
}

module.exports = { CYLSearchControllerDelegate, CYLSearchController };
