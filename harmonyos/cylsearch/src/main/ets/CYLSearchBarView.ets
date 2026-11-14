import { CYLSearchBarItem, CYLSearchBarItemOwner, CYLSearchBarItemStyle, CYLSearchBarItemView, CYLSearchBarStyle } from './CYLSearchBarItem';

/**
 * The icon of the button before the field (iOS `CYLSearchBarNavigationIcon`).
 */
export enum CYLSearchBarNavigationIcon {
  /**
   * No button.
   */
  none = 0,
  /**
   * A back arrow.
   */
  arrow = 1,
  /**
   * A magnifier.
   */
  search = 2
}

/**
 * Where the search button sits while the bar is iconified (iOS `CYLSearchBarIconPosition`).
 */
export enum CYLSearchBarIconPosition {
  /**
   * At the end.
   */
  trailing = 0,
  /**
   * In the middle.
   */
  center = 1,
  /**
   * At the start.
   */
  leading = 2
}

/**
 * How the field opens from the search button (iOS `CYLSearchBarExpansionAnimation`).
 */
export enum CYLSearchBarExpansionAnimation {
  /**
   * The field fades in.
   */
  fade = 0,
  /**
   * The field grows from the button, as one animated fraction from an icon circle to the full bar (the technique
   * of Applib-HarmonyOS/FlexibleSearchBar's `startOpen` / `startClose`).
   */
  circularReveal = 1
}

/**
 * The events of a `CYLSearchBarView` (iOS `CYLSearchBarViewDelegate`); every method is optional.
 */
export interface CYLSearchBarViewDelegate {
  /**
   * Asks whether editing may start; false reports `searchBarViewDidTapWhileNotEditable` instead.
   */
  searchBarViewShouldBeginEditing?: (searchBarView: CYLSearchBarView) => boolean;
  /**
   * The field was tapped while it may not be edited.
   */
  searchBarViewDidTapWhileNotEditable?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Editing started.
   */
  searchBarViewDidBeginEditing?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Editing ended.
   */
  searchBarViewDidEndEditing?: (searchBarView: CYLSearchBarView) => void;
  /**
   * The text changed (iOS `-searchBarView:textDidChange:`).
   */
  searchBarViewTextDidChange?: (searchBarView: CYLSearchBarView, text: string) => void;
  /**
   * The search key or the submit button.
   */
  searchBarViewSearchButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Cancel was tapped.
   */
  searchBarViewCancelButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * The button before the field was tapped.
   */
  searchBarViewNavigationButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * The microphone was tapped.
   */
  searchBarViewVoiceButtonClicked?: (searchBarView: CYLSearchBarView) => void;
  /**
   * Asks whether the text may be submitted (iOS `-searchBarView:shouldSubmitText:`).
   */
  searchBarViewShouldSubmitText?: (searchBarView: CYLSearchBarView, text: string) => boolean;
  /**
   * The field opened or closed (iOS `-searchBarView:didChangeIconified:`).
   */
  searchBarViewDidChangeIconified?: (searchBarView: CYLSearchBarView, iconified: boolean) => void;
  /**
   * An appended item was tapped (iOS `-searchBarView:didSelectItem:`).
   */
  searchBarViewDidSelectItem?: (searchBarView: CYLSearchBarView, item: CYLSearchBarItem) => void;
}

/**
 * A configurable search bar (iOS `CYLSearchBarView`): a rounded field with a magnifier, text and clear button,
 * appended items after the text, a button before the field and an optional Cancel button. This class is the bar's
 * state and API; `CYLSearchBarComponent` draws it. Sizes are in vp, durations in seconds, as on iOS.
 */
