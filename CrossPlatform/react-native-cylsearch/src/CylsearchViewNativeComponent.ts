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

type ResultSelectEvent = Readonly<{
  result: string;
  index: CodegenTypes.Int32;
}>;

type RefreshEvent = Readonly<{}>;

export interface NativeProps extends ViewProps {
  /**
   * The suggestions to filter as the text changes (iOS `suggestions`).
   */
  suggestions?: ReadonlyArray<string>;
  /**
   * "tags" (CollectionViewClassifyMenu's tag list, the default) or "list" (one row each).
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
   * Shows the header above the cached queries (the title and the trash button); false takes it away, for a page that
   * clears the history with its own control (iOS `showsSuggestionCacheHeader`).
   */
  showsSuggestionCacheHeader?: CodegenTypes.WithDefault<boolean, true>;
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
  /**
   * The results of the current query (the core's `resultsDataSource`): listed under the bar instead of the
   * suggestions while the query is not empty. Update them in `onTextChange` / `onSubmit`.
   */
  results?: ReadonlyArray<string>;
  /**
   * Lists `results` (sets the core's `resultsDataSource`); false keeps the suggestions only.
   */
  showsResults?: boolean;
  /**
   * Adds pull-to-refresh to the results list (the core's `refreshHandler`, CYLTableViewPlaceHolder's header).
   */
  refreshEnabled?: boolean;
  /**
   * True starts the refresh indicator (`beginRefreshing`), false stops it (`endRefreshing`); set it to false on
   * every completion path of `onRefresh`.
   */
  refreshing?: boolean;
  onTextChange?: CodegenTypes.DirectEventHandler<TextEvent>;
  onSubmit?: CodegenTypes.DirectEventHandler<TextEvent>;
  onSuggestionSelect?: CodegenTypes.DirectEventHandler<SuggestionSelectEvent>;
  /**
   * The back arrow or Cancel closed the search: pop the screen here.
   */
  onClose?: CodegenTypes.DirectEventHandler<CloseEvent>;
  /**
   * A row of the results list was tapped (`searchView:didSelectResult:`).
   */
  onSelectResult?: CodegenTypes.DirectEventHandler<ResultSelectEvent>;
  /**
   * The person pulled the results list: refresh `results`, then set `refreshing` to false.
   */
  onRefresh?: CodegenTypes.DirectEventHandler<RefreshEvent>;
}

export default codegenNativeComponent<NativeProps>('CylsearchView') as HostComponent<NativeProps>;
