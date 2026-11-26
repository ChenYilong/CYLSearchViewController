// The trailing group layout (owner, 2026-11-26; iOS testTrailingGroupGapsBesideTheDividerAreEqual): the field flexes, the group's
// elements are spaced only by the group's spacing, a plain item hugs its content with a 36 px touch width, an item with a shape of
// its own (the icon search capsule) keeps its size.
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

const root = path.join(__dirname, '..');
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), 'utf8');

const camera = { style: 'icon', hasShape: false, itemHeight: 0, contentWidth: 22 };
const divider = { style: 'divider', hasShape: false, itemHeight: 0, contentWidth: 0 };
const capsule = { style: 'icon', hasShape: true, itemHeight: 28, contentWidth: 20 };

test('gap glyph-to-divider equals divider-to-capsule', () => {
  const [glyph, line, pill] = core.cylSearchTrailingGroupLayout([camera, divider, capsule]);
  assert.equal(glyph.width, 22, 'the plain icon hugs its glyph');
  assert.equal(line.width, 1);
  assert.equal(line.left - glyph.right, pill.left - line.right);
  assert.equal(pill.left - line.right, core.CYL_SEARCH_TRAILING_SPACING);
});

test('the capsule keeps its size, a plain item widens only its touch area to 36', () => {
  const [glyph, , pill] = core.cylSearchTrailingGroupLayout([camera, divider, capsule]);
  assert.equal(pill.width, 28, 'a 28 high capsule is at least as wide as high; its content is 20 so it keeps 28');
  assert.equal(pill.touchLeft, pill.left);
  assert.equal(glyph.touchRight - glyph.touchLeft, core.CYL_SEARCH_TOUCH_WIDTH);
  assert.equal(glyph.touchLeft, glyph.left - 7);
});

test('a plain text item hugs its title; with a background it keeps at least 36', () => {
  assert.equal(core.cylSearchItemHugsContent('text', false, 0), true);
  assert.equal(core.cylSearchItemHugsContent('text', true, 0), false);
  assert.equal(core.cylSearchItemHugsContent('icon', true, 28), false);
  assert.equal(core.cylSearchItemHugsContent('divider', false, 0), false);
  const [word] = core.cylSearchTrailingGroupLayout([{ style: 'text', hasShape: false, itemHeight: 0, contentWidth: 40 }]);
  assert.equal(word.width, 40);
});

test('items report hugsContent: plain icon hugs, the icon search button capsule does not', () => {
  const plain = CYLSearchBarItem.iconItem('/c.svg', 'Camera');
  assert.equal(plain.hugsContent, true);
  const bar = new CYLSearchBarView();
  assert.equal(bar.searchButtonStyle, 'icon');
  const button = bar.searchButtonItem;
  button.backgroundColor = '#000000';
  assert.equal(button.hugsContent, false);
  bar.searchButtonStyle = 'text';
  assert.equal(bar.searchButtonItem.hugsContent, true, 'the text style hugs its title');
});

test('the component spaces the group by one margin and hugs plain items', () => {
  const css = read('src', 'cyl-search-bar', 'index.wxss');
  assert.match(css, /\.cyl-gap \{[^}]*margin-left: 8px/);
  assert.match(css, /\.cyl-divider \{[^}]*margin: 0;/, 'no empty room beside the divider');
  assert.match(css, /\.cyl-item-hug \{ min-width: 0; \}/);
  assert.match(css, /\.cyl-item-hug::after \{[^}]*width: 36px/);
  const wxml = read('src', 'cyl-search-bar', 'index.wxml');
  assert.equal((wxml.match(/cyl-divider cyl-gap/g) || []).length, 2);
  assert.match(wxml, /item\.hugs \? 'cyl-item-hug'/);
  assert.match(wxml, /searchButton\.hugs \? 'cyl-item-hug'/);
});
