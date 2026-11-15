# cyl-search-miniprogram

CYLSearchViewController for WeChat Mini Programs: the search bar with appended items, the search page with a suggestion
cache, the overlay, several searches side by side and the placeholders, with the iOS names.

## Components

| Component | iOS | What it draws |
| :--- | :--- | :--- |
| `cyl-search-bar` | `CYLSearchBarView` | The navigation button (`navigationIcon` arrow or search), the field (magnifier, text, clear, voice or submit button, slot `trailing`, appended `items`), Cancel; iconified with a fade or circular reveal (`iconified`, `iconifiedByDefault`, `iconPosition`, `expansionAnimation`); `editable="{{false}}"` turns it into a button (`tapwhilenoteditable`). Slots `leading` and `trailing`. |
| `cyl-search-bar-item` | `CYLSearchBarItemView` | One appended item (icon, divider, text), its badge. |
| `cyl-search` | `CYLSearchView` | The search page (`show()`, `close()`, `setQuery()`): back arrow, cached queries, suggestions as a list or as tags folded inline (the chevron after the last visible tag), placeholders, colors, voice button, `closesOnSubmit`, slot `content` (iOS `contentView`), slot `placeholder-footer`, `coversNavigationBar`. |
| `cyl-search-controller` | `CYLSearchController` | The animated overlay (Cancel, pinned field, results); the page answers `querychange` with `results`. |
| `cyl-multi-search` | `CYLMultiSearchView` | Several searches side by side, the selected one underlined, with its remove button. |
| `cyl-search-placeholder` | `CYLSearchPlaceholderView` | An image above a message: `kind`, or one of the 41 `placeholderStyle` images (from the iOS bundle) with a `message` or your `text`, or your own `image`. |

Logic without views, tested with Node (`yarn test` / `node --test test/*.test.js`, 26 tests): `CYLSearchSuggestionStore`
(policies none, database, userDefaults, sandboxFile; storage is `wx.getStorageSync`), `CYLSearchBarItem` /
`CYLSearchBarItems`, `CYLSearchViewModel`, the playback strategy, the inline tag fold, the navigation bar metrics, and
the example's texts and Discover rules.

Core: `src/core/` has a counterpart for every public iOS API (397/397, `docs/miniprogram-api-alignment.md` in the
repository), ported from the HarmonyOS models: `require('cyl-search-miniprogram/src/core')`.

## Example: a 1:1 copy of the iOS example

`node scripts/sync-example.js` copies `src/` into `example/miniprogram/components/` and installs CYLTabBarController's
mini program tab bar and Lottie player (at the commit in `package.json` `cylTabBarControllerCommit`) into
`example/miniprogram/miniprogram_npm/`. Then open `example/` in WeChat DevTools. AppID: `project.config.json` keeps
`touristappid`, which DevTools refuses to run and automate; put your own AppID in `example/project.private.config.json`
(git-ignored; it overrides `project.config.json`): `{ "appid": "wx…" }`.

The pages are those of `CYLSearchExample`, with its texts (en, ja, zh-Hans, zh-Hant), data and images, imported from the
iOS bundles by `node scripts/import-ios-resources.js`:

- Tabs, from `CYLTabBarConfiguration.json`: Search (the Issue #1317 reproduction: Overlay, Repro, pull to refresh, the
  "No matching results" placeholder), Examples, the raised plus button's Search bar page, Tag style (MaterialSearchView's
  six samples as tags) and Discover (CollectionViewClassifyMenu's search page).
- Examples: Search and refresh, Placeholder styles (41 styles × 4 messages, then the custom ones), Search bar, Other
  libraries' examples (lapism/search, MaterialSearchView with its six samples, yechaoa SearchView, android-cjj circular
  reveal, iammert MultiSearchView).

`scripts/devtools-screenshots.js` drives every page with miniprogram-automator. Animated placeholders: the
MaterialSearchView samples play CYLTableViewPlaceHolder's Lottie animations through `cyl-search`'s abstract node
`cyl-animation-view` (`generic:cyl-animation-view="cyl-lottie"`), with "Play all", a speed slider and a loop switch in
the slot `placeholder-footer` (`animationSpeed` 0.25 to 3, `animationLoops`, `playAnimationFromStart()`).
