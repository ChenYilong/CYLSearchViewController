import { display, LengthMetrics, UIContext, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { accessibility } from '@kit.AccessibilityKit';
import {
  CYLPlaceholderActions,
  CYLPlaceholderButtonStyle,
  CYLPlaceholderComponent,
  CYLPlaceholderScenario,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLRefreshContainer,
  CYLRefreshNormalHeaderModel,
  CYLRefreshScrollViewModel,
  CYLPlaceholderStyle
} from 'cylplaceholder';
import {
  CYLMenuFoldControl as CYLTagFoldControl,
  CYLMenuFoldControlContent as CYLTagFoldContent,
  CYLMenuFoldControlPosition as CYLTagFoldPosition,
  CYLMenuDelegate,
  CYLMenuGestureState,
  CYLMenuSelectionMode,
  CYLTag,
  CYLTagListState,
  CYLTagListView
} from '@cyl/classifymenu';
import {
  CYLSearchBarAppearance,
  CYLSearchBarComponent,
  CYLSearchBarNavigationIcon,
  CYLSearchBarView,
  CYLSearchBarViewDelegate
} from './CYLSearchBarView';
import { CYLSearchResources, CYLSearchSuggestionCache, CYLSearchSuggestionCachePolicy } from './CYLSearchResources';

// MARK: - Pure logic (begin): no ArkUI, no kit; harmonyos/scripts/host-logic-test.mjs runs it with Node.

/**
 * The text with its accents removed, lowercased, so "cafe" matches "café" (Android `CYLSearchView.fold`).
 */
function cylFoldSearchText(text: string): string {
  return text.normalize('NFD').replace(new RegExp('[̀-ͯ]+', 'g'), '').toLowerCase();
}

/**
 * Whether `suggestion` matches `query`: the trimmed, folded query is part of the folded suggestion (Android
 * `CYLSearchView.matches` without a custom filter).
 */
function cylSuggestionMatches(suggestion: string, query: string): boolean {
  return cylFoldSearchText(suggestion).includes(cylFoldSearchText(query.trim()));
}

/**
 * The suggestions to show and whether they are the cached queries (Android `CYLSearchView.refilter`).
 */
interface CYLSearchFilterResult {
  /**
   * The suggestions to show, in order.
   */
  suggestions: string[];
  /**
   * True when the list is the cached queries (an empty query with a cache), so the cache header is shown.
   */
  showsCachedQueries: boolean;
}

/**
 * Filters the suggestions for `query` (Android `CYLSearchView.refilter`): an empty or blank query shows the cached
 * queries, or every suggestion with `showsAllForEmptyQuery`, or nothing; any other query shows the matching cached
 * queries first, then the matching suggestions not already listed. `matches` replaces the default match.
 */
function cylFilterSuggestions(query: string, cached: string[], all: string[], showsAllForEmptyQuery: boolean,
  matches?: (suggestion: string, query: string) => boolean): CYLSearchFilterResult {
  const match = matches ?? cylSuggestionMatches;
  if (query.trim().length === 0) {
    if (cached.length > 0) {
      const cachedResult: CYLSearchFilterResult = { suggestions: cached.slice(), showsCachedQueries: true };
      return cachedResult;
    }
    const emptyResult: CYLSearchFilterResult = {
      suggestions: showsAllForEmptyQuery ? all.slice() : [],
      showsCachedQueries: false
    };
    return emptyResult;
  }
  const result: string[] = [];
  cached.forEach((value: string) => {
    if (match(value, query)) {
      result.push(value);
    }
  });
  all.forEach((value: string) => {
    if (match(value, query) && !result.includes(value)) {
      result.push(value);
    }
  });
  const filtered: CYLSearchFilterResult = { suggestions: result, showsCachedQueries: false };
  return filtered;
}

/**
 * Where the first match of `query` is in `text`, as the start and the end of the range in `text`, ignoring case and
 * accents (iOS `range(of:options: [.caseInsensitive, .diacriticInsensitive])`); undefined for an empty query or no match.
 * Each character is folded on its own, so the range is in the original text although folding changes the length.
 */
function cylSearchMatchRange(text: string, query: string): number[] | undefined {
  const needle = cylFoldSearchText(query);
  if (needle.length === 0) {
    return undefined;
  }
  let folded = '';
  const starts: number[] = [];
  const ends: number[] = [];
  let index = 0;
  for (const character of text) {
    const piece = cylFoldSearchText(character);
    if (piece.length === 0 && ends.length > 0) {
      // A combining mark belongs to the character before it: the range ends after it.
      ends[ends.length - 1] = index + character.length;
    }
    for (let i = 0; i < piece.length; i++) {
      starts.push(index);
      ends.push(index + character.length);
    }
    folded += piece;
    index += character.length;
  }
  const at = folded.indexOf(needle);
  if (at < 0) {
    return undefined;
  }
  return [starts[at], ends[at + needle.length - 1]];
}

/**
 * Whether a swipe to dismiss begins (iOS `CYLSearchEdgePanGestureRecognizer`): the touch went down within 24 of the
 * left edge, then moved right past a slop of 10 and more than up or down.
 */
function cylSearchSwipeBegins(startX: number, dx: number, dy: number): boolean {
  return startX <= 24 && dx > 10 && dx > Math.abs(dy);
}

/**
 * Whether a swipe to dismiss ends the search: it moved right past a quarter of the width (iOS `CYLSearchEdgeSwipe`).
 */
function cylSearchSwipeCompletes(dx: number, width: number): boolean {
  return dx > width / 4;
}

/**
 * Whether the empty view shows: it was asked for and the query is not empty (iOS `QMUISearchController`: the empty
 * view is not shown while the text is empty, because it would sit on the dimming view).
 */
function cylSearchEmptyViewShown(requested: boolean, query: string): boolean {
  return requested && query.trim().length > 0;
}

/**
 * Whether the launch view shows: there is one and the query is empty.
 */
function cylSearchLaunchViewShown(hasLaunchView: boolean, query: string): boolean {
  return hasLaunchView && query.trim().length === 0;
}

/**
 * Whether the scrim shows under the bar: a scrim color is set, the query is empty and no launch view covers it
 * (iOS `scrimColor` is ignored when `launchView` is set).
 */
function cylSearchDimmingShown(hasDimming: boolean, hasLaunchView: boolean, query: string): boolean {
  return hasDimming && !hasLaunchView && query.trim().length === 0;
}

/**
 * The height to add after the rows so that a header of the list can scroll out of sight above a short list:
 * what the rows leave of the viewport, never less than 0 (iOS `CYLSearchHeaderSnapper`, issue 1160).
 */
function cylSearchHeaderFillerHeight(viewportHeight: number, rowsHeight: number): number {
  return Math.max(0, viewportHeight - rowsHeight);
}

/**
 * Where a header that rests at `offset` settles: fully hidden (its height) from its half on, else fully shown (0);
 * undefined when it already is, or when it is not in the header band (iOS `CYLSearchHeaderSnapper.settle`).
 */
function cylSearchHeaderSettleOffset(offset: number, headerHeight: number): number | undefined {
  if (headerHeight <= 0 || offset <= 0 || offset >= headerHeight) {
    return undefined;
  }
  return offset >= headerHeight / 2 ? headerHeight : 0;
}

/**
 * The title of the header over the results (iOS `resultsHeaderTitleProvider`): what the provider answers for the query
 * while results show; undefined (no header) when no results show, there is no provider, or it answers undefined.
 */
function cylSearchResultsHeaderTitle(showsResults: boolean, provider: ((query: string) => string | undefined) | undefined,
  query: string): string | undefined {
  if (!showsResults || provider === undefined) {
    return undefined;
  }
  return provider(query);
}

// MARK: - Pure logic (end)

/**
 * Animates `change` with the UI context of the component that draws the model (`UIContext.animateTo`). Before any
 * component has drawn the model there is nothing on screen to animate: the change is applied at once and `onFinish`
 * is called.
 */
function cylAnimate(uiContext: UIContext | undefined, param: AnimateParam, change: () => void): void {
  if (uiContext === undefined) {
    change();
    param.onFinish?.();
    return;
  }
  uiContext.animateTo(param, change);
}

// MARK: - Pull to refresh (CYLTableViewPlaceHolder's CYLRefresh, from its HarmonyOS library `cylplaceholder`)

/**
 * The refresh state of each scroller (the iOS scroll view's `cyl_header`). A weak map: an entry, with its handler,
 * goes away with its scroller, so a handler never keeps its page alive.
 */
const cylRefreshScrollViews: WeakMap<Scroller, CYLRefreshScrollViewModel> =
  new WeakMap<Scroller, CYLRefreshScrollViewModel>();

/**
 * The refresh state of `scroller`, created the first time it is asked for.
 */
function cylRefreshScrollView(scroller: Scroller): CYLRefreshScrollViewModel {
  let scrollView = cylRefreshScrollViews.get(scroller);
  if (scrollView === undefined) {
    scrollView = new CYLRefreshScrollViewModel();
    cylRefreshScrollViews.set(scroller, scrollView);
  }
  return scrollView;
}

/**
 * Nothing: the default content of `CYLSearchRefreshComponent`.
 */
@Builder
function cylSearchEmptyContent() {
}

/**
 * How the suggestions are shown under the search bar (iOS `CYLSearchSuggestionStyle`).
 */
export enum CYLSearchSuggestionStyle {
  /**
   * One suggestion per row with its icon.
   */
  list = 0,
  /**
   * Tags that wrap like words.
   */
  tags = 1
}

/**
 * Where the fold control of the tag suggestions sits. Kept for the code that set it: the tag list draws
 * CollectionViewClassifyMenu's own `CYLMenuFoldControlPosition` (`inline` is its `tail`, `bottom` its `footer`).
 * @deprecated Set `suggestionsTagView.foldControl` with CollectionViewClassifyMenu's `CYLMenuFoldControl`.
 */
export enum CYLMenuFoldControlPosition {
  /**
   * After the last visible tag.
   */
  inline = 0,
  /**
   * On a row of its own under the tags.
   */
  bottom = 1,
  /**
   * No control: every tag is shown (iOS `CYLMenuFoldControlPositionNone`).
   */
  none = 2
}


/**
 * What the fold control shows; kept for the code that set it (CollectionViewClassifyMenu's `CYLMenuFoldControlContent`).
 * @deprecated Set `suggestionsTagView.foldControl` with CollectionViewClassifyMenu's `CYLMenuFoldControl`.
 */
export enum CYLMenuFoldControlContent {
  /**
   * A chevron.
   */
  icon = 0,
  /**
   * "More" / "Less".
   */
  title = 1
}

/**
 * The fold control of the tag suggestions; kept for the code that set it, it maps onto CollectionViewClassifyMenu's
 * `CYLMenuFoldControl` of the tag list.
 * @deprecated Set `suggestionsTagView.foldControl` with CollectionViewClassifyMenu's `CYLMenuFoldControl`.
 */
export class CYLMenuFoldControl {
  /**
   * Where it sits.
   */
  readonly position: CYLMenuFoldControlPosition;
  /**
   * What it shows.
   */
  readonly content: CYLMenuFoldControlContent;

  /**
   * A fold control (iOS `+foldControlWithPosition:content:`).
   */
  constructor(position: CYLMenuFoldControlPosition = CYLMenuFoldControlPosition.inline,
    content: CYLMenuFoldControlContent = CYLMenuFoldControlContent.icon) {
    this.position = position;
    this.content = content;
  }
}

/**
 * The tag list's own fold control for a `CYLMenuFoldControl` of this file (`inline` is the last tag, `bottom` is the
 * footer, a title is a title).
 */
function cylTagFoldControl(control: CYLMenuFoldControl): CYLTagFoldControl {
  let position: CYLTagFoldPosition = CYLTagFoldPosition.tail;
  if (control.position === CYLMenuFoldControlPosition.bottom) {
    position = CYLTagFoldPosition.footer;
  } else if (control.position === CYLMenuFoldControlPosition.none) {
    position = CYLTagFoldPosition.none;
  }
  return new CYLTagFoldControl(position,
    control.content === CYLMenuFoldControlContent.title ? CYLTagFoldContent.title : CYLTagFoldContent.icon);
}

/**
 * A piece of a result row's text and whether it is the match.
 */
class CYLSearchResultPart {
  text: string;
  matches: boolean;

  constructor(text: string, matches: boolean) {
    this.text = text;
    this.matches = matches;
  }
}

/**
 * The pieces of `text` around the first match of `query` (see `cylSearchMatchRange`); one piece without a match when
 * `query` is empty or not found.
 */
function cylSearchResultParts(text: string, query: string): CYLSearchResultPart[] {
  const range = cylSearchMatchRange(text, query);
  if (range === undefined) {
    return [new CYLSearchResultPart(text, false)];
  }
  const parts: CYLSearchResultPart[] = [];
  if (range[0] > 0) {
    parts.push(new CYLSearchResultPart(text.substring(0, range[0]), false));
  }
  parts.push(new CYLSearchResultPart(text.substring(range[0], range[1]), true));
  if (range[1] < text.length) {
    parts.push(new CYLSearchResultPart(text.substring(range[1]), false));
  }
  return parts;
}

/**
 * Events of a `CYLSearchView` (iOS `CYLSearchViewDelegate`); every method is optional.
 */
export interface CYLSearchViewDelegate {
  /**
   * The search view finished opening.
   */
  searchViewDidShow?: (searchView: CYLSearchView) => void;
  /**
   * The search view finished closing.
   */
  searchViewDidClose?: (searchView: CYLSearchView) => void;
  /**
   * The query changed (iOS `-searchView:textDidChange:`).
   */
  searchViewTextDidChange?: (searchView: CYLSearchView, text: string) => void;
  /**
   * The query was submitted (iOS `-searchView:didSubmitText:`). Return true when you handled it and the search view
   * stays open; false lets `closesOnSubmit` close it.
   */
  searchViewDidSubmitText?: (searchView: CYLSearchView, text: string) => boolean;
  /**
   * The field started or stopped editing (iOS `-searchView:didChangeFocus:`).
   */
  searchViewDidChangeFocus?: (searchView: CYLSearchView, focused: boolean) => void;
  /**
   * A suggestion was tapped (iOS `-searchView:didSelectSuggestion:atIndex:`).
   */
  searchViewDidSelectSuggestion?: (searchView: CYLSearchView, suggestion: string, index: number) => void;
  /**
   * The voice button was tapped.
   */
  searchViewVoiceButtonClicked?: (searchView: CYLSearchView) => void;
  /**
   * The navigation button (the back arrow by default) was tapped. Without this method it closes the search view.
   */
  searchViewNavigationButtonClicked?: (searchView: CYLSearchView) => void;
  /**
   * A result of `resultsDataSource` was tapped (iOS `-searchView:didSelectResult:`).
   */
  searchViewDidSelectResult?: (searchView: CYLSearchView, result: Object) => void;
  /**
   * The search is about to open (iOS `willPresentSearchController`).
   */
  searchViewWillShow?: (searchView: CYLSearchView) => void;
  /**
   * The search is about to close (iOS `willDismissSearchController`).
   */
  searchViewWillClose?: (searchView: CYLSearchView) => void;
  /**
   * Update the results for `searchString`: called on every change of the text, also with "" (when the search opens,
   * when the text is deleted or cleared), as iOS `searchResultsDelegate.updateResultsFor` is.
   */
  searchViewUpdateResults?: (searchView: CYLSearchView, searchString: string) => void;
  /**
   * A submitted query went into the history; a launch view that stays on screen reads it again (iOS
   * `historyDidChangeNotification`).
   */
  searchViewHistoryDidChange?: (searchView: CYLSearchView, query: string) => void;
}

/**
 * The content of the empty view of a search or a list (iOS `showEmptyView(text:detailText:buttonTitle:buttonAction:)`,
 * `hideEmptyView()`, `isEmptyViewShowing`): a centered text, an optional detail text and an optional button.
 */
@ObservedV2
export class CYLSearchEmptyView {
  /**
   * Whether the empty view was asked for.
   */
  @Trace isShowing: boolean = false;
  /**
   * The main text, such as "No matching results".
   */
  @Trace text: string = '';
  /**
   * The smaller text under it.
   */
  @Trace detailText: string | undefined = undefined;
  /**
   * The title of the button under the texts.
   */
  @Trace buttonTitle: string | undefined = undefined;
  /**
   * Called when the button is tapped.
   */
  buttonAction: (() => void) | undefined = undefined;
  /**
   * CYLTableViewPlaceHolder's placeholder that draws the texts: the "no results" animation with the title, an optional
   * hint and an optional button (iOS `CYLSearchEmptyView.message`), the same placeholder every empty view of the core
   * is drawn with. Undefined until the first `show`.
   */
  @Trace placeholder: CYLPlaceholderStackViewModel | undefined = undefined;
  /**
   * Counts the calls of `show`; the component draws a new placeholder for each.
   */
  @Trace revision: number = 0;

  /**
   * Shows the empty view with these texts.
   */
  show(text: string, detailText?: string, buttonTitle?: string, buttonAction?: () => void): void {
    this.text = text;
    this.detailText = detailText;
    this.buttonTitle = buttonTitle;
    this.buttonAction = buttonAction;
    this.placeholder = CYLSearchEmptyView.message(text, detailText, buttonTitle, buttonAction);
    this.revision += 1;
    this.isShowing = true;
  }

  /**
   * Shows the empty view with one of CYLTableViewPlaceHolder's scenarios (iOS `CYLSearchEmptyView.scenario`).
   */
  showScenario(scenario: CYLPlaceholderScenario): void {
    this.text = '';
    this.detailText = undefined;
    this.buttonTitle = undefined;
    this.buttonAction = undefined;
    this.placeholder = CYLPlaceholderStackViewModel.initWithScenario(scenario);
    this.revision += 1;
    this.isShowing = true;
  }

  /**
   * The one place that builds the placeholder of an empty view with texts of your own (iOS `CYLSearchEmptyView.message`):
   * the bundled "no results" animation with `text` as its title, a hint with `detailText`, and an outlined button that
   * calls `buttonAction`.
   */
  static message(text: string, detailText?: string, buttonTitle?: string,
    buttonAction?: () => void): CYLPlaceholderStackViewModel {
    const components: CYLPlaceholderComponent[] = [CYLPlaceholderComponent.componentWithBundledAnimation(
      'CYLPlaceholderNoResults.json', CYLPlaceholderStyle.NoResults, text, 96, null)];
    if (detailText !== undefined && detailText.length > 0) {
      components.push(CYLPlaceholderComponent.hintComponentWithText(detailText));
    }
    if (buttonTitle !== undefined && buttonTitle.length > 0) {
      components.push(CYLPlaceholderComponent.buttonComponentWithTitle(buttonTitle, CYLPlaceholderButtonStyle.Outlined,
        CYLPlaceholderActions.Retry));
    }
    const model = CYLPlaceholderStackViewModel.initWithComponents(components, null);
    model.setHandler((_: CYLPlaceholderStackViewModel, __: string) => {
      buttonAction?.();
    }, CYLPlaceholderActions.Retry);
    return model;
  }

  /**
   * Hides the empty view.
   */
  hide(): void {
    this.isShowing = false;
  }
}

/**
 * Supplies the search results of a `CYLSearchView` and the text of their rows (iOS `CYLSearchViewDataSource`, was
 * `CYLSearchResultsDataSource`).
 */
export interface CYLSearchViewDataSource {
  /**
   * The results for a query that is not empty (iOS `-searchView:resultsForQuery:`).
   */
  searchViewResultsForQuery: (searchView: CYLSearchView, query: string) => Object[];
  /**
   * The text a result shows in its row (iOS `-searchView:configureResultCell:withResult:`).
   */
  searchViewConfigureResultCell: (searchView: CYLSearchView, result: Object) => string;
}

/**
 * A search page that opens over its host (iOS `CYLSearchView`): a `CYLSearchBarView` at the top, a divider, then the
 * suggestions as a list or as tags, the cached queries first, the results of `resultsDataSource` while a query is
 * typed, CYLTableViewPlaceHolder's placeholders for an empty cache and for no results, and pull to refresh on the
 * results (`refreshHandler`; the static methods give another scroller the same refresh). This class is the page's
 * state and API; `CYLSearchComponent` draws it.
 *
 * Core behavior rule 1: focusing the field alone changes nothing below the search bar; that area changes only when
 * the text or the data changes.
 */
@ObservedV2
export class CYLSearchView {
  /**
   * The UI context of the component that draws it, set by that component; animations use it.
   */
  uiContext: UIContext | undefined = undefined;
  /**
   * Receives the events of the search view.
   */
  delegate: CYLSearchViewDelegate | undefined = undefined;
  /**
   * The search bar at the top. Style it directly (placeholder, colors, icons, keyboard, voice button, items).
   */
  readonly searchBarView: CYLSearchBarView = new CYLSearchBarView();
  /**
   * How the suggestions are shown: tags (the default, folded to `suggestionsFoldedRowCount` rows with the fold control
   * as the last tag) or a list.
   */
  @Trace suggestionStyle: CYLSearchSuggestionStyle = CYLSearchSuggestionStyle.tags;
  /**
   * The tag list of the suggestions (iOS `suggestionsTagView`): CollectionViewClassifyMenu's `CYLTagListState`, drawn by
   * its `CYLTagListView`. Style it, or read its folding.
   */
  readonly suggestionsTagView: CYLTagListState = new CYLTagListState(new CYLTagFoldControl(CYLTagFoldPosition.tail,
    CYLTagFoldContent.icon));
  /**
   * The height the tag list needs (it reports it when the tags or the folding change).
   */
  @Trace suggestionTagsHeight: number = 0;
  /**
   * Shows CYLTableViewPlaceHolder's placeholder for `emptyResultsScenario` under the search bar while a non-empty
   * query matches no suggestion, or gives no result of `resultsDataSource`. False by default.
   */
  @Trace showsEmptyResultsPlaceholder: boolean = false;
  /**
   * The color of the line under the search bar; undefined uses the system divider color.
   */
  @Trace dividerColor: ResourceColor | undefined = undefined;
  /**
   * A view of yours shown under the divider, behind the suggestions: a results list, a history.
   */
  @Trace contentView: WrappedBuilder<[]> | undefined = undefined;
  /**
   * True while a tag list (a drag of a tag or a smear selection) has a gesture active, the mini program's content page lock. The
   * core's own scrollers hold while it is true; a host scroller in `contentView` binds `enableScrollInteraction(!searchView.tagGestureActive)`.
   */
  @Trace tagGestureActive: boolean = false;
  /**
   * The color of the one overlay under the bar while the query is empty and no launch view covers it; a tap on it ends
   * the search (iOS `scrimColor`). Undefined draws none.
   */
  @Trace scrimColor: ResourceColor | undefined = undefined;
  /**
   * The page background; undefined uses the system background.
   */
  @Trace backgroundColor: ResourceColor | undefined = undefined;
  /**
   * Decides whether a suggestion matches the query. Undefined uses a case-insensitive "contains" test.
   */
  suggestionFilter: ((suggestion: string, query: string) => boolean) | undefined = undefined;
  /**
   * The suggestions that match the current query: cached queries first, then `suggestions`, without repeats.
   */
  @Trace filteredSuggestions: string[] = [];
  /**
   * The icon before each suggestion; undefined shows none. A magnifier by default.
   */
  @Trace suggestionImage: Resource | undefined = $r('sys.symbol.magnifyingglass');
  /**
   * The tint of `suggestionImage`; undefined uses the secondary text color.
   */
  @Trace suggestionImageTintColor: ResourceColor | undefined = undefined;
  /**
   * The background of the suggestion rows; undefined keeps the page background.
   */
  @Trace suggestionBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The color of the suggestion text; undefined uses the primary text color.
   */
  @Trace suggestionTextColor: ResourceColor | undefined = undefined;
  /**
   * How a long suggestion is cut. `TextOverflow.None` (whole text, wrapped) by default.
   */
  @Trace suggestionLineBreakMode: TextOverflow = TextOverflow.None;
  /**
   * Submits a suggestion as soon as it is tapped. False by default: the field shows it and waits.
   */
  submitsOnSuggestionSelection: boolean = false;
  /**
   * Draws each suggestion row yourself, from the suggestion and its index (iOS `suggestionCellConfiguration`).
   */
  @Trace suggestionCellConfiguration: WrappedBuilder<[string, number]> | undefined = undefined;
  /**
   * The cache in use: the built-in store of `suggestionCachePolicy`, or a store of yours (set it after the policy).
   */
  suggestionCache: CYLSearchSuggestionCache | undefined = undefined;
  /**
   * The title of the header above the cached queries ("Recent searches").
   */
  @Trace suggestionCacheTitle: ResourceStr = $r('app.string.cyl_search_recent');
  /**
   * Shows a placeholder while the query is empty and there is nothing to list. True by default.
   */
  @Trace showsEmptySuggestionsPlaceholder: boolean = true;
  /**
   * Focuses the search field when the search opens, which raises the keyboard. True by default. False opens the
   * search with the suggestion list only; the field is focused when the user taps it.
   */
  focusesSearchFieldOnShow: boolean = true;
  /**
   * Shows the header above the cached queries (the title and the trash button; iOS `showsSuggestionCacheHeader`). True
   * by default. False takes it away, for a host that clears the history with its own control that calls
   * `clearSuggestionCache()`.
   */
  @Trace showsSuggestionCacheHeader: boolean = true;
  /**
   * The length of the open and close animations, in seconds. 0.25 by default.
   */
  animationDuration: number = 0.25;
  /**
   * Closes the search view after a submitted query that the delegate did not handle. True by default.
   */
  closesOnSubmit: boolean = true;
  /**
   * Whether the list currently shows cached queries (it then has the "Recent searches" header).
   */
  @Trace showsCachedQueries: boolean = false;
  /**
   * The text of the empty view while a query has no result (iOS `noResultsText`); undefined shows none. The core shows
   * and hides the empty view itself.
   */
  @Trace noResultsText: string | undefined = undefined;
  /**
   * Titles the results: while results show, a header above the first row says what this closure returns for the query
   * (a footnote in `resultsHeaderTextColor`, read as a header by screen readers); undefined from the closure, or no
   * closure (the default), shows none (iOS `resultsHeaderTitleProvider`).
   */
  @Trace resultsHeaderTitleProvider: ((query: string) => string | undefined) | undefined = undefined;
  /**
   * The color of the results header text; undefined (the default) is the secondary font color (iOS
   * `resultsHeaderTextColor`).
   */
  @Trace resultsHeaderTextColor: ResourceColor | undefined = undefined;
  /**
   * A text button under the cached queries and the suggestions of the list style that clears the cache, with this title.
   * Undefined (the default) shows none; with it, set `showsSuggestionCacheHeader` to false to have the text button
   * instead of the trash icon (iOS `suggestionCacheFooterTitle`).
   */
  @Trace suggestionCacheFooterTitle: ResourceStr | undefined = undefined;
  /**
   * Draws the first match of the query in each result row in `resultMatchHighlightColor`, ignoring case and accents
   * (iOS `highlightsResultMatches`). False by default. Rows of `resultCellConfiguration` are yours to draw.
   */
  @Trace highlightsResultMatches: boolean = false;
  /**
   * The color of a highlighted match; undefined uses the tint color (the system brand color).
   */
  @Trace resultMatchHighlightColor: ResourceColor | undefined = undefined;
  /**
   * Whether a swipe from the left edge ends the search (iOS `supportsSwipeToDismissSearch`). False by default. The system
   * back gesture and the Back key end the search through `handleBackPress` whatever this is.
   */
  @Trace supportsSwipeToDismissSearch: boolean = false;
  /**
   * Draws a result as your own view, such as a text with the match highlighted; it is given the result and its index.
   * Without it a result is the text of `searchViewConfigureResultCell`.
   */
  @Trace resultCellConfiguration: WrappedBuilder<[CYLSearchView, Object, number]> | undefined = undefined;
  /**
   * Counts the submitted queries that went into the history; a component that draws the history reads it, so it is read
   * again (iOS `historyDidChangeNotification`).
   */
  @Trace historyRevision: number = 0;
  /**
   * The empty view (iOS `showEmptyView`): "No matching results" in the results.
   */
  readonly emptyView: CYLSearchEmptyView = new CYLSearchEmptyView();

  /**
   * The scroller of the results list (iOS `resultsTableView`): scroll it, or pass it to the static refresh methods.
   */
  readonly resultsTableView: Scroller = new Scroller();

  @Trace private open: boolean = false;
  @Trace private launchViewStorage: WrappedBuilder<[CYLSearchView]> | undefined = undefined;
  @Trace private suggestionsLaunch: boolean = false;
  private foldControlStorage: CYLMenuFoldControl = new CYLMenuFoldControl();
  private foldedRowCountStorage: number = 2;
  private lastTagTitles: string = '';
  private generation: number = 0;
  @Trace private resultsScenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoSearchResults;
  @Trace private suggestionsScenario: CYLPlaceholderScenario = CYLPlaceholderScenario.NoContent;
  @Trace private results: Object[] = [];
  @Trace private dataSource: CYLSearchViewDataSource | undefined = undefined;
  @Trace private refreshAction: (() => void) | undefined = undefined;
  @Trace private suggestionsShown: boolean = true;
  @Trace private allSuggestions: string[] = [];
  @Trace private showsAllForEmptyQuery: boolean = false;
  private cachePolicy: CYLSearchSuggestionCachePolicy = CYLSearchSuggestionCachePolicy.database;
  private cacheName: string = 'CYLSearchView';
  private context: common.Context | undefined = undefined;
  private emptyResults: CYLPlaceholderStackViewModel | undefined = undefined;
  private emptySuggestions: CYLPlaceholderStackViewModel | undefined = undefined;

  /**
   * A closed search view with the default look (iOS `-initWithFrame:`).
   */
  constructor() {
    this.searchBarView.navigationIcon = CYLSearchBarNavigationIcon.arrow;
    const barDelegate: CYLSearchBarViewDelegate = {
      searchBarViewTextDidChange: (_: CYLSearchBarView, text: string) => {
        this.queryChanged(text);
      },
      searchBarViewSearchButtonClicked: (_: CYLSearchBarView) => {
        this.submitted();
      },
      searchBarViewDidBeginEditing: (_: CYLSearchBarView) => {
        this.delegate?.searchViewDidChangeFocus?.(this, true);
      },
      searchBarViewDidEndEditing: (_: CYLSearchBarView) => {
        this.delegate?.searchViewDidChangeFocus?.(this, false);
      },
      searchBarViewVoiceButtonClicked: (_: CYLSearchBarView) => {
        this.delegate?.searchViewVoiceButtonClicked?.(this);
      },
      searchBarViewCancelButtonClicked: (_: CYLSearchBarView) => {
        // Cancel ends the search (iOS `UISearchController`).
        this.closeSearch(true);
      },
      searchBarViewNavigationButtonClicked: (_: CYLSearchBarView) => {
        if (this.delegate?.searchViewNavigationButtonClicked !== undefined) {
          this.delegate.searchViewNavigationButtonClicked(this);
        } else {
          this.closeSearch(true);
        }
      }
    };
    this.searchBarView.delegate = barDelegate;
    this.configureSuggestionsTagView();
    // One history signal: the view follows every change of its history, from any view of the same policy and name.
    const weak = new WeakRef<CYLSearchView>(this);
    CYLSearchResources.observeHistory(() => weak.deref()?.suggestionCache, () => {
      weak.deref()?.historyChanged();
    }, () => weak.deref() !== undefined);
  }

  // The suggestion area's tags are CollectionViewClassifyMenu's tag list: no section header, nothing selected, the
  // content as tall as the tags, a tapped tag chooses its suggestion (iOS `CYLSearchSuggestionArea`).
  private configureSuggestionsTagView(): void {
    const list = this.suggestionsTagView;
    list.showsSectionHeaders = false;
    list.selectionMode = CYLMenuSelectionMode.none;
    list.isScrollEnabled = false;
    list.defaultVisibleRows = this.foldedRowCountStorage;
    const delegate: CYLMenuDelegate = {
      menuDidChangeContentHeight: (_: Object, height: number) => {
        this.suggestionTagsHeight = height;
      }
    };
    list.menuDelegate = delegate;
    list.tagClickHandler = (index: number, _: CYLTag) => {
      const suggestion = this.filteredSuggestions[index];
      if (suggestion !== undefined) {
        this.suggestionSelected(suggestion, index);
      }
    };
  }

  /**
   * The history changed (the signal of `CYLSearchResources.observeHistory`): a component that draws it reads it again.
   */
  historyChanged(): void {
    this.historyRevision += 1;
    this.refilter();
  }

  /**
   * The fold control of the tag suggestions; the last tag, an icon, by default. Deprecated type: it maps onto
   * CollectionViewClassifyMenu's `CYLMenuFoldControl` of `suggestionsTagView.foldControl` (`inline` is `tail`,
   * `bottom` is `footer`), which is the one control that is drawn.
   */
  get suggestionsFoldControl(): CYLMenuFoldControl {
    return this.foldControlStorage;
  }

  set suggestionsFoldControl(value: CYLMenuFoldControl) {
    this.foldControlStorage = value;
    this.suggestionsTagView.foldControl = cylTagFoldControl(value);
  }

  /**
   * The rows of tag suggestions shown while folded. 2 by default; 0 shows every row.
   */
  get suggestionsFoldedRowCount(): number {
    return this.foldedRowCountStorage;
  }

  set suggestionsFoldedRowCount(value: number) {
    this.foldedRowCountStorage = value;
    this.suggestionsTagView.defaultVisibleRows = value;
  }

  /**
   * Whether the tag suggestions are folded; the fold control of the tag list changes it.
   */
  get suggestionsFolded(): boolean {
    return !this.suggestionsTagView.isSectionExpanded(0);
  }

  set suggestionsFolded(value: boolean) {
    this.suggestionsTagView.setExpanded(!value, 0, true);
  }

  /**
   * A view of yours under the bar while the query is empty (iOS `launchView`). It is given this search view. Setting
   * one turns `showsSuggestionsLaunchView` off.
   */
  get launchView(): WrappedBuilder<[CYLSearchView]> | undefined {
    return this.launchViewStorage;
  }

  set launchView(value: WrappedBuilder<[CYLSearchView]> | undefined) {
    this.launchViewStorage = value;
    if (value !== undefined) {
      this.suggestionsLaunch = false;
    }
  }

  /**
   * Whether the core's own launch content shows while the query is empty (iOS `showsSuggestionsLaunchView`): the
   * suggestion area, with the history under its header, else `suggestions`, as tags of the tag list folded to
   * `suggestionsFoldedRowCount` rows with the fold control last. False by default. True replaces a custom `launchView`.
   */
  get showsSuggestionsLaunchView(): boolean {
    return this.suggestionsLaunch;
  }

  set showsSuggestionsLaunchView(value: boolean) {
    this.suggestionsLaunch = value;
    if (value) {
      this.launchViewStorage = undefined;
      this.showsAllForEmptyQuery = true;
      this.refilter();
    }
  }

  /**
   * The same overlay as `scrimColor` (iOS `dimmingColor` forwards to it).
   * @deprecated Use `scrimColor`.
   */
  get dimmingColor(): ResourceColor | undefined {
    return this.scrimColor;
  }

  set dimmingColor(value: ResourceColor | undefined) {
    this.scrimColor = value;
  }

  /**
   * The suggestions to filter as the text changes.
   */
  get suggestions(): string[] {
    return this.allSuggestions;
  }

  set suggestions(value: string[]) {
    this.allSuggestions = value;
    this.refilter();
  }

  /**
   * Lists every suggestion while the query is empty. False by default.
   */
  get showsSuggestionsForEmptyQuery(): boolean {
    return this.showsAllForEmptyQuery;
  }

  set showsSuggestionsForEmptyQuery(value: boolean) {
    this.showsAllForEmptyQuery = value;
    this.refilter();
  }

  /**
   * Where submitted queries are cached for the suggestion list. `database` by default.
   */
  get suggestionCachePolicy(): CYLSearchSuggestionCachePolicy {
    return this.cachePolicy;
  }

  set suggestionCachePolicy(value: CYLSearchSuggestionCachePolicy) {
    this.cachePolicy = value;
    this.rebuildCache();
  }

  /**
   * Separates the caches of different search screens. "CYLSearchView" by default.
   */
  get suggestionCacheName(): string {
    return this.cacheName;
  }

  set suggestionCacheName(value: string) {
    this.cacheName = value;
    this.rebuildCache();
  }

  /**
   * The CYLTableViewPlaceHolder scenario of the empty results placeholder. `NoSearchResults` by default. Setting it
   * drops the placeholder made for the old scenario.
   */
  get emptyResultsScenario(): CYLPlaceholderScenario {
    return this.resultsScenario;
  }

  set emptyResultsScenario(value: CYLPlaceholderScenario) {
    this.resultsScenario = value;
    this.emptyResults = undefined;
    this.refilter();
  }

  /**
   * The CYLTableViewPlaceHolder scenario of the empty suggestions placeholder. `NoContent` by default; setting it
   * drops the old placeholder.
   */
  get emptySuggestionsScenario(): CYLPlaceholderScenario {
    return this.suggestionsScenario;
  }

  set emptySuggestionsScenario(value: CYLPlaceholderScenario) {
    this.suggestionsScenario = value;
    this.emptySuggestions = undefined;
    this.refilter();
  }

  /**
   * CYLTableViewPlaceHolder's placeholder shown for empty results, created the first time it is needed; undefined
   * before. Style it after it appears, or change `emptyResultsScenario`.
   */
  get emptyResultsView(): CYLPlaceholderStackViewModel | undefined {
    return this.emptyResults;
  }

  /**
   * CYLTableViewPlaceHolder's placeholder shown for an empty cache, created the first time it is needed; undefined
   * before.
   */
  get emptySuggestionsView(): CYLPlaceholderStackViewModel | undefined {
    return this.emptySuggestions;
  }

  /**
   * Supplies the results shown while a query is typed (iOS `resultsDataSource`); undefined shows the suggestions
   * only. Setting it queries it for the current query.
   */
  get resultsDataSource(): CYLSearchViewDataSource | undefined {
    return this.dataSource;
  }

  set resultsDataSource(value: CYLSearchViewDataSource | undefined) {
    this.dataSource = value;
    this.reloadResults();
  }

  /**
   * The results of `resultsDataSource` for the current query; empty while the query is empty (iOS `searchResults`).
   */
  get searchResults(): Object[] {
    return this.results;
  }

  /**
   * True while the area below the bar shows the results: `resultsDataSource` is set and the query is not empty.
   */
  get showsResults(): boolean {
    return this.dataSource !== undefined && this.query.trim().length > 0;
  }

  /**
   * The title of the header over the results now (`resultsHeaderTitleProvider`), or undefined for none.
   */
  get resultsHeaderTitle(): string | undefined {
    return cylSearchResultsHeaderTitle(this.showsResults, this.resultsHeaderTitleProvider, this.query);
  }

  /**
   * Keeps the bar of `table`, a search bar that is the header of a list, scrollable out of sight above a short list and
   * settles it fully shown or fully hidden when scrolling stops, while this search view is not open (what
   * `CYLSearchController.snapsHeaderSearchBar` does for its bar, issues 1160 and 1207; iOS `setSnapsHeader(_:for:in:)`).
   * `snaps` false takes the settling away. A list keeps one such handling, which a second call updates.
   */
  setSnapsHeader(snaps: boolean, table: CYLSearchTableView): void {
    table.snapsHeaderSearchBar = snaps;
    table.snapsOwner = this;
  }

  /**
   * Called when the results list is pulled down (iOS `refreshHandler`): set, it adds CYLTableViewPlaceHolder's pull to
   * refresh (its normal header) to the results; undefined removes it. Call `endRefreshing()` on every completion path.
   */
  get refreshHandler(): (() => void) | undefined {
    return this.refreshAction;
  }

  set refreshHandler(value: (() => void) | undefined) {
    this.refreshAction = value;
    CYLSearchView.setRefreshHandler(value, this.resultsTableView);
  }

  /**
   * True while the results list refreshes (iOS `isRefreshing`).
   */
  get isRefreshing(): boolean {
    return CYLSearchView.isRefreshingIn(this.resultsTableView);
  }

  /**
   * True while the search view is open (iOS `searchOpen`).
   */
  get isSearchOpen(): boolean {
    return this.open;
  }

  /**
   * Whether the search is active, that is open (iOS `isActive`).
   */
  get isActive(): boolean {
    return this.open;
  }

  /**
   * Starts or ends the search from code (iOS `setActive(_:animated:)`).
   */
  setActive(active: boolean, animated: boolean): void {
    if (active) {
      this.showSearch(animated);
    } else {
      this.closeSearch(animated);
    }
  }

  /**
   * The submitted queries (iOS `historyStore`); the same store as `suggestionCache`, shared with a launch view.
   */
  get historyStore(): CYLSearchSuggestionCache | undefined {
    return this.suggestionCache;
  }

  set historyStore(value: CYLSearchSuggestionCache | undefined) {
    this.suggestionCache = value;
    this.historyChanged();
  }

  /**
   * Shows the empty view in the results, such as "No matching results" (iOS `showEmptyView`). Nothing is shown while
   * the query is empty.
   */
  showEmptyView(text: string, detailText?: string, buttonTitle?: string, buttonAction?: () => void): void {
    if (this.query.trim().length === 0) {
      return;
    }
    this.emptyView.show(text, detailText, buttonTitle, buttonAction);
  }

  /**
   * Shows one of CYLTableViewPlaceHolder's scenarios as the empty view in the results (iOS `showEmptyView(scenario:)`).
   * Nothing is shown while the query is empty.
   */
  showEmptyViewScenario(scenario: CYLPlaceholderScenario): void {
    if (this.query.trim().length === 0) {
      return;
    }
    this.emptyView.showScenario(scenario);
  }

  /**
   * Hides the empty view (iOS `hideEmptyView()`).
   */
  hideEmptyView(): void {
    this.emptyView.hide();
  }

  /**
   * Whether the empty view shows now (iOS `isEmptyViewShowing`).
   */
  get isEmptyViewShowing(): boolean {
    return cylSearchEmptyViewShown(this.emptyView.isShowing, this.query);
  }

  /**
   * Whether a custom launch view shows now: there is one and the query is empty.
   */
  get showsLaunchView(): boolean {
    return cylSearchLaunchViewShown(this.launchView !== undefined, this.query);
  }

  /**
   * Whether the scrim shows now: a `scrimColor` is set, the query is empty and no launch view (a custom one, or the
   * suggestion area with `showsSuggestionsLaunchView`) covers it.
   */
  get showsDimming(): boolean {
    return cylSearchDimmingShown(this.scrimColor !== undefined, this.launchView !== undefined || this.suggestionsLaunch,
      this.query);
  }

  /**
   * The current query.
   */
  get query(): string {
    return this.searchBarView.text;
  }

  set query(value: string) {
    this.setQuery(value, false);
  }

  /**
   * True while the suggestions are listed (`showSuggestions` / `dismissSuggestions`).
   */
  get suggestionsVisible(): boolean {
    return this.suggestionsShown;
  }

  /**
   * True while the query is not empty, nothing matches it (no result of `resultsDataSource`, or no suggestion
   * without one) and the empty results placeholder is on.
   */
  get showsEmptyResults(): boolean {
    if (!this.showsEmptyResultsPlaceholder || this.query.trim().length === 0) {
      return false;
    }
    if (this.dataSource !== undefined) {
      return this.results.length === 0;
    }
    return this.suggestionsShown && this.filteredSuggestions.length === 0;
  }

  /**
   * True while the query is empty, there is nothing to list and the empty suggestions placeholder is on.
   */
  get showsEmptySuggestions(): boolean {
    return this.suggestionsShown && this.showsEmptySuggestionsPlaceholder && this.query.trim().length === 0 &&
      this.filteredSuggestions.length === 0 && this.suggestionCache !== undefined;
  }

  /**
   * Gives the search view the app's context (for the suggestion cache) without opening it (iOS `-installInView:`).
   * Put a `CYLSearchComponent` for this search view over the page it covers.
   */
  installInView(context: common.Context): void {
    if (this.context === context) {
      return;
    }
    this.context = context;
    this.rebuildCache();
  }

  /**
   * Installs the search view with the context of the page when it has none yet, then opens it (iOS
   * `-showSearchInViewController:animated:`, was `CYLSearchController.showInViewController`).
   */
  showSearchIn(context: common.Context, animated: boolean = true): void {
    if (this.context !== context) {
      this.installInView(context);
    }
    this.showSearch(animated);
  }

  /**
   * Opens the search view and, with `focusesSearchFieldOnShow`, starts editing (iOS `-showSearch:`).
   */
  showSearch(animated: boolean = true): void {
    if (this.open) {
      // Already open: only the field is focused again (Android `showSearch`).
      if (this.focusesSearchFieldOnShow) {
        this.searchBarView.showKeyboard();
      }
      return;
    }
    this.delegate?.searchViewWillShow?.(this);
    const generation = ++this.generation;
    this.searchBarView.hostIsActive = true;
    this.refilter();
    if (animated && this.animationDuration > 0) {
      // The delegate hears of it when the animation ends, as on Android; a close that began since has the last word.
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseOut, onFinish: () => {
        if (generation === this.generation) {
          this.delegate?.searchViewDidShow?.(this);
        }
      } }, () => {
        this.open = true;
      });
    } else {
      this.open = true;
      this.delegate?.searchViewDidShow?.(this);
    }
    // The first activation reports the text, "" included (iOS `updateResultsFor`).
    this.delegate?.searchViewUpdateResults?.(this, this.query);
    if (this.focusesSearchFieldOnShow) {
      // The field exists once the open state is drawn.
      setTimeout(() => {
        this.searchBarView.showKeyboard();
      }, 0);
    }
  }

  /**
   * Closes the search view and ends editing (iOS `-closeSearch:completion:`, was `CYLSearchController.hide`).
   * `completion` runs once it is closed, also when it was not open.
   */
  closeSearch(animated: boolean = true, completion?: () => void): void {
    if (!this.open) {
      completion?.();
      return;
    }
    this.delegate?.searchViewWillClose?.(this);
    const generation = ++this.generation;
    this.searchBarView.hostIsActive = false;
    this.emptyView.hide();
    this.searchBarView.hideKeyboard();
    if (animated && this.animationDuration > 0) {
      // A show that began since has the last word: the finished close is not reported as a close.
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseIn, onFinish: () => {
        if (generation === this.generation) {
          this.delegate?.searchViewDidClose?.(this);
        }
        completion?.();
      } }, () => {
        this.open = false;
      });
    } else {
      this.open = false;
      this.delegate?.searchViewDidClose?.(this);
      completion?.();
    }
  }

  /**
   * Queries `resultsDataSource` for the current query and shows its results (iOS `-reloadResults`, was
   * `reloadSearchResults` and `reloadResultsTableView`). Nothing is asked while the query is empty.
   */
  reloadResults(): void {
    const source = this.dataSource;
    const query = this.query;
    this.results = source !== undefined && query.trim().length > 0 ? source.searchViewResultsForQuery(this, query) :
      [];
    this.updatePlaceholders();
    this.updateNoResultsText();
  }

  // The core shows and hides the empty view for `noResultsText` (iOS `noResultsText`).
  private updateNoResultsText(): void {
    const text = this.noResultsText;
    if (text === undefined) {
      return;
    }
    if (this.showsResults && this.results.length === 0) {
      if (!(this.emptyView.isShowing && this.emptyView.text === text)) {
        this.emptyView.show(text);
      }
    } else if (this.emptyView.isShowing && this.emptyView.text === text) {
      this.emptyView.hide();
    }
  }

  /**
   * Starts refreshing the results list, which calls `refreshHandler` (iOS `-beginRefreshing`).
   */
  beginRefreshing(): void {
    CYLSearchView.beginRefreshingIn(this.resultsTableView);
  }

  /**
   * Stops refreshing the results list (iOS `-endRefreshing`).
   */
  endRefreshing(): void {
    CYLSearchView.endRefreshingIn(this.resultsTableView);
  }

  /**
   * The same pull to refresh on another scroller (iOS `+setRefreshHandler:forScrollView:`); its list is drawn inside
   * a `CYLSearchRefreshComponent` with that scroller. Undefined removes it.
   */
  static setRefreshHandler(handler: (() => void) | undefined, scroller: Scroller): void {
    const scrollView = cylRefreshScrollView(scroller);
    if (handler === undefined) {
      scrollView.cyl_header = null;
      return;
    }
    const header = new CYLRefreshNormalHeaderModel();
    header.refreshingBlock = handler;
    scrollView.cyl_header = header;
  }

  /**
   * Starts refreshing that scroller, which calls its handler (iOS `+beginRefreshingInScrollView:`).
   */
  static beginRefreshingIn(scroller: Scroller): void {
    cylRefreshScrollView(scroller).cyl_header?.beginRefreshing();
  }

  /**
   * Stops refreshing that scroller (iOS `+endRefreshingInScrollView:`).
   */
  static endRefreshingIn(scroller: Scroller): void {
    cylRefreshScrollView(scroller).cyl_header?.endRefreshing();
  }

  /**
   * True while that scroller refreshes (iOS `+isRefreshingInScrollView:`).
   */
  static isRefreshingIn(scroller: Scroller): boolean {
    return cylRefreshScrollView(scroller).cyl_header?.refreshing ?? false;
  }

  /**
   * A result was tapped: the delegate is told.
   */
  resultSelected(result: Object): void {
    this.delegate?.searchViewDidSelectResult?.(this, result);
  }

  /**
   * Closes the open search view for the system Back gesture; true when it did. Call it from the page's
   * `onBackPress()` and return its result (Android `OnBackPressedCallback`; iOS has the back button only).
   */
  handleBackPress(): boolean {
    if (!this.open) {
      return false;
    }
    this.closeSearch(true);
    return true;
  }

  /**
   * The state to keep across a restart: whether the search view is open and its query.
   */
  encodeRestorableState(): Record<string, Object> {
    const state: Record<string, Object> = { 'open': this.open, 'query': this.query };
    return state;
  }

  /**
   * Restores the query and reopens the search view when it was open.
   */
  decodeRestorableState(state: Record<string, Object>): void {
    this.setQuery((state['query'] as string | undefined) ?? '', false);
    if ((state['open'] as boolean | undefined) ?? false) {
      this.showSearch(false);
    }
  }

  /**
   * The back gesture or key: closes an open search view and returns true (iOS `-accessibilityPerformEscape`).
   */
  accessibilityPerformEscape(): boolean {
    if (!this.open) {
      return false;
    }
    this.closeSearch(true);
    return true;
  }

  /**
   * A click handler that opens the search view, for a menu item or a button (iOS `-attachToBarButtonItem:`).
   */
  attachToMenuItem(): () => void {
    return () => {
      this.showSearch(true);
    };
  }

  /**
   * Sets the query and submits it when `submit` is true (iOS `-setQuery:submit:`).
   */
  setQuery(text: string | undefined, submit: boolean): void {
    // As on Android: the text is set silently, the change is reported once, and a submit goes through the bar
    // (`searchBarViewShouldSubmitText`, blank text refused).
    this.searchBarView.setText(text, false);
    this.queryChanged(text ?? '');
    if (submit) {
      this.searchBarView.submit();
    }
  }

  /**
   * Lists the suggestions that match the current query.
   */
  showSuggestions(): void {
    this.refilter();
  }

  /**
   * Hides the suggestions.
   */
  dismissSuggestions(): void {
    this.suggestionsShown = false;
  }

  /**
   * Clears the whole cache, as the trash button of the header does (iOS `-clearSuggestionCache`).
   */
  clearSuggestionCache(): void {
    this.suggestionCache?.removeAllQueries();
    // A built-in cache announced the change; one of your own is announced here.
    CYLSearchResources.announceHistoryChange(this.suggestionCache);
    this.announceForAccessibility('search.recentCleared');
  }

  /**
   * Tells the screen reader the text of `key`, as iOS posts `UIAccessibilityAnnouncementNotification` and Android
   * calls `announceForAccessibility`. Does nothing without a context.
   */
  private announceForAccessibility(key: string): void {
    const context = this.context;
    if (context === undefined) {
      return;
    }
    const eventInfo: accessibility.EventInfo = {
      type: 'announceForAccessibility',
      bundleName: context.applicationInfo.name,
      triggerAction: 'common',
      textAnnouncedForAccessibility: CYLSearchResources.localizedString(context, key)
    };
    accessibility.sendAccessibilityEvent(eventInfo).catch(() => {
      // No screen reader running.
    });
  }

  /**
   * A suggestion was tapped: the field shows it, the delegate is told, and it is submitted with
   * `submitsOnSuggestionSelection`.
   */
  suggestionSelected(suggestion: string, index: number): void {
    // A tag of the launch content (the query is empty) submits, as iOS `CYLSearchController`'s launch view does.
    const fromLaunch = this.suggestionsLaunch && this.query.trim().length === 0;
    // Android `select`: the text is set silently, the delegate is told, then the query is submitted or reported.
    this.searchBarView.setText(suggestion, false);
    this.delegate?.searchViewDidSelectSuggestion?.(this, suggestion, index);
    if (this.submitsOnSuggestionSelection || fromLaunch) {
      this.searchBarView.submit();
    } else {
      this.queryChanged(suggestion);
    }
  }

  private queryChanged(text: string): void {
    this.refilter();
    this.reloadResults();
    this.delegate?.searchViewTextDidChange?.(this, text);
    this.delegate?.searchViewUpdateResults?.(this, text);
  }

  // Every submitted query is cached, so the list shows it the next time (Android `searchBarViewSearchButtonClicked`).
  private submitted(): void {
    const text = this.query;
    if (this.suggestionCache !== undefined) {
      this.suggestionCache.addQuery(text);
      // The history changed: the signal (built-in caches announce themselves) makes every view of it, this one
      // included, read it again (iOS `historyDidChangeNotification`).
      CYLSearchResources.announceHistoryChange(this.suggestionCache);
      this.delegate?.searchViewHistoryDidChange?.(this, text);
    }
    const handled = this.delegate?.searchViewDidSubmitText?.(this, text) ?? false;
    if (!handled && this.closesOnSubmit) {
      this.closeSearch(true);
    } else {
      this.dismissSuggestions();
    }
  }

  private rebuildCache(): void {
    if (this.context === undefined) {
      return;
    }
    // The database is read in the background: its queries are data that changed, so the list shows them.
    const cache = CYLSearchResources.suggestionCache(this.context, this.cachePolicy, this.cacheName, () => {
      if (this.suggestionCache === cache) {
        this.refilter();
      }
    });
    this.suggestionCache = cache;
    this.refilter();
  }

  // The custom filter, or the folded match (Android `matches`).
  private matches(suggestion: string, query: string): boolean {
    if (this.suggestionFilter !== undefined) {
      return this.suggestionFilter(suggestion, query);
    }
    return cylSuggestionMatches(suggestion, query);
  }

  private refilter(): void {
    const cached = this.suggestionCache?.cachedQueries() ?? [];
    this.suggestionsShown = true;
    const filtered: CYLSearchFilterResult = cylFilterSuggestions(this.query, cached, this.allSuggestions,
      this.showsAllForEmptyQuery, (suggestion: string, query: string) => this.matches(suggestion, query));
    this.showsCachedQueries = filtered.showsCachedQueries;
    this.filteredSuggestions = filtered.suggestions;
    const titles = JSON.stringify(filtered.suggestions);
    if (titles !== this.lastTagTitles) {
      this.lastTagTitles = titles;
      this.suggestionsTagView.setTagsWithTitles(filtered.suggestions);
    }
    this.updatePlaceholders();
  }

  // CYLTableViewPlaceHolder's placeholders are made the first time they are shown (iOS `CYLPlaceholderStackView`).
  private updatePlaceholders(): void {
    if (this.showsEmptyResults && this.emptyResults === undefined) {
      this.emptyResults = CYLPlaceholderStackViewModel.initWithScenario(this.resultsScenario);
    }
    if (this.showsEmptySuggestions && this.emptySuggestions === undefined) {
      this.emptySuggestions = CYLPlaceholderStackViewModel.initWithScenario(this.suggestionsScenario);
    }
  }
}

