// The default search button (owner directive 2026-11-26, docs/instructions/core.md rule 5, example-demos.md rule 9): the core's
// built-in button after the field and the owner's items, text or icon style, its item API (cornerRadius, borderColor,
// borderWidth, itemHeight), the concentric icon pill, the first-level field tap versus the button tap, and the checks that no
// example adds its own Search item or hides the button.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');

global.wx = {
  getStorageSync: () => undefined,
  setStorageSync: () => {},
  getAppBaseInfo: () => ({ language: 'en' }),
  nextTick: (fn) => fn(),
};

const core = require('../src/core/CYLSearchBarView');
const { CYLSearchBarView, CYLSearchBarItem } = core;
const { CYLSearchResources } = require('../src/core/CYLSearchResources');

const root = path.join(__dirname, '..');
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), 'utf8');

function loadBar(properties = {}) {
  let definition;
  global.Component = (options) => { definition = options; };
  const file = path.join(root, 'src', 'cyl-search-bar', 'index.js');
  delete require.cache[require.resolve(file)];
  require(file);
  const instance = { data: JSON.parse(JSON.stringify(definition.data)), properties: {}, events: [] };
  Object.entries(definition.properties).forEach(([key, spec]) => {
    instance.properties[key] = key in properties ? properties[key] : spec.value;
    instance.data[key] = instance.properties[key];
  });
  Object.assign(instance, definition.methods);
  instance.setData = (values) => {
    Object.entries(values).forEach(([key, value]) => {
      instance.data[key] = value;
      if (key in instance.properties) instance.properties[key] = value;
    });
  };
  instance.triggerEvent = (type, detail) => instance.events.push([type, detail]);
  instance.selectComponent = () => null;
  instance.createSelectorQuery = () => {
    const query = { selectAll: () => query, select: () => query, boundingClientRect: () => query, exec() {} };
    return query;
  };
  definition.lifetimes.created.call(instance);
  definition.lifetimes.attached.call(instance);
  return instance;
}

test('a bar keeps a default search button; never for an editing bar or in multiple mode', () => {
  const bar = new CYLSearchBarView();
  assert.equal(bar.showsSearchButton, true);
  assert.equal(bar.searchButtonStyle, 'text');
  assert.equal(bar.hasSearchButton, true);
  bar.showsSearchButton = false;
  assert.equal(bar.hasSearchButton, false);
  assert.equal(CYLSearchBarView.editingBar('Name', 'Add').hasSearchButton, false);
  const multiple = new CYLSearchBarView();
  multiple.mode = 'multiple';
  assert.equal(multiple.hasSearchButton, false);
  assert.equal(bar.items.length, 0, 'the search button is not in items');
});

test('text style: the localized "Search" (en, zh-Hans, zh-Hant, ja), a custom title wins; icon style: filled capsule 28 high', () => {
  const word = { en: 'Search', 'zh-Hans': '搜索', 'zh-Hant': '搜尋', ja: '検索' };
  Object.entries(word).forEach(([language, value]) => {
    assert.equal(CYLSearchResources.localizedString(undefined, 'search.button', language), value, language);
  });
  const bar = new CYLSearchBarView();
  const text = bar.searchButtonItem;
  assert.equal(text.style, 'text');
  assert.equal(text.title, 'Search');
  bar.searchButtonTitle = 'Go';
  assert.equal(bar.searchButtonItem.title, 'Go');
  bar.searchButtonStyle = 'icon';
  const icon = bar.searchButtonItem;
  assert.equal(icon.style, 'icon');
  assert.equal(icon.cornerRadius, core.CYLSearchBarItemCornerRadiusCapsule);
  assert.equal(icon.itemHeight, 28);
  assert.equal(icon.contentInsets, 16);
  assert.ok(icon.image, 'the core has a built-in magnifier');
  bar.searchButtonImage = '/custom.svg';
  assert.equal(bar.searchButtonItem.image, '/custom.svg');
  assert.deepEqual(core.cylSearchButtonColors(false), { fill: '#000000', glyph: '#FFFFFF' });
  assert.deepEqual(core.cylSearchButtonColors(true), { fill: '#FFFFFF', glyph: '#000000' });
});

test('item API: cornerRadius, borderColor, borderWidth, itemHeight reach the tag style', () => {
  const item = CYLSearchBarItem.iconItem('/a.svg', 'A');
  assert.equal(item.cornerRadius, core.CYLSearchBarItemCornerRadiusAutomatic);
  assert.equal(item.tagButtonProperties(undefined, false).tagStyle.itemHeight, 36);
  assert.equal(item.tagButtonProperties(undefined, false).tagStyle.normal.cornerRadius, 0);
  item.backgroundColor = '#000';
  assert.equal(item.tagButtonProperties(undefined, false).tagStyle.normal.cornerRadius, 10);
  item.cornerRadius = core.CYLSearchBarItemCornerRadiusCapsule;
  item.borderColor = '#FF0000';
  item.borderWidth = 2;
  item.itemHeight = 28;
  const style = item.tagButtonProperties(undefined, false).tagStyle;
  assert.equal(style.itemHeight, 28);
  assert.equal(style.normal.cornerRadius, 1000);
  assert.equal(style.normal.borderWidth, 2);
  assert.equal(style.normal.borderColor, '#FF0000');
});

