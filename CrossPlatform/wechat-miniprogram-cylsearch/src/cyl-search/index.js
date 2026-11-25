const { CYLSearchView, cylClampAnimationSpeed, cylSnapHeaderOffset, cylSwipeShouldDismiss, cylEdgeSwipeBegins } = require('../core/CYLSearchView');
const { CYLSearchResources, cylNavigationMetrics } = require('../core/CYLSearchResources');

const text = (key) => CYLSearchResources.localizedString(undefined, key);

/**
 * The search view component (iOS `CYLSearchView`), drawing a `CYLSearchView` (`this.model`); it also takes the
 * place of the overlay (was `cyl-search-controller`) and of the results list (was `CYLSearchResultsViewController`).
 * Set `suggestions`; call `showSearch()` to open it (the field is focused unless `focusesSearchFieldOnShow` is
 * false), or set `inline` to draw it in place, always open. While results are set (the `results` property, or
 * `setResultsDataSource(dataSource)`) and the query is not empty (or `showsResultsForEmptyQuery`), the results take
 * the place of the suggestions, with CYLTableViewPlaceHolder's pull-to-refresh when `refresherEnabled` is set or a
 * refresh handler is given.
 *
 * Events: `show`, `close`, `submit` `{ text }`, `textchange` `{ text }`, `suggestionselect` `{ suggestion, index }`,
 * `selectresult` `{ result, index }`, `refresh`, `focuschange` `{ focused }`, `voicetap`, `itemselect`.
 * Methods: `showSearch(animated, completion)`, `closeSearch(animated, completion)`, `isSearchOpen()`,
 * `setQuery(text, submit)`, `setResultsDataSource(dataSource)`, `reloadResults()`, `searchResults()`,
 * `setRefreshHandler(handler)`, `beginRefreshing()`, `endRefreshing()`, `isRefreshing()`, `emptyResultsView()`,
 * `emptySuggestionsView()`, `playAnimationFromStart()`. Abstract node `cyl-empty-view` (properties `scenario`,
 * `animated`, `loop`, `speed`; method `playAll()`): the empty placeholders, CYLTableViewPlaceHolder's
 * `<cyl-placeholder>` by default. Slots: `placeholder-footer` (under the empty suggestions placeholder); `content`
 * (with `showsContent`: your own view in place of the suggestions, iOS `contentView`). The content page is the one
 * scroller below the bar and scrolls by itself; it holds its scrolling only while a tag list inside has a drag
 * (`reorderingchange`) or a smear (`smearingchange`) active, which that list sends as bubbling, composed events
 * through the slot (CollectionViewClassifyMenu's `cyl-tag-cloud`). Put your content in the slot: do not wrap it in a
 * `<scroll-view>` of your own, and do not switch scrolling yourself.
 */
