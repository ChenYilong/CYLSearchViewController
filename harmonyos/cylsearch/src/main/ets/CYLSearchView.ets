import { common } from '@kit.AbilityKit';
import { LengthMetrics } from '@kit.ArkUI';
import { CYLSearchBarComponent, CYLSearchBarNavigationIcon, CYLSearchBarView, CYLSearchBarViewDelegate } from './CYLSearchBarView';
import { CYLSearchPlaceholderComponent, CYLSearchPlaceholderKind, CYLSearchPlaceholderView } from './CYLSearchPlaceholderView';
import { CYLSearchSuggestionCache, CYLSearchSuggestionCachePolicy, CYLSearchSuggestionStore } from './CYLSearchSuggestionCache';

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
  bottom = 1
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
}

/**
 * A search page that opens over its host (iOS `CYLSearchView`): a `CYLSearchBarView` at the top, a divider, then the
 * suggestions as a list or as tags, the cached queries first, and placeholders for an empty cache and for no
 * results. This class is the page's state and API; `CYLSearchComponent` draws it.
 *
 * Core behavior rule 1: focusing the field alone changes nothing below the search bar; that area changes only when
 * the text or the data changes.
 */
@ObservedV2
export class CYLSearchView {
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
   * Shows a placeholder under the search bar while a non-empty query matches no suggestion. False by default.
   */
  @Trace showsEmptyResultsPlaceholder: boolean = false;
  /**
   * The kind of that placeholder. `noResults` by default.
   */
  @Trace emptyResultsScenario: CYLSearchPlaceholderKind = CYLSearchPlaceholderKind.noResults;
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
   * The kind of that placeholder. `empty` by default.
   */
  @Trace emptySuggestionsScenario: CYLSearchPlaceholderKind = CYLSearchPlaceholderKind.empty;
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

  @Trace private open: boolean = false;
  @Trace private suggestionsShown: boolean = true;
  @Trace private allSuggestions: string[] = [];
  @Trace private showsAllForEmptyQuery: boolean = false;
  private cachePolicy: CYLSearchSuggestionCachePolicy = CYLSearchSuggestionCachePolicy.database;
  private cacheName: string = 'CYLSearchView';
  private context: common.Context | undefined = undefined;
  private emptyResults: CYLSearchPlaceholderView | undefined = undefined;
  private emptySuggestions: CYLSearchPlaceholderView | undefined = undefined;

