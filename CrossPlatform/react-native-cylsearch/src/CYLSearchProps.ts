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
export function cylSearchBarItemsJSON(items: readonly CYLSearchBarItem[]): string {
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
