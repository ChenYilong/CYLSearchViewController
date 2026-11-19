import {
  codegenNativeComponent,
  type CodegenTypes,
  type HostComponent,
  type ViewProps,
} from 'react-native';

type TagSelectEvent = Readonly<{
  index: CodegenTypes.Int32;
  title: string;
  /**
   * The tag's id (`tagIds`), or its title when there are no ids.
   */
  id: string;
  /**
   * Whether the tap selected the tag (false: deselected), with `selectionMode` "multiple".
   */
  selected: boolean;
}>;

type HeightChangeEvent = Readonly<{
  height: CodegenTypes.Double;
}>;

type TagEvent = Readonly<{
  index: CodegenTypes.Int32;
  id: string;
}>;

type TagMoveEvent = Readonly<{
  from: CodegenTypes.Int32;
  to: CodegenTypes.Int32;
}>;

type RenameRequestEvent = Readonly<{
  index: CodegenTypes.Int32;
  id: string;
  title: string;
}>;

type EmptyEvent = Readonly<{
  section: CodegenTypes.Int32;
}>;

export interface NativeProps extends ViewProps {
  /**
   * The titles of the tags.
   */
  tags?: ReadonlyArray<string>;
  /**
   * The tags' ids, one per title (iOS `menuIdentifierForItem(at:)`): kept by renaming and reordering, and reported by the
   * events. Empty: the titles are the ids.
   */
  tagIds?: ReadonlyArray<string>;
  /**
   * The ids of the selected tags (with `selectionMode` "multiple").
   */
  selectedIds?: ReadonlyArray<string>;
  /**
   * "none" (default: taps report `onTagSelect` and select nothing) or "multiple".
   */
  selectionMode?: string;
  /**
   * The section's header title; empty hides the header.
   */
  sectionTitle?: string;
  /**
   * A trash button in the header (iOS `menuShowsClearButton(forSection:)`): `onClearButtonTap`.
   */
  showsClearButton?: boolean;
  /**
   * Editing mode (iOS `setEditing(_:animated:)`): a cross on each tag (`onTagDelete`) and dragging (`onTagMove`).
   */
  editing?: boolean;
  /**
   * While editing, an edit icon before each cross; it and a title tap send `onRenameRequest` (the host renames by id and
   * sends the new `tags`).
   */
  supportsRenaming?: boolean;
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
  onTagDelete?: CodegenTypes.DirectEventHandler<TagEvent>;
  onTagMove?: CodegenTypes.DirectEventHandler<TagMoveEvent>;
  onRenameRequest?: CodegenTypes.DirectEventHandler<RenameRequestEvent>;
  onClearButtonTap?: CodegenTypes.DirectEventHandler<EmptyEvent>;
}

export default codegenNativeComponent<NativeProps>('CylsearchTagListView') as HostComponent<NativeProps>;
