// The search view module (src/core/CYLSearchView.js): suggestions and cache, open and close with completions, the
// results of a data source (was CYLSearchController / CYLSearchResultsViewController) and the refresh API.
const test = require('node:test');
const assert = require('node:assert/strict');
const { CYLSearchView } = require('../src/core/CYLSearchView');
const { CYLSearchSuggestionCachePolicy } = require('../src/core/CYLSearchResources');

function memoryStorage() {
  const values = {};
  return { getSync: (key) => values[key], setSync: (key, value) => { values[key] = value; }, values };
}

const items = Array.from({ length: 40 }, (_, index) => `Sample result ${index + 1}`);
const dataSource = {
  searchViewResultsForQuery: (_, query) => items.filter((item) => item.toLowerCase().includes(query.toLowerCase())),
};

test('the search view lists the cache first, filters while typing and caches on submit', () => {
  const view = new CYLSearchView(memoryStorage());
  view.suggestions = ['Swift', 'Kotlin', 'Flutter'];
  assert.equal(view.showsEmptySuggestions, true, 'an empty cache shows the placeholder');
  view.setQuery('Flutter', true);
  view.setQuery('Kotlin', true);
  view.setQuery('', false);
  assert.deepEqual(view.filteredSuggestions, ['Kotlin', 'Flutter']);
  assert.equal(view.showsCachedQueries, true);
  assert.equal(view.showsEmptySuggestions, false);
  view.textChanged('t');
  assert.deepEqual(view.filteredSuggestions, ['Kotlin', 'Flutter', 'Swift'], 'cached matches first, no repeats');
  view.textChanged('');
  view.clearSuggestionCache();
  assert.equal(view.showsEmptySuggestions, true);
  view.suggestionCachePolicy = CYLSearchSuggestionCachePolicy.none;
  assert.equal(view.suggestionCache, undefined);
  assert.equal(view.showsEmptySuggestions, false);
});

test('focusesSearchFieldOnShow decides whether the keyboard is asked for, and focus alone changes nothing below', () => {
  const view = new CYLSearchView(memoryStorage());
  view.suggestions = ['Swift'];
  view.showsSuggestionsForEmptyQuery = true;
  view.showSearch(false);
  assert.equal(view.searchBarView.isKeyboardRequested, true);
  view.closeSearch(false);
  assert.equal(view.searchBarView.isKeyboardRequested, false);
  view.focusesSearchFieldOnShow = false;
  view.showSearch(false);
  assert.equal(view.searchBarView.isKeyboardRequested, false);
  const state = () => JSON.stringify([view.filteredSuggestions, view.showsCachedQueries, view.showsEmptyResults, view.showsEmptySuggestions]);
  const before = state();
  view.focusChanged(true);
  view.focusChanged(false);
  assert.equal(state(), before);
});

test('showSearch and closeSearch run their completion once the animation is over, also when nothing changes', async () => {
  const view = new CYLSearchView(memoryStorage());
  view.animationDuration = 0.01;
  const events = [];
  view.delegate = { searchViewDidShow: () => events.push('show'), searchViewDidClose: () => events.push('close') };
  await new Promise((resolve) => view.showSearch(true, resolve));
  assert.equal(view.isSearchOpen, true);
  await new Promise((resolve) => view.showSearch(true, resolve));
  await new Promise((resolve) => view.closeSearch(true, resolve));
  await new Promise((resolve) => view.closeSearch(true, resolve));
  assert.equal(view.isSearchOpen, false);
  assert.deepEqual(events, ['show', 'close']);
});

test('empty results show the placeholder only for a non-empty query that matches nothing', () => {
  const view = new CYLSearchView(memoryStorage());
  view.suggestions = ['Swift'];
  view.showsEmptyResultsPlaceholder = true;
  view.textChanged('zzz');
  assert.equal(view.showsEmptyResults, true);
  view.textChanged('sw');
  assert.equal(view.showsEmptyResults, false);
});

test('submit tells the delegate, closes unless handled, and selecting a suggestion can submit', () => {
  const view = new CYLSearchView(memoryStorage());
  const events = [];
  view.delegate = {
    searchViewDidSubmitText: (_, text) => { events.push(`submit ${text}`); return text === 'keep'; },
    searchViewDidClose: () => events.push('close'),
    searchViewDidSelectSuggestion: (_, suggestion, index) => events.push(`suggestion ${suggestion} ${index}`),
  };
  view.showSearch(false);
  view.setQuery('keep', true);
  assert.equal(view.isSearchOpen, true, 'handled: stays open');
  view.setQuery('go', true);
  assert.equal(view.isSearchOpen, false);
  view.submitsOnSuggestionSelection = true;
  view.suggestionSelected('Swift', 0);
  assert.equal(view.suggestionCache.cachedQueries()[0], 'Swift');
  assert.deepEqual(events, ['submit keep', 'submit go', 'close', 'suggestion Swift 0', 'submit Swift']);
});

