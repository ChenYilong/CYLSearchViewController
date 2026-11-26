// The first-level navigation bar (owner directive 2026-11-26, docs/instructions/example-demos.md rule 10): the pure state
// machine of the back button and the bar width, the component's behaviour, the presets, and the checks that every tab of
// the example uses the core (no page animates the back button or sets a width itself).
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('fs');
const path = require('path');
const nav = require('../src/core/CYLSearchNavigationBar');
const { CYLSearchBarView, CYLSearchBarPreset, cylSearchBarPresetSpec } = require('../src/core/CYLSearchBarView');

const root = path.join(__dirname, '..');
const read = (...parts) => fs.readFileSync(path.join(root, ...parts), 'utf8');

test('a request for the state the back button has is a no-op, else applies at once or animated', () => {
  assert.equal(nav.cylBackButtonRequest(false, false, true), 0);
  assert.equal(nav.cylBackButtonRequest(true, true, false), 0);
  assert.equal(nav.cylBackButtonRequest(false, true, true), 2);
  assert.equal(nav.cylBackButtonRequest(false, true, false), 1);
  assert.equal(nav.cylBackButtonRequest(true, false, true), 2);
});

test('the progress is clamped and the slot and the inset derive from it', () => {
  assert.equal(nav.cylBackButtonProgress(-1), 0);
  assert.equal(nav.cylBackButtonProgress(NaN), 0);
  assert.equal(nav.cylBackButtonProgress(3), 1);
  assert.equal(nav.cylBackSlotWidth(0), 0);
  assert.equal(nav.cylBackSlotWidth(1), 32);
  assert.equal(nav.cylTitleLeadingInset(0), 16);
  assert.equal(nav.cylTitleLeadingInset(1), 6);
});

test('the bar is the whole width inside the safe area at 0 and shrinks monotonically towards 1', () => {
  assert.equal(nav.cylBarWidth(390, 0, 16), 390 - 16 - 16);
  assert.equal(nav.cylBarWidth(390, 1, 16), 390 - 6 - 16 - 32);
  let previous = Infinity;
  for (let progress = 0; progress <= 1.0001; progress += 0.1) {
    const width = nav.cylBarWidth(390, progress, 101);
    assert.ok(width < previous);
    previous = width;
  }
  assert.equal(nav.cylBarWidth(20, 1), 0);
});

test('a tap pushes only on a first-level bar whose back button is not shown yet; the root page has no back button', () => {
  assert.equal(nav.cylFirstLevelTapAction(false, false), 0);
  assert.equal(nav.cylFirstLevelTapAction(true, false), 1);
  assert.equal(nav.cylFirstLevelTapAction(true, true), 2);
  assert.equal(nav.cylBackButtonWantedFor(true), false);
  assert.equal(nav.cylBackButtonWantedFor(false), true);
});

test('CYLSearchNavigationBar: showBackButton and hideBackButton, the tap hook and the sync with the shown page', () => {
  const bar = new nav.CYLSearchNavigationBar();
  const taps = [];
  bar.pushesOnTap = true;
  bar.onFirstLevelTap = () => taps.push(bar.showsBackButton);
  bar.firstLevelTapped();
  assert.deepEqual(taps, [true], 'the back button comes in before the push hook runs');
  assert.equal(bar.backButtonProgress, 1);
  assert.equal(bar.backButtonAnimated, true);
  bar.firstLevelTapped();
  assert.equal(taps.length, 1, 'a second tap while the push is under way does nothing');
  bar.syncBackButton(true, true);
  assert.equal(bar.backButtonProgress, 0, 'the first-level page is shown again: back button out');
  bar.showBackButton(false);
  assert.equal(bar.backButtonAnimated, false);
  bar.hideBackButton();
  assert.equal(bar.backButtonAnimated, true);
  const plain = new nav.CYLSearchNavigationBar();
  plain.onFirstLevelTap = () => taps.push('no');
  plain.firstLevelTapped();
  assert.equal(taps.length, 1, 'a bar that is not first-level never pushes');
});

test('presets: five distinct looks, applied by CYLSearchBarView.applyPreset', () => {
  const names = Object.values(CYLSearchBarPreset);
  assert.equal(names.length, 5);
  assert.equal(new Set(names.map((name) => JSON.stringify(cylSearchBarPresetSpec(name)))).size, 5);
  const bar = new CYLSearchBarView();
  bar.applyPreset(CYLSearchBarPreset.centeredCapsule);
  assert.equal(bar.centersPlaceholder, true);
  assert.equal(bar.fieldCornerRadius, -1);
  const navigation = new CYLSearchBarView();
  navigation.applyPreset(CYLSearchBarPreset.navigationField);
  assert.equal(navigation.fieldCornerRadius, 18);
});

function loadNavigationBar(properties = {}) {
  let definition;
  global.wx = { getAppBaseInfo: () => ({ language: 'en' }), getStorageSync: () => undefined, setStorageSync: () => {} };
  global.Component = (options) => { definition = options; };
  const file = path.join(root, 'src', 'cyl-search-navigation-bar', 'index.js');
  delete require.cache[require.resolve(file)];
  require(file);
  const instance = { data: JSON.parse(JSON.stringify(definition.data)), properties: {}, events: [] };
  Object.entries(definition.properties).forEach(([key, spec]) => { instance.properties[key] = key in properties ? properties[key] : spec.value; });
  Object.assign(instance, definition.methods);
  instance.setData = (values) => Object.assign(instance.data, values);
  instance.triggerEvent = (type) => instance.events.push(type);
  definition.lifetimes.attached.call(instance);
  return { instance, definition };
}

