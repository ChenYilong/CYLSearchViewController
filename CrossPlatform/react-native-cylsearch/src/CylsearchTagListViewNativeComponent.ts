import {
  codegenNativeComponent,
  type CodegenTypes,
  type HostComponent,
  type ViewProps,
} from 'react-native';

type TagSelectEvent = Readonly<{
  index: CodegenTypes.Int32;
  title: string;
}>;

type HeightChangeEvent = Readonly<{
  height: CodegenTypes.Double;
}>;

export interface NativeProps extends ViewProps {
  /**
   * The titles of the tags.
   */
  tags?: ReadonlyArray<string>;
  /**
   * The fold control: "none", "inline" (default), "bottom", "topTrailing" or "topLeading".
   */
  foldControlPosition?: string;
  /**
   * What it shows: "icon" (default), "title" or "iconAndTitle".
   */
  foldControlContent?: string;
  /**
   * The rows shown while folded; 0 shows every row.
   */
  foldedRowCount?: CodegenTypes.WithDefault<CodegenTypes.Int32, 2>;
  /**
   * "light" or "dark".
   */
  colorScheme?: string;
  onTagSelect?: CodegenTypes.DirectEventHandler<TagSelectEvent>;
  /**
   * The height the tags need at the view's width (folding and unfolding change it).
   */
  onHeightChange?: CodegenTypes.DirectEventHandler<HeightChangeEvent>;
}

export default codegenNativeComponent<NativeProps>('CylsearchTagListView') as HostComponent<NativeProps>;
