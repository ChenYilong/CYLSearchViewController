# cyl-search-miniprogram

CYLSearchViewController for WeChat Mini Program: the search bar with appended items, the search page with a suggestion
cache, the search overlay, several searches side by side and the placeholder views, with the iOS API names. The
JavaScript core has a counterpart of every public iOS API (397/397, `docs/miniprogram-api-alignment.md` in the
repository). Texts in English, Japanese, Simplified Chinese and Traditional Chinese.

## Install

With npm: `npm i cyl-search-miniprogram` in your mini program's folder, then DevTools > Tools > Build npm
(构建 npm). The components are then `cyl-search-miniprogram/<component>/index`:

```json
{
  "usingComponents": {
    "cyl-search-bar": "cyl-search-miniprogram/cyl-search-bar/index",
    "cyl-search": "cyl-search-miniprogram/cyl-search/index"
  }
}
```

Without npm: copy `src/` into your mini program (for example as `components/`) and use
`/components/cyl-search-bar/index`. The components refer to each other by relative paths, so the folder can live
anywhere.

The JavaScript API: `require('cyl-search-miniprogram')` (or `require('/components/cyl_search')` in a copy) has the core
classes (`CYLSearchBarView`, `CYLSearchView`, `CYLMultiSearchView`, `CYLSearchController`, `CYLSearchPlaceholderView`,
`CYLSearchSuggestionStore`, `CYLSearchBarItem`…) and the helpers (`CYLSearchViewModel`, `CYLSearchBarItems`,
`cylFoldTags`, `cylNavigationMetrics`, `cylClampAnimationSpeed`, `cylFormatString`).

## Usage

```html
<cyl-search-bar placeholder="Search" searchBarStyle="bordered" items="{{items}}"
  bind:focuschange="openSearch" bind:itemselect="onItem" />
<cyl-search id="search" suggestions="{{suggestions}}" suggestionStyle="tags" showsEmptyResultsPlaceholder
  cacheName="MySearch" bind:submit="onSubmit" />
```

```js
Page({
  data: {
    suggestions: ['Swift', 'Kotlin', 'Dart'],
    items: [{ style: 'icon', title: 'Camera', image: '/images/camera.svg' }, { style: 'divider' }, { style: 'text', title: 'Search' }],
  },
  openSearch() { this.selectComponent('#search').show(); },
  onSubmit(e) { console.log('query', e.detail.text); },
});
```

### `cyl-search-bar` (iOS `CYLSearchBarView`)

| Property | Default | Meaning |
| --- | --- | --- |
| `value`, `placeholder`, `focus` | `''`, `''`, `false` | The text, the placeholder, editing |
| `searchBarStyle` | `plain` | `bordered`: the field and its items in one outline |
| `items` | `[]` | Appended items, plain values (`style` icon / divider / text, `title`, `image`, `badgeValue`, `isSelectable`…) |
| `navigationIcon` | `none` | `arrow` (back) or `search`: a button before the field |
| `showsCancelButton`, `showsVoiceButton`, `showsSubmitButton`, `showsClearButton`, `showsSearchIcon` | | The buttons |
| `fieldHeight`, `fieldCornerRadius`, `fieldBackgroundColor`, `fieldBorderColor`, `fieldBorderWidth`, `fieldShadowOpacity`, `contentInsets`, `fontSize`, `textColor`, `placeholderColor`, `cursorColor`, `searchIconTintColor` | 36, -1 (capsule)… | The look |
| `secure`, `maximumTextLength`, `returnKeyType` | `false`, 0, `search` | The keyboard |
| `editable` | `true` | `false` turns the bar into a button (`tapwhilenoteditable`) |
| `iconified`, `iconifiedByDefault`, `iconPosition`, `expansionAnimation`, `animationDuration` | `false`, `false`, `trailing`, `fade`, 0.3 | Only a search button; it opens with a fade or a circular reveal |

Events: `textchange`, `submit`, `focuschange`, `cancel`, `itemselect`, `navigationtap`, `voicetap`,
`tapwhilenoteditable`, `iconifiedchange`. Methods: `setText(text, submit)`, `setIconified(iconified)`, `showKeyboard()`,
`hideKeyboard()`. Slots: `leading`, `trailing`.

### `cyl-search` (iOS `CYLSearchView`)

