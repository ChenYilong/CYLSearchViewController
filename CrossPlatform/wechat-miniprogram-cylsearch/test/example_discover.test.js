// The Discover page's rules, as on iOS (CYLSearchDiscoverData, CYLSearchDiscoverViewController).
const test = require('node:test');
const assert = require('node:assert');
const { cylTopicPage, cylNextTopicPage, cylSearchedRecent } = require('../example/miniprogram/utils/cyl_discover_logic');
const { cylAllDiscoverData } = require('../example/miniprogram/utils/cyl_demo_text');
const { cylFoldTags } = require('../src/core/CYLSearchView');
const { cylNavigationMetricsFrom } = require('../src/core/CYLSearchResources');

test('tags that fit in two rows are not folded', () => {
  assert.deepStrictEqual(cylFoldTags([100, 100, 100], 400, 12, 40, 2), { visibleCount: 3, needsFold: false });
  assert.deepStrictEqual(cylFoldTags([], 400, 12, 40, 2), { visibleCount: 0, needsFold: false });
});

test('folded tags keep the first two rows with the chevron after the last visible tag', () => {
  // Rows of 400: [150, 150] then [150, 150], then more; the chevron (40) must fit after the last kept tag.
  const widths = [150, 150, 150, 150, 150, 150];
  const result = cylFoldTags(widths, 400, 12, 40, 2);
  assert.strictEqual(result.needsFold, true);
  // 150 + 12 + 150 + 12 + 40 = 364 fits on row 2, so all four tags of the two rows stay.
  assert.strictEqual(result.visibleCount, 4);
  // A wider chevron no longer fits after the fourth tag: it drops to make room.
  assert.strictEqual(cylFoldTags(widths, 400, 12, 120, 2).visibleCount, 3);
});

test('refresh shows the next page, cyclically, with no random pick', () => {
  const pool = Array.from({ length: 24 }, (_, i) => ({ title: `T${i}` }));
  assert.deepStrictEqual(cylTopicPage(pool, 6, 0).topics.map((t) => t.title), ['T0', 'T1', 'T2', 'T3', 'T4', 'T5']);
  let state = cylTopicPage(pool, 6, 0);
  const pages = [];
  for (let i = 0; i < 5; i += 1) {
    state = cylNextTopicPage(pool, 6, state.page);
    pages.push(state.page);
  }
  assert.deepStrictEqual(pages, [1, 2, 3, 0, 1]);
  assert.strictEqual(state.topics[0].title, 'T6');
  assert.strictEqual(cylTopicPage(pool, 6, -1).page, 3);
  // A pool that is not a whole number of pages keeps whole pages only.
  assert.strictEqual(cylTopicPage(pool.slice(0, 8), 6, 3).page, 0);
});

test('every language: 4 pages of 6, exactly one hot record per page, its slot differs from the next page', () => {
  for (const language of Object.keys(cylAllDiscoverData)) {
    const { discover, discoverCount } = cylAllDiscoverData[language];
    assert.strictEqual(discoverCount, 6, language);
    assert.strictEqual(discover.length, 24, language);
    let state = cylTopicPage(discover, discoverCount, 0);
    let previousSlot = -1;
    let firstSlot = -1;
    // Twice around the pages: each shows one hot record whose slot never equals the previous page's.
    for (let refresh = 0; refresh <= 8; refresh += 1) {
      const hot = state.topics.map((topic, slot) => (topic.icon === 'hot' ? slot : -1)).filter((slot) => slot >= 0);
      assert.strictEqual(hot.length, 1, `${language} page ${state.page}`);
      assert.notStrictEqual(hot[0], previousSlot, `${language} page ${state.page}`);
      if (refresh === 0) firstSlot = hot[0];
      if (refresh === 4) assert.strictEqual(hot[0], firstSlot, `${language} wraps to the first page`);
      previousSlot = hot[0];
      state = cylNextTopicPage(discover, discoverCount, state.page);
    }
  }
});

test('a search moves the query to the front of the recent searches, once', () => {
  assert.deepStrictEqual(cylSearchedRecent(['a', 'b', 'c'], ' c '), ['c', 'a', 'b']);
  assert.deepStrictEqual(cylSearchedRecent(['a'], 'new'), ['new', 'a']);
  assert.deepStrictEqual(cylSearchedRecent(['a'], '  '), ['a']);
});

test('a bar in the navigation bar is centered on the menu button and ends before it', () => {
  const metrics = cylNavigationMetricsFrom({ statusBarHeight: 44, windowWidth: 390 }, { top: 48, height: 32, left: 296, right: 383 });
  assert.strictEqual(metrics.navigationBarHeight, 40);
  assert.strictEqual(metrics.trailingInset, 94 + 7);
  assert.strictEqual(cylNavigationMetricsFrom({ statusBarHeight: 20, windowWidth: 375 }, null).navigationBarHeight, 44);
});
