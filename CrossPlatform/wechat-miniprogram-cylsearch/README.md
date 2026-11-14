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

Status (2026-11-15): the logic is covered by 8 Node tests, and the example runs in WeChat DevTools (base library
3.6.6): the bordered bar with its items, the search page with the empty-cache placeholder and the keyboard down, and
the `submit` event (screenshot: `docs/assets/miniprogram-search-devtools.png` in the repository). Not yet: a search
icon image in the field, and the placeholders' Lottie animations.
