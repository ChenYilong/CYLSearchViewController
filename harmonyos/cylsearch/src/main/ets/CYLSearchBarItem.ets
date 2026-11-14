/**
 * How an item appended to a search bar looks (iOS `CYLSearchBarItemStyle`).
 */
export enum CYLSearchBarItemStyle {
  /**
   * An icon button with a 36 vp touch area (a camera, a filter).
   */
  icon = 0,
  /**
   * A thin vertical line between two items; it takes no taps and screen readers skip it.
   */
  divider = 1,
  /**
   * A text button (a "Search" button); an image, when set, comes before the title.
   */
  text = 2
}

/**
 * The fixed look of the whole bar (iOS `CYLSearchBarStyle`): the field stays, the items are appended after its text.
 */
export enum CYLSearchBarStyle {
  /**
   * The field as configured by its own properties (the default; nothing is changed).
   */
  plain = 0,
  /**
   * A capsule with a 1 vp outline: the field and its items inside one outline.
   */
  bordered = 1
}

/**
 * The item states for text attributes (iOS `UIControlState`).
 */
export enum CYLSearchBarItemState {
  /**
   * Enabled and not selected.
   */
  normal = 0,
  /**
   * Selected (`isSelected`).
   */
  selected = 1,
  /**
   * Disabled (`isEnabled` false).
   */
  disabled = 2
}

/**
 * Title or badge text attributes (iOS `NSAttributedString` attributes).
 */
export class CYLSearchBarItemTextAttributes {
  /**
   * The text color.
   */
  color?: ResourceColor;
  /**
   * The font size in fp.
   */
  size?: number;
  /**
   * The font weight.
   */
  weight?: FontWeight;
}

/**
 * What an item needs from its bar: the item list (for `index`) and the shared tint.
 */
export interface CYLSearchBarItemOwner {
  /**
   * The appended items, in order.
   */
  items: CYLSearchBarItem[];
  /**
   * The icon and title color of every item without its own `tintColor`.
   */
  itemTintColor: ResourceColor | undefined;
}

/**
 * One element after the text of a `CYLSearchBarView`: a model independent of its view (iOS `CYLSearchBarItem`, like
 * `CYLFlatDesignTabBarItem`). Append it with `CYLSearchBarView.addItem`; `CYLSearchBarItemView` draws it.
 */
