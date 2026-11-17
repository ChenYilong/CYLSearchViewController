const { CYLSearchBarView, CYLSearchBarItem, CYLSearchBarMode } = require('../core/CYLSearchBarView');
const { CYLSearchResources, cylFormatString } = require('../core/CYLSearchResources');

const text = (key) => CYLSearchResources.localizedString(undefined, key);

/**
 * The search bar component (iOS `CYLSearchBarView`), drawing a `CYLSearchBarView` (`this.model`). With `mode`
 * "single" (the default): an optional navigation button, the rounded field (the magnifier, the text, the clear
 * button, the voice or submit button, the slot `trailing` and the appended `items`, plain values of
 * `CYLSearchBarItem.item`), then an optional Cancel button. With `mode` "multiple" (was `cyl-multi-search`): the
 * completed searches side by side, the selected one underlined with its remove button, the field of the search being
 * typed, and the new-search button at the end.
 *
 * Events: `textchange` `{ text }` (`{ text, index }` in the "multiple" mode), `submit` `{ text }`, `focuschange`
 * `{ focused }`, `cancel`, `itemselect` `{ item, index, selected }`, `navigationtap`, `voicetap`,
 * `tapwhilenoteditable` (with `editable` false), `iconifiedchange` `{ iconified }`; "multiple" mode:
 * `completesearch` `{ text, index }`, `removesearch` `{ index }`, `selectsearch` `{ text, index }`.
 * Methods: `setText(text, submit)`, `setIconified(iconified)`, `showKeyboard()`, `hideKeyboard()`; "multiple" mode:
 * `beginNewSearch()`, `completeSearch()`, `addSearch(text)`, `selectSearch(index)`, `removeSearch(index)`,
 * `searches()`.
 */
