// Runs the pure logic of the HarmonyOS search core on the host, without an emulator or a device.
// Usage (Node 22.18 or newer, which strips TypeScript types itself):
//   node harmonyos/scripts/host-logic-test.mjs
// The logic is private to the core files (CYLSearchBarView.ets, CYLSearchView.ets, CYLSearchResources.ets,
// CYLSearchController.ets, CYLSearchNavigationBar.ets, CYLSearchTagListStyle.ets),
// each between the lines "// MARK: - Pure logic (begin)" and "// MARK: - Pure logic (end)" (plain TypeScript, no kit
// import). This script copies those parts to a temporary .ts file, exports their functions, imports it and runs
// node:test cases that mirror the Android Kotlin tests of the same behaviour.
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { after, describe, it } from 'node:test';
import assert from 'node:assert/strict';

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, '..', 'cylsearch', 'src', 'main', 'ets');
const parts = ['CYLSearchBarView.ets', 'CYLSearchView.ets', 'CYLSearchResources.ets', 'CYLSearchController.ets',
  'CYLSearchNavigationBar.ets', 'CYLSearchTagListStyle.ets'].map((name) => {
  const text = readFileSync(join(core, name), 'utf8');
  const begin = text.indexOf('// MARK: - Pure logic (begin)');
  const end = text.indexOf('// MARK: - Pure logic (end)');
  assert.ok(begin >= 0 && end > begin, `${name} has no pure logic part`);
  return text.slice(begin, end).replace(/^function /gm, 'export function ');
});
// The example's pure logic parts (the Placeholder styles page builds its tag lists in chunks).
const examplePart = readFileSync(join(here, '..', 'entry', 'src', 'main', 'ets', 'demos', 'CYLGalleryChunks.ets'), 'utf8');
parts.push(examplePart.slice(examplePart.indexOf('// MARK: - Pure logic (begin)'), examplePart.indexOf('// MARK: - Pure logic (end)'))
  .replace(/^function /gm, 'export function '));
const folder = mkdtempSync(join(tmpdir(), 'cyl-logic-'));
const target = join(folder, 'CYLSearchLogic.ts');
// ArkTS resource lookups ($r) have no host counterpart: a stub returns the resource name, so a pure logic part may
// hold a colour constant such as $r('app.color.cyl_search_secondary_label').
const arkTsStubs = "const $r = (name: string) => ({ resource: name });\n";
writeFileSync(target, arkTsStubs + parts.join('\n'));
const logic = await import(pathToFileURL(target).href);
after(() => rmSync(folder, { recursive: true, force: true }));

describe('cylFoldSearchText', () => {
  it('removes accents and lowercases', () => {
    assert.equal(logic.cylFoldSearchText('Café Crème'), 'cafe creme');
    assert.equal(logic.cylFoldSearchText('ÉLAN'), 'elan');
  });
});

describe('cylSuggestionMatches', () => {
  it('matches accents folded and the query trimmed', () => {
    assert.ok(logic.cylSuggestionMatches('Café', '  cafe '));
    assert.ok(!logic.cylSuggestionMatches('Kotlin', 'swift'));
  });
});

describe('cylFilterSuggestions', () => {
  const all = ['Swift', 'SwiftUI', 'Kotlin', 'Café'];
  it('shows the cached queries for an empty query', () => {
    const result = logic.cylFilterSuggestions('  ', ['Rust'], all, true);
    assert.deepEqual(result, { suggestions: ['Rust'], showsCachedQueries: true });
  });
  it('shows every suggestion for an empty query without a cache, with showsAllForEmptyQuery', () => {
    assert.deepEqual(logic.cylFilterSuggestions('', [], all, true).suggestions, all);
    assert.deepEqual(logic.cylFilterSuggestions('', [], all, false).suggestions, []);
  });
  it('lists matching cached queries first, then the other matches once', () => {
    const result = logic.cylFilterSuggestions('swi', ['SwiftUI'], all, false);
    assert.deepEqual(result, { suggestions: ['SwiftUI', 'Swift'], showsCachedQueries: false });
  });
  it('uses a custom filter', () => {
    const prefix = (suggestion, query) => suggestion.startsWith(query);
    assert.deepEqual(logic.cylFilterSuggestions('K', [], all, false, prefix).suggestions, ['Kotlin']);
  });
});

describe('cylQueriesAdding', () => {
  it('trims, moves to the front and keeps at most the maximum', () => {
    assert.deepEqual(logic.cylQueriesAdding(['A', 'B', 'C'], ' C ', 2), ['C', 'A']);
  });
  it('keeps at least one query', () => {
    assert.deepEqual(logic.cylQueriesAdding(['A'], 'B', 0), ['B']);
  });
  it('ignores a blank query', () => {
    assert.deepEqual(logic.cylQueriesAdding(['A'], '   ', 5), ['A']);
  });
});

