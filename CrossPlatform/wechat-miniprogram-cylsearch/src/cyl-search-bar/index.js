const { CYLSearchBarItem, CYLSearchBarItems } = require('../cyl-search/cyl_search_bar_item');
const { CYLSearchResources } = require('../core/CYLSearchResources');

const text = (key) => CYLSearchResources.localizedString(undefined, key);

/**
 * The search bar component (iOS `CYLSearchBarView`): an optional navigation button, then the rounded field (the
 * magnifier, the text, the clear button, the voice or submit button, the slot `trailing` and the appended `items`),
 * then an optional Cancel button. `items` is a list of plain values (see `CYLSearchBarItem.item`).
 *
 * Events: `textchange` `{ text }`, `submit` `{ text }`, `focuschange` `{ focused }`, `cancel`, `itemselect`
 * `{ item, index, selected }`, `navigationtap`, `voicetap`, `tapwhilenoteditable` (with `editable` false, iOS
 * `-searchBarViewShouldBeginEditing:` returning NO), `iconifiedchange` `{ iconified }`.
 * Methods: `setText(text, submit)`, `setIconified(iconified)`, `showKeyboard()`, `hideKeyboard()`.
 */
Component({
  options: { multipleSlots: true },
  properties: {
    value: { type: String, value: '', observer: 'onValueChange' },
    placeholder: { type: String, value: '' },
    focus: { type: Boolean, value: false, observer: 'onFocusPropertyChange' },
    searchBarStyle: { type: String, value: 'plain' },
    searchIcon: { type: String, value: '../images/search.svg' },
    showsSearchIcon: { type: Boolean, value: true },
    showsCancelButton: { type: Boolean, value: false },
    cancelButtonTitle: { type: String, value: '' },
    items: { type: Array, value: [] },
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
    maximumTextLength: { type: Number, value: 0 },
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
  },
  data: {
    text: '', focused: false, inputFocus: false, collapsed: false, revealing: false,
    labels: {}, fieldStyle: '', inputStyle: '', placeholderStyle: '',
  },
  observers: {
    'fieldHeight, fieldCornerRadius, fieldBackgroundColor, fieldBorderColor, fieldBorderWidth, fieldShadowOpacity, fontSize, textColor, placeholderColor': function () {
      this.updateStyles();
    },
  },
  lifetimes: {
    attached() {
      this.setData({
        text: this.properties.value,
        collapsed: this.properties.iconified || (this.properties.iconifiedByDefault && !this.properties.value),
        labels: {
          back: text('search.back'), search: text('search.field'), voice: text('search.voice'),
          submit: text('search.submit'), clear: text('search.clear'), cancel: text('search.cancel'),
        },
      });
      this.updateStyles();
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
    onValueChange(value) {
      if (value !== this.data.text) this.setData({ text: value });
    },
    onFocusPropertyChange(focus) {
      this.setData({ inputFocus: focus });
    },
    onIconifiedByDefaultChange(value) {
      if (value && !this.data.focused && !this.data.text) {
        this.setData({ collapsed: true, revealing: false, inputFocus: false });
      }
    },
    onIconifiedPropertyChange(iconified) {
      if (iconified !== this.data.collapsed) this.setIconified(iconified);
    },
    onInput(event) {
      this.setData({ text: event.detail.value });
      this.triggerEvent('textchange', { text: event.detail.value });
    },
    onConfirm(event) {
      this.submit(event.detail.value);
    },
    submit(value) {
      const query = value !== undefined ? value : this.data.text;
      if (!query) return false;
      this.triggerEvent('submit', { text: query });
      return true;
    },
    onFocus() {
      this.setData({ focused: true });
      this.triggerEvent('focuschange', { focused: true });
    },
    onBlur() {
      this.setData({ focused: false, inputFocus: false });
      this.triggerEvent('focuschange', { focused: false });
      // iOS iconifiedByDefault: the field closes back to its icon when editing ends with no text.
      if (this.properties.iconifiedByDefault && !this.data.text) this.setIconified(true);
    },
    onCancel() {
      this.triggerEvent('cancel');
    },
    onClear() {
      this.setData({ text: '', inputFocus: true });
      this.triggerEvent('textchange', { text: '' });
    },
    onNavigationTap() {
      this.triggerEvent('navigationtap');
    },
    onVoiceTap() {
      this.triggerEvent('voicetap');
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
    /** Sets the text and, with `submit` and a non-empty text, submits it (iOS `-setText:submit:`). */
    setText(value, submit) {
      this.setData({ text: value || '' });
      this.triggerEvent('textchange', { text: value || '' });
      if (submit) this.submit(value || '');
    },
    /** Opens (with the expansion animation, then editing) or closes the field (iOS `-setIconified:animated:`). */
    setIconified(iconified) {
      if (iconified === this.data.collapsed) return;
      if (iconified) {
        this.setData({ collapsed: true, revealing: false, inputFocus: false });
      } else {
        // The field starts hidden at the icon (revealing), then the next frame opens it, so the transition runs.
        this.setData({ collapsed: false, revealing: true });
        setTimeout(() => this.setData({ revealing: false, inputFocus: true }), 30);
      }
      this.triggerEvent('iconifiedchange', { iconified });
    },
    showKeyboard() {
      this.setData({ inputFocus: true });
    },
    hideKeyboard() {
      this.setData({ inputFocus: false });
    },
    onItemTap(event) {
      const index = Number(event.currentTarget.dataset.index);
      const values = this.data.items[index];
      if (!values || values.isEnabled === false) return;
      const bar = new CYLSearchBarItems();
      const item = CYLSearchBarItem.item(values);
      bar.addItem(item);
      bar.itemTapped(item);
      if (item.isSelectable) this.setData({ [`items[${index}].isSelected`]: item.isSelected });
      this.triggerEvent('itemselect', { item: values, index, selected: item.isSelected });
    },
  },
});
