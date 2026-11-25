import { describe, it, expect, beforeAll } from '@ohos/hypium';
import { abilityDelegatorRegistry, Component, Driver, ON } from '@kit.TestKit';
import { common, Want } from '@kit.AbilityKit';
import { CYLSearchResources } from 'cylsearch';

const BUNDLE = 'com.cyl.search.harmonyos';

function context(): common.Context {
  return abilityDelegatorRegistry.getAbilityDelegator().getAppContext();
}

// A string of the library in the system language (`demo.title`), so the tests pass in any language.
function libString(key: string): string {
  return CYLSearchResources.localizedString(context(), key);
}

// A string of the app (`tab_examples`).
function appString(name: string): string {
  return context().resourceManager.getStringByNameSync(name);
}

// The icon-only open-search button of the MaterialSearchView samples (CYLDemoNavBar's rightId).
const OPEN_SEARCH = 'CYLMaterialOpenSearch';

/*
 * Controls are found the way a screen reader finds them (AGENTS.md, "HarmonyOS: screen readers and localization"):
 * by their accessibility label or their visible text, in the language the device shows. An id is used only for
 * what has no label of its own. A test that cannot find a control by its label shows a screen-reader gap: add the
 * label in the app first.
 *
 * Icon-only controls: uitest on HarmonyOS 6.0.1 (API 21) reports a node's visible text (its own or its children's)
 * and its accessibilityDescription, but not its accessibilityText (checked with `uitest dumpLayout` on the emulator,
 * 2026-11-17: the open-search and mic buttons have empty text although their accessibilityText is set and grouped).
 * Such a control is passed with its id as well; the label is still tried first.
 */
async function findByLabel(driver: Driver, label: string, iconId?: string): Promise<Component> {
  const byText = await driver.findComponent(ON.text(label));
  if (byText) {
    return byText;
  }
  const byDescription = await driver.findComponent(ON.description(label));
  if (byDescription) {
    return byDescription;
  }
  if (iconId !== undefined) {
    const byId = await driver.findComponent(ON.id(iconId));
    if (byId) {
      return byId;
    }
  }
  throw new Error(`No control labelled "${label}"`);
}

async function tapLabel(driver: Driver, label: string, wait: number = 800, iconId?: string): Promise<void> {
  await (await findByLabel(driver, label, iconId)).click();
  await driver.delayMs(wait);
}

// An Examples row is a tag of the example's tag list (ids `CYLTagListItem-0-<row>`, a 3-row fold `CYLTagListFold-0`): the
// list draws no text a test can find, so the row is found by its id, expanding the fold when the tag is folded away.
async function tapExamplesTag(driver: Driver, label: string, row: number, wait: number = 1000): Promise<void> {
  const id = `CYLTagListItem-0-${row}`;
  let tag = await driver.findComponent(ON.id(id));
  if (!tag) {
    const fold = await driver.findComponent(ON.id('CYLTagListFold-0'));
    if (fold) {
      await fold.click();
      await driver.delayMs(500);
    }
    tag = await driver.findComponent(ON.id(id));
  }
  if (!tag) {
    throw new Error(`No Examples tag for "${label}"`);
  }
  await tag.click();
  await driver.delayMs(wait);
}

async function assertLabel(driver: Driver, label: string, iconId?: string): Promise<void> {
  expect(await findByLabel(driver, label, iconId) !== undefined).assertTrue();
}

// Back until the tab bar shows again (found by the Search tab's label): a test that ends on a pushed page must not
// break the next one.
async function backToTabBar(driver: Driver): Promise<void> {
  // The Examples tab's label, in this app's window: the keyboard's search key also reads "Search".
  const tab = appString('tab_examples');
  for (let i = 0; i < 4 && !(await driver.findComponent(ON.text(tab).inWindow(BUNDLE))); i++) {
    await driver.pressBack();
    await driver.delayMs(800);
  }
}

/**
 * The example as on iOS (CYLSearchExampleUITests): the tab bar, the Examples menu, a MaterialSearchView sample whose
 * search page Back closes, and the Discover tab; every control found by its label.
 */
