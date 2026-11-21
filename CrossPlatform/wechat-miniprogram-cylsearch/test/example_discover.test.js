// The Discover page's rules, as on iOS (CYLSearchDiscoverData, CYLSearchDiscoverViewController).
const test = require('node:test');
const assert = require('node:assert');
const { cylRandomTopics, cylSearchedRecent } = require('../example/miniprogram/utils/cyl_discover_logic');
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

test('refreshed topics differ from the shown ones while the pool allows', () => {
  const pool = Array.from({ length: 12 }, (_, i) => ({ title: `T${i}` }));
  const current = pool.slice(0, 6);
  let seed = 1;
  const random = () => {
    seed = (seed * 16807) % 2147483647;
    return (seed - 1) / 2147483646;
  };
  const next = cylRandomTopics(pool, current, 6, random);
  assert.strictEqual(next.length, 6);
  assert.ok(next.every((topic) => !current.some((shown) => shown.title === topic.title)));
  // A pool smaller than twice the count fills up with shown topics.
  const small = pool.slice(0, 8);
  const filled = cylRandomTopics(small, small.slice(0, 6), 6, random);
  assert.strictEqual(filled.length, 6);
  assert.strictEqual(new Set(filled.map((t) => t.title)).size, 6);
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