test('the back arrow and Cancel close the search view unless the delegate takes the navigation button', () => {
  const view = new CYLSearchView(memoryStorage());
  view.showSearch(false);
  view.searchBarView.cancelTapped();
  assert.equal(view.isSearchOpen, false);
  view.showSearch(false);
  view.searchBarView.navigationTapped();
  assert.equal(view.isSearchOpen, false);
  let taps = 0;
  view.delegate = { searchViewNavigationButtonClicked: () => { taps += 1; } };
  view.showSearch(false);
  view.searchBarView.navigationTapped();
  assert.equal(view.isSearchOpen, true);
  assert.equal(taps, 1);
});

test('the results of the data source replace the suggestions for a non-empty query', () => {
  const view = new CYLSearchView(memoryStorage());
  view.suggestions = ['Swift'];
  view.showsSuggestionsForEmptyQuery = true;
  view.showsEmptyResultsPlaceholder = true;
  view.resultsDataSource = dataSource;
  assert.equal(view.showsResults, false, 'an empty query keeps the suggestions');
  assert.deepEqual(view.reloadResults(), []);
  view.textChanged('result 1');
  assert.equal(view.showsResults, true);
  assert.equal(view.searchResults.length, 11, 'Sample result 1, 10 to 19');
  assert.equal(view.showsEmptySuggestions, false);
  view.textChanged('nothing');
  assert.deepEqual(view.searchResults, []);
  assert.equal(view.showsEmptyResults, true, 'the empty results placeholder covers an empty result list');
  view.showsResultsForEmptyQuery = true;
  view.setQuery('', false);
  assert.equal(view.searchResults.length, 40);
  view.searchResults.push('changed');
  assert.equal(view.searchResults.length, 40, 'searchResults is read-only');
});

test('a result row is configured by the data source and its selection goes to the delegate', () => {
  const view = new CYLSearchView(memoryStorage());
  const selected = [];
  view.delegate = { searchViewDidSelectResult: (_, result, index) => selected.push([result, index]) };
  assert.deepEqual(view.resultCell('Plain'), { title: 'Plain', subtitle: '', accessibilityLabel: 'Plain' });
  view.resultsDataSource = Object.assign({}, dataSource, {
    searchViewConfigureResultCell: (_, cell, result) => { cell.title = result.name; cell.subtitle = result.detail; },
  });
  assert.deepEqual(view.resultCell({ name: 'Swift', detail: 'Apple' }), { title: 'Swift', subtitle: 'Apple', accessibilityLabel: 'Swift, Apple' });
  view.resultSelected('Sample result 2', 1);
  assert.deepEqual(selected, [['Sample result 2', 1]]);
});

test('refresh: beginRefreshing calls the handler once, endRefreshing ends it, the static API reaches any target', () => {
  const view = new CYLSearchView(memoryStorage());
  view.beginRefreshing();
  assert.equal(view.isRefreshing, false, 'no handler, no refresh');
  let calls = 0;
  view.refreshHandler = () => { calls += 1; };
  view.beginRefreshing();
  view.beginRefreshing();
  assert.equal(calls, 1);
  assert.equal(view.isRefreshing, true);
  view.endRefreshing();
  assert.equal(view.isRefreshing, false);

  const other = new CYLSearchView(memoryStorage());
  CYLSearchView.setRefreshHandler(() => { calls += 1; }, other);
  CYLSearchView.beginRefreshing(other);
  assert.equal(CYLSearchView.isRefreshing(other), true);
  CYLSearchView.endRefreshing(other);
  assert.equal(CYLSearchView.isRefreshing(other), false);
  assert.equal(calls, 2);

  // A <cyl-search> instance: its methods are called.
  const log = [];
  const component = {
    setRefreshHandler: (handler) => log.push(typeof handler),
    beginRefreshing: () => log.push('begin'),
    endRefreshing: () => log.push('end'),
    isRefreshing: () => true,
  };
  CYLSearchView.setRefreshHandler(() => {}, component);
  CYLSearchView.beginRefreshing(component);
  CYLSearchView.endRefreshing(component);
  assert.equal(CYLSearchView.isRefreshing(component), true);
  assert.deepEqual(log, ['function', 'begin', 'end']);
  assert.throws(() => CYLSearchView.beginRefreshing(undefined), TypeError);
});

test('the restorable state reopens the search view with its query', () => {
  const view = new CYLSearchView(memoryStorage());
  view.showSearch(false);
  view.setQuery('Swift', false);
  const copy = new CYLSearchView(memoryStorage());
  copy.decodeRestorableState(view.encodeRestorableState());
  assert.equal(copy.isSearchOpen, true);
  assert.equal(copy.query, 'Swift');
  assert.equal(copy.accessibilityPerformEscape(), true);
  assert.equal(copy.isSearchOpen, false);
});