@ObservedV2
export class CYLSearchBarView implements CYLSearchBarItemOwner {
  private static nextIdentifier: number = 0;
  /**
   * Receives the events.
   */
  delegate: CYLSearchBarViewDelegate | undefined = undefined;
  /**
   * The id of the text input, for focus (`showKeyboard`) and tests.
   */
  readonly textFieldId: string;
  /**
   * The text input's controller (caret and editing).
   */
  readonly textField: TextInputController = new TextInputController();
  /**
   * The text of the field.
   */
  @Trace text: string = '';
  /**
   * The placeholder.
   */
  @Trace placeholder: string | undefined = undefined;
  /**
   * The font size in fp. 17 by default.
   */
  @Trace font: number = 17;
  /**
   * The text color; undefined uses the primary text color.
   */
  @Trace textColor: ResourceColor | undefined = undefined;
  /**
   * The placeholder color; undefined uses the tertiary text color.
   */
  @Trace placeholderColor: ResourceColor | undefined = undefined;
  /**
   * The caret color; undefined uses the system accent.
   */
  @Trace cursorColor: ResourceColor | undefined = undefined;
  /**
   * The field's height. 36 by default.
   */
  @Trace fieldHeight: number = 36;
  /**
   * The space around the field inside the bar.
   */
  @Trace contentInsets: Padding = { top: 6, left: 12, bottom: 6, right: 12 };
  /**
   * The field's background; undefined uses a light fill.
   */
  @Trace fieldBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The field's corner radius; negative makes a capsule. -1 by default.
   */
  @Trace fieldCornerRadius: number = -1;
  /**
   * The field's border color; undefined draws no border.
   */
  @Trace fieldBorderColor: ResourceColor | undefined = undefined;
  /**
   * The field's border width, used with `fieldBorderColor`. 0 by default.
   */
  @Trace fieldBorderWidth: number = 0;
  /**
   * The field's shadow, 0 to 1. 0 by default.
   */
  @Trace fieldShadowOpacity: number = 0;
  /**
   * An image drawn behind the field's content, clipped to its corners.
   */
  @Trace fieldBackgroundImage: ResourceStr | undefined = undefined;
  /**
   * The magnifier at the start of the field; undefined hides it.
   */
  @Trace searchIcon: Resource | undefined = $r('sys.symbol.magnifyingglass');
  /**
   * The magnifier's color; undefined uses the secondary text color.
   */
  @Trace searchIconTintColor: ResourceColor | undefined = undefined;
  /**
   * Shows the Cancel button after the field. False by default.
   */
  @Trace showsCancelButton: boolean = false;
  /**
   * The Cancel button's title.
   */
  @Trace cancelButtonTitle: string = 'Cancel';
  /**
   * Cancel also ends editing. True by default.
   */
  cancelButtonEndsEditing: boolean = true;
  /**
   * Cancel also clears the text. False by default.
   */
  clearsTextOnCancel: boolean = false;
  /**
   * Ending editing clears the text. False by default.
   */
  clearsTextOnEndEditing: boolean = false;
  /**
   * The icon of the button before the field; `none` hides it unless `navigationImage` is set.
   */
  @Trace navigationIcon: CYLSearchBarNavigationIcon = CYLSearchBarNavigationIcon.none;
  /**
   * A symbol of yours for the button before the field; it wins over `navigationIcon`.
   */
  @Trace navigationImage: Resource | undefined = undefined;
  /**
   * What screen readers read for the button before the field.
   */
  @Trace navigationAccessibilityLabel: string = 'Back';
  /**
   * A round background behind the button before the field; undefined draws none.
   */
  @Trace navigationBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * The shadow of the button before the field, 0 to 1.
   */
  @Trace navigationShadowOpacity: number = 0;
  /**
   * Called when the button before the field is tapped, after the delegate.
   */
  navigationHandler: ((searchBarView: CYLSearchBarView) => void) | undefined = undefined;
  /**
   * Shows a microphone inside the field while the text is empty. False by default.
   */
  @Trace showsVoiceButton: boolean = false;
  /**
   * The microphone's symbol.
   */
  @Trace voiceImage: Resource = $r('sys.symbol.mic');
  /**
   * Shows a submit button inside the field while there is text. False by default.
   */
  @Trace showsSubmitButton: boolean = false;
  /**
   * The submit button's symbol.
   */
  @Trace submitImage: Resource = $r('sys.symbol.arrow_right');
  /**
   * The clear button's symbol.
   */
  @Trace clearImage: Resource = $r('sys.symbol.xmark_circle_fill');
  /**
   * The keyboard (iOS `keyboardType`).
   */
  @Trace keyboardType: InputType = InputType.Normal;
  /**
   * The return key (iOS `returnKeyType`). Search by default.
   */
  @Trace returnKeyType: EnterKeyType = EnterKeyType.Search;
  /**
   * Hides the typed text (iOS `isSecureTextEntry`).
   */
  @Trace isSecureTextEntry: boolean = false;
  /**
   * The longest text allowed; 0 is no limit.
   */
  @Trace maximumTextLength: number = 0;
  /**
   * The bar shows only its search button until it is tapped. False by default.
   */
  @Trace iconifiedByDefault: boolean = false;
  /**
   * How the field opens from the search button.
   */
  expansionAnimation: CYLSearchBarExpansionAnimation = CYLSearchBarExpansionAnimation.fade;
  /**
   * Where the search button sits while iconified.
   */
  @Trace iconPosition: CYLSearchBarIconPosition = CYLSearchBarIconPosition.trailing;
  /**
   * The duration of the open and close animation, in seconds. 0.3 by default.
   */
  animationDuration: number = 0.3;
  /**
   * The appended items, in order, after the text (like the FlatDesign tab bar's `items`). The field stays; only
   * items are appended.
   */
  @Trace items: CYLSearchBarItem[] = [];
  /**
   * The icon and title color of every item without its own `tintColor`; undefined uses the primary text color.
   */
  @Trace itemTintColor: ResourceColor | undefined = undefined;

