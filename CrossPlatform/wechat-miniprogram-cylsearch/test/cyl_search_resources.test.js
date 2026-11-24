// The resources module (src/core/CYLSearchResources.js): strings, formats, navigation metrics and the suggestion cache.
const test = require('node:test');
const assert = require('node:assert/strict');
const {
  CYLSearchResources, CYLSearchSuggestionCachePolicy, CYLSearchSuggestionCache, cylSuggestionCache, cylFormatString,
  cylNavigationMetricsFrom,
} = require('../src/core/CYLSearchResources');

function memoryStorage() {
  const values = {};
  return { getSync: (key) => values[key], setSync: (key, value) => { values[key] = value; }, values };
}

test('strings fall back to English, then to the key; language tags map to the tables', () => {
  assert.equal(CYLSearchResources.localizedString(null, 'search.cancel', 'ja'), 'キャンセル');
  assert.equal(CYLSearchResources.localizedString(null, 'search.cancel', 'fr'), 'Cancel');
  assert.equal(CYLSearchResources.localizedString(null, 'no.such.key', 'en'), 'no.such.key');
  assert.equal(CYLSearchResources.languageFor('zh_TW'), 'zh-Hant');
  assert.equal(CYLSearchResources.languageFor('zh-Hans-CN'), 'zh-Hans');
  assert.equal(CYLSearchResources.imageNamed('camera'), '../images/camera.svg');
  assert.equal(CYLSearchResources.imageNamed('nothing'), undefined);
});

test('formats keep the iOS and Android forms', () => {
  assert.equal(cylFormatString('Search %1$d of %2$d', [1, 3]), 'Search 1 of 3');
  assert.equal(CYLSearchResources.formatString('%@ and %d%%', ['a', 2]), 'a and 2%');
});

test('the navigation bar is centered on the menu button and ends before it', () => {
  const metrics = cylNavigationMetricsFrom({ statusBarHeight: 44, windowWidth: 390 }, { top: 48, height: 32, left: 296, right: 383 });
  assert.equal(metrics.navigationBarHeight, 40);
  assert.equal(metrics.trailingInset, 101);
  assert.equal(cylNavigationMetricsFrom(null, null).navigationBarHeight, 44);
});

test('every policy keeps submitted queries newest first, without repeats', () => {
  for (const policy of [CYLSearchSuggestionCachePolicy.database, CYLSearchSuggestionCachePolicy.userDefaults, CYLSearchSuggestionCachePolicy.sandboxFile]) {
    const store = cylSuggestionCache(policy, 'a', memoryStorage());
    assert.ok(store instanceof CYLSearchSuggestionCache);
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
  assert.equal(cylSuggestionCache(CYLSearchSuggestionCachePolicy.none, 'a', memoryStorage()), undefined);
});

test('the cache keeps at most maximumCount queries, separates names and shares the user defaults key', () => {
  const storage = memoryStorage();
  const store = cylSuggestionCache(CYLSearchSuggestionCachePolicy.database, 'one', storage);
  store.maximumCount = 3;
  ['a', 'b', 'c', 'd'].forEach((query) => store.addQuery(query));
  assert.deepEqual(store.cachedQueries(), ['d', 'c', 'b']);
  assert.deepEqual(cylSuggestionCache(CYLSearchSuggestionCachePolicy.database, 'two', storage).cachedQueries(), []);
  cylSuggestionCache(CYLSearchSuggestionCachePolicy.userDefaults, 'x', storage).addQuery('one');
  cylSuggestionCache(CYLSearchSuggestionCachePolicy.userDefaults, 'y', storage).addQuery('two');
  assert.deepEqual(Object.keys(storage.values.CYLSearchSuggestionDefaults).sort(), ['x', 'y']);
  // The JSON text earlier versions stored is still read.
  storage.values.CYLSearchSuggestions_old = '["kept"]';
  assert.deepEqual(cylSuggestionCache(CYLSearchSuggestionCachePolicy.database, 'old', storage).cachedQueries(), ['kept']);
});

test('the refresh icon and its label tagList.refresh are built into the core in four languages', () => {
  const fs = require('node:fs');
  const path = require('node:path');
  const labels = { en: 'Refresh', ja: '更新', 'zh-Hans': '刷新', 'zh-Hant': '重新整理' };
  for (const [language, label] of Object.entries(labels)) {
    assert.equal(CYLSearchResources.localizedString(null, 'tagList.refresh', language), label, language);
  }
  assert.equal(CYLSearchResources.imageNamed('refresh'), '../images/refresh.svg');
  assert.ok(fs.existsSync(path.join(__dirname, '..', 'src', 'images', 'refresh.svg')), 'the SVG lives in the core package');
});

test('the field embedded in the navigation bar is 36 high, with or without a menu button', () => {
  assert.equal(cylNavigationMetricsFrom(null, null).fieldHeight, 36);
  assert.equal(cylNavigationMetricsFrom({ statusBarHeight: 44, windowWidth: 390 }, { top: 48, height: 32, left: 296, right: 383 }).fieldHeight, 36);
});

test('the navigation bar measures the width left for the bar beside the back button and the menu button', () => {
  const { cylNavigationBarWidthsFrom, CYL_NAVIGATION_BACK_WIDTH } = require('../src/core/CYLSearchResources');
  const window = { statusBarHeight: 44, windowWidth: 390 };
  const menu = { top: 48, height: 32, left: 296, right: 383 };
  // Trailing inset: 390 - 296 + 390 - 383 = 101; leading 16.
  const withBack = cylNavigationBarWidthsFrom(window, menu, true);
  assert.equal(withBack.trailing, 101);
  assert.equal(withBack.back, CYL_NAVIGATION_BACK_WIDTH);
  assert.equal(withBack.fieldWidth, 390 - 16 - 101 - CYL_NAVIGATION_BACK_WIDTH);
  const plain = cylNavigationBarWidthsFrom(window, menu, false);
  assert.equal(plain.fieldWidth, 390 - 16 - 101);
  // Without a menu button rectangle both sides keep the 16 margin; a tiny window never goes negative.
  assert.equal(cylNavigationBarWidthsFrom(window, null, true).fieldWidth, 390 - 16 - 16 - CYL_NAVIGATION_BACK_WIDTH);
  assert.equal(cylNavigationBarWidthsFrom({ windowWidth: 80 }, null, true).fieldWidth, 8);
  assert.equal(cylNavigationBarWidthsFrom({ windowWidth: 30 }, null, true).fieldWidth, 0);
});
