// The accessibility label of the refresh button (cyl-search-refresh-button): the localized `tagList.refresh` in every
// language, the `label` property overriding it, and the template reading it as the button's aria-label (the icon is hidden).
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const folder = path.join(__dirname, '..', 'src', 'cyl-search-refresh-button');
const LABELS = { en: 'Refresh', 'en-US': 'Refresh', ja: '更新', 'zh-Hans': '刷新', 'zh_CN': '刷新', 'zh-Hant': '重新整理', zh_TW: '重新整理' };

/** Loads the component with a stub of the `Component` and `wx` globals, attaches it, and returns what it set. */
function attach(language, label = '') {
  let definition;
  global.Component = (options) => { definition = options; };
  global.wx = { getAppBaseInfo: () => ({ language }) };
  delete require.cache[require.resolve(path.join(folder, 'index.js'))];
  require(path.join(folder, 'index.js'));
  const instance = {
    properties: { label }, data: {}, setData(values) { Object.assign(this.data, values); },
    triggerEvent(name, detail) { (this.events = this.events || []).push([name, detail]); },
  };
  definition.lifetimes.attached.call(instance);
  return { instance, methods: definition.methods };
}

test('the label of the refresh button is tagList.refresh in the language of WeChat', () => {
  for (const [language, label] of Object.entries(LABELS)) {
    assert.equal(attach(language).instance.data.text, label, language);
  }
});

test('the label property overrides the localized label', () => {
  assert.equal(attach('en', 'Next topics').instance.data.text, 'Next topics');
});

test('the icon is the built-in refresh image and a tap sends tap', () => {
  const { instance, methods } = attach('en');
  assert.match(instance.data.icon, /refresh\.svg$/);
  methods.onTap.call(instance);
  assert.deepEqual(instance.events, [['tap', {}]]);
});

test('the template makes the button a labelled button and hides the icon from screen readers', () => {
  const wxml = fs.readFileSync(path.join(folder, 'index.wxml'), 'utf8');
  assert.match(wxml, /role="button"[^>]*aria-label="\{\{text\}\}"|aria-label="\{\{text\}\}"[^>]*role="button"/);
  assert.match(wxml, /<image[^>]*aria-hidden="true"/);
});