describe('cylSearchMatchRange (the result highlight)', () => {
  it('finds the first match, ignoring case', () => {
    assert.deepEqual(logic.cylSearchMatchRange('Healthy', 'heal'), [0, 4]);
    assert.deepEqual(logic.cylSearchMatchRange('Healthy Health', 'HEALTH'), [0, 6]);
    assert.deepEqual(logic.cylSearchMatchRange('Maintain', 'tai'), [4, 7]);
  });
  it('ignores accents in the text and in the query', () => {
    assert.deepEqual(logic.cylSearchMatchRange('Café crème', 'cafe'), [0, 4]);
    assert.deepEqual(logic.cylSearchMatchRange('Café crème', 'CRÈME'), [5, 10]);
    // A decomposed text (e + combining acute) has a longer string than its folded form.
    const decomposed = 'cafe\u0301 bar';
    assert.deepEqual(logic.cylSearchMatchRange(decomposed, 'bar'), [6, 9]);
    assert.deepEqual(logic.cylSearchMatchRange(decomposed, 'cafe'), [0, 5]);
  });
  it('is undefined for an empty query or no match', () => {
    assert.equal(logic.cylSearchMatchRange('Health', ''), undefined);
    assert.equal(logic.cylSearchMatchRange('Health', 'zzz'), undefined);
  });
});

describe('swipe to dismiss rules (iOS CYLSearchEdgePanGestureRecognizer)', () => {
  it('begins at the left edge, moving right past the slop and more than vertically', () => {
    assert.ok(logic.cylSearchSwipeBegins(2, 12, 3));
    assert.ok(!logic.cylSearchSwipeBegins(30, 12, 3));
    assert.ok(!logic.cylSearchSwipeBegins(2, 8, 0));
    assert.ok(!logic.cylSearchSwipeBegins(2, -12, 0));
    assert.ok(!logic.cylSearchSwipeBegins(2, 12, 20));
  });
  it('ends the search past a quarter of the width', () => {
    assert.ok(logic.cylSearchSwipeCompletes(101, 400));
    assert.ok(!logic.cylSearchSwipeCompletes(100, 400));
    assert.ok(!logic.cylSearchSwipeCompletes(-50, 400));
  });
});

describe('cylSearchTextLimited', () => {
  it('cuts to the limit, or keeps the text with no limit', () => {
    assert.equal(logic.cylSearchTextLimited('Kotlin', 3), 'Kot');
    assert.equal(logic.cylSearchTextLimited('Kotlin', 0), 'Kotlin');
  });
});

describe('cylSearchTextCompletes', () => {
  it('needs a non-empty text of at least the minimum length, not trimmed', () => {
    assert.ok(!logic.cylSearchTextCompletes('', 0));
    assert.ok(!logic.cylSearchTextCompletes('ab', 3));
    assert.ok(logic.cylSearchTextCompletes('  ', 2));
    assert.ok(logic.cylSearchTextCompletes('abc', 3));
  });
});

describe('cylSelectionAfterRemoval', () => {
  it('selects the next item when the selected one is removed', () => {
    assert.equal(logic.cylSelectionAfterRemoval(1, 1, 3), 1);
  });
  it('selects the previous item when the last one is removed', () => {
    assert.equal(logic.cylSelectionAfterRemoval(2, 2, 2), 1);
  });
  it('keeps the same item when an earlier one is removed', () => {
    assert.equal(logic.cylSelectionAfterRemoval(2, 0, 2), 1);
  });
  it('keeps the selection when a later one is removed', () => {
    assert.equal(logic.cylSelectionAfterRemoval(0, 2, 2), 0);
  });
  it('selects the item at the removed place when nothing was selected', () => {
    assert.equal(logic.cylSelectionAfterRemoval(-1, 0, 1), 0);
  });
  it('selects nothing when no item is left', () => {
    assert.equal(logic.cylSelectionAfterRemoval(0, 0, 0), -1);
  });
});

describe('cylSearchTextSubmittable', () => {
  it('refuses blank text', () => {
    assert.ok(!logic.cylSearchTextSubmittable('   '));
    assert.ok(logic.cylSearchTextSubmittable(' Swift '));
  });
});

