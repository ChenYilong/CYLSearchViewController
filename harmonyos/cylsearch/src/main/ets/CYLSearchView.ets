import { display, LengthMetrics, UIContext, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { accessibility } from '@kit.AccessibilityKit';
import {
  CYLPlaceholderScenario,
  CYLPlaceholderStackView,
  CYLPlaceholderStackViewModel,
  CYLRefreshContainer,
  CYLRefreshNormalHeaderModel,
  CYLRefreshScrollViewModel
} from 'cylplaceholder';
import { CYLSearchBarComponent, CYLSearchBarNavigationIcon, CYLSearchBarView, CYLSearchBarViewDelegate } from './CYLSearchBarView';
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
 * How many of the tags (`widths`, in vp) fit in `rows` rows of `width` with `spacing` between them, when a fold
 * control of `controlWidth` must follow the last visible tag (0 for no control in the flow); all of them when they
 * fit together without the control. Rows of 0 or less, or no width yet, show every tag (CollectionViewClassifyMenu
 * `CYLTagListView` folding).
 */
function cylFoldedTagCount(widths: number[], width: number, rows: number, spacing: number,
  controlWidth: number): number {
  if (rows <= 0 || width <= 0) {
    return widths.length;
  }
  const fits = (count: number, extra: number): boolean => {
    let row = 1;
    let x = 0;
    const items = widths.slice(0, count).map((w: number) => Math.min(w, width));
    if (extra > 0) {
      items.push(Math.min(extra, width));
    }
    for (const w of items) {
      if (x > 0 && x + spacing + w > width) {
        row++;
        x = w;
      } else {
        x = x > 0 ? x + spacing + w : w;
      }
      if (row > rows) {
        return false;
      }
    }
    return true;
  };
  if (fits(widths.length, 0)) {
    return widths.length;
  }
  for (let count = widths.length - 1; count >= 0; count--) {
    if (fits(count, controlWidth)) {
      return count;
    }
  }
  return 0;
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
 * Where the fold control of the tag suggestions sits (CollectionViewClassifyMenu's `CYLMenuFoldControlPosition`).
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
 * What the fold control shows (CollectionViewClassifyMenu's `CYLMenuFoldControlContent`).
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
 * The fold control of the tag suggestions (CollectionViewClassifyMenu's `CYLMenuFoldControl`).
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
   * How the suggestions are shown: a list (the default) or tags.
   */
  @Trace suggestionStyle: CYLSearchSuggestionStyle = CYLSearchSuggestionStyle.list;
  /**
   * The fold control of the tag suggestions. An inline chevron by default.
   */
  @Trace suggestionsFoldControl: CYLMenuFoldControl = new CYLMenuFoldControl();
  /**
   * The rows of tag suggestions shown while folded. 2 by default; 0 shows every row.
   */
  @Trace suggestionsFoldedRowCount: number = 2;
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
   * The color behind the page while it is open; undefined draws none.
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
   * Whether the tag suggestions are folded.
   */
  @Trace suggestionsFolded: boolean = true;

  /**
   * The scroller of the results list (iOS `resultsTableView`): scroll it, or pass it to the static refresh methods.
   */
  readonly resultsTableView: Scroller = new Scroller();

  @Trace private open: boolean = false;
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
      searchBarViewNavigationButtonClicked: (_: CYLSearchBarView) => {
        if (this.delegate?.searchViewNavigationButtonClicked !== undefined) {
          this.delegate.searchViewNavigationButtonClicked(this);
        } else {
          this.closeSearch(true);
        }
      }
    };
    this.searchBarView.delegate = barDelegate;
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
    this.refilter();
    if (animated && this.animationDuration > 0) {
      // The delegate hears of it when the animation ends, as on Android.
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseOut, onFinish: () => {
        this.delegate?.searchViewDidShow?.(this);
      } }, () => {
        this.open = true;
      });
    } else {
      this.open = true;
      this.delegate?.searchViewDidShow?.(this);
    }
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
    this.searchBarView.hideKeyboard();
    if (animated && this.animationDuration > 0) {
      cylAnimate(this.uiContext, { duration: this.animationDuration * 1000, curve: Curve.EaseIn, onFinish: () => {
        this.delegate?.searchViewDidClose?.(this);
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
    this.refilter();
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
    // Android `select`: the text is set silently, the delegate is told, then the query is submitted or reported.
    this.searchBarView.setText(suggestion, false);
    this.delegate?.searchViewDidSelectSuggestion?.(this, suggestion, index);
    if (this.submitsOnSuggestionSelection) {
      this.searchBarView.submit();
    } else {
      this.queryChanged(suggestion);
    }
  }

  private queryChanged(text: string): void {
    this.refilter();
    this.reloadResults();
    this.delegate?.searchViewTextDidChange?.(this, text);
  }

  // Every submitted query is cached, so the list shows it the next time (Android `searchBarViewSearchButtonClicked`).
  private submitted(): void {
    const text = this.query;
    this.suggestionCache?.addQuery(text);
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
  @Local tagsWidth: number = 0;
  // The part of the area under the search bar that the keyboard covers (vp): the placeholders and suggestions end
  // above the keyboard, whatever keyboard mode the app's window uses (iOS insets the scroll view for the keyboard).
  @Local keyboardInset: number = 0;
  private keyboardHeight: number = 0;
  private contentBottom: number = 0;
  private hostWindow: window.Window | undefined = undefined;
  private keyboardListener: (height: number) => void = (height: number) => {
    this.keyboardHeight = this.getUIContext().px2vp(height);
    this.updateKeyboardInset();
  };

  aboutToAppear(): void {
    this.searchView.uiContext = this.getUIContext();
    const context = this.getUIContext().getHostContext();
    if (context === undefined) {
      return;
    }
    window.getLastWindow(context).then((win: window.Window) => {
      this.hostWindow = win;
      win.on('keyboardHeightChange', this.keyboardListener);
    }).catch(() => {
      // No window: the content keeps its full height.
    });
  }

  aboutToDisappear(): void {
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

  // A resource in the language the app shows, as a string (to measure it).
  private resolvedText(value: Resource): string {
    try {
      return this.getUIContext().getHostContext()?.resourceManager.getStringSync(value.id) ?? '';
    } catch (error) {
      return '';
    }
  }

  private textWidth(text: string, fontSize: number): number {
    const size = this.getUIContext().getMeasureUtils().measureTextSize({ textContent: text, fontSize: fontSize });
    return this.getUIContext().px2vp(Number(size.width));
  }

  private tagWidth(title: string): number {
    return this.textWidth(title, 15) + 14 * 2 + 2;
  }

  private foldControlWidth(): number {
    if (this.searchView.suggestionsFoldControl.content === CYLMenuFoldControlContent.title) {
      return Math.max(this.textWidth(this.resolvedText($r('app.string.cyl_search_foldMore')), 14),
        this.textWidth(this.resolvedText($r('app.string.cyl_search_foldLess')), 14)) + 12 * 2 + 2;
    }
    return 44;
  }

  /**
   * The number of tags shown: every tag unfolded, with no control, or before the layout is known; otherwise the tags
   * of the folded rows, leaving room for the control when it is inline (as CollectionViewClassifyMenu does).
   */
  private visibleTagCount(): number {
    const all = this.searchView.filteredSuggestions.length;
    const control = this.searchView.suggestionsFoldControl;
    if (!this.searchView.suggestionsFolded || control.position === CYLMenuFoldControlPosition.none ||
      this.searchView.suggestionsFoldedRowCount <= 0 || this.tagsWidth <= 0) {
      return all;
    }
    const widths = this.searchView.filteredSuggestions.map((title: string) => this.tagWidth(title));
    return cylFoldedTagCount(widths, this.tagsWidth, this.searchView.suggestionsFoldedRowCount, 8,
      control.position === CYLMenuFoldControlPosition.inline ? this.foldControlWidth() : 0);
  }

  /**
   * The control is shown while folding hides a tag, and while unfolded tags would be hidden by folding again.
   */
  private showsFoldControl(): boolean {
    const control = this.searchView.suggestionsFoldControl;
    if (control.position === CYLMenuFoldControlPosition.none || this.searchView.suggestionsFoldedRowCount <= 0 ||
      this.tagsWidth <= 0) {
      return false;
    }
    const widths = this.searchView.filteredSuggestions.map((title: string) => this.tagWidth(title));
    const folded = cylFoldedTagCount(widths, this.tagsWidth, this.searchView.suggestionsFoldedRowCount, 8,
      control.position === CYLMenuFoldControlPosition.inline ? this.foldControlWidth() : 0);
    return folded < widths.length;
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
    }
    .width('100%')
    .layoutWeight(1)
    .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
    .accessibilityText($r('app.string.cyl_search_suggestions'))
  }

  @Builder
  foldControl() {
    Row() {
      if (this.searchView.suggestionsFoldControl.content === CYLMenuFoldControlContent.title) {
        Text(this.searchView.suggestionsFolded ? $r('app.string.cyl_search_foldMore') :
          $r('app.string.cyl_search_foldLess'))
          .fontSize(14)
          .fontColor($r('sys.color.font_secondary'))
      } else {
        SymbolGlyph($r('sys.symbol.chevron_down'))
          .fontSize(16)
          .fontColor([$r('sys.color.font_secondary')])
          .rotate({ angle: this.searchView.suggestionsFolded ? 0 : 180 })
      }
    }
    .height(34)
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.Center)
    .borderRadius(17)
    // A 44 vp tall touch area around the 34 vp control, without changing the layout.
    .responseRegion({ x: 0, y: -5, width: '100%', height: 44 })
    .border({ width: 1, color: $r('sys.color.comp_divider') })
    .backgroundColor(this.searchView.backgroundColor ?? $r('sys.color.background_primary'))
    .accessibilityGroup(true)
    .accessibilityText(this.searchView.suggestionsFolded ? $r('app.string.cyl_search_showMore') :
      $r('app.string.cyl_search_showLess'))
    .onClick(() => {
      this.searchView.suggestionsFolded = !this.searchView.suggestionsFolded;
    })
  }

  @Builder
  suggestionTags() {
    Scroll() {
      Column({ space: 8 }) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          ForEach(this.searchView.filteredSuggestions.slice(0, this.visibleTagCount()),
            (suggestion: string, index: number) => {
              Text(suggestion)
                .fontSize(15)
                .fontColor(this.searchView.suggestionTextColor ?? $r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .height(34)
                .padding({ left: 14, right: 14 })
                .borderRadius(17)
                .border({ width: 1, color: $r('sys.color.comp_divider') })
                .backgroundColor(this.searchView.suggestionBackgroundColor ?? Color.Transparent)
                .onClick(() => {
                  this.searchView.suggestionSelected(suggestion, index);
                })
            }, (suggestion: string, index: number) => `${index}-${suggestion}`)
          // Inline: the control is the last tag of the flow (CollectionViewClassifyMenu `CYLMenuFoldControlPositionInline`).
          if (this.showsFoldControl() &&
            this.searchView.suggestionsFoldControl.position === CYLMenuFoldControlPosition.inline) {
            this.foldControl()
          }
        }
        .width('100%')
        .onAreaChange((_: Area, area: Area) => {
          this.tagsWidth = Number(area.width);
        })

        if (this.showsFoldControl() &&
          this.searchView.suggestionsFoldControl.position === CYLMenuFoldControlPosition.bottom) {
          this.foldControl()
        }
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .layoutWeight(1)
    .align(Alignment.Top)
  }

  // The results of `resultsDataSource` (iOS `resultsTableView`, was `CYLSearchResultsViewController`): one row per
  // result, each one element for screen readers with the result's text as its label.
  @Builder
  resultsList() {
    List({ scroller: this.searchView.resultsTableView }) {
      ForEach(this.searchView.searchResults, (result: Object) => {
        ListItem() {
          Text(this.searchView.resultsDataSource?.searchViewConfigureResultCell(this.searchView, result) ?? '')
            .fontSize(17)
            .fontColor(this.searchView.suggestionTextColor ?? $r('sys.color.font_primary'))
            .width('100%')
            .constraintSize({ minHeight: this.rowHeight() })
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        }
        .accessibilityGroup(true)
        .onClick(() => {
          this.searchView.resultSelected(result);
        })
      }, (result: Object, index: number) => `${index}`)
    }
    .width('100%')
    .height('100%')
    .divider({ strokeWidth: 0.5, color: $r('sys.color.comp_divider'), startMargin: 16 })
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
  }

  build() {
    Stack() {
      if (this.searchView.isSearchOpen) {
        Column() {
          CYLSearchBarComponent({ searchBarView: this.searchView.searchBarView })
          Divider()
            .strokeWidth(0.5)
            .color(this.searchView.dividerColor ?? $r('sys.color.comp_divider'))
          Stack({ alignContent: Alignment.Top }) {
            if (this.searchView.contentView !== undefined) {
              this.searchView.contentView.builder()
            }
            Column() {
              if (this.searchView.showsEmptyResults && this.searchView.emptyResultsView !== undefined) {
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
              } else if (this.searchView.showsEmptySuggestions &&
                this.searchView.emptySuggestionsView !== undefined) {
                CYLSearchPlaceholderHost({ model: this.searchView.emptySuggestionsView })
              } else if (this.searchView.suggestionsVisible && this.searchView.filteredSuggestions.length > 0) {
                if (this.searchView.showsCachedQueries) {
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
          }
          .width('100%')
          .layoutWeight(1)
          .onAreaChange((_: Area, area: Area) => {
            this.contentBottom = Number(area.globalPosition.y ?? 0) + Number(area.height);
            this.updateKeyboardInset();
          })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.searchView.backgroundColor ?? $r('sys.color.background_primary'))
        .transition(TransitionEffect.OPACITY)
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
    .backgroundColor(this.searchView.isSearchOpen ? (this.searchView.scrimColor ?? Color.Transparent) :
    Color.Transparent)
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
