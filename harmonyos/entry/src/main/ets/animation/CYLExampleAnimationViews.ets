/**
 * The example's animation engines: `cylRegisterExampleAnimationEngines()` registers CYLTabBarController's engine views
 * (`CYLAnimatedItemLottie`, `CYLAnimatedItemPAG`, `CYLAnimatedItemRive`, `CYLAnimatedItemGIF`, `CYLAnimatedItemSVGA`), so
 * every search bar item's animated icon plays through `CYLAnimatedItemView`'s default engine view. The example's own
 * players are gone: engine fixes live in CYLTabBarController and are shared by every app that uses it. Same as
 * CollectionViewClassifyMenu's example (`harmony/entry/src/main/ets/animation`, the pinned
 * `collectionViewClassifyMenuCommit`). Example layer only; `cylsearch` depends on no animation library.
 */
import { CYLAnimatedItemEngines, CYLAnimatedItemGIF, CYLAnimatedItemSVGA } from 'cylanimateditem';
import { CYLAnimatedItemLottie } from 'cylanimateditem_lottie';
import { CYLAnimatedItemPAG } from 'cylanimateditem_pag';
import { CYLAnimatedItemRive } from 'cylanimateditem_rive';

/**
 * Registers the engines the example plays (Lottie, PAG, Rive, GIF, SVGA). Called once, before any item is shown
 * (`EntryAbility.onCreate`). With the ability's context, the x86_64 engine kit is read first (PAG and Rive then play on
 * the x86_64 emulator).
 */
export function cylRegisterExampleAnimationEngines(context?: Context): void {
  if (context !== undefined) {
    CYLAnimatedItemEngines.loadX86_64DebugEngines(context);
  }
  CYLAnimatedItemLottie.register();
  CYLAnimatedItemPAG.register();
  CYLAnimatedItemRive.register();
  CYLAnimatedItemGIF.register();
  CYLAnimatedItemSVGA.register();
}
