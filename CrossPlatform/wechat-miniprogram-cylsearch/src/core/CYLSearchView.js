// The search view module of cyl-search-miniprogram (iOS `CYLSearchView.swift`): `CYLSearchView` (the search page:
// the bar, the suggestions or the results of `resultsDataSource`, the empty placeholders, the pull-to-refresh of the
// results), its delegate and data source, `CYLSearchSuggestionStyle`, the fold control of the tag suggestions, and
// the playback strategy of the animated placeholders. The `<cyl-search>` component draws a `CYLSearchView`. Merged
// from CYLSearchView.js, CYLSearchController.js (the overlay), CYLSearchResultsViewController.js (the results list)
// and the component helpers cyl_search_view_model.js, cyl_tag_fold.js and cyl_search_animation_playback.js.
'use strict';

const { $r, animateTo, Curve, TextOverflow, CYLSearchSuggestionCachePolicy, cylSuggestionCache } = require('./CYLSearchResources');
const { CYLSearchBarView, CYLSearchBarNavigationIcon } = require('./CYLSearchBarView');

/**
 * How the suggestions are shown under the search bar (iOS `CYLSearchSuggestionStyle`): one per row, or tags.
 */
const CYLSearchSuggestionStyle = Object.freeze({
  list: 'list',
  tags: 'tags',
});

/**
 * Where the fold control of the tag suggestions sits (CollectionViewClassifyMenu's `CYLMenuFoldControlPosition`).
 */
const CYLMenuFoldControlPosition = Object.freeze({
  inline: 'inline',
  bottom: 'bottom',
});

/**
 * What the fold control shows (CollectionViewClassifyMenu's `CYLMenuFoldControlContent`): a chevron, or a title.
 */
const CYLMenuFoldControlContent = Object.freeze({
  icon: 'icon',
  title: 'title',
});

/**
 * The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`).
 */
class CYLMenuFoldControl {
  /**
   * A fold control (iOS `+foldControlWithPosition:content:`).
   */
  constructor(position = CYLMenuFoldControlPosition.inline, content = CYLMenuFoldControlContent.icon) {
    this.position = position;
    this.content = content;
  }
}

/**
 * The events of a `CYLSearchView` (iOS `CYLSearchViewDelegate`); every method is optional.
 * `searchViewDidSubmitText` returns true when it handled the query and the search view stays open.
 */
class CYLSearchViewDelegate {
  /**
   * An empty delegate: set the methods you need.
   */
  constructor() {
    this.searchViewWillShow = undefined;
    this.searchViewWillClose = undefined;
    this.searchViewDidShow = undefined;
    this.searchViewDidClose = undefined;
    this.searchViewTextDidChange = undefined;
    this.searchViewDidSubmitText = undefined;
    this.searchViewDidChangeFocus = undefined;
    this.searchViewDidSelectSuggestion = undefined;
    this.searchViewDidSelectResult = undefined;
    this.searchViewVoiceButtonClicked = undefined;
    this.searchViewNavigationButtonClicked = undefined;
  }
}

/**
 * Supplies the results of a `CYLSearchView` and describes their rows (iOS `CYLSearchViewDataSource`, was
 * `CYLSearchResultsDataSource`): `searchViewResultsForQuery(searchView, query)` returns an array;
 * `searchViewConfigureResultCell(searchView, cell, result)` (optional) fills the row's plain `cell`
 * (`title`, `subtitle`, `accessibilityLabel`).
 */
class CYLSearchViewDataSource {
  /**
   * An empty data source: set `searchViewResultsForQuery`, and `searchViewConfigureResultCell` when needed.
   */
  constructor() {
    this.searchViewResultsForQuery = undefined;
    this.searchViewConfigureResultCell = undefined;
  }
}

// Calls an optional delegate method.
function tell(delegate, method, ...args) {
  if (delegate && typeof delegate[method] === 'function') return delegate[method](...args);
  return undefined;
}

// The refresh state of a target of the static refresh API that is not a search view (a component or a model).
function refreshTarget(target) {
  if (!target) throw new TypeError('CYLSearchView: a refresh target is needed (a <cyl-search> instance or a CYLSearchView).');
  return target;
}

