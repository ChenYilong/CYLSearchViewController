/**
 * One field (`single`, the default) or several searches side by side (`multiple`): iOS and Android `CYLSearchBarMode`.
 */
export type CYLSearchBarMode = 'single' | 'multiple';

/**
 * One element after the text of a search bar (iOS and Android `CYLSearchBarItem`, like the FlatDesign tab bar's
 * items). The field stays; the bar only appends items.
 */
export type CYLSearchBarItem = {
  /**
   * "icon" (36-point touch area), "divider" (skipped by screen readers) or "text" (a "Search" button).
   */
  style: 'icon' | 'divider' | 'text';
  /**
   * The text of a text item, and the screen reader label of an icon item.
   */
  title?: string;
  /**
   * `camera`, `mic`, `search` or `back` (drawn by the core), else an app image (iOS asset or SF Symbol, Android drawable).
   */
  image?: string;
  /**
   * A test identifier of the item view.
   */
  accessibilityIdentifier?: string;
  /**
   * False dims the item and ignores taps.
   */
  isEnabled?: boolean;
  /**
   * Each tap toggles the selected state on the native side.
   */
  isSelectable?: boolean;
  /**
   * The selected state.
   */
  isSelected?: boolean;
  /**
   * The badge text; "" draws a dot.
   */
  badgeValue?: string;
  /**
   * Called on each tap with the selected state after the tap.
   */
  onPress?: (selected: boolean) => void;
};

/**
 * The items as the JSON the native bar reads (`CYLSearchBarItem itemWithDictionary:` / `fromMap`), without handlers.
 */
export function cylSearchBarItemsJSON(
  items: readonly CYLSearchBarItem[]
): string {
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  return JSON.stringify(items.map(({ onPress, ...values }) => values));
}

/**
 * The tapped item for a native `onItemSelect` event, after calling its own `onPress`; undefined for an unknown index.
 */
export function cylSearchBarSelectedItem(
  items: readonly CYLSearchBarItem[],
  index: number,
  selected: boolean
): CYLSearchBarItem | undefined {
  const item = items[index];
  item?.onPress?.(selected);
  return item;
}

/**
 * Whether the search page lists results: the explicit `showsResults`, else whether `results` is given.
 */
export function cylSearchViewShowsResults(
  showsResults: boolean | undefined,
  results: ReadonlyArray<string> | undefined
): boolean {
  return showsResults ?? results !== undefined;
}

/**
 * The suggestion style `CYLSearchView` sends to the core: `"tags"` (folded, the fold control as the last tag) unless
 * the app asks for `"list"`, as the core's default.
 */
export function cylSearchViewSuggestionStyle(
  style: string | undefined
): string {
  return style ?? 'tags';
}

/**
 * Margins in points (iOS) or dp (Android): `UIEdgeInsets` order.
 */
export type CYLEdgeInsets = {
  top?: number;
  left?: number;
  bottom?: number;
  right?: number;
};

/**
 * The margins as the native [top, left, bottom, right] array; undefined sends none.
 */
export function cylInsetsArray(insets: CYLEdgeInsets | undefined): number[] {
  return insets
    ? [insets.top ?? 0, insets.left ?? 0, insets.bottom ?? 0, insets.right ?? 0]
    : [];
}

/**
 * A view beside the field (`leadingAccessoryView` / `trailingAccessoryView`): a rounded square with a stroke, drawn by the core's
 * wrapper (QDSearchBarViewController's 30 x 30 accessory).
 */
export type CYLSearchBarAccessory = {
  kind: 'square';
  /** Width and height; 30 by default. */
  size?: number;
  /** "#RRGGBB" or "#AARRGGBB". */
  color?: string;
  /** The screen reader label. */
  label?: string;
};

/**
 * The accessory as the JSON the native bar reads; "" for none.
 */
export function cylAccessoryJSON(
  accessory: CYLSearchBarAccessory | undefined
): string {
  return accessory ? JSON.stringify({ size: 30, ...accessory }) : '';
}

/**
 * `CYLSearchBarAppearance`: the values that are set replace the default style's (colors "#RRGGBB" or "#AARRGGBB").
 */
export type CYLSearchBarAppearance = {
  textColor?: string;
  placeholderColor?: string;
  tintColor?: string;
  fieldBackgroundColor?: string;
  cancelTitle?: string;
  /** Negative makes a capsule. */
  fieldCornerRadius?: number;
  fontSize?: number;
};

/**
 * The appearance as the JSON the native bar reads; "" for none.
 */
export function cylAppearanceJSON(
  appearance: CYLSearchBarAppearance | undefined
): string {
  return appearance ? JSON.stringify(appearance) : '';
}

/**
 * The text split around the first match of `query` (case sensitive, as QMUI's `range(of:)`): the match is drawn in the tint
 * color. No match, or an empty query, leaves the whole text in `before`.
 */
export function cylSplitMatch(
  text: string,
  query: string
): { before: string; match: string; after: string } {
  const start = query.length > 0 ? text.indexOf(query) : -1;
  if (start < 0) return { before: text, match: '', after: '' };
  return {
    before: text.slice(0, start),
    match: query,
    after: text.slice(start + query.length),
  };
}

/**
 * The results of a text for a list that stands for `resultsQuery`: results of another text are not shown (a late answer never
 * fills the list of a newer text), as the native list does.
 */
export function cylResultsForQuery<T>(
  query: string,
  resultsQuery: string,
  results: readonly T[]
): readonly T[] {
  return query === resultsQuery ? results : [];
}
