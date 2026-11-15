/*
 * Pure logic of the search core: no ArkUI, no kit import, so it also runs on the host with Node
 * (`harmonyos/scripts/host-logic-test.mjs`) without an emulator. Each function follows the Android Kotlin source
 * named in its comment.
 */

/**
 * The text with its accents removed, lowercased, so "cafe" matches "café" (Android `CYLSearchView.fold`).
 */
export function cylFoldSearchText(text: string): string {
  return text.normalize('NFD').replace(new RegExp('[̀-ͯ]+', 'g'), '').toLowerCase();
}

/**
 * Whether `suggestion` matches `query`: the trimmed, folded query is part of the folded suggestion (Android
 * `CYLSearchView.matches` without a custom filter).
 */
export function cylSuggestionMatches(suggestion: string, query: string): boolean {
  return cylFoldSearchText(suggestion).includes(cylFoldSearchText(query.trim()));
}

/**
 * The suggestions to show and whether they are the cached queries (Android `CYLSearchView.refilter`).
 */
export interface CYLSearchFilterResult {
  /**
   * The suggestions to show, in order.
   */
  suggestions: string[];
  /**
   * True when the list is the cached queries (an empty query with a cache), so the cache header is shown.
   */
  showsCachedQueries: boolean;
}

/**
 * Filters the suggestions for `query` (Android `CYLSearchView.refilter`): an empty or blank query shows the cached
 * queries, or every suggestion with `showsAllForEmptyQuery`, or nothing; any other query shows the matching cached
 * queries first, then the matching suggestions not already listed. `matches` replaces the default match.
 */
export function cylFilterSuggestions(query: string, cached: string[], all: string[], showsAllForEmptyQuery: boolean,
  matches?: (suggestion: string, query: string) => boolean): CYLSearchFilterResult {
  const match = matches ?? cylSuggestionMatches;
  if (query.trim().length === 0) {
    if (cached.length > 0) {
      return { suggestions: cached.slice(), showsCachedQueries: true };
    }
    return { suggestions: showsAllForEmptyQuery ? all.slice() : [], showsCachedQueries: false };
  }
  const result: string[] = [];
  cached.forEach((value: string) => {
    if (match(value, query)) {
      result.push(value);
    }
  });
  all.forEach((value: string) => {
    if (match(value, query) && !result.includes(value)) {
      result.push(value);
    }
  });
  return { suggestions: result, showsCachedQueries: false };
}

/**
 * The cached queries after adding `query`: trimmed, moved to the front, at most `maximumCount` kept and at least one
 * (Android `CYLSearchSuggestionStore.addQuery`); unchanged for a blank query.
 */
export function cylQueriesAdding(queries: string[], query: string, maximumCount: number): string[] {
  const text = query.trim();
  if (text.length === 0) {
    return queries.slice();
  }
  const result = queries.filter((value: string) => value !== text);
  result.unshift(text);
  return result.slice(0, Math.max(1, maximumCount));
}

/**
 * How many of the tags (`widths`, in vp) fit in `rows` rows of `width` with `spacing` between them, when a fold
 * control of `controlWidth` must follow the last visible tag (0 for no control in the flow); all of them when they
 * fit together without the control. Rows of 0 or less, or no width yet, show every tag (CollectionViewClassifyMenu
 * `CYLTagListView` folding).
 */
export function cylFoldedTagCount(widths: number[], width: number, rows: number, spacing: number,
  controlWidth: number): number {
  if (rows <= 0 || width <= 0) {
    return widths.length;
  }
  const fits = (count: number, extra: number): boolean => {
    let row = 1;
    let x = 0;
    const items = widths.slice(0, count).map((w: number) => Math.min(w, width));
    if (extra > 0) {
      items.push(Math.min(extra, width));
    }
    for (const w of items) {
      if (x > 0 && x + spacing + w > width) {
        row++;
        x = w;
      } else {
        x = x > 0 ? x + spacing + w : w;
      }
      if (row > rows) {
        return false;
      }
    }
    return true;
  };
  if (fits(widths.length, 0)) {
    return widths.length;
  }
  for (let count = widths.length - 1; count >= 0; count--) {
    if (fits(count, controlWidth)) {
      return count;
    }
  }
  return 0;
}
