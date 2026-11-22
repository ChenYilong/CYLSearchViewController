// The QMUI search port on the mini program (docs/qmui-search-controller.md, "the WeChat mini program ... QMUI search port"): the
// parity rows of CYLSearchBar, CYLSearchController and CYLSearchTableViewController, as parameters and methods of
// <cyl-search-bar> and <cyl-search>, driven by the same stand-in of the mini program runtime as components.test.js.
// WeChat DevTools draws them; this checks their logic, state and events.
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');
const {
  CYLSearchBarAppearance, cylInsetsCSS, CYLSearchBarView,
} = require('../src/core/CYLSearchBarView');
const {
  CYLSearchView, cylHighlightParts, cylSnapHeaderOffset, cylSwipeShouldDismiss,
} = require('../src/core/CYLSearchView');

global.wx = {
  getStorageSync: () => undefined,
  setStorageSync: () => {},
  getAppBaseInfo: () => ({ language: 'en' }),
  getWindowInfo: () => ({ windowWidth: 400 }),
  nextTick: (fn) => fn(),
};

function load(name) {
  let definition;
  global.Component = (options) => { definition = options; };
  const file = path.join(__dirname, '..', 'src', name, 'index.js');
  delete require.cache[require.resolve(file)];
  require(file);
  return (properties = {}, children = {}) => {
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
      // WeChat runs the observers of the data fields that changed (not recursively inside an observer's own setData).
      if (definition.observers && !instance.inObserver) {
        instance.inObserver = true;
        Object.entries(definition.observers).forEach(([keys, fn]) => {
          if (keys.split(',').some((k) => k.trim() in values)) fn.call(instance);
        });
        instance.inObserver = false;
      }
    };
    instance.triggerEvent = (type, detail) => instance.events.push([type, detail]);
    instance.selectComponent = (selector) => children[selector] || null;
    instance.createSelectorQuery = () => {
      const query = { selectAll: () => query, select: () => query, boundingClientRect: () => query, exec() {} };
      return query;
    };
    instance.set = (key, value) => {
      instance.properties[key] = value;
      instance.data[key] = value;
      const observer = definition.properties[key].observer;
      if (observer) instance[observer](value);
      if (definition.observers) {
        Object.entries(definition.observers).forEach(([keys, fn]) => {
          if (keys.split(',').map((k) => k.trim()).includes(key)) fn.call(instance, value);
        });
      }
    };
    definition.lifetimes.created.call(instance);
    definition.lifetimes.attached.call(instance);
    return instance;
  };
}

const names = (instance) => instance.events.map(([type]) => type);

// ---- CYLSearchBar: placeholder, margins, Cancel, accessories, appearance ----

