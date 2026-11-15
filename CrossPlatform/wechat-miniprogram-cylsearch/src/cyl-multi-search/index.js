const { CYLMultiSearchView } = require('../core/CYLMultiSearchView');
const { CYLSearchResources } = require('../core/CYLSearchResources');
const { cylFormatString } = require('../cyl-search/cyl_format');

const text = (key) => CYLSearchResources.localizedString(undefined, key);

/**
 * Several searches side by side (iOS `CYLMultiSearchView`, iammert MultiSearchView): the search button at the
 * trailing end starts a new search or completes the one being typed; a completed search becomes an item in a
 * horizontally scrolling row, the selected one underlined, each with a remove button. Draws a `CYLMultiSearchView`
 * (`this.model`).
 *
 * Events, as the iOS delegate: `textchange` `{ text, index }`, `complete` `{ text, index }`, `remove` `{ index }`,
 * `select` `{ text, index }`. Methods: `search()`, `completeSearch()`, `addSearchText(text)`, `selectItem(index)`,
 * `removeItem(index)`.
 */
Component({
  properties: {
    placeholder: { type: String, value: '' },
    fontSize: { type: Number, value: 17 },
    textColor: { type: String, value: '' },
    placeholderColor: { type: String, value: '' },
    maximumTextLength: { type: Number, value: 0 },
    minimumTextLength: { type: Number, value: 3 },
    returnKeyType: { type: String, value: 'search' },
    indicatorColor: { type: String, value: '' },
    unselectedItemAlpha: { type: Number, value: 0.5 },
    searchFieldWidth: { type: Number, value: 160 },
  },
  data: { items: [], typing: false, typedText: '', selectedIndex: -1, focus: false, labels: {}, placeholderText: '' },
  lifetimes: {
    attached() {
      const model = new CYLMultiSearchView();
      model.maximumTextLength = this.properties.maximumTextLength;
      model.minimumTextLength = this.properties.minimumTextLength;
      model.delegate = {
        multiSearchViewTextDidChange: (_, value, index) => this.triggerEvent('textchange', { text: value, index }),
        multiSearchViewDidCompleteSearch: (_, value, index) => this.triggerEvent('complete', { text: value, index }),
        multiSearchViewDidRemoveItemAtIndex: (_, index) => this.triggerEvent('remove', { index }),
        multiSearchViewDidSelectItem: (_, value, index) => this.triggerEvent('select', { text: value, index }),
      };
      this.model = model;
      this.setData({
        placeholderText: this.properties.placeholder || text('search.field'),
        labels: { add: text('multisearch.add'), remove: text('multisearch.remove') },
      });
      this.sync();
    },
  },
  methods: {
    sync() {
      const model = this.model;
      const completed = model.completedSearchTexts;
      const itemFormat = text('multisearch.item');
      this.setData({
        typing: model.isInSearchMode,
        typedText: model.typedText,
        selectedIndex: model.selectedIndex,
        items: completed.map((value, index) => ({
          text: value,
          label: `${value}, ${cylFormatString(itemFormat, [index + 1, completed.length])}`,
        })),
      });
    },
    search() {
      this.model.search();
      this.sync();
      this.setData({ focus: true });
    },
    completeSearch() {
      this.model.completeSearch();
      this.setData({ focus: false });
      this.sync();
    },
    addSearchText(value) {
      this.model.addSearchText(value);
      this.sync();
    },
    selectItem(index) {
      this.model.selectItemAtIndex(index);
      this.setData({ focus: false });
      this.sync();
    },
    removeItem(index) {
      this.model.removeItemAtIndex(index);
      this.sync();
    },
    // The search button: a new search, or the one being typed is completed.
    onSearchButton() {
      if (this.model.isInSearchMode) this.completeSearch();
      else this.search();
    },
    onInput(event) {
      this.model.textChanged(event.detail.value);
      // The model enforces maximumTextLength; the field shows what it kept.
      this.setData({ typedText: this.model.typedText });
    },
    onConfirm() {
      this.completeSearch();
    },
    onItemTap(event) {
      this.selectItem(Number(event.currentTarget.dataset.index));
    },
    onRemoveTap(event) {
      this.removeItem(Number(event.currentTarget.dataset.index));
    },
  },
});
