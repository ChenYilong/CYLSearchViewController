const { CYLSearchViewModel } = require('./cyl_search_view_model');

/**
 * The search page component (iOS `CYLSearchView`): draws a `CYLSearchViewModel`. Set `suggestions`; call `show()` to
 * open it (the field is focused unless `focusesSearchFieldOnShow` is false). Events: `submit` `{ text }`, `close`,
 * `textchange` `{ text }`, `suggestionselect` `{ suggestion, index }`.
 */
Component({
  properties: {
    suggestions: { type: Array, value: [], observer: 'onSuggestionsChange' },
    suggestionStyle: { type: String, value: 'list' },
    placeholder: { type: String, value: '' },
    cancelButtonTitle: { type: String, value: 'Cancel' },
    searchBarStyle: { type: String, value: 'plain' },
    items: { type: Array, value: [] },
    cacheName: { type: String, value: 'CYLSearchView' },
    focusesSearchFieldOnShow: { type: Boolean, value: true },
    showsEmptyResultsPlaceholder: { type: Boolean, value: false },
    foldedRowCount: { type: Number, value: 2 },
    emptyResultsText: { type: String, value: 'No matching results' },
    emptySuggestionsText: { type: String, value: 'Nothing here yet' },
    recentTitle: { type: String, value: 'Recent searches' },
    clearLabel: { type: String, value: 'Clear recent searches' },
  },
  data: { open: false, focus: false, query: '', folded: true, filtered: [], showsCachedQueries: false, showsEmptyResults: false, showsEmptySuggestions: false },
  lifetimes: {
    attached() {
      const model = new CYLSearchViewModel();
      model.suggestionCacheName = this.properties.cacheName;
      model.suggestionStyle = this.properties.suggestionStyle;
      model.focusesSearchFieldOnShow = this.properties.focusesSearchFieldOnShow;
      model.showsEmptyResultsPlaceholder = this.properties.showsEmptyResultsPlaceholder;
      model.suggestions = this.properties.suggestions;
      model.delegate = {
        onSubmit: (_, text) => {
          this.triggerEvent('submit', { text });
          return false;
        },
        onClose: () => this.triggerEvent('close'),
        onSelectSuggestion: (_, suggestion, index) => this.triggerEvent('suggestionselect', { suggestion, index }),
      };
      this.model = model;
      this.sync();
    },
  },
  methods: {
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
        suggestions: model.filteredSuggestions,
        showsCachedQueries: model.showsCachedQueries,
        showsEmptyResults: model.showsEmptyResults,
        showsEmptySuggestions: model.showsEmptySuggestions,
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
      this.model.suggestionSelected(this.data.suggestions[index], index);
      this.sync();
    },
    onClear() {
      this.model.clearSuggestionCache();
      this.sync();
    },
    onToggleFold() {
      this.setData({ folded: !this.data.folded });
    },
  },
});