@ObservedV2
export class CYLSearchBarItem {
  /**
   * How the item looks (icon, divider or text); set when the item is created.
   */
  readonly style: CYLSearchBarItemStyle;
  /**
   * The text of a text item, and the screen reader label of an icon item without `itemAccessibilityLabel`.
   */
  @Trace title: string | undefined = undefined;
  /**
   * The icon: a system symbol (`$r('sys.symbol.camera')`), tinted with `tintColor`.
   */
  @Trace image: Resource | undefined = undefined;
  /**
   * The icon while `isSelected` is true; undefined uses `image`.
   */
  @Trace selectedImage: Resource | undefined = undefined;
  /**
   * An animated icon (a GIF or animated WebP as an image source), drawn instead of `image` when set.
   */
  @Trace animatedImage: ResourceStr | undefined = undefined;
  /**
   * The icon side in vp; 0 uses 20.
   */
  @Trace imageSize: number = 0;
  /**
   * What screen readers read; undefined reads `title`.
   */
  @Trace itemAccessibilityLabel: string | undefined = undefined;
  /**
   * A test identifier for the item view (its component id).
   */
  @Trace itemAccessibilityIdentifier: string | undefined = undefined;
  /**
   * False dims the item and ignores taps. True by default.
   */
  @Trace isEnabled: boolean = true;
  /**
   * True makes each tap toggle `isSelected` (a filter that stays on). False by default.
   */
  isSelectable: boolean = false;
  /**
   * The selected state (drawn with `selectedImage`, `selectedBackgroundColor` and the selected title attributes).
   */
  @Trace isSelected: boolean = false;
  /**
   * The icon and title color; undefined uses the bar's `itemTintColor`.
   */
  @Trace tintColor: ResourceColor | undefined = undefined;
  /**
   * The item background; undefined is transparent.
   */
  @Trace backgroundColor: ResourceColor | undefined = undefined;
  /**
   * The item background while selected; undefined uses `backgroundColor`.
   */
  @Trace selectedBackgroundColor: ResourceColor | undefined = undefined;
  /**
   * Horizontal padding around the icon and title, in vp; negative uses the style's default (4 for text, 0 else).
   */
  @Trace contentInsets: number = -1;
  /**
   * Moves the icon, in vp, without changing the item's size.
   */
  @Trace imagePositionAdjustment: Position = { x: 0, y: 0 };
  /**
   * Moves the title, in vp, without changing the item's size.
   */
  @Trace titlePositionAdjustment: Position = { x: 0, y: 0 };
  /**
   * The badge text; undefined hides the badge, an empty string draws a dot.
   */
  @Trace badgeValue: string | undefined = undefined;
  /**
   * The badge background; undefined is red.
   */
  @Trace badgeColor: ResourceColor | undefined = undefined;
  /**
   * The smallest badge side in vp; 0 uses 16 (a dot is 8).
   */
  @Trace badgeSize: number = 0;
  /**
   * Horizontal padding around the badge text, in vp.
   */
  @Trace badgeContentInsets: number = 4;
  /**
   * Moves the badge from the icon's top end corner, in vp.
   */
  @Trace badgePositionAdjustment: Position = { x: 0, y: 0 };
  /**
   * Called on each tap, after `CYLSearchBarViewDelegate.searchBarViewDidSelectItem`.
   */
  handler: ((item: CYLSearchBarItem) => void) | undefined = undefined;
  /**
   * The bar the item was appended to; undefined before `addItem` and after `removeItem`.
   */
  searchBarView: CYLSearchBarItemOwner | undefined = undefined;

  @Trace private attributesVersion: number = 0;
  private titleAttributes: Map<CYLSearchBarItemState, CYLSearchBarItemTextAttributes> = new Map();
  private badgeAttributes: Map<CYLSearchBarItemState, CYLSearchBarItemTextAttributes> = new Map();

  /**
   * An item of the given style with a title and an icon (iOS `-initWithStyle:title:image:`).
   */
  constructor(style: CYLSearchBarItemStyle, title?: string, image?: Resource) {
    this.style = style;
    this.title = title;
    this.image = image;
  }

  /**
   * The item's position in its bar's `items`; -1 when it is in no bar.
   */
  get index(): number {
    return this.searchBarView === undefined ? -1 : this.searchBarView.items.indexOf(this);
  }

  /**
   * The state the item is drawn in.
   */
  get currentState(): CYLSearchBarItemState {
    if (!this.isEnabled) {
      return CYLSearchBarItemState.disabled;
    }
    return this.isSelected ? CYLSearchBarItemState.selected : CYLSearchBarItemState.normal;
  }

