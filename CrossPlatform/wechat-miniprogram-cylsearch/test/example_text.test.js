// The example's texts follow the iOS bundles: same keys, same formats, same languages.
const test = require('node:test');
const assert = require('node:assert');
const { cylDemoText, cylDemoLanguage, cylFormat, cylDiscoverData, cylSetDemoLanguage, cylAllDiscoverData } = require('../example/miniprogram/utils/cyl_demo_text');
const resources = require('../example/miniprogram/utils/cyl_demo_resources');

test('WeChat languages map to the iOS localizations', () => {
  assert.strictEqual(cylDemoLanguage('zh_CN'), 'zh-Hans');
  assert.strictEqual(cylDemoLanguage('zh_TW'), 'zh-Hant');
  assert.strictEqual(cylDemoLanguage('zh_HK'), 'zh-Hant');
  assert.strictEqual(cylDemoLanguage('ja'), 'ja');
  assert.strictEqual(cylDemoLanguage('en'), 'en');
  assert.strictEqual(cylDemoLanguage(''), 'en');
});

test('iOS formats are filled in order and by position', () => {
  assert.strictEqual(cylFormat('Query: %@', ['Swift']), 'Query: Swift');
  assert.strictEqual(cylFormat('Sample result %lu', [7]), 'Sample result 7');
  assert.strictEqual(cylFormat('Search %1$lu of %2$lu', [2, 3]), 'Search 2 of 3');
  assert.strictEqual(cylFormat('%2$lu / %1$lu', [2, 3]), '3 / 2');
});

test('the example texts are the iOS ones in every language', () => {
  cylSetDemoLanguage('en');
  assert.strictEqual(cylDemoText('demo.port.searched', 'abc'), 'Search content===abc');
  assert.strictEqual(cylDemoText('tab.tagStyle'), 'Tag style');
  cylSetDemoLanguage('zh-Hans');
  assert.strictEqual(cylDemoText('discover.title'), '发现');
  cylSetDemoLanguage('');
  for (const language of resources.languages) {
    assert.deepStrictEqual(Object.keys(resources.strings[language]).sort(), Object.keys(resources.strings.en).sort(), language);
  }
});

test('the embedded discover data equals the json copies the sync script checks', () => {
  for (const language of resources.languages) {
    const copy = require(`../example/miniprogram/utils/discover/${language}.json`);
    const embedded = JSON.parse(JSON.stringify(resources.discover[language]));
    delete copy.comment;
    assert.deepStrictEqual(embedded, copy, language);
  }
});

test('the discover data has the same topics in every language', () => {
  cylSetDemoLanguage('en');
  assert.strictEqual(cylDiscoverData().discoverCount, 6);
  for (const language of resources.languages) {
    assert.strictEqual(cylAllDiscoverData[language].discover.length, cylAllDiscoverData.en.discover.length, language);
  }
  cylSetDemoLanguage('');
});