  @Trace private style: CYLSearchBarStyle = CYLSearchBarStyle.plain;
  @Trace private iconified: boolean = false;
  /**
   * 0 while iconified, 1 while open; animated between the two (FlexibleSearchBar's single fraction).
   */
  @Trace expansionFraction: number = 1;
  /**
   * Whether the field is being edited.
   */
  @Trace isEditing: boolean = false;

  /**
   * A bar with the default look (iOS `-initWithFrame:`).
   */
  constructor() {
    CYLSearchBarView.nextIdentifier += 1;
    this.textFieldId = `CYLSearchBarTextField${CYLSearchBarView.nextIdentifier}`;
  }

  /**
   * The fixed look of the bar. `bordered` draws the field and its items inside one capsule outline.
   */
  get searchBarStyle(): CYLSearchBarStyle {
    return this.style;
  }

  set searchBarStyle(value: CYLSearchBarStyle) {
    this.style = value;
    if (value === CYLSearchBarStyle.bordered) {
      this.fieldBorderColor = $r('sys.color.comp_divider');
      this.fieldBorderWidth = 1;
      this.fieldBackgroundColor = $r('sys.color.comp_background_primary');
      this.fieldCornerRadius = -1;
    }
  }

  /**
   * Whether the bar shows only its search button.
   */
  get isIconified(): boolean {
    return this.iconified;
  }

  /**
   * The views of `items` are drawn by `CYLSearchBarItemView`; this is the list they draw, in order.
   */
  get itemViews(): CYLSearchBarItem[] {
    return this.items;
  }

  /**
   * The first selected item (a `isSelectable` item that is on), or undefined.
   */
  get selectedItem(): CYLSearchBarItem | undefined {
    return this.items.find((item: CYLSearchBarItem) => item.isSelected);
  }

  /**
   * The index of `selectedItem`, or -1.
   */
  get selectedIndex(): number {
    return this.items.findIndex((item: CYLSearchBarItem) => item.isSelected);
  }

  /**
   * Appends an item after the others (iOS `-addItem:`).
   */
  addItem(item: CYLSearchBarItem): void {
    this.insertItem(item, this.items.length);
  }

  /**
   * Inserts an item at an index, clamped to `items` (iOS `-insertItem:atIndex:`).
   */
  insertItem(item: CYLSearchBarItem, index: number): void {
    if (item.searchBarView !== undefined) {
      const owner = item.searchBarView as CYLSearchBarView;
      owner.removeItem(item);
    }
    const position = Math.min(Math.max(0, index), this.items.length);
    this.items.splice(position, 0, item);
    item.searchBarView = this;
  }

  /**
   * Creates an item and inserts it at an index; a negative or larger index appends it (iOS
   * `-addItemWithStyle:title:image:index:handler:`).
   */
  addItemWithStyle(style: CYLSearchBarItemStyle, title: string | undefined, image: Resource | undefined,
    index: number = -1, handler?: (item: CYLSearchBarItem) => void): CYLSearchBarItem {
    const item = new CYLSearchBarItem(style, title, image);
    item.handler = handler;
    this.insertItem(item, index < 0 ? this.items.length : index);
    return item;
  }

  /**
   * Removes an item from the bar (iOS `-removeItem:`).
   */
  removeItem(item: CYLSearchBarItem): void {
    const index = this.items.indexOf(item);
    if (index < 0) {
      return;
    }
    this.items.splice(index, 1);
    item.searchBarView = undefined;
  }

  /**
   * Removes every item.
   */
  removeAllItems(): void {
    this.items.forEach((item: CYLSearchBarItem) => {
      item.searchBarView = undefined;
    });
    this.items = [];
  }

  /**
   * True when an item of the style was appended (iOS `-hasItemOfStyle:`).
   */
  hasItem(style: CYLSearchBarItemStyle): boolean {
    return this.items.some((item: CYLSearchBarItem) => item.style === style);
  }

