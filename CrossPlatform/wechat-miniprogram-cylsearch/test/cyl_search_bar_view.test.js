// The search bar module (src/core/CYLSearchBarView.js): items, text and submit, and the "multiple" mode (was
// CYLMultiSearchView).
const test = require('node:test');
const assert = require('node:assert/strict');
const { CYLSearchBarView, CYLSearchBarItem, CYLSearchBarItemStyle, CYLSearchBarMode } = require('../src/core/CYLSearchBarView');

test('items are appended like the FlatDesign tab bar items and report their taps', () => {
  const bar = new CYLSearchBarView();
  const events = [];
  bar.delegate = { searchBarViewDidSelectItem: (_, item) => events.push(`select ${item.index}`) };
  let cameraTaps = 0;
  const camera = CYLSearchBarItem.iconItem('camera.png', 'Camera', () => { cameraTaps += 1; });
  const divider = CYLSearchBarItem.divider();
  const search = CYLSearchBarItem.textItem('Search');
  assert.equal(camera.index, -1);
  bar.addItem(camera);
  bar.addItem(search);
  bar.insertItem(divider, 1);
  assert.deepEqual(bar.items, [camera, divider, search]);
  assert.equal(search.index, 2);
  assert.equal(bar.hasItem(CYLSearchBarItemStyle.text), true);
  bar.itemTapped(camera);
  assert.equal(cameraTaps, 1);
  assert.deepEqual(events, ['select 0']);
  camera.isEnabled = false;
  bar.itemTapped(camera);
  bar.itemTapped(divider);
  assert.equal(cameraTaps, 1);
  camera.isEnabled = true;
  camera.isSelectable = true;
  assert.equal(bar.selectedItem, undefined);
  bar.itemTapped(camera);
  assert.equal(camera.isSelected, true);
  assert.equal(bar.selectedIndex, 0);
  bar.removeItem(divider);
  assert.deepEqual(bar.items, [camera, search]);
  const added = bar.addItemWithStyle(CYLSearchBarItemStyle.icon, 'Mic', 'mic.svg', 0);
  assert.equal(added.index, 0);
  bar.removeAllItems();
  assert.equal(bar.items.length, 0);
  assert.equal(camera.searchBarView, undefined);
});

test('an item is built from plain values and gives them back', () => {
  const item = CYLSearchBarItem.item({ style: 'icon', title: 'Camera', image: 'camera', accessibilityIdentifier: 'camera', isSelectable: true, badgeValue: '3' });
  assert.equal(item.style, 'icon');
  assert.equal(item.image, '../images/camera.svg');
  assert.equal(item.itemAccessibilityIdentifier, 'camera');
  assert.equal(item.accessibilityText, 'Camera, 3');
  assert.deepEqual(CYLSearchBarItem.item(item.itemDictionary()).itemDictionary(), item.itemDictionary());
  assert.equal(CYLSearchBarItem.item({ style: 'divider' }).style, 'divider');
  assert.equal(CYLSearchBarItem.item({ style: 'text', title: 'Search' }).style, 'text');
  assert.equal(CYLSearchBarItem.item({ image: '/a.png' }).image, '/a.png');
});

test('the text is cut to maximumTextLength and submitted unless the delegate refuses it', () => {
  const bar = new CYLSearchBarView();
  const events = [];
  bar.maximumTextLength = 4;
  bar.delegate = {
    searchBarViewTextDidChange: (_, text) => events.push(`text ${text}`),
    searchBarViewShouldSubmitText: (_, text) => text !== 'no',
    searchBarViewSearchButtonClicked: (b) => events.push(`submit ${b.text}`),
  };
  assert.equal(bar.submit(), false, 'an empty text is not submitted');
  bar.setText('Swifty', true);
  bar.setText('no', true);
  bar.textChanged('no');
  assert.deepEqual(events, ['text Swif', 'submit Swif', 'text no']);
});

test('the multiple mode completes, selects and removes searches with the indexed events', () => {
  const bar = new CYLSearchBarView();
  bar.mode = CYLSearchBarMode.multiple;
  const events = [];
  bar.delegate = {
    searchBarViewTextDidChange: () => events.push('single text'),
    searchBarViewTextDidChangeAtIndex: (_, text, index) => events.push(`text ${text} ${index}`),
    searchBarViewDidCompleteSearch: (_, text, index) => events.push(`complete ${text} ${index}`),
    searchBarViewDidSelectSearch: (_, text, index) => events.push(`select ${text} ${index}`),
    searchBarViewDidRemoveSearchAtIndex: (_, index) => events.push(`remove ${index}`),
  };
  assert.equal(bar.selectedSearchIndex, -1);
  bar.beginNewSearch();
  assert.equal(bar.isEditingNewSearch, true);
  assert.equal(bar.isKeyboardRequested, true);
  bar.textChanged('Swift');
  assert.deepEqual(bar.searches, ['Swift']);
  assert.equal(bar.submit(), true, 'the search key completes the search');
  bar.beginNewSearch();
  bar.textChanged('ab');
  bar.completeSearch();
  assert.deepEqual(bar.searches, ['Swift'], 'a search shorter than minimumTextLength is dropped');
  assert.equal(bar.selectedSearchIndex, 0);
  bar.addSearch('Kotlin');
  bar.addSearch('  ');
  bar.selectSearch(0);
  bar.removeSearch(1);
  bar.removeSearch(5);
  assert.deepEqual(bar.searches, ['Swift']);
  assert.equal(bar.selectedSearchIndex, 0);
  bar.removeSearch(0);
  assert.equal(bar.selectedSearchIndex, -1);
  assert.equal(bar.intrinsicContentSize, 48);
  assert.deepEqual(events, ['text Swift 0', 'complete Swift 0', 'text ab 1', 'complete Kotlin 1', 'select Swift 0', 'remove 1', 'remove 0']);
});

test('the restorable state keeps the text, the icon state and the searches', () => {
  const bar = new CYLSearchBarView();
  bar.mode = CYLSearchBarMode.multiple;
  bar.addSearch('one');
  bar.addSearch('two');
  bar.selectSearch(0);
  const copy = new CYLSearchBarView();
  copy.mode = CYLSearchBarMode.multiple;
  copy.decodeRestorableState(bar.encodeRestorableState());
  assert.deepEqual(copy.searches, ['one', 'two']);
  assert.equal(copy.selectedSearchIndex, 0);
});
