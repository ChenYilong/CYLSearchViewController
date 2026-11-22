# cyl-search-miniprogram

CYLSearchViewController for WeChat Mini Program, with the iOS API names: two components and three core modules, as
the iOS core's `Sources/CYLSearchBar` (`CYLSearchBarView.swift`, `CYLSearchView.swift`, `CYLSearchResources.swift`):

| Component / module | iOS | What it is |
| --- | --- | --- |
| `<cyl-search-bar>`, `core/CYLSearchBarView.js` | `CYLSearchBarView`, `CYLSearchBarItem` | The search bar with appended items; with `mode="multiple"`, several searches side by side |
| `<cyl-search>`, `core/CYLSearchView.js` | `CYLSearchView` | The search view: suggestions and their cache, or the results of a data source, the empty placeholders, pull-to-refresh; over the page or `inline` |
| `core/CYLSearchResources.js` | `CYLSearchResources` | Images, strings, the suggestion cache (`CYLSearchSuggestionCache`, `CYLSearchSuggestionCachePolicy`) |

Texts in English, Japanese, Simplified Chinese and Traditional Chinese. The search core depends on no other search
library; its two sub-dependencies, neither a search library, are pinned by commit in `package.json`:
CYLTableViewPlaceHolder's mini program package, `cyl-placeholder-miniprogram` (placeholders and pull-to-refresh;
`cylTableViewPlaceHolderCommit`), and CollectionViewClassifyMenu's, `cyl-tag-list-miniprogram`, whose `cyl-tag-button`
(the one icon + title + animated icon component) draws every item of `cyl-search-bar`, with its badge and its
`animationURL` (`collectionViewClassifyMenuCommit`).

## Install