/**
 * A search page that opens over its host (iOS `CYLSearchView`): a `CYLSearchBarView` at the top, a divider, then
 * either the results of `resultsDataSource` (while it is set and the query is not empty) or the suggestions as a list
 * or as tags, the cached queries first; CYLTableViewPlaceHolder's placeholders for no results and for an empty cache;
 * and CYLTableViewPlaceHolder's pull-to-refresh on the results (`refreshHandler`). This class is the page's state and
 * API; `<cyl-search>` draws it.
 *
 * Core behavior rule 1: focusing the field alone changes nothing below the search bar; that area changes only when
 * the text or the data changes.
 */
class CYLSearchView {
  /**
   * A closed search view with the default look (iOS `-initWithFrame:`). `storage` is the suggestion cache's storage
   * (`{ getSync(key), setSync(key, value) }`; wx storage by default).
   */
  constructor(storage) {
    this.delegate = undefined;
    this.resultsDataSource = undefined;
    this.refreshHandler = undefined;
    this.searchBarView = new CYLSearchBarView();
    this.searchBarView.navigationIcon = CYLSearchBarNavigationIcon.arrow;
    this.suggestionStyle = CYLSearchSuggestionStyle.tags;
    this.suggestionsFoldControl = new CYLMenuFoldControl();
    this.suggestionsFoldedRowCount = 2;
    this.showsEmptyResultsPlaceholder = false;
    this.emptyResultsScenario = 'NoSearchResults';
    this.showsEmptySuggestionsPlaceholder = true;
    this.emptySuggestionsScenario = 'NoContent';
    this.showsResultsForEmptyQuery = false;
    this.dividerColor = undefined;
    this.contentView = undefined;
    // The one dimming overlay under the bar while the query is empty (iOS `scrimColor`; `dimmingColor` forwards to it).
    this.scrimColor = undefined;
    this.backgroundColor = undefined;
    this.suggestionFilter = undefined;
    this.filteredSuggestions = [];
    this.suggestionImage = $r('sys.symbol.magnifyingglass');
    this.suggestionImageTintColor = undefined;
    this.suggestionBackgroundColor = undefined;
    this.suggestionTextColor = undefined;
    this.suggestionLineBreakMode = TextOverflow.None;
    this.submitsOnSuggestionSelection = false;
    this.suggestionCellConfiguration = undefined;
    this.suggestionCacheTitle = $r('app.string.cyl_search_recent');
    this.focusesSearchFieldOnShow = true;
    // iOS CYLSearchController (QMUI), as modes of this one class: a launch view under the bar while the query is empty
    // (`showsSuggestionsLaunchView`: the suggestion area itself; `showsLaunchView`: the component's slot `launch-view`
    // for a view of the page's own), the scrim there instead, results that mark the match (`highlightsResultMatches`),
    // the empty view with its own text (`noResultsText`), and the list screen mode (the bar as the header of the
    // content: CYLSearchTableViewController).
    this.showsSuggestionsLaunchView = false;
    this.showsLaunchView = false;
    this.highlightsResultMatches = false;
    this.resultMatchHighlightColor = undefined;
    // The line over the results (iOS `resultsHeaderTitleProvider`: the query in, a text or undefined out, in
    // `resultsHeaderTextColor`), and the text button under the cached queries that clears them
    // (`suggestionCacheFooterTitle`).
    this.resultsHeaderTitleProvider = undefined;
    this.resultsHeaderTextColor = undefined;
    this.suggestionCacheFooterTitle = undefined;
    this.noResultsText = undefined;
    this.autoEmptyView = false;
    this.emptyView = undefined;
    this.emptyViewInContent = false;
    this.showsSearchBar = false;
    this.hidesSearchBarInitially = false;
    this.hidesSearchBarWhenEmptyViewShowing = false;
    this.snapsHeaderSearchBar = true;
    this.supportsSwipeToDismissSearch = false;
    // Shows the header above the cached queries (the title and the trash button; iOS showsSuggestionCacheHeader). false
    // takes it away, for a host that clears the history with its own control that calls clearSuggestionCache().
    this.showsSuggestionCacheHeader = true;
    this.animationDuration = 0.25;
    this.closesOnSubmit = true;
    this.showsCachedQueries = false;
    this.suggestionsFolded = true;
    this.storage = storage;
    this.open = false;
    this.suggestionsShown = true;
    this.allSuggestions = [];
    this.showsAllForEmptyQuery = false;
    this.results = [];
    this.refreshing = false;
    this.cachePolicy = CYLSearchSuggestionCachePolicy.database;
    this.cacheName = 'CYLSearchView';
    this.suggestionCache = cylSuggestionCache(this.cachePolicy, this.cacheName, storage);
    this.searchBarView.delegate = {
      searchBarViewTextDidChange: (_, text) => {
        this.refilter();
        this.reloadResults();
        if (text.length === 0) this.hideEmptyView();
        tell(this.delegate, 'searchViewTextDidChange', this, text);
        tell(this.delegate, 'searchViewUpdateResults', this, text);
      },
      searchBarViewSearchButtonClicked: () => this.submitted(),
      searchBarViewDidBeginEditing: () => tell(this.delegate, 'searchViewDidChangeFocus', this, true),
      searchBarViewDidEndEditing: () => tell(this.delegate, 'searchViewDidChangeFocus', this, false),
      searchBarViewVoiceButtonClicked: () => tell(this.delegate, 'searchViewVoiceButtonClicked', this),
      searchBarViewCancelButtonClicked: () => this.closeSearch(true),
      searchBarViewNavigationButtonClicked: () => {
        if (this.delegate && typeof this.delegate.searchViewNavigationButtonClicked === 'function') {
          this.delegate.searchViewNavigationButtonClicked(this);
        } else {
          this.closeSearch(true);
        }
      },
    };
  }

