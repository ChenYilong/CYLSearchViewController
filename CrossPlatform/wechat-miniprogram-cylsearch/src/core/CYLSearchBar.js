// CYLSearchBar.swift for the mini program: the QMUI `UISearchBar` knobs (docs/qmui-search-controller.md) on one object. A
// mini program has no `UISearchBar`; `<cyl-search-bar>` draws a `CYLSearchBarView`, so this class is the iOS name of the same
// state: every knob reads and writes the bar view that `<cyl-search-bar>` draws, and nothing is kept twice.
'use strict';

const { CYLSearchBarView, CYLSearchBarAppearance } = require('./CYLSearchBarView');

/**
 * The bar of a search (iOS `CYLSearchBar`, a `UISearchBar` styled by `CYLSearchBarAppearance`): the placeholder, text and
 * Cancel knobs of QMUI's `QMUISearchBar`, over the `CYLSearchBarView` that `<cyl-search-bar>` draws.
 */
class CYLSearchBar {
  /**
   * A bar styled with the default appearance, over `barView` (a new `CYLSearchBarView` by default).
   */
  constructor(barView) {
    this.barView = barView || new CYLSearchBarView();
    /** Whether the bar is a list's header (set by the screens that install it as one); default false. */
    this.usedAsTableHeaderView = false;
    /** Whether the Cancel button stays enabled although the keyboard is down; default true. */
    this.alwaysEnablesCancelButton = true;
    this.applyDefaultAppearance();
  }

  /**
   * The style applied to the bar; assigning one applies it.
   */
  get appearanceStyle() {
    return this.barView.appearanceStyle;
  }

  set appearanceStyle(value) {
    this.barView.appearanceStyle = value;
  }

  /**
   * The space around the leading accessory (`{ top, left, bottom, right }` in px); `right` is the gap to the field.
   */
  get leadingAccessoryViewMargins() {
    return this.barView.leadingAccessoryMargins;
  }

  set leadingAccessoryViewMargins(value) {
    this.barView.leadingAccessoryMargins = value;
  }

  /**
   * The space around the trailing accessories; `left` is the gap to the field.
   */
  get trailingAccessoryViewMargins() {
    return this.barView.trailingAccessoryMargins;
  }

  set trailingAccessoryViewMargins(value) {
    this.barView.trailingAccessoryMargins = value;
  }

  /**
   * Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text.
   */
  get centersPlaceholder() {
    return this.barView.centersPlaceholder;
  }

  set centersPlaceholder(value) {
    this.barView.centersPlaceholder = !!value;
  }

  /**
   * The placeholder's color.
   */
  get placeholderColor() {
    return this.barView.placeholderColor;
  }

  set placeholderColor(value) {
    this.barView.placeholderColor = value;
  }

  /**
   * The color of the typed text.
   */
  get textColor() {
    return this.barView.textColor;
  }

  set textColor(value) {
    this.barView.textColor = value;
  }

  /**
   * The font size of the typed text and of the placeholder, in px.
   */
  get font() {
    return this.barView.font;
  }

  set font(value) {
    this.barView.font = value;
  }

  /**
   * The margins added to the field (`{ top, left, bottom, right }` in px).
   */
  get textFieldMargins() {
    return this.barView.textFieldMargins;
  }

  set textFieldMargins(value) {
    this.barView.textFieldMargins = value;
  }

  /**
   * Returns the field's margins for the bar's state, `(bar, active) => insets`; wins over `textFieldMargins`.
   */
  get textFieldMarginsProvider() {
    return this.barView.textFieldMarginsProvider;
  }

  set textFieldMarginsProvider(value) {
    this.barView.textFieldMarginsProvider = value;
  }

  /**
   * The font of the Cancel button's title (`{ size, weight }`).
   */
  get cancelButtonFont() {
    return this.barView.cancelButtonFont;
  }

  set cancelButtonFont(value) {
    this.barView.cancelButtonFont = value;
  }

  /**
   * Returns the margins of the Cancel button for the bar's state, `(bar, active) => insets`.
   */
  get cancelButtonMarginsProvider() {
    return this.barView.cancelButtonMarginsProvider;
  }

  set cancelButtonMarginsProvider(value) {
    this.barView.cancelButtonMarginsProvider = value;
  }

  /**
   * Whether the leading accessory (the slot `leading` of `<cyl-search-bar>`) shows, without animation.
   */
  get showsLeadingAccessoryView() {
    return this.barView.showsLeadingView;
  }

  set showsLeadingAccessoryView(value) {
    this.barView.setShowsLeadingView(value, false);
  }

  /**
   * Whether the trailing accessories (the slot `trailing`) show, without animation.
   */
  get showsTrailingAccessoryView() {
    return this.barView.showsTrailingAccessoryViews;
  }

  set showsTrailingAccessoryView(value) {
    this.barView.setShowsTrailingAccessoryViews(value, false);
  }

  /**
   * Whether the Cancel button is enabled while the field has (`editing`) or has not the focus: always with
   * `alwaysEnablesCancelButton`.
   */
  isCancelButtonEnabled(editing) {
    return this.alwaysEnablesCancelButton || !!editing;
  }

  /**
   * Applies `CYLSearchBarAppearance.default()`.
   */
  applyDefaultAppearance() {
    this.barView.applyDefaultAppearance();
  }

  /**
   * Shows or hides the leading accessory, sliding it when `animated`; toggling quickly ends in the last request.
   */
  setShowsLeadingAccessoryView(shows, animated = false) {
    this.barView.setShowsLeadingView(shows, animated);
  }

  /**
   * Shows or hides the trailing accessories, sliding them when `animated`.
   */
  setShowsTrailingAccessoryView(shows, animated = false) {
    this.barView.setShowsTrailingAccessoryViews(shows, animated);
  }

  /**
   * The CSS background of a text field in `color` (iOS draws a resizable image; CSS needs none), or undefined.
   */
  textFieldBackgroundImage(color) {
    return CYLSearchBarAppearance.textFieldBackgroundCSS(color);
  }

  /**
   * The CSS background of a bar: `color` (white by default) with a 1 px bottom border in `borderColor`; undefined when
   * both are missing.
   */
  backgroundImage(color, borderColor) {
    return CYLSearchBarAppearance.backgroundCSS(color, borderColor);
  }
}

module.exports = { CYLSearchBar };