// Search bar items are drawn by CollectionViewClassifyMenu's CYLTagButton (iOS
// testSearchBarItemsAreAppendedLikeFlatDesignTabBarItems, Android CYLSearchBarItemTest): what the tag shows per style.
describe('cylSearchBarItemButtonContent', () => {
  const camera = { id: 'camera' };
  const selected = { id: 'camera.fill' };
  const gif = 'loading.gif';
  it('draws a text item with its title, its icon, its badge and its animation file', () => {
    const content = logic.cylSearchBarItemButtonContent(2, 'Search', camera, selected, undefined, 'asset:a.svga', '3');
    assert.deepEqual(content, {
      title: 'Search', image: camera, selectedImage: selected, animationURL: 'asset:a.svga', badgeValue: '3'
    });
  });
  it('draws an icon item with its icon only; the title is what screen readers read', () => {
    const content = logic.cylSearchBarItemButtonContent(0, 'Camera', camera, undefined, undefined, undefined, '');
    assert.equal(content.title, undefined);
    assert.equal(content.image, camera);
    assert.equal(content.badgeValue, '', 'an empty badge is a dot');
  });
  it('draws nothing on a divider', () => {
    assert.deepEqual(logic.cylSearchBarItemButtonContent(1, 'x', camera, selected, gif, 'asset:a.json', '1'), {
      title: undefined, image: undefined, selectedImage: undefined, animationURL: undefined, badgeValue: undefined
    });
  });
  it('lets an animated image replace the icon and the selected icon', () => {
    const content = logic.cylSearchBarItemButtonContent(0, 'Loading', camera, selected, gif, undefined, undefined);
    assert.equal(content.image, gif);
    assert.equal(content.selectedImage, undefined);
  });
});

describe('cylSearchBarItemInsets', () => {
  it('uses the item insets, else 8 for the divider, 4 for a text item and 0 for the others', () => {
    assert.equal(logic.cylSearchBarItemInsets(0, 6), 6);
    assert.equal(logic.cylSearchBarItemInsets(2, -1), 4);
    assert.equal(logic.cylSearchBarItemInsets(0, -1), 0);
    assert.equal(logic.cylSearchBarItemInsets(1, -1), 8);
  });
});

describe('cylSearchTouchRegion', () => {
  it('grows a 36 vp item to a 44 vp touch target around its center', () => {
    assert.deepEqual(logic.cylSearchTouchRegion(36, 36, 44), { x: -4, y: -4, width: 44, height: 44 });
  });
  it('keeps a larger item as it is', () => {
    assert.deepEqual(logic.cylSearchTouchRegion(80, 36, 44), { x: 0, y: -4, width: 80, height: 44 });
  });
});

describe('QMUI search port: bar rules', () => {
  const zero = { top: 0, left: 0, bottom: 0, right: 0 };
  it('centers the placeholder only at rest, empty, with a placeholder', () => {
    assert.equal(logic.cylSearchPlaceholderCentered(true, false, '', true), true);
    assert.equal(logic.cylSearchPlaceholderCentered(true, true, '', true), false);
    assert.equal(logic.cylSearchPlaceholderCentered(true, false, 'a', true), false);
    assert.equal(logic.cylSearchPlaceholderCentered(true, false, '', false), false);
    assert.equal(logic.cylSearchPlaceholderCentered(false, false, '', true), false);
  });
  it('lets the provider win over the fixed margins', () => {
    const fixed = { top: 0, left: 8, bottom: 0, right: 8 };
    const provided = { top: 0, left: 32, bottom: 0, right: 32 };
    assert.deepEqual(logic.cylSearchResolvedInsets(provided, fixed), provided);
    assert.deepEqual(logic.cylSearchResolvedInsets(undefined, fixed), fixed);
    assert.deepEqual(logic.cylSearchResolvedInsets(undefined, zero), zero);
  });
  it('draws Cancel when asked for, or automatically while active', () => {
    assert.equal(logic.cylSearchCancelVisible(true, false, false), true);
    assert.equal(logic.cylSearchCancelVisible(false, true, true), true);
    assert.equal(logic.cylSearchCancelVisible(false, true, false), false);
    assert.equal(logic.cylSearchCancelVisible(false, false, true), false);
  });
});

describe('QMUI search port: search view rules', () => {
  it('shows the empty view only for a non-empty query', () => {
    assert.equal(logic.cylSearchEmptyViewShown(true, 'zzz'), true);
    assert.equal(logic.cylSearchEmptyViewShown(true, '  '), false);
    assert.equal(logic.cylSearchEmptyViewShown(false, 'zzz'), false);
  });
  it('shows the launch view while the query is empty', () => {
    assert.equal(logic.cylSearchLaunchViewShown(true, ''), true);
    assert.equal(logic.cylSearchLaunchViewShown(true, 'a'), false);
    assert.equal(logic.cylSearchLaunchViewShown(false, ''), false);
  });
  it('ignores the dimming when a launch view is set or the query is not empty', () => {
    assert.equal(logic.cylSearchDimmingShown(true, false, ''), true);
    assert.equal(logic.cylSearchDimmingShown(true, true, ''), false);
    assert.equal(logic.cylSearchDimmingShown(true, false, 'a'), false);
    assert.equal(logic.cylSearchDimmingShown(false, false, ''), false);
  });
});

