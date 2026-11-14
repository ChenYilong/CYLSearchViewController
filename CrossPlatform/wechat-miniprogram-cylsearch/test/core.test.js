// The core ported from the HarmonyOS models (src/core), with a stub of `wx` storage.
const test = require('node:test');
const assert = require('node:assert');

const storage = {};
global.wx = {
  env: { USER_DATA_PATH: '/tmp' },
  getStorageSync: (key) => storage[key],
  setStorageSync: (key, value) => { storage[key] = value; },
  getAppBaseInfo: () => ({ language: 'en' }),
  getFileSystemManager: () => ({ accessSync() { throw new Error('missing'); }, readFileSync() { return '[]'; }, writeFileSync() {} }),
};

const { CYLSearchSuggestionStore, CYLSearchSuggestionCachePolicy } = require('../src/core/CYLSearchSuggestionCache');
const { CYLSearchBarView } = require('../src/core/CYLSearchBarView');
const { CYLSearchBarItem, CYLSearchBarItemStyle } = require('../src/core/CYLSearchBarItem');
const { CYLSearchView } = require('../src/core/CYLSearchView');
const { CYLSearchResources } = require('../src/core/CYLSearchResources');

test('the database store keeps the newest query first, once', () => {
  const store = CYLSearchSuggestionStore.cache({}, CYLSearchSuggestionCachePolicy.database, 'core-test');
  store.addQuery('Swift');
  store.addQuery('Kotlin');
  store.addQuery('Swift');
  assert.deepStrictEqual(store.cachedQueries(), ['Swift', 'Kotlin']);
  store.removeAllQueries();
  assert.deepStrictEqual(store.cachedQueries(), []);
});

test('user defaults share one storage key between caches', () => {
  const first = CYLSearchSuggestionStore.cache({}, CYLSearchSuggestionCachePolicy.userDefaults, 'a');
  const second = CYLSearchSuggestionStore.cache({}, CYLSearchSuggestionCachePolicy.userDefaults, 'b');
  first.addQuery('one');
  second.addQuery('two');
  assert.deepStrictEqual(Object.keys(storage.CYLSearchSuggestionDefaults).sort(), ['a', 'b']);
  assert.strictEqual(CYLSearchSuggestionStore.cache({}, CYLSearchSuggestionCachePolicy.none, 'x'), undefined);
});

test('the search bar adds, inserts and removes items', () => {
  const bar = new CYLSearchBarView();
  const camera = new CYLSearchBarItem(CYLSearchBarItemStyle.icon, 'Camera', 'camera');
  const divider = new CYLSearchBarItem(CYLSearchBarItemStyle.divider);
  bar.addItem(camera);
  bar.insertItem(divider, 0);
  assert.deepStrictEqual(bar.items, [divider, camera]);
  bar.removeItem(divider);
  assert.deepStrictEqual(bar.items, [camera]);
});

test('an item from plain values keeps its flags', () => {
  const item = CYLSearchBarItem.item({ style: 'text', title: 'Search', isSelectable: true, badgeValue: '3' });
  assert.strictEqual(item.style, CYLSearchBarItemStyle.text);
  assert.strictEqual(item.title, 'Search');
  assert.strictEqual(item.isSelectable, true);
  assert.strictEqual(item.badgeValue, '3');
});

test('the search view filters its suggestions by the query', () => {
  const view = new CYLSearchView();
  view.suggestions = ['Swift', 'Objective-C', 'Kotlin'];
  view.searchBarView.setText('sw', false);
  view.refilter();
  assert.deepStrictEqual(view.filteredSuggestions, ['Swift']);
});

test('strings fall back to English, then to the key', () => {
  assert.notStrictEqual(CYLSearchResources.localizedString(null, 'search.placeholder', 'ja'), 'search.placeholder');
  assert.strictEqual(CYLSearchResources.localizedString(null, 'no.such.key', 'en'), 'no.such.key');
  assert.strictEqual(CYLSearchResources.languageFor('zh_TW'), 'zh-Hant');
  assert.strictEqual(CYLSearchResources.imageNamed('camera'), '../images/camera.svg');
});
