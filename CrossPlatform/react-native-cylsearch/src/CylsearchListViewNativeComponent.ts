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
   * The rows of the list under the bar (iOS `CYLSearchTableViewController`, Android `CYLSearchListView`).
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
   * The empty view's text ("No matching results") for a text whose results are empty; empty shows none
   * (`showEmptyView` / `hideEmptyView`).
   */
  emptyViewText?: string;
  /**
   * The launch view (`launchView`): its title ("Recent searches"), shown under the bar while the text is empty; empty shows none.
   */
  launchTitle?: string;
  /**
   * The tags the launch view shows while there is no history.
   */
  launchSuggestions?: ReadonlyArray<string>;
  /**
   * Screen reader labels of the launch view's tags and of its clear button.
   */
  launchLabel?: string;
  clearHistoryLabel?: string;
  /**
   * Where submitted queries are kept (`historyStore`): "none" (default), "userDefaults", "database" or "sandboxFile".
   */
  historyPolicy?: string;
  /**
   * Separates the histories of different screens.
   */
  historyName?: string;
  /**
   * The dimming under the bar while the text is empty and no launch view shows, as "#RRGGBB" or "#AARRGGBB"; a tap ends the search (`dimmingColor`).
   */
  dimmingColor?: string;
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
