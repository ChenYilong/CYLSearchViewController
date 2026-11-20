import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { CYL_TAB_ICON_SOURCE_KEY, cylStoredTabIconSource } from '../common/DemoCommon';
import { cylRegisterExampleAnimationEngines } from '../animation/CYLExampleAnimationViews';
import { CYLMenuGestureState } from '@cyl/classifymenu';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // cylsearch and CollectionViewClassifyMenu play no animation by themselves: the example registers the engines it
    // bundles (Lottie, PAG, Rive, SVGA, GIF) and the views that play them, before any search bar item is shown.
    cylRegisterExampleAnimationEngines();
    // The tab icon source chosen last time (the Examples page's "Tab icons: …" button), before any page is built.
    AppStorage.setOrCreate<number>(CYL_TAB_ICON_SOURCE_KEY, cylStoredTabIconSource(this.context));
    this.storeLaunchParameters(want);
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.storeLaunchParameters(want);
  }

  // `aa start -b com.cyl.search.harmonyos -a EntryAbility --pi CYLDemoTab 3` selects that tab (iOS `-CYLDemoTab 3`, for
  // screenshots): the launch parameters arrive in `want.parameters`, and `pages/Index.ets` reads them from AppStorage.
  private storeLaunchParameters(want: Want): void {
    // `--pi CYLDemoTabIconSource <0|1|2>` chooses the tab icons for this launch (iOS `-CYLDemoTabIconSource <n>`).
    const source = want.parameters?.[CYL_TAB_ICON_SOURCE_KEY];
    if (source !== undefined && source !== null && [0, 1, 2].includes(Number(source))) {
      AppStorage.setOrCreate<number>(CYL_TAB_ICON_SOURCE_KEY, Number(source));
    }
    // The contact tags example (iOS launch arguments): `--pi CYLContactTags 1`, `CYLContactTagsEditor`,
    // `CYLContactTagsEmpty`, `CYLContactTagsResetCache` (1 = YES) and `CYLContactTagsServerLatency` (seconds).
    ['CYLContactTags', 'CYLContactTagsEditor', 'CYLContactTagsEmpty', 'CYLContactTagsResetCache',
      'CYLContactTagsServerLatency'].forEach((key: string) => {
      const value = want.parameters?.[key];
      if (value !== undefined && value !== null && !Number.isNaN(Number(value))) {
        AppStorage.setOrCreate<number>(key, Number(value));
      }
    });
    // Debug: `--pi CYLDebugTagGestureActive 1` sets the shared tag gesture state active (0 clears it), as a tag drag does, so a
    // test that cannot make a real long press can check that the scrollers hold and release.
    const gesture = want.parameters?.['CYLDebugTagGestureActive'];
    if (gesture !== undefined && gesture !== null && !Number.isNaN(Number(gesture))) {
      CYLMenuGestureState.shared.setActive(-1, Number(gesture) !== 0);
    }
    const tab = want.parameters?.['CYLDemoTab'];
    if (tab !== undefined && tab !== null) {
      const index = Number(tab);
      if (!Number.isNaN(index)) {
        AppStorage.setOrCreate<number>('CYLDemoTab', index);
      }
    }
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}