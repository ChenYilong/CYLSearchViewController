import { CYLSearchBarAppearance, CYLSearchBarView, CYLSearchEdgeInsets } from './CYLSearchBarView';

/**
 * A search bar that is styled by `CYLSearchBarAppearance` and adds what QMUI's `QMUISearchBar` adds to a platform search
 * bar: a centered placeholder, placeholder and text colors and fonts, margins of the text field and the Cancel button,
 * accessory views and a Cancel button that stays enabled (iOS `CYLSearchBar`, a `UISearchBar`). On HarmonyOS the bar is
 * the model `CYLSearchBarView` that `CYLSearchBarComponent` draws; this class is the QMUI-shaped front of it, so a
 * `CYLSearchController` and a `CYLSearchTableViewController` configure the bar with the iOS names.
 */
export class CYLSearchBar {
  /**
   * The bar's model: pass it to `CYLSearchBarComponent`.
   */
  readonly searchBarView: CYLSearchBarView;
  /**
   * Whether the bar is a list's header (iOS `usedAsTableHeaderView`, QMUI `qmui_usedAsTableHeaderView`). Set by the
   * screens that install the bar as a header; false by default.
   */
  usedAsTableHeaderView: boolean = false;
  private marginsProvider: ((active: boolean) => CYLSearchEdgeInsets) | undefined = undefined;
  private cancelMarginsProvider: ((active: boolean) => CYLSearchEdgeInsets) | undefined = undefined;

  /**
   * A bar styled with the default appearance; `searchBarView` wraps a model you already have.
   */
  constructor(searchBarView?: CYLSearchBarView) {
    this.searchBarView = searchBarView ?? new CYLSearchBarView();
    if (searchBarView === undefined) {
      this.applyDefaultAppearance();
    }
  }

  /**
   * The style applied to the bar (a copy of `CYLSearchBarAppearance.defaultAppearance` when the bar is created).
   * Assigning a style applies it.
   */
  get appearanceStyle(): CYLSearchBarAppearance {
    return this.searchBarView.appearanceStyle;
  }

  set appearanceStyle(value: CYLSearchBarAppearance) {
    this.searchBarView.appearanceStyle = value;
  }

  /**
   * Whether the magnifier and the placeholder are centered in the field while the bar is not editing and has no text
   * (QMUI `qmui_centerPlaceholder`). Default false.
   */
  get centersPlaceholder(): boolean {
    return this.searchBarView.centersPlaceholder;
  }

  set centersPlaceholder(value: boolean) {
    this.searchBarView.centersPlaceholder = value;
  }

  /**
   * The placeholder's color (QMUI `qmui_placeholderColor`).
   */
  get placeholderColor(): ResourceColor | undefined {
    return this.searchBarView.placeholderColor;
  }

  set placeholderColor(value: ResourceColor | undefined) {
    this.searchBarView.placeholderColor = value;
  }

  /**
   * The color of the typed text (QMUI `qmui_textColor`).
   */
  get textColor(): ResourceColor | undefined {
    return this.searchBarView.textColor;
  }

  set textColor(value: ResourceColor | undefined) {
    this.searchBarView.textColor = value;
  }

  /**
   * The font size, in fp, of the typed text and of the placeholder (QMUI `qmui_font`).
   */
  get font(): number {
    return this.searchBarView.font;
  }

  set font(value: number) {
    this.searchBarView.font = value;
  }

  /**
   * The margins added to the text field's frame (QMUI `qmui_textFieldMargins`). A positive value shrinks the field, a
   * negative one grows it.
   */
  get textFieldMargins(): CYLSearchEdgeInsets {
    return this.searchBarView.textFieldMargins;
  }

  set textFieldMargins(value: CYLSearchEdgeInsets) {
    this.searchBarView.textFieldMargins = value;
  }

  /**
   * Returns the margins of the text field for the bar's state (true while searching); wins over `textFieldMargins`
   * (QMUI `qmui_textFieldMarginsBlock`).
   */
  get textFieldMarginsProvider(): ((active: boolean) => CYLSearchEdgeInsets) | undefined {
    return this.marginsProvider;
  }

  set textFieldMarginsProvider(value: ((active: boolean) => CYLSearchEdgeInsets) | undefined) {
    this.marginsProvider = value;
    this.searchBarView.textFieldMarginsProvider = value === undefined ? undefined :
      (searchBarView: CYLSearchBarView, active: boolean): CYLSearchEdgeInsets => value(active);
  }

  /**
   * The font size of the Cancel button's title, in fp (QMUI `qmui_cancelButtonFont`); undefined uses `font`.
   */
  get cancelButtonFont(): number | undefined {
    return this.searchBarView.cancelButtonFont;
  }