  /**
   * An icon item: the title is what screen readers read (iOS `+iconItemWithImage:title:handler:`).
   */
  static iconItem(image: Resource | undefined, title: string | undefined,
    handler?: (item: CYLSearchBarItem) => void): CYLSearchBarItem {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.icon, title, image);
    item.handler = handler;
    return item;
  }

  /**
   * A text item, a "Search" button (iOS `+textItemWithTitle:handler:`).
   */
  static textItem(title: string, handler?: (item: CYLSearchBarItem) => void): CYLSearchBarItem {
    const item = new CYLSearchBarItem(CYLSearchBarItemStyle.text, title);
    item.handler = handler;
    return item;
  }

  /**
   * A divider between two items (iOS `+dividerItem`).
   */
  static divider(): CYLSearchBarItem {
    return new CYLSearchBarItem(CYLSearchBarItemStyle.divider);
  }

  /**
   * An item from plain values, as the cross-platform wrappers send them (iOS `+itemWithDictionary:`): `style`
   * (`icon`, `divider`, `text`), `title`, `image` (`camera`, `mic`, `search`, `back`), `accessibilityIdentifier`,
   * `isEnabled`, `isSelectable`, `isSelected`, `badgeValue`.
   */
  static item(dictionary: Record<string, Object>): CYLSearchBarItem {
    const styleName = dictionary['style'] as string | undefined;
    let style = CYLSearchBarItemStyle.icon;
    if (styleName === 'divider') {
      style = CYLSearchBarItemStyle.divider;
    } else if (styleName === 'text') {
      style = CYLSearchBarItemStyle.text;
    }
    const item = new CYLSearchBarItem(style, dictionary['title'] as string | undefined,
      CYLSearchBarItem.namedImage(dictionary['image'] as string | undefined));
    item.itemAccessibilityIdentifier = dictionary['accessibilityIdentifier'] as string | undefined;
    item.isEnabled = (dictionary['isEnabled'] as boolean | undefined) ?? true;
    item.isSelectable = (dictionary['isSelectable'] as boolean | undefined) ?? false;
    item.isSelected = (dictionary['isSelected'] as boolean | undefined) ?? false;
    item.badgeValue = dictionary['badgeValue'] as string | undefined;
    if (style === CYLSearchBarItemStyle.icon) {
      item.imageSize = 22;
    }
    return item;
  }

  private static namedImage(name: string | undefined): Resource | undefined {
    if (name === 'camera') {
      return $r('sys.symbol.camera');
    }
    if (name === 'mic') {
      return $r('sys.symbol.mic');
    }
    if (name === 'search') {
      return $r('sys.symbol.magnifyingglass');
    }
    if (name === 'back') {
      return $r('sys.symbol.chevron_backward');
    }
    return undefined;
  }

  /**
   * The title attributes for a state (iOS `-setTitleTextAttributes:forState:`).
   */
  setTitleTextAttributes(attributes: CYLSearchBarItemTextAttributes | undefined, state: CYLSearchBarItemState): void {
    if (attributes === undefined) {
      this.titleAttributes.delete(state);
    } else {
      this.titleAttributes.set(state, attributes);
    }
    this.attributesVersion += 1;
  }

  /**
   * The title attributes set for a state, or undefined (iOS `-titleTextAttributesForState:`).
   */
  titleTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes | undefined {
    return this.attributesVersion >= 0 ? this.titleAttributes.get(state) : undefined;
  }

  /**
   * The badge text attributes for a state (iOS `-setBadgeTextAttributes:forState:`).
   */
  setBadgeTextAttributes(attributes: CYLSearchBarItemTextAttributes | undefined, state: CYLSearchBarItemState): void {
    if (attributes === undefined) {
      this.badgeAttributes.delete(state);
    } else {
      this.badgeAttributes.set(state, attributes);
    }
    this.attributesVersion += 1;
  }

  /**
   * The badge text attributes set for a state, or undefined (iOS `-badgeTextAttributesForState:`).
   */
  badgeTextAttributes(state: CYLSearchBarItemState): CYLSearchBarItemTextAttributes | undefined {
    return this.attributesVersion >= 0 ? this.badgeAttributes.get(state) : undefined;
  }
}

/**
 * The view of a `CYLSearchBarItem` (iOS `CYLSearchBarItemView`, like `CYLFlatDesignTabBarButton`).
 */
@ComponentV2
export struct CYLSearchBarItemView {
  /**
   * The item this view draws.
   */
  @Require @Param item: CYLSearchBarItem;
  /**
   * The bar's tint, for an item without its own.
   */
  @Param itemTintColor: ResourceColor | undefined = undefined;
  /**
   * The item was tapped (the bar toggles a selectable item, then tells its delegate and the item's handler).
   */
  @Event onSelect: (item: CYLSearchBarItem) => void = () => {
  };

  private tint(): ResourceColor {
    return this.item.tintColor ?? this.itemTintColor ?? $r('sys.color.font_primary');
  }

  private side(): number {
    return this.item.imageSize > 0 ? this.item.imageSize : 20;
  }

