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
    instance.createSelectorQuery = () => ({ selectAll() {}, select() {}, exec() {} });
    instance.set = (key, value) => {
      instance.properties[key] = value;
      instance.data[key] = value;
      const observer = definition.properties[key].observer;
      if (observer) instance[observer](value);
    };
    definition.lifetimes.created.call(instance);
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

test('cyl-search: submit closes the overlay with its transition, Cancel closes it with the completion', async () => {
  const search = load('cyl-search')({});
  search.model.animationDuration = 0.01;
  search.showSearch(false);
  assert.equal(search.data.visible, true);
  search.onTextChange({ detail: { text: 'Swift' } });
  search.onSubmit({ detail: { text: 'Swift' } });
  assert.equal(search.data.open, false);
  assert.deepEqual(names(search), ['show', 'textchange', 'submit', 'close']);
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
  assert.equal(text.tagStyle.normal.contentInsets.left, 4);
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
