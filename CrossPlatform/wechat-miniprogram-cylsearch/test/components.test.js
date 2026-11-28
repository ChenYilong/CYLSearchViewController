// The two components driven by a small stand-in of the mini program runtime (Component, setData, triggerEvent,
// selectComponent): <cyl-search-bar> in the "multiple" mode and with items, <cyl-search> with results and refresh.
// WeChat DevTools draws them; this checks their logic and events.
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');

global.wx = {
  getStorageSync: () => undefined,
  setStorageSync: () => {},
  getAppBaseInfo: () => ({ language: 'en' }),
  nextTick: (fn) => fn(),
};

// Loads a component's index.js and returns a factory of instances with the given properties.
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
    };
    if (definition.lifetimes.created) definition.lifetimes.created.call(instance);
    definition.lifetimes.attached.call(instance);
    return instance;
  };
}

const names = (instance) => instance.events.map(([type]) => type);

test('cyl-search-bar in the multiple mode: new search, complete, select, remove, with the indexed events', () => {
  const bar = load('cyl-search-bar')({ mode: 'multiple', minimumTextLength: 3 });
  bar.onNewSearchTap();
  assert.equal(bar.data.editingNewSearch, true);
  assert.equal(bar.data.inputFocus, true, 'a new search raises the keyboard');
  bar.onSearchInput({ detail: { value: 'Swift' } });
  bar.onSearchConfirm();
  bar.addSearch('Kotlin');
  assert.deepEqual(bar.data.searchItems.map((item) => item.text), ['Swift', 'Kotlin']);
  assert.equal(bar.data.searchItems[0].label, 'Swift, Search 1 of 2');
  assert.equal(bar.data.selectedSearchIndex, 1);
  bar.onSearchTap({ currentTarget: { dataset: { index: 0 } } });
  bar.onRemoveSearchTap({ currentTarget: { dataset: { index: 1 } } });
  assert.deepEqual(bar.searches(), ['Swift']);
  assert.deepEqual(bar.events, [
    ['textchange', { text: 'Swift', index: 0 }], ['completesearch', { text: 'Swift', index: 0 }],
    ['completesearch', { text: 'Kotlin', index: 1 }], ['selectsearch', { text: 'Swift', index: 0 }], ['removesearch', { index: 1 }],
  ]);
});

test('cyl-search-bar in the single mode: text, submit, items and Cancel', () => {
  const bar = load('cyl-search-bar')({ items: [{ style: 'icon', title: 'Camera', image: '/c.svg', isSelectable: true, badgeValue: '2' }, { style: 'divider' }] });
  assert.equal(bar.data.shownItems[0].label, 'Camera, 2');
  bar.onInput({ detail: { value: 'Jay' } });
  bar.onConfirm({ detail: { value: 'Jay' } });
  bar.onItemTap({ currentTarget: { dataset: { index: 0 } } });
  assert.equal(bar.data.shownItems[0].isSelected, true);
  bar.onItemTap({ currentTarget: { dataset: { index: 1 } } });
  bar.onCancel();
  bar.setText('Chou', true);
  assert.deepEqual(names(bar), ['textchange', 'submit', 'itemselect', 'cancel', 'textchange', 'submit']);
  assert.deepEqual(bar.events[2][1].selected, true);
  bar.set('value', 'from page');
  assert.equal(bar.data.text, 'from page');
  assert.equal(bar.events.length, 6, 'a value from the page sends no textchange');
});

test('cyl-search: results from the property, selection, empty placeholder, suggestions for an empty query', () => {
  const search = load('cyl-search')({ results: [], showsEmptyResultsPlaceholder: true, suggestions: ['Swift'] });
  search.showSearch(false);
  assert.equal(search.data.open, true);
  assert.equal(search.data.showsResults, false, 'an empty query keeps the suggestions');
  search.onTextChange({ detail: { text: 'res' } });
  assert.equal(search.data.showsResults, true);
  assert.equal(search.data.showsEmptyResults, true);
  search.set('results', ['Result 1', 'Result 2']);
  assert.deepEqual(search.data.shownResults.map((cell) => cell.title), ['Result 1', 'Result 2']);
  assert.equal(search.data.showsEmptyResults, false);
  search.onResultTap({ currentTarget: { dataset: { index: 1 } } });
  assert.deepEqual(search.events.at(-1), ['selectresult', { result: 'Result 2', index: 1 }]);
  search.set('results', null);
  assert.equal(search.data.showsResults, false);
});