test('a tap submits the text; the listener also fires for empty text; the handler runs after', () => {
  const bar = new CYLSearchBarView();
  const log = [];
  bar.delegate = { searchBarViewSearchButtonClicked: (view) => log.push(`clicked:${view.text}`) };
  bar.searchButtonHandler = () => log.push('handler');
  bar.searchButtonTapped();
  bar.setText('swift');
  bar.searchButtonTapped();
  assert.deepEqual(log, ['clicked:', 'handler', 'clicked:swift', 'handler']);
});

test('the icon pill is concentric: gap above == gap below == gap at the right', () => {
  const look = core.cylSearchButtonLook('icon', undefined, 'Search', false);
  [36, 40, 44].forEach((fieldHeight) => {
    const top = (fieldHeight - look.itemHeight) / 2;
    const bottom = fieldHeight - look.itemHeight - top;
    const right = core.cylSearchButtonTrailingInset(fieldHeight, look.itemHeight, 12, true);
    assert.equal(top, bottom);
    assert.equal(right, top);
  });
  assert.equal(core.cylSearchButtonTrailingInset(36, 28, 12, true), 4);
  assert.equal(core.cylSearchButtonTrailingInset(36, 0, 12, false), 12);
});

test('cyl-search-bar: divider only after an owner item, icon style padding, tap submits, editing and multiple have none', () => {
  const plain = loadBar();
  assert.equal(plain.data.searchButton.visible, true);
  assert.equal(plain.data.searchButton.hasDivider, false);
  assert.equal(plain.data.searchButton.button.title, 'Search');
  assert.equal(plain.data.fieldPadStyle, '');

  const withItem = loadBar({ items: [{ style: 'icon', title: 'Camera', image: '/c.svg' }], searchButtonStyle: 'icon', fieldHeight: 36 });
  assert.equal(withItem.data.searchButton.hasDivider, true);
  assert.equal(withItem.data.searchButton.button.tagStyle.itemHeight, 28);
  assert.equal(withItem.data.searchButton.button.tagStyle.normal.backgroundColor, '#000000');
  assert.equal(withItem.data.searchButton.button.tagStyle.normal.iconColor, '#FFFFFF');
  assert.equal(withItem.data.fieldPadStyle, 'padding-right: 4px', 'concentric: 4 = (36 - 28) / 2');

  plain.onInput({ detail: { value: 'kotlin' } });
  plain.onSearchButtonTap();
  assert.deepEqual(plain.events.filter(([type]) => type === 'submit'), [['submit', { text: 'kotlin' }]]);
  const empty = loadBar();
  empty.onSearchButtonTap();
  assert.deepEqual(empty.events, [['submit', { text: '' }]], 'the listener also fires for empty text');

  assert.equal(loadBar({ editingBar: true }).data.searchButton.visible, false);
  assert.equal(loadBar({ mode: 'multiple' }).data.searchButton.visible, false);
  assert.equal(loadBar({ showsSearchButton: false }).data.searchButton.visible, false);
});

test('first-level: a tap on the field pushes, a tap on the search button submits', () => {
  const bar = loadBar({ pushesOnTap: true });
  bar.onNotEditableTap();
  assert.deepEqual(bar.events, [['firstleveltap', {}]]);
  bar.onSearchButtonTap();
  assert.deepEqual(bar.events[1], ['submit', { text: '' }]);
  const wxml = read('src', 'cyl-search-bar', 'index.wxml');
  assert.match(wxml, /disabled="\{\{!editable \|\| pushesOnTap\}\}"/);
  assert.match(wxml, /bindtap="onSearchButtonTap"/);
  assert.match(wxml, /fieldPadStyle/);
});

test('examples: every one shows the default search button, none adds its own Search item or hides it', () => {
  const example = path.join(root, 'example', 'miniprogram');
  const files = [];
  const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true }).forEach((entry) => {
    if (entry.name === 'miniprogram_npm' || entry.name === 'components' || entry.name === 'node_modules') return;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full);
    else if (/\.(js|wxml)$/.test(entry.name)) files.push(full);
  });
  walk(example);
  assert.ok(files.length > 20);
  files.forEach((file) => {
    const text = fs.readFileSync(file, 'utf8');
    const name = path.relative(example, file);
    assert.doesNotMatch(text, /style:\s*'text'[^}]*(discover\.search|Search)/, `${name} adds its own Search item`);
    assert.doesNotMatch(text, /CYLSearchDiscoverSearchButton/, `${name} keeps the old own Search button`);
    assert.doesNotMatch(text, /showsSearchButton\s*=\s*"?\{?\{?\s*false|showsSearchButton="\{\{false\}\}"|showsSearchButton="false"/,
      `${name} hides the default search button`);
  });
  // The bars of the examples never opt out; the Search tab shows the icon style, the others the text style.
  const bars = files.filter((file) => file.endsWith('.wxml') && /<cyl-search-bar/.test(fs.readFileSync(file, 'utf8')));
  assert.ok(bars.length >= 8, 'the examples draw the bar on many pages');
  assert.match(read('example', 'miniprogram', 'pages', 'search', 'index.wxml'), /searchButtonStyle="icon"/);
  assert.match(read('example', 'miniprogram', 'demo-components', 'cyl-demo-first-level-bar', 'index.wxml'), /searchButtonStyle="\{\{searchButtonStyle\}\}"/);
  const discover = read('example', 'miniprogram', 'pages', 'discoverSearch', 'index.js');
  assert.doesNotMatch(discover, /style: 'divider'/, 'the divider before the Search button is the core\'s');
  assert.match(discover, /image: CAMERA_IMAGE/, 'the camera stays an owner item');
});