  /**
   * Deprecated: the scrim (iOS `dimmingColor`, which forwards to `scrimColor`).
   */
  get dimmingColor() {
    return this.scrimColor;
  }

  set dimmingColor(value) {
    this.scrimColor = value;
  }

  /**
   * Deprecated: `highlightsResultMatches` (the earlier name of this port).
   */
  get highlightsMatches() {
    return this.highlightsResultMatches;
  }

  set highlightsMatches(value) {
    this.highlightsResultMatches = !!value;
  }

  /**
   * The suggestions to filter as the text changes.
   */
  get suggestions() {
    return this.allSuggestions;
  }

  set suggestions(value) {
    this.allSuggestions = Array.isArray(value) ? value : [];
    this.refilter();
  }

  /**
   * Lists every suggestion while the query is empty. False by default.
   */
  get showsSuggestionsForEmptyQuery() {
    return this.showsAllForEmptyQuery;
  }

  set showsSuggestionsForEmptyQuery(value) {
    this.showsAllForEmptyQuery = !!value;
    this.refilter();
  }

  /**
   * Where submitted queries are cached for the suggestion list (`CYLSearchSuggestionCachePolicy`). `database` by
   * default; it replaces `suggestionCache` with the default store of that policy.
   */
  get suggestionCachePolicy() {
    return this.cachePolicy;
  }

  set suggestionCachePolicy(value) {
    this.cachePolicy = value;
    this.suggestionCache = cylSuggestionCache(value, this.cacheName, this.storage);
    this.refilter();
  }

  /**
   * Separates the caches of different search screens. "CYLSearchView" by default.
   */
  get suggestionCacheName() {
    return this.cacheName;
  }

  set suggestionCacheName(value) {
    this.cacheName = value;
    this.suggestionCache = cylSuggestionCache(this.cachePolicy, value, this.storage);
    this.refilter();
  }

  /**
   * True while the search view is open (iOS `isSearchOpen`).
   */
  get isSearchOpen() {
    return this.open;
  }

  /**
   * The current query.
   */
  get query() {
    return this.searchBarView.text;
  }

  set query(value) {
    this.setQuery(value, false);
  }

  /**
   * True while the suggestions are listed (`showSuggestions` / `dismissSuggestions`).
   */
  get suggestionsVisible() {
    return this.suggestionsShown;
  }

  /**
   * The results of the current query from `resultsDataSource` (iOS `searchResults`, read-only).
   */
  get searchResults() {
    return this.results.slice();
  }

  /**
   * True while the results take the place of the suggestions: `resultsDataSource` is set and the query is not empty
   * (or `showsResultsForEmptyQuery` is true).
   */
  get showsResults() {
    return !!this.resultsDataSource && (this.query.length > 0 || this.showsResultsForEmptyQuery);
  }

  /**
   * The text over the results while they show (iOS `resultsHeaderTitleProvider`), or undefined: no provider, no
   * results shown, or the provider returned nothing or an empty text.
   */
  get resultsHeaderTitle() {
    if (!this.showsResults || typeof this.resultsHeaderTitleProvider !== 'function') return undefined;
    const title = this.resultsHeaderTitleProvider(this.query);
    return typeof title === 'string' && title.length > 0 ? title : undefined;
  }