test('cyl-search: a data source in JavaScript, configured rows, reloadResults', () => {
  const search = load('cyl-search')({ inline: true, showsResultsForEmptyQuery: true });
  let version = 1;
  search.setResultsDataSource({
    searchViewResultsForQuery: (_, query) => [`${query || 'all'} v${version}`],
    searchViewConfigureResultCell: (_, cell) => { cell.subtitle = 'detail'; },
  });
  assert.equal(search.data.open, true, 'inline is open at once');
  assert.deepEqual(search.data.shownResults, [{ title: 'all v1', subtitle: 'detail', accessibilityLabel: 'all v1, detail' }]);
  version = 2;
  search.reloadResults();
  assert.deepEqual(search.searchResults(), ['all v2']);
  search.closeSearch(false);
  assert.equal(search.isSearchOpen(), true, 'an inline search view stays open');
});

test('cyl-search: the refresh API drives CYLTableViewPlaceHolder cyl-refresh and sends refresh once', () => {
  const refresh = { begun: 0, ended: 0, beginRefreshing() { this.begun += 1; }, endRefreshing() { this.ended += 1; } };
  const search = load('cyl-search')({ inline: true, refresherEnabled: true, showsResultsForEmptyQuery: true, results: ['a'] },
    { '#cyl-refresh': refresh });
  assert.equal(search.data.refreshes, true);
  search.beginRefreshing();
  assert.equal(refresh.begun, 1, 'the header starts and sends its refresh event');
  search.onRefresh();
  search.onRefresh();
  assert.equal(search.isRefreshing(), true);
  assert.deepEqual(names(search).filter((type) => type === 'refresh'), ['refresh']);
  search.endRefreshing();
  assert.equal(search.isRefreshing(), false);
  assert.equal(refresh.ended, 1);
  let handled = 0;
  search.setRefreshHandler(() => { handled += 1; });
  search.onRefresh();
  assert.equal(handled, 1, 'the JavaScript handler runs before the event');
  search.endRefreshing();
  search.set('refresherEnabled', false);
  assert.equal(search.data.refreshes, true, 'a handler keeps the pull-to-refresh');
  search.setRefreshHandler(null);
  assert.equal(search.data.refreshes, false);
});

test('cyl-search: the empty-text submit of the search button does nothing and keeps the keyboard', () => {
  const search = load('cyl-search')({});
  search.showSearch(false);
  let keyboard = 0;
  search.barComponent = () => ({ showKeyboard: () => { keyboard += 1; } });
  const before = names(search).length;
  search.onSubmit({ detail: { text: '' } });
  search.onSubmit({ detail: { text: '   ' } });
  assert.equal(search.data.open, true, 'nothing closed');
  assert.equal(names(search).length, before, 'no submit event');
  assert.equal(search.model.suggestionCache === undefined ? 0 : search.model.suggestionCache.cachedQueries().length, 0, 'nothing recorded');
  assert.equal(keyboard, 2);
  search.onSubmit({ detail: { text: 'Swift' } });
  assert.equal(search.data.open, false, 'with text it submits as before');
});

test('cyl-search: submit closes the overlay with its transition, Cancel closes it with the completion', async () => {
  const search = load('cyl-search')({});
  search.model.animationDuration = 0.01;
  search.showSearch(false);
  assert.equal(search.data.visible, true);
  search.onTextChange({ detail: { text: 'Swift' } });
  search.onSubmit({ detail: { text: 'Swift' } });
  assert.equal(search.data.open, false);
  // The iOS CYLSearchController events (willpresent, updateresults, historychange, willdismiss) come with them.
  assert.deepEqual(names(search).filter((name) => !['willpresent', 'updateresults', 'historychange', 'willdismiss'].includes(name)),
    ['show', 'textchange', 'submit', 'close']);
  search.showSearch(false);
  await new Promise((resolve) => search.closeSearch(true, resolve));
  assert.equal(search.isSearchOpen(), false);
  await new Promise((resolve) => setTimeout(resolve, 20));
  assert.equal(search.data.visible, false);
});