| Property | Default | Meaning |
| --- | --- | --- |
| `suggestions`, `suggestionStyle` | `[]`, `list` | The suggestions, as a list or as `tags` folded inline to `foldedRowCount` rows |
| `cacheName`, `focusesSearchFieldOnShow`, `closesOnSubmit` | `CYLSearchView`, `true`, `true` | Submitted queries are cached and listed first |
| `showsEmptyResultsPlaceholder`, `emptyResultsScenario`, `emptySuggestionsScenario` | `false`, `NoSearchResults`, `NoContent` | The empty placeholders: CYLTableViewPlaceHolder scenario names, drawn by the abstract node `cyl-empty-view` (default `cyl-search-empty-view`, CYLSearchPlaceholderView; pass a view that renders cyl-placeholder-miniprogram's `<cyl-placeholder scenario>` for CYLTableViewPlaceHolder's own) |
| `emptyPlaceholderAnimated`, `animationSpeed`, `animationLoops` | `false`, 1, `true` | Ask `cyl-empty-view` to play the scenario's animation (static on iOS) |
| `navigationIcon`, `showsCancelButton`, `showsVoiceButton`, `showsSearchIcon`, `secure`, `cursorColor` | `arrow`… | The bar |
| `backgroundColor`, `textColor`, `placeholderColor`, `navigationColor`, `suggestionTextColor`, `suggestionImageTintColor`, `dividerColor`, `suggestionLineBreak` | | The look |
| `showsContent` | `false` | Your own view (slot `content`) in place of the suggestions |
| `coversNavigationBar` | `false` | On a `"navigationStyle": "custom"` page, the bar takes the navigation bar's place, clear of WeChat's menu button |

Events: `submit`, `close`, `textchange`, `suggestionselect`, `focuschange`, `voicetap`, `itemselect`. Methods: `show()`,
`close()`, `setQuery(text, submit)`, `playAnimationFromStart()`. Slots: `content`, `placeholder-footer`. Abstract node:
`cyl-empty-view` (properties `scenario`, `animated`, `loop`, `speed`; method `playAll()`).

### Other components

| Component | iOS | Use |
| --- | --- | --- |
| `cyl-search-controller` | `CYLSearchController` | `show()` / `hide()`; answer `querychange` `{ text }` by setting `results`; events `select`, `cancel` |
| `cyl-multi-search` | `CYLMultiSearchView` | Events `textchange`, `complete`, `remove`, `select` (`{ text, index }`); methods `search()`, `completeSearch()`, `addSearchText()`, `selectItem()`, `removeItem()` |
| `cyl-search-placeholder` | `CYLSearchPlaceholderView` | `kind` (`empty`, `noResults`, `error`); or `placeholderStyle` (one of 41 styles) with `message` (`empty`, `noResults`, `error`, `network`) or `text`; or your own `image` (`tintsImage`, `imageTintColor`) |
| `cyl-search-bar-item` | `CYLSearchBarItemView` | One item of `cyl-search-bar` (used by it) |

## Example

Open this folder (`CrossPlatform/wechat-miniprogram-cylsearch`) in WeChat DevTools. `project.config.json` points
`miniprogramRoot` at `example/miniprogram/` and its `beforeCompile` / `beforePreview` / `beforeUpload` hooks run
`node scripts/sync-example.js`, which copies `src/` into the example (a mini program cannot load files outside its
root) and installs CYLTabBarController's tab bar and Lottie player at the commit pinned in `package.json`
(`cylTabBarControllerCommit`; `CYL_TABBAR_DIR` uses a local checkout), and CYLTableViewPlaceHolder's `cyl-placeholder`
and `cyl-refresh` (`cylTableViewPlaceHolderCommit`; `CYL_PLACEHOLDER_DIR`), the sub-repositories the iOS example uses
through CocoaPods. DevTools asks once whether to run the project's
custom commands; run `npm run sync-example` yourself if the hooks are off. DevTools refuses the committed
`touristappid`: put your own AppID in `project.private.config.json` (git-ignored), for example `{ "appid": "wx…" }`.

The example is a 1:1 copy of the iOS example (`CYLSearchExample`): the Search tab (the Issue #1317 reproduction), the
Examples menu (Search and refresh, Placeholder styles, Search bar, the ports of lapism/search, MaterialSearchView,
yechaoa, android-cjj and iammert MultiSearchView), the plus button's Search bar page, the Tag style tab and the
Discover tab, with the iOS texts, data and images; the search pages show CYLTableViewPlaceHolder's NoContent and
NoSearchResults placeholders and the reproduction its CYLRefreshNormalHeader, as on iOS; dark mode follows the system.

## Development

- `npm test`: unit tests (`node --test`): the core, the components' logic, the package (entry, components, files,
  requires that name files, as a mini program needs), the example's texts and Discover rules.
- `npm run import-ios`: re-imports the placeholder images, the texts and the Discover data from the iOS bundles.
- `npm run sync-example`: prepares the example (the DevTools hooks run it).
- `scripts/devtools-screenshots.js`: drives every page of the example with miniprogram-automator.
- `npm pack`: the published files are `src/`, `README.md` and `LICENSE`.

## License

MIT, see `LICENSE`. The placeholder images in `src/images/placeholder` come unchanged from the iOS bundle and keep
their licenses (the Material Design icons are Apache 2.0, `LICENSE.material-design-icons`, listed in `NOTICE` and
`ICON-SOURCES`; `LICENSE.placeholder-third-party` covers the others). The example's sub-repositories are copied with
their own licenses (`scripts/sync-example.js`).