  /**
   * An item was tapped: a selectable item toggles, then the delegate and the item's handler are told.
   */
  itemTapped(item: CYLSearchBarItem): void {
    if (!item.isEnabled) {
      return;
    }
    if (item.isSelectable) {
      item.isSelected = !item.isSelected;
    }
    this.delegate?.searchBarViewDidSelectItem?.(this, item);
    item.handler?.(item);
  }

  /**
   * Sets the text and, when `submit` is true, submits it (iOS `-setText:submit:`).
   */
  setText(text: string | undefined, submit: boolean): void {
    this.textChanged(text ?? '');
    if (submit) {
      this.submit();
    }
  }

  /**
   * Submits the text like the search key; false when the text is empty or the delegate refuses it.
   */
  submit(): boolean {
    if (this.text.length === 0) {
      return false;
    }
    const allowed = this.delegate?.searchBarViewShouldSubmitText?.(this, this.text) ?? true;
    if (!allowed) {
      return false;
    }
    this.delegate?.searchBarViewSearchButtonClicked?.(this);
    return true;
  }

  /**
   * Focuses the field, which raises the keyboard.
   */
  showKeyboard(): void {
    focusControl.requestFocus(this.textFieldId);
  }

  /**
   * Focuses the field and returns true (iOS `-becomeFirstResponder`).
   */
  becomeFirstResponder(): boolean {
    this.showKeyboard();
    return true;
  }

  /**
   * Ends editing and returns true (iOS `-resignFirstResponder`).
   */
  resignFirstResponder(): boolean {
    this.hideKeyboard();
    return true;
  }

  /**
   * Ends editing, which lowers the keyboard.
   */
  hideKeyboard(): void {
    this.textField.stopEditing();
  }

  /**
   * Opens or closes the field, animated over `animationDuration` when `animated` is true (iOS
   * `-setIconified:animated:`). Opening also starts editing.
   */
  setIconified(iconified: boolean, animated: boolean): void {
    if (this.iconified === iconified) {
      return;
    }
    if (iconified) {
      this.hideKeyboard();
    }
    const apply = () => {
      this.iconified = iconified;
      this.expansionFraction = iconified ? 0 : 1;
    };
    if (animated && this.animationDuration > 0) {
      animateTo({ duration: this.animationDuration * 1000, curve: Curve.EaseInOut }, apply);
    } else {
      apply();
    }
    if (!iconified) {
      this.showKeyboard();
    }
    this.delegate?.searchBarViewDidChangeIconified?.(this, iconified);
  }

  /**
   * The state to keep across a restart: the text and whether the bar is iconified (iOS
   * `-encodeRestorableStateWithCoder:`).
   */
  encodeRestorableState(): Record<string, Object> {
    const state: Record<string, Object> = { 'text': this.text, 'iconified': this.iconified };
    return state;
  }

  /**
   * Restores what `encodeRestorableState` returned (iOS `-decodeRestorableStateWithCoder:`).
   */
  decodeRestorableState(state: Record<string, Object>): void {
    this.textChanged((state['text'] as string | undefined) ?? '');
    this.setIconified((state['iconified'] as boolean | undefined) ?? false, false);
  }

  /**
   * The bar's height: the field and the insets above and below it (iOS `intrinsicContentSize`).
   */
  get intrinsicContentSize(): number {
    return this.fieldHeight + Number(this.contentInsets.top ?? 0) + Number(this.contentInsets.bottom ?? 0);
  }

  /**
   * The component reports a new text; the delegate is told when it differs.
   */
  textChanged(text: string): void {
    let next = text;
    if (this.maximumTextLength > 0 && next.length > this.maximumTextLength) {
      next = next.substring(0, this.maximumTextLength);
    }
    if (next === this.text) {
      return;
    }
    this.text = next;
    this.delegate?.searchBarViewTextDidChange?.(this, next);
  }

  /**
   * The component reports that editing started or ended.
   */
  editingChanged(editing: boolean): void {
    if (this.isEditing === editing) {
      return;
    }
    this.isEditing = editing;
    if (editing) {
      this.delegate?.searchBarViewDidBeginEditing?.(this);
    } else {
      if (this.clearsTextOnEndEditing) {
        this.textChanged('');
      }
      this.delegate?.searchBarViewDidEndEditing?.(this);
    }
  }