test('CYLSearchBarAppearance: the merged defaults land on the bar, explicit properties win', () => {
  const values = CYLSearchBarAppearance.default();
  assert.equal(values.textFieldBackgroundColor, '#BBBAC1');
  assert.equal(values.tintColor, '#0068F8');
  assert.equal(values.textFieldCornerRadius, -1);
  const css = CYLSearchBarAppearance.styles(values, false);
  assert.match(css.field, /background: #BBBAC1/);
  assert.match(CYLSearchBarAppearance.styles(values, true).field, /background: #3A3A3C/);
  assert.equal(CYLSearchBarAppearance.styles({ barBorderColor: '#ccc' }, false).bar, 'border-bottom: 1px solid #ccc');
  const bar = load('cyl-search-bar')({ appearance: values });
  assert.match(bar.data.fieldStyle, /background: #BBBAC1/);
  assert.match(bar.data.cancelStyle, /color: #0068F8/);
  assert.equal(bar.data.fieldStyle.includes('border-radius: 18px'), true, 'a negative radius is half the field height');
  const own = load('cyl-search-bar')({ appearance: values, fieldBackgroundColor: '#fff' });
  assert.ok(own.data.fieldStyle.lastIndexOf('background: #fff') > own.data.fieldStyle.lastIndexOf('background: #BBBAC1'));
  const plain = load('cyl-search-bar')({});
  assert.equal(plain.data.barStyle, '', 'without an appearance nothing changes');
});

test('cyl-search-bar: placeholder and text style properties exist (placeholder / placeholderColor / textColor / font)', () => {
  const bar = load('cyl-search-bar')({ placeholder: 'Search', placeholderColor: '#999', textColor: '#111', fontSize: 20 });
  assert.equal(bar.data.placeholderStyle, 'color: #999');
  assert.match(bar.data.inputStyle, /font-size: 20px/);
  assert.match(bar.data.inputStyle, /color: #111/);
});

test('centersPlaceholder: centred at rest, leading while editing or with text', () => {
  const bar = load('cyl-search-bar')({ placeholder: 'Search', centersPlaceholder: true });
  assert.equal(bar.data.centered, true);
  bar.onFocus();
  assert.equal(bar.data.centered, false, 'editing puts it leading');
  bar.onBlur();
  assert.equal(bar.data.centered, true);
  bar.onInput({ detail: { value: 'a' } });
  assert.equal(bar.data.centered, false, 'text is never centred');
  bar.onInput({ detail: { value: '' } });
  assert.equal(bar.data.centered, true);
  bar.set('centersPlaceholder', false);
  assert.equal(bar.data.centered, false);
});

test('field margins per state: properties, and a provider (bar, active) that wins', () => {
  assert.equal(cylInsetsCSS({ top: 0, left: 32, bottom: 0, right: 32 }), '0px 32px 0px 32px');
  assert.equal(cylInsetsCSS(null), '');
  const bar = load('cyl-search-bar')({ textFieldMargins: { top: 0, left: 32, bottom: 0, right: 32 }, activeTextFieldMargins: { top: 0, left: 0, bottom: 0, right: 0 } });
  assert.match(bar.data.fieldStyle, /margin: 0px 32px 0px 32px/);
  bar.onFocus();
  assert.match(bar.data.fieldStyle, /margin: 0px 0px 0px 0px/);
  bar.onBlur();
  const calls = [];
  bar.setTextFieldMarginsProvider((view, active) => { calls.push(active); return active ? { left: 4 } : { left: 8, right: 8 }; });
  assert.match(bar.data.fieldStyle, /margin: 0px 8px 0px 8px/);
  bar.onFocus();
  assert.match(bar.data.fieldStyle, /margin: 0px 0px 0px 4px/);
  assert.equal(calls.includes(true) && calls.includes(false), true);
  bar.setTextFieldMarginsProvider(undefined);
  assert.match(bar.data.fieldStyle, /margin: 0px 0px 0px 0px/, 'back to the properties');
});

test('Cancel: margins per state, font, provider, and setShowsCancelButton(shows, animated)', () => {
  const bar = load('cyl-search-bar')({ cancelButtonFont: { size: 14, weight: 600 }, activeCancelButtonMargins: { top: 0, left: -16, bottom: 0, right: 0 } });
  assert.match(bar.data.cancelStyle, /font-size: 14px/);
  assert.match(bar.data.cancelStyle, /font-weight: 600/);
  assert.doesNotMatch(bar.data.cancelStyle, /margin/);
  bar.onFocus();
  assert.match(bar.data.cancelStyle, /margin: 0px 0px 0px -16px/);
  bar.onBlur();
  bar.setCancelButtonMarginsProvider((view, active) => (active ? { left: -8 } : null));
  bar.onFocus();
  assert.match(bar.data.cancelStyle, /margin: 0px 0px 0px -8px/);
  assert.equal(bar.data.cancelShown, false);
  bar.setShowsCancelButton(true, true);
  assert.deepEqual([bar.data.cancelShown, bar.data.cancelAnimated], [true, true]);
  bar.setShowsCancelButton(false, false);
  assert.deepEqual([bar.data.cancelShown, bar.data.cancelAnimated], [false, false]);
  assert.equal(bar.model.showsCancelButton, false);
  bar.set('showsCancelButton', true);
  assert.equal(bar.data.cancelShown, true, 'the property still works');
});

test('accessory views: margins, shows..., animated, and fast toggling ends in the last request', () => {
  const bar = load('cyl-search-bar')({ leadingAccessoryMargins: { top: 0, left: 8, bottom: 0, right: 8 }, trailingAccessoryMargins: { top: 0, left: 8, bottom: 0, right: 8 } });
  assert.deepEqual([bar.data.leadingShown, bar.data.trailingShown], [false, false], 'hidden first');
  assert.equal(bar.data.leadingStyle, 'padding: 0px 8px 0px 8px');
  bar.setShowsLeadingAccessoryView(true, true);
  assert.deepEqual([bar.data.leadingShown, bar.data.accessoryAnimated], [true, true]);
  bar.setShowsTrailingAccessoryView(true, false);
  assert.deepEqual([bar.data.trailingShown, bar.data.accessoryAnimated], [true, false]);
  for (let i = 0; i < 5; i += 1) bar.setShowsLeadingAccessoryView(i % 2 === 0, true);
  assert.equal(bar.data.leadingShown, true, 'five requests, the last one is "show"');
  assert.equal(bar.model.showsLeadingAccessoryView, true);
  bar.setShowsLeadingAccessoryView(false, true);
  assert.equal(bar.data.leadingShown, false);
  bar.set('showsTrailingAccessory', false);
  assert.equal(bar.data.trailingShown, false);
});

// ---- CYLSearchController: launch view, dimming, results, empty view, history, life cycle ----

function memoryStorage() {
  const values = {};
  return { getSync: (key) => values[key], setSync: (key, value) => { values[key] = value; } };
}

test('launch view: shown while the query is empty and no results show, gone when text is typed', () => {
  const search = load('cyl-search')({ showsLaunchView: true, results: [] });
  search.showSearch(false);
  assert.equal(search.data.showsLaunch, true);
  search.onFocusChange({ detail: { focused: true } });
  assert.equal(search.data.showsLaunch, true, 'focus alone changes nothing below the bar');
  search.onTextChange({ detail: { text: 'H' } });
  assert.equal(search.data.showsLaunch, false);
  search.onTextChange({ detail: { text: '' } });
  assert.equal(search.data.showsLaunch, true);
});

test('dimming: a color under the bar while the query is empty and there is no launch view; a tap ends the search', () => {
  const search = load('cyl-search')({ dimmingColor: 'rgba(0,0,0,0.4)' });
  search.showSearch(false);
  assert.equal(search.data.showsDimming, true);
  search.onTextChange({ detail: { text: 'a' } });
  assert.equal(search.data.showsDimming, false);
  search.onTextChange({ detail: { text: '' } });
  search.onDimmingTap();
  assert.equal(search.isSearchOpen(), false);
  const withLaunch = load('cyl-search')({ dimmingColor: 'red', showsLaunchView: true });
  withLaunch.showSearch(false);
  assert.equal(withLaunch.data.showsDimming, false, 'the launch view wins over the dimming');
});

test('updateresults: every change of the text, also "" on activation and on clear', () => {
  const search = load('cyl-search')({});
  search.showSearch(false);
  search.onTextChange({ detail: { text: 'He' } });
  search.onTextChange({ detail: { text: '' } });
  const updates = search.events.filter(([type]) => type === 'updateresults').map(([, detail]) => detail.text);
  assert.deepEqual(updates, ['', 'He', ''], 'first activation, typing, the clear button');
});

test('will / did present and dismiss events, setActive and isActive', async () => {
  const search = load('cyl-search')({});
  search.model.animationDuration = 0.01;
  search.setActive(true, false);
  assert.equal(search.isActive(), true);
  search.setActive(false, false);
  assert.equal(search.isActive(), false);
  await new Promise((resolve) => setTimeout(resolve, 30));
  assert.deepEqual(names(search).filter((name) => /present|dismiss|^show$|^close$/.test(name)),
    ['willpresent', 'show', 'willdismiss', 'close', 'didpresent', 'diddismiss']);
});

test('empty view with text: not for an empty query, hidden when the search ends, button action, isEmptyViewShowing', () => {
  const search = load('cyl-search')({ results: [] });
  search.showSearch(false);
  search.showEmptyView('No matching results');
  assert.equal(search.isEmptyViewShowing(), false, 'nothing shows for an empty query (E8)');
  search.onTextChange({ detail: { text: 'zzz' } });
  let taps = 0;
  search.showEmptyView('No matching results', 'Try again', 'Retry', () => { taps += 1; });
  assert.equal(search.isEmptyViewShowing(), true);
  assert.deepEqual(search.data.emptyView, { text: 'No matching results', detailText: 'Try again', buttonTitle: 'Retry' });
  search.onEmptyButtonTap();
  assert.equal(taps, 1);
  search.hideEmptyView();
  assert.equal(search.isEmptyViewShowing(), false);
  search.showEmptyView('No matching results');
  search.closeSearch(false);
  assert.equal(search.isEmptyViewShowing(), false, 'hidden when the search ends (E9)');
});

test('history: submitted queries are kept newest first, historychange follows a submit and a clear', () => {
  const view = new CYLSearchView(memoryStorage());
  const seen = [];
  view.delegate = { searchViewHistoryDidChange: (_, history) => seen.push(history.slice()) };
  view.setQuery('Liver', true);
  view.setQuery('Fat', true);
  view.setQuery('Liver', true);
  assert.deepEqual(view.history, ['Liver', 'Fat']);
  assert.deepEqual(seen.at(-1), ['Liver', 'Fat']);
  assert.equal(view.historyStore, view.suggestionCache);
  view.clearHistory();
  assert.deepEqual(seen.at(-1), []);
  const search = load('cyl-search')({ cacheName: 'QMUIPortHistory' });
  search.setQuery('Health', true);
  assert.ok(names(search).includes('historychange'));
  assert.ok(Array.isArray(search.history()));
});

test('results mark the match: parts of a title around the first match', () => {
  assert.deepEqual(cylHighlightParts('Healthy', 'alt'), [
    { text: 'He', highlighted: false }, { text: 'alt', highlighted: true }, { text: 'hy', highlighted: false }]);
  assert.deepEqual(cylHighlightParts('Fat', ''), [{ text: 'Fat', highlighted: false }]);
  assert.deepEqual(cylHighlightParts('Fat', 'x'), [{ text: 'Fat', highlighted: false }]);
  const search = load('cyl-search')({ results: ['Healthy', 'Healthy'], highlightsMatches: true });
  search.showSearch(false);
  search.onTextChange({ detail: { text: 'alt' } });
  assert.equal(search.data.shownResults[0].parts[1].highlighted, true);
  assert.equal(search.data.shownResults.length, 2);
  const plain = load('cyl-search')({ results: ['Healthy'] });
  plain.showSearch(false);
  plain.onTextChange({ detail: { text: 'alt' } });
  assert.equal(plain.data.shownResults[0].parts, undefined, 'off by default');
});

test('swipe to dismiss: from the left edge, more than a quarter of the width or fast', () => {
  assert.equal(cylSwipeShouldDismiss(10, 120, 400), true);
  assert.equal(cylSwipeShouldDismiss(10, 60, 400), false);
  assert.equal(cylSwipeShouldDismiss(10, 60, 400, 1), true, 'a fast swipe');
  assert.equal(cylSwipeShouldDismiss(100, 300, 400), false, 'it did not start at the edge');
  assert.equal(cylSwipeShouldDismiss(10, -50, 400, 2), false, 'leftwards never dismisses');
  const search = load('cyl-search')({ supportsSwipeToDismissSearch: true });
  search.showSearch(false);
  search.onPageTouchStart({ touches: [{ clientX: 100 }] });
  search.onPageTouchEnd({ changedTouches: [{ clientX: 300 }] });
  assert.equal(search.isSearchOpen(), true, 'a gesture that starts away from the edge does not begin (E11)');
  search.onPageTouchStart({ touches: [{ clientX: 5 }] });
  search.onPageTouchMove({ touches: [{ clientX: 80 }] });
  assert.equal(search.data.swipeX, 75);
  search.swipe.startTime -= 1000;
  search.onPageTouchEnd({ changedTouches: [{ clientX: 40 }] });
  assert.equal(search.isSearchOpen(), true);
  assert.equal(search.data.swipeX, 0, 'a short swipe springs back');
  search.onPageTouchStart({ touches: [{ clientX: 5 }] });
  search.onPageTouchEnd({ changedTouches: [{ clientX: 250 }] });
  assert.equal(search.isSearchOpen(), false);
  const off = load('cyl-search')({});
  off.showSearch(false);
  off.onPageTouchStart({ touches: [{ clientX: 5 }] });
  off.onPageTouchEnd({ changedTouches: [{ clientX: 300 }] });
  assert.equal(off.isSearchOpen(), true, 'off by default');
});

// ---- CYLSearchTableViewController: the list screen, I4 snapping ----

test('snapsHeaderSearchBar (I4, #1160): a half scrolled bar settles fully shown or hidden', () => {
  assert.equal(cylSnapHeaderOffset(10, 56), 0);
  assert.equal(cylSnapHeaderOffset(40, 56), 56);
  assert.equal(cylSnapHeaderOffset(20, 56, 0.2), 56, 'a fling upwards hides it');
  assert.equal(cylSnapHeaderOffset(40, 56, -0.2), 0, 'a fling downwards shows it');
  assert.equal(cylSnapHeaderOffset(0, 56), 0);
  assert.equal(cylSnapHeaderOffset(120, 56), 120, 'outside the band nothing moves');
  const screen = load('cyl-search')({ showsSearchBar: true, showsContent: true });
  assert.equal(screen.data.showsContent, false, 'the list screen draws its content in its own scroller');
  screen.setData({ headerHeight: 56 });
  screen.onContentScroll({ detail: { scrollTop: 40 } });
  assert.equal(screen.settleHeader(), 56);
  assert.equal(screen.data.scrollTop, 56);
  assert.equal(screen.data.scrollAnimated, true);
  screen.onContentScroll({ detail: { scrollTop: 10 } });
  assert.equal(screen.settleHeader(), 0);
  const off = load('cyl-search')({ showsSearchBar: true, snapsHeaderSearchBar: false });
  off.onContentScroll({ detail: { scrollTop: 40 } });
  assert.equal(off.settleHeader(), undefined);
  const wxml = require('node:fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search', 'index.wxml'), 'utf8');
  assert.match(wxml, /min-height: calc\(100% \+ ' \+ headerHeight/, 'a short list can scroll the bar out');
});

test('list screen: focusing the header bar starts the search, Cancel shows with it and ends it', () => {
  const calls = [];
  const bar = { model: { showsCancelButton: false }, setShowsCancelButton: (shows, animated) => calls.push([shows, animated]) };
  const screen = load('cyl-search')({ showsSearchBar: true, results: [] }, { '#cyl-header-bar': bar });
  screen.setData({ scrollTop: 30 });
  screen.onFocusChange({ detail: { focused: true } });
  assert.equal(screen.isSearchOpen(), true);
  assert.equal(screen.data.scrollTop, 0, 'the page scrolls to the top');
  assert.deepEqual(calls, [[true, true]]);
  screen.onTextChange({ detail: { text: 'He' } });
  screen.onBarClose();
  assert.equal(screen.isSearchOpen(), false);
  assert.equal(screen.model.query, '', 'Cancel clears the text');
  assert.deepEqual(calls, [[true, true], [false, true]], 'Cancel goes again');
  bar.model.showsCancelButton = true;
  screen.onFocusChange({ detail: { focused: true } });
  screen.closeSearch(false);
  assert.equal(calls.length, 2, 'a Cancel the host showed stays');
  screen.setActive(true);
  assert.equal(screen.isActive(), true);
});

test('hidesSearchBarInitially / hidesSearchBarWhenEmptyViewShowing: the content empty view takes the bar away', () => {
  const screen = load('cyl-search')({ showsSearchBar: true, hidesSearchBarWhenEmptyViewShowing: true, hidesSearchBarInitially: true });
  assert.equal(screen.data.headerHidden, false);
  screen.setData({ headerHeight: 56 });
  screen.showEmptyView('Nothing here');
  assert.equal(screen.data.emptyInContent, true, 'while the search is not active it replaces the content');
  assert.equal(screen.data.headerHidden, true);
  screen.hideEmptyView();
  assert.equal(screen.data.headerHidden, false);
  assert.equal(screen.data.scrollTop, 56, 'the bar comes back hidden initially');
  const keep = load('cyl-search')({ showsSearchBar: true });
  keep.showEmptyView('Nothing here');
  assert.equal(keep.data.headerHidden, false, 'off by default');
});

test('the search bar of the list screen is the one bar: its slots reach the accessory slots', () => {
  const wxml = require('node:fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search', 'index.wxml'), 'utf8');
  assert.match(wxml, /<slot name="leading-accessory" slot="leading-accessory" \/>/);
  assert.match(wxml, /<slot name="trailing-accessory" slot="trailing-accessory" \/>/);
  const barWxml = require('node:fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search-bar', 'index.wxml'), 'utf8');
  assert.match(barWxml, /<slot name="leading-accessory" \/>/);
  assert.match(barWxml, /<slot name="trailing-accessory" \/>/);
  assert.match(wxml, /<slot name="launch-view" \/>/);
});

test('the bar model keeps the iOS names for the new members', () => {
  const bar = new CYLSearchBarView();
  assert.equal(bar.centersPlaceholder, false);
  assert.equal(bar.textFieldMarginsFor(true), undefined);
  bar.textFieldMarginsProvider = (view, active) => ({ left: active ? 1 : 2 });
  assert.deepEqual(bar.textFieldMarginsFor(false), { left: 2 });
  bar.cancelButtonMarginsProvider = (view, active) => ({ left: active ? 3 : 4 });
  assert.deepEqual(bar.cancelButtonMarginsFor(true), { left: 3 });
});
