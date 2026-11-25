const { cylSearchShouldFocusOnAppear, cylSearchHasBackButton, cylNavigationFieldStyle, cylSearchBarPresetSpec, CYLSearchBarColors, CYLSearchBarView, CYLSearchBarItem, CYLSearchBarMode, CYLSearchBarAppearance, cylInsetsCSS, cylSearchButtonColors, cylSearchButtonHasDivider, cylSearchButtonTrailingInset, CYLSearchBarSearchButtonStyle } = require('../core/CYLSearchBarView');
const { CYLSearchResources, cylFormatString } = require('../core/CYLSearchResources');

const text = (key) => CYLSearchResources.localizedString(undefined, key);

// The items' default tint, the label color of the color mode (iOS `UIColor.label`).
function defaultItemTint() {
  try {
    const info = wx.getAppBaseInfo ? wx.getAppBaseInfo() : {};
    return info && info.theme === 'dark' ? '#FFFFFF' : '#000000';
  } catch (error) {
    return '#000000';
  }
}

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
 * Methods: `applyNavigationFieldStyle()`, `setText(text, submit)`, `setIconified(iconified)`, `showKeyboard()`, `hideKeyboard()`; "multiple" mode:
 * `beginNewSearch()`, `completeSearch()`, `addSearch(text)`, `selectSearch(index)`, `removeSearch(index)`,
 * `searches()`.
 *
 * Abstract nodes (`componentGenerics`): `cyl-lottie-view`, `cyl-pag-view`, `cyl-rive-view` and `cyl-svga-view`, the
 * animation engines of the items' animated icons. The bar forwards them to CollectionViewClassifyMenu's
 * `<cyl-tag-button>`, which hands them to CYLTabBarController's `<cyl-animated-item>`; the package links no engine (the
 * default, `cyl-animation-placeholder`, plays nothing, so the item's `image` shows). Pass yours with
 * `generic:cyl-svga-view="cyl-svga"` and so on.
 */
