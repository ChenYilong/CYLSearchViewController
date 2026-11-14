const { CYLSearchSuggestionCachePolicy, CYLSearchSuggestionStore } = require('./cyl_search_suggestion_cache');

/**
 * The state and rules of a search page (iOS `CYLSearchView`), without any view: the component only draws what this
 * decides and reports taps and text to it.
 *
 * Core behavior rule 1: focusing the field alone changes nothing below the search bar; that area changes only when the
 * text or the data changes.
 */
class CYLSearchViewModel {
  /**
   * A closed search view with the default look (iOS `-initWithFrame:`). `storage` is the cache's storage (see
   * `CYLSearchSuggestionStore`).
   */
  constructor(storage) {
    this.storage = storage;
    /** `'list'` or `'tags'` (iOS `suggestionStyle`). */
    this.suggestionStyle = 'list';
    this.suggestionsFoldedRowCount = 2;
    this.showsEmptyResultsPlaceholder = false;
    this.emptyResultsScenario = 'noResults';
    this.showsEmptySuggestionsPlaceholder = true;
    this.emptySuggestionsScenario = 'empty';
    /** Focuses the field when the search opens, which raises the keyboard. True by default. */
    this.focusesSearchFieldOnShow = true;
    this.submitsOnSuggestionSelection = false;
    this.closesOnSubmit = true;
    /** Decides whether a suggestion matches the query; undefined uses a case-insensitive "contains" test. */
    this.suggestionFilter = undefined;
    /** Receives the events: `{ onShow, onClose, onTextChange, onSubmit, onFocusChange, onSelectSuggestion }`. */
    this.delegate = {};
    this.query = '';
    this.isSearchOpen = false;
    this.filteredSuggestions = [];
    this.showsCachedQueries = false;
    this._suggestions = [];
    this._showsAllForEmptyQuery = false;
    this._policy = CYLSearchSuggestionCachePolicy.database;
    this._cacheName = 'CYLSearchView';
    this.suggestionCache = CYLSearchSuggestionStore.cache(this._policy, this._cacheName, storage);
  }

  /** The suggestions to filter as the text changes (iOS `suggestions`). */
  get suggestions() {
    return this._suggestions;
  }

  set suggestions(value) {
    this._suggestions = value || [];
    this.refilter();
  }

  /** Lists every suggestion while the query is empty (iOS `showsSuggestionsForEmptyQuery`). */
  get showsSuggestionsForEmptyQuery() {
    return this._showsAllForEmptyQuery;
  }

  set showsSuggestionsForEmptyQuery(value) {
    this._showsAllForEmptyQuery = !!value;
    this.refilter();
  }

  /** Where submitted queries are cached (iOS `suggestionCachePolicy`); `database` by default. */
  get suggestionCachePolicy() {
    return this._policy;
  }

  set suggestionCachePolicy(value) {
    this._policy = value;
    this.suggestionCache = CYLSearchSuggestionStore.cache(value, this._cacheName, this.storage);
    this.refilter();
  }

  /** Separates the caches of different search screens (iOS `suggestionCacheName`). */
  get suggestionCacheName() {
    return this._cacheName;
  }

  set suggestionCacheName(value) {
    this._cacheName = value;
    this.suggestionCache = CYLSearchSuggestionStore.cache(this._policy, value, this.storage);
    this.refilter();
  }

  /** True while a non-empty query matches nothing and the empty results placeholder is on. */
  get showsEmptyResults() {
    return this.showsEmptyResultsPlaceholder && this.query.length > 0 && this.filteredSuggestions.length === 0;
  }

  /** True while the query is empty, there is nothing to list and the empty suggestions placeholder is on. */
  get showsEmptySuggestions() {
    return (
      this.showsEmptySuggestionsPlaceholder &&
      this.query.length === 0 &&
      this.filteredSuggestions.length === 0 &&
      !!this.suggestionCache
    );
  }

  /**
   * Opens the search view (iOS `-showSearch:`); the result says whether the component should focus the field, which
   * is `focusesSearchFieldOnShow`.
   */
  showSearch() {
    if (this.isSearchOpen) return { focus: false };
    this.refilter();
    this.isSearchOpen = true;
    if (this.delegate.onShow) this.delegate.onShow(this);
    return { focus: this.focusesSearchFieldOnShow };
  }

  /** Closes the search view (iOS `-closeSearch:`). */
  closeSearch() {
    if (!this.isSearchOpen) return;
    this.isSearchOpen = false;
    if (this.delegate.onClose) this.delegate.onClose(this);
  }

  /** The text changed (the component reports it). */
  textChanged(text) {
    this.query = String(text || '');
    this.refilter();
    if (this.delegate.onTextChange) this.delegate.onTextChange(this, this.query);
  }

  /** Sets the query and submits it when `submit` is true (iOS `-setQuery:submit:`). */
  setQuery(text, submit) {
    this.query = String(text || '');
    this.refilter();
    if (submit) this.submitted();
  }

  /** The field started or stopped editing. Nothing below the search bar changes. */
  focusChanged(focused) {
    if (this.delegate.onFocusChange) this.delegate.onFocusChange(this, focused);
  }

  /** A suggestion was tapped: the field shows it, and it is submitted with `submitsOnSuggestionSelection`. */
  suggestionSelected(suggestion, index) {
    this.query = suggestion;
    this.refilter();
    if (this.delegate.onSelectSuggestion) this.delegate.onSelectSuggestion(this, suggestion, index);
    if (this.submitsOnSuggestionSelection) this.submitted();
  }

  /** The search key or the Search item: caches the query and tells the delegate. */
  submitted() {
    const text = this.query.trim();
    if (!text) return;
    if (this.suggestionCache) this.suggestionCache.addQuery(text);
    const handled = this.delegate.onSubmit ? this.delegate.onSubmit(this, text) === true : false;
    if (!handled && this.closesOnSubmit) this.closeSearch();
    this.refilter();
  }

  /** Clears the whole cache (iOS `-clearSuggestionCache`). */
  clearSuggestionCache() {
    if (this.suggestionCache) this.suggestionCache.removeAllQueries();
    this.refilter();
  }

  matches(suggestion, query) {
    if (this.suggestionFilter) return this.suggestionFilter(suggestion, query);
    return suggestion.toLowerCase().includes(query.toLowerCase());
  }

  /** Recomputes `filteredSuggestions`: cached queries first, then `suggestions`, without repeats. */
  refilter() {
    const query = this.query;
    const cached = this.suggestionCache ? this.suggestionCache.cachedQueries() : [];
    let result = [];
    if (query.length === 0) {
      if (cached.length > 0) {
        result = cached.slice();
        this.showsCachedQueries = true;
      } else {
        result = this._showsAllForEmptyQuery ? this._suggestions.slice() : [];
        this.showsCachedQueries = false;
      }
    } else {
      this.showsCachedQueries = false;
      cached.forEach((value) => {
        if (this.matches(value, query)) result.push(value);
      });
      this._suggestions.forEach((value) => {
        if (this.matches(value, query) && !result.includes(value)) result.push(value);
      });
    }
    this.filteredSuggestions = result;
  }
}

module.exports = { CYLSearchViewModel };
