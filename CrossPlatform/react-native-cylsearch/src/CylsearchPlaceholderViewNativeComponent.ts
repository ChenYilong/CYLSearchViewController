import {
  codegenNativeComponent,
  type HostComponent,
  type ViewProps,
} from 'react-native';

export interface NativeProps extends ViewProps {
  /**
   * CYLTableViewPlaceHolder's `CYLPlaceholderStyle`, by name: "empty", "noResults", "personOff", … (the image).
   */
  placeholderStyle?: string;
  /**
   * The text under the image.
   */
  text?: string;
  /**
   * "light" or "dark".
   */
  colorScheme?: string;
}

export default codegenNativeComponent<NativeProps>('CylsearchPlaceholderView') as HostComponent<NativeProps>;