  /**
   * The title of the clear button under the cached queries, or undefined while there is none or no cached query shows
   * (iOS `suggestionCacheFooterTitle`).
   */
  get suggestionCacheFooter() {
    const title = this.suggestionCacheFooterTitle;
    return this.showsCachedQueries && typeof title === 'string' && title.length > 0 ? title : undefined;
  }

  /**
   * Turns the snapping of the header search bar on or off (iOS `setSnapsHeader(_:for:in:)`, which names the header and
   * its table view; the mini program's header bar is the one of `<cyl-search showsSearchBar>`, so only the flag is
   * left): a bar half scrolled out settles fully shown or fully hidden when the scrolling ends (`cylSnapHeaderOffset`).
   */
  setSnapsHeader(snaps) {
    this.snapsHeaderSearchBar = !!snaps;
  }

  /**
   * True while the empty results placeholder shows: it is on, and the results (or, without results, the suggestions
   * of a non-empty query) are empty.
   */
  get showsEmptyResults() {
    if (!this.showsEmptyResultsPlaceholder) return false;
    if (this.showsResults) return this.results.length === 0;
    return this.query.length > 0 && this.filteredSuggestions.length === 0;
  }

  /**
   * True while the query is empty, there is nothing to list and the empty suggestions placeholder is on.
   */
  get showsEmptySuggestions() {
    return this.showsEmptySuggestionsPlaceholder && !this.showsResults && this.query.length === 0
      && this.filteredSuggestions.length === 0 && this.suggestionCache !== undefined;
  }

  /**
   * True while the results are refreshing (iOS `isRefreshing`).
   */
  get isRefreshing() {
    return this.refreshing;
  }

  /**
   * Opens the search view and, with `focusesSearchFieldOnShow`, starts editing (iOS `showSearch(animated:)`);
   * `completion` runs once it is open, also when it already was.
   */
  showSearch(animated = true, completion = undefined) {
    if (this.open) {
      if (completion) completion();
      return;
    }
    this.refilter();
    this.reloadResults();
    tell(this.delegate, 'searchViewWillShow', this);
    const duration = animated ? this.animationDuration * 1000 : 0;
    animateTo({ duration, curve: Curve.EaseOut, onFinish: completion }, () => {
      this.open = true;
    });
    if (this.focusesSearchFieldOnShow) this.searchBarView.showKeyboard();
    tell(this.delegate, 'searchViewDidShow', this);
    // UIKit calls the results updater on the first activation too, with the empty text (iOS E10).
    tell(this.delegate, 'searchViewUpdateResults', this, this.query);
  }

  /**
   * Starts or ends the search (iOS `setActive(_:animated:)`): `showSearch` or `closeSearch`.
   */
  setActive(active, animated = true) {
    if (active) this.showSearch(animated);
    else this.closeSearch(animated);
  }

  /**
   * True while the search is active (iOS `isActive`), as `isSearchOpen`.
   */
  get isActive() {
    return this.open;
  }

  /**
   * Closes the search view and ends editing (iOS `closeSearch(animated:completion:)`); `completion` runs once it is
   * closed, also when it was not open.
   */
  closeSearch(animated = true, completion = undefined) {
    if (!this.open) {
      if (completion) completion();
      return;
    }
    tell(this.delegate, 'searchViewWillClose', this);
    this.searchBarView.hideKeyboard();
    // The empty view is hidden when the search ends (iOS E9).
    this.hideEmptyView();
    const duration = animated ? this.animationDuration * 1000 : 0;
    animateTo({ duration, curve: Curve.EaseIn, onFinish: completion }, () => {
      this.open = false;
    });
    tell(this.delegate, 'searchViewDidClose', this);
  }

  /**
   * The state to keep across a restart: whether the search view is open and its query.
   */
  encodeRestorableState() {
    return { open: this.open, query: this.query };
  }

  /**
   * Restores the query and reopens the search view when it was open.
   */
  decodeRestorableState(state) {
    const values = state || {};
    this.setQuery(values.query || '', false);
    if (values.open === true) this.showSearch(false);
  }

  /**
   * The back gesture or key: closes an open search view and returns true (iOS `-accessibilityPerformEscape`).
   */
  accessibilityPerformEscape() {
    if (!this.open) return false;
    this.closeSearch(true);
    return true;
  }

  /**
   * A tap handler that opens the search view, for a menu item or a button (iOS `-attachToBarButtonItem:`).
   */
  attachToMenuItem() {
    return () => this.showSearch(true);
  }