  private currentImage(): Resource | undefined {
    return this.item.isSelected ? (this.item.selectedImage ?? this.item.image) : this.item.image;
  }

  private titleAttributes(): CYLSearchBarItemTextAttributes | undefined {
    return this.item.titleTextAttributes(this.item.currentState) ??
    this.item.titleTextAttributes(CYLSearchBarItemState.normal);
  }

  private badgeAttributes(): CYLSearchBarItemTextAttributes | undefined {
    return this.item.badgeTextAttributes(this.item.currentState) ??
    this.item.badgeTextAttributes(CYLSearchBarItemState.normal);
  }

  private itemBackground(): ResourceColor {
    const color = this.item.isSelected ? (this.item.selectedBackgroundColor ?? this.item.backgroundColor) :
    this.item.backgroundColor;
    return color ?? Color.Transparent;
  }

  private insets(): number {
    if (this.item.contentInsets >= 0) {
      return this.item.contentInsets;
    }
    return this.item.style === CYLSearchBarItemStyle.text ? 4 : 0;
  }

  build() {
    if (this.item.style === CYLSearchBarItemStyle.divider) {
      Divider()
        .vertical(true)
        .height(18)
        .strokeWidth(1)
        .color($r('sys.color.comp_divider'))
        .accessibilityLevel('no')
    } else {
      Stack({ alignContent: Alignment.TopEnd }) {
        Row({ space: 4 }) {
          if (this.item.animatedImage !== undefined) {
            Image(this.item.animatedImage)
              .width(this.side())
              .height(this.side())
              .objectFit(ImageFit.Contain)
              .offset(this.item.imagePositionAdjustment)
          } else if (this.currentImage() !== undefined) {
            SymbolGlyph(this.currentImage())
              .fontSize(this.side())
              .fontColor([this.tint()])
              .offset(this.item.imagePositionAdjustment)
          }
          if (this.item.style === CYLSearchBarItemStyle.text && this.item.title !== undefined) {
            Text(this.item.title)
              .fontSize(this.titleAttributes()?.size ?? 17)
              .fontWeight(this.titleAttributes()?.weight ?? FontWeight.Bold)
              .fontColor(this.titleAttributes()?.color ?? this.tint())
              .maxLines(1)
              .offset(this.item.titlePositionAdjustment)
          }
        }
        .justifyContent(FlexAlign.Center)
        .constraintSize({ minWidth: 36, minHeight: 36 })
        .padding({ left: this.insets(), right: this.insets() })

        if (this.item.badgeValue !== undefined) {
          Text(this.item.badgeValue)
            .fontSize(this.badgeAttributes()?.size ?? 11)
            .fontWeight(this.badgeAttributes()?.weight ?? FontWeight.Medium)
            .fontColor(this.badgeAttributes()?.color ?? Color.White)
            .textAlign(TextAlign.Center)
            .constraintSize({
              minWidth: this.item.badgeValue.length === 0 ? 8 : (this.item.badgeSize > 0 ? this.item.badgeSize : 16),
              minHeight: this.item.badgeValue.length === 0 ? 8 : (this.item.badgeSize > 0 ? this.item.badgeSize : 16)
            })
            .padding({
              left: this.item.badgeValue.length === 0 ? 0 : this.item.badgeContentInsets,
              right: this.item.badgeValue.length === 0 ? 0 : this.item.badgeContentInsets
            })
            .backgroundColor(this.item.badgeColor ?? Color.Red)
            .borderRadius(8)
            .offset(this.item.badgePositionAdjustment)
            .accessibilityLevel('no')
        }
      }
      .backgroundColor(this.itemBackground())
      .borderRadius(10)
      .opacity(this.item.isEnabled ? 1 : 0.4)
      .enabled(this.item.isEnabled)
      .id(this.item.itemAccessibilityIdentifier ?? '')
      .accessibilityGroup(true)
      .accessibilityText(this.item.itemAccessibilityLabel ?? this.item.title ?? '')
      .onClick(() => {
        this.onSelect(this.item);
      })
    }
  }
}
