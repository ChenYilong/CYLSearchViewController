import { common } from '@kit.AbilityKit';

/**
 * Images and localized strings of the library's resources (iOS `CYLSearchResources`, the resource bundle of the pod).
 */
export class CYLSearchResources {
  /**
   * The name of the module that holds the resources (iOS `resourceBundle`).
   */
  static readonly resourceBundle: string = 'cylsearch';

  /**
   * A built-in image by name (`camera`, `mic`, `search`, `back`, `clear`, `submit`, `trash`), as a system symbol, or
   * undefined when there is none (iOS `+imageNamed:`).
   */
  static imageNamed(name: string): Resource | undefined {
    if (name === 'camera') {
      return $r('sys.symbol.camera');
    }
    if (name === 'mic') {
      return $r('sys.symbol.mic');
    }
    if (name === 'search') {
      return $r('sys.symbol.magnifyingglass');
    }
    if (name === 'back') {
      return $r('sys.symbol.chevron_backward');
    }
    if (name === 'clear') {
      return $r('sys.symbol.xmark_circle_fill');
    }
    if (name === 'submit') {
      return $r('sys.symbol.arrow_right');
    }
    if (name === 'trash') {
      return $r('sys.symbol.trash');
    }
    return undefined;
  }

  /**
   * The text of `key` ("search.cancel") in the language the app shows, or in `language` ("zh-Hans") when given; the
   * key itself when it is missing (iOS `+localizedStringForKey:` and `+localizedStringForKey:language:`).
   */
  static localizedString(context: common.Context, key: string, language?: string): string {
    const name = 'cyl_' + key.replace(new RegExp('\\.', 'g'), '_');
    try {
      if (language === undefined || language.length === 0) {
        return context.resourceManager.getStringByNameSync(name);
      }
      const configuration = context.resourceManager.getOverrideConfiguration();
      configuration.locale = language;
      return context.resourceManager.getOverrideResourceManager(configuration).getStringByNameSync(name);
    } catch (error) {
      return key;
    }
  }
}
