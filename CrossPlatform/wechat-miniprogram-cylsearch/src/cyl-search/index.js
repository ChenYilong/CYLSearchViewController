const { CYLSearchViewModel } = require('./cyl_search_view_model');
const { cylClampAnimationSpeed } = require('./cyl_search_animation_playback');
const { cylNavigationMetrics } = require('./cyl_navigation_metrics');
const { cylFoldTags } = require('./cyl_tag_fold');

const TAG_SPACING = 12;
const TAG_SIDE_INSET = 16;
// The fold chevron's labels: CollectionViewClassifyMenu's CYLMenuExpand / CYLMenuCollapse (CYLClassifyMenu.strings).
const FOLD_LABELS = {
  en: ['More', 'Less'], 'zh-Hans': ['更多', '收起'], 'zh-Hant': ['更多', '收合'],
};
const { CYLSearchResources } = require('../core/CYLSearchResources');

const text = (key) => CYLSearchResources.localizedString(undefined, key);

/**
 * The search page component (iOS `CYLSearchView`): draws a `CYLSearchViewModel`. Set `suggestions`; call `show()` to
 * open it (the field is focused unless `focusesSearchFieldOnShow` is false). The bar has a back arrow that closes
 * the page (iOS `navigationIcon = .arrow`); each suggestion row starts with a magnifier.
 *
 * Events: `submit` `{ text }`, `close`, `textchange` `{ text }`, `suggestionselect` `{ suggestion, index }`,
 * `focuschange` `{ focused }`, `voicetap`, `itemselect`.
 * Methods: `show()`, `close()`, `setQuery(text, submit)`, `playAnimationFromStart()`. Abstract node: `cyl-empty-view`
 * (properties `scenario`, `animated`, `loop`, `speed`; method `playAll()`), the empty placeholders.
 * Slots: `placeholder-footer` (under the empty placeholder); `content` (with `showsContent`: your own view in place of
 * the suggestions, iOS `contentView`).
 */
Component({
  options: { multipleSlots: true },
  properties: {
    suggestions: { type: Array, value: [], observer: 'onSuggestionsChange' },
    suggestionStyle: { type: String, value: 'list' },
    placeholder: { type: String, value: '' },
    searchBarStyle: { type: String, value: 'plain' },
    items: { type: Array, value: [] },
    cacheName: { type: String, value: 'CYLSearchView' },
    focusesSearchFieldOnShow: { type: Boolean, value: true },
    showsEmptyResultsPlaceholder: { type: Boolean, value: false },
    // NO keeps the page open after a submitted query (iOS closesOnSubmit, or a delegate that handles the query).
    closesOnSubmit: { type: Boolean, value: true },
    foldedRowCount: { type: Number, value: 2 },
    // The CYLTableViewPlaceHolder scenario shown while a non-empty query matches nothing (iOS emptyResultsScenario,
    // CYLPlaceholderScenarioNoSearchResults by default) and while the query and the cache are empty (iOS
    // emptySuggestionsScenario, CYLPlaceholderScenarioNoContent). The abstract node cyl-empty-view draws it: by
    // default cyl-search-empty-view (CYLSearchPlaceholderView, no dependency); pass a view that draws
    // cyl-placeholder-miniprogram's <cyl-placeholder scenario> for CYLTableViewPlaceHolder's own placeholders.
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
    playbackSpeed: 1, shownSuggestions: [], visibleTags: [], needsFold: false, open: false, focus: false, query: '', folded: true,
    showsCachedQueries: false, showsEmptyResults: false, showsEmptySuggestions: false,
    labels: {}, pageStyle: '', barInsets: '',
  },
  lifetimes: {
    attached() {
      const model = new CYLSearchViewModel();
      model.suggestionCacheName = this.properties.cacheName;
      model.suggestionStyle = this.properties.suggestionStyle;
      model.focusesSearchFieldOnShow = this.properties.focusesSearchFieldOnShow;
      model.showsEmptyResultsPlaceholder = this.properties.showsEmptyResultsPlaceholder;
      model.closesOnSubmit = this.properties.closesOnSubmit;
      model.suggestions = this.properties.suggestions;
      model.delegate = {
        onSubmit: (_, query) => {
          this.triggerEvent('submit', { text: query });
          return false;
        },
        onClose: () => this.triggerEvent('close'),
        onSelectSuggestion: (_, suggestion, index) => this.triggerEvent('suggestionselect', { suggestion, index }),
      };
      this.model = model;
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
          recent: text('search.recent'), clear: text('search.clearRecent'), suggestions: text('search.suggestions'),
          showMore: (FOLD_LABELS[CYLSearchResources.languageFor()] || FOLD_LABELS.en)[0],
          showLess: (FOLD_LABELS[CYLSearchResources.languageFor()] || FOLD_LABELS.en)[1],
        },
      });
      this.sync();
    },
  },
  methods: {
    onAnimationSpeedChange(value) {
      this.setData({ playbackSpeed: cylClampAnimationSpeed(value) });
    },
    // Restarts the placeholder animation that shows from progress 0 ("Play all"); does nothing without one.
    playAnimationFromStart() {
      const view = this.selectComponent('#cyl-empty-view');
      if (view && typeof view.playAll === 'function') view.playAll();
    },
    onSuggestionsChange(value) {
      if (!this.model) return;
      this.model.suggestions = value;
      this.sync();
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
      });
      if (this.properties.suggestionStyle === 'tags') this.foldTags();
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
    show() {
      const { focus } = this.model.showSearch();
      this.setData({ focus });
      this.sync();
    },
    close() {
      this.model.closeSearch();
      this.setData({ focus: false });
      this.sync();
    },
    // The page container left: a back press, or `close` already ran.
    onBackLeave() {
      if (this.data.open) this.close();
    },
    /** Sets the query and, with `submit`, submits it (iOS `-setQuery:submit:`). */
    setQuery(query, submit) {
      this.model.setQuery(query, !!submit);
      this.triggerEvent('textchange', { text: this.model.query });
      this.sync();
    },
    onTextChange(event) {
      this.model.textChanged(event.detail.text);
      this.triggerEvent('textchange', { text: event.detail.text });
      this.sync();
    },
    onSubmit(event) {
      this.model.setQuery(event.detail.text, true);
      this.setData({ focus: false });
      this.sync();
    },
    onFocusChange(event) {
      this.model.focusChanged(event.detail.focused);
      this.triggerEvent('focuschange', { focused: event.detail.focused });
    },
    onVoiceTap() {
      this.triggerEvent('voicetap');
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
