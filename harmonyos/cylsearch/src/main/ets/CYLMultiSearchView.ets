/**
 * Events of a `CYLMultiSearchView` (iOS `CYLMultiSearchViewDelegate`); every method is optional.
 */
export interface CYLMultiSearchViewDelegate {
  /**
   * The text of the search being typed changed (iOS `-multiSearchView:textDidChange:atIndex:`).
   */
  multiSearchViewTextDidChange?: (multiSearchView: CYLMultiSearchView, text: string, index: number) => void;
  /**
   * A search was completed and became an item (iOS `-multiSearchView:didCompleteSearch:atIndex:`).
   */
  multiSearchViewDidCompleteSearch?: (multiSearchView: CYLMultiSearchView, text: string, index: number) => void;
  /**
   * An item was removed (iOS `-multiSearchView:didRemoveItemAtIndex:`).
   */
  multiSearchViewDidRemoveItemAtIndex?: (multiSearchView: CYLMultiSearchView, index: number) => void;
  /**
   * An item was selected by a tap (iOS `-multiSearchView:didSelectItem:atIndex:`).
   */
  multiSearchViewDidSelectItem?: (multiSearchView: CYLMultiSearchView, text: string, index: number) => void;
}

/**
 * Several searches side by side (iOS `CYLMultiSearchView`): the search button starts a new search; a completed
 * search becomes an item; a tap selects an item and its remove button removes it. This class is the state and API;
 * `CYLMultiSearchComponent` draws it.
 */
@ObservedV2
export class CYLMultiSearchView {
  private static nextIdentifier: number = 0;
  /**
   * Receives the events.
   */
  delegate: CYLMultiSearchViewDelegate | undefined = undefined;
  /**
   * The selected item, or -1 when there is none.
   */
  @Trace selectedIndex: number = -1;
  /**
   * The placeholder of a new search. "Search" by default.
   */
  @Trace placeholder: ResourceStr = $r('app.string.cyl_search_placeholder');
  /**
   * The font size of the items, in fp. 17 by default.
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
   * The longest search a person can type; 0 means no limit.
   */
  @Trace maximumTextLength: number = 0;
  /**
   * A search shorter than this is dropped when it is completed. 3 by default.
   */
  minimumTextLength: number = 3;
  /**
   * The return key. Search by default.
   */
  @Trace returnKeyType: EnterKeyType = EnterKeyType.Search;
  /**
   * The keyboard.
   */
  @Trace keyboardType: InputType = InputType.Normal;
  /**
   * The color of the indicator under the selected item and of the buttons; undefined uses the system accent.
   */
  @Trace indicatorColor: ResourceColor | undefined = undefined;
  /**
   * The opacity of items that are not selected. 0.5 by default.
   */
  @Trace unselectedItemAlpha: number = 0.5;
  /**
   * The width of the field for a new search, in vp. 160 by default.
   */
  @Trace searchFieldWidth: number = 160;
  /**
   * The length of the animations, in seconds. 0.25 by default.
   */
  animationDuration: number = 0.25;
  /**
   * The search button's symbol. A magnifier by default.
   */
  @Trace searchImage: Resource = $r('sys.symbol.magnifyingglass');
  /**
   * The remove button's symbol.
   */
  @Trace removeImage: Resource = $r('sys.symbol.xmark_circle_fill');
  /**
   * The id of the text input of the search being typed.
   */
  readonly textFieldId: string;
  /**
   * The text of the search being typed.
   */
  @Trace typedText: string = '';

  @Trace private completed: string[] = [];
  @Trace private typing: boolean = false;

  /**
   * An empty multi search view (iOS `-initWithFrame:`).
   */
  constructor() {
    CYLMultiSearchView.nextIdentifier += 1;
    this.textFieldId = `CYLMultiSearchTextField${CYLMultiSearchView.nextIdentifier}`;
  }

  /**
   * True while a new search is being typed (iOS `inSearchMode`).
   */
  get isInSearchMode(): boolean {
    return this.typing;
  }

  /**
   * The texts of the items, completed searches first, then the one being typed.
   */
  get searchTexts(): string[] {
    return this.typing ? this.completed.concat([this.typedText]) : this.completed.slice();
  }

  /**
   * The completed searches, as the component lists them.
   */
  get completedSearchTexts(): string[] {
    return this.completed;
  }

  /**
   * The view's height: one row of items (iOS `intrinsicContentSize`).
   */
  get intrinsicContentSize(): number {
    return 48;
  }

  /**
   * Starts a new search and shows the keyboard. Does nothing while a search is being typed.
   */
  search(): void {
    if (this.typing) {
      return;
    }
    this.typedText = '';
    this.typing = true;
    this.selectedIndex = this.completed.length;
    setTimeout(() => {
      focusControl.requestFocus(this.textFieldId);
    }, 50);
  }

  /**
   * Completes the search being typed: it becomes the selected item, or is dropped when shorter than
   * `minimumTextLength`.
   */
  completeSearch(): void {
    if (!this.typing) {
      return;
    }
    const text = this.typedText.trim();
    this.typing = false;
    this.typedText = '';
    if (text.length < this.minimumTextLength) {
      this.selectedIndex = this.completed.length > 0 ? this.completed.length - 1 : -1;
      return;
    }
    this.completed.push(text);
    this.selectedIndex = this.completed.length - 1;
    this.delegate?.multiSearchViewDidCompleteSearch?.(this, text, this.selectedIndex);
  }