Component({
  options: { multipleSlots: true },
  properties: {
    suggestions: { type: Array, value: [], observer: 'onSuggestionsChange' },
    suggestionStyle: { type: String, value: 'tags' },
    placeholder: { type: String, value: '' },
    searchBarStyle: { type: String, value: 'plain' },
    items: { type: Array, value: [] },
    cacheName: { type: String, value: 'CYLSearchView', observer: 'onCacheNameChange' },
    focusesSearchFieldOnShow: { type: Boolean, value: true },
    // false hides the "Recent searches" header and its trash button (iOS showsSuggestionCacheHeader).
    showsSuggestionCacheHeader: { type: Boolean, value: true },
    showsEmptyResultsPlaceholder: { type: Boolean, value: false },
    // NO keeps the page open after a submitted query (iOS closesOnSubmit, or a delegate that handles the query).
    closesOnSubmit: { type: Boolean, value: true },
    foldedRowCount: { type: Number, value: 2 },
    // The CYLTableViewPlaceHolder scenario shown while a non-empty query matches nothing or the results are empty
    // (iOS emptyResultsScenario) and while the query and the cache are empty (iOS emptySuggestionsScenario). The
    // abstract node cyl-empty-view draws it: cyl-placeholder-miniprogram's <cyl-placeholder> by default; pass a view
    // of yours (for example one that gives <cyl-placeholder> a Lottie player) with generic:cyl-empty-view.
    // The abstract nodes cyl-lottie-view, cyl-pag-view, cyl-rive-view and cyl-svga-view are the animation engines of
    // the bar items' animated icons, forwarded to <cyl-search-bar> (see there); the package links no engine.
    emptyResultsScenario: { type: String, value: 'NoSearchResults' },
    emptySuggestionsScenario: { type: String, value: 'NoContent' },
    // YES asks cyl-empty-view to play the scenario's animation (NO on iOS: CYLPlaceholderStackView is static).
    emptyPlaceholderAnimated: { type: Boolean, value: false },
    // The playback strategy of that animation, applied live: a speed (0.25 to 3, rounded to 0.25) and whether it
    // loops. playAnimationFromStart() restarts it from progress 0.
    animationSpeed: { type: Number, value: 1, observer: 'onAnimationSpeedChange' },
    animationLoops: { type: Boolean, value: true },
    recentTitle: { type: String, value: '' },
    clearLabel: { type: String, value: '' },
    // The results (iOS resultsDataSource from WXML): an array shows them in place of the suggestions; null (the
    // default) shows the suggestions. Update it on textchange. setResultsDataSource() is the JavaScript way.
    results: { type: null, value: null, observer: 'onResultsChange' },
    // YES shows the results while the query is empty too.
    showsResultsForEmptyQuery: { type: Boolean, value: false },
    // YES adds CYLTableViewPlaceHolder's pull-to-refresh (CYLRefreshNormalHeader) to the results: a pull sends
    // `refresh`; call endRefreshing() on every completion path (iOS refreshHandler).
    refresherEnabled: { type: Boolean, value: false, observer: 'updateRefreshes' },
    // YES draws the search view in place, always open (no overlay, no back handling), as a screen's own content.
    // Passed to the inline bar (cyl-search-bar focusesOnAppear).
    focusesOnAppear: { type: Boolean, value: false },
    inline: { type: Boolean, value: false },
    // YES puts the bar at the top of the scrolling results, so it scrolls away with them (UIKit
    // hidesSearchBarWhenScrolling); NO keeps it pinned above them.
    hidesSearchBarWhenScrolling: { type: Boolean, value: false },
    // The bar (iOS searchBarView): the navigation button ("arrow", "search", "none"), Cancel, voice, magnifier, keyboard.
    navigationIcon: { type: String, value: 'arrow' },
    showsCancelButton: { type: Boolean, value: false },
    cancelButtonTitle: { type: String, value: '' },
    showsVoiceButton: { type: Boolean, value: false },
    showsSearchIcon: { type: Boolean, value: true },
    secure: { type: Boolean, value: false },
    cursorColor: { type: String, value: '' },
    // The look (iOS backgroundColor, searchBarView.textColor / placeholderColor / navigationButton tint,
    // suggestionTextColor, suggestionImageTintColor, dividerColor); empty keeps the system colors.
    backgroundColor: { type: String, value: '' },
    textColor: { type: String, value: '' },
    placeholderColor: { type: String, value: '' },
    navigationColor: { type: String, value: '' },
    suggestionTextColor: { type: String, value: '' },
    suggestionImageTintColor: { type: String, value: '' },
    dividerColor: { type: String, value: '' },
    // "truncate" (one line with an ellipsis) or "wrap" (iOS suggestionLineBreakMode).
    suggestionLineBreak: { type: String, value: 'truncate' },
    // YES draws the slot content in place of the suggestions (iOS contentView).
    showsContent: { type: Boolean, value: false },
    // YES puts the bar where the navigation bar of a "navigationStyle": "custom" page is, clear of the menu button.
    coversNavigationBar: { type: Boolean, value: false },
    // The list screen (iOS CYLSearchTableViewController): with `showsContent`, the bar is the header of the content page, in
    // the content's own scroller. Focusing it starts the search: the page scrolls to the top, and the launch view, the
    // dimming, the suggestions, the results or the empty view fill the space under the bar, never over it.
    showsSearchBar: { type: Boolean, value: false },
    // The bar starts scrolled out of sight (iOS hidesSearchBarInitially).
    hidesSearchBarInitially: { type: Boolean, value: false },
    // The bar leaves while the content's empty view shows (iOS hidesSearchBarWhenEmptyViewShowing).
    hidesSearchBarWhenEmptyViewShowing: { type: Boolean, value: false },
    // A header bar half scrolled out settles fully shown or fully hidden when the scrolling ends, and a short list can
    // scroll it out (iOS snapsHeaderSearchBar, QMUI #1160).
    snapsHeaderSearchBar: { type: Boolean, value: true },
    // The launch view under the bar while the query is empty (iOS showsSuggestionsLaunchView): the suggestion area itself,
    // CollectionViewClassifyMenu's tag list with the history (newest first, with the header and its trash button) or,
    // without one, `suggestions`; a tapped tag sets the query and submits it. It wins over `showsLaunchView`.
    showsSuggestionsLaunchView: { type: Boolean, value: false },
    // Your own view under the bar while the query is empty (iOS launchView): the slot `launch-view`.
    showsLaunchView: { type: Boolean, value: false },
    // The color of the one scrim under the bar while the query is empty and there is no launch view; a tap ends the search
    // (iOS scrimColor). `dimmingColor` is the earlier name and forwards to it.
    scrimColor: { type: String, value: '' },
    dimmingColor: { type: String, value: '' },
    // The result rows mark the first match of the query, ignoring case and diacritics, in `resultMatchHighlightColor` (the
    // tint color by default; iOS highlightsResultMatches). `highlightsMatches` and `highlightColor` are the earlier names.
    highlightsResultMatches: { type: Boolean, value: false },
    resultMatchHighlightColor: { type: String, value: '' },
    highlightsMatches: { type: Boolean, value: false },
    highlightColor: { type: String, value: '' },
    // The empty view's text while the query is not empty and the results are empty (iOS noResultsText).
    noResultsText: { type: String, value: '' },
    // The line over the results (iOS resultsHeaderTitleProvider, set with setResultsHeaderTitleProvider(fn)) in this color
    // (iOS resultsHeaderTextColor), and the text button under the cached queries that clears them (iOS
    // suggestionCacheFooterTitle).
    resultsHeaderTextColor: { type: String, value: '' },
    suggestionCacheFooterTitle: { type: String, value: '' },
    // A swipe from the left edge ends the search (iOS supportsSwipeToDismissSearch).
    supportsSwipeToDismissSearch: { type: Boolean, value: false },
    // The bar's own style, passed to the header bar (see cyl-search-bar): iOS CYLSearchBar.
    centersPlaceholder: { type: Boolean, value: false },
    textFieldMargins: { type: Object, value: null },
    activeTextFieldMargins: { type: Object, value: null },
    cancelButtonMargins: { type: Object, value: null },
    activeCancelButtonMargins: { type: Object, value: null },
    cancelButtonFont: { type: Object, value: null },
    // The leading view and the trailing accessory views of the bar (iOS showsLeadingView / showsTrailingAccessoryViews; the
    // slots `leading` and `trailing`); showsLeadingAccessory / showsTrailingAccessory and the slots `leading-accessory` /
    // `trailing-accessory` are the earlier names.
    showsLeadingView: { type: Boolean, value: true },
    showsTrailingAccessoryViews: { type: Boolean, value: true },
    showsLeadingAccessory: { type: null, value: null },
    showsTrailingAccessory: { type: null, value: null },
    leadingAccessoryMargins: { type: Object, value: null },
    trailingAccessoryMargins: { type: Object, value: null },
    appearance: { type: Object, value: null },
  },
  data: {
    playbackSpeed: 1, shownSuggestions: [], tagConfiguration: null, open: false, visible: false, entered: false,
    focus: false, query: '', showsCachedQueries: false, showsCacheHeader: false, showsEmptyResults: false, showsEmptySuggestions: false, resultsHeaderTitle: '', cacheFooterTitle: '',
    showsResults: false, shownResults: [], refreshes: false, labels: {}, pageStyle: '', barInsets: '', contentScrollHeld: false,
    showsLaunch: false, showsDimming: false, emptyView: null, emptyInContent: false, headerHidden: false, headerHeight: 56,
    scrollTop: 0, scrollAnimated: false, swipeX: 0,
  },
  observers: {
    'showsSuggestionsLaunchView, showsLaunchView, scrimColor, dimmingColor, highlightsResultMatches, highlightsMatches, resultMatchHighlightColor, resultsHeaderTextColor, suggestionCacheFooterTitle, noResultsText, foldedRowCount, showsSearchBar, hidesSearchBarWhenEmptyViewShowing, showsEmptyResultsPlaceholder, closesOnSubmit, showsResultsForEmptyQuery, focusesSearchFieldOnShow, showsSuggestionCacheHeader, suggestionStyle, suggestionTextColor, suggestionImageTintColor, dividerColor, emptyResultsScenario, emptySuggestionsScenario': function () {
      if (!this.model) return;
      this.applyProperties();
      this.model.refilter();
      this.model.reloadResults();
      this.sync();
    },
  },
  lifetimes: {
    created() {
      const model = new CYLSearchView();
      model.delegate = {
        searchViewDidShow: () => this.onModelShown(),
        searchViewDidClose: () => this.onModelClosed(),
        searchViewTextDidChange: (_, query) => this.triggerEvent('textchange', { text: query }),
        searchViewDidSubmitText: (_, query) => {
          this.triggerEvent('submit', { text: query });
          return false;
        },
        searchViewDidChangeFocus: (_, focused) => this.triggerEvent('focuschange', { focused }),
        searchViewDidSelectSuggestion: (_, suggestion, index) => this.triggerEvent('suggestionselect', { suggestion, index }),
        searchViewDidSelectResult: (_, result, index) => this.triggerEvent('selectresult', { result, index }),
        searchViewVoiceButtonClicked: () => this.triggerEvent('voicetap'),
        // UIKit's updateSearchResults: every change of the text, the empty text on the first activation and on clear.
        searchViewUpdateResults: (_, query) => this.triggerEvent('updateresults', { text: query }),
        searchViewHistoryDidChange: (_, history) => this.triggerEvent('historychange', { history }),
        searchViewWillShow: () => this.triggerEvent('willpresent'),
        searchViewWillClose: () => this.triggerEvent('willdismiss'),
      };
      model.searchBarView.keyboardHandler = (shown) => this.setData({ focus: shown });
      // The pull of the results list (or beginRefreshing()) calls this: the JavaScript handler, then the event.
      model.refreshHandler = () => {
        if (this.refreshHandlerFunction) this.refreshHandlerFunction();
        this.triggerEvent('refresh');
      };
      this.model = model;
      this.propertyDataSource = { searchViewResultsForQuery: () => (Array.isArray(this.properties.results) ? this.properties.results : []) };
    },
    attached() {
      const model = this.model;
      model.suggestionCacheName = this.properties.cacheName;
      model.suggestions = this.properties.suggestions;
      this.applyProperties();
      if (Array.isArray(this.properties.results)) model.resultsDataSource = this.propertyDataSource;
      let pageStyle = '';
      let barInsets = '';
      if (this.properties.coversNavigationBar) {
        const metrics = cylNavigationMetrics();
        pageStyle = `padding-top: ${metrics.statusBarHeight}px;`;
        barInsets = `${(metrics.navigationBarHeight - 36) / 2}px ${metrics.trailingInset}px ${(metrics.navigationBarHeight - 36) / 2}px 4px`;
      }
      this.setData({
        pageStyle,
        barInsets,
        labels: {
          dismiss: text('search.cancel'), recent: text('search.recent'), clear: text('search.clearRecent'), suggestions: text('search.suggestions'),
        },
      });
      this.updateRefreshes();
      // The list screen draws the content itself, in its scroller with the bar; the chain below is the search's layer.
      if (this.properties.showsSearchBar) this.setData({ showsContent: false });
      if (this.properties.inline && !this.properties.showsSearchBar) {
        // Inline: open at once, without raising the keyboard.
        model.focusesSearchFieldOnShow = false;
        model.showSearch(false);
        model.focusesSearchFieldOnShow = this.properties.focusesSearchFieldOnShow;
      }
      model.reloadResults();
      this.sync();
    },
    ready() {
      if (this.properties.showsSearchBar) this.measureHeader();
    },
  },
  methods: {
    applyProperties() {
      const p = this.properties;
      const model = this.model;
      model.suggestionStyle = p.suggestionStyle;
      model.focusesSearchFieldOnShow = p.focusesSearchFieldOnShow;
      model.showsSuggestionCacheHeader = p.showsSuggestionCacheHeader;
      model.showsEmptyResultsPlaceholder = p.showsEmptyResultsPlaceholder;
      // An inline search view never closes, so a submitted query keeps it open.
      model.closesOnSubmit = p.closesOnSubmit && !p.inline;
      model.showsResultsForEmptyQuery = p.showsResultsForEmptyQuery;
      model.emptyResultsScenario = p.emptyResultsScenario;
      model.emptySuggestionsScenario = p.emptySuggestionsScenario;
      model.showsSuggestionsLaunchView = p.showsSuggestionsLaunchView;
      model.showsLaunchView = p.showsLaunchView;
      model.scrimColor = p.scrimColor || p.dimmingColor || undefined;
      model.highlightsResultMatches = p.highlightsResultMatches || p.highlightsMatches;
      model.resultMatchHighlightColor = p.resultMatchHighlightColor || p.highlightColor || undefined;
      model.resultsHeaderTextColor = p.resultsHeaderTextColor || undefined;
      model.suggestionCacheFooterTitle = p.suggestionCacheFooterTitle || undefined;
      model.noResultsText = p.noResultsText || undefined;
      model.suggestionsFoldedRowCount = p.foldedRowCount;
      model.suggestionTextColor = p.suggestionTextColor || undefined;
      model.suggestionImageTintColor = p.suggestionImageTintColor || undefined;
      model.dividerColor = p.dividerColor || undefined;
      model.showsSearchBar = p.showsSearchBar;
      model.hidesSearchBarInitially = p.hidesSearchBarInitially;
      model.hidesSearchBarWhenEmptyViewShowing = p.hidesSearchBarWhenEmptyViewShowing;
      model.snapsHeaderSearchBar = p.snapsHeaderSearchBar;
      model.supportsSwipeToDismissSearch = p.supportsSwipeToDismissSearch;
    },
    /**
     * Sets the function that gives the line over the results: `(query) => text` (iOS `resultsHeaderTitleProvider`);
     * undefined or an empty text shows none.
     */
    setResultsHeaderTitleProvider(provider) {
      this.model.resultsHeaderTitleProvider = provider;
      this.sync();
    },
    onAnimationSpeedChange(value) {
      this.setData({ playbackSpeed: cylClampAnimationSpeed(value) });
    },
    onSuggestionsChange(value) {
      if (!this.model) return;
      this.model.suggestions = value;
      this.sync();
    },
    onCacheNameChange(value) {
      if (!this.model) return;
      this.model.suggestionCacheName = value;
      this.sync();
    },
    onResultsChange(value) {
      if (!this.model) return;
      if (Array.isArray(value)) this.model.resultsDataSource = this.propertyDataSource;
      else if (this.model.resultsDataSource === this.propertyDataSource) this.model.resultsDataSource = undefined;
      this.model.reloadResults();
      this.sync();
    },
    updateRefreshes() {
      this.setData({ refreshes: this.properties.refresherEnabled || typeof this.refreshHandlerFunction === 'function' });
    },
    // Copies the model's state into the data the template draws.
    sync() {
      const model = this.model;
      // The tag list takes a new configuration only when the tags or the colors changed: a keystroke keeps the fold state.
      const tagConfiguration = this.properties.suggestionStyle === 'tags' ? model.suggestionTagConfiguration(this.isDark()) : null;
      const tagKey = JSON.stringify(tagConfiguration);
      const tagsChanged = tagKey !== this.tagKey;
      this.tagKey = tagKey;
      this.setData({
        ...(tagsChanged ? { tagConfiguration } : {}),
        open: model.isSearchOpen,
        query: model.query,
        shownSuggestions: model.filteredSuggestions,
        showsCachedQueries: model.showsCachedQueries,
        showsCacheHeader: model.showsCachedQueries && model.showsSuggestionCacheHeader,
        showsEmptyResults: model.showsEmptyResults,
        showsEmptySuggestions: model.showsEmptySuggestions,
        showsResults: model.showsResults,
        resultsHeaderTitle: model.resultsHeaderTitle || '',
        cacheFooterTitle: model.suggestionCacheFooter || '',
        shownResults: model.searchResults.map((result) => model.resultCell(result)),
        showsLaunch: model.showsLaunch,
        showsDimming: model.showsDimming,
        emptyView: model.emptyView ? { text: model.emptyView.text, detailText: model.emptyView.detailText, buttonTitle: model.emptyView.buttonTitle } : null,
        emptyInContent: model.emptyViewInContent,
        headerHidden: model.hidesHeaderBar,
      });
    },
    // The system's dark mode, for the tag colors the page did not set.
    isDark() {
      try {
        return (wx.getAppBaseInfo ? wx.getAppBaseInfo() : {}).theme === 'dark';
      } catch (error) {
        return false;
      }
    },
    // The model opened: the page is drawn hidden, then the next frame runs the open transition.
    onModelShown() {
      const animated = this.showAnimated !== false;
      this.presents = (this.presents || 0) + 1;
      this.setData({ visible: true, entered: !animated });
      if (animated) setTimeout(() => this.setData({ entered: true }), 30);
      this.triggerEvent('show');
      setTimeout(() => this.triggerEvent('didpresent'), animated ? this.model.animationDuration * 1000 : 0);
    },
    // The model closed (a call, the back arrow, Cancel, a submitted query): the close transition, then the page goes.
    onModelClosed() {
      const animated = this.closeAnimated !== false;
      this.closeAnimated = true;
      // A present that started while this dismiss ran overtakes it: no diddismiss for it (iOS generation guard).
      const presents = this.presents || 0;
      this.setData({ entered: false, focus: false, swipeX: 0 });
      setTimeout(() => {
        if (presents !== (this.presents || 0)) return;
        if (!this.model.isSearchOpen) this.setData({ visible: false });
        this.triggerEvent('diddismiss');
      }, animated ? this.model.animationDuration * 1000 : 0);
      this.triggerEvent('close');
      this.endHeaderSearch();
    },
    /**
     * Opens the search view (iOS `showSearch(animated:)`); `completion` runs once it is open.
     */
    showSearch(animated = true, completion = undefined) {
      this.showAnimated = animated !== false;
      this.model.showSearch(animated !== false, completion);
      this.showAnimated = true;
      this.sync();
    },
    /**
     * Closes the search view (iOS `closeSearch(animated:completion:)`); `completion` runs once it is closed. An
     * inline search view stays open and runs `completion` at once.
     */
    closeSearch(animated = true, completion = undefined) {
      if (this.properties.inline) {
        if (completion) completion();
        return;
      }
      this.closeAnimated = animated !== false;
      this.model.closeSearch(animated !== false, completion);
      this.sync();
    },
    /**
     * True while the search view is open (iOS `isSearchOpen`).
     */
    isSearchOpen() {
      return this.model.isSearchOpen;
    },
    // The page container left: a back press, or closeSearch already ran.
    onBackLeave() {
      if (this.data.open) this.closeSearch();
    },
    /**
     * Sets the query and, with `submit`, submits it (iOS `-setQuery:submit:`).
     */
    setQuery(query, submit) {
      this.model.setQuery(query, !!submit);
      this.triggerEvent('textchange', { text: this.model.query });
      this.sync();
    },
    /**
     * Sets the data source of the results (iOS `resultsDataSource`): `searchViewResultsForQuery(searchView, query)`
     * and, optionally, `searchViewConfigureResultCell(searchView, cell, result)`; null removes it.
     */
    setResultsDataSource(dataSource) {
      this.model.resultsDataSource = dataSource || undefined;
      this.model.reloadResults();
      this.sync();
    },
    /**
     * Queries the data source for the current query and reloads the results (iOS `reloadResults()`).
     */
    reloadResults() {
      this.model.reloadResults();
      this.sync();
    },
    /**
     * The results of the current query (iOS `searchResults`).
     */
    searchResults() {
      return this.model.searchResults;
    },
    /**
     * Sets the pull-to-refresh handler of the results (iOS `refreshHandler`); it runs before the `refresh` event. A
     * handler adds the pull-to-refresh like `refresherEnabled`; null removes it (unless `refresherEnabled` is set).
     */
    setRefreshHandler(handler) {
      this.refreshHandlerFunction = typeof handler === 'function' ? handler : undefined;
      this.updateRefreshes();
    },
    /**
     * Starts refreshing the results, as a pull does (iOS `beginRefreshing()`).
     */
    beginRefreshing() {
      if (this.model.isRefreshing) return;
      const refresh = this.selectComponent('#cyl-refresh');
      if (refresh && this.data.refreshes) refresh.beginRefreshing();
      else this.model.beginRefreshing();
    },
    /**
     * Ends refreshing the results (iOS `endRefreshing()`); call it on every completion path.
     */
    endRefreshing() {
      this.model.endRefreshing();
      const refresh = this.selectComponent('#cyl-refresh');
      if (refresh) refresh.endRefreshing();
    },
    /**
     * True while the results are refreshing (iOS `isRefreshing`).
     */
    isRefreshing() {
      return this.model.isRefreshing;
    },
    // The pull of cyl-refresh (CYLRefreshNormalHeader).
    onRefresh() {
      this.model.beginRefreshing();
    },
    /**
     * The empty results placeholder (an instance of the cyl-empty-view node) while it shows, else null (iOS
     * `emptyResultsView`).
     */
    emptyResultsView() {
      return this.data.showsEmptyResults ? this.selectComponent('#cyl-empty-view') : null;
    },
    /**
     * The empty suggestions placeholder while it shows, else null (iOS `emptySuggestionsView`).
     */
    emptySuggestionsView() {
      return this.data.showsEmptySuggestions ? this.selectComponent('#cyl-empty-view') : null;
    },
    /**
     * Restarts the placeholder animation that shows from progress 0 ("Play all"); does nothing without one.
     */
    playAnimationFromStart() {
      const view = this.selectComponent('#cyl-empty-view');
      if (view && typeof view.playAll === 'function') view.playAll();
    },
    onTextChange(event) {
      this.model.textChanged(event.detail.text);
      this.sync();
    },
    onSubmit(event) {
      this.model.setQuery(event.detail.text, true);
      this.sync();
    },
    onFocusChange(event) {
      this.model.focusChanged(event.detail.focused);
      // The list screen: focusing the header bar starts the search (UIKit activates on a tap in the bar).
      if (event.detail.focused && this.properties.showsSearchBar && !this.model.isSearchOpen) this.beginHeaderSearch(false);
    },
    onBarClose() {
      // Cancel clears the text (UIKit) and ends the search.
      if (this.properties.showsSearchBar) this.model.setQuery('', false);
      this.closeSearch();
    },
    // The list screen's search starts: the page scrolls to the top and holds, the bar shows Cancel unless the host did.
    beginHeaderSearch(focus) {
      const bar = this.barComponent();
      this.autoCancel = !!bar && bar.model && !bar.model.showsCancelButton;
      if (this.autoCancel) bar.setShowsCancelButton(true, true);
      this.setData({ scrollTop: 0, scrollAnimated: true });
      const keep = this.model.focusesSearchFieldOnShow;
      this.model.focusesSearchFieldOnShow = focus;
      this.showSearch(true);
      this.model.focusesSearchFieldOnShow = keep;
    },
    // The search ended: Cancel goes again if it came with the search.
    endHeaderSearch() {
      if (!this.properties.showsSearchBar) return;
      const bar = this.barComponent();
      if (this.autoCancel && bar) bar.setShowsCancelButton(false, true);
      this.autoCancel = false;
    },
    // The bar of the page: the header bar of the list screen, else the page's own.
    barComponent() {
      return this.selectComponent('#cyl-header-bar') || this.selectComponent('#cyl-bar');
    },
    /**
     * Starts or ends the search from code (iOS `setActive(_:animated:)`).
     */
    setActive(active, animated = true) {
      if (!active) {
        this.closeSearch(animated);
      } else if (this.properties.showsSearchBar) {
        if (!this.model.isSearchOpen) this.beginHeaderSearch(true);
      } else {
        this.showSearch(animated);
      }
    },
    /**
     * True while the search is active (iOS `isActive`).
     */
    isActive() {
      return this.model.isSearchOpen;
    },
    /**
     * Shows the empty view with your text under the bar (iOS `showEmptyView(text:detailText:buttonTitle:buttonAction:)`);
     * while the search is not active it takes the content's place, and the bar leaves with it when
     * `hidesSearchBarWhenEmptyViewShowing` is set. Nothing shows while the text is empty and the search is active.
     */
    showEmptyView(text, detailText, buttonTitle, buttonAction) {
      this.emptyButtonAction = typeof buttonAction === 'function' ? buttonAction : undefined;
      this.model.showEmptyView(text, detailText, buttonTitle, buttonAction);
      this.sync();
      if (this.data.headerHidden) this.setData({ scrollTop: 0 });
    },
    /**
     * Hides the empty view (iOS `hideEmptyView()`); the bar of the list screen comes back scrolled out when
     * `hidesSearchBarInitially` is set.
     */
    hideEmptyView() {
      this.model.hideEmptyView();
      this.emptyButtonAction = undefined;
      this.sync();
      if (this.properties.hidesSearchBarInitially) this.setData({ scrollTop: this.data.headerHeight });
    },
    /**
     * True while the empty view shows (iOS `isEmptyViewShowing`).
     */
    isEmptyViewShowing() {
      return this.model.isEmptyViewShowing;
    },
    onEmptyButtonTap() {
      if (this.emptyButtonAction) this.emptyButtonAction();
    },
    /**
     * The submitted queries, newest first, no duplicates (iOS `historyStore.cachedQueries()`); `historychange` tells
     * when they change, also while a launch view stays on screen.
     */
    history() {
      return this.model.history;
    },
    /**
     * Clears the history (iOS `historyStore.removeAllQueries()`).
     */
    clearHistory() {
      this.model.clearHistory();
      this.sync();
    },
    /**
     * Shows or hides Cancel on the bar, animated or not (iOS `setShowsCancelButton(_:animated:)`).
     */
    setShowsCancelButton(shows, animated) {
      const bar = this.barComponent();
      if (bar) bar.setShowsCancelButton(shows, animated);
    },
    /**
     * Shows or hides the leading view before the field (iOS `setShowsLeadingView(_:animated:)`).
     */
    setShowsLeadingView(shows, animated) {
      const bar = this.barComponent();
      if (bar) bar.setShowsLeadingView(shows, animated);
    },
    /**
     * Shows or hides the trailing accessory views of the field (iOS `setShowsTrailingAccessoryViews(_:animated:)`).
     */
    setShowsTrailingAccessoryViews(shows, animated) {
      const bar = this.barComponent();
      if (bar) bar.setShowsTrailingAccessoryViews(shows, animated);
    },
    /**
     * Deprecated: `setShowsLeadingView`.
     */
    setShowsLeadingAccessoryView(shows, animated) {
      this.setShowsLeadingView(shows, animated);
    },
    /**
     * Deprecated: `setShowsTrailingAccessoryViews`.
     */
    setShowsTrailingAccessoryView(shows, animated) {
      this.setShowsTrailingAccessoryViews(shows, animated);
    },
    /**
     * The field's margins per state from a function `(bar, active) => { top, left, bottom, right }` (iOS
     * `textFieldMarginsProvider`).
     */
    setTextFieldMarginsProvider(provider) {
      const bar = this.barComponent();
      if (bar) bar.setTextFieldMarginsProvider(provider);
    },
    /**
     * The Cancel button's margins per state from a function (iOS `cancelButtonMarginsProvider`).
     */
    setCancelButtonMarginsProvider(provider) {
      const bar = this.barComponent();
      if (bar) bar.setCancelButtonMarginsProvider(provider);
    },
    // The header bar's height, measured; with `hidesSearchBarInitially` the content starts scrolled by it.
    measureHeader() {
      const query = this.createSelectorQuery();
      query.select('.cyl-header-bar').boundingClientRect();
      query.exec(([rect]) => {
        if (!rect || !(rect.height > 0)) return;
        this.setData({ headerHeight: Math.ceil(rect.height) });
        if (this.properties.hidesSearchBarInitially) this.setData({ scrollTop: Math.ceil(rect.height) });
      });
    },
    // The content scrolled: once it stops (and no finger is down), a bar half scrolled out settles (iOS #1160).
    onContentScroll(event) {
      this.scrollTopNow = event.detail.scrollTop;
      this.scheduleSettle();
    },
    onContentTouchStart() {
      this.touching = true;
      clearTimeout(this.settleTimer);
    },
    onContentTouchEnd() {
      this.touching = false;
      this.scheduleSettle();
    },
    scheduleSettle() {
      clearTimeout(this.settleTimer);
      if (this.touching) return;
      this.settleTimer = setTimeout(() => this.settleHeader(), 120);
    },
    /**
     * Settles the header bar fully shown or fully hidden when the scrolling ended inside its band (iOS
     * `snapsHeaderSearchBar`); returns the offset it moved to, or undefined.
     */
    settleHeader() {
      const p = this.properties;
      if (!p.showsSearchBar || !p.snapsHeaderSearchBar || this.model.isSearchOpen || this.data.headerHidden) return undefined;
      const offset = this.scrollTopNow || 0;
      const target = cylSnapHeaderOffset(offset, this.data.headerHeight);
      if (target === offset) return undefined;
      // Scroll-top follows the data only when it changes: set the real offset first, then the target animated.
      this.setData({ scrollTop: offset, scrollAnimated: false });
      wx.nextTick(() => this.setData({ scrollTop: target, scrollAnimated: true }));
      return target;
    },
    // A swipe from the left edge ends the search (iOS supportsSwipeToDismissSearch): the page follows the finger.
    onPageTouchStart(event) {
      if (!this.properties.supportsSwipeToDismissSearch || !this.model.isSearchOpen) return;
      const touch = event.touches[0];
      this.swipe = touch.clientX <= 24 ? { startX: touch.clientX, startY: touch.clientY || 0, startTime: Date.now(), began: false } : undefined;
    },
    // The swipe begins when the touch moved right past the slop, more than up or down (cylEdgeSwipeBegins, iOS
    // CYLSearchEdgeSwipe); any other first move fails it, so a vertical drag from the edge scrolls as usual.
    onPageTouchMove(event) {
      const swipe = this.swipe;
      if (!swipe) return;
      const touch = event.touches[0];
      const deltaX = touch.clientX - swipe.startX;
      const deltaY = (touch.clientY || 0) - swipe.startY;
      if (!swipe.began) {
        if (Math.abs(deltaX) <= 10 && Math.abs(deltaY) <= 10) return;
        if (!cylEdgeSwipeBegins(swipe.startX, deltaX, deltaY)) {
          this.swipe = undefined;
          return;
        }
        swipe.began = true;
      }
      if (deltaX > 0) this.setData({ swipeX: deltaX });
    },
    onPageTouchEnd(event) {
      const swipe = this.swipe;
      this.swipe = undefined;
      if (!swipe || !swipe.began) return;
      const deltaX = event.changedTouches[0].clientX - swipe.startX;
      const velocity = deltaX / Math.max(1, Date.now() - swipe.startTime);
      let width = 375;
      try {
        width = (wx.getWindowInfo ? wx.getWindowInfo() : wx.getSystemInfoSync()).windowWidth || width;
      } catch (error) {
        width = 375;
      }
      if (cylSwipeShouldDismiss(swipe.startX, deltaX, width, velocity)) this.closeSearch(false);
      else this.setData({ swipeX: 0 });
    },
    onDimmingTap() {
      this.closeSearch();
    },
    onVoiceTap() {
      this.model.searchBarView.voiceTapped();
    },
    /**
     * A tag list inside the content page starts or ends a drag (`reorderingchange` { reordering }) or a smear
     * (`smearingchange` { smearing }). The content page holds its own scrolling only while one of them is active, from the
     * start of the gesture until it ends or is cancelled; at every other time, in the list's editing mode too, it scrolls.
     */
    onContentGesture(event) {
      const detail = event.detail || {};
      this.contentGestures = { ...this.contentGestures, [event.type]: !!(detail.reordering || detail.smearing) };
      const held = Object.values(this.contentGestures).some(Boolean);
      if (held !== this.data.contentScrollHeld) this.setData({ contentScrollHeld: held });
    },
    onItemSelect(event) {
      this.triggerEvent('itemselect', event.detail);
      if (event.detail.item && event.detail.item.style === 'text') {
        this.model.submitted();
        this.sync();
      }
    },
    // A tag of the tag list (`tagtap` { item }) or a row of the list style (`data-index`).
    onSuggestionTap(event) {
      const index = event.detail && event.detail.item !== undefined ? event.detail.item : Number(event.currentTarget.dataset.index);
      this.model.suggestionSelected(this.data.shownSuggestions[index], index);
      this.triggerEvent('textchange', { text: this.model.query });
      this.sync();
    },
    onResultTap(event) {
      const index = Number(event.currentTarget.dataset.index);
      this.model.resultSelected(this.model.searchResults[index], index);
    },
    onClear() {
      this.model.clearSuggestionCache();
      this.sync();
    },
  },
});