1. `npm i cyl-search-miniprogram` in your mini program's folder.
2. Install the sub-dependency at the pinned commit: the folders `src/cyl-placeholder` and `src/cyl-refresh` of
   `CrossPlatform/wechat-miniprogram-cylplaceholder` in
   [CYLTableViewPlaceHolder](https://github.com/ChenYilong/CYLTableViewPlaceHolder) go into
   `miniprogram_npm/cyl-placeholder-miniprogram/` (`scripts/sync-example.js` does it for the example). It is not on
   the npm registry and npm cannot install a folder of a Git repository, so `package.json` names it as a peer
   dependency (npm does not fetch it). It is required: `cyl-search` uses its `cyl-refresh` and, by default, its
   `cyl-placeholder`, so without the folder the mini program does not compile ("component not found in the path:
   …/cyl-placeholder-miniprogram/cyl-refresh/index", checked in WeChat DevTools on 2026-11-19). In the same way, the folder
   `CrossPlatform/wechat-miniprogram/packages/cyl-tag-list-miniprogram/miniprogram_dist` of
   [CollectionViewClassifyMenu](https://github.com/ChenYilong/CollectionViewClassifyMenu) goes into
   `miniprogram_npm/cyl-tag-list-miniprogram/`: the search bar draws its items with its `cyl-tag-button`, whose icon is
   CYLTabBarController's `cyl-animated-item` (vendored in that folder by commit).
   The package links no animation engine: an item's `animationURL` plays through the abstract nodes
   `cyl-lottie-view`, `cyl-pag-view`, `cyl-rive-view` and `cyl-svga-view` of `cyl-search-bar` and `cyl-search`, which
   forward them to `cyl-tag-button`. Pass the players you install, for example
   `<cyl-search-bar generic:cyl-lottie-view="cyl-lottie" generic:cyl-svga-view="cyl-svga" …>`; without one, the item
   shows its `image`. A GIF item can also give `gifFirstFrame` and `gifLastFrame` (still images shown before and
   after it plays) and `gifDuration` (one pass in ms; 0: the registered GIF's, else 1000); any animated item can give
   `animationAutoplay` (default false: it rests until tapped or played; true plays it once when it appears) and `animationEmbedded` (default false).
3. DevTools > Tools > Build npm (构建 npm). The components are then `cyl-search-miniprogram/<component>/index`:

```json
{
  "usingComponents": {
    "cyl-search-bar": "cyl-search-miniprogram/cyl-search-bar/index",
    "cyl-search": "cyl-search-miniprogram/cyl-search/index"
  }
}
```

Without npm: copy `src/` into your mini program (for example as `components/`) and use
`/components/cyl-search-bar/index`. The JavaScript API is `require('cyl-search-miniprogram')` (or
`require('/components/index')` in a copy): `CYLSearchBarView`, `CYLSearchBarItem`, `CYLSearchBarMode`, `CYLSearchView`,
`CYLSearchViewDelegate`, `CYLSearchViewDataSource`, `CYLSearchSuggestionStyle`, `CYLSearchResources`,
`CYLSearchSuggestionCache`, `CYLSearchSuggestionCachePolicy` and the helpers `cylFoldTags`, `cylNavigationMetrics`,
`cylClampAnimationSpeed`, `cylFormatString`.

## Usage

```html
<cyl-search-bar placeholder="Search" searchBarStyle="bordered" items="{{items}}"
  bind:focuschange="openSearch" bind:itemselect="onItem" />
<cyl-search id="search" suggestions="{{suggestions}}" suggestionStyle="tags" showsEmptyResultsPlaceholder
  cacheName="MySearch" results="{{results}}" refresherEnabled
  bind:textchange="onText" bind:selectresult="onResult" bind:refresh="onRefresh" bind:submit="onSubmit" />
```

```js
Page({
  data: {
    suggestions: ['Swift', 'Kotlin', 'Dart'],
    results: [],
    items: [{ style: 'icon', title: 'Camera', image: '/images/camera.svg' }, { style: 'divider' }, { style: 'text', title: 'Search' }],
  },
  openSearch() { this.selectComponent('#search').showSearch(); },
  onText(e) { this.setData({ results: find(e.detail.text) }); },
  onResult(e) { console.log('result', e.detail.result, e.detail.index); },
  onRefresh() { load().finally(() => this.selectComponent('#search').endRefreshing()); },
  onSubmit(e) { console.log('query', e.detail.text); },
});
```

### `<cyl-search-bar>` (iOS `CYLSearchBarView`)

| Property | Default | Meaning |
| --- | --- | --- |
| `mode` | `single` | `multiple`: several searches side by side (iOS `CYLSearchBarMode.multiple`) |
| `value`, `placeholder`, `focus` | `''`, `''`, `false` | The text, the placeholder, editing |
| `searchBarStyle` | `plain` | `bordered`: the field and its items in one outline |
| `items` | `[]` | Appended items, plain values of `CYLSearchBarItem.item` (`style` icon / divider / text, `title`, `image`, `badgeValue`, `isSelectable`…) |
| `navigationIcon` | `none` | `arrow` (back) or `search`: a button before the field |
| `showsCancelButton`, `showsVoiceButton`, `showsSubmitButton`, `showsClearButton`, `showsSearchIcon` | | The buttons |
| `fieldHeight`, `fieldCornerRadius`, `fieldBackgroundColor`, `fieldBorderColor`, `fieldBorderWidth`, `fieldShadowOpacity`, `contentInsets`, `fontSize`, `textColor`, `placeholderColor`, `cursorColor`, `searchIconTintColor` | 36, -1 (capsule)… | The look |
| `secure`, `maximumTextLength`, `minimumTextLength`, `returnKeyType` | `false`, 0, 3, `search` | The keyboard; `minimumTextLength` drops shorter completed searches (`multiple`) |
| `editable` | `true` | `false` turns the bar into a button (`tapwhilenoteditable`) |
| `iconified`, `iconifiedByDefault`, `iconPosition`, `expansionAnimation`, `animationDuration` | `false`, `false`, `trailing`, `fade`, 0.3 | Only a search button; it opens with a fade or a circular reveal |
| `searchIndicatorColor`, `unselectedSearchAlpha`, `searchFieldWidth` | system, 0.5, 160 | The `multiple` mode's look |

Events: `textchange` `{ text }` (`{ text, index }` in `multiple`), `submit`, `focuschange`, `cancel`, `itemselect`,
`navigationtap`, `voicetap`, `tapwhilenoteditable`, `iconifiedchange`; `multiple`: `completesearch` `{ text, index }`,
`removesearch` `{ index }`, `selectsearch` `{ text, index }`. Methods: `setText(text, submit)`,
`setIconified(iconified)`, `showKeyboard()`, `hideKeyboard()`; `multiple`: `beginNewSearch()`, `completeSearch()`,
`addSearch(text)`, `selectSearch(index)`, `removeSearch(index)`, `searches()`. Slots: `leading`, `trailing`.

### `<cyl-search>` (iOS `CYLSearchView`)

| Property | Default | Meaning |
| --- | --- | --- |
| `suggestions`, `suggestionStyle` | `[]`, `tags` (`list` until 2026-11-22) | The suggestions, as `tags` folded inline to `foldedRowCount` rows with the fold chevron as the last tag, or as a `list` |
| `cacheName`, `focusesSearchFieldOnShow`, `closesOnSubmit` | `CYLSearchView`, `true`, `true` | Submitted queries are cached and listed first |
| `results`, `showsResultsForEmptyQuery` | `null`, `false` | An array: the results take the place of the suggestions while the query is not empty (iOS `resultsDataSource`; `setResultsDataSource()` in JavaScript) |
| `refresherEnabled` | `false` | CYLTableViewPlaceHolder's pull-to-refresh on the results (iOS `refreshHandler`): `refresh` event, `endRefreshing()` |
| `inline`, `hidesSearchBarWhenScrolling` | `false`, `false` | Drawn in place and always open; the bar scrolls away with the results |
| `showsEmptyResultsPlaceholder`, `emptyResultsScenario`, `emptySuggestionsScenario` | `false`, `NoSearchResults`, `NoContent` | The empty placeholders: CYLTableViewPlaceHolder scenarios, drawn by the abstract node `cyl-empty-view` (default: its `<cyl-placeholder>`) |
| `emptyPlaceholderAnimated`, `animationSpeed`, `animationLoops` | `false`, 1, `true` | Ask `cyl-empty-view` to play the scenario's animation (static on iOS) |
| `navigationIcon`, `showsCancelButton`, `showsVoiceButton`, `showsSearchIcon`, `secure`, `cursorColor` | `arrow`… | The bar |
| `backgroundColor`, `textColor`, `placeholderColor`, `navigationColor`, `suggestionTextColor`, `suggestionImageTintColor`, `dividerColor`, `suggestionLineBreak` | | The look |
| `showsContent` | `false` | Your own view (slot `content`) in place of the suggestions. The content page scrolls by itself (do not add a `<scroll-view>`) and holds its scrolling only while a tag list inside has a drag (`reorderingchange`) or a smear (`smearingchange`) active |
| `coversNavigationBar` | `false` | On a `"navigationStyle": "custom"` page, the bar takes the navigation bar's place, clear of WeChat's menu button |

Events: `show`, `close`, `submit`, `textchange`, `suggestionselect`, `selectresult` `{ result, index }`, `refresh`,
`focuschange`, `voicetap`, `itemselect`. Methods: `showSearch(animated, completion)`, `closeSearch(animated,
completion)`, `isSearchOpen()`, `setQuery(text, submit)`, `setResultsDataSource(dataSource)` (an object with
`searchViewResultsForQuery(searchView, query)` and, optionally, `searchViewConfigureResultCell(searchView, cell,
result)`), `reloadResults()`, `searchResults()`, `setRefreshHandler(handler)`, `beginRefreshing()`, `endRefreshing()`,
`isRefreshing()`, `emptyResultsView()`, `emptySuggestionsView()`, `playAnimationFromStart()`. The static
`CYLSearchView.setRefreshHandler(handler, target)`, `beginRefreshing(target)`, `endRefreshing(target)` and
`isRefreshing(target)` take a `<cyl-search>` instance or a `CYLSearchView`. Slots: `content`, `placeholder-footer`.
Abstract node: `cyl-empty-view` (properties `scenario`, `animated`, `loop`, `speed`; method `playAll()`).

### QMUI search bar and controller (the iOS CYLSearchBar / CYLSearchController)

All of it is opt-in; the defaults change nothing.

- `<cyl-search-bar>`: `centersPlaceholder`; `textFieldMargins` / `activeTextFieldMargins` and `cancelButtonMargins` /
  `activeCancelButtonMargins` (`{ top, left, bottom, right }` in px, at rest and while editing), or the functions
  `setTextFieldMarginsProvider((bar, active) => insets)` and `setCancelButtonMarginsProvider`; `cancelButtonFont`
  (`{ size, weight }`); `setShowsCancelButton(shows, animated)`; the accessory views beside the field: slots `leading-accessory`
  and `trailing-accessory`, `showsLeadingAccessory` / `showsTrailingAccessory`, their margins, and
  `setShowsLeadingAccessoryView(shows, animated)` / `setShowsTrailingAccessoryView`; `appearance`
  (`CYLSearchBarAppearance.default()`).
- `<cyl-search>`: `showsSearchBar` with `showsContent` is the list screen (iOS CYLSearchTableViewController): the bar is the header of
  the content's scroller, `hidesSearchBarInitially`, `hidesSearchBarWhenEmptyViewShowing`, `snapsHeaderSearchBar` (a half hidden
  bar settles, a short list can scroll it out); focusing it starts the search. `showsLaunchView` (slot `launch-view`),
  `dimmingColor`, `highlightsMatches` / `highlightColor`, `supportsSwipeToDismissSearch`; events `updateresults` (every change,
  also "" on activation), `willpresent`, `didpresent`, `willdismiss`, `diddismiss`, `historychange`; methods `setActive(active,
  animated)`, `isActive()`, `showEmptyView(text, detailText, buttonTitle, buttonAction)`, `hideEmptyView()`,
  `isEmptyViewShowing()`, `history()`, `clearHistory()`, and the bar's methods above. Design and parity:
  `docs/qmui-search-controller.md` of the repository.

## Example

Open this folder (`CrossPlatform/wechat-miniprogram-cylsearch`) in WeChat DevTools. `project.config.json` points
`miniprogramRoot` at `example/miniprogram/` and its `beforeCompile` / `beforePreview` / `beforeUpload` hooks run
`node scripts/sync-example.js`, which copies `src/` into the example (a mini program cannot load files outside its
root) and installs CYLTabBarController's tab bar and Lottie player at the commit pinned in `package.json`
(`cylTabBarControllerCommit`; `CYL_TABBAR_DIR` uses a local checkout), and CYLTableViewPlaceHolder's `cyl-placeholder`
and `cyl-refresh` (`cylTableViewPlaceHolderCommit`; `CYL_PLACEHOLDER_DIR`), and CollectionViewClassifyMenu's
`cyl-tag-list-miniprogram` (`collectionViewClassifyMenuCommit`; `CYL_CLASSIFYMENU_DIR`). DevTools asks once whether to run the
project's custom commands; run `npm run sync-example` yourself if the hooks are off. DevTools refuses the committed
`touristappid`: put your own AppID in `project.private.config.json` (git-ignored), for example `{ "appid": "wx…" }`.

The example copies the iOS example (`CYLSearchExample`): the Search tab (the Issue #1317 reproduction: an inline
`<cyl-search>` with results, pull-to-refresh and the overlay), the Examples menu (Search and refresh, the placeholder
gallery of CYLTableViewPlaceHolder's scenarios, Search bar, the ports of lapism/search, MaterialSearchView, yechaoa,
android-cjj and iammert MultiSearchView, the last one a `<cyl-search-bar mode="multiple">`), the plus button's Search
bar page, the Tag style tab and the Discover tab, with the iOS texts, data and images. The example refreshes only
through the core's refresh API. Dark mode follows the system.

## Development

- `npm test`: unit tests (`node --test`): the three core modules, the two components driven by a stand-in of the
  runtime, the package (entry, components, the only sub-dependency, requires that name files), the example's texts
  and Discover rules.
- `npm run import-ios`: re-imports the texts, the Discover data and the hot icons from the iOS bundles.
- `npm run sync-example`: prepares the example (the DevTools hooks run it).
- `scripts/devtools-screenshots.js`: drives every page of the example with miniprogram-automator.
- `npm pack`: the published files are `src/`, `README.md` and `LICENSE`.

## License

MIT, see `LICENSE`. The example's sub-repositories are copied with their own licenses (`scripts/sync-example.js`).