describe('QMUI search port: header snapping (issue 1160)', () => {
  it('adds only what the rows leave of the viewport', () => {
    assert.equal(logic.cylSearchHeaderFillerHeight(700, 300), 400);
    assert.equal(logic.cylSearchHeaderFillerHeight(700, 900), 0);
    assert.equal(logic.cylSearchHeaderFillerHeight(700, 700), 0);
  });
  it('settles a half-hidden header fully shown or fully hidden', () => {
    assert.equal(logic.cylSearchHeaderSettleOffset(10, 48), 0);
    assert.equal(logic.cylSearchHeaderSettleOffset(24, 48), 48);
    assert.equal(logic.cylSearchHeaderSettleOffset(40, 48), 48);
  });
  it('leaves a header alone outside the header band', () => {
    assert.equal(logic.cylSearchHeaderSettleOffset(0, 48), undefined);
    assert.equal(logic.cylSearchHeaderSettleOffset(48, 48), undefined);
    assert.equal(logic.cylSearchHeaderSettleOffset(120, 48), undefined);
    assert.equal(logic.cylSearchHeaderSettleOffset(10, 0), undefined);
  });
});

// The example's Discover page keeps its paging rule in the same kind of part (entry/src/main/ets/demos/Discover.ets) and
// the rawfile data it reads is checked here too: the rule of docs/animated-icon-component.md, "Discover data contract".
const discoverSource = readFileSync(join(here, '..', 'entry', 'src', 'main', 'ets', 'demos', 'Discover.ets'), 'utf8');
const discoverBegin = discoverSource.indexOf('// MARK: - Pure logic (begin)');
const discoverEnd = discoverSource.indexOf('// MARK: - Pure logic (end)');
assert.ok(discoverBegin >= 0 && discoverEnd > discoverBegin, 'Discover.ets has no pure logic part');
const discoverFolder = mkdtempSync(join(tmpdir(), 'cyl-discover-'));
const discoverTarget = join(discoverFolder, 'CYLDiscoverLogic.ts');
writeFileSync(discoverTarget, discoverSource.slice(discoverBegin, discoverEnd).replace(/^function /gm, 'export function '));
const discoverLogic = await import(pathToFileURL(discoverTarget).href);
after(() => rmSync(discoverFolder, { recursive: true, force: true }));

describe('Discover: refresh shows the next page, cyclically', () => {
  const rawfiles = ['base', 'ja_JP', 'zh_CN', 'zh_TW'];
  const data = (name) => JSON.parse(readFileSync(join(here, '..', 'entry', 'src', 'main', 'resources', 'rawfile', 'discover', `${name}.json`), 'utf8'));
  it('wraps around and counts a negative page from the end', () => {
    const pool = Array.from({ length: 24 }, (_, i) => ({ title: `T${i}` }));
    assert.deepEqual(discoverLogic.cylDiscoverPage(pool, 6, 0).topics.map((t) => t.title), ['T0', 'T1', 'T2', 'T3', 'T4', 'T5']);
    assert.deepEqual([1, 2, 3, 4, 5].map((page) => discoverLogic.cylDiscoverPage(pool, 6, page).page), [1, 2, 3, 0, 1]);
    assert.equal(discoverLogic.cylDiscoverPage(pool, 6, -1).page, 3);
    assert.equal(discoverLogic.cylDiscoverPage(pool.slice(0, 8), 6, 3).page, 0);
  });
  it('every language has 4 pages of 6, one hot record per page and a hot slot that differs from the next page', () => {
    for (const name of rawfiles) {
      const { discover, discoverCount } = data(name);
      assert.equal(discoverCount, 6, name);
      assert.equal(discover.length, 24, name);
      let page = 0;
      let previous = -1;
      let first = -1;
      for (let refresh = 0; refresh <= 8; refresh++) {
        const shown = discoverLogic.cylDiscoverPage(discover, discoverCount, page);
        const hot = shown.topics.map((t, slot) => (t.icon === 'hot' ? slot : -1)).filter((slot) => slot >= 0);
        assert.equal(hot.length, 1, `${name} page ${shown.page}`);
        assert.notEqual(hot[0], previous, `${name} page ${shown.page}`);
        if (refresh === 0) first = hot[0];
        if (refresh === 4) assert.equal(hot[0], first, `${name} wraps to the first page`);
        previous = hot[0];
        page = discoverLogic.cylDiscoverPage(discover, discoverCount, shown.page + 1).page;
      }
    }
  });
});

