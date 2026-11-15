import { describe, it, expect, beforeAll } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver, ON } from '@kit.TestKit';
import { common, Want } from '@kit.AbilityKit';
import { CYLSearchResources } from 'cylsearch';

const BUNDLE = 'com.cyl.search.harmonyos';

function context(): common.Context {
  return abilityDelegatorRegistry.getAbilityDelegator().getAppContext();
}

// A string of the app in the system language, so the tests pass in any language.
function appString(name: string): string {
  return context().resourceManager.getStringByNameSync(name);
}

export default function cylSearchUITest() {
  describe('CYLSearchUI', () => {
    beforeAll(async () => {
      const want: Want = { bundleName: BUNDLE, abilityName: 'EntryAbility' };
      await abilityDelegatorRegistry.getAbilityDelegator().startAbility(want);
      await Driver.create().delayMs(2000);
    });

    it('discoverShowsTitleAndSearchBar', 0, async () => {
      const driver = Driver.create();
      await driver.assertComponentExist(ON.text(appString('discover_title')));
      await driver.assertComponentExist(ON.id('CYLSearchDiscoverOpenSearch'));
      expect((await driver.findComponents(ON.type('TextInput'))).length > 0).assertTrue();
    });

    it('openSearchShowsEmptyPlaceholder', 0, async () => {
      const driver = Driver.create();
      await (await driver.findComponent(ON.id('CYLSearchDiscoverOpenSearch'))).click();
      await driver.delayMs(1500);
      const empty = CYLSearchResources.localizedString(context(), 'placeholder.empty');
      await driver.assertComponentExist(ON.text(empty));
    });

    it('typingFiltersSuggestions', 0, async () => {
      const driver = Driver.create();
      const fields = await driver.findComponents(ON.type('TextInput'));
      const field = fields[fields.length - 1];
      await field.inputText('Kot');
      await driver.delayMs(1000);
      await driver.assertComponentExist(ON.text('Kotlin'));
      expect(await driver.findComponent(ON.text('Flutter'))).assertNull();
    });

    it('backReturnsToDiscover', 0, async () => {
      const driver = Driver.create();
      // Back may hide the keyboard first, then closes the search page (onBackPress → handleBackPress).
      for (let i = 0; i < 2 && (await driver.findComponent(ON.text('Kotlin'))) !== null; i++) {
        await driver.pressBack();
        await driver.delayMs(1000);
      }
      await driver.assertComponentExist(ON.id('CYLSearchDiscoverOpenSearch'));
      expect(await driver.findComponent(ON.text('Kotlin'))).assertNull();
    });
  });
}
