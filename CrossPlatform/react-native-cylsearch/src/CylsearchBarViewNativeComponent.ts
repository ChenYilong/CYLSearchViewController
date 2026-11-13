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
  onTextChange?: CodegenTypes.DirectEventHandler<TextEvent>;
  onSubmit?: CodegenTypes.DirectEventHandler<TextEvent>;
  onCancel?: CodegenTypes.DirectEventHandler<CancelEvent>;
}

export default codegenNativeComponent<NativeProps>('CylsearchBarView') as HostComponent<NativeProps>;
