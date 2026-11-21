// Runs the pure logic of the HarmonyOS search core on the host, without an emulator or a device.
// Usage (Node 22.18 or newer, which strips TypeScript types itself):
//   node harmonyos/scripts/host-logic-test.mjs
// The logic is private to the three core files (CYLSearchBarView.ets, CYLSearchView.ets, CYLSearchResources.ets),
// each between the lines "// MARK: - Pure logic (begin)" and "// MARK: - Pure logic (end)" (plain TypeScript, no kit
// import). This script copies those parts to a temporary .ts file, exports their functions, imports it and runs
// node:test cases that mirror the Android Kotlin tests of the same behaviour.
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { after, describe, it } from 'node:test';
import assert from 'node:assert/strict';

const here = dirname(fileURLToPath(import.meta.url));
const core = join(here, '..', 'cylsearch', 'src', 'main', 'ets');
const parts = ['CYLSearchBarView.ets', 'CYLSearchView.ets', 'CYLSearchResources.ets'].map((name) => {
  const text = readFileSync(join(core, name), 'utf8');
  const begin = text.indexOf('// MARK: - Pure logic (begin)');
  const end = text.indexOf('// MARK: - Pure logic (end)');
  assert.ok(begin >= 0 && end > begin, `${name} has no pure logic part`);
  return text.slice(begin, end).replace(/^function /gm, 'export function ');
});
const folder = mkdtempSync(join(tmpdir(), 'cyl-logic-'));
const target = join(folder, 'CYLSearchLogic.ts');
writeFileSync(target, parts.join('\n'));
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

describe('cylFoldedTagCount', () => {
  const widths = [45, 45, 45, 45, 45];
  it('shows every tag when they fit', () => {
    assert.equal(logic.cylFoldedTagCount(widths, 100, 3, 10, 40), 5);
  });
  it('leaves room for an inline control after the last visible tag', () => {
    assert.equal(logic.cylFoldedTagCount(widths, 100, 2, 10, 40), 3);
  });
  it('keeps the folded rows full when the control is on its own row', () => {
    assert.equal(logic.cylFoldedTagCount(widths, 100, 2, 10, 0), 4);
  });
  it('shows every tag with no rows or no width yet', () => {
    assert.equal(logic.cylFoldedTagCount(widths, 100, 0, 10, 40), 5);
    assert.equal(logic.cylFoldedTagCount(widths, 0, 2, 10, 40), 5);
  });
  it('clamps a tag wider than the row', () => {
    assert.equal(logic.cylFoldedTagCount([300, 45], 100, 1, 10, 40), 0);
    assert.equal(logic.cylFoldedTagCount([300], 100, 1, 10, 40), 1);
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
  it('uses the item insets, else 4 for a text item and 0 for the others', () => {
    assert.equal(logic.cylSearchBarItemInsets(0, 6), 6);
    assert.equal(logic.cylSearchBarItemInsets(2, -1), 4);
    assert.equal(logic.cylSearchBarItemInsets(0, -1), 0);
    assert.equal(logic.cylSearchBarItemInsets(1, -1), 0);
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
