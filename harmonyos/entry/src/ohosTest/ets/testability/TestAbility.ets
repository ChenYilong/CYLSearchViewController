import { UIAbility, Want, AbilityConstant } from '@kit.AbilityKit';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { window } from '@kit.ArkUI';
import { Hypium } from '@ohos/hypium';
import testsuite from '../test/List.test';

export default class TestAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    const delegator = abilityDelegatorRegistry.getAbilityDelegator();
    const args = abilityDelegatorRegistry.getArguments();
    Hypium.hypiumTest(delegator, args, testsuite);
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    windowStage.loadContent('testability/pages/Index');
  }
}