  /**
   * Sets the query and submits it when `submit` is true (iOS `-setQuery:submit:`).
   */
  setQuery(text, submit = false) {
    this.searchBarView.setText(text, false);
    this.refilter();
    this.reloadResults();
    tell(this.delegate, 'searchViewUpdateResults', this, this.query);
    if (submit) this.submitted();
  }

  /**
   * The component reports the text of the field.
   */
  textChanged(text) {
    const before = this.query;
    this.searchBarView.textChanged(text);
    if (before === this.query) {
      this.refilter();
      this.reloadResults();
    }
  }

  /**
   * The component reports that the field started or stopped editing. Nothing below the search bar changes.
   */
  focusChanged(focused) {
    this.searchBarView.editingChanged(!!focused);
  }

  /**
   * Lists the suggestions that match the current query.
   */
  showSuggestions() {
    this.suggestionsShown = true;
    this.refilter();
  }

  /**
   * Hides the suggestions.
   */
  dismissSuggestions() {
    this.suggestionsShown = false;
  }

  /**
   * Clears the whole cache, as the trash button of the header does (iOS `-clearSuggestionCache`).
   */
  clearSuggestionCache() {
    if (this.suggestionCache) this.suggestionCache.removeAllQueries();
    this.refilter();
    this.historyChanged();
  }

  /**
   * The submitted queries, newest first, no duplicates (iOS `historyStore.cachedQueries()`): the suggestion cache.
   */
  get history() {
    return this.suggestionCache ? this.suggestionCache.cachedQueries() : [];
  }

  /**
   * Where submitted queries are kept (iOS `historyStore`): `suggestionCache`.
   */
  get historyStore() {
    return this.suggestionCache;
  }

  set historyStore(value) {
    this.suggestionCache = value;
    this.refilter();
  }

  /**
   * Clears the history (iOS `historyStore.removeAllQueries()`) and tells the delegate.
   */
  clearHistory() {
    this.clearSuggestionCache();
  }

  // Tells the delegate that the history changed (iOS `historyDidChangeNotification`), so a launch view that stays on
  // screen reads it again.
  historyChanged() {
    tell(this.delegate, 'searchViewHistoryDidChange', this, this.history);
  }

  /**
   * Shows the empty view with its own text (iOS `showEmptyView(text:detailText:buttonTitle:buttonAction:)`). It is not
   * shown while the query is empty while searching (iOS E8, it would sit on the dimming); when the search is not active it
   * takes the content's place (the list screen's empty view). Returns whether it is showing.
   */
  showEmptyView(text, detailText, buttonTitle, buttonAction) {
    this.autoEmptyView = false;
    if (this.open && this.query.length === 0) return false;
    this.emptyView = { text: text || '', detailText: detailText || '', buttonTitle: buttonTitle || '', buttonAction };
    this.emptyViewInContent = !this.open;
    return true;
  }

  /**
   * Hides the empty view (iOS `hideEmptyView()`).
   */
  hideEmptyView() {
    this.emptyView = undefined;
    this.emptyViewInContent = false;
    this.autoEmptyView = false;
  }

  // `noResultsText` (iOS `CYLSearchController.noResultsText`): the empty view shows while the query is not empty and the
  // results are empty, and goes with them; an empty view the page showed itself is never replaced or hidden by it.
  applyNoResultsText() {
    if (!this.noResultsText) {
      if (this.autoEmptyView) this.hideEmptyView();
      return;
    }
    const none = this.showsResults && this.query.length > 0 && this.results.length === 0;
    if (none && (this.emptyView === undefined || this.autoEmptyView)) {
      if (this.showEmptyView(this.noResultsText)) this.autoEmptyView = true;
    } else if (!none && this.autoEmptyView) {
      this.hideEmptyView();
    }
  }

  /**
   * True while the empty view shows (iOS `isEmptyViewShowing`).
   */
  get isEmptyViewShowing() {
    return this.emptyView !== undefined;
  }

  /**
   * True while the launch view shows: it is on, the query is empty and no results show (iOS `launchView`).
   */
  get showsLaunch() {
    return this.showsLaunchView && !this.showsSuggestionsLaunchView && this.query.length === 0 && !this.showsResults && this.emptyView === undefined;
  }

  /**
   * True while the scrim shows under the bar: a scrim color, an empty query, no launch view (iOS `scrimColor`).
   */
  get showsDimming() {
    return !!this.scrimColor && this.query.length === 0 && !this.showsLaunchView && !this.showsSuggestionsLaunchView && !this.showsResults;
  }

