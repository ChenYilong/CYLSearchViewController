import type * as React from 'react';
import {
  codegenNativeCommands,
  codegenNativeComponent,
  type CodegenTypes,
  type HostComponent,
  type ViewProps,
} from 'react-native';

type TextEvent = Readonly<{
  text: string;
}>;

type IndexedTextEvent = Readonly<{
  text: string;
  index: CodegenTypes.Int32;
}>;

type IndexEvent = Readonly<{
  index: CodegenTypes.Int32;
}>;

type CancelEvent = Readonly<{}>;

type ItemSelectEvent = Readonly<{
  index: CodegenTypes.Int32;
  selected: boolean;
}>;

type ActiveEvent = Readonly<{
  active: boolean;
}>;

type BackButtonEvent = Readonly<{
  tapped: boolean;
}>;

export interface NativeProps extends ViewProps {
  /**
   * The placeholder.
   */
  placeholder?: string;
  /**
   * The text; "" keeps what the person typed.
   */
  text?: string;
  /**
   * Shows Cancel after the field.
   */
  showsCancelButton?: boolean;
  /**
   * The field's shadow, 0 to 1.
   */
  fieldShadowOpacity?: CodegenTypes.Double;
  /**
   * "light" or "dark".
   */
  colorScheme?: string;
  /**
   * The fixed look of the bar: "plain" (default) or "bordered".
   */
  searchBarStyle?: string;
  /**
   * Draws the magnifier at the start of the field.
   */
  showsSearchIcon?: CodegenTypes.WithDefault<boolean, true>;
  /**
   * The core navigation field preset (iOS `applyNavigationFieldStyle()`): bordered capsule radius 18, soft shadow 0.06, no
   * magnifier, 16 text that scales, an opaque white (light) or black (dark) fill. It wins over `searchBarStyle`,
   * `fieldShadowOpacity` and `showsSearchIcon`.
   */
  navigationFieldStyle?: CodegenTypes.WithDefault<boolean, false>;
  /**
   * The field focuses itself (and the keyboard shows) every time the bar appears on screen, like a `viewDidAppear`: the first
   * entry, a tab switch, a push and pop and the return from the background. Default false. Android filter (owner, 2026-11-26): only a bar embedded in a navigation bar that shows a back button (`embedsInNavigationBar` with `showsBackButton`) focuses; a root tab or a plain bar never does. Android: the core
   * (`CYLSearchBarView.focusesOnAppear`) watches attach, visibility, window focus and the Activity's resume, so no JS side
   * moment is needed (an AppState listener cannot tell whether the bar is on screen).
   */
  focusesOnAppear?: CodegenTypes.WithDefault<boolean, false>;
  /**
   * The bar sits in a navigation bar the core creates (`CYLSearchNavigationBar`, 44 pt high, the field 36 pt) instead of
   * being a plain view: the page always has its search bar in a navigation bar. Default false.
   */
  embedsInNavigationBar?: CodegenTypes.WithDefault<boolean, false>;
  /**
   * With `embedsInNavigationBar`: the navigation bar has the back button of a second-level page on its leading side and
   * the search bar takes the width that is left; a tap reports `onBackButtonTap` (the host closes the page). Default
   * false.
   */
  showsBackButton?: CodegenTypes.WithDefault<boolean, false>;
  /**
   * With `showsBackButton`: the bar starts whole and the back button slides in while the width shrinks (the continuation of the
   * first-level bar that pushed this page; Android core `showBackButton(animated)`); a later change of `showsBackButton`
   * animates too. False: at once. Default true.
   */
  animatesBackButton?: CodegenTypes.WithDefault<boolean, true>;
  /**
   * First-level page (with `embedsInNavigationBar`): the bar is shown whole and a tap on its field does not edit. The native core
   * brings the back button in (animated) and sends `onFirstLevelTap`, where the page pushes the second-level search page, whose
   * bar sets `showsBackButton`. Default false.
   */
  pushesOnTap?: CodegenTypes.WithDefault<boolean, false>;
  /**
   * The appended items as JSON (an array of `CYLSearchBarItem` values; see `CYLSearchBarView` in index.tsx).
   */
  itemsJSON?: string;
  /**
   * "single" (one field, the default) or "multiple" (several searches side by side, `CYLSearchBarMode`).
   */
  mode?: string;
  /**
   * "multiple" mode: the completed searches; a new list replaces the native ones, the last one selected.
   */
  searches?: ReadonlyArray<string>;
  /**
   * "multiple" mode: a search shorter than this is dropped when it is completed (3 by default).
   */
  minimumTextLength?: CodegenTypes.WithDefault<CodegenTypes.Int32, 3>;
  /**
   * The editing bar (iOS `CYLSearchBarView.editingBar(placeholder:actionTitle:)`): no magnifier, `actionTitle` ("Add",
   * "Done") as the trailing button, which submits the trimmed text as the return key does (`onEditingSubmit`). The host keeps
   * it above the keyboard (`KeyboardAvoidingView`). Given a `text` (a tag's title to rename), the editing bar takes the
   * keyboard with the text selected.
   */
  editingBar?: boolean;
  actionTitle?: string;
  /**
   * Applies `CYLSearchBarAppearance.default` (`applyDefaultAppearance()`) before the other style options. The options
   * below (`centersPlaceholder` to `onActiveChange`) are members of `CYLSearchBarView` on iOS and Android.
   */
  usesDefaultAppearance?: boolean;
  /**
   * The placeholder and its magnifier sit in the middle of the field at rest and at the start while editing (`centersPlaceholder`).
   */
  centersPlaceholder?: boolean;
  /**
   * Colors as "#RRGGBB" or "#AARRGGBB"; empty keeps the appearance's.
   */
  placeholderColor?: string;
  textColor?: string;
  /**
   * The field's margins in points / dp, [top, left, bottom, right], at rest and while searching (`textFieldMarginsProvider(bar, active)`);
   * empty means none.
   */
  fieldMargins?: ReadonlyArray<CodegenTypes.Double>;
  searchingFieldMargins?: ReadonlyArray<CodegenTypes.Double>;
  /**
   * Cancel's margins, [top, left, bottom, right], at rest and while searching (`cancelButtonMarginsProvider(bar, active)`); a
   * negative left pulls Cancel toward the field.
   */
  cancelMargins?: ReadonlyArray<CodegenTypes.Double>;
  searchingCancelMargins?: ReadonlyArray<CodegenTypes.Double>;
  /**
   * Cancel and the accessories change with an animation (`setShowsCancelButton(_:animated:)`); false changes at once.
   */
  animatesChanges?: CodegenTypes.WithDefault<boolean, true>;
  /**
   * The view before the field (`leadingView`) and the views after the text (`trailingAccessoryViews`, a JSON array), each a
   * spec drawn by the wrapper (`{"kind":"square","size":30,"color":"#FF3B30","label":"..."}`, a stroked rounded square);
   * shown or hidden by `showsLeadingView` and `showsTrailingAccessoryViews`, animated unless `animatesChanges` is false.
   */
  leadingViewJSON?: string;
  trailingAccessoryViewsJSON?: string;
  showsLeadingView?: boolean;
  showsTrailingAccessoryViews?: boolean;
  /**
   * `appearanceStyle`: a `CYLSearchBarAppearance` as JSON (`{"textColor","placeholderColor","tintColor","cancelTitle","fieldBackgroundColor","fieldCornerRadius","fontSize"}`).
   */
  appearanceStyleJSON?: string;
  /**
   * The font of Cancel's title (`cancelButtonFont`) as JSON (`{"size":17,"weight":"semibold"}`); empty keeps the bar's font.
   */
  cancelButtonFontJSON?: string;
  /**
   * The field gained or lost the focus (iOS: the bar is editing; `searchController.isActive` once a controller owns it).
   */
  onActiveChange?: CodegenTypes.DirectEventHandler<ActiveEvent>;
  onItemSelect?: CodegenTypes.DirectEventHandler<ItemSelectEvent>;
  /**
   * The back button of the navigation bar was tapped (`showsBackButton`): the host closes the page.
   */
  onBackButtonTap?: CodegenTypes.DirectEventHandler<BackButtonEvent>;
  /**
   * The first-level field was tapped (`pushesOnTap`): push the second-level search page.
   */
  onFirstLevelTap?: CodegenTypes.DirectEventHandler<BackButtonEvent>;
  /**
   * The text changed: `index` is the search being typed in "multiple" mode, -1 in "single" mode.
   */
  onTextChange?: CodegenTypes.DirectEventHandler<IndexedTextEvent>;
  /**
   * "multiple" mode: a typed search was completed and became the search at `index`.
   */
  onCompleteSearch?: CodegenTypes.DirectEventHandler<IndexedTextEvent>;
  /**
   * "multiple" mode: the search at `index` was removed.
   */
  onRemoveSearch?: CodegenTypes.DirectEventHandler<IndexEvent>;
  /**
   * "multiple" mode: the search at `index` was selected by a tap.
   */
  onSelectSearch?: CodegenTypes.DirectEventHandler<IndexedTextEvent>;
  onSubmit?: CodegenTypes.DirectEventHandler<TextEvent>;
  /**
   * The editing bar's action button or return key, with the trimmed text (not sent for empty text); the field clears after it.
   */
  onEditingSubmit?: CodegenTypes.DirectEventHandler<TextEvent>;
  onCancel?: CodegenTypes.DirectEventHandler<CancelEvent>;
}

export default codegenNativeComponent<NativeProps>(
  'CylsearchBarView'
) as HostComponent<NativeProps>;

interface NativeCommands {
  /**
   * Starts (focus, the keyboard rises) or ends (focus leaves) the search from code (`isActive`).
   */
  setActive: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    active: boolean
  ) => void;
  /**
   * Plays the animation of the item at `index` again from the start (`CYLSearchBarItem.restartAnimation()`).
   */
  restartItemAnimation: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    index: CodegenTypes.Int32
  ) => void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['setActive', 'restartItemAnimation'],
});
