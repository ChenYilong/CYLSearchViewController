// The example screens of the QMUI search port: "Search controller" (QDSearchViewController), "Search bar styles"
// (QDSearchBarViewController) and "Short list" (issue #1160 scenario), driven with a stand-in of Page and the cyl-search
// component's API. The examples read their texts from the iOS bundles in four languages.
const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('path');
const fs = require('node:fs');

const example = path.join(__dirname, '..', 'example', 'miniprogram');
global.wx = {
  getStorageSync: () => undefined, setStorageSync: () => {}, getAppBaseInfo: () => ({ language: 'en' }),
  getWindowInfo: () => ({ windowHeight: 800, windowWidth: 400, statusBarHeight: 20 }),
  getMenuButtonBoundingClientRect: () => ({ top: 26, height: 32, right: 370, left: 280, width: 90, bottom: 58 }),
  getSystemInfoSync: () => ({ windowHeight: 800, windowWidth: 400, statusBarHeight: 20 }),
  nextTick: (fn) => fn(),
};

// The tag list package is installed by the example's sync script (git-ignored): a stand-in with its default style shape.
const Module = require('module');
const loadModule = Module._load;
Module._load = function load(request, ...rest) {
  if (request === 'cyl-tag-list-miniprogram') return { tagCloud: { defaultStyle: () => ({ normal: {}, selected: {}, disabled: {} }) } };
  return loadModule.call(this, request, ...rest);
};

function page(name, search) {
  let definition;
  global.Page = (options) => { definition = options; };
  global.getCurrentPages = () => [{}, {}];
  const file = path.join(example, 'pages', name, 'index.js');
  delete require.cache[require.resolve(file)];
  require(file);
  const instance = { data: JSON.parse(JSON.stringify(definition.data)), ...definition };
  instance.setData = (values) => Object.assign(instance.data, values);
  instance.selectComponent = () => search;
  return instance;
}

function fakeSearch() {
  const calls = [];
  const state = { history: [], active: false };
  return {
    calls, state,
    history: () => state.history,
    clearHistory: () => { state.history = []; calls.push('clearHistory'); },
    showEmptyView: (text) => calls.push(['showEmptyView', text]),
    hideEmptyView: () => calls.push('hideEmptyView'),
    isActive: () => state.active,
    setActive: (active) => { state.active = active; calls.push(['setActive', active]); },
    setTextFieldMarginsProvider: (provider) => calls.push(['field', provider({}, false), provider({}, true)]),
    setCancelButtonMarginsProvider: (provider) => calls.push(['cancel', provider({}, true)]),
    setShowsCancelButton: (shows, animated) => calls.push(['cancelShown', shows, animated]),
    setShowsLeadingAccessoryView: (shows, animated) => calls.push(['leading', shows, animated]),
    setShowsTrailingAccessoryView: (shows, animated) => calls.push(['trailing', shows, animated]),
  };
}

