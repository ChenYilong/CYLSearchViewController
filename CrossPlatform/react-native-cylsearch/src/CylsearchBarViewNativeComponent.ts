import {
  codegenNativeComponent,
  type CodegenTypes,
  type HostComponent,
  type ViewProps,
} from 'react-native';

type TextEvent = Readonly<{
  text: string;
}>;

type CancelEvent = Readonly<{}>;

type ItemSelectEvent = Readonly<{
  index: CodegenTypes.Int32;
  selected: boolean;
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
   * The appended items as JSON (an array of `CYLSearchBarItem` values; see `CYLSearchBarView` in index.tsx).
   */
  itemsJSON?: string;
  onItemSelect?: CodegenTypes.DirectEventHandler<ItemSelectEvent>;
  onTextChange?: CodegenTypes.DirectEventHandler<TextEvent>;
  onSubmit?: CodegenTypes.DirectEventHandler<TextEvent>;
  onCancel?: CodegenTypes.DirectEventHandler<CancelEvent>;
}

export default codegenNativeComponent<NativeProps>('CylsearchBarView') as HostComponent<NativeProps>;