test('cyl-search-bar passes GIF stills, duration, autoplay and embedded on to cyl-tag-button', () => {
  const bar = load('cyl-search-bar')({ items: [
    { style: 'icon', title: 'Live', image: '/l.svg', animationURL: '/live.gif', gifFirstFrame: '/live-first.png',
      gifLastFrame: '/live-last.png', gifDuration: 1200, animationAutoplay: true, animationEmbedded: true },
    { style: 'icon', title: 'Camera', image: '/c.svg' },
  ] });
  const [gif, plain] = bar.data.shownItems.map((item) => item.button);
  assert.equal(gif.gifFirstFrame, '/live-first.png');
  assert.equal(gif.gifLastFrame, '/live-last.png');
  assert.equal(gif.gifDuration, 1200);
  assert.equal(gif.autoplay, true, 'animationAutoplay: true plays once on load');
  assert.equal(gif.embedded, true);
  assert.equal(plain.gifFirstFrame, '');
  assert.equal(plain.gifDuration, 0, '0: the registered GIF duration, else 1000');
  assert.equal(plain.autoplay, false, 'an animated icon rests until played, as cyl-tag-button and iOS');
  assert.equal(plain.embedded, false);
});

test('cyl-search-bar draws each item with cyl-tag-button: title, image, badge, animationURL, transparent', () => {
  const bar = load('cyl-search-bar')({ items: [
    { style: 'icon', title: 'Camera', image: '/c.svg', badgeValue: '', animationURL: 'camera.json' },
    { style: 'divider' },
    { style: 'text', title: 'Search', image: '/s.svg', badgeValue: '3', badgeColor: '#0000FF' },
  ] });
  const [icon, divider, text] = bar.data.shownItems.map((item) => item.button);
  assert.equal(icon.title, '', 'an icon item shows only its icon');
  assert.equal(icon.image, '/c.svg');
  assert.equal(icon.badgeValue, '', 'an empty badge is a dot');
  assert.equal(icon.animationURL, 'camera.json');
  assert.equal(icon.accessibilityLabel, 'Camera', 'the title is what the screen reader reads');
  assert.equal(icon.tagStyle.allowsTransparentBackground, true);
  assert.equal(icon.tagStyle.normal.backgroundColor, 'transparent');
  assert.equal(icon.tagStyle.normal.borderWidth, 0);
  assert.deepEqual(icon.tagStyle.imageSize, { width: 22, height: 22 });
  assert.equal(divider.image, '');
  assert.equal(divider.badgeValue, null);
  assert.equal(text.title, 'Search');
  assert.equal(text.badgeValue, '3');
  assert.equal(text.badgeColor, '#0000FF');
  assert.equal(text.tagStyle.normal.contentInsets.left, 0, 'a plain text item hugs its title: no inset');
  assert.equal(text.tagStyle.normal.font.weight, 'semibold');
  // A tap plays the animated icon, then selects the item.
  let played = 0;
  const tapped = load('cyl-search-bar');
  const withChild = tapped({ items: [{ style: 'icon', title: 'Camera', image: '/c.svg', animationURL: 'camera.json' }] },
    { '#cyl-bar-item-0': { playAnimation: () => { played += 1; } } });
  withChild.onItemTap({ currentTarget: { dataset: { index: 0 } } });
  assert.equal(played, 1);
  assert.deepEqual(names(withChild), ['itemselect']);
});

test('cyl-search-bar editing bar: every new title takes the keyboard, also when focus is already set', (t) => {
  t.mock.timers.enable({ apis: ['setTimeout'] });
  const bar = load('cyl-search-bar')({ editingBar: true, cancelButtonTitle: 'Done' });
  const focusHistory = [];
  const setData = bar.setData;
  bar.setData = (values) => {
    if ('inputFocus' in values) focusHistory.push(values.inputFocus);
    setData(values);
  };
  // First rename: the title arrives, the field focuses.
  bar.set('value', 'Family');
  assert.deepEqual(focusHistory, [true]);
  // Done: the page clears the value, but the field keeps inputFocus (no blur event reached it, as on a phone).
  bar.set('value', '');
  assert.equal(bar.data.inputFocus, true);
  // Second rename: false then true, so WeChat focuses the input again.
  bar.set('value', 'College Classmates');
  assert.deepEqual(focusHistory, [true, false]);
  t.mock.timers.tick(30);
  assert.deepEqual(focusHistory, [true, false, true]);
  assert.equal(bar.data.inputFocus, true);
  // The page's own focus property also re-triggers while focus is set.
  bar.set('focus', true);
  t.mock.timers.tick(30);
  assert.deepEqual(focusHistory.slice(-2), [false, true]);
});


