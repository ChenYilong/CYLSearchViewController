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

type ReorderingChangeEvent = Readonly<{
  /**
   * True while a tag is being dragged to a new place (from the long press until the finger lifts or the drag is
   * cancelled).
   */
  reordering: boolean;
}>;

type SmearingChangeEvent = Readonly<{
  /**
   * True while a finger smears across tags to select them.
   */
  smearing: boolean;
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
   * A refresh icon (the SF Symbol "arrow.clockwise", a localized VoiceOver label) at the trailing end of the header, in
   * place of the More button's three dots (iOS `menuShowsMoreButton(inSection:)`, the core's `CYLSearchTagListHeader`):
   * `onRefreshButtonTap`. One header action: the refresh icon wins over `showsClearButton`.
   */
  showsRefreshButton?: boolean;
  /**
   * More than 0 shows the tags as a grid of that many plain titles per row (CollectionViewClassifyMenu's
   * `gridStyle(itemsPerRow:)`, the iOS example's discover topics); 0 (default) is the flowing capsule tags.
   */
  columns?: CodegenTypes.Int32;
  /**
   * An image after each tag's title, one entry per tag (a file URL or path, "" for none), shown at its own size: the
   * discover topics' hot icon. Empty means no images.
   */
  tagImages?: ReadonlyArray<string>;
  /**
   * The accessibility label of each tag's image, localized, one entry per tag ("" for none): VoiceOver and TalkBack read it
   * as the tag's value (for the hot icon, "Hot").
   */
  tagImageLabels?: ReadonlyArray<string>;
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
   * A drag that starts on a tag selects every tag it crosses (CollectionViewClassifyMenu `allowsSmearSelection`), with
   * `selectionMode` "multiple" and not while editing; `onSmearingChange` reports it. Default false.
   */
  allowsSmearSelection?: boolean;
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
  onRefreshButtonTap?: CodegenTypes.DirectEventHandler<EmptyEvent>;
  /**
   * A drag to reorder started or ended (CollectionViewClassifyMenu `menuDidChangeReordering`; the mini program's
   * `reorderingchange`). The native list already holds an ancestor scroll view during the drag; this reports the state.
   * Android and iOS (iOS: `-menu:didChangeReordering:`, CollectionViewClassifyMenu `c73ae8bd` or newer).
   */
  onReorderingChange?: CodegenTypes.DirectEventHandler<ReorderingChangeEvent>;
  /**
   * A smear selection started or ended (CollectionViewClassifyMenu `menuDidChangeSmearing`; the mini program's
   * `smearingchange`). Android and iOS, as `onReorderingChange`.
   */
  onSmearingChange?: CodegenTypes.DirectEventHandler<SmearingChangeEvent>;
}

export default codegenNativeComponent<NativeProps>('CylsearchTagListView') as HostComponent<NativeProps>;
