import {
  codegenNativeComponent,
  type CodegenTypes,
  type HostComponent,
  type ViewProps,
} from 'react-native';

type TextEvent = Readonly<{
  text: string;
}>;

type SuggestionSelectEvent = Readonly<{
  suggestion: string;
  index: CodegenTypes.Int32;
}>;

type CloseEvent = Readonly<{}>;

export interface NativeProps extends ViewProps {
  /**
   * The suggestions to filter as the text changes (iOS `suggestions`).
   */
  suggestions?: ReadonlyArray<string>;
  /**
   * "list" (one row each) or "tags" (CollectionViewClassifyMenu's tag list).
   */
  suggestionStyle?: string;
  /**
   * The search bar's placeholder.
   */
  placeholder?: string;
  /**
   * The query to start with.
   */
  query?: string;
  /**
   * Lists every suggestion while the query is empty.
   */
  showsSuggestionsForEmptyQuery?: boolean;
  /**
   * Submits a suggestion as soon as it is tapped.
   */
  submitsOnSuggestionSelection?: boolean;
  /**
   * Shows CYLTableViewPlaceHolder's placeholder while a query matches nothing.
   */
  showsEmptyResultsPlaceholder?: boolean;
  /**
   * "noSearchResults" or "noContent".
   */
  emptyResultsScenario?: string;
  /**
   * Where submitted queries are cached: "none", "database" (default), "userDefaults" or "sandboxFile".
   */
  suggestionCachePolicy?: string;
  /**
   * Separates the caches of different search pages.
   */
  suggestionCacheName?: string;
  /**
   * Focuses the field when the page opens (the keyboard rises); false waits for a tap.
   */
  focusesSearchFieldOnShow?: CodegenTypes.WithDefault<boolean, true>;
  /**
   * The tag suggestions' fold control: "none", "inline" (default), "bottom", "topTrailing" or "topLeading".
   */
  suggestionsFoldControlPosition?: string;
  /**
   * What it shows: "icon" (default), "title" or "iconAndTitle".
   */
  suggestionsFoldControlContent?: string;
  /**
   * The rows of tag suggestions shown while folded; 0 shows every row.
   */
  suggestionsFoldedRowCount?: CodegenTypes.WithDefault<CodegenTypes.Int32, 2>;
  /**
   * "light" or "dark": the native view follows the app's color scheme.
   */
  colorScheme?: string;
  onTextChange?: CodegenTypes.DirectEventHandler<TextEvent>;
  onSubmit?: CodegenTypes.DirectEventHandler<TextEvent>;
  onSuggestionSelect?: CodegenTypes.DirectEventHandler<SuggestionSelectEvent>;
  /**
   * The back arrow or Cancel closed the search: pop the screen here.
   */
  onClose?: CodegenTypes.DirectEventHandler<CloseEvent>;
}

export default codegenNativeComponent<NativeProps>('CylsearchView') as HostComponent<NativeProps>;
