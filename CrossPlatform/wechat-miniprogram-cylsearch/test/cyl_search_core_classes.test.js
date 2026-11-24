// The core classes that give the iOS names to what CYLSearchBarView and CYLSearchView hold: CYLSearchBar, CYLSearchBarAppearance,
// CYLSearchController, CYLSearchTableViewController, CYLSearchNavigationBar, CYLSearchTagListStyle / Header, and the
// additions to CYLSearchView, CYLSearchBarView and CYLSearchResources.
const test = require('node:test');
const assert = require('node:assert/strict');

const store = {};
global.wx = {
  getStorageSync: (key) => store[key],
  setStorageSync: (key, value) => { store[key] = value; },
  getAppBaseInfo: () => ({ language: 'en' }),
  getWindowInfo: () => ({ windowWidth: 400, statusBarHeight: 20 }),
};

const { CYLSearchBarView, CYLSearchBarAppearance } = require('../src/core/CYLSearchBarView');
const { CYLSearchView } = require('../src/core/CYLSearchView');
const { CYLSearchResources, CYLSearchSuggestionCachePolicy } = require('../src/core/CYLSearchResources');
const { CYLSearchBar } = require('../src/core/CYLSearchBar');
const { CYLSearchController } = require('../src/core/CYLSearchController');
const { CYLSearchTableViewController } = require('../src/core/CYLSearchTableViewController');
const { CYLSearchNavigationBar } = require('../src/core/CYLSearchNavigationBar');
const { CYLSearchTagListStyle, CYLSearchTagListHeader } = require('../src/core/CYLSearchTagListStyle');