// The adaptive width is the core's job: the title builder of CYLSearchNavigationPage lays the search bar out with
// layoutWeight(1) between the back button and the end, and an example page passes no width, margin or padding to fit
// the back button (docs/animated-icon-component.md, "The adaptive width is the core's job"). ArkUI layout cannot run on
// the host, so this checks the rule in the source of the builder and of the example.
describe('navigation title builder: the core adapts the bar width', () => {
  const barSource = readFileSync(join(core, 'CYLSearchBarView.ets'), 'utf8');
  const titleBar = barSource.slice(barSource.indexOf('titleBar() {'), barSource.indexOf('build() {', barSource.indexOf('titleBar() {')));
  it('gives the bar the width left beside the back button with layoutWeight(1)', () => {
    assert.match(titleBar, /CYLSearchBarComponent\(\{ searchBarView: this\.searchBarView \}\)\.layoutWeight\(1\)/);
    assert.ok(titleBar.indexOf('if (this.showsBack)') < titleBar.indexOf('CYLSearchBarComponent'), 'the back button comes first');
  });
  it('lets the example page pass no width, margin or padding to the bar', () => {
    const start = discoverSource.indexOf('CYLSearchNavigationPage({');
    const page = discoverSource.slice(start, discoverSource.indexOf('discoverContent() {', start));
    assert.doesNotMatch(page, /\.(width|margin|padding)\(/);
    assert.doesNotMatch(discoverSource, /CYLSearchBarComponent/);
    assert.doesNotMatch(discoverSource, /\bfieldHeight\b/);
  });
});

// The refresh button's accessibility label (CYLSearchRefreshButton): the localized `tagList.refresh` as accessibilityText
// in the core, the string in the base language and the four iOS languages with the iOS text, and in every other language
// the library localizes (the CYLTabBarController translations). The ohosTest case discoverRefreshButtonHasItsLabel
// checks the label on the emulator (written, not run).
describe('refresh button label', () => {
  const resources = join(here, '..', 'cylsearch', 'src', 'main', 'resources');
  const value = (qualifier) => {
    const file = join(resources, qualifier, 'element', 'string.json');
    const item = JSON.parse(readFileSync(file, 'utf8')).string.find((entry) => entry.name === 'cyl_tagList_refresh');
    return item && item.value;
  };
  const barSource = readFileSync(join(core, 'CYLSearchBarView.ets'), 'utf8');
  it('reads cyl_tagList_refresh as the accessibility text of the symbol button', () => {
    const start = barSource.indexOf('export struct CYLSearchRefreshButton');
    const button = barSource.slice(start, barSource.indexOf('@ComponentV2', start));
    assert.match(button, /\.accessibilityText\(\$r\('app\.string\.cyl_tagList_refresh'\)\)/);
  });
  it('has the iOS text in base, ja_JP, zh_CN and zh_TW', () => {
    assert.deepEqual(['base', 'ja_JP', 'zh_CN', 'zh_TW'].map(value), ['Refresh', '更新', '刷新', '重新整理']);
  });
  it('has a label in every language the library localizes', () => {
    const qualifiers = readdirSync(resources).filter((name) => existsSync(join(resources, name, 'element', 'string.json')) && name !== 'dark');
    assert.ok(qualifiers.length > 4);
    for (const qualifier of qualifiers) {
      assert.ok(value(qualifier), `${qualifier} has no cyl_tagList_refresh`);
    }
  });
});

// The hot icon's screen reader label (iOS bridges send it as tagImageLabels): ClassifyMenu's tag list hides the icon
// from the screen reader, so the example leads the hot topic's hint with the localized `discover_hot`. The ohosTest
// case is not written; the UI behaviour is written, not run (docs/animated-icon-component.md, "Test hand-over").
describe('Discover: the hot icon has a localized screen reader label', () => {
  const resources = join(here, '..', 'entry', 'src', 'main', 'resources');
  const value = (qualifier) => {
    const file = join(resources, qualifier, 'element', 'string.json');
    const item = JSON.parse(readFileSync(file, 'utf8')).string.find((entry) => entry.name === 'discover_hot');
    return item && item.value;
  };
  it('has Hot, 人気, 热门 and 熱門 in base, ja_JP, zh_CN and zh_TW', () => {
    assert.deepEqual(['base', 'ja_JP', 'zh_CN', 'zh_TW'].map(value), ['Hot', '人気', '热门', '熱門']);
  });
  it('leads the hint of a hot topic with the label and leaves other topics alone', () => {
    const hot = { title: 'T', icon: 'hot' };
    assert.equal(discoverLogic.cylDiscoverItemHint(hot, 'Hot', 'Tap to search'), 'Hot. Tap to search');
    assert.equal(discoverLogic.cylDiscoverItemHint(hot, '热门', ''), '热门');
    assert.equal(discoverLogic.cylDiscoverItemHint(hot, '', 'Tap'), 'Tap');
    assert.equal(discoverLogic.cylDiscoverItemHint({ title: 'T' }, 'Hot', 'Tap to search'), 'Tap to search');
  });
  it('passes discover_hot to the data source and the hint through cylDiscoverItemHint', () => {
    assert.match(discoverSource, /this\.topicSource\.hotLabel = this\.text\('discover_hot'\)/);
    assert.match(discoverSource, /cylDiscoverItemHint\(this\.topics\[indexPath\.item\], this\.hotLabel, this\.hint\)/);
  });
});

// Corner radius, the owner's final rule (item 8b of docs/animated-icon-component.md): 0 is square, the capsule is ONE
// named constant (1000) passed by name, no other value is special.
describe('corner radius capsule constant', () => {
  const entryEts = join(here, '..', 'entry', 'src', 'main', 'ets');
  const library = readFileSync(join(core, 'CYLSearchBarView.ets'), 'utf8');
  const walk = (directory, found = []) => {
    for (const entry of readdirSync(directory, { withFileTypes: true })) {
      const full = join(directory, entry.name);
      if (entry.isDirectory()) walk(full, found);
      else if (entry.name.endsWith('.ets')) found.push(full);
    }
    return found;
  };
  it('takes the capsule constant from the library (cylanimateditem, 1000), with no repo-local copy', () => {
    const vendored = join(here, '..', 'vendor', 'cylanimateditem');
    if (existsSync(vendored)) {
      assert.match(readFileSync(join(vendored, 'Index.ets'), 'utf8'), /\bCYLAnimatedItemCornerRadiusCapsule\b/);
      assert.match(readFileSync(join(vendored, 'src', 'main', 'ets', 'CYLAnimatedItemBackground.ets'), 'utf8'),
        /export const CYLAnimatedItemCornerRadiusCapsule: number = 1000;/);
    }
    assert.equal(existsSync(join(entryEts, 'common', 'CYLCornerRadius.ets')), false);
    assert.equal(walk(entryEts).filter((file) => /CYL_CORNER_RADIUS_CAPSULE/.test(readFileSync(file, 'utf8'))).length, 0);
  });
  it('gives no radius in the entry or library sources the literal 1000, 999 or 0.001', () => {
    const radius = /(?:[cC]ornerRadius|borderRadius|radius)\s*(?:=|:|\()\s*(?:1000|999|9999|0\.001)\b/;
    const offenders = [...walk(entryEts), ...walk(core)].filter((file) => radius.test(readFileSync(file, 'utf8')));
    assert.deepEqual(offenders, []);
  });
  it('passes the library constant by name where the Discover bar is a capsule', () => {
    assert.match(discoverSource, /bar\.fieldCornerRadius = CYLAnimatedItemCornerRadiusCapsule;/);
    assert.match(discoverSource, /import \{ CYLAnimatedItemCornerRadiusCapsule \} from 'cylanimateditem';/);
  });
  it('draws the search bar item square with 0, and CYLTagCornerRadiusSquare is gone', () => {
    assert.match(library, /appearance\.cornerRadius = hasBackground \? 10 : 0;/);
    const menu = readFileSync(join(entryEts, 'demos', 'ExamplesMenu.ets'), 'utf8');
    assert.match(menu, /appearance\.cornerRadius = 0;/);
    assert.doesNotMatch(library + menu, /CYLTagCornerRadiusSquare/);
  });
});

// Every example tag list is Liquid Glass with ONE parameter, `style.backgroundStyle = CYLTagBackgroundStyle.liquidGlass`
// (CollectionViewClassifyMenu 551072a); the glass is the background, so the glass tags have no fill and no border of
// their own. The Discover "recent" tags stay opaque white (plain Text, not a tag list). Source checks: the styles import
// kit code and run only on a device.
describe('Liquid Glass tag lists', () => {
  const demos = join(here, '..', 'entry', 'src', 'main', 'ets', 'demos');
  const contactSource = readFileSync(join(demos, 'contacttags', 'CYLContactTagsPages.ets'), 'utf8');
  const functionBody = (source, name) => {
    source = source.replace(/\r\n/g, '\n');
    const start = source.indexOf(`function ${name}(`);
    assert.ok(start >= 0, `${name} exists`);
    const end = source.indexOf('\n}\n', start);
    return source.slice(start, end);
  };
  const glass = /style\.backgroundStyle = CYLTagBackgroundStyle\.liquidGlass;/;
  it('sets the one parameter on the Discover topics grid and the contact tags, and imports the enum', () => {
    assert.match(functionBody(discoverSource, 'cylDiscoverStyle'), glass);
    assert.match(functionBody(contactSource, 'cylContactTagStyle'), glass);
    assert.match(discoverSource, /import \{[^}]*\bCYLTagBackgroundStyle\b[^}]*\} from '@cyl\/classifymenu';/);
    assert.match(contactSource, /import \{[^}]*\bCYLTagBackgroundStyle\b[^}]*\} from '@cyl\/classifymenu';/);
  });
  it('gives the glass tags no fill and no border of their own; the selected tint keeps visible after the glass', () => {
    const contact = functionBody(contactSource, 'cylContactTagStyle');
    assert.match(contact, /normalAppearance\.backgroundColor = CYLColor\.CLEAR;/);
    assert.match(contact, /appearance\.borderWidth = 0;/);
    assert.doesNotMatch(contact, /CYL_GRAY6|borderColor/);
    // The glass keeps 75% of the tint's alpha (CYLLiquidGlass.GLASS_TINT_ALPHA): the selected tint is 20%, 15% on the glass.
    const selected = /selectedAppearance\.backgroundColor = '#([0-9A-F]{2})07C160';/.exec(contact);
    assert.ok(selected, 'the selected tint is an #AARRGGBB green');
    const alpha = parseInt(selected[1], 16) / 255 * 0.75;
    assert.ok(alpha >= 0.1 && alpha <= 0.3, `selected tint alpha on the glass is ${alpha}`);
    const discover = functionBody(discoverSource, 'cylDiscoverStyle');
    assert.doesNotMatch(discover, /backgroundColor|borderColor|borderWidth/);
  });
  it('keeps the Discover recent tags opaque white and flat (no glass in recentTag)', () => {
    const text = discoverSource.replace(/\r\n/g, '\n');
    const start = text.indexOf('recentTag(title: string) {');
    const recent = text.slice(start, text.indexOf('\n  }\n', start));
    assert.match(recent, /\.backgroundColor\(\$r\('sys\.color\.background_primary'\)\)/);
    assert.doesNotMatch(recent, /liquidGlass|backgroundEffect/);
    assert.equal((discoverSource.match(/liquidGlass/g) || []).length, 1);
  });
});