  /**
   * Adds a completed search without typing it and selects it.
   */
  addSearchText(text: string): void {
    const value = text.trim();
    if (value.length === 0) {
      return;
    }
    if (this.typing) {
      this.typing = false;
      this.typedText = '';
    }
    this.completed.push(value);
    this.selectedIndex = this.completed.length - 1;
    this.delegate?.multiSearchViewDidCompleteSearch?.(this, value, this.selectedIndex);
  }

  /**
   * Selects an item, like a tap on it (iOS `-selectItemAtIndex:`).
   */
  selectItemAtIndex(index: number): void {
    if (index < 0 || index >= this.completed.length) {
      return;
    }
    if (this.typing) {
      this.completeSearch();
    }
    this.selectedIndex = Math.min(index, this.completed.length - 1);
    this.delegate?.multiSearchViewDidSelectItem?.(this, this.completed[this.selectedIndex], this.selectedIndex);
  }

  /**
   * Removes an item, like a tap on its remove button (iOS `-removeItemAtIndex:`).
   */
  removeItemAtIndex(index: number): void {
    if (index < 0 || index >= this.completed.length) {
      return;
    }
    this.completed.splice(index, 1);
    if (this.completed.length === 0) {
      this.selectedIndex = -1;
    } else if (this.selectedIndex >= this.completed.length || this.selectedIndex > index) {
      this.selectedIndex = Math.max(0, this.selectedIndex - 1);
    }
    this.delegate?.multiSearchViewDidRemoveItemAtIndex?.(this, index);
  }

  /**
   * The component reports the text being typed.
   */
  textChanged(text: string): void {
    let next = text;
    if (this.maximumTextLength > 0 && next.length > this.maximumTextLength) {
      next = next.substring(0, this.maximumTextLength);
    }
    if (next === this.typedText) {
      return;
    }
    this.typedText = next;
    this.delegate?.multiSearchViewTextDidChange?.(this, next, this.completed.length);
  }
}

/**
 * Draws a `CYLMultiSearchView`: the items in a row that scrolls, the field of the search being typed, and the search
 * button at the trailing end.
 */
@ComponentV2
export struct CYLMultiSearchComponent {
  /**
   * The multi search view to draw.
   */
  @Require @Param multiSearchView: CYLMultiSearchView;

  private accent(): ResourceColor {
    return this.multiSearchView.indicatorColor ?? $r('sys.color.brand');
  }

  build() {
    Row({ space: 8 }) {
      Scroll() {
        Row({ space: 16 }) {
          ForEach(this.multiSearchView.completedSearchTexts, (text: string, index: number) => {
            Column({ space: 4 }) {
              Row({ space: 4 }) {
                Text(text)
                  .fontSize(this.multiSearchView.font)
                  .fontColor(this.multiSearchView.textColor ?? $r('sys.color.font_primary'))
                  .maxLines(1)
                if (index === this.multiSearchView.selectedIndex) {
                  SymbolGlyph(this.multiSearchView.removeImage)
                    .fontSize(18)
                    .fontColor([this.accent()])
                    .accessibilityText($r('app.string.cyl_multisearch_remove'))
                    .onClick(() => {
                      this.multiSearchView.removeItemAtIndex(index);
                    })
                }
              }
              Divider()
                .strokeWidth(2)
                .color(this.accent())
                .opacity(index === this.multiSearchView.selectedIndex ? 1 : 0)
            }
            .opacity(index === this.multiSearchView.selectedIndex ? 1 : this.multiSearchView.unselectedItemAlpha)
            .onClick(() => {
              this.multiSearchView.selectItemAtIndex(index);
            })
          }, (text: string, index: number) => `${index}-${text}`)
          if (this.multiSearchView.isInSearchMode) {
            TextInput({ text: this.multiSearchView.typedText, placeholder: this.multiSearchView.placeholder })
              .id(this.multiSearchView.textFieldId)
              .width(this.multiSearchView.searchFieldWidth)
              .height(36)
              .padding(0)
              .backgroundColor(Color.Transparent)
              .borderRadius(0)
              .fontSize(this.multiSearchView.font)
              .fontColor(this.multiSearchView.textColor ?? $r('sys.color.font_primary'))
              .placeholderColor(this.multiSearchView.placeholderColor ?? $r('sys.color.font_tertiary'))
              .type(this.multiSearchView.keyboardType)
              .enterKeyType(this.multiSearchView.returnKeyType)
              .maxLength(this.multiSearchView.maximumTextLength > 0 ? this.multiSearchView.maximumTextLength : 100000)
              .onChange((value: string) => {
                this.multiSearchView.textChanged(value);
              })
              .onSubmit(() => {
                this.multiSearchView.completeSearch();
              })
          }
        }
        .padding({ left: 16, right: 8 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .align(Alignment.Start)

      Row() {
        SymbolGlyph(this.multiSearchView.searchImage)
          .fontSize(22)
          .fontColor([this.accent()])
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .accessibilityGroup(true)
      .accessibilityText($r('app.string.cyl_multisearch_add'))
      .onClick(() => {
        if (this.multiSearchView.isInSearchMode) {
          this.multiSearchView.completeSearch();
        } else {
          this.multiSearchView.search();
        }
      })
    }
    .width('100%')
    .height(this.multiSearchView.intrinsicContentSize)
  }
}