test('cyl-search: the content page is the one scroller and holds its scrolling only while a drag or a smear is active', () => {
  const fs = require('node:fs');
  const wxml = fs.readFileSync(path.join(__dirname, '..', 'src', 'cyl-search', 'index.wxml'), 'utf8');
  // The content slot sits in a <scroll-view> that listens, as an ancestor of the slot, to the tag list's gesture events.
  assert.match(wxml, /<scroll-view wx:if="\{\{showsContent\}\}" class="cyl-content" scroll-y="\{\{!contentScrollHeld\}\}"/);
  assert.match(wxml, /bind:reorderingchange="onContentGesture"\s+bind:smearingchange="onContentGesture"><slot name="content" \/><\/scroll-view>/);
  const search = load('cyl-search')({ showsContent: true, inline: true });
  assert.equal(search.data.contentScrollHeld, false, 'scrolling is on, also while a list is in its editing mode');
  search.onContentGesture({ type: 'reorderingchange', detail: { reordering: true } });
  assert.equal(search.data.contentScrollHeld, true, 'a drag holds the scrolling');
  search.onContentGesture({ type: 'smearingchange', detail: { smearing: true } });
  search.onContentGesture({ type: 'reorderingchange', detail: { reordering: false } });
  assert.equal(search.data.contentScrollHeld, true, 'a smear still active holds it');
  search.onContentGesture({ type: 'smearingchange', detail: { smearing: false } });
  assert.equal(search.data.contentScrollHeld, false, 'the end of the last gesture releases it');
  search.onContentGesture({ type: 'reorderingchange', detail: { reordering: true } });
  search.onContentGesture({ type: 'reorderingchange', detail: { reordering: false } });
  assert.equal(search.data.contentScrollHeld, false, 'a cancelled drag releases it too (the list sends false)');
});

test('cyl-search: tags are the default suggestion style: CollectionViewClassifyMenu\'s tag list, folded to two rows, its fold control last', () => {
  const fs = require('node:fs');
  const read = (file) => fs.readFileSync(path.join(__dirname, '..', 'src', 'cyl-search', file), 'utf8');
  const wxml = read('index.wxml');
  assert.match(wxml, /<cyl-tag-list configuration="\{\{tagConfiguration\}\}" bind:tagtap="onSuggestionTap" \/>/, 'the tag list draws the tags');
  assert.doesNotMatch(wxml, /class="cyl-tag[ "]|cyl-measure|visibleTags|cyl-fold/, 'no hand-made chips, measuring row or fold chevron');
  assert.doesNotMatch(read('index.wxss'), /flex-wrap|\.cyl-tag\b|\.cyl-measure/, 'no flex wrap layout of tags');
  assert.equal(JSON.parse(read('index.json')).usingComponents['cyl-tag-list'], 'cyl-tag-list-miniprogram/cyl-tag-list/cyl-tag-list');
  const many = Array.from({ length: 10 }, (_, index) => 'Tag ' + index);
  const search = load('cyl-search')({ suggestions: many });
  assert.equal(search.properties.suggestionStyle, 'tags', 'the property defaults to tags');
  assert.equal(search.properties.foldedRowCount, 2);
  search.showSearch(false);
  search.onTextChange({ detail: { text: 'tag' } });
  assert.equal(search.data.shownSuggestions.length, 10);
  const configuration = search.data.tagConfiguration;
  assert.equal(configuration.defaultVisibleRows, 2, 'folded to two rows at start');
  assert.deepEqual(configuration.foldControl, { position: 'tail', content: 'icon' }, 'the fold control is the last tag, as an icon');
  assert.equal(configuration.selectionMode, 'none');
  assert.equal(configuration.showsSectionHeaders, false);
  assert.deepEqual(configuration.sections[0].items.map((item) => item.title), many);
  search.onTextChange({ detail: { text: 'tag ' } });
  assert.strictEqual(search.data.tagConfiguration, configuration, 'a keystroke that keeps the tags keeps the configuration (and the fold state)');
  search.onTextChange({ detail: { text: 'tag 1' } });
  assert.deepEqual(search.data.tagConfiguration.sections[0].items.map((item) => item.title), ['Tag 1']);
  const list = load('cyl-search')({ suggestions: ['A'], suggestionStyle: 'list' });
  assert.equal(list.properties.suggestionStyle, 'list', 'the list stays available');
  assert.equal(list.data.tagConfiguration, null);
});