  /**
   * True while the bar of the list screen is hidden: the content's empty view shows and the bar hides with it (iOS
   * `hidesSearchBarWhenEmptyViewShowing`).
   */
  get hidesHeaderBar() {
    return this.showsSearchBar && this.hidesSearchBarWhenEmptyViewShowing && this.emptyView !== undefined && this.emptyViewInContent;
  }

  /**
   * A suggestion was tapped: the field shows it, the delegate is told, and it is submitted with
   * `submitsOnSuggestionSelection`.
   */
  suggestionSelected(suggestion, index) {
    // A tag of the launch view submits (iOS `showsSuggestionsLaunchView`).
    const launching = this.showsSuggestionsLaunchView && this.query.length === 0;
    this.searchBarView.setText(suggestion, false);
    this.refilter();
    this.reloadResults();
    tell(this.delegate, 'searchViewDidSelectSuggestion', this, suggestion, index);
    tell(this.delegate, 'searchViewUpdateResults', this, this.query);
    if (this.submitsOnSuggestionSelection || launching) this.submitted();
  }

  /**
   * Queries `resultsDataSource` for the current query and reloads the results (iOS `reloadResults()`). Without a data
   * source, or while the results do not show, the results are empty.
   */
  reloadResults() {
    const source = this.resultsDataSource;
    if (!source || !this.showsResults || typeof source.searchViewResultsForQuery !== 'function') {
      this.results = [];
    } else {
      const results = source.searchViewResultsForQuery(this, this.query);
      this.results = Array.isArray(results) ? results.slice() : [];
    }
    this.applyNoResultsText();
    return this.searchResults;
  }

  /**
   * The row of a result: `{ title, subtitle, accessibilityLabel }`, `title` being the result's text unless
   * `resultsDataSource.searchViewConfigureResultCell` fills it.
   */
  resultCell(result) {
    const cell = { title: result === null || result === undefined ? '' : String(result), subtitle: '', accessibilityLabel: '' };
    tell(this.resultsDataSource, 'searchViewConfigureResultCell', this, cell, result);
    if (!cell.accessibilityLabel) cell.accessibilityLabel = cell.subtitle ? `${cell.title}, ${cell.subtitle}` : cell.title;
    if (this.highlightsResultMatches) cell.parts = cylHighlightParts(cell.title, this.query);
    return cell;
  }

  /**
   * A result was tapped: the delegate is told (iOS `searchView(_:didSelectResult:)`).
   */
  resultSelected(result, index) {
    tell(this.delegate, 'searchViewDidSelectResult', this, result, index);
  }

  /**
   * Starts refreshing the results, as a pull does: `refreshHandler` is called (iOS `beginRefreshing()`). Does
   * nothing without a handler or while refreshing.
   */
  beginRefreshing() {
    if (this.refreshing || typeof this.refreshHandler !== 'function') return;
    this.refreshing = true;
    this.refreshHandler();
  }

  /**
   * Ends refreshing (iOS `endRefreshing()`); call it on every completion path of `refreshHandler`.
   */
  endRefreshing() {
    this.refreshing = false;
  }

  /**
   * Sets the pull-to-refresh handler of another target (iOS `static setRefreshHandler(_:for:)`): a `<cyl-search>`
   * instance (its `setRefreshHandler`) or a `CYLSearchView`; undefined removes it.
   */
  static setRefreshHandler(handler, target) {
    const view = refreshTarget(target);
    if (typeof view.setRefreshHandler === 'function') view.setRefreshHandler(handler);
    else view.refreshHandler = handler;
  }

  /**
   * Starts refreshing that target (iOS `static beginRefreshing(in:)`).
   */
  static beginRefreshing(target) {
    refreshTarget(target).beginRefreshing();
  }

  /**
   * Ends refreshing that target (iOS `static endRefreshing(in:)`).
   */
  static endRefreshing(target) {
    refreshTarget(target).endRefreshing();
  }

  /**
   * Whether that target is refreshing (iOS `static isRefreshing(in:)`).
   */
  static isRefreshing(target) {
    const view = refreshTarget(target);
    return typeof view.isRefreshing === 'function' ? view.isRefreshing() : !!view.isRefreshing;
  }

  submitted() {
    const text = this.query.trim();
    if (text.length === 0) return;
    if (this.suggestionCache) {
      this.suggestionCache.addQuery(text);
      this.historyChanged();
    }
    this.searchBarView.hideKeyboard();
    const handled = tell(this.delegate, 'searchViewDidSubmitText', this, text) === true;
    if (!handled && this.closesOnSubmit) this.closeSearch(true);
    this.refilter();
  }

