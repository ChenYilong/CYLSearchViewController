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

type PresentationEvent = Readonly<{}>;

type HistoryEvent = Readonly<{
  query: string;
}>;

type RowSelectEvent = Readonly<{
  row: string;
  index: CodegenTypes.Int32;
}>;

type ResultSelectEvent = Readonly<{
  result: string;
  index: CodegenTypes.Int32;
}>;

export interface NativeProps extends ViewProps {
  /**
   * The rows of the list under the bar (iOS: a table under a `CYLSearchBarView` that opens the core's `CYLSearchView`; Android: `CYLSearchListView`).
   */
  rows?: ReadonlyArray<string>;
  /**
   * The placeholder of the search bar; empty keeps the localized default.
   */
  placeholder?: string;
  /**
   * The placeholder is centered at rest (`centersPlaceholder`).
   */
  centersPlaceholder?: boolean;
  /**
   * The bar is the first item of the list (`showsSearchBar`).
   */
  showsSearchBar?: CodegenTypes.WithDefault<boolean, true>;
  /**
   * The list starts scrolled so that the bar is out of sight (`hidesSearchBarInitially`).
   */
  hidesSearchBarInitially?: boolean;
  /**
   * The bar leaves the list while the empty view shows (`hidesSearchBarWhenEmptyViewShowing`).
   */
  hidesSearchBarWhenEmptyViewShowing?: boolean;
  /**
   * A bar above a short list settles fully shown or fully hidden when scrolling ends (`snapsHeaderSearchBar`, QMUI #1160).
   */
  snapsHeaderSearchBar?: CodegenTypes.WithDefault<boolean, true>;
  /**
   * The results of `resultsQuery`, listed while the search has that text; the match is drawn in the tint color. Answer
   * `onUpdateResults` with them: results of another text are not shown (a late answer never fills the list of a newer text).
   */
  results?: ReadonlyArray<string>;
  /**
   * The text `results` belong to.
   */
  resultsQuery?: string;
  /**
   * The empty view's text ("No matching results") for a text whose results are empty; empty shows none (`noResultsText`).
   */
  noResultsText?: string;
  /**
   * The launch area (the core's suggestion area, shown under the bar while the text is empty): these tags while there is no
   * history, then the history, with its title and clear button (`suggestions`, `showsSuggestionsForEmptyQuery`).
   */
  suggestions?: ReadonlyArray<string>;
  /**
   * A tapped tag submits the query like the return key (`submitsOnSuggestionSelection`).
   */
  submitsOnSuggestionSelection?: CodegenTypes.WithDefault<boolean, true>;
  /**
   * Where submitted queries are kept (`suggestionCachePolicy`): "none" (default), "userDefaults", "database" or "sandboxFile".
   */
  suggestionCachePolicy?: string;
  /**
   * Separates the histories of different screens (`suggestionCacheName`).
   */
  suggestionCacheName?: string;
  /**
   * The color behind the open search, as "#RRGGBB" or "#AARRGGBB"; a tap on it ends the search (`scrimColor`).
   */
  scrimColor?: string;
  /**
   * The first match of the text in each result is drawn in `resultMatchHighlightColor` (the tint color by default), case and
   * diacritic insensitive (`highlightsResultMatches`).
   */
  highlightsResultMatches?: boolean;
  resultMatchHighlightColor?: string;
  /**
   * A swipe from the edge ends the search (`supportsSwipeToDismissSearch`; Android: the predictive back swipe).
   */
  supportsSwipeToDismissSearch?: boolean;
  /**
   * "light" or "dark".
   */
  colorScheme?: string;
  /**
   * The text changed, also "" (`updateResultsFor`): send the `results` of it.
   */
  onUpdateResults?: CodegenTypes.DirectEventHandler<TextEvent>;
  onWillPresent?: CodegenTypes.DirectEventHandler<PresentationEvent>;
  onDidPresent?: CodegenTypes.DirectEventHandler<PresentationEvent>;
  onWillDismiss?: CodegenTypes.DirectEventHandler<PresentationEvent>;
  onDidDismiss?: CodegenTypes.DirectEventHandler<PresentationEvent>;
  /**
   * A submitted query went into the history (`historyDidChangeNotification`).
   */
  onHistoryChange?: CodegenTypes.DirectEventHandler<HistoryEvent>;
  /**
   * A query was submitted: the return key or a tapped tag.
   */
  onSubmit?: CodegenTypes.DirectEventHandler<TextEvent>;
  onSelectRow?: CodegenTypes.DirectEventHandler<RowSelectEvent>;
  onSelectResult?: CodegenTypes.DirectEventHandler<ResultSelectEvent>;
}

export default codegenNativeComponent<NativeProps>(
  'CylsearchListView'
) as HostComponent<NativeProps>;

interface NativeCommands {
  /**
   * Starts or ends the search from code (`setActive(_:animated:)`).
   */
  setActive: (
    viewRef: React.ElementRef<HostComponent<NativeProps>>,
    active: boolean,
    animated: boolean
  ) => void;
  /**
   * Removes every query of the history (the launch view's clear button).
   */
  clearHistory: (viewRef: React.ElementRef<HostComponent<NativeProps>>) => void;
}

export const Commands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ['setActive', 'clearHistory'],
});
