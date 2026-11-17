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

async function assertLabel(driver: Driver, label: string, iconId?: string): Promise<void> {
  expect(await findByLabel(driver, label, iconId) !== undefined).assertTrue();
}

// Back until the tab bar shows again (found by the Search tab's label): a test that ends on a pushed page must not
// break the next one.
async function backToTabBar(driver: Driver): Promise<void> {
  const tab = appString('tab_search');
  for (let i = 0; i < 4 && !(await driver.findComponent(ON.text(tab))); i++) {
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
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
      await Driver.create().delayMs(2000);
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
      await tapLabel(driver, libString('demo.styles'), 1000);
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
      expect((await driver.findComponents(ON.text(libString('sample.result').replace('%d', '12')))).length)
        .assertEqual(0);
      await driver.pressBack();
      await driver.delayMs(1000);
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
      await tapLabel(driver, libString('demo.ports'), 1000);
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

    it('discoverTabShowsRecentSearches', 0, async () => {
      const driver = Driver.create();
      await backToTabBar(driver);
      await tapLabel(driver, appString('tab_discover'));
      await assertLabel(driver, appString('discover_recent'));
      await assertLabel(driver, appString('discover_ask'), 'CYLSearchDiscoverMicButton');
    });
  });
}