describe('cylSearchItemShape and cylSearchItemShapesMatch (setItems)', () => {
  const first = { style: 'icon', title: 'A', animationLoops: true, animationSpeed: 2 };
  it('ignores the playback keys and the key order', () => {
    const same = { animationSpeed: 1, title: 'A', style: 'icon' };
    assert.equal(logic.cylSearchItemShape(first), logic.cylSearchItemShape(same));
  });
  it('tells another value apart', () => {
    assert.notEqual(logic.cylSearchItemShape(first), logic.cylSearchItemShape({ style: 'icon', title: 'B' }));
  });
  it('keeps the items only when the shapes and the item count are the same', () => {
    const shapes = [logic.cylSearchItemShape(first)];
    assert.ok(logic.cylSearchItemShapesMatch(shapes, [...shapes], 1));
    assert.ok(!logic.cylSearchItemShapesMatch(undefined, shapes, 1));
    assert.ok(!logic.cylSearchItemShapesMatch(shapes, shapes, 2), 'an item was added in another way');
    assert.ok(!logic.cylSearchItemShapesMatch(shapes, [shapes[0], shapes[0]], 2));
  });
});

describe('cylSearchCancelEnabled', () => {
  it('is always on with alwaysEnablesCancelButton, else only while editing', () => {
    assert.ok(logic.cylSearchCancelEnabled(true, false));
    assert.ok(!logic.cylSearchCancelEnabled(false, false));
    assert.ok(logic.cylSearchCancelEnabled(false, true));
  });
});