/**
 * Draws CYLTableViewPlaceHolder's placeholder (its V1 component `CYLPlaceholderStackView`, which links an `@Observed`
 * model) inside the V2 components of this file: the model is held as V1 state, then linked.
 */
@Component
struct CYLSearchPlaceholderHost {
  /**
   * The placeholder to draw.
   */
  @State model: CYLPlaceholderStackViewModel = CYLPlaceholderStackViewModel.initWithScenario(
    CYLPlaceholderScenario.NoContent);

  build() {
    CYLPlaceholderStackView({ model: this.model })
  }
}

/**
 * Draws a `CYLSearchEmptyView` (iOS: the one placeholder of every empty view): its placeholder, centered, made new for
 * each `show`.
 */
@ComponentV2
struct CYLSearchEmptyViewComponent {
  /**
   * The content to draw.
   */
  @Require @Param content: CYLSearchEmptyView;

  build() {
    Column() {
      if (this.content.placeholder !== undefined) {
        ForEach([this.content.revision], (_: number) => {
          CYLSearchPlaceholderHost({ model: this.content.placeholder as CYLPlaceholderStackViewModel })
        }, (revision: number) => `${revision}`)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .id('CYLSearchEmptyView')
  }
}

/**
 * Draws a `CYLSearchView` over the page it is placed on: nothing while it is closed; the search bar, the divider and
 * the suggestions while it is open. The search bar sits at the top of the safe area and covers no view of the page
 * behind it: the page under it is hidden by the search page's own background.
 */
@ComponentV2
export struct CYLSearchComponent {
  /**
   * The search view to draw.
   */
  @Require @Param searchView: CYLSearchView;
  // The part of the area under the search bar that the keyboard covers (vp): the placeholders and suggestions end
  // above the keyboard, whatever keyboard mode the app's window uses (iOS insets the scroll view for the keyboard).
  @Local keyboardInset: number = 0;
  private pageWidth: number = 0;
  private swipeBegan: boolean = false;
  private keyboardHeight: number = 0;
  private contentBottom: number = 0;
  private hostWindow: window.Window | undefined = undefined;
  private keyboardListener: (height: number) => void = (height: number) => {
    this.keyboardHeight = this.getUIContext().px2vp(height);
    this.updateKeyboardInset();
  };

  private onTagGesture = (active: boolean): void => {
    hilog.info(0x0000, 'testTag', 'tagGestureActive -> %{public}s', String(active));
    this.searchView.tagGestureActive = active;
  };

  aboutToAppear(): void {
    this.searchView.uiContext = this.getUIContext();
    this.searchView.tagGestureActive = CYLMenuGestureState.shared.isActive;
    hilog.info(0x0000, 'testTag', 'search component appeared, tagGestureActive=%{public}s', String(this.searchView.tagGestureActive));
    CYLMenuGestureState.shared.addListener(this.onTagGesture);
    const context = this.getUIContext().getHostContext();
    if (context === undefined) {
      return;
    }
    // The history needs the app's context; a search view opened with `showSearch` has not been given one yet.
    this.searchView.installInView(context);
    window.getLastWindow(context).then((win: window.Window) => {
      this.hostWindow = win;
      win.on('keyboardHeightChange', this.keyboardListener);
    }).catch(() => {
      // No window: the content keeps its full height.
    });
  }

  aboutToDisappear(): void {
    CYLMenuGestureState.shared.removeListener(this.onTagGesture);
    this.searchView.tagGestureActive = false;
    try {
      this.hostWindow?.off('keyboardHeightChange', this.keyboardListener);
    } catch (error) {
      // Already gone with its window.
    }
  }

  // The keyboard rises from the bottom of the screen: only the part above the content's bottom edge covers it.
  private updateKeyboardInset(): void {
    if (this.keyboardHeight <= 0 || this.contentBottom <= 0) {
      this.keyboardInset = 0;
      return;
    }
    let screenHeight = 0;
    try {
      screenHeight = this.getUIContext().px2vp(display.getDefaultDisplaySync().height);
    } catch (error) {
      this.keyboardInset = 0;
      return;
    }
    this.keyboardInset = Math.max(0, this.keyboardHeight - (screenHeight - this.contentBottom));
  }

  private rowHeight(): number {
    return 44;
  }

  @Builder
  cacheHeader() {
    Row() {
      Text(this.searchView.suggestionCacheTitle)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.font_secondary'))
        .layoutWeight(1)
      Row() {
        SymbolGlyph($r('sys.symbol.trash'))
          .fontSize(20)
          .fontColor([$r('sys.color.font_secondary')])
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .accessibilityGroup(true)
      .accessibilityText($r('app.string.cyl_search_clearRecent'))
      .onClick(() => {
        this.searchView.clearSuggestionCache();
      })
    }
    .width('100%')
    .padding({ left: 16, right: 4 })
  }

  @Builder
  suggestionRow(suggestion: string, index: number) {
    Row({ space: 12 }) {
      if (this.searchView.suggestionImage !== undefined) {
        SymbolGlyph(this.searchView.suggestionImage)
          .fontSize(18)
          .fontColor([this.searchView.suggestionImageTintColor ?? $r('sys.color.font_secondary')])
          .accessibilityLevel('no')
      }
      Text(suggestion)
        .fontSize(17)
        .fontColor(this.searchView.suggestionTextColor ?? $r('sys.color.font_primary'))
        .textOverflow({ overflow: this.searchView.suggestionLineBreakMode })
        .maxLines(this.searchView.suggestionLineBreakMode === TextOverflow.None ? 10 : 1)
        .layoutWeight(1)
    }
    .width('100%')
    .constraintSize({ minHeight: this.rowHeight() })
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
    .backgroundColor(this.searchView.suggestionBackgroundColor ?? Color.Transparent)
    .onClick(() => {
      this.searchView.suggestionSelected(suggestion, index);
    })
  }

  @Builder
  suggestionList() {
    List() {
      ForEach(this.searchView.filteredSuggestions, (suggestion: string, index: number) => {
        ListItem() {
          if (this.searchView.suggestionCellConfiguration !== undefined) {
            Row() {
              this.searchView.suggestionCellConfiguration.builder(suggestion, index)
            }
            .width('100%')
            // A cell of yours is read as one element with the suggestion as its label.
            .accessibilityGroup(true)
            .accessibilityText(suggestion)
            .onClick(() => {
              this.searchView.suggestionSelected(suggestion, index);
            })
          } else {
            this.suggestionRow(suggestion, index)
          }
        }
      }, (suggestion: string, index: number) => `${index}-${suggestion}`)
      if (this.searchView.suggestionCacheFooterTitle !== undefined) {
        ListItem() {
          Row() {
            Button(this.searchView.suggestionCacheFooterTitle, { type: ButtonType.Normal, stateEffect: true })
              .id('CYLSearchSuggestionCacheFooterButton')
              .fontSize(13)
              .fontColor($r('sys.color.font_primary'))
              .backgroundColor(Color.Transparent)
              .border({ width: 1, color: $r('sys.color.comp_divider'), radius: 4 })
              .padding({ left: 24, right: 24, top: 6, bottom: 6 })
              .onClick(() => {
                this.searchView.clearSuggestionCache();
              })
          }
          .width('100%')
          .height(64)
          .justifyContent(FlexAlign.Center)
        }
      }
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
    .enableScrollInteraction(!this.searchView.tagGestureActive)
    .accessibilityText($r('app.string.cyl_search_suggestions'))
  }

  // The tags of the suggestion area: CollectionViewClassifyMenu's tag list, folded to `suggestionsFoldedRowCount` rows with
  // the fold control as the last tag; its height is what its content needs, and the page scrolls when it is taller.
  @Builder
  suggestionTags() {
    Scroll() {
      Column() {
        CYLTagListView({ tagList: this.searchView.suggestionsTagView })
          .height(this.searchView.suggestionTagsHeight)
          .accessibilityText($r('app.string.cyl_search_suggestions'))
          .id('CYLSearchSuggestionTags')
      }
      .width('100%')
    }
    .width('100%')
    .layoutWeight(1)
    .align(Alignment.Top)
    .enableScrollInteraction(!this.searchView.tagGestureActive)
  }

  // A result row's text; with `highlightsResultMatches` the first match of the query is drawn in the highlight color
  // (iOS `CYLSearchResultHighlight`).
  @Builder
  resultText(text: string) {
    Text() {
      ForEach(cylSearchResultParts(text, this.searchView.highlightsResultMatches ? this.searchView.query : ''),
        (part: CYLSearchResultPart, partIndex: number) => {
          Span(part.text)
            .fontColor(part.matches ? (this.searchView.resultMatchHighlightColor ?? $r('sys.color.brand')) :
              (this.searchView.suggestionTextColor ?? $r('sys.color.font_primary')))
        }, (part: CYLSearchResultPart, partIndex: number) => `${partIndex}`)
    }
    .fontSize(17)
    .width('100%')
    .constraintSize({ minHeight: this.rowHeight() })
    .padding({ left: 16, right: 16, top: 8, bottom: 8 })
  }

  // The results of `resultsDataSource` (iOS `resultsTableView`, was `CYLSearchResultsViewController`): one row per
  // result, each one element for screen readers with the result's text as its label.
  @Builder
  resultsList() {
    List({ scroller: this.searchView.resultsTableView }) {
      if (this.searchView.resultsHeaderTitle !== undefined) {
        ListItem() {
          Text(this.searchView.resultsHeaderTitle)
            .fontSize(13)
            .fontColor(this.searchView.resultsHeaderTextColor ?? $r('sys.color.font_secondary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
            .padding({ left: 16, right: 16 })
            .accessibilityLevel('yes')
        }
        .height(44)
      }
      ForEach(this.searchView.searchResults, (result: Object, index: number) => {
        ListItem() {
          if (this.searchView.resultCellConfiguration !== undefined) {
            this.searchView.resultCellConfiguration.builder(this.searchView, result, index)
          } else {
            this.resultText(this.searchView.resultsDataSource?.searchViewConfigureResultCell(this.searchView, result) ?? '')
          }
        }
        .accessibilityGroup(true)
        .onClick(() => {
          this.searchView.resultSelected(result);
        })
      // The query is part of the key, so a result view of yours is built again for a new query (to move a highlight).
      }, (result: Object, index: number) => `${index}-${this.searchView.query}`)
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .enableScrollInteraction(!this.searchView.tagGestureActive)
  }

  build() {
    Stack() {
      if (this.searchView.isSearchOpen) {
        Column() {
          Column() {
            CYLSearchBarComponent({ searchBarView: this.searchView.searchBarView })
            Divider()
              .strokeWidth(0.5)
              .color(this.searchView.dividerColor ?? $r('sys.color.comp_divider'))
          }
          .width('100%')
          .backgroundColor(this.searchView.backgroundColor ?? $r('sys.color.background_primary'))
          Stack({ alignContent: Alignment.Top }) {
            if (this.searchView.showsDimming && this.searchView.scrimColor !== undefined) {
              // The one overlay: a tap on it ends the search (iOS `scrimColor`, which `dimmingColor` forwards to).
              Row()
                .width('100%')
                .height('100%')
                .backgroundColor(this.searchView.scrimColor)
                .accessibilityText($r('app.string.cyl_search_cancel'))
                .onClick(() => {
                  this.searchView.closeSearch(true);
                })
            }
            if (this.searchView.contentView !== undefined) {
              this.searchView.contentView.builder()
            }
            Column() {
              if (this.searchView.isEmptyViewShowing) {
                CYLSearchEmptyViewComponent({ content: this.searchView.emptyView })
              } else if (this.searchView.showsEmptyResults && this.searchView.emptyResultsView !== undefined) {
                CYLSearchPlaceholderHost({ model: this.searchView.emptyResultsView })
              } else if (this.searchView.showsResults) {
                if (this.searchView.refreshHandler !== undefined) {
                  CYLRefreshContainer({
                    scrollView: cylRefreshScrollView(this.searchView.resultsTableView),
                    scroller: this.searchView.resultsTableView
                  }) {
                    this.resultsList()
                  }
                } else {
                  this.resultsList()
                }
              } else if (this.searchView.showsLaunchView && this.searchView.launchView !== undefined) {
                this.searchView.launchView.builder(this.searchView)
              } else if (this.searchView.showsEmptySuggestions &&
                this.searchView.emptySuggestionsView !== undefined) {
                CYLSearchPlaceholderHost({ model: this.searchView.emptySuggestionsView })
              } else if (this.searchView.suggestionsVisible && this.searchView.filteredSuggestions.length > 0) {
                if (this.searchView.showsCachedQueries && this.searchView.showsSuggestionCacheHeader) {
                  this.cacheHeader()
                }
                if (this.searchView.suggestionStyle === CYLSearchSuggestionStyle.tags) {
                  this.suggestionTags()
                } else {
                  this.suggestionList()
                }
              }
            }
            .width('100%')
            .height('100%')
            .padding({ bottom: this.keyboardInset })
            .hitTestBehavior(this.searchView.showsDimming ? HitTestMode.Transparent : HitTestMode.Default)
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor(this.searchView.showsDimming ? Color.Transparent :
            (this.searchView.backgroundColor ?? $r('sys.color.background_primary')))
          .onAreaChange((_: Area, area: Area) => {
            this.contentBottom = Number(area.globalPosition.y ?? 0) + Number(area.height);
            this.updateKeyboardInset();
          })
        }
        .width('100%')
        .height('100%')
        .transition(TransitionEffect.OPACITY)
        .onAreaChange((_: Area, area: Area) => {
          this.pageWidth = Number(area.width);
        })
        // A swipe from the left edge ends the search with `supportsSwipeToDismissSearch` (iOS: the edge pan).
        .parallelGesture(PanGesture({ fingers: 1, direction: PanDirection.Horizontal, distance: 10 })
          .onActionStart((event: GestureEvent) => {
            const finger = event.fingerList[0];
            this.swipeBegan = this.searchView.supportsSwipeToDismissSearch && finger !== undefined &&
              cylSearchSwipeBegins(finger.globalX - event.offsetX, event.offsetX, event.offsetY);
          })
          .onActionEnd((event: GestureEvent) => {
            if (this.swipeBegan && cylSearchSwipeCompletes(event.offsetX, this.pageWidth)) {
              this.searchView.closeSearch(true);
            }
            this.swipeBegan = false;
          }))
        .onKeyEvent((event: KeyEvent) => {
          if (event.keyCode === 2070 && event.type === KeyType.Up) {
            return this.searchView.accessibilityPerformEscape();
          }
          return false;
        })
      }
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(this.searchView.isSearchOpen ? HitTestMode.Default : HitTestMode.None)
  }
}

/**
 * Gives a list of yours the pull to refresh of `CYLSearchView.setRefreshHandler(handler, scroller)` (iOS: the scroll
 * view passed to `+setRefreshHandler:forScrollView:`): build the list inside it with the same scroller. Start and
 * stop it with `CYLSearchView.beginRefreshingIn` / `endRefreshingIn`.
 */
@ComponentV2
export struct CYLSearchRefreshComponent {
  /**
   * The scroller of the list inside.
   */
  @Require @Param scroller: Scroller;
  /**
   * The list, built with `scroller`.
   */
  @BuilderParam content: () => void = cylSearchEmptyContent;

  build() {
    CYLRefreshContainer({ scrollView: cylRefreshScrollView(this.scroller), scroller: this.scroller }) {
      this.content()
    }
  }
}

/**
 * A list screen with a built-in search bar as its first row (iOS `CYLSearchTableViewController`): `showsSearchBar`,
 * `hidesSearchBarInitially`, `hidesSearchBarWhenEmptyViewShowing`, the empty view, and a bar that settles fully
 * shown or fully hidden above a short list (`snapsHeaderSearchBar`, issue 1160). `CYLSearchTableComponent` draws it.
 * The bar is a `CYLSearchBarView` with the default appearance, Cancel while active, and Cancel clears the text.
 */
@ObservedV2
export class CYLSearchTableView {
  /**
   * The bar of the list (iOS `searchBar`).
   */
  readonly searchBarView: CYLSearchBarView = new CYLSearchBarView();
  /**
   * The list's scroller (iOS `tableView`).
   */
  readonly scroller: Scroller = new Scroller();
  /**
   * The empty view (iOS `showEmptyView`).
   */
  readonly emptyView: CYLSearchEmptyView = new CYLSearchEmptyView();
  /**
   * Shows the bar as the list's first row. False by default.
   */
  @Trace showsSearchBar: boolean = false;
  /**
   * The bar starts scrolled out of sight (iOS `hidesSearchBarInitially`). False by default.
   */
  @Trace hidesSearchBarInitially: boolean = false;
  /**
   * The bar is removed while the empty view shows and comes back, scrolled out, after it (iOS
   * `hidesSearchBarWhenEmptyViewShowing`). False by default.
   */
  @Trace hidesSearchBarWhenEmptyViewShowing: boolean = false;
  /**
   * The bar settles fully shown or fully hidden when scrolling stops with it half out (issue 1160). True by default.
   */
  snapsHeaderSearchBar: boolean = true;
  /**
   * The search view whose `setSnapsHeader` configured this list: the bar settles only while it is not open.
   */
  snapsOwner: CYLSearchView | undefined = undefined;
  /**
   * A search view that a tap on the bar opens, as the iOS bar that is the header of a table and starts a search;
   * undefined makes the bar an editable field in the list.
   */
  @Trace searchView: CYLSearchView | undefined = undefined;
  /**
   * The height of the bar row, measured by the component.
   */
  @Trace headerHeight: number = 0;
  /**
   * The height added after the rows so the bar can scroll out above a short list.
   */
  @Trace fillerHeight: number = 0;
  /**
   * The height of the list's viewport.
   */
  @Trace viewportHeight: number = 0;
  private hiddenInitiallyApplied: boolean = false;
  private fillerTop: number = -1;

  /**
   * A list with a default bar.
   */
  constructor() {
    this.searchBarView.appearanceStyle = CYLSearchBarAppearance.defaultAppearance;
    this.searchBarView.automaticallyShowsCancelButton = true;
    this.searchBarView.clearsTextOnCancel = true;
  }

  /**
   * Shows the empty view in place of the rows (iOS `showEmptyView`).
   */
  showEmptyView(text: string, detailText?: string, buttonTitle?: string, buttonAction?: () => void): void {
    this.emptyView.show(text, detailText, buttonTitle, buttonAction);
  }

  /**
   * Shows one of CYLTableViewPlaceHolder's scenarios in place of the rows (iOS `showEmptyView(scenario:)`).
   */
  showEmptyViewScenario(scenario: CYLPlaceholderScenario): void {
    this.emptyView.showScenario(scenario);
  }

  /**
   * Hides the empty view; a bar that was removed comes back scrolled out (iOS `hideEmptyView()`).
   */
  hideEmptyView(): void {
    if (this.emptyView.isShowing && this.hidesSearchBarWhenEmptyViewShowing && this.showsSearchBar) {
      this.hiddenInitiallyApplied = false;
    }
    this.emptyView.hide();
  }

  /**
   * Whether the empty view shows (iOS `isEmptyViewShowing`).
   */
  get isEmptyViewShowing(): boolean {
    return this.emptyView.isShowing;
  }

  /**
   * Whether the bar is a row of the list now.
   */
  get showsHeader(): boolean {
    return this.showsSearchBar && !(this.hidesSearchBarWhenEmptyViewShowing && this.emptyView.isShowing);
  }

  /**
   * The list reports where the end filler is (in the viewport) and how tall the viewport is; the filler grows so the
   * bar can scroll out, and a bar that starts hidden scrolls out once.
   */
  layoutChanged(viewportHeight: number, fillerTopInViewport: number): void {
    this.viewportHeight = viewportHeight;
    if (fillerTopInViewport >= 0) {
      this.fillerTop = fillerTopInViewport + this.scroller.currentOffset().yOffset;
    }
    if (!this.showsHeader || this.headerHeight <= 0 || this.fillerTop < 0) {
      return;
    }
    const rowsHeight = this.fillerTop - this.headerHeight;
    const wanted = cylSearchHeaderFillerHeight(viewportHeight, rowsHeight);
    if (Math.abs(wanted - this.fillerHeight) > 1) {
      this.fillerHeight = wanted;
    }
    if (this.hidesSearchBarInitially && !this.hiddenInitiallyApplied) {
      this.hiddenInitiallyApplied = true;
      setTimeout(() => {
        this.scroller.scrollTo({ xOffset: 0, yOffset: this.headerHeight, animation: false });
      }, 50);
    }
  }

  /**
   * Settles the bar fully shown or fully hidden after scrolling stopped with it half out (issue 1160).
   */
  settle(): void {
    if (!this.snapsHeaderSearchBar || !this.showsHeader || this.snapsOwner?.isSearchOpen === true) {
      return;
    }
    const target = cylSearchHeaderSettleOffset(this.scroller.currentOffset().yOffset, this.headerHeight);
    if (target !== undefined) {
      this.scroller.scrollTo({ xOffset: 0, yOffset: target, animation: { duration: 200, curve: Curve.EaseOut } });
    }
  }
}

/**
 * Draws a `CYLSearchTableView`: a list whose first row is the search bar, then your rows (`ListItem`s and
 * `ListItemGroup`s), then a filler that lets the bar scroll out above a short list; the empty view replaces the rows.
 */
@ComponentV2
export struct CYLSearchTableComponent {
  /**
   * The list to draw.
   */
  @Require @Param searchTable: CYLSearchTableView;
  /**
   * Your rows: `ListItem`s and `ListItemGroup`s.
   */
  @BuilderParam rows: () => void = cylSearchEmptyContent;

  // The bar's placeholder as text, for screen readers (a resource in the language the app shows).
  private placeholderLabel(): string {
    const placeholder: ResourceStr = this.searchTable.searchBarView.placeholder ?? $r('app.string.cyl_search_field');
    if (typeof placeholder === 'string') {
      return placeholder;
    }
    try {
      return this.getUIContext().getHostContext()?.resourceManager.getStringSync((placeholder as Resource).id) ?? '';
    } catch (error) {
      return '';
    }
  }

  @Builder
  header() {
    Column() {
      CYLSearchBarComponent({ searchBarView: this.searchTable.searchBarView })
    }
    // With a search view, a tap on the bar starts its search instead of editing here.
    .hitTestBehavior(this.searchTable.searchView !== undefined ? HitTestMode.Block : HitTestMode.Default)
    .accessibilityGroup(this.searchTable.searchView !== undefined)
    .accessibilityText(this.searchTable.searchView !== undefined ? this.placeholderLabel() : '')
    .onClick(() => {
      this.searchTable.searchView?.showSearch(true);
    })
    .onAreaChange((_: Area, area: Area) => {
      this.searchTable.headerHeight = Number(area.height);
    })
  }

  build() {
    List({ scroller: this.searchTable.scroller }) {
      if (this.searchTable.showsHeader) {
        ListItem() {
          this.header()
        }
      }
      if (this.searchTable.emptyView.isShowing) {
        ListItem() {
          CYLSearchEmptyViewComponent({ content: this.searchTable.emptyView })
            .height(Math.max(240, this.searchTable.viewportHeight - this.searchTable.headerHeight))
        }
      } else {
        this.rows()
      }
      ListItem() {
        Row()
          .width('100%')
          .height(this.searchTable.fillerHeight)
      }
      .onAreaChange((_: Area, area: Area) => {
        this.searchTable.layoutChanged(this.searchTable.viewportHeight, Number(area.position.y));
      })
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
    .onAreaChange((_: Area, area: Area) => {
      this.searchTable.layoutChanged(Number(area.height), -1);
    })
    .onScrollStop(() => {
      this.searchTable.settle();
    })
  }
}