  /**
   * A closed search view with the default look (iOS `-initWithFrame:`).
   */
  constructor() {
    this.searchBarView.navigationIcon = CYLSearchBarNavigationIcon.arrow;
    const barDelegate: CYLSearchBarViewDelegate = {
      searchBarViewTextDidChange: (_: CYLSearchBarView, text: string) => {
        this.refilter();
        this.delegate?.searchViewTextDidChange?.(this, text);
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
   * The placeholder shown for empty results, created the first time it is needed; undefined before.
   */
  get emptyResultsView(): CYLSearchPlaceholderView | undefined {
    return this.emptyResults;
  }

  /**
   * The placeholder shown for an empty cache, created the first time it is needed; undefined before.
   */
  get emptySuggestionsView(): CYLSearchPlaceholderView | undefined {
    return this.emptySuggestions;
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
   * True while the query is not empty, nothing matches it and the empty results placeholder is on.
   */
  get showsEmptyResults(): boolean {
    return this.showsEmptyResultsPlaceholder && this.query.length > 0 && this.filteredSuggestions.length === 0;
  }

  /**
   * True while the query is empty, there is nothing to list and the empty suggestions placeholder is on.
   */
  get showsEmptySuggestions(): boolean {
    return this.showsEmptySuggestionsPlaceholder && this.query.length === 0 &&
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
   * Opens the search view and, with `focusesSearchFieldOnShow`, starts editing (iOS `-showSearch:`).
   */
  showSearch(animated: boolean = true): void {
    if (this.open) {
      return;
    }
    this.refilter();
    if (animated && this.animationDuration > 0) {
      animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseOut }, () => {
        this.open = true;
      });
    } else {
      this.open = true;
    }
    if (this.focusesSearchFieldOnShow) {
      setTimeout(() => {
        this.searchBarView.showKeyboard();
      }, animated ? this.animationDuration * 1000 : 0);
    }
    this.delegate?.searchViewDidShow?.(this);
  }

  /**
   * Closes the search view and ends editing (iOS `-closeSearch:`).
   */
  closeSearch(animated: boolean = true): void {
    if (!this.open) {
      return;
    }
    this.searchBarView.hideKeyboard();
    if (animated && this.animationDuration > 0) {
      animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseIn }, () => {
        this.open = false;
      });
    } else {
      this.open = false;
    }
    this.delegate?.searchViewDidClose?.(this);
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
    this.searchBarView.setText(text, false);
    this.refilter();
    if (submit) {
      this.submitted();
    }
  }

  /**
   * Lists the suggestions that match the current query.
   */
  showSuggestions(): void {
    this.suggestionsShown = true;
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
  }

  /**
   * A suggestion was tapped: the field shows it, the delegate is told, and it is submitted with
   * `submitsOnSuggestionSelection`.
   */
  suggestionSelected(suggestion: string, index: number): void {
    this.searchBarView.setText(suggestion, false);
    this.refilter();
    this.delegate?.searchViewDidSelectSuggestion?.(this, suggestion, index);
    if (this.submitsOnSuggestionSelection) {
      this.submitted();
    }
  }

  private submitted(): void {
    const text = this.query.trim();
    if (text.length === 0) {
      return;
    }
    this.suggestionCache?.addQuery(text);
    this.searchBarView.hideKeyboard();
    const handled = this.delegate?.searchViewDidSubmitText?.(this, text) ?? false;
    if (!handled && this.closesOnSubmit) {
      this.closeSearch(true);
    }
    this.refilter();
  }

  private rebuildCache(): void {
    if (this.context === undefined) {
      return;
    }
    this.suggestionCache = CYLSearchSuggestionStore.cache(this.context, this.cachePolicy, this.cacheName);
    this.refilter();
  }

  private matches(suggestion: string, query: string): boolean {
    if (this.suggestionFilter !== undefined) {
      return this.suggestionFilter(suggestion, query);
    }
    return suggestion.toLocaleLowerCase().includes(query.toLocaleLowerCase());
  }

  private refilter(): void {
    const query = this.query;
    const cached = this.suggestionCache?.cachedQueries() ?? [];
    let result: string[] = [];
    if (query.length === 0) {
      if (cached.length > 0) {
        result = cached;
        this.showsCachedQueries = true;
      } else {
        result = this.showsAllForEmptyQuery ? this.allSuggestions.slice() : [];
        this.showsCachedQueries = false;
      }
    } else {
      this.showsCachedQueries = false;
      cached.forEach((value: string) => {
        if (this.matches(value, query)) {
          result.push(value);
        }
      });
      this.allSuggestions.forEach((value: string) => {
        if (this.matches(value, query) && !result.includes(value)) {
          result.push(value);
        }
      });
    }
    this.filteredSuggestions = result;
    if (this.showsEmptyResults && this.emptyResults === undefined) {
      this.emptyResults = CYLSearchPlaceholderView.withKind(this.emptyResultsScenario);
    }
    if (this.showsEmptySuggestions && this.emptySuggestions === undefined) {
      this.emptySuggestions = CYLSearchPlaceholderView.withKind(this.emptySuggestionsScenario);
    }
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
        Text(this.searchView.suggestionsFolded ? 'More' : 'Less')
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
    .border({ width: 1, color: $r('sys.color.comp_divider') })
    .backgroundColor(this.searchView.backgroundColor ?? $r('sys.color.background_primary'))
    .accessibilityGroup(true)
    .accessibilityText(this.searchView.suggestionsFolded ? 'Show more' : 'Show less')
    .onClick(() => {
      this.searchView.suggestionsFolded = !this.searchView.suggestionsFolded;
    })
  }

  @Builder
  suggestionTags() {
    Scroll() {
      Column({ space: 8 }) {
        Stack({ alignContent: Alignment.BottomEnd }) {
          Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
            ForEach(this.searchView.filteredSuggestions, (suggestion: string, index: number) => {
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
          }
          .width('100%')
          .constraintSize({
            maxHeight: this.searchView.suggestionsFolded && this.searchView.suggestionsFoldedRowCount > 0 ?
              this.searchView.suggestionsFoldedRowCount * 34 + (this.searchView.suggestionsFoldedRowCount - 1) * 8 :
              100000
          })
          .clip(true)

          if (this.searchView.suggestionsFoldedRowCount > 0 &&
            this.searchView.suggestionsFoldControl.position === CYLMenuFoldControlPosition.inline) {
            this.foldControl()
          }
        }

        if (this.searchView.suggestionsFoldedRowCount > 0 &&
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
                CYLSearchPlaceholderComponent({ placeholderView: this.searchView.emptyResultsView })
              } else if (this.searchView.showsEmptySuggestions &&
                this.searchView.emptySuggestionsView !== undefined) {
                CYLSearchPlaceholderComponent({ placeholderView: this.searchView.emptySuggestionsView })
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
          }
          .width('100%')
          .layoutWeight(1)
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