describe('cylSearchResultsHeaderTitle', () => {
  const provider = (query) => (query === 'none' ? undefined : 'Results for ' + query);
  it('asks the provider only while results show', () => {
    assert.equal(logic.cylSearchResultsHeaderTitle(true, provider, 'swift'), 'Results for swift');
    assert.equal(logic.cylSearchResultsHeaderTitle(false, provider, 'swift'), undefined);
  });
  it('shows no header without a provider or when it answers nothing', () => {
    assert.equal(logic.cylSearchResultsHeaderTitle(true, undefined, 'swift'), undefined);
    assert.equal(logic.cylSearchResultsHeaderTitle(true, provider, 'none'), undefined);
  });
});

describe('search controller state', () => {
  it('lets a swipe begin only inside the search view', () => {
    assert.ok(logic.cylSearchSwipeShouldBegin(false, false));
    assert.ok(logic.cylSearchSwipeShouldBegin(true, true));
    assert.ok(!logic.cylSearchSwipeShouldBegin(true, false));
  });
  it('pushes the navigation bar away only while searching', () => {
    assert.ok(logic.cylSearchNavigationBarHidden(true, true));
    assert.ok(!logic.cylSearchNavigationBarHidden(true, false));
    assert.ok(!logic.cylSearchNavigationBarHidden(false, true));
  });
  it('asks the status bar providers only while searching', () => {
    assert.ok(logic.cylSearchStatusBarHidden(true, () => true));
    assert.ok(!logic.cylSearchStatusBarHidden(false, () => true));
    assert.ok(!logic.cylSearchStatusBarHidden(true, undefined));
    assert.equal(logic.cylSearchStatusBarStyle(true, () => 1, 0), 1);
    assert.equal(logic.cylSearchStatusBarStyle(false, () => 1, 0), 0);
    assert.equal(logic.cylSearchStatusBarStyle(true, undefined, 0), 0);
  });
  it('forwards the appearance only when asked for and searching', () => {
    assert.ok(logic.cylSearchAppearanceForwarded(true, true));
    assert.ok(!logic.cylSearchAppearanceForwarded(true, false));
    assert.ok(!logic.cylSearchAppearanceForwarded(false, true));
  });
  it('reports the search bar edge only while searching', () => {
    assert.equal(logic.cylSearchBarMaxY(true, 96), 96);
    assert.equal(logic.cylSearchBarMaxY(false, 96), 0);
    assert.equal(logic.cylSearchBarMaxY(true, -4), 0);
  });
});