test('Search controller: ten keywords, twenty rows per match, "No matching results", the launch view lists history or suggestions', () => {
  const search = fakeSearch();
  const screen = page('searchController', search);
  screen.onLoad();
  assert.equal(screen.data.title, 'Search controller');
  assert.deepEqual(screen.data.keywords, ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat', 'Metabolism', 'Nuturally']);
  screen.onReady();
  assert.equal(screen.data.tags.length, 8, 'the eight suggestions without a history');
  assert.equal(screen.data.hasHistory, false);
  screen.onUpdateResults({ detail: { text: 'Health' } });
  assert.equal(screen.data.results.length, 40, 'Health and Healthy, twenty rows each');
  assert.equal(screen.data.results.filter((row) => row === 'Health').length, 20);
  assert.deepEqual(search.calls.at(-1), 'hideEmptyView');
  screen.onUpdateResults({ detail: { text: 'zzz' } });
  assert.deepEqual(screen.data.results, []);
  assert.deepEqual(search.calls.at(-1), ['showEmptyView', 'No matching results']);
  screen.onUpdateResults({ detail: { text: '' } });
  assert.deepEqual(screen.data.results, []);
  // A submitted query: historychange makes the launch view read the history again while it stays on screen.
  search.state.history = ['Liver', 'Fat'];
  screen.onHistoryChange();
  assert.deepEqual(screen.data.tags.map((tag) => tag.title), ['Liver', 'Fat']);
  assert.equal(screen.data.hasHistory, true);
  screen.onClearHistory();
  assert.equal(screen.data.hasHistory, false);
  assert.equal(screen.data.tags.length, 8);
});

test('Search bar styles: sections, rows and the bar calls of QDSearchBarViewController', () => {
  const search = fakeSearch();
  const screen = page('searchBarStyles', search);
  screen.onLoad();
  const rows = screen.data.sections.flatMap((section) => section.rows.map((row) => row.text));
  assert.deepEqual(screen.data.sections.map((section) => section.title), ['Placeholder', 'Layout', 'Accessory view']);
  assert.deepEqual(rows, ['Center placeholder', 'Change placeholder', 'Adjust the field at rest', 'Adjust Cancel while searching',
    'Animated', 'Show Cancel', 'Show leading accessory', 'Show trailing accessory']);
  assert.equal(screen.data.showsLeading, false, 'hidden first');
  screen.onSwitch({ currentTarget: { dataset: { id: 'center' } }, detail: { value: true } });
  assert.equal(screen.data.centersPlaceholder, true);
  screen.onRow({ currentTarget: { dataset: { id: 'change' } } });
  assert.equal(screen.data.placeholder, 'A very very very long placeholder');
  screen.onRow({ currentTarget: { dataset: { id: 'field' } } });
  assert.deepEqual(search.calls.at(-1), ['field', { top: 0, left: 32, bottom: 0, right: 32 }, { top: 0, left: 0, bottom: 0, right: 0 }], 'margins 32 at rest, none searching');
  screen.onRow({ currentTarget: { dataset: { id: 'cancelMargins' } } });
  assert.deepEqual(search.calls.at(-2), ['cancel', { top: 0, left: -16, bottom: 0, right: 0 }]);
  assert.deepEqual(search.calls.at(-1), ['setActive', true], 'it also starts the search');
  screen.onRow({ currentTarget: { dataset: { id: 'leading' } } });
  assert.deepEqual(search.calls.at(-1), ['leading', true, true]);
  assert.equal(screen.data.sections[2].rows[2].text, 'Hide leading accessory');
  screen.onSwitch({ currentTarget: { dataset: { id: 'animated' } }, detail: { value: false } });
  screen.onRow({ currentTarget: { dataset: { id: 'trailing' } } });
  assert.deepEqual(search.calls.at(-1), ['trailing', true, false], 'not animated');
  screen.onRow({ currentTarget: { dataset: { id: 'cancel' } } });
  assert.deepEqual(search.calls.at(-1), ['cancelShown', true, false]);
  screen.onRow({ currentTarget: { dataset: { id: 'cancel' } } });
  assert.deepEqual(search.calls.at(-1), ['cancelShown', false, false]);
});

test('Short list: three rows under the bar, the matching rows, the empty view', () => {
  const search = fakeSearch();
  const screen = page('shortList', search);
  screen.onLoad();
  assert.deepEqual(screen.data.rows, ['Row 1', 'Row 2', 'Row 3']);
  screen.onUpdateResults({ detail: { text: 'row 2' } });
  assert.deepEqual(screen.data.results, ['Row 2']);
  screen.onUpdateResults({ detail: { text: 'x' } });
  assert.deepEqual(search.calls.at(-1), ['showEmptyView', 'No matching results']);
});

test('the screens are registered, in the menu after the contact tags, and the texts exist in four languages', () => {
  const app = JSON.parse(fs.readFileSync(path.join(example, 'app.json'), 'utf8'));
  ['searchBarStyles', 'searchController', 'shortList'].forEach((name) => {
    assert.ok(app.pages.includes(`pages/${name}/index`));
    ['index.js', 'index.json', 'index.wxml', 'index.wxss'].forEach((file) => assert.ok(fs.existsSync(path.join(example, 'pages', name, file)), `${name}/${file}`));
  });
  const menu = fs.readFileSync(path.join(example, 'pages', 'examples', 'index.js'), 'utf8');
  assert.ok(menu.indexOf('demo.searchBarStyles') < menu.indexOf('demo.searchController'), 'iOS order: styles (row 7), controller (row 8)');
  const resources = require(path.join(example, 'utils', 'cyl_demo_resources'));
  ['demo.searchBarStyles', 'demo.searchController', 'controller.recent', 'controller.noResults', 'styles.centerPlaceholder', 'styles.adjustField',
    'styles.adjustCancel', 'styles.animated', 'styles.show', 'styles.hide', 'demo.shortList', 'issue.row'].forEach((key) => {
    ['en', 'ja', 'zh-Hans', 'zh-Hant'].forEach((language) => assert.ok(resources.strings[language][key], `${language} ${key}`));
  });
  const wxml = fs.readFileSync(path.join(example, 'pages', 'searchController', 'index.wxml'), 'utf8');
  assert.match(wxml, /<cyl-tag-cloud/, 'the recent searches are the vendored tag list, not hand-drawn tags');
  assert.doesNotMatch(wxml, /<scroll-view/, 'the core owns the one scroller');
  const styles = fs.readFileSync(path.join(example, 'pages', 'searchBarStyles', 'index.wxss'), 'utf8');
  assert.match(styles, /width: 30px; height: 30px;[^}]*border: 3px solid/, '30 x 30 stroked accessories');
});