  matches(suggestion, query) {
    if (this.suggestionFilter) return this.suggestionFilter(suggestion, query);
    return cylFold(suggestion).folded.includes(cylFold(query).folded);
  }

  /**
   * Recomputes `filteredSuggestions`: the cached queries first, then `suggestions`, without repeats.
   */
  refilter() {
    const query = this.query;
    const cached = this.suggestionCache ? this.suggestionCache.cachedQueries() : [];
    let result = [];
    if (query.length === 0) {
      this.showsCachedQueries = cached.length > 0;
      if (cached.length > 0) result = cached.slice();
      else result = this.showsAllForEmptyQuery || this.showsSuggestionsLaunchView ? this.allSuggestions.slice() : [];
    } else {
      this.showsCachedQueries = false;
      cached.forEach((value) => {
        if (this.matches(value, query)) result.push(value);
      });
      this.allSuggestions.forEach((value) => {
        if (this.matches(value, query) && !result.includes(value)) result.push(value);
      });
    }
    this.filteredSuggestions = result;
  }

  /**
   * The suggestion tags as the configuration of CollectionViewClassifyMenu's tag list (`<cyl-tag-list>`, the mini
   * program's `CYLTagListView`): one section without a header, no selection, folded to `suggestionsFoldedRowCount` rows
   * with the fold control of `suggestionsFoldControl` (inline is its tail, bottom its footer) last; the colors of the
   * suggestion knobs go in its style. `dark` picks the dark defaults when no color was set.
   */
  suggestionTagConfiguration(dark = false) {
    const control = this.suggestionsFoldControl;
    const positions = { [CYLMenuFoldControlPosition.inline]: 'tail', [CYLMenuFoldControlPosition.bottom]: 'footer' };
    const normal = {};
    const textColor = this.suggestionTextColor || (dark ? '#FFFFFF' : undefined);
    const borderColor = this.dividerColor || (dark ? '#38383A' : undefined);
    if (textColor) normal.textColor = textColor;
    if (borderColor) normal.borderColor = borderColor;
    const style = { backgroundColor: 'rgba(0, 0, 0, 0)', normal };
    const foldColor = this.suggestionImageTintColor || (dark ? 'rgba(235, 235, 245, 0.6)' : undefined);
    if (foldColor) style.foldControlColor = foldColor;
    return {
      selectionMode: 'none',
      showsSectionHeaders: false,
      defaultVisibleRows: Math.max(0, this.suggestionsFoldedRowCount),
      foldControl: { position: positions[control.position] || 'tail', content: control.content === CYLMenuFoldControlContent.title ? 'title' : 'icon' },
      style,
      sections: [{ items: this.filteredSuggestions.map((title) => ({ title: String(title) })) }],
    };
  }
}

/**
 * A text with case and diacritics folded away (iOS `range(of:options: [.caseInsensitive, .diacriticInsensitive])`):
 * `folded` is the folded text and `map[i]` the `[start, end)` of the original characters that produced `folded[i]`, so a
 * match in the folded text maps back to the original (folding changes the length: "é" is "e" plus a mark).
 */
function cylFold(value) {
  const text = value === null || value === undefined ? '' : String(value);
  let folded = '';
  const map = [];
  let offset = 0;
  for (const character of text) {
    const piece = character.normalize('NFD').replace(/\p{M}/gu, '').toLowerCase();
    for (let i = 0; i < piece.length; i += 1) map.push([offset, offset + character.length]);
    folded += piece;
    offset += character.length;
  }
  return { folded, map };
}

/**
 * A result's title split around the first match of the query, ignoring case and diacritics like the suggestion filter
 * (QMUI demo: the match in the tint color): `[{ text, highlighted }]`, the text as it was written; the whole title when
 * the query is empty or does not match.
 */
function cylHighlightParts(title, query) {
  const text = String(title);
  const wanted = cylFold(query).folded;
  const { folded, map } = cylFold(text);
  const index = wanted ? folded.indexOf(wanted) : -1;
  if (index < 0) return [{ text, highlighted: false }];
  const start = map[index][0];
  let end = map[index + wanted.length - 1][1];
  // A mark that follows the last matched letter belongs to it ("e" + U+0301 for "é").
  while (end < text.length && /^\p{M}/u.test(text.slice(end))) end += text.codePointAt(end) > 0xffff ? 2 : 1;
  return [
    { text: text.slice(0, start), highlighted: false },
    { text: text.slice(start, end), highlighted: true },
    { text: text.slice(end), highlighted: false },
  ].filter((part) => part.text.length > 0);
}

