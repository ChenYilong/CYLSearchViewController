const test = require('node:test');
const assert = require('node:assert/strict');
const { CYLSearchViewModel } = require('../src/cyl-search/cyl_search_view_model');
const { CYLSearchSuggestionCachePolicy, CYLSearchSuggestionStore } = require('../src/cyl-search/cyl_search_suggestion_cache');

function memoryStorage() {
  const values = {};
  return { getSync: (key) => values[key], setSync: (key, value) => { values[key] = value; }, values };
}

test('every policy keeps submitted queries newest first, without repeats', () => {
  for (const policy of [CYLSearchSuggestionCachePolicy.database, CYLSearchSuggestionCachePolicy.userDefaults, CYLSearchSuggestionCachePolicy.sandboxFile]) {
    const store = CYLSearchSuggestionStore.cache(policy, 'a', memoryStorage());
    store.addQuery('Swift');
    store.addQuery('Kotlin');
    store.addQuery(' Swift ');
    store.addQuery('   ');
    assert.deepEqual(store.cachedQueries(), ['Swift', 'Kotlin']);
    store.removeQuery('Swift');
    assert.deepEqual(store.cachedQueries(), ['Kotlin']);
    store.removeAllQueries();
    assert.deepEqual(store.cachedQueries(), []);
  }
  assert.equal(CYLSearchSuggestionStore.cache(CYLSearchSuggestionCachePolicy.none, 'a', memoryStorage()), null);
});

test('the cache keeps at most maximumCount queries and separates names', () => {
  const storage = memoryStorage();
  const store = new CYLSearchSuggestionStore(CYLSearchSuggestionCachePolicy.database, 'one', storage);
  store.maximumCount = 3;
  ['a', 'b', 'c', 'd'].forEach((query) => store.addQuery(query));
  assert.deepEqual(store.cachedQueries(), ['d', 'c', 'b']);
  assert.deepEqual(new CYLSearchSuggestionStore(CYLSearchSuggestionCachePolicy.database, 'two', storage).cachedQueries(), []);
});

test('the search page lists the cache first, filters while typing and caches on submit', () => {
  const model = new CYLSearchViewModel(memoryStorage());
  model.suggestions = ['Swift', 'Kotlin', 'Flutter'];
  assert.equal(model.showsEmptySuggestions, true, 'an empty cache shows the placeholder');
  model.setQuery('Flutter', true);
  model.setQuery('Kotlin', true);
  model.setQuery('', false);
  assert.deepEqual(model.filteredSuggestions, ['Kotlin', 'Flutter']);
  assert.equal(model.showsCachedQueries, true);
  assert.equal(model.showsEmptySuggestions, false);
  model.textChanged('t');
  assert.deepEqual(model.filteredSuggestions, ['Kotlin', 'Flutter', 'Swift'], 'cached matches first, no repeats');
  model.textChanged('');
  model.clearSuggestionCache();
  assert.equal(model.showsEmptySuggestions, true);
});

test('focusesSearchFieldOnShow decides whether the field is focused, and focus alone changes nothing below', () => {
  const model = new CYLSearchViewModel(memoryStorage());
  model.suggestions = ['Swift'];
  model.showsSuggestionsForEmptyQuery = true;
  assert.deepEqual(model.showSearch(), { focus: true });
  model.closeSearch();
  model.focusesSearchFieldOnShow = false;
  assert.deepEqual(model.showSearch(), { focus: false });
  const before = JSON.stringify([model.filteredSuggestions, model.showsCachedQueries, model.showsEmptyResults, model.showsEmptySuggestions]);
  model.focusChanged(true);
  model.focusChanged(false);
  assert.equal(JSON.stringify([model.filteredSuggestions, model.showsCachedQueries, model.showsEmptyResults, model.showsEmptySuggestions]), before);
});

test('empty results show the placeholder only for a non-empty query that matches nothing', () => {
  const model = new CYLSearchViewModel(memoryStorage());
  model.suggestions = ['Swift'];
  model.showsEmptyResultsPlaceholder = true;
  model.textChanged('zzz');
  assert.equal(model.showsEmptyResults, true);
  model.textChanged('sw');
  assert.equal(model.showsEmptyResults, false);
});

test('submit tells the delegate, closes unless handled, and selecting a suggestion can submit', () => {
  const model = new CYLSearchViewModel(memoryStorage());
  const events = [];
  model.delegate = { onSubmit: (_, text) => { events.push(`submit ${text}`); return text === 'keep'; }, onClose: () => events.push('close') };
  model.showSearch();
  model.setQuery('keep', true);
  assert.equal(model.isSearchOpen, true, 'handled: stays open');
  model.setQuery('go', true);
  assert.equal(model.isSearchOpen, false);
  assert.deepEqual(events, ['submit keep', 'submit go', 'close']);
  model.submitsOnSuggestionSelection = true;
  model.suggestionSelected('Swift', 0);
  assert.equal(model.suggestionCache.cachedQueries()[0], 'Swift');
});