describe('search navigation bar', () => {
  it('holds the field with 4 above and below and no side inset, and never pops by itself', () => {
    assert.deepEqual(logic.cylSearchNavigationContentInsets(), [4, 0, 4, 0]);
    assert.equal(logic.cylSearchNavigationShouldPop(), false);
  });
});

describe('CYLSearchTagListStyle', () => {
  it('names the glass background case-insensitively and everything else is flat', () => {
    assert.ok(logic.cylSearchTagIsLiquidGlass('liquidGlass'));
    assert.ok(logic.cylSearchTagIsLiquidGlass('LIQUIDGLASS'));
    assert.ok(!logic.cylSearchTagIsLiquidGlass('flat'));
    assert.ok(!logic.cylSearchTagIsLiquidGlass(''));
  });
  it('leaves the list alone for 0 or fewer columns', () => {
    assert.ok(!logic.cylSearchTagGridApplies(0));
    assert.ok(!logic.cylSearchTagGridApplies(-1));
    assert.ok(logic.cylSearchTagGridApplies(2));
  });
  it('has the metrics of the iOS example recent searches', () => {
    const metrics = logic.cylSearchTagDefaultMetrics();
    assert.equal(metrics.margin, 14);
    assert.equal(metrics.fontSize, 17);
    assert.equal(metrics.itemHeight, 36);
    assert.equal(metrics.interitemSpacing, 12);
    assert.equal(metrics.lineSpacing, 12);
    assert.deepEqual(metrics.sectionInsets, [4, 16, 24, 16]);
    assert.equal(metrics.headerHeight, 44);
    assert.equal(metrics.headerFontSize, 20);
    assert.equal(metrics.headerHorizontalInset, 16);
  });
  it('has the metrics of the discover topics grid', () => {
    const metrics = logic.cylSearchTagGridMetrics();
    assert.equal(metrics.itemHeight, 36);
    assert.equal(metrics.lineSpacing, 16);
    assert.deepEqual(metrics.sectionInsets, [4, 16, 16, 16]);
    assert.equal(metrics.headerHeight, 44);
  });
});

describe('the Placeholder styles page chunks', () => {
  it('splits 42 sections into chunks of 6 and clamps past the end', () => {
    assert.deepEqual(logic.cylGalleryChunkRange(0, 6, 42), [0, 6]);
    assert.deepEqual(logic.cylGalleryChunkRange(6, 6, 42), [36, 6]);
    assert.deepEqual(logic.cylGalleryChunkRange(7, 6, 42), [42, 0]);
    assert.deepEqual(logic.cylGalleryChunkRange(3, 6, 20), [18, 2]);
  });
  it('shows one more chunk when the scroll reaches the end, never more than exist', () => {
    assert.equal(logic.cylGalleryChunksAfterReachEnd(1, 6, 42), 2);
    assert.equal(logic.cylGalleryChunksAfterReachEnd(7, 6, 42), 7);
    assert.equal(logic.cylGalleryChunksAfterReachEnd(1, 6, 4), 1);
  });
});
