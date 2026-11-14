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

Core: `src/core/` has a counterpart for every public iOS API (397/397, `docs/miniprogram-api-alignment.md` in the
repository), ported from the HarmonyOS models: `require('cyl-search-miniprogram/src/core')`. Components:
`cyl-search-bar` (slots `leading` and `trailing`), `cyl-search-bar-item`, `cyl-search`.

Example: `node scripts/sync-example.js` copies `src/` into `example/miniprogram/components/` and installs
CYLTabBarController's mini program tab bar (`cyl-tabbar-miniprogram`, at the commit in `package.json`
`cylTabBarControllerCommit`) into `example/miniprogram/miniprogram_npm/`. Then open `example/` in WeChat DevTools. Five
tabs (Search, Examples, List style, Tag style, Discover) and a raised plus button that opens the search bar samples.
`scripts/devtools-screenshots.js` drives every tab with miniprogram-automator.

Status (2026-11-15): Node tests 14/14; the example runs in WeChat DevTools (base library 3.6.6) with no console
errors (screenshot: `docs/assets/miniprogram-example-tabbar-devtools.png` in the repository).

Animated placeholders: `cyl-search` plays `emptySuggestionsAnimation` / `emptyResultsAnimation` (Lottie JSON paths)
above the text through its abstract node `cyl-animation-view`; pass `generic:cyl-animation-view="cyl-lottie"` with
`cyl-lottie-miniprogram` installed (the example does, with CYLTableViewPlaceHolder's animations and their licenses in
`example/miniprogram/assets/placeholder/`). Without the node, only the text shows and no player is shipped.

Playback: `animationSpeed` (0.25 to 3) and `animationLoops` apply live; `playAnimationFromStart()` restarts the
animation from progress 0. Put controls in the slot `placeholder-footer` (under the placeholder); the List style and
Tag style pages of the example offer "Play all", a speed slider and a loop switch. Node tests 17/17.