Component({
  options: { multipleSlots: true },
  properties: {
    // "single" (one search) or "multiple" (several searches side by side; iOS CYLSearchBarMode).
    mode: { type: String, value: 'single' },
    value: { type: String, value: '', observer: 'onValueChange' },
    placeholder: { type: String, value: '' },
    focus: { type: Boolean, value: false, observer: 'onFocusPropertyChange' },
    searchBarStyle: { type: String, value: 'plain' },
    searchIcon: { type: String, value: '../images/search.svg' },
    showsSearchIcon: { type: Boolean, value: true },
    showsCancelButton: { type: Boolean, value: false },
    cancelButtonTitle: { type: String, value: '' },
    items: { type: Array, value: [], observer: 'onItemsChange' },
    // The navigation button before the field (iOS navigationIcon): "none", "arrow" (back) or "search".
    navigationIcon: { type: String, value: 'none' },
    navigationAccessibilityLabel: { type: String, value: '' },
    navigationColor: { type: String, value: '' },
    // The field (iOS fieldHeight, fieldCornerRadius, fieldBackgroundColor, fieldBorderColor, fieldBorderWidth,
    // fieldShadowOpacity, contentInsets as a CSS padding, font size, colors). Sizes are in px, as points on iOS.
    fieldHeight: { type: Number, value: 36 },
    fieldCornerRadius: { type: Number, value: -1 },
    fieldBackgroundColor: { type: String, value: '' },
    fieldBorderColor: { type: String, value: '' },
    fieldBorderWidth: { type: Number, value: 0 },
    fieldShadowOpacity: { type: Number, value: 0 },
    contentInsets: { type: String, value: '' },
    fontSize: { type: Number, value: 17 },
    textColor: { type: String, value: '' },
    placeholderColor: { type: String, value: '' },
    cursorColor: { type: String, value: '' },
    searchIconTintColor: { type: String, value: '' },
    // The buttons inside the field (iOS showsVoiceButton: while the text is empty; showsSubmitButton: while there is text).
    showsVoiceButton: { type: Boolean, value: false },
    showsSubmitButton: { type: Boolean, value: false },
    showsClearButton: { type: Boolean, value: true },
    // The keyboard (iOS isSecureTextEntry, maximumTextLength, returnKeyType: "search", "done", "go", "next", "send").
    secure: { type: Boolean, value: false },
    maximumTextLength: { type: Number, value: 0, observer: 'onLengthChange' },
    // "multiple" mode: a completed search shorter than this is dropped (iOS minimumTextLength).
    minimumTextLength: { type: Number, value: 3, observer: 'onLengthChange' },
    returnKeyType: { type: String, value: 'search' },
    // NO makes the bar a button: a tap triggers tapwhilenoteditable instead of editing.
    editable: { type: Boolean, value: true },
    // Only a search button instead of the field (iOS iconified), where iconPosition says ("trailing", "center",
    // "leading"); it opens with expansionAnimation ("fade" or "circularReveal") over animationDuration seconds.
    iconified: { type: Boolean, value: false, observer: 'onIconifiedPropertyChange' },
    // YES closes the field back to its icon when editing ends with no text; setting it closes an idle empty field
    // at once (iOS iconifiedByDefault).
    iconifiedByDefault: { type: Boolean, value: false, observer: 'onIconifiedByDefaultChange' },
    iconPosition: { type: String, value: 'trailing' },
    expansionAnimation: { type: String, value: 'fade' },
    animationDuration: { type: Number, value: 0.3 },
    iconButtonColor: { type: String, value: '' },
    iconButtonBackgroundColor: { type: String, value: '' },
    // "multiple" mode (iOS searchIndicatorColor, unselectedSearchAlpha, searchFieldWidth in px).
    searchIndicatorColor: { type: String, value: '' },
    unselectedSearchAlpha: { type: Number, value: 0.5 },
    searchFieldWidth: { type: Number, value: 160 },
  },
  data: {
    text: '', focused: false, inputFocus: false, collapsed: false, revealing: false,
    labels: {}, fieldStyle: '', inputStyle: '', placeholderStyle: '', shownItems: [],
    searchItems: [], editingNewSearch: false, selectedSearchIndex: -1,
  },
  observers: {
    'fieldHeight, fieldCornerRadius, fieldBackgroundColor, fieldBorderColor, fieldBorderWidth, fieldShadowOpacity, fontSize, textColor, placeholderColor': function () {
      this.updateStyles();
    },
  },
  lifetimes: {
    created() {
      const model = new CYLSearchBarView();
      model.delegate = {
        searchBarViewTextDidChange: (_, value) => this.triggerEvent('textchange', { text: value }),
        searchBarViewSearchButtonClicked: (bar) => this.triggerEvent('submit', { text: bar.text }),
        searchBarViewDidBeginEditing: () => this.triggerEvent('focuschange', { focused: true }),
        searchBarViewDidEndEditing: () => this.triggerEvent('focuschange', { focused: false }),
        searchBarViewCancelButtonClicked: () => this.triggerEvent('cancel'),
        searchBarViewNavigationButtonClicked: () => this.triggerEvent('navigationtap'),
        searchBarViewVoiceButtonClicked: () => this.triggerEvent('voicetap'),
        searchBarViewDidChangeIconified: (_, iconified) => this.triggerEvent('iconifiedchange', { iconified }),
        searchBarViewDidSelectItem: (bar, item) => this.triggerEvent('itemselect', {
          item: item.itemDictionary(), index: item.index, selected: item.isSelected,
        }),
        searchBarViewTextDidChangeAtIndex: (_, value, index) => this.triggerEvent('textchange', { text: value, index }),
        searchBarViewDidCompleteSearchAtIndex: (_, value, index) => this.triggerEvent('completesearch', { text: value, index }),
        searchBarViewDidRemoveSearchAtIndex: (_, index) => this.triggerEvent('removesearch', { index }),
        searchBarViewDidSelectSearchAtIndex: (_, value, index) => this.triggerEvent('selectsearch', { text: value, index }),
      };
      // The model asks for the keyboard; the field opens it once the expansion animation has revealed it.
      model.keyboardHandler = (shown) => {
        if (this.data.revealing && shown) return;
        this.setData({ inputFocus: shown });
      };
      this.model = model;
    },
    attached() {
      const p = this.properties;
      const model = this.model;
      model.mode = p.mode === CYLSearchBarMode.multiple ? CYLSearchBarMode.multiple : CYLSearchBarMode.single;
      model.text = p.value || '';
      model.maximumTextLength = p.maximumTextLength;
      model.minimumTextLength = p.minimumTextLength;
      model.iconified = p.iconified || (p.iconifiedByDefault && !p.value);
      this.setData({
        text: model.text,
        collapsed: model.iconified,
        labels: {
          back: text('search.back'), search: text('search.field'), voice: text('search.voice'),
          submit: text('search.submit'), clear: text('search.clear'), cancel: text('search.cancel'),
          add: text('multisearch.add'), remove: text('multisearch.remove'),
        },
      });
      this.onItemsChange(p.items);
      this.updateStyles();
      this.syncSearches();
    },
  },
  methods: {
    updateStyles() {
      const p = this.properties;
      const radius = p.fieldCornerRadius < 0 ? p.fieldHeight / 2 : p.fieldCornerRadius;
      const field = [`min-height: ${p.fieldHeight}px`, `border-radius: ${radius}px`];
      if (p.fieldBackgroundColor) field.push(`background: ${p.fieldBackgroundColor}`);
      if (p.fieldBorderColor && p.fieldBorderWidth > 0) field.push(`border: ${p.fieldBorderWidth}px solid ${p.fieldBorderColor}`);
      if (p.fieldShadowOpacity > 0) field.push(`box-shadow: 0 2px 8px rgba(0, 0, 0, ${p.fieldShadowOpacity})`);
      const input = [`font-size: ${p.fontSize}px`, `height: ${p.fieldHeight}px`];
      if (p.textColor) input.push(`color: ${p.textColor}`);
      this.setData({
        fieldStyle: field.join('; '),
        inputStyle: input.join('; '),
        placeholderStyle: p.placeholderColor ? `color: ${p.placeholderColor}` : '',
      });
    },
    onLengthChange() {
      if (!this.model) return;
      this.model.maximumTextLength = this.properties.maximumTextLength;
      this.model.minimumTextLength = this.properties.minimumTextLength;
    },
    // The items property (plain values) becomes the model's CYLSearchBarItem list; the template draws `shownItems`.
    onItemsChange(values) {
      if (!this.model) return;
      this.model.removeAllItems();
      (values || []).forEach((value) => this.model.addItem(CYLSearchBarItem.item(value)));
      this.syncItems();
    },
    syncItems() {
      this.setData({
        shownItems: this.model.items.map((item) => Object.assign(item.itemDictionary(), { label: item.accessibilityText })),
      });
    },
    onValueChange(value) {
      if (!this.model || value === this.model.text) return;
      // A new value from the page: no textchange event (the page already knows it).
      this.model.text = value || '';
      this.setData({ text: this.model.text });
    },
    onFocusPropertyChange(focus) {
      this.setData({ inputFocus: focus });
    },
    onIconifiedByDefaultChange(value) {
      if (value && !this.data.focused && !this.data.text) {
        this.model.iconified = true;
        this.setData({ collapsed: true, revealing: false, inputFocus: false });
      }
    },
    onIconifiedPropertyChange(iconified) {
      if (this.model && iconified !== this.data.collapsed) this.setIconified(iconified);
    },
    onInput(event) {
      this.model.textChanged(event.detail.value);
      this.setData({ text: this.model.text });
    },
    onConfirm(event) {
      this.submit(event.detail.value);
    },
    submit(value) {
      if (value !== undefined && value !== this.model.text) this.model.textChanged(value);
      return this.model.submit();
    },
    onFocus() {
      this.setData({ focused: true });
      this.model.editingChanged(true);
    },
    onBlur() {
      this.setData({ focused: false, inputFocus: false });
      this.model.isKeyboardRequested = false;
      this.model.editingChanged(false);
      // iOS iconifiedByDefault: the field closes back to its icon when editing ends with no text.
      if (this.properties.iconifiedByDefault && !this.data.text) this.setIconified(true);
    },
    onCancel() {
      this.model.cancelTapped();
    },
    onClear() {
      this.model.textChanged('');
      this.setData({ text: '', inputFocus: true });
    },
    onNavigationTap() {
      this.model.navigationTapped();
    },
    onVoiceTap() {
      this.model.voiceTapped();
    },
    onSubmitTap() {
      this.submit();
    },
    onNotEditableTap() {
      this.triggerEvent('tapwhilenoteditable');
    },
    onIconTap() {
      this.setIconified(false);
    },
    /**
     * Sets the text and, with `submit` and a non-empty text, submits it (iOS `-setText:submit:`).
     */
    setText(value, submit) {
      this.model.setText(value || '', false);
      this.setData({ text: this.model.text });
      if (submit) this.model.submit();
    },
    /**
     * Opens (with the expansion animation, then editing) or closes the field (iOS `-setIconified:animated:`).
     */
    setIconified(iconified) {
      if (iconified === this.data.collapsed) return;
      if (iconified) {
        this.setData({ collapsed: true, revealing: false, inputFocus: false });
        this.model.setIconified(true, false);
        return;
      }
      // The field starts hidden at the icon (revealing), then the next frame opens it, so the transition runs.
      this.setData({ collapsed: false, revealing: true });
      this.model.setIconified(false, false);
      setTimeout(() => this.setData({ revealing: false, inputFocus: true }), 30);
    },
    /**
     * Focuses the field, which raises the keyboard.
     */
    showKeyboard() {
      this.model.showKeyboard();
    },
    /**
     * Ends editing, which lowers the keyboard.
     */
    hideKeyboard() {
      this.model.hideKeyboard();
    },
    onItemTap(event) {
      const item = this.model.items[Number(event.currentTarget.dataset.index)];
      if (!item) return;
      this.model.itemTapped(item);
      this.syncItems();
    },

    // The "multiple" mode.
    syncSearches() {
      const model = this.model;
      const completed = model.completedSearches;
      const itemFormat = text('multisearch.item');
      this.setData({
        editingNewSearch: model.isEditingNewSearch,
        text: model.text,
        selectedSearchIndex: model.selectedSearchIndex,
        searchItems: completed.map((value, index) => ({
          text: value,
          label: `${value}, ${cylFormatString(itemFormat, [index + 1, completed.length])}`,
        })),
      });
    },
    /**
     * Starts a new search and shows the keyboard (iOS `beginNewSearch()`).
     */
    beginNewSearch() {
      this.model.beginNewSearch();
      this.syncSearches();
    },
    /**
     * Completes the search being typed (iOS `completeSearch()`); a search shorter than `minimumTextLength` is dropped.
     */
    completeSearch() {
      this.model.completeSearch();
      this.syncSearches();
    },
    /**
     * Adds a completed search without typing it and selects it (iOS `addSearch(_:)`).
     */
    addSearch(value) {
      this.model.addSearch(value);
      this.syncSearches();
    },
    /**
     * Selects a search, like a tap on it (iOS `selectSearch(at:)`).
     */
    selectSearch(index) {
      this.model.selectSearch(index);
      this.model.hideKeyboard();
      this.syncSearches();
    },
    /**
     * Removes a search, like a tap on its remove button (iOS `removeSearch(at:)`).
     */
    removeSearch(index) {
      this.model.removeSearch(index);
      this.syncSearches();
    },
    /**
     * The searches: the completed ones, then the one being typed (iOS `searches`).
     */
    searches() {
      return this.model.searches;
    },
    // The new-search button: a new search, or the one being typed is completed.
    onNewSearchTap() {
      if (this.model.isEditingNewSearch) this.completeSearch();
      else this.beginNewSearch();
    },
    onSearchInput(event) {
      this.model.textChanged(event.detail.value);
      // The model enforces maximumTextLength; the field shows what it kept.
      this.setData({ text: this.model.text });
    },
    onSearchConfirm() {
      this.completeSearch();
    },
    onSearchTap(event) {
      this.selectSearch(Number(event.currentTarget.dataset.index));
    },
    onRemoveSearchTap(event) {
      this.removeSearch(Number(event.currentTarget.dataset.index));
    },
  },
});
