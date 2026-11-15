import { UIContext } from '@kit.ArkUI';

/**
 * Animates `change` with the UI context of the component that draws the model (`UIContext.animateTo`, which replaces
 * the deprecated global `animateTo`). Before any component has drawn the model there is nothing on screen to
 * animate: the change is applied at once and `onFinish` is called.
 */
export function cylAnimate(uiContext: UIContext | undefined, param: AnimateParam, change: () => void): void {
  if (uiContext === undefined) {
    change();
    param.onFinish?.();
    return;
  }
  uiContext.animateTo(param, change);
}