/**
 * Where a header search bar settles when a drag ends inside its band (iOS `snapsHeaderSearchBar`, #1160): fully hidden
 * (the header height) from half of it on, else fully shown (0); a fling decides by its direction (`velocity` in px per ms,
 * positive scrolls the content up). An offset outside the band stays.
 */
function cylSnapHeaderOffset(offset, headerHeight, velocity = 0) {
  if (!(headerHeight > 0) || offset <= 0 || offset >= headerHeight) return offset;
  const projected = offset + velocity * 200;
  return projected >= headerHeight / 2 ? headerHeight : 0;
}

/**
 * Whether a swipe from the left edge ends the search (iOS `supportsSwipeToDismissSearch`): it began within `edge` px of the
 * edge, and moved right more than a quarter of the `width` or fast to the right (iOS: velocity above 0).
 */
function cylSwipeShouldDismiss(startX, deltaX, width, velocity = 0, edge = 24) {
  if (startX > edge || deltaX <= 0) return false;
  return deltaX > width / 4 || (velocity > 0.5 && deltaX > 24);
}

/**
 * Whether a touch that moved by (`deltaX`, `deltaY`) has begun the edge swipe (iOS `CYLSearchEdgeSwipe`, the touch itself):
 * it went down within `edge` px of the left edge and moved right past `slop` px, more than up or down.
 */
function cylEdgeSwipeBegins(startX, deltaX, deltaY, edge = 24, slop = 10) {
  return startX <= edge && deltaX > slop && Math.abs(deltaX) > Math.abs(deltaY);
}

/**
 * Deprecated: the suggestion tags are CollectionViewClassifyMenu's tag list, which folds them itself (`defaultVisibleRows`,
 * its fold control last); nothing in this package calls this any more.
 *
 * How many tags fit in `rows` rows of width `available` when the fold chevron must follow the last visible tag
 * (CollectionViewClassifyMenu `CYLMenuFoldControlPositionInline`): `{ visibleCount, needsFold }`.
 */
function cylFoldTags(widths, available, spacing, chevronWidth, rows) {
  const place = (count, extra) => {
    let row = 1;
    let x = 0;
    for (const width of widths.slice(0, count).concat(extra ? [extra] : [])) {
      const needed = x === 0 ? width : x + spacing + width;
      if (needed > available && x > 0) {
        row += 1;
        x = width;
      } else {
        x = needed;
      }
    }
    return row;
  };
  if (widths.length === 0) return { visibleCount: 0, needsFold: false };
  if (place(widths.length, 0) <= rows) return { visibleCount: widths.length, needsFold: false };
  let count = widths.length;
  while (count > 0 && place(count, chevronWidth) > rows) count -= 1;
  return { visibleCount: count, needsFold: true };
}

/**
 * The speeds the playback slider of the animated placeholders offers, as multiples of the animation's own speed.
 */
const CYLSearchAnimationSpeed = Object.freeze({ minimum: 0.25, maximum: 3, step: 0.25, standard: 1 });

/**
 * Clamps a speed to the slider's range and rounds it to its step; anything that is not a number is 1.
 */
function cylClampAnimationSpeed(speed) {
  const value = Number(speed);
  if (!Number.isFinite(value)) return CYLSearchAnimationSpeed.standard;
  const { minimum, maximum, step } = CYLSearchAnimationSpeed;
  return Math.min(maximum, Math.max(minimum, Math.round(value / step) * step));
}

/**
 * What a screen reader says for the playback strategy, e.g. "1.5x, looping" or "0.25x, plays once".
 */
function cylAnimationPlaybackDescription(speed, loops) {
  return `${cylClampAnimationSpeed(speed)}x, ${loops ? 'looping' : 'plays once'}`;
}

module.exports = {
  CYLSearchSuggestionStyle,
  CYLMenuFoldControlPosition,
  CYLMenuFoldControlContent,
  CYLMenuFoldControl,
  CYLSearchViewDelegate,
  CYLSearchViewDataSource,
  CYLSearchView,
  cylFoldTags,
  cylHighlightParts,
  cylSnapHeaderOffset,
  cylSwipeShouldDismiss,
  cylEdgeSwipeBegins,
  cylFold,
  CYLSearchAnimationSpeed,
  cylClampAnimationSpeed,
  cylAnimationPlaybackDescription,
};