  set cancelButtonFont(value: number | undefined) {
    this.searchBarView.cancelButtonFont = value;
  }

  /**
   * Returns the margins applied to the Cancel button for the bar's state (true while searching); a negative left value
   * moves it left and widens it (QMUI `qmui_cancelButtonMarginsBlock`).
   */
  get cancelButtonMarginsProvider(): ((active: boolean) => CYLSearchEdgeInsets) | undefined {
    return this.cancelMarginsProvider;
  }

  set cancelButtonMarginsProvider(value: ((active: boolean) => CYLSearchEdgeInsets) | undefined) {
    this.cancelMarginsProvider = value;
    this.searchBarView.cancelButtonMarginsProvider = value === undefined ? undefined :
      (searchBarView: CYLSearchBarView, active: boolean): CYLSearchEdgeInsets => value(active);
  }

  /**
   * Whether the Cancel button stays enabled although the field is not being edited (QMUI
   * `qmui_alwaysEnableCancelButton`). Default true.
   */
  get alwaysEnablesCancelButton(): boolean {
    return this.searchBarView.alwaysEnablesCancelButton;
  }

  set alwaysEnablesCancelButton(value: boolean) {
    this.searchBarView.alwaysEnablesCancelButton = value;
  }

  /**
   * The view left of the text field (QMUI `qmui_leftAccessoryView`).
   */
  get leadingAccessoryView(): WrappedBuilder<[]> | undefined {
    return this.searchBarView.leadingView;
  }

  set leadingAccessoryView(value: WrappedBuilder<[]> | undefined) {
    this.searchBarView.leadingView = value;
  }

  /**
   * Whether the leading accessory view is shown (QMUI `qmui_showsLeftAccessoryView`), without animation. Default true.
   */
  get showsLeadingAccessoryView(): boolean {
    return this.searchBarView.showsLeadingView;
  }

  set showsLeadingAccessoryView(value: boolean) {
    this.searchBarView.showsLeadingView = value;
  }

  /**
   * The space around the leading accessory view; `right` is the gap to the text field.
   */
  get leadingAccessoryViewMargins(): CYLSearchEdgeInsets {
    return this.searchBarView.leadingAccessoryViewMargins;
  }

  set leadingAccessoryViewMargins(value: CYLSearchEdgeInsets) {
    this.searchBarView.leadingAccessoryViewMargins = value;
  }

  /**
   * The view right of the text field (QMUI `qmui_rightAccessoryView`).
   */
  get trailingAccessoryView(): WrappedBuilder<[]> | undefined {
    return this.searchBarView.trailingAccessoryViews;
  }

  set trailingAccessoryView(value: WrappedBuilder<[]> | undefined) {
    this.searchBarView.trailingAccessoryViews = value;
  }

  /**
   * Whether the trailing accessory view is shown (QMUI `qmui_showsRightAccessoryView`), without animation. Default true.
   */
  get showsTrailingAccessoryView(): boolean {
    return this.searchBarView.showsTrailingAccessoryViews;
  }

  set showsTrailingAccessoryView(value: boolean) {
    this.searchBarView.showsTrailingAccessoryViews = value;
  }

  /**
   * The space around the trailing accessory view; `left` is the gap to the text field.
   */
  get trailingAccessoryViewMargins(): CYLSearchEdgeInsets {
    return this.searchBarView.trailingAccessoryViewMargins;
  }

  set trailingAccessoryViewMargins(value: CYLSearchEdgeInsets) {
    this.searchBarView.trailingAccessoryViewMargins = value;
  }

  /**
   * Applies `CYLSearchBarAppearance.defaultAppearance` (QMUI `qmui_styledAsQMUISearchBar`).
   */
  applyDefaultAppearance(): void {
    this.searchBarView.applyDefaultAppearance();
  }

  /**
   * Shows or hides the leading accessory view, optionally sliding it (QMUI `qmui_setShowsLeftAccessoryView:animated:`).
   * Toggling quickly ends in the last requested state.
   */
  setShowsLeadingAccessoryView(shows: boolean, animated: boolean): void {
    this.searchBarView.setShowsLeadingView(shows, animated);
  }

  /**
   * Shows or hides the trailing accessory view, optionally sliding it (QMUI `qmui_setShowsRightAccessoryView:animated:`).
   * Toggling quickly ends in the last requested state.
   */
  setShowsTrailingAccessoryView(shows: boolean, animated: boolean): void {
    this.searchBarView.setShowsTrailingAccessoryViews(shows, animated);
  }
}
