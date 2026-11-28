// The Discover page's rules, as on iOS (CYLSearchDiscoverData, CYLSearchDiscoverViewController).
const test = require('node:test');
const assert = require('node:assert');
const { cylTopicPage, cylNextTopicPage, cylSearchedRecent, cylDiscoverCloudTags, cylHotIconSize, cylDiscoverCloudStyle } = require('../example/miniprogram/utils/cyl_discover_logic');
const fs = require('node:fs');
const path = require('node:path');
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

test('the topics are the tags of the ClassifyMenu tag cloud: a hot topic carries the hot icon and its label', () => {
  const tags = cylDiscoverCloudTags([{ title: 'A' }, { title: 'B', icon: 'hot' }], '/hot.png', 'Hot');
  assert.deepStrictEqual(tags, [
    { identifier: 0, title: 'A', isEnabled: true, isDeletable: false },
    { identifier: 1, title: 'B', isEnabled: true, isDeletable: false, image: '/hot.png', imageLabel: 'Hot' },
  ]);
  assert.strictEqual(cylHotIconSize('en'), 30);
  assert.strictEqual(cylHotIconSize('zh-Hans'), 18);
});

test('the grid style is the iOS discoverStyle() over the base style of the cloud and does not change the base', () => {
  const state = () => ({ backgroundColor: '#F2F2F7', borderColor: '#D1D1D1', borderWidth: 0.5, fontSize: 14, textColor: '#444', contentInsets: { top: 5, left: 10, bottom: 5, right: 10 } });
  const base = { normal: state(), selected: state(), disabled: state(), numberOfItemsPerRow: 0, itemHeight: 30, imageSize: 14, backgroundColor: '#fff', sectionInsets: { top: 10, left: 16, bottom: 10, right: 16 } };
  const style = cylDiscoverCloudStyle(base, { dark: true, iconSize: 30 });
  assert.strictEqual(style.numberOfItemsPerRow, 2);
  assert.strictEqual(style.itemHeight, 36);
  assert.strictEqual(style.lineSpacing, 16);
  assert.strictEqual(style.imageSize, 30);
  assert.deepStrictEqual(style.sectionInsets, { top: 4, left: 16, bottom: 16, right: 16 });
  for (const name of ['normal', 'selected', 'disabled']) {
    assert.strictEqual(style[name].fontSize, 17);
    assert.strictEqual(style[name].borderWidth, 0);
    assert.strictEqual(style[name].textColor, '#FFFFFF');
  }
  assert.strictEqual(cylDiscoverCloudStyle(base).normal.textColor, '#000000');
  assert.strictEqual(base.numberOfItemsPerRow, 0);
  assert.strictEqual(base.normal.fontSize, 14);
});

// The synced tag cloud (example/miniprogram/miniprogram_npm, git-ignored, made by `npm run sync-example`): when it is there,
// a hot topic renders as an equal cell of two per row with its icon and reads "title, label".
const cloudModel = path.join(__dirname, '../example/miniprogram/miniprogram_npm/cyl-tag-list-miniprogram/cyl-tag-cloud/model.js');
test('the synced tag cloud renders the grid cell of a hot topic', { skip: !fs.existsSync(cloudModel) }, () => {
  const model = require(cloudModel);
  const listStyle = cylDiscoverCloudStyle(model.defaultStyle(), { iconSize: 30 });
  const [plain, hot] = cylDiscoverCloudTags([{ title: 'A' }, { title: 'B', icon: 'hot' }], '/hot.png', 'Hot')
    .map((tag, index) => model.renderTag(tag, index, { listStyle, theme: 'none' }));
  assert.match(plain.style, /width: calc\(\(100% - 24px\) \/ 2\)/);
  assert.strictEqual(plain.icon, null);
  assert.strictEqual(plain.accessibilityLabel, 'A');
  assert.strictEqual(hot.icon.image, '/hot.png');
  assert.strictEqual(hot.accessibilityLabel, 'B, Hot');
});

// The hot icon's screen reader label (iOS bridges send it as tagImageLabels): `discover.hot` in each language is the
// tag's imageLabel; the cloud hides the icon from the screen reader (aria-hidden) and reads it in the label of the cell
// ("title, label"), so the label reaches the screen reader without an aria-label on the picture itself.
test('the hot label is Hot, 人気, 热门 and 熱門 and every language passes it as the imageLabel of the hot topic', () => {
  const { cylDemoText, cylSetDemoLanguage } = require('../example/miniprogram/utils/cyl_demo_text');
  const expected = { en: 'Hot', ja: '人気', 'zh-Hans': '热门', 'zh-Hant': '熱門' };
  try {
    for (const [language, label] of Object.entries(expected)) {
      cylSetDemoLanguage(language);
      assert.strictEqual(cylDemoText('discover.hot'), label, language);
      const [, hot] = cylDiscoverCloudTags([{ title: 'A' }, { title: 'B', icon: 'hot' }], '/hot.png', cylDemoText('discover.hot'));
      assert.strictEqual(hot.imageLabel, label, language);
      if (fs.existsSync(cloudModel)) {
        const model = require(cloudModel);
        const rendered = model.renderTag(hot, 1, { listStyle: model.defaultStyle(), theme: 'none' });
        assert.strictEqual(rendered.accessibilityLabel, `B, ${label}`, language);
      }
    }
  } finally {
    cylSetDemoLanguage('en');
  }
});

test('the Discover page passes discover.hot to the hot topics', () => {
  const page = fs.readFileSync(path.join(__dirname, '../example/miniprogram/pages/discoverSearch/index.js'), 'utf8');
  assert.match(page, /hot: cylDemoText\('discover\.hot'\)/);
  assert.match(page, /cylDiscoverCloudTags\(this\.data\.topics, this\.data\.hotIcon, this\.data\.texts\.hot\)/);
});