test('CYLSearchBarAppearance: every iOS key, a copy, the CSS of the images and the hidden background', () => {
  const values = CYLSearchBarAppearance.default();
  ['font', 'textColor', 'placeholderColor', 'placeholder', 'cancelTitle', 'tintColor', 'searchIconImage', 'clearIconImage',
    'textFieldBackgroundColor', 'textFieldBackgroundImage', 'textFieldBorderColor', 'textFieldCornerRadius', 'barBackgroundImage',
    'barBackgroundColor', 'barBorderColor', 'hidesBarBackground'].forEach((key) => assert.ok(key in values, key));
  assert.equal(values.hidesBarBackground, true);
  const copy = new CYLSearchBarAppearance();
  copy.font = 20;
  assert.equal(copy.copy().font, 20);
  assert.equal(new CYLSearchBarAppearance().font, 17);
  const css = CYLSearchBarAppearance.styles({ textFieldBackgroundImage: '/f.png', barBackgroundImage: '/b.png', searchIconImage: '/s.svg' }, false);
  assert.match(css.field, /url\(\/f\.png\)/);
  assert.match(css.bar, /url\(\/b\.png\)/);
  assert.equal(css.searchIcon, '/s.svg');
  assert.equal(CYLSearchBarAppearance.styles({}, false).bar, '');
  assert.match(CYLSearchBarAppearance.styles({ hidesBarBackground: false }, false).bar, /background: #F7F7F7/);
  assert.equal(CYLSearchBarAppearance.backgroundCSS(undefined, undefined), undefined);
  assert.equal(CYLSearchBarAppearance.backgroundCSS(undefined, '#ccc'), 'background: #FFFFFF; border-bottom: 1px solid #ccc');
  assert.equal(CYLSearchBarAppearance.textFieldBackgroundCSS('#eee'), 'background: #eee');
});

test('CYLSearchBarView: appearanceStyle maps onto the bar, setItems keeps the items when only the playback differs', () => {
  const bar = new CYLSearchBarView();
  bar.applyDefaultAppearance();
  assert.equal(bar.font, 17);
  assert.equal(bar.fieldCornerRadius, -1);
  assert.equal(bar.fieldBackgroundColor, '#BBBAC1');
  bar.appearanceStyle = Object.assign(CYLSearchBarAppearance.default(), { textColor: '#111', placeholder: 'Find', textFieldBorderColor: '#999', cancelTitle: 'Done' });
  assert.equal(bar.textColor, '#111');
  assert.equal(bar.placeholder, 'Find');
  assert.equal(bar.fieldBorderWidth, 1);
  assert.equal(bar.cancelButtonTitle, 'Done');
  assert.equal(bar.appearanceStyle.textColor, '#111');
  bar.setItems([{ style: 'text', title: 'A', animationLoops: false }, { style: 'text', title: 'B' }]);
  const first = bar.items[0];
  bar.setItems([{ style: 'text', title: 'A', animationLoops: true, animationSpeed: 2 }, { style: 'text', title: 'B' }]);
  assert.equal(bar.items[0], first);
  assert.equal(first.animationLoops, true);
  assert.equal(first.animationSpeed, 2);
  bar.setItems([{ style: 'text', title: 'C' }]);
  assert.equal(bar.items.length, 1);
  assert.notEqual(bar.items[0], first);
  assert.equal(first.searchBarView, undefined);
});

test('CYLSearchBar: the knobs read and write the bar view', () => {
  const view = new CYLSearchBarView();
  const bar = new CYLSearchBar(view);
  bar.centersPlaceholder = true;
  bar.placeholderColor = '#aaa';
  bar.textColor = '#222';
  bar.font = 15;
  bar.textFieldMargins = { top: 1, left: 2, bottom: 3, right: 4 };
  bar.cancelButtonFont = { size: 14, weight: 600 };
  bar.leadingAccessoryViewMargins = { top: 0, left: 0, bottom: 0, right: 8 };
  assert.equal(view.centersPlaceholder, true);
  assert.equal(view.placeholderColor, '#aaa');
  assert.equal(view.textColor, '#222');
  assert.equal(view.font, 15);
  assert.equal(view.textFieldMarginsFor(false).left, 2);
  assert.equal(view.cancelButtonFont.size, 14);
  assert.equal(view.leadingAccessoryMargins.right, 8);
  const provider = (_, active) => ({ top: 0, left: active ? 10 : 0, bottom: 0, right: 0 });
  bar.textFieldMarginsProvider = provider;
  assert.equal(view.textFieldMarginsFor(true).left, 10);
  bar.setShowsLeadingAccessoryView(false);
  assert.equal(bar.showsLeadingAccessoryView, false);
  bar.showsTrailingAccessoryView = false;
  assert.equal(view.showsTrailingAccessoryViews, false);
  assert.equal(bar.isCancelButtonEnabled(false), true);
  bar.alwaysEnablesCancelButton = false;
  assert.equal(bar.isCancelButtonEnabled(false), false);
  assert.equal(bar.isCancelButtonEnabled(true), true);
  assert.equal(bar.backgroundImage('#fff', '#ccc'), 'background: #fff; border-bottom: 1px solid #ccc');
  assert.equal(bar.textFieldBackgroundImage(undefined), undefined);
});

test('CYLSearchResources: the shared store, its change event and the history notification name', () => {
  assert.equal(CYLSearchResources.historyDidChangeNotification, 'CYLSearchSuggestionStoreDidChange');
  assert.equal(CYLSearchResources.suggestionCache(CYLSearchSuggestionCachePolicy.none, 'x'), undefined);
  const memory = {};
  const storage = { getSync: (k) => memory[k], setSync: (k, v) => { memory[k] = v; } };
  const cache = CYLSearchResources.suggestionCache(CYLSearchSuggestionCachePolicy.database, 'core-test', storage);
  const seen = [];
  const stop = CYLSearchResources.observeHistory((changed) => seen.push(changed));
  cache.addQuery('one');
  cache.addQuery('two');
  assert.deepEqual(cache.cachedQueries(), ['two', 'one']);
  assert.equal(seen.length, 2);
  assert.equal(seen[0], cache);
  stop();
  cache.removeAllQueries();
  assert.equal(seen.length, 2);
});

test('CYLSearchView: the will events, the results header, the cache footer, the highlight color and the snapping flag', () => {
  const view = new CYLSearchView({ getSync: () => undefined, setSync: () => {} });
  const events = [];
  view.delegate = { searchViewWillShow: () => events.push('willShow'), searchViewWillClose: () => events.push('willClose') };
  view.showSearch(false);
  view.closeSearch(false);
  assert.deepEqual(events, ['willShow', 'willClose']);
  view.resultsDataSource = { searchViewResultsForQuery: () => ['a', 'b'] };
  view.resultsHeaderTitleProvider = (query) => (query ? `${query}: results` : undefined);
  view.query = 'ab';
  view.reloadResults();
  assert.equal(view.resultsHeaderTitle, 'ab: results');
  view.resultsHeaderTitleProvider = () => '';
  assert.equal(view.resultsHeaderTitle, undefined);
  view.suggestionCacheFooterTitle = 'Clear';
  assert.equal(view.suggestionCacheFooter, undefined);
  view.showsCachedQueries = true;
  assert.equal(view.suggestionCacheFooter, 'Clear');
  view.setSnapsHeader(false);
  assert.equal(view.snapsHeaderSearchBar, false);
  assert.equal(view.resultMatchHighlightColor, undefined);
});

test('CYLSearchController: forwards to the search view, tells the delegate, loads the results once', () => {
  const controller = new CYLSearchController({ getSync: () => undefined, setSync: () => {} });
  const view = controller.searchView;
  const calls = [];
  controller.searchResultsDelegate = {
    searchControllerUpdateResultsForSearchString: (_, text) => calls.push(['update', text]),
    searchControllerDidLoadSearchResultsTableView: () => calls.push(['load']),
    searchControllerWillShowEmptyView: (_, scenario) => calls.push(['empty', scenario]),
    willPresentSearchController: () => calls.push(['willPresent']),
    didPresentSearchController: () => calls.push(['didPresent']),
    willDismissSearchController: () => calls.push(['willDismiss']),
    didDismissSearchController: () => calls.push(['didDismiss']),
  };
  controller.highlightsResultMatches = true;
  controller.resultMatchHighlightColor = '#f00';
  controller.dimmingColor = 'rgba(0,0,0,0.4)';
  controller.showsSuggestionsLaunchView = true;
  controller.launchView = true;
  controller.alwaysShowsSearchResultsController = true;
  controller.noResultsText = 'Nothing';
  assert.equal(view.highlightsResultMatches, true);
  assert.equal(view.resultMatchHighlightColor, '#f00');
  assert.equal(view.scrimColor, 'rgba(0,0,0,0.4)');
  assert.equal(view.showsSuggestionsLaunchView, true);
  assert.equal(view.showsLaunchView, true);
  assert.equal(view.showsResultsForEmptyQuery, true);
  assert.equal(controller.noResultsText, 'Nothing');
  view.resultsDataSource = { searchViewResultsForQuery: (_, q) => (q === 'x' ? [] : ['row']) };
  controller.isActive = true;
  assert.equal(controller.isSearchOpen, true);
  // The results show at once (alwaysShowsSearchResultsController), so the list loads with the first update, once.
  assert.deepEqual(calls.slice(0, 4), [['willPresent'], ['didPresent'], ['update', ''], ['load']]);
  view.textChanged('row');
  controller.updateSearchResults('row');
  assert.equal(calls.filter((c) => c[0] === 'load').length, 1);
  assert.equal(controller.showEmptyViewForScenario('NoSearchResults'), false, 'the results are not empty');
  view.textChanged('x');
  assert.equal(controller.showEmptyViewForScenario('NoSearchResults'), true);
  assert.deepEqual(calls.filter((c) => c[0] === 'empty'), [['empty', 'NoSearchResults'], ['empty', 'NoSearchResults']]);
  controller.setActive(false, false);
  assert.deepEqual(calls.filter((c) => /Dismiss/.test(c[0])).map((c) => c[0]), ['willDismiss', 'didDismiss']);
  controller.setActive(true, false);
  controller.updateSearchResults('row');
  assert.equal(calls.filter((c) => c[0] === 'load').length, 2, 'a new presentation loads the list again');
  controller.setActive(false, false);
  assert.equal(controller.isActive, false);
  assert.equal(CYLSearchController.historyDidChangeNotification, 'CYLSearchControllerHistoryDidChange');
  controller.installSearchBar();
  assert.equal(view.showsSearchBar, true);
  assert.equal(controller.searchBar.usedAsTableHeaderView, true);
  assert.equal(controller.searchBarMaxY, 20 + 44);
});

test('CYLSearchController: the empty view for a scenario needs text; the edge swipe needs the swipe on and the search open', () => {
  const controller = new CYLSearchController({ getSync: () => undefined, setSync: () => {} });
  assert.equal(controller.showEmptyViewForScenario('NoContent'), false);
  assert.equal(controller.gestureRecognizerShouldBegin(5, 30, 2), false);
  controller.supportsSwipeToDismissSearch = true;
  controller.showSearch(false);
  assert.equal(controller.gestureRecognizerShouldBegin(5, 30, 2), true);
  assert.equal(controller.gestureRecognizerShouldBegin(100, 30, 2), false);
});

test('CYLSearchTableViewController: the bar is created on viewDidLoad, the hooks run, the empty view hides the bar', () => {
  const calls = [];
  class Screen extends CYLSearchTableViewController {
    setUpSearchBar() { calls.push('setUp'); this.searchBar.font = 14; }
    searchControllerUpdateResultsFor(_, text) { calls.push(['update', text]); }
  }
  const screen = new Screen({ getSync: () => undefined, setSync: () => {} });
  assert.equal(screen.searchController, undefined);
  assert.equal(screen.searchBar, undefined);
  screen.hidesSearchBarWhenEmptyViewShowing = true;
  screen.hidesSearchBarInitially = true;
  screen.viewDidLoad();
  assert.equal(screen.searchBar, undefined, 'no bar while showsSearchBar is off');
  screen.showsSearchBar = true;
  screen.viewDidLoad();
  assert.deepEqual(calls, ['setUp']);
  assert.equal(screen.searchController.searchView.showsSearchBar, true);
  assert.equal(screen.searchController.searchView.hidesSearchBarInitially, true);
  assert.equal(screen.searchBar.font, 14);
  assert.equal(screen.hidesSearchBarWhenEmptyViewShowing, true);
  screen.searchController.searchView.textChanged('q');
  assert.deepEqual(calls.slice(1), [['update', 'q']]);
  assert.equal(screen.showEmptyView('None', 'Try again'), true);
  assert.equal(screen.isEmptyViewShowing, true);
  assert.equal(screen.searchController.searchView.hidesHeaderBar, true);
  screen.hideEmptyView();
  assert.equal(screen.isEmptyViewShowing, false);
  screen.showsSearchBar = false;
  screen.viewDidLoad();
  assert.equal(screen.searchController, undefined);
});

test('CYLSearchNavigationBar: the holding bar is set up, the back button calls the handler and keeps the items', () => {
  assert.equal(CYLSearchNavigationBar.standardHeight, 44);
  const view = new CYLSearchBarView();
  const bar = CYLSearchNavigationBar.holding(view, true);
  assert.equal(bar.searchBarView, view);
  assert.equal(bar.showsBackButton, true);
  assert.equal(view.fieldHeight, 36);
  assert.deepEqual(view.contentInsets, { top: 0, left: 0, bottom: 0, right: 0 });
  assert.equal(CYLSearchNavigationBar.holding(view).showsBackButton, false);
  let backs = 0;
  bar.backHandler = () => { backs += 1; };
  assert.equal(bar.navigationBar(), false);
  assert.equal(backs, 1);
  assert.equal(new CYLSearchNavigationBar().navigationBar(), false);
  const widths = bar.widths({ windowWidth: 400 }, null);
  assert.equal(widths.back, 40);
  assert.equal(widths.fieldWidth, 400 - 16 - 16 - 40);
});

test('CYLSearchTagListStyle: the defaults, the customizer, the grid, the glass name and the refresh icon', () => {
  assert.equal(CYLSearchTagListStyle.tagCornerRadius, 1000);
  assert.equal(CYLSearchTagListStyle.tagBackgroundStyle, 'flat');
  assert.equal(CYLSearchTagListHeader.refreshImage, CYLSearchResources.imageNamed('refresh'));
  assert.equal(CYLSearchTagListHeader.refreshAccessibilityLabel, 'Refresh');
  const style = CYLSearchTagListStyle.applyDefaults({ backgroundColor: 'clear' });
  assert.equal(style.backgroundColor, 'clear', 'values the defaults do not name stay');
  assert.equal(style.normal.cornerRadius, 1000);
  assert.equal(style.normal.borderWidth, 1);
  assert.equal(style.itemHeight, 36);
  assert.equal(style.headerHeight, 44);
  CYLSearchTagListStyle.styleCustomizer = (s) => { s.itemHeight = 40; };
  assert.equal(CYLSearchTagListStyle.applyDefaults({}).itemHeight, 40);
  CYLSearchTagListStyle.styleCustomizer = undefined;
  const configuration = { style: { lineSpacing: 5 }, sections: [] };
  CYLSearchTagListStyle.applyDefaultStyle(configuration);
  assert.equal(configuration.style.lineSpacing, 12);
  assert.equal(configuration.style.moreButtonImage, CYLSearchTagListHeader.refreshImage);
  CYLSearchTagListStyle.applyBackgroundStyle('LiquidGlass', configuration);
  assert.equal(configuration.style.backgroundStyle, 'liquidGlass');
  assert.equal(configuration.style.itemHeight, 36, 'the other style values stay');
  CYLSearchTagListStyle.applyBackgroundStyle('', configuration);
  assert.equal(configuration.style.backgroundStyle, 'flat');
  CYLSearchTagListStyle.applyGrid(0, configuration);
  assert.equal(configuration.style.itemHeight, 36);
  CYLSearchTagListStyle.applyGrid(3, configuration);
  assert.equal(configuration.style.itemsPerRow, 3);
  assert.equal(configuration.style.lineSpacing, 16);
  CYLSearchTagListStyle.tagBackgroundStyle = 'liquidGlass';
  CYLSearchTagListStyle.tagCornerRadius = 6;
  const glass = CYLSearchTagListStyle.applyDefaults({});
  assert.equal(glass.backgroundStyle, 'liquidGlass');
  assert.equal(glass.normal.borderWidth, 0);
  assert.equal(glass.normal.cornerRadius, 6);
  CYLSearchTagListStyle.tagBackgroundStyle = 'flat';
  CYLSearchTagListStyle.tagCornerRadius = 1000;
});
