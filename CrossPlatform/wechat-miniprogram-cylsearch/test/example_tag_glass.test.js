// Every example tag list is Liquid Glass with ONE parameter at the style (`backgroundStyle: 'liquidGlass'`, the key of
// CollectionViewClassifyMenu 551072a); the glass is the background, so the glass tags have no fill and no border of their
// own. The Discover "recent" tags stay opaque white and are not a tag list.
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { cylDiscoverCloudStyle } = require('../example/miniprogram/utils/cyl_discover_logic');
const { cylContactTagStyle } = require('../example/miniprogram/utils/cyl_contact_tags');
const { cylAnimatedItemGlassTint } = require('../example/miniprogram/miniprogram_npm/cyl-tag-list-miniprogram/cyl-animated-item/cyl_animated_item_model');

const pages = path.join(__dirname, '..', 'example', 'miniprogram', 'pages');
const read = (...parts) => fs.readFileSync(path.join(pages, ...parts), 'utf8');
const base = () => ({ normal: { backgroundColor: '#F2F2F7', borderColor: '#C6C6C8', borderWidth: 1 }, selected: {}, disabled: {} });
const STATES = ['normal', 'selected', 'disabled'];

test('the Discover topics grid carries backgroundStyle liquidGlass and no fill or border of its own', () => {
  for (const dark of [false, true]) {
    const style = cylDiscoverCloudStyle(base(), { dark, iconSize: 18 });
    assert.equal(style.backgroundStyle, 'liquidGlass');
    for (const state of STATES) {
      assert.equal(style[state].backgroundColor, 'transparent');
      assert.equal(style[state].borderColor, null);
      assert.equal(style[state].borderWidth, 0);
    }
  }
});

test('the contact tags carry backgroundStyle liquidGlass, no own fill or border, and a SELECTED green tint that survives the glass', () => {
  const style = cylContactTagStyle(base());
  assert.equal(style.backgroundStyle, 'liquidGlass');
  assert.equal(style.normal.backgroundColor, '');
  for (const state of STATES) {
    assert.equal(style[state].borderColor, null);
    assert.equal(style[state].borderWidth, 0);
  }
  // The glass keeps 75% of the tint's alpha: the selected tint must stay visible (at least 10%) and below an opaque cover.
  const alpha = Number(/,\s*([\d.]+)\)$/.exec(cylAnimatedItemGlassTint(style.selected.backgroundColor))[1]);
  assert.ok(alpha >= 0.1 && alpha <= 0.3, `selected tint alpha on the glass is ${alpha}`);
  assert.equal(style.selected.textColor, '#07C160');
});

test('the Discover recent tags stay opaque white, flat, and are no tag list', () => {
  const wxml = read('discoverSearch', 'index.wxml');
  assert.match(wxml, /class="tag measure-tag"|wx:for="\{\{visibleRecent\}\}"/);
  assert.doesNotMatch(wxml.split('<cyl-tag-cloud')[0], /<cyl-tag-cloud/);
  const wxss = read('discoverSearch', 'index.wxss');
  assert.match(wxss, /^\.tag \{[^}]*background: #fff;/m);
  const script = read('discoverSearch', 'index.js');
  assert.doesNotMatch(script, /liquidGlass/);
});

test('the only liquidGlass the example pages set is the topics style (through cylDiscoverCloudStyle) and the contact tags (through cylContactTagStyle)', () => {
  const offenders = [];
  const walk = (directory) => {
    for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
      const full = path.join(directory, entry.name);
      if (entry.isDirectory()) walk(full);
      else if (/\.(js|wxml|json)$/.test(entry.name) && /liquidGlass/.test(fs.readFileSync(full, 'utf8'))) offenders.push(path.relative(pages, full));
    }
  };
  walk(pages);
  assert.deepEqual(offenders, []);
});