test('cyl-search-navigation-bar: a first-level tap shows the back button animated, fires the event and pushes; onShow reverses it', () => {
  const pushed = [];
  const { instance, definition } = loadNavigationBar({ pushesOnTap: true, pushUrl: '/pages/searchSecond/index?preset=pill' });
  global.wx.navigateTo = (options) => pushed.push(options.url);
  try {
    assert.equal(instance.data.backShown, false);
    instance.onFirstLevelTap();
    assert.equal(instance.data.backShown, true);
    assert.equal(instance.data.backAnimated, true);
    assert.deepEqual(instance.events, ['firstleveltap']);
    assert.deepEqual(pushed, ['/pages/searchSecond/index?preset=pill']);
    instance.onFirstLevelTap();
    assert.equal(pushed.length, 1, 'no second push');
    definition.pageLifetimes.show.call(instance);
    assert.equal(instance.data.backShown, false, 'the page is shown again (swipe back): the back button goes out');
    assert.equal(instance.data.backAnimated, true);
    definition.pageLifetimes.show.call(instance);
    assert.equal(instance.data.backShown, false);
  } finally {
    delete global.wx.navigateTo;
  }
});

test('cyl-search-navigation-bar: showsBack is the initial state, shown at once; a plain bar never pushes', () => {
  const second = loadNavigationBar({ showsBack: true }).instance;
  assert.equal(second.data.backShown, true);
  assert.equal(second.data.backAnimated, false);
  const plain = loadNavigationBar().instance;
  plain.onFirstLevelTap();
  assert.equal(plain.data.backShown, false);
  assert.deepEqual(plain.events, []);
});

test('the component lays the bar out by flex and CSS transitions, never by a page-set width', () => {
  const wxss = read('src', 'cyl-search-navigation-bar', 'index.wxss');
  assert.match(wxss, /\.cyl-nav-animated \.cyl-nav-back \{ transition: width/);
  assert.match(wxss, /\.cyl-nav-content \{ flex: 1/);
  // No transparent layer over the bar any more: the field of the cyl-search-bar takes the tap, the search button keeps its own.
  assert.doesNotMatch(read('src', 'cyl-search-navigation-bar', 'index.wxml'), /bindtap="onFirstLevelTap"/);
  assert.match(read('src', 'cyl-search-navigation-bar', 'index.js'), /firstLevelTapped()/);
  assert.match(read('src', 'cyl-search-bar', 'index.wxml'), /<view wx:if="{{!editable || pushesOnTap}}" class="cyl-tap-cover"/);
});

test('the example: every tab shows its own preset as the whole bar and pushes on tap', () => {
  const example = ['example', 'miniprogram'];
  const presets = {
    'pages/search/index.wxml': 'pill',
    'pages/examples/index.wxml': 'rounded',
    'demo-components/cyl-demo-search-bar/index.wxml': 'outlined',
    'demo-components/cyl-demo-material-menu/index.wxml': 'centeredCapsule',
    'pages/discover/index.wxml': 'navigationField',
  };
  Object.entries(presets).forEach(([file, preset]) => {
    const text = read(...example, file);
    assert.match(text, new RegExp(`<cyl-demo-first-level-bar[^>]*preset="${preset}"`), `${file}: ${preset}`);
  });
  assert.equal(new Set(Object.values(presets)).size, 5, 'one preset per tab');
  assert.match(read(...example, 'demo-components/cyl-demo-first-level-bar/index.wxml'), /<cyl-search-navigation-bar id="nav" pushesOnTap pushUrl=/);
  assert.match(read(...example, 'app.json'), /pages\/searchSecond\/index/);
  assert.doesNotMatch(read(...example, 'pages/discover/index.js'), /navigateTo/, 'the Discover tab no longer opens its page by itself');
});

test('the example pages never animate the back button or set the bar width themselves', () => {
  const files = ['pages/search/index', 'pages/examples/index', 'pages/discover/index', 'pages/searchSecond/index',
    'demo-components/cyl-demo-first-level-bar/index'];
  files.forEach((file) => {
    ['js', 'wxml', 'wxss'].forEach((ext) => {
      const text = read('example', 'miniprogram', `${file}.${ext}`);
      assert.doesNotMatch(text, /showBackButton|hideBackButton|backShown|transition\s*:|animation\s*:/, `${file}.${ext}`);
    });
  });
});

test('a showsBack set after the bar was attached (a page sets it in onLoad) shows the back button', () => {
  global.wx = { getStorageSync: () => undefined, getAppBaseInfo: () => ({ language: 'en' }), getWindowInfo: () => ({ windowWidth: 390, statusBarHeight: 47 }),
    getMenuButtonBoundingClientRect: () => ({ left: 296, right: 383, top: 51, height: 32 }) };
  let definition;
  global.Component = (options) => { definition = options; };
  const file = path.join(root, 'src', 'cyl-search-navigation-bar', 'index.js');
  delete require.cache[require.resolve(file)];
  require(file);
  const instance = Object.assign({ data: JSON.parse(JSON.stringify(definition.data)), properties: { showsBack: false, backLabel: '' } }, definition.methods);
  instance.setData = (patch) => Object.assign(instance.data, patch);
  definition.lifetimes.attached.call(instance);
  assert.equal(instance.data.backShown, false);
  instance.properties.showsBack = true;
  assert.equal(definition.properties.showsBack.observer, 'onShowsBackChange');
  instance.onShowsBackChange();
  assert.equal(instance.data.backShown, true, 'the observer redraws with the back button');
});
