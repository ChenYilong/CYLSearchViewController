const { CYLSearchView, cylFoldTags, cylClampAnimationSpeed } = require('../core/CYLSearchView');
const { CYLSearchResources, cylNavigationMetrics } = require('../core/CYLSearchResources');

const TAG_SPACING = 12;
const TAG_SIDE_INSET = 16;
// The fold chevron's labels: CollectionViewClassifyMenu's CYLMenuExpand / CYLMenuCollapse (CYLClassifyMenu.strings).
const FOLD_LABELS = {
  en: ['More', 'Less'], 'zh-Hans': ['更多', '收起'], 'zh-Hant': ['更多', '收合'],
};

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
 * (with `showsContent`: your own view in place of the suggestions, iOS `contentView`).
 */
Component({
  options: { multipleSlots: true },
  properties: {
    suggestions: { type: Array, value: [], observer: 'onSuggestionsChange' },
    suggestionStyle: { type: String, value: 'list' },
    placeholder: { type: String, value: '' },
    searchBarStyle: { type: String, value: 'plain' },
    items: { type: Array, value: [] },
    cacheName: { type: String, value: 'CYLSearchView', observer: 'onCacheNameChange' },
    focusesSearchFieldOnShow: { type: Boolean, value: true },
    showsEmptyResultsPlaceholder: { type: Boolean, value: false },
    // NO keeps the page open after a submitted query (iOS closesOnSubmit, or a delegate that handles the query).
    closesOnSubmit: { type: Boolean, value: true },
    foldedRowCount: { type: Number, value: 2 },
    // The CYLTableViewPlaceHolder scenario shown while a non-empty query matches nothing or the results are empty
    // (iOS emptyResultsScenario) and while the query and the cache are empty (iOS emptySuggestionsScenario). The
    // abstract node cyl-empty-view draws it: cyl-placeholder-miniprogram's <cyl-placeholder> by default; pass a view
    // of yours (for example one that gives <cyl-placeholder> a Lottie player) with generic:cyl-empty-view.
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
  },
  data: {
    playbackSpeed: 1, shownSuggestions: [], visibleTags: [], needsFold: false, open: false, visible: false, entered: false,
    focus: false, query: '', folded: true, showsCachedQueries: false, showsEmptyResults: false, showsEmptySuggestions: false,
    showsResults: false, shownResults: [], refreshes: false, labels: {}, pageStyle: '', barInsets: '',
  },
  observers: {
    'showsEmptyResultsPlaceholder, closesOnSubmit, showsResultsForEmptyQuery, focusesSearchFieldOnShow, suggestionStyle, emptyResultsScenario, emptySuggestionsScenario': function () {
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
      const language = CYLSearchResources.languageFor();
      this.setData({
        pageStyle,
        barInsets,
        labels: {
          recent: text('search.recent'), clear: text('search.clearRecent'), suggestions: text('search.suggestions'),
          showMore: (FOLD_LABELS[language] || FOLD_LABELS.en)[0],
          showLess: (FOLD_LABELS[language] || FOLD_LABELS.en)[1],
        },
      });
      this.updateRefreshes();
      if (this.properties.inline) {
        // Inline: open at once, without raising the keyboard.
        model.focusesSearchFieldOnShow = false;
        model.showSearch(false);
        model.focusesSearchFieldOnShow = this.properties.focusesSearchFieldOnShow;
      }
      model.reloadResults();
      this.sync();
    },
  },
  methods: {
    applyProperties() {
      const p = this.properties;
      const model = this.model;
      model.suggestionStyle = p.suggestionStyle;
      model.focusesSearchFieldOnShow = p.focusesSearchFieldOnShow;
      model.showsEmptyResultsPlaceholder = p.showsEmptyResultsPlaceholder;
      // An inline search view never closes, so a submitted query keeps it open.
      model.closesOnSubmit = p.closesOnSubmit && !p.inline;
      model.showsResultsForEmptyQuery = p.showsResultsForEmptyQuery;
      model.emptyResultsScenario = p.emptyResultsScenario;
      model.emptySuggestionsScenario = p.emptySuggestionsScenario;
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
      this.setData({
        open: model.isSearchOpen,
        query: model.query,
        shownSuggestions: model.filteredSuggestions,
        showsCachedQueries: model.showsCachedQueries,
        showsEmptyResults: model.showsEmptyResults,
        showsEmptySuggestions: model.showsEmptySuggestions,
        showsResults: model.showsResults,
        shownResults: model.searchResults.map((result) => model.resultCell(result)),
      });
      if (this.properties.suggestionStyle === 'tags' && !model.showsResults) this.foldTags();
    },
    // The tags end with the fold chevron, `foldedRowCount` rows while folded (iOS suggestionsFoldControl inline, as on
    // the Discover page): every tag is measured on one hidden line, then the tags of the first rows are kept.
    foldTags() {
      const all = this.data.shownSuggestions;
      const rows = this.properties.foldedRowCount;
      if (!all.length || rows <= 0) {
        this.setData({ visibleTags: all, needsFold: false });
        return;
      }
      wx.nextTick(() => {
        const query = this.createSelectorQuery();
        query.selectAll('.cyl-measure-tag').boundingClientRect();
        query.select('.cyl-measure-chevron').boundingClientRect();
        query.select('.cyl-page').boundingClientRect();
        query.exec(([tags, chevron, page]) => {
          if (!tags || tags.length !== all.length || !page) return;
          const { visibleCount, needsFold } = cylFoldTags(tags.map((tag) => tag.width), page.width - TAG_SIDE_INSET * 2,
            TAG_SPACING, chevron ? chevron.width : 40, rows);
          this.setData({ needsFold, visibleTags: needsFold && this.data.folded ? all.slice(0, visibleCount) : all });
        });
      });
    },
    // The model opened: the page is drawn hidden, then the next frame runs the open transition.
    onModelShown() {
      const animated = this.showAnimated !== false;
      this.setData({ visible: true, entered: !animated });
      if (animated) setTimeout(() => this.setData({ entered: true }), 30);
      this.triggerEvent('show');
    },
    // The model closed (a call, the back arrow, Cancel, a submitted query): the close transition, then the page goes.
    onModelClosed() {
      const animated = this.closeAnimated !== false;
      this.closeAnimated = true;
      this.setData({ entered: false, focus: false });
      setTimeout(() => {
        if (!this.model.isSearchOpen) this.setData({ visible: false });
      }, animated ? this.model.animationDuration * 1000 : 0);
      this.triggerEvent('close');
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
    },
    onBarClose() {
      this.closeSearch();
    },
    onVoiceTap() {
      this.model.searchBarView.voiceTapped();
    },
    onItemSelect(event) {
      this.triggerEvent('itemselect', event.detail);
      if (event.detail.item && event.detail.item.style === 'text') {
        this.model.submitted();
        this.sync();
      }
    },
    onSuggestionTap(event) {
      const index = Number(event.currentTarget.dataset.index);
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
    onToggleFold() {
      this.setData({ folded: !this.data.folded });
      this.foldTags();
    },
  },
});
