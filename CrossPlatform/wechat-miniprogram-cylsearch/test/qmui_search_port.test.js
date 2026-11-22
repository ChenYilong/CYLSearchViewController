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
  CYLSearchView, cylHighlightParts, cylSnapHeaderOffset, cylSwipeShouldDismiss, cylEdgeSwipeBegins,
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

test('leading view and trailing accessory views: shown by default, margins, animated, fast toggling ends in the last request', () => {
  const bar = load('cyl-search-bar')({ leadingAccessoryMargins: { top: 0, left: 8, bottom: 0, right: 8 }, trailingAccessoryMargins: { top: 0, left: 8, bottom: 0, right: 8 },
    showsLeadingView: false, showsTrailingAccessoryViews: false });
  assert.deepEqual([bar.data.leadingShown, bar.data.trailingShown], [false, false], 'hidden when the page says so');
  assert.equal(bar.data.leadingStyle, 'padding: 0px 8px 0px 8px');
  bar.setShowsLeadingView(true, true);
  assert.deepEqual([bar.data.leadingShown, bar.data.accessoryAnimated], [true, true]);
  bar.setShowsTrailingAccessoryViews(true, false);
  assert.deepEqual([bar.data.trailingShown, bar.data.accessoryAnimated], [true, false]);
  for (let i = 0; i < 5; i += 1) bar.setShowsLeadingView(i % 2 === 0, true);
  assert.equal(bar.data.leadingShown, true, 'five requests, the last one is "show"');
  assert.equal(bar.model.showsLeadingView, true);
  bar.setShowsLeadingView(false, true);
  assert.equal(bar.data.leadingShown, false);
  bar.set('showsTrailingAccessoryViews', false);
  assert.equal(bar.data.trailingShown, false);
  assert.equal(load('cyl-search-bar')({}).data.leadingShown, true, 'shown by default, as the iOS views are');
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
  search.onPageTouchMove({ touches: [{ clientX: 250 }] });
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
  assert.match(wxml, /<slot name="leading" slot="leading" \/>/);
  assert.match(wxml, /<slot name="trailing" slot="trailing" \/>/);
  assert.match(wxml, /<slot name="leading-accessory" slot="leading-accessory" \/>/);
  assert.match(wxml, /<slot name="trailing-accessory" slot="trailing-accessory" \/>/);
  const barWxml = require('node:fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search-bar', 'index.wxml'), 'utf8');
  assert.match(barWxml, /<slot name="leading" \/><slot name="leading-accessory" \/>/, 'one container holds both names of the leading view');
  assert.match(barWxml, /<slot name="trailing" \/><slot name="trailing-accessory" \/>/, 'one container holds both names of the trailing views');
  assert.equal((barWxml.match(/class="cyl-accessory /g) || []).length, 2, 'one animated container per side, none beside the old slots');
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

// ---- Merge phase 5 (docs/qmui-search-controller.md, "Merge phase 5 log: the WeChat mini program"): one implementation per concept ----

test('launch view: the suggestion area itself, history newest first with the header, else the suggestions; a tapped tag submits', () => {
  const eight = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat'];
  const search = load('cyl-search')({ showsSuggestionsLaunchView: true, suggestions: eight, results: [], cacheName: 'MergeP5Launch' + Date.now(), closesOnSubmit: false });
  search.showSearch(false);
  assert.deepEqual(search.data.shownSuggestions, eight, 'no history: the suggestions');
  assert.equal(search.data.showsCacheHeader, false, 'the header only over a history');
  assert.deepEqual(search.data.tagConfiguration.sections[0].items.map((item) => item.title), eight, 'drawn by the tag list');
  assert.equal(search.data.showsLaunch, false, 'the slot is not the launch view here');
  search.onFocusChange({ detail: { focused: true } });
  assert.deepEqual(search.data.shownSuggestions, eight, 'focus alone changes nothing');
  // A tapped tag sets the query and submits it: results follow (updateresults), the history is kept, the tag list refreshes.
  search.onSuggestionTap({ detail: { section: 0, item: 3, title: 'Health' } });
  assert.equal(search.data.query, 'Health');
  const types = search.events.map(([type]) => type);
  assert.ok(types.includes('updateresults') && types.includes('submit') && types.includes('historychange'));
  assert.deepEqual(search.events.filter(([type]) => type === 'updateresults').map(([, detail]) => detail.text).slice(-1), ['Health']);
  assert.deepEqual(search.events.filter(([type]) => type === 'submit').map(([, detail]) => detail.text), ['Health']);
  assert.deepEqual(search.history(), ['Health']);
  search.onTextChange({ detail: { text: '' } });
  assert.deepEqual(search.data.shownSuggestions, ['Health'], 'the history, newest first');
  assert.equal(search.data.showsCacheHeader, true, 'with the header and its trash button');
  assert.deepEqual(search.data.tagConfiguration.sections[0].items.map((item) => item.title), ['Health']);
  search.onClear();
  assert.deepEqual(search.data.shownSuggestions, eight, 'the trash goes back to the suggestions');
  const custom = load('cyl-search')({ showsSuggestionsLaunchView: true, showsLaunchView: true, suggestions: eight, results: [] });
  custom.showSearch(false);
  assert.equal(custom.data.showsLaunch, false, 'the built-in launch view wins over the slot');
  assert.equal(load('cyl-search')({}).properties.showsSuggestionsLaunchView, false, 'off by default');
});

test('scrim: scrimColor is the one overlay color, dimmingColor forwards to it', () => {
  const view = new CYLSearchView(memoryStorage());
  view.dimmingColor = 'red';
  assert.equal(view.scrimColor, 'red');
  view.scrimColor = 'blue';
  assert.equal(view.dimmingColor, 'blue');
  const scrim = load('cyl-search')({ scrimColor: 'rgba(0,0,0,0.4)' });
  scrim.showSearch(false);
  assert.equal(scrim.data.showsDimming, true);
  assert.equal(scrim.model.scrimColor, 'rgba(0,0,0,0.4)');
  const old = load('cyl-search')({ dimmingColor: 'green' });
  assert.equal(old.model.scrimColor, 'green', 'the earlier name still works');
  const wxml = require('node:fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search', 'index.wxml'), 'utf8');
  assert.equal((wxml.match(/class="cyl-dimming"/g) || []).length, 1, 'one overlay view');
  const withTags = load('cyl-search')({ scrimColor: 'red', showsSuggestionsLaunchView: true });
  withTags.showSearch(false);
  assert.equal(withTags.data.showsDimming, false, 'the launch view wins over the scrim');
});

test('noResultsText: the empty view shows while the query is not empty and the results are empty, and goes with them', () => {
  const search = load('cyl-search')({ results: [], noResultsText: 'No matching results' });
  search.showSearch(false);
  assert.equal(search.isEmptyViewShowing(), false, 'nothing for an empty query');
  search.onTextChange({ detail: { text: 'zzz' } });
  assert.equal(search.isEmptyViewShowing(), true);
  assert.equal(search.data.emptyView.text, 'No matching results');
  search.set('results', ['Health']);
  assert.equal(search.isEmptyViewShowing(), false, 'results came: the view goes');
  search.set('results', []);
  assert.equal(search.isEmptyViewShowing(), true, 'also when the page sets the results after the text');
  search.onTextChange({ detail: { text: '' } });
  assert.equal(search.isEmptyViewShowing(), false);
  // An empty view the page showed itself is never replaced or hidden by the option.
  search.onTextChange({ detail: { text: 'zzz' } });
  search.showEmptyView('Mine', 'detail');
  search.set('results', ['x']);
  assert.equal(search.data.emptyView.text, 'Mine');
  const off = load('cyl-search')({ results: [] });
  off.showSearch(false);
  off.onTextChange({ detail: { text: 'zzz' } });
  assert.equal(off.isEmptyViewShowing(), false, 'off by default');
  const wxml = require('node:fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search', 'index.wxml'), 'utf8');
  assert.equal((wxml.match(/cyl-custom-empty-title/g) || []).length, 1, 'one empty view markup for the content and the layer');
});

test('highlight: highlightsResultMatches and resultMatchHighlightColor, case and diacritic insensitive, the old names still work', () => {
  assert.deepEqual(cylHighlightParts('Health', 'HEAL'), [{ text: 'Heal', highlighted: true }, { text: 'th', highlighted: false }]);
  assert.deepEqual(cylHighlightParts('Café au lait', 'cafe'), [{ text: 'Café', highlighted: true }, { text: ' au lait', highlighted: false }]);
  assert.deepEqual(cylHighlightParts('Cafe\u0301 au lait', 'CAFÉ'), [{ text: 'Cafe\u0301', highlighted: true }, { text: ' au lait', highlighted: false }], 'decomposed, the mark stays in the match');
  assert.deepEqual(cylHighlightParts('Crème brûlée', 'brulee'), [{ text: 'Crème ', highlighted: false }, { text: 'brûlée', highlighted: true }]);
  assert.deepEqual(cylHighlightParts('Health', ''), [{ text: 'Health', highlighted: false }]);
  assert.deepEqual(cylHighlightParts('Health', 'xyz'), [{ text: 'Health', highlighted: false }]);
  const search = load('cyl-search')({ results: ['Healthy'], highlightsResultMatches: true, resultMatchHighlightColor: '#ff0000' });
  search.showSearch(false);
  search.onTextChange({ detail: { text: 'ALT' } });
  assert.deepEqual(search.data.shownResults[0].parts.map((part) => [part.text, part.highlighted]), [['He', false], ['alt', true], ['hy', false]]);
  const old = load('cyl-search')({ results: ['Healthy'], highlightsMatches: true, highlightColor: '#00ff00' });
  old.showSearch(false);
  old.onTextChange({ detail: { text: 'alt' } });
  assert.equal(old.data.shownResults[0].parts[1].highlighted, true, 'highlightsMatches still turns it on');
  const wxml = require('node:fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search', 'index.wxml'), 'utf8');
  assert.match(wxml, /resultMatchHighlightColor \|\| highlightColor/);
  const view = new CYLSearchView(memoryStorage());
  view.highlightsMatches = true;
  assert.equal(view.highlightsResultMatches, true, 'the model forwards the old name');
});

test('the suggestion filter ignores case and diacritics like iOS', () => {
  const view = new CYLSearchView(memoryStorage());
  view.suggestions = ['Café', 'Health', 'resume', 'résumé'];
  view.setQuery('CAFE');
  assert.deepEqual(view.filteredSuggestions, ['Café']);
  view.setQuery('resume');
  assert.deepEqual(view.filteredSuggestions, ['resume', 'résumé']);
});

test('swipe to dismiss: the touch begins the swipe itself (24 px edge, 10 px slop, more sideways than vertical)', () => {
  assert.equal(cylEdgeSwipeBegins(2, 11, 0), true);
  assert.equal(cylEdgeSwipeBegins(2, 10, 0), false, 'inside the slop');
  assert.equal(cylEdgeSwipeBegins(30, 80, 0), false, 'not from the edge');
  assert.equal(cylEdgeSwipeBegins(2, -40, 0), false, 'leftwards');
  assert.equal(cylEdgeSwipeBegins(2, 30, 60), false, 'more vertical than horizontal');
  const search = load('cyl-search')({ supportsSwipeToDismissSearch: true });
  search.showSearch(false);
  search.onPageTouchStart({ touches: [{ clientX: 3, clientY: 300 }] });
  search.onPageTouchMove({ touches: [{ clientX: 6, clientY: 305 }] });
  assert.equal(search.data.swipeX, 0, 'inside the slop nothing moves yet');
  search.onPageTouchMove({ touches: [{ clientX: 40, clientY: 310 }] });
  assert.equal(search.data.swipeX, 37, 'it began: the page follows the finger');
  search.swipe.startTime -= 1000;
  search.onPageTouchEnd({ changedTouches: [{ clientX: 40 }] });
  assert.equal(search.data.swipeX, 0);
  assert.equal(search.isSearchOpen(), true, 'a short swipe springs back');
  search.onPageTouchStart({ touches: [{ clientX: 3, clientY: 300 }] });
  search.onPageTouchMove({ touches: [{ clientX: 20, clientY: 420 }] });
  search.onPageTouchMove({ touches: [{ clientX: 300, clientY: 430 }] });
  search.onPageTouchEnd({ changedTouches: [{ clientX: 300 }] });
  assert.equal(search.isSearchOpen(), true, 'a vertical first move fails the swipe for good: the list scrolls');
  assert.equal(search.data.swipeX, 0);
});

test('events: a present that starts during a dismiss overtakes it, no diddismiss for it', async () => {
  const search = load('cyl-search')({});
  search.model.animationDuration = 0.02;
  search.showSearch(false);
  search.closeSearch(true);
  search.showSearch(true);
  await new Promise((resolve) => setTimeout(resolve, 60));
  assert.equal(search.isSearchOpen(), true);
  assert.equal(search.data.visible, true, 'it did not end hidden');
  assert.equal(names(search).filter((name) => name === 'diddismiss').length, 0);
  assert.deepEqual(names(search).filter((name) => /^will/.test(name)), ['willpresent', 'willdismiss', 'willpresent']);
});

test('leading view and trailing accessory views: the earlier names forward, a set earlier property wins', () => {
  const bar = load('cyl-search-bar')({ showsLeadingAccessory: false, showsTrailingAccessoryViews: true });
  assert.deepEqual([bar.data.leadingShown, bar.data.trailingShown], [false, true], 'showsLeadingAccessory=false hides it');
  bar.setShowsLeadingAccessoryView(true, true);
  assert.equal(bar.model.showsLeadingView, true, 'the deprecated method calls the new one');
  bar.setShowsTrailingAccessoryView(false, false);
  assert.equal(bar.model.showsTrailingAccessoryViews, false);
  const model = new CYLSearchBarView();
  assert.equal(model.showsLeadingView, true);
  model.showsLeadingAccessoryView = false;
  assert.equal(model.showsLeadingView, false, 'the deprecated property forwards');
  model.setShowsTrailingAccessoryView(false);
  assert.equal(model.showsTrailingAccessoryViews, false);
  const search = load('cyl-search')({}, { '#cyl-header-bar': bar });
  search.barComponent = () => bar;
  search.setShowsLeadingView(false, false);
  assert.equal(bar.model.showsLeadingView, false);
  search.setShowsTrailingAccessoryView(true, false);
  assert.equal(bar.model.showsTrailingAccessoryViews, true);
});

test('no component of the package lays tags out by itself: the tag list is CollectionViewClassifyMenu\'s', () => {
  const fs = require('node:fs');
  const dir = path.join(__dirname, '..', 'src');
  ['cyl-search', 'cyl-search-bar'].forEach((name) => {
    ['index.wxss', 'index.wxml'].forEach((file) => {
      const content = fs.readFileSync(path.join(dir, name, file), 'utf8');
      assert.doesNotMatch(content, /flex-wrap/, name + '/' + file);
    });
  });
  assert.equal(typeof require('../src/index.js').cylFoldTags, 'function', 'the deprecated helper stays exported');
});