  /**
   * Cancel was tapped.
   */
  cancelTapped(): void {
    if (this.clearsTextOnCancel) {
      this.textChanged('');
    }
    if (this.cancelButtonEndsEditing) {
      this.hideKeyboard();
    }
    this.delegate?.searchBarViewCancelButtonClicked?.(this);
  }

  /**
   * The button before the field was tapped.
   */
  navigationTapped(): void {
    this.delegate?.searchBarViewNavigationButtonClicked?.(this);
    this.navigationHandler?.(this);
  }

  /**
   * The microphone was tapped.
   */
  voiceTapped(): void {
    this.delegate?.searchBarViewVoiceButtonClicked?.(this);
  }

  /**
   * The symbol of the button before the field, or undefined when it is hidden.
   */
  get navigationSymbol(): Resource | undefined {
    if (this.navigationImage !== undefined) {
      return this.navigationImage;
    }
    if (this.navigationIcon === CYLSearchBarNavigationIcon.arrow) {
      return $r('sys.symbol.chevron_backward');
    }
    if (this.navigationIcon === CYLSearchBarNavigationIcon.search) {
      return $r('sys.symbol.magnifyingglass');
    }
    return undefined;
  }
}

/**
 * Draws a `CYLSearchBarView`: the button before the field, the field (magnifier, text, clear button, voice or
 * submit button, appended items) and Cancel; while iconified, only the search button.
 */
@ComponentV2
export struct CYLSearchBarComponent {
  /**
   * The bar to draw.
   */
  @Require @Param searchBarView: CYLSearchBarView;
  /**
   * A view of yours before the field (a back button); it wins over the navigation button (iOS `leadingView`).
   */
  @BuilderParam leadingView: () => void = this.emptyBuilder;
  /**
   * Views of yours inside the field after the text, before the items (iOS `trailingAccessoryViews`).
   */
  @BuilderParam trailingAccessoryViews: () => void = this.emptyBuilder;

  @Builder
  emptyBuilder() {
  }

  private secondary(): ResourceColor {
    return this.searchBarView.searchIconTintColor ?? $r('sys.color.font_secondary');
  }

  private radius(): number {
    return this.searchBarView.fieldCornerRadius < 0 ? this.searchBarView.fieldHeight / 2 :
    this.searchBarView.fieldCornerRadius;
  }

  private iconAlignment(): FlexAlign {
    if (this.searchBarView.iconPosition === CYLSearchBarIconPosition.center) {
      return FlexAlign.Center;
    }
    return this.searchBarView.iconPosition === CYLSearchBarIconPosition.leading ? FlexAlign.Start : FlexAlign.End;
  }

  aboutToAppear(): void {
    if (this.searchBarView.iconifiedByDefault) {
      this.searchBarView.setIconified(true, false);
    }
  }