test('cyl-search-refresh-button shows the built-in icon, reads the localized label and sends tap', () => {
  const button = load('cyl-search-refresh-button')();
  assert.equal(button.data.icon, '../images/refresh.svg');
  assert.equal(button.data.text, 'Refresh');
  button.onTap();
  assert.deepEqual(names(button), ['tap']);
  assert.equal(load('cyl-search-refresh-button')({ label: 'Reload' }).data.text, 'Reload');
});

test('cyl-search-navigation-bar sits below the status bar and ends before the menu button', () => {
  global.wx.getWindowInfo = () => ({ statusBarHeight: 44, windowWidth: 390 });
  global.wx.getMenuButtonBoundingClientRect = () => ({ top: 48, height: 32, left: 296, right: 383 });
  try {
    const bar = load('cyl-search-navigation-bar')({ showsBack: true });
    assert.equal(bar.data.metrics.navigationBarHeight, 40);
    assert.equal(bar.data.metrics.fieldHeight, 36);
    // 44 pt status bar, 16 pt leading margin, the trailing side clears the capsule (101 pt), the bar is 40 pt high.
    assert.equal(bar.data.barStyle, 'padding: 44px 101px 0 16px; height: 40px;');
    assert.equal(bar.data.contentStyle, '', 'the bar takes the free width by flex: 1, beside the back slot');
    assert.equal(bar.data.backShown, true, 'showsBack is the initial state, shown at once');
    assert.equal(bar.data.backAnimated, false);
    assert.equal(bar.data.back, 'Back');
    let navigatedBack = 0;
    global.wx.navigateBack = () => { navigatedBack += 1; };
    bar.onBack();
    assert.deepEqual(names(bar), ['back']);
    assert.equal(navigatedBack, 1, 'the back arrow goes back by itself');
    bar.properties.autoBack = false;
    bar.onBack();
    assert.equal(navigatedBack, 1, 'autoBack false leaves it to the page');
  } finally {
    delete global.wx.navigateBack;
    delete global.wx.getWindowInfo;
    delete global.wx.getMenuButtonBoundingClientRect;
  }
});

test('cyl-search-bar appearance: its cancelTitle and clearIconImage are drawn, the bar\'s own title wins', () => {
  const { CYLSearchBarAppearance } = require('../src/core/CYLSearchBarView');
  const appearance = Object.assign(CYLSearchBarAppearance.default(), { cancelTitle: 'Close', clearIconImage: '/images/clear.png' });
  const bar = load('cyl-search-bar')({ appearance });
  assert.equal(bar.data.appearanceCancelTitle, 'Close');
  assert.equal(bar.data.clearIcon, '/images/clear.png');
  const own = load('cyl-search-bar')({ appearance, cancelButtonTitle: 'Done' });
  assert.equal(own.data.cancelButtonTitle, 'Done');
  const plain = load('cyl-search-bar')({});
  assert.equal(plain.data.appearanceCancelTitle, '');
  assert.equal(plain.data.clearIcon, '');
  // The template shows the bar's title first, then the appearance's, then the localized Cancel; the image replaces the mask.
  const wxml = require('fs').readFileSync(path.join(__dirname, '..', 'src', 'cyl-search-bar', 'index.wxml'), 'utf8');
  assert.match(wxml, /\{\{cancelButtonTitle \|\| appearanceCancelTitle \|\| labels\.cancel\}\}/);
  assert.match(wxml, /<image wx:if="\{\{clearIcon\}\}"[^>]*src="\{\{clearIcon\}\}"/);
});
