import { describe, it, expect, beforeAll } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
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

/**
 * The example as on iOS (CYLSearchExampleUITests): the tab bar, the Examples menu, a MaterialSearchView sample whose
 * search page Back closes, and the Discover tab.
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
      await driver.assertComponentExist(ON.text(libString('search.title')));
      await driver.assertComponentExist(ON.id('CYLIssueReproductionToggle'));
      await driver.assertComponentExist(ON.text(libString('sample.result').replace('%d', '1')));
    });

    it('examplesMenuOpensPlaceholderStyles', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('cyl-tab-examples'))).click();
      await driver.delayMs(800);
      await driver.assertComponentExist(ON.text(libString('demo.title')));
      await (await driver.findComponent(ON.id('CYLDemoRow1'))).click();
      await driver.delayMs(1000);
      await driver.assertComponentExist(ON.text('CYLSearchEmpty'));
      await driver.pressBack();
      await driver.delayMs(800);
    });

    it('tagStyleSampleSearchClosesOnBack', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('cyl-tab-tagStyle'))).click();
      await driver.delayMs(800);
      await (await driver.findComponent(ON.id('CYLMaterialSample0'))).click();
      await driver.delayMs(1000);
      await (await driver.findComponent(ON.id('CYLMaterialOpenSearch'))).click();
      await driver.delayMs(1000);
      expect((await driver.findComponents(ON.type('TextInput'))).length > 0).assertTrue();
      await driver.pressBack();
      await driver.delayMs(1000);
      await driver.assertComponentExist(ON.id('CYLMaterialOpenSearch'));
    });

    it('discoverTabShowsRecentSearches', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('cyl-tab-discover'))).click();
      await driver.delayMs(800);
      await driver.assertComponentExist(ON.text(appString('discover_recent')));
      await driver.assertComponentExist(ON.id('CYLSearchDiscoverMicButton'));
    });
  });
}
