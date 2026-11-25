// The navigation field preset (iOS applyNavigationFieldStyle()) on the core model, the cyl-search-bar component and the
// example pages: no page sets the preset's values itself, no system <input type="search"> / <search> remains.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const { CYLSearchBarView, cylNavigationFieldStyle, cylNavigationFieldFill } = require('../src/core/CYLSearchBarView');

const root = path.join(__dirname, '..');
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), 'utf8');

test('the preset: bordered capsule radius 18, shadow 0.06, no magnifier, 16 text, opaque white / black fill', () => {
  assert.deepEqual(cylNavigationFieldStyle(), { cornerRadius: 18, shadowOpacity: 0.06, fontSize: 16, showsSearchIcon: false, bordered: true });
  assert.equal(cylNavigationFieldFill(false), '#FFFFFF');
  assert.equal(cylNavigationFieldFill(true), '#000000');
});

test('CYLSearchBarView.applyNavigationFieldStyle sets the preset on the model', () => {
  const bar = new CYLSearchBarView();
  bar.applyNavigationFieldStyle();
  assert.equal(bar.searchIcon, undefined);
  assert.equal(bar.searchBarStyle, 'bordered');
  assert.equal(bar.fieldCornerRadius, 18);
  assert.equal(bar.fieldShadowOpacity, 0.06);
  assert.equal(bar.font, 16);
  assert.notEqual(bar.fieldBackgroundColor, undefined);
});

function loadBar() {
  let definition;
  global.wx = { getStorageSync: () => undefined, setStorageSync: () => {}, getAppBaseInfo: () => ({ language: 'en' }), nextTick: (fn) => fn() };
  global.Component = (options) => { definition = options; };
  const file = path.join(root, 'src', 'cyl-search-bar', 'index.js');
  delete require.cache[require.resolve(file)];
  require(file);
  const instance = { data: JSON.parse(JSON.stringify(definition.data)), properties: {}, events: [] };
  Object.entries(definition.properties).forEach(([key, spec]) => { instance.properties[key] = spec.value; instance.data[key] = spec.value; });
  Object.assign(instance, definition.methods);
  instance.setData = (values) => Object.entries(values).forEach(([key, value]) => {
    instance.data[key] = value;
    if (key in instance.properties) instance.properties[key] = value;
  });
  instance.triggerEvent = () => {};
  instance.createSelectorQuery = () => { const q = { selectAll: () => q, select: () => q, boundingClientRect: () => q, exec() {} }; return q; };
  definition.lifetimes.created.call(instance);
  definition.lifetimes.attached.call(instance);
  return { instance, definition };
}

test('cyl-search-bar: the property navigationFieldStyle and the method applyNavigationFieldStyle apply the preset', () => {
  const { instance, definition } = loadBar();
  assert.equal(definition.properties.navigationFieldStyle.value, false);
  instance.onNavigationFieldStyle(true);
  assert.equal(instance.properties.searchBarStyle, 'bordered');
  assert.equal(instance.properties.showsSearchIcon, false);
  assert.equal(instance.properties.fieldCornerRadius, 18);
  assert.equal(instance.properties.fieldShadowOpacity, 0.06);
  assert.equal(instance.properties.fontSize, 16);
  const other = loadBar().instance;
  other.applyNavigationFieldStyle();
  assert.equal(other.properties.navigationFieldStyle, true);
  assert.equal(other.properties.fieldCornerRadius, 18);
});

test('the component draws an opaque fill in light and dark for the preset', () => {
  const style = read('src', 'cyl-search-bar', 'index.wxss');
  assert.match(style, /\.cyl-bar-navigation \.cyl-field \{ background: #fff; \}/);
  assert.match(style, /prefers-color-scheme: dark[\s\S]*\.cyl-bar-navigation \.cyl-field \{ background: #000; \}/);
  assert.match(read('src', 'cyl-search-bar', 'index.wxml'), /cyl-bar-navigation/);
});

test('example pages call the preset and never set its values; no system search input', () => {
  const pages = path.join(root, 'example', 'miniprogram', 'pages');
  for (const page of ['discoverSearch', 'lapism', 'reveal', 'contactTags']) {
    const markup = fs.readFileSync(path.join(pages, page, 'index.wxml'), 'utf8');
    assert.match(markup, /\bnavigationFieldStyle\b/, page);
    const bar = markup.slice(markup.indexOf('<cyl-search-bar'));
    assert.doesNotMatch(bar.slice(0, bar.indexOf('>') + 1 + 400), /fieldCornerRadius=|fieldShadowOpacity=|fieldBackgroundColor=/, page);
  }
  const walk = (dir) => fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return /^(miniprogram_npm|components|vendor|node_modules)$/.test(entry.name) ? [] : walk(full);
    return entry.name.endsWith('.wxml') ? [full] : [];
  });
  const offenders = [...walk(path.join(root, 'example', 'miniprogram')), ...walk(path.join(root, 'src'))]
    .filter((file) => /<input\b[^>]*type="search"|<search[\s>]/.test(fs.readFileSync(file, 'utf8')));
  assert.deepEqual(offenders, []);
  const remark = fs.readFileSync(path.join(pages, 'contactTags', 'index.wxml'), 'utf8');
  assert.doesNotMatch(remark, /<input\b/);
});
