# cyl-search-miniprogram

CYLSearchViewController for WeChat Mini Programs: the search bar with appended items, the search page with a suggestion
cache, and the rules behind them, with the iOS names.

- `cyl-search-bar`: the field, then the appended `items` (icon, divider, text; a plain-values list, see
  `CYLSearchBarItem.item`) inside one outline with `searchBarStyle="bordered"`. Events: `textchange`, `submit`,
  `focuschange`, `cancel`, `itemselect`.
- `cyl-search`: the page (`show()` / `close()`): the cached queries first, then the suggestions as a list or tags with
  a fold control; placeholders for an empty cache and empty results; `focusesSearchFieldOnShow` (default on).
- Logic without views, tested with Node (`yarn test` / `node --test test/*.test.js`): `CYLSearchSuggestionStore` (policies
  none, database, userDefaults, sandboxFile; storage is `wx.getStorageSync`), `CYLSearchBarItem` / `CYLSearchBarItems`,
  `CYLSearchViewModel`.

Status: the logic is covered by 8 Node tests. The components were written against the Mini Program component API and
have not been run in WeChat DevTools (not available here): treat their rendering as unverified. Animations of the
placeholders (Lottie) are not included.