Component({
  options: { multipleSlots: true },
  properties: {
    // "single" (one search) or "multiple" (several searches side by side; iOS CYLSearchBarMode).
    mode: { type: String, value: 'single' },
    value: { type: String, value: '', observer: 'onValueChange' },
    placeholder: { type: String, value: '' },
    focus: { type: Boolean, value: false, observer: 'onFocusPropertyChange' },
    // The field focuses itself every time the bar appears on screen (iOS focusesOnAppear, like a viewDidAppear), only with a
    // back button (arrow icon or a previous page in the page stack): when the
    // component is attached and every time its page shows (return from another page or from the background). False by default.
    // TODO: iOS takes its moments from CYLDeallocBlockExecutor; no such dependency here until the unified pin pair is announced.
    focusesOnAppear: { type: Boolean, value: false },
    searchBarStyle: { type: String, value: 'plain' },
    // The navigation field preset, the Discover look of every screen (iOS applyNavigationFieldStyle()): a bordered capsule
    // (radius 18), a soft shadow (0.06), an opaque white / black fill, no magnifier, 16 text. A page sets this property
    // (or calls the method applyNavigationFieldStyle()) and never the values; a JS method cannot share the property's name.
    navigationFieldStyle: { type: Boolean, value: false, observer: 'onNavigationFieldStyle' },
    // One of the looks the core ships (CYLSearchBarPreset): "navigationField" (the same as `navigationFieldStyle`), "pill",
    // "rounded", "outlined" or "centeredCapsule"; a page names it and never sets the values. Empty: none.
    preset: { type: String, value: '', observer: 'onPreset' },
    searchIcon: { type: String, value: '../images/search.svg' },
    showsSearchIcon: { type: Boolean, value: true },
    showsCancelButton: { type: Boolean, value: false },
    // An editing bar (iOS CYLSearchBarView.editingBar): no magnifier, `cancelButtonTitle` ("Add", "Done") is the action;
    // it and the confirm key send `editingsubmit` {text} with the trimmed text.
    editingBar: { type: Boolean, value: false },
    // Pinned to the top of the keyboard (iOS pinToKeyboard(in:)): fixed at the page's bottom, lifted by the keyboard's
    // height (wx.onKeyboardHeightChange); the field does not push the page.
    pinsToKeyboard: { type: Boolean, value: false },
    cancelButtonTitle: { type: String, value: '' },
    items: { type: Array, value: [], observer: 'onItemsChange' },
    // The default search button (iOS showsSearchButton, searchButtonStyle "text" or "icon", searchButtonTitle,
    // searchButtonImage): kept after the field and the items, a divider before it when an item precedes it; false for an
    // editing bar and in "multiple" mode. A tap submits the text; the event `submit` also fires for empty text.
    showsSearchButton: { type: Boolean, value: true, observer: 'onSearchButtonChange' },
    searchButtonStyle: { type: String, value: 'text', observer: 'onSearchButtonChange' },
    searchButtonTitle: { type: String, value: '', observer: 'onSearchButtonChange' },
    searchButtonImage: { type: String, value: '', observer: 'onSearchButtonChange' },
    // A first-level bar (iOS pushesOnTap): a tap on the field (not on the items and the search button) triggers `firstleveltap`
    // instead of editing; `<cyl-search-navigation-bar>` plays the push.
    pushesOnTap: { type: Boolean, value: false },
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
    // iOS CYLSearchBar (QMUI): the placeholder (with the magnifier) centred while the field rests, leading while it edits.
    centersPlaceholder: { type: Boolean, value: false },
    // The field's margins as { top, left, bottom, right } in px, at rest and while editing (iOS textFieldMargins and the
    // two states of textFieldMarginsProvider; setTextFieldMarginsProvider(fn(bar, active)) wins over both).
    textFieldMargins: { type: Object, value: null },
    activeTextFieldMargins: { type: Object, value: null },
    // The same for the Cancel button (iOS cancelButtonMarginsProvider), and its font { size, weight } (cancelButtonFont).
    cancelButtonMargins: { type: Object, value: null },
    activeCancelButtonMargins: { type: Object, value: null },
    cancelButtonFont: { type: Object, value: null },
    // The leading view before the field (slot `leading`) and the trailing accessory views in it (slot `trailing`), one
    // animated container each, and whether they show (iOS showsLeadingView / showsTrailingAccessoryViews; the methods
    // setShowsLeadingView and setShowsTrailingAccessoryViews(shows, animated) change it, animated). The slots
    // `leading-accessory` and `trailing-accessory` and the properties `showsLeadingAccessory` and
    // `showsTrailingAccessory` are the earlier names of the same views: a set property wins over the new one.
    showsLeadingView: { type: Boolean, value: true, observer: 'onAccessoryProperty' },
    showsTrailingAccessoryViews: { type: Boolean, value: true, observer: 'onAccessoryProperty' },
    showsLeadingAccessory: { type: null, value: null, observer: 'onAccessoryProperty' },
    showsTrailingAccessory: { type: null, value: null, observer: 'onAccessoryProperty' },
    leadingAccessoryMargins: { type: Object, value: null },
    trailingAccessoryMargins: { type: Object, value: null },
    // iOS CYLSearchBarAppearance: plain values of CYLSearchBarAppearance.default(), applied under the bar's own properties.
    appearance: { type: Object, value: null },
  },
  data: {
    text: '', focused: false, inputFocus: false, collapsed: false, revealing: false, keyboardHeight: 0,
    labels: {}, searchButton: { visible: false }, fieldPadStyle: '', fieldStyle: '', inputStyle: '', placeholderStyle: '', shownItems: [],
    searchItems: [], editingNewSearch: false, selectedSearchIndex: -1,
    centered: false, cancelShown: false, cancelAnimated: false, leadingShown: false, trailingShown: false, accessoryAnimated: false,
    leadingWidth: 0, trailingWidth: 0, barStyle: '', fieldMargin: '', cancelStyle: '', leadingStyle: '', trailingStyle: '', fieldIconAlt: '',
  },
  observers: {
    'fieldHeight, fieldCornerRadius, fieldBackgroundColor, fieldBorderColor, fieldBorderWidth, fieldShadowOpacity, fontSize, textColor, placeholderColor, centersPlaceholder, textFieldMargins, activeTextFieldMargins, cancelButtonMargins, activeCancelButtonMargins, cancelButtonFont, leadingAccessoryMargins, trailingAccessoryMargins, appearance, focused, text': function () {
      this.updateStyles();
    },
    showsCancelButton(value) {
      if (this.model) this.model.setShowsCancelButton(value, false);
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
        searchBarViewShouldSubmitText: () => true,
        searchBarViewNavigationButtonClicked: () => this.triggerEvent('navigationtap'),
        searchBarViewVoiceButtonClicked: () => this.triggerEvent('voicetap'),
        searchBarViewDidChangeIconified: (_, iconified) => this.triggerEvent('iconifiedchange', { iconified }),
        searchBarViewDidSelectItem: (bar, item) => this.triggerEvent('itemselect', {
          item: item.itemDictionary(), index: item.index, selected: item.isSelected,
        }),
        searchBarViewTextDidChangeAtIndex: (_, value, index) => this.triggerEvent('textchange', { text: value, index }),
        searchBarViewDidCompleteSearch: (_, value, index) => this.triggerEvent('completesearch', { text: value, index }),
        searchBarViewDidRemoveSearchAtIndex: (_, index) => this.triggerEvent('removesearch', { index }),
        searchBarViewDidSelectSearch: (_, value, index) => this.triggerEvent('selectsearch', { text: value, index }),
      };
      // The model asks for the keyboard; the field opens it once the expansion animation has revealed it.
      model.keyboardHandler = (shown) => {
        if (this.data.revealing && shown) return;
        if (shown) this.requestInputFocus();
        else this.setData({ inputFocus: false });
      };
      // setShowsCancelButton / setShows...AccessoryView(shows, animated) reach the view through this handler.
      model.accessoryHandler = (which, shown, animated) => {
        if (which === 'cancel') this.setData({ cancelShown: shown, cancelAnimated: animated });
        else this.setData({ [`${which}Shown`]: shown, accessoryAnimated: animated });
        this.updateStyles();
      };
      // CYLSearchBarItem.restartAnimation() reaches the item's cyl-tag-button through this handler; playAnimation()
      // plays from progress 0, which is the restart.
      model.itemAnimationHandler = (item) => {
        const button = this.selectComponent(`#cyl-bar-item-${item.index}`);
        if (button && typeof button.playAnimation === 'function') button.playAnimation();
      };
      this.model = model;
    },
    attached() {
      const p = this.properties;
      // A live light/dark switch re-resolves the colors CSS cannot reach (placeholder-style, the items' tint).
      if (typeof wx !== 'undefined' && wx.onThemeChange) {
        this.themeListener = () => { this.updateStyles(); this.syncItems(); };
        wx.onThemeChange(this.themeListener);
      }
      const model = this.model;
      model.mode = p.mode === CYLSearchBarMode.multiple ? CYLSearchBarMode.multiple : CYLSearchBarMode.single;
      model.text = p.value || '';
      model.maximumTextLength = p.maximumTextLength;
      model.minimumTextLength = p.minimumTextLength;
      model.iconified = p.iconified || (p.iconifiedByDefault && !p.value);
      model.showsCancelButton = p.showsCancelButton;
      model.defaultSearchButtonTitle = text('search.button');
      this.applySearchButtonProperties();
      const shows = this.accessoryShows();
      model.showsLeadingView = shows.leading;
      model.showsTrailingAccessoryViews = shows.trailing;
      if (p.editingBar) {
        model.isEditingBar = true;
        model.cancelButtonEndsEditing = false;
        model.editingSubmitHandler = (_, value) => this.triggerEvent('editingsubmit', { text: value });
      }
      if (p.pinsToKeyboard && typeof wx !== 'undefined' && wx.onKeyboardHeightChange) {
        this.keyboardListener = (result) => this.setData({ keyboardHeight: result.height || 0 });
        wx.onKeyboardHeightChange(this.keyboardListener);
      }
      this.setData({
        text: model.text,
        collapsed: model.iconified,
        cancelShown: p.showsCancelButton,
        leadingShown: shows.leading,
        trailingShown: shows.trailing,
        labels: {
          back: text('search.back'), search: text('search.field'), voice: text('search.voice'),
          submit: text('search.submit'), clear: text('search.clear'), cancel: text('search.cancel'),
          add: text('multisearch.add'), remove: text('multisearch.remove'),
        },
      });
      this.onItemsChange(p.items);
      this.updateStyles();
      this.syncSearches();
      this.focusIfAppearing();
    },
    ready() {
      this.measureAccessories();
    },
    detached() {
      if (this.themeListener && typeof wx !== 'undefined' && wx.offThemeChange) wx.offThemeChange(this.themeListener);
      if (this.keyboardListener && typeof wx !== 'undefined' && wx.offKeyboardHeightChange) {
        wx.offKeyboardHeightChange(this.keyboardListener);
      }
    },
  },
  // The page the bar sits on shows again (tab switch, pop, return from the background): an appearance.
  pageLifetimes: {
    show() {
      this.focusIfAppearing();
    },
  },
  methods: {
    /**
     * Focuses the field when `focusesOnAppear` is on and the bar is drawn and editable: the input's `focus` is set false,
     * then true, on each appearance (WeChat focuses an input only when it goes from false to true).
     */
    focusIfAppearing() {
      const p = this.properties;
      if (p.mode === CYLSearchBarMode.multiple) return;
      const pages = typeof getCurrentPages === 'function' ? getCurrentPages() : [];
      const hasBack = cylSearchHasBackButton(p.navigationIcon, pages.length);
      if (!cylSearchShouldFocusOnAppear(p.focusesOnAppear, hasBack, this.data.collapsed, p.editable)) return;
      this.setData({ inputFocus: false });
      setTimeout(() => this.setData({ inputFocus: true }), 30);
    },
    onNavigationFieldStyle(value) {
      if (!value) return;
      const preset = cylNavigationFieldStyle();
      this.setData({
        searchBarStyle: 'bordered', showsSearchIcon: preset.showsSearchIcon, fieldCornerRadius: preset.cornerRadius,
        fieldShadowOpacity: preset.shadowOpacity, fontSize: preset.fontSize,
      });
    },
    onPreset(name) {
      if (!name) return;
      if (name === 'navigationField') {
        this.onNavigationFieldStyle(true);
        return;
      }
      const spec = cylSearchBarPresetSpec(name);
      const values = { showsSearchIcon: spec.showsSearchIcon, fieldCornerRadius: spec.cornerRadius, fieldShadowOpacity: spec.shadowOpacity, fontSize: spec.fontSize,
        centersPlaceholder: spec.centersPlaceholder, navigationFill: spec.usesNavigationFill };
      if (spec.bordered) values.searchBarStyle = 'bordered';
      this.setData(values);
    },
    /**
     * Applies the navigation field preset (the same as the property `navigationFieldStyle`; iOS `applyNavigationFieldStyle()`).
     */
    applyNavigationFieldStyle() {
      this.setData({ navigationFieldStyle: true });
      this.onNavigationFieldStyle(true);
    },
    updateStyles() {
      const p = this.properties;
      if (!this.model) return;
      const dark = defaultItemTint() === '#FFFFFF';
      const ap = p.appearance ? CYLSearchBarAppearance.styles(p.appearance, dark) : null;
      const model = this.model;
      model.centersPlaceholder = p.centersPlaceholder;
      const active = !!this.data.focused;
      const radiusValue = p.fieldCornerRadius >= 0 ? p.fieldCornerRadius : (ap && ap.radius >= 0 ? ap.radius : -1);
      const radius = radiusValue < 0 ? p.fieldHeight / 2 : radiusValue;
      const field = [`min-height: ${p.fieldHeight}px`, `border-radius: ${radius}px`];
      if (ap) field.push(ap.field);
      if (p.fieldBackgroundColor) field.push(`background: ${p.fieldBackgroundColor}`);
      if (p.fieldBorderColor && p.fieldBorderWidth > 0) field.push(`border: ${p.fieldBorderWidth}px solid ${p.fieldBorderColor}`);
      if (p.fieldShadowOpacity > 0) field.push(`box-shadow: 0 2px 8px rgba(0, 0, 0, ${p.fieldShadowOpacity})`);
      const fieldMargins = cylInsetsCSS(model.textFieldMarginsProvider ? model.textFieldMarginsFor(active)
        : (active ? p.activeTextFieldMargins || p.textFieldMargins : p.textFieldMargins));
      if (fieldMargins) field.push(`margin: ${fieldMargins}`);
      const fontSize = p.fontSize !== 17 || !ap ? p.fontSize : ap.fontSize;
      const input = [`font-size: ${fontSize}px`, `height: ${p.fieldHeight}px`];
      const textColor = p.textColor || (ap && ap.textColor);
      if (textColor) input.push(`color: ${textColor}`);
      const placeholderColor = p.placeholderColor || (ap && ap.placeholderColor) || CYLSearchBarColors.secondaryLabel(dark);
      const cancel = [];
      if (ap && ap.cancel) cancel.push(ap.cancel);
      const font = p.cancelButtonFont;
      if (font && font.size) cancel.push(`font-size: ${font.size}px`);
      if (font && font.weight) cancel.push(`font-weight: ${font.weight}`);
      const cancelMargins = cylInsetsCSS(model.cancelButtonMarginsProvider ? model.cancelButtonMarginsFor(active)
        : (active ? p.activeCancelButtonMargins || p.cancelButtonMargins : p.cancelButtonMargins));
      if (cancelMargins) cancel.push(`margin: ${cancelMargins}`);
      const padding = (margins) => { const css = cylInsetsCSS(margins); return css ? `padding: ${css}` : ''; };
      this.setData({
        fieldStyle: field.join('; '),
        inputStyle: input.join('; '),
        placeholderStyle: placeholderColor ? `color: ${placeholderColor}` : '',
        barStyle: ap ? ap.bar : '',
        cancelStyle: cancel.join('; '),
        leadingStyle: padding(p.leadingAccessoryMargins || model.leadingAccessoryMargins),
        trailingStyle: padding(p.trailingAccessoryMargins || model.trailingAccessoryMargins),
        centered: !!p.centersPlaceholder && !this.data.focused && !this.data.text,
        fieldCursor: p.cursorColor || (ap && ap.tintColor) || '',
        // The style's magnifier replaces the default one (the bar's own `searchIcon` wins when it is not the default).
        ...(ap && ap.searchIcon && p.searchIcon === '../images/search.svg' ? { searchIcon: ap.searchIcon } : {}),
      });
    },
    // Whether the views show, from the properties: an earlier-name property that was set wins over the new one.
    accessoryShows() {
      const p = this.properties;
      const set = (old, value) => (old === null || old === undefined ? !!value : !!old);
      return { leading: set(p.showsLeadingAccessory, p.showsLeadingView), trailing: set(p.showsTrailingAccessory, p.showsTrailingAccessoryViews) };
    },
    onAccessoryProperty() {
      if (!this.model) return;
      const shows = this.accessoryShows();
      this.model.setShowsLeadingView(shows.leading, false);
      this.model.setShowsTrailingAccessoryViews(shows.trailing, false);
    },
    /**
     * Shows or hides Cancel, animated or not (iOS `setShowsCancelButton(_:animated:)`).
     */
    setShowsCancelButton(shows, animated) {
      this.model.setShowsCancelButton(shows, animated === true);
    },
    /**
     * Shows or hides the leading view before the field (iOS `setShowsLeadingView(_:animated:)`).
     */
    setShowsLeadingView(shows, animated) {
      this.model.setShowsLeadingView(shows, animated === true);
    },
    /**
     * Shows or hides the trailing accessory views of the field (iOS `setShowsTrailingAccessoryViews(_:animated:)`).
     */
    setShowsTrailingAccessoryViews(shows, animated) {
      this.model.setShowsTrailingAccessoryViews(shows, animated === true);
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
     * The margins of the field per state, from a function (iOS `textFieldMarginsProvider`): `(bar, active) => { top,
     * left, bottom, right }`; undefined removes it.
     */
    setTextFieldMarginsProvider(provider) {
      this.model.textFieldMarginsProvider = typeof provider === 'function' ? provider : undefined;
      this.updateStyles();
    },
    /**
     * The margins of Cancel per state, from a function (iOS `cancelButtonMarginsProvider`); undefined removes it.
     */
    setCancelButtonMarginsProvider(provider) {
      this.model.cancelButtonMarginsProvider = typeof provider === 'function' ? provider : undefined;
      this.updateStyles();
    },
    /**
     * The accessories' widths, measured once they are drawn, so that showing one animates the width (iOS lays them out).
     */
    measureAccessories() {
      const query = this.createSelectorQuery();
      query.select('.cyl-leading-inner').boundingClientRect();
      query.select('.cyl-trailing-inner').boundingClientRect();
      query.exec(([leading, trailing]) => {
        this.setData({ leadingWidth: leading ? Math.ceil(leading.width) : 0, trailingWidth: trailing ? Math.ceil(trailing.width) : 0 });
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
    // Each item is drawn by CollectionViewClassifyMenu's <cyl-tag-button> (`button`: its properties).
    applySearchButtonProperties() {
      const p = this.properties;
      const model = this.model;
      model.mode = p.mode === CYLSearchBarMode.multiple ? CYLSearchBarMode.multiple : CYLSearchBarMode.single;
      model.isEditingBar = model.isEditingBar || p.editingBar;
      model.showsSearchButton = p.showsSearchButton;
      model.searchButtonStyle = p.searchButtonStyle === CYLSearchBarSearchButtonStyle.icon
        ? CYLSearchBarSearchButtonStyle.icon : CYLSearchBarSearchButtonStyle.text;
      model.searchButtonTitle = p.searchButtonTitle || undefined;
      model.searchButtonImage = p.searchButtonImage || undefined;
    },
    onSearchButtonChange() {
      if (!this.model) return;
      this.applySearchButtonProperties();
      this.syncItems();
    },
    // The default search button: its model item, drawn by a <cyl-tag-button> like the owner's items. The filled icon style
    // takes the inverse colors, and sits concentric in the field (the right gap equals the gap above and below).
    searchButtonData(dark) {
      const model = this.model;
      if (!model.hasSearchButton) return { visible: false };
      const item = model.searchButtonItem;
      const icon = model.searchButtonStyle === CYLSearchBarSearchButtonStyle.icon;
      if (icon) {
        const colors = cylSearchButtonColors(dark);
        item.backgroundColor = colors.fill;
        item.tintColor = colors.glyph;
      }
      return {
        visible: true,
        hasDivider: cylSearchButtonHasDivider(model.items.length),
        label: item.accessibilityText,
        button: item.tagButtonProperties(model.itemTintColor, dark),
        trailingInset: cylSearchButtonTrailingInset(this.properties.fieldHeight, item.itemHeight, 12, icon),
        icon,
      };
    },
    syncItems() {
      const dark = defaultItemTint() === '#FFFFFF';
      const searchButton = this.searchButtonData(dark);
      this.setData({
        searchButton,
        fieldPadStyle: searchButton.visible && searchButton.icon ? `padding-right: ${searchButton.trailingInset}px` : '',
        shownItems: this.model.items.map((item) => Object.assign(item.itemDictionary(), {
          label: item.accessibilityText,
          button: item.tagButtonProperties(this.model.itemTintColor, dark),
        })),
      });
    },
    onValueChange(value) {
      if (!this.model || value === this.model.text) return;
      // A new value from the page: no textchange event (the page already knows it).
      this.model.text = value || '';
      this.setData({ text: this.model.text });
      // An editing bar given a new title (the page's answer to a rename request) takes the keyboard, every time, as
      // CYLSearchBarView's editing bar does on iOS, Android, React Native and Flutter.
      if (this.properties.editingBar && this.model.text) this.requestInputFocus();
    },
    onFocusPropertyChange(focus) {
      if (focus) this.requestInputFocus();
      else this.setData({ inputFocus: false });
    },
    /**
     * Focuses the field and raises the keyboard. WeChat focuses an input only when its `focus` goes from false to
     * true, so a request while `inputFocus` is still true (the keyboard closed without a blur reaching the page, or a
     * second rename) first clears it, then sets it on the next frame.
     */
    requestInputFocus() {
      if (!this.data.inputFocus) {
        this.setData({ inputFocus: true });
        return;
      }
      this.setData({ inputFocus: false });
      setTimeout(() => this.setData({ inputFocus: true }), 30);
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
    onSearchButtonTap() {
      this.model.searchButtonTapped();
    },
    onSubmitTap() {
      this.submit();
    },
    onNotEditableTap() {
      if (this.properties.pushesOnTap) this.triggerEvent('firstleveltap', {});
      else this.triggerEvent('tapwhilenoteditable');
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
      const index = Number(event.currentTarget.dataset.index);
      const item = this.model.items[index];
      if (!item || !item.isEnabled) return;
      // An animated icon plays on each tap (iOS `CYLSearchBarItemButton`).
      if (item.animationURL) {
        const button = this.selectComponent(`#cyl-bar-item-${index}`);
        if (button && typeof button.playAnimation === 'function') button.playAnimation();
      }
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