export default function cylSearchUITest() {
  describe('CYLSearchUI', () => {
    beforeAll(async () => {
      // The suite hung forever when the emulator's display was off or locked: `startAbility` never returned and no test
      // started (2026-11-22, reproduced with `power-shell suspend`). Wake the display and swipe the lock screen away first.
      const driver = Driver.create();
      await driver.wakeUpDisplay();
      await driver.delayMs(1000);
      const size = await driver.getDisplaySize();
      await driver.swipe(Math.round(size.x / 2), Math.round(size.y * 0.9), Math.round(size.x / 2),
        Math.round(size.y * 0.3), 600);
      await driver.delayMs(1000);
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
      await driver.delayMs(2000);
    });

    it('searchTabShowsResultsAndReproductionToggle', 0, async () => {
      const driver = Driver.create();
      await assertLabel(driver, libString('search.title'));
      await assertLabel(driver, libString('repro.off'));
      await assertLabel(driver, libString('sample.result').replace('%d', '1'));
    });

    it('examplesMenuOpensPlaceholderStyles', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_examples'));
      await assertLabel(driver, libString('demo.title'));
      await tapExamplesTag(driver, libString('demo.styles'), 1);
      // The section headers are CYLTableViewPlaceHolder's image names (its CYLPlaceholderView styles).
      await assertLabel(driver, 'CYLPlaceholderEmpty');
      await driver.pressBack();
      await driver.delayMs(800);
    });

    // The overlay is a CYLSearchView with a results data source: typing shows the matching results below the bar,
    // a query with no result shows CYLTableViewPlaceHolder's placeholder, and Back closes it.
    it('overlayShowsResultsOfTheDataSource', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_search'));
      await tapLabel(driver, libString('action.overlay'), 1000);
      const fields = await driver.findComponents(ON.type('TextInput'));
      expect(fields.length > 0).assertTrue();
      const field = fields[fields.length - 1];
      await field.inputText(libString('sample.result').replace('%d', '12'));
      await driver.delayMs(800);
      await assertLabel(driver, libString('sample.result').replace('%d', '12'));
      await field.clearText();
      await field.inputText('zzzz');
      await driver.delayMs(800);
      // Only in this app's window: the keyboard's clipboard bar shows the text typed before (uitest types through the
      // clipboard), and it is not a result.
      // findComponents gives null, not an empty list, when nothing matches.
      const left = await driver.findComponents(ON.text(libString('sample.result').replace('%d', '12')).inWindow(BUNDLE));
      expect(left === null || left.length === 0).assertTrue();
      // Back hides the keyboard first, then closes the overlay.
      for (let i = 0; i < 3 && !(await driver.findComponent(ON.text(libString('repro.off')).inWindow(BUNDLE))); i++) {
        await driver.pressBack();
        await driver.delayMs(800);
      }
      await assertLabel(driver, libString('repro.off'));
    });

    // The core's pull to refresh on the reproduction's list (CYLSearchView.setRefreshHandler): a pull down refreshes
    // and the list is still there afterwards.
    it('reproductionListPullsToRefresh', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_search'));
      const first = await findByLabel(driver, libString('sample.result').replace('%d', '1'));
      const rect = await first.getBounds();
      const x = Math.round((rect.left + rect.right) / 2);
      await driver.swipe(x, rect.top + 10, x, rect.top + 600, 600);
      await driver.delayMs(1500);
      await assertLabel(driver, libString('sample.result').replace('%d', '1'));
    });

    // A search bar in multiple mode (the MultiSearchView port): the new-search button starts a search, the typed
    // search becomes one of the searches when submitted.
    it('multipleModeSearchBarAddsSearches', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_examples'));
      await tapExamplesTag(driver, libString('demo.ports'), 3);
      await tapLabel(driver, 'iammert/MultiSearchView', 1000);
      await tapLabel(driver, libString('multisearch.add'), 800, 'CYLSearchBarNewSearch');
      const field = await driver.findComponent(ON.type('TextInput'));
      await field.inputText('Swift');
      await driver.delayMs(500);
      await driver.triggerKey(2054);
      await driver.delayMs(800);
      await assertLabel(driver, 'Swift');
      await driver.pressBack();
      await driver.delayMs(800);
      await driver.pressBack();
      await driver.delayMs(800);
    });

    it('tagStyleSampleSearchClosesOnBack', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_tagStyle'));
      await tapLabel(driver, libString('demo.port.default'), 1000);
      await tapLabel(driver, libString('demo.port.open'), 1000, OPEN_SEARCH);
      expect((await driver.findComponents(ON.type('TextInput'))).length > 0).assertTrue();
      await driver.pressBack();
      await driver.delayMs(1000);
      await assertLabel(driver, libString('demo.port.open'), OPEN_SEARCH);
      await driver.pressBack();
      await driver.delayMs(800);
    });

    // A longer flow by labels only: open a sample, open its search page, type, clear with the labelled button,
    // type again and submit (which closes the search page), then leave the sample with Back.
    it('searchFlowByLabels', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_tagStyle'));
      await tapLabel(driver, libString('demo.port.default'), 1000);
      await tapLabel(driver, libString('demo.port.open'), 1000, OPEN_SEARCH);
      const field = await driver.findComponent(ON.type('TextInput'));
      await field.inputText('Swift');
      await driver.delayMs(500);
      expect(await field.getText()).assertEqual('Swift');
      await field.clearText();
      await field.inputText('Kotlin');
      await driver.delayMs(500);
      await driver.triggerKey(2054);
      await driver.delayMs(800);
      // Submitting closes the search page, as MaterialSearchView does: the sample's open-search button is back.
      await assertLabel(driver, libString('demo.port.open'), OPEN_SEARCH);
      await driver.pressBack();
      await driver.delayMs(800);
    });

    // The Search controller screen sets only core options (suggestions, showsSuggestionsLaunchView,
    // highlightsResultMatches, noResultsText): the launch area is the tag list, a tapped tag submits, and the core shows
    // the empty view.
    it('searchControllerScreenUsesTheCoreOptions', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_examples'));
      await tapExamplesTag(driver, libString('demo.searchController'), 5);
      const fields = await driver.findComponents(ON.type('TextInput'));
      expect(fields.length > 0).assertTrue();
      await fields[0].click();
      await driver.delayMs(1000);
      // The tags of the suggestion area (CollectionViewClassifyMenu's tag list), the first one a tag of the history.
      const tag = await driver.findComponent(ON.id('CYLTagListItem-0-0'));
      expect(tag !== undefined && tag !== null).assertTrue();
      await tag.click();
      await driver.delayMs(1000);
      const searchField = (await driver.findComponents(ON.type('TextInput'))).pop() as Component;
      expect((await searchField.getText()).length > 0).assertTrue();
      await searchField.clearText();
      await searchField.inputText('Hzzz');
      await driver.delayMs(800);
      await assertLabel(driver, libString('controller.noResults'));
      for (let i = 0; i < 4 && !(await driver.findComponent(ON.text(appString('tab_examples')).inWindow(BUNDLE))); i++) {
        await driver.pressBack();
        await driver.delayMs(800);
      }
      await backToTabBar(driver);
    });

    it('discoverTabShowsRecentSearches', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_discover'));
      await assertLabel(driver, appString('discover_recent'));
      await assertLabel(driver, appString('discover_ask'), 'CYLSearchDiscoverMicButton');
    });

    // The refresh button of the Discover topics header is labelled with the localized tagList.refresh (Refresh, 更新,
    // 刷新, 重新整理 in the four iOS languages, the CYLTabBarController translations in the others). Written, not run.
    it('discoverRefreshButtonHasItsLabel', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_discover'));
      const label = libString('tagList.refresh');
      expect(label.length > 0 && label !== 'tagList.refresh').assertTrue();
      // uitest does not report accessibilityText (see findByLabel), so the id is the fallback.
      await assertLabel(driver, label, 'CYLSearchDiscoverMore');
      await tapLabel(driver, label, 800, 'CYLSearchDiscoverMore');
      await assertLabel(driver, label, 'CYLSearchDiscoverMore');
    });
  });
}