  @Builder
  field() {
    Row({ space: 8 }) {
      if (this.searchBarView.searchIcon !== undefined) {
        SymbolGlyph(this.searchBarView.searchIcon)
          .fontSize(18)
          .fontColor([this.secondary()])
          .accessibilityLevel('no')
      }
      TextInput({
        text: this.searchBarView.text,
        placeholder: this.searchBarView.placeholder,
        controller: this.searchBarView.textField
      })
        .id(this.searchBarView.textFieldId)
        .layoutWeight(1)
        .height('100%')
        .padding(0)
        .backgroundColor(Color.Transparent)
        .borderRadius(0)
        .fontSize(this.searchBarView.font)
        .fontColor(this.searchBarView.textColor ?? $r('sys.color.font_primary'))
        .placeholderColor(this.searchBarView.placeholderColor ?? $r('sys.color.font_tertiary'))
        .placeholderFont({ size: this.searchBarView.font })
        .caretColor(this.searchBarView.cursorColor ?? $r('sys.color.brand'))
        .type(this.searchBarView.isSecureTextEntry ? InputType.Password : this.searchBarView.keyboardType)
        .enterKeyType(this.searchBarView.returnKeyType)
        .maxLength(this.searchBarView.maximumTextLength > 0 ? this.searchBarView.maximumTextLength : 100000)
        .cancelButton({ style: CancelButtonStyle.INPUT, icon: { color: this.secondary() } })
        .onChange((value: string) => {
          this.searchBarView.textChanged(value);
        })
        .onEditChange((editing: boolean) => {
          this.searchBarView.editingChanged(editing);
        })
        .onSubmit(() => {
          this.searchBarView.submit();
        })
        .onWillInsert(() => {
          const allowed = this.searchBarView.delegate?.searchBarViewShouldBeginEditing?.(this.searchBarView) ?? true;
          if (!allowed) {
            this.searchBarView.delegate?.searchBarViewDidTapWhileNotEditable?.(this.searchBarView);
          }
          return allowed;
        })
      this.trailingAccessoryViews()
      if (this.searchBarView.showsVoiceButton && this.searchBarView.text.length === 0) {
        SymbolGlyph(this.searchBarView.voiceImage)
          .fontSize(20)
          .fontColor([this.secondary()])
          .accessibilityText('Voice search')
          .onClick(() => {
            this.searchBarView.voiceTapped();
          })
      }
      if (this.searchBarView.showsSubmitButton && this.searchBarView.text.length > 0) {
        SymbolGlyph(this.searchBarView.submitImage)
          .fontSize(20)
          .fontColor([this.secondary()])
          .accessibilityText('Search')
          .onClick(() => {
            this.searchBarView.submit();
          })
      }
      ForEach(this.searchBarView.items, (item: CYLSearchBarItem) => {
        CYLSearchBarItemView({
          item: item,
          itemTintColor: this.searchBarView.itemTintColor,
          onSelect: (selected: CYLSearchBarItem) => {
            this.searchBarView.itemTapped(selected);
          }
        })
      }, (item: CYLSearchBarItem, index: number) => `${index}-${item.style}-${item.title ?? ''}`)
    }
    .layoutWeight(1)
    .height(this.searchBarView.fieldHeight)
    .padding({ left: 12, right: 12 })
    .backgroundColor(this.searchBarView.fieldBackgroundColor ?? $r('sys.color.comp_background_tertiary'))
    .backgroundImage(this.searchBarView.fieldBackgroundImage)
    .backgroundImageSize(ImageSize.Cover)
    .borderRadius(this.radius())
    .border({
      width: this.searchBarView.fieldBorderColor !== undefined ? this.searchBarView.fieldBorderWidth : 0,
      color: this.searchBarView.fieldBorderColor ?? Color.Transparent
    })
    .shadow({
      radius: this.searchBarView.fieldShadowOpacity > 0 ? 8 : 0,
      color: `rgba(0,0,0,${this.searchBarView.fieldShadowOpacity * 0.3})`,
      offsetY: this.searchBarView.fieldShadowOpacity > 0 ? 2 : 0
    })
    .clip(this.searchBarView.fieldBackgroundImage !== undefined)
    .opacity(this.searchBarView.expansionFraction)
    .scale(this.searchBarView.expansionAnimation === CYLSearchBarExpansionAnimation.circularReveal ?
      { x: 0.1 + 0.9 * this.searchBarView.expansionFraction, y: 1 } : { x: 1, y: 1 })
  }

  build() {
    Row({ space: 8 }) {
      if (this.searchBarView.isIconified) {
        Row() {
          SymbolGlyph($r('sys.symbol.magnifyingglass'))
            .fontSize(22)
            .fontColor([this.secondary()])
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .accessibilityGroup(true)
        .accessibilityText('Search')
        .onClick(() => {
          this.searchBarView.setIconified(false, true);
        })
      } else {
        this.leadingView()
        if (this.searchBarView.navigationSymbol !== undefined) {
          Row() {
            SymbolGlyph(this.searchBarView.navigationSymbol)
              .fontSize(22)
              .fontColor([this.searchBarView.textColor ?? $r('sys.color.font_primary')])
          }
          .width(44)
          .height(44)
          .justifyContent(FlexAlign.Center)
          .backgroundColor(this.searchBarView.navigationBackgroundColor ?? Color.Transparent)
          .borderRadius(22)
          .shadow({
            radius: this.searchBarView.navigationShadowOpacity > 0 ? 6 : 0,
            color: `rgba(0,0,0,${this.searchBarView.navigationShadowOpacity * 0.3})`
          })
          .accessibilityGroup(true)
          .accessibilityText(this.searchBarView.navigationAccessibilityLabel)
          .onClick(() => {
            this.searchBarView.navigationTapped();
          })
        }
        this.field()
        if (this.searchBarView.showsCancelButton) {
          Text(this.searchBarView.cancelButtonTitle)
            .fontSize(this.searchBarView.font)
            .fontColor($r('sys.color.brand'))
            .maxLines(1)
            .constraintSize({ minWidth: 44, minHeight: 36 })
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.searchBarView.cancelTapped();
            })
        }
      }
    }
    .width('100%')
    .justifyContent(this.searchBarView.isIconified ? this.iconAlignment() : FlexAlign.Start)
    .padding(this.searchBarView.contentInsets)
  }
}
