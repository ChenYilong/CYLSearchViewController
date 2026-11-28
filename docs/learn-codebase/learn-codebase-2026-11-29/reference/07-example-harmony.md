> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# HarmonyOS example: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `harmonyos/AppScope/app.json5` | 10 |
| `harmonyos/build-profile.json5` | 70 |
| `harmonyos/entry/build-profile.json5` | 26 |
| `harmonyos/entry/hvigorfile.ts` | 6 |
| `harmonyos/entry/oh-package.json5` | 21 |
| `harmonyos/entry/src/main/ets/animation/CYLExampleAnimationViews.ets` | 28 |
| `harmonyos/entry/src/main/ets/common/DemoCommon.ets` | 365 |
| `harmonyos/entry/src/main/ets/common/DemoTagMenu.ets` | 110 |
| `harmonyos/entry/src/main/ets/common/SpeechRecognizer.ets` | 67 |
| `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagServer.ets` | 112 |
| `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagsPages.ets` | 869 |
| `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagStore.ets` | 334 |
| `harmonyos/entry/src/main/ets/demos/CYLGalleryChunks.ets` | 36 |
| `harmonyos/entry/src/main/ets/demos/Discover.ets` | 619 |
| `harmonyos/entry/src/main/ets/demos/ExamplesMenu.ets` | 312 |
| `harmonyos/entry/src/main/ets/demos/FirstLevel.ets` | 117 |
| `harmonyos/entry/src/main/ets/demos/MaterialSearch.ets` | 303 |
| `harmonyos/entry/src/main/ets/demos/Ports.ets` | 326 |
| `harmonyos/entry/src/main/ets/demos/SearchBarDemo.ets` | 156 |
| `harmonyos/entry/src/main/ets/demos/SearchController.ets` | 356 |
| `harmonyos/entry/src/main/ets/demos/SearchExample.ets` | 237 |
| `harmonyos/entry/src/main/ets/entryability/EntryAbility.ets` | 100 |
| `harmonyos/entry/src/main/ets/pages/Index.ets` | 286 |
| `harmonyos/entry/src/main/module.json5` | 45 |
| `harmonyos/entry/src/main/resources/rawfile/CYLTabBarConfiguration.json` | 28 |
| `harmonyos/hvigor/hvigor-config.json5` | 4 |
| `harmonyos/hvigorfile.ts` | 6 |
| `harmonyos/oh-package.json5` | 16 |

## `harmonyos/entry/src/main/ets/animation/CYLExampleAnimationViews.ets`

The example's animation engines: `cylRegisterExampleAnimationEngines()` registers CYLTabBarController's engine views (`CYLAnimatedItemLottie`, `CYLAnimatedItemPAG`, `CYLAnimatedItemRive`, `CYLAnimatedItemGIF`, `CYLAnimatedItemSVGA`), so every search bar item's animated icon plays through `CYLAnimatedItemView`'s default engine view. The example's own players are gone: engine fixes live in CYLTabBar

- L19 `export function cylRegisterExampleAnimationEngines(context?: Context): void` — Registers the engines the example plays (Lottie, PAG, Rive, GIF, SVGA). Called once, before any item is shown (`EntryAbility.onCreate`). With the ability's context, the x86_64 engine kit is read first (PAG and Rive then play on the x86_64 emulator).

## `harmonyos/entry/src/main/ets/common/DemoCommon.ets`

- L16 `export function cylFormat(format: string, ...args: (string | number)[]): string` — Fills `%s`, `%d` and positional `%1$d` / `%1$s` in `format` with `args`, in order.
- L28 `export function cylDemoText(context: common.Context, key: string, ...args: (string | number)[]): string` — A text of the library (`demo.port.item`, the `demo.*` keys of iOS CYLSearchViewController.bundle), filled with `args` (iOS `cylDemoText` and `String.localizedStringWithFormat`).
- L35 `export function cylAppText(context: common.Context, name: string, ...args: (string | number)[]): string` — A text of the example (`tab_search`, `discover_recent`, `refresh_idle`), filled with `args`.
- L46 `export class CYLDemoRoute` — The routes of the example's pages, pushed on the tab's NavPathStack.
- L75 `export interface CYLSearchSecondLevelParam` — The second-level search page's parameter: the preset of the tab whose bar was tapped (its bar looks the same).
- L84 `export interface CYLPlaceholderDetailParam` — What a placeholder detail page shows: a row of the Placeholder styles page.
- L93 `export interface CYLMaterialSampleParam` — What a MaterialSearchView sample page gets from its menu.
- L104 `export class CYLSnackbar` — A short message at the bottom of a page, like Android's `Snackbar.make(...).show()` (iOS `CYLSnackbar`): the page draws `CYLSnackbarView` with it.
- L126 `export struct CYLSnackbarView` — Draws a `CYLSnackbar` above the bottom of its page: white text on a dark rounded bar.
- L158 `export struct CYLDemoNavBar` — The navigation bar of a page (UINavigationBar): an optional back button or left button, the title, and an optional right button.
- L238 `export struct CYLDemoCell` — A row of a grouped list (UITableViewCell): an optional image, the text, an optional subtitle and the disclosure chevron.
- L290 `export const CYL_TAB_ICON_SOURCE_KEY: string = 'CYLDemoTabIconSource';` — Where the tab icons come from (iOS `CYLDemoTabIconSource`, a user default and a launch argument): 0 the symbols of CYLTabBarConfiguration.json, 1 SVGA files set in code (the initialization keys), 2 SVGA files of CYLTabBarConfiguration_svga.json. Kept in AppSto
- L292 `const CYL_DEMO_PREFERENCES: string = 'CYLSearchExample';`
- L297 `export function cylStoredTabIconSource(context: common.Context): number` — The stored tab icon source, 0 when none was chosen.
- L310 `export function cylSetTabIconSource(context: common.Context, source: number): void` — Chooses the tab icon source: stored for the next launch and set in AppStorage, so the tab bar changes now.
- L325 `export const CYL_PLUS_IMAGE_SIZE: number = 56;` — The image size of the example's raised plus button (vp), as the iOS example (AGENTS.md, "Example layer, raised plus button").
- L333 `export const CYL_PLUS_OVERHANG: number = cyl_plusButtonOverhang({ imageSize: CYL_PLUS_IMAGE_SIZE, title: '+' });` — How far the raised plus button rises above the tab bar (vp), from cyltabbar's `cyl_plusButtonOverhang` (24 for the 56 vp image above an aligned title in the 49 vp bar). Scrolling lists end this much lower (`contentEndOffset`), so their last rows can scroll cle
- L340 `export struct CYLDemoPlaceholderStack` — Draws a CYLTableViewPlaceHolder placeholder stack (a scenario) inside the example's V2 pages: cylplaceholder's components are V1 and link an `@Observed` model, so the model is held here as V1 state.
- L353 `export struct CYLDemoPlaceholderItem` — Draws one CYLTableViewPlaceHolder placeholder view (an image above a text), centered, inside the example's V2 pages.

## `harmonyos/entry/src/main/ets/common/DemoTagMenu.ets`

- L11 `export interface CYLDemoTagRow` — One row of a grouped demo list: the tag's main title and icon, and the subtitle a long press shows in a callout.
- L20 `export class CYLDemoTagSection` — One section of a grouped demo list: a header that always has a title, and its rows.
- L33 `class CYLDemoTagSource implements CYLMenuDataSource` — The data source of a grouped demo list (docs/instructions/example-demos.md rule 1): a section per group, a tag per row.
- L68 `export struct CYLDemoTagMenuView` — A grouped demo list as ClassifyMenu's tag list (docs/instructions/example-demos.md, rules 1 to 7): titled sections, the Liquid Glass board and glass tags from the shared style (CYLSearchTagListStyle), adaptive tag width, titles that wrap, a 3-row fold whose co

## `harmonyos/entry/src/main/ets/common/SpeechRecognizer.ets`

Turns one spoken phrase into text with CoreSpeechKit (iOS `CYLSpeechRecognizer` with the Speech framework; the sample's `RecognizerIntent`). The engine records from the microphone itself (recognitionMode 0).

- L8 `export class CYLSpeechRecognizer` — Turns one spoken phrase into text with CoreSpeechKit (iOS `CYLSpeechRecognizer` with the Speech framework; the sample's `RecognizerIntent`). The engine records from the microphone itself (recognitionMode 0).

## `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagServer.ets`

- L13 `export const CYL_CONTACT_TAGS_LATENCY_KEY: string = 'CYLContactTagsServerLatency';` — The `CYLContactTagsServerLatency` launch parameter (`--pi CYLContactTagsServerLatency 2`), in seconds.
- L24 `export class CYLContactTagServer` — The contact tags demo's simulated server (iOS `CYLContactTagServer`). The local cache, A, is the store's; the server's data, B, is a second preference file that stands for the server shared by the user's devices. Every request waits `latency` (5 s, or the laun

## `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagsPages.ets`

- L23 `const CYL_GREEN: string = '#07C160';` — The chat app's green (#07C160) and link color (#576B95).
- L24 `const CYL_LINK: string = '#576B95';`
- L25 `const CYL_GRAY6: string = '#F2F2F7';`
- L28 `export const CYL_CONTACT_TAGS_OPEN_KEY: string = 'CYLContactTags';` — The launch parameters of the demo (iOS launch arguments), `--pi <name> 1` (EntryAbility stores them).
- L29 `export const CYL_CONTACT_TAGS_EDITOR_KEY: string = 'CYLContactTagsEditor';`
- L30 `export const CYL_CONTACT_TAGS_EMPTY_KEY: string = 'CYLContactTagsEmpty';`
- L31 `export const CYL_CONTACT_TAGS_RESET_KEY: string = 'CYLContactTagsResetCache';`
- L37 `export function cylContactTagStyle(): CYLMenuStyle` — Liquid Glass tags (one parameter, `backgroundStyle`): the glass is the background, so a tag has no fill and no border of its own; a selected tag tints the glass green and its title is green (iOS `CYLContactTagEditorViewController.tagStyle()`).
- L65 `export class CYLContactTagEditorParam` — What "Edit Tags" opens with and reports to (pushed with the route).
- L78 `export class CYLContactListParam` — The contacts page of a tag.
- L86 `class CYLManageButtonModel` — "Manage" / "Done Managing" in the header of "My Tags" (the list's accessory view, a global builder).
- L93 `const cylManageButtonModel: CYLManageButtonModel = new CYLManageButtonModel();`
- L96 `struct CYLManageButton`
- L110 `function cylManageAccessory(section: number)`
- L114 `const cylManageAccessoryBuilder: WrappedBuilder<[number]> = wrapBuilder(cylManageAccessory);`
- L117 `class CYLRemarkSource implements CYLMenuDataSource` — The contact's tags, display only (Edit Remarks).
- L145 `export struct CYLContactRemarkPage` — "Edit Remarks" (iOS `CYLContactRemarkViewController`): a remark name and the contact's tags (a display-only tag list); "Tags" opens "Edit Tags". Without tags, CYLTableViewPlaceHolder's placeholder takes the list's place and opens the editor too.
- L261 `class CYLContactTagItem` — One item of a section: a tag (its id), or "+ New Tag" (no name: asks for one) / "+ New tag: <name>".
- L280 `enum CYLContactTagSectionKind`
- L286 `class CYLContactTagSection`
- L293 `enum CYLContactTagsEmptyState` — The empty state shown with CYLPlaceholderView.
- L303 `class CYLContactTagsEditorSource implements CYLMenuDataSource` — The data source of "Edit Tags": its sections (made by the page), the menu's questions about them, and the edits (remove, move, rename) handed back to the page.
- L393 `export struct CYLContactTagEditorPage` — "Edit Tags" (iOS `CYLContactTagEditorViewController`): chooses, creates, renames and deletes a contact's tags, searched with this library's `CYLSearchBarView`; the tags are CollectionViewClassifyMenu's tag list. - "Recent" (the list's built-in clear button) an
- L817 `export struct CYLContactListPage` — The contacts that have a tag (iOS `CYLContactListViewController`): the page a tap on a tag opens in "Manage" mode; CYLTableViewPlaceHolder's placeholder when none has it.

## `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagStore.ets`

A text of the contact tags demo (iOS `cylContactTagsText`): `contactTags.<key>` of `CYLContactTags.bundle`, imported into the entry's string.json as `contactTags_<key>` (scripts/import-ios-resources.py), filled with `args`.

- L11 `export function cylContactTagsText(context: common.Context, key: string, ...args: (string | number)[]): string` — A text of the contact tags demo (iOS `cylContactTagsText`): `contactTags.<key>` of `CYLContactTags.bundle`, imported into the entry's string.json as `contactTags_<key>` (scripts/import-ios-resources.py), filled with `args`.
- L19 `export class CYLContactTag` — A tag (iOS `CYLContactTag`): its id is its primary key (a reorder or a rename keeps it, and contacts are bound to it); its title is what the lists show.
- L32 `export class CYLContactTagContact` — A demo contact (iOS `CYLContactTagData.Contact`): a name and the ids of its tags.
- L41 `export class CYLContactTagData` — The contents of contact-tags.json (iOS `CYLContactTagData`), version 2: tags with ids, the ids of the recently used ones and of the tags the remark screen starts with, and the contacts.
- L72 `export class CYLContactTagSections` — Sections of tags ("mine", "recent") with their ids, as JSON: cache A and the server's cache B keep ids with the titles, as iOS's `CYLTagListCacheItem`.
- L99 `export const CYL_CONTACT_TAGS_MINE: string = 'mine';` — The cache keys of "My Tags" and "Recent".
- L100 `export const CYL_CONTACT_TAGS_RECENT: string = 'recent';`
- L102 `export const CYL_CONTACT_TAGS_CACHE: string = 'CYLContactTags';` — The names of cache A (the store) and cache B (the simulated server).
- L103 `export const CYL_CONTACT_TAGS_SERVER: string = 'CYLContactTagsServer';`
- L104 `const SECTIONS_KEY: string = 'sections';`
- L109 `export class CYLContactTagPreferences` — Reads and writes a sections preference file (caches A and B).
- L139 `export class CYLContactTagStore` — The user's tags (iOS `CYLContactTagStore`), keyed by id: every tag in the user's order, and the recently used ones. Changes are saved to `cache` (cache A) with their ids.

## `harmonyos/entry/src/main/ets/demos/CYLGalleryChunks.ets`

The Placeholder styles page has 42 sections (168 glass tags). Building them all in one go blocks the ArkTS main thread for more than 6 seconds on the emulator (appfreeze THREAD_BLOCK_6S, "App died"), so the page builds its tag lists in chunks of a few sections and adds the next chunk when the scroll reaches the end. MARK: - Pure logic (begin) The sections of one chunk: [first, count] of the chunk'

- L12 `function cylGalleryChunkRange(chunk: number, chunkSize: number, total: number): number[]` — The sections of one chunk: [first, count] of the chunk's sections, or an empty range past the last section.
- L21 `function cylGalleryChunksAfterReachEnd(shown: number, chunkSize: number, total: number): number` — The number of chunks to show after the scroll reached the end: one more, never more than the chunks that exist.
- L28 `export const CYL_GALLERY_CHUNK_SIZE: number = 6;`
- L30 `export function cylGalleryRange(chunk: number, total: number): number[]`
- L34 `export function cylGalleryNextChunkCount(shown: number, total: number): number`

## `harmonyos/entry/src/main/ets/demos/Discover.ets`

- L23 `function cylFoldedTagCount(widths: number[], width: number, rows: number, spacing: number,` — How many tags (`widths`, in vp) fit in `rows` rows of `width`, leaving room for a control of `controlWidth` after the last visible tag; all of them when they fit without it (the folding of the recent searches, as iOS's CYLSearchDiscoverViewController; the core
- L64 `export interface CYLDiscoverTopic` — A discover topic of search-discover.json; `icon` "hot" adds the localized hot icon after the title.
- L72 `interface CYLDiscoverPage` — One page of topics and its number.
- L80 `export interface CYLSearchDiscoverData` — The demo's data (iOS `CYLSearchDiscoverData`): one rawfile per language, the same topics in the same order.
- L90 `export function cylLoadDiscoverData(context: common.Context): CYLSearchDiscoverData` — The demo data of the device language (Discover and the second-level search pages share it).
- L112 `function cylDiscoverItemHint(topic: CYLDiscoverTopic, hotLabel: string, hint: string): string` — The screen reader description of a topic: a hot topic's hot icon has no label of its own in ClassifyMenu's tag list (the icon is hidden from the screen reader and the cell reads its title), so the localized hot label (iOS bridges send it as `tagImageLabels`) l
- L120 `function cylDiscoverPage(pool: CYLDiscoverTopic[], count: number, page: number): CYLDiscoverPage` — The topics of page `page` of `pool`: whole pages of `count` records, the page number taken modulo the number of pages (a negative page counts from the end). Refresh shows the next page, cyclically, with no random pick.
- L133 `class CYLDiscoverSource implements CYLMenuDataSource` — The discover topics as the data source of ClassifyMenu's tag list (iOS `CYLDiscoverSource`): one section, the title of a topic, the localized hot icon after the title of a hot topic.
- L167 `function cylDiscoverStyle(hotWidth: number): CYLMenuStyle` — The iOS example's `discoverStyle()`: `CYLMenuStyle.gridStyle(itemsPerRow: 2)` (ClassifyMenu's own preset: two equal cells per row, no fill, no border, the icon after the title) with 17 pt medium titles in the theme's text color, 36 high, 16 between rows and se
- L185 `const TAG_HEIGHT: number = 36;`
- L186 `const TAG_SPACING: number = 12;`
- L187 `const TAG_MARGIN: number = 14;`
- L188 `const CHEVRON_WIDTH: number = 44;`
- L198 `export struct DiscoverView` — The Discover tab (iOS `CYLSearchDiscoverViewController`, copied from CollectionViewClassifyMenu's CYLMenuExample): the bordered search bar with the camera, a divider and Search appended inside it; "Recent searches" as tags folded to two rows with the chevron a
- L574 `export struct DiscoverEntryView` — The root of the Discover tab, a first-level page: the navigation bar holds the whole search bar of the reference look (bordered capsule, camera and the Search button inside), full width within the safe area. A tap on it pushes the Discover page; the core bring
- L613 `export struct DiscoverPage` — The Discover page pushed from the entry page: back button on the left, the search bar in the navigation bar.

## `harmonyos/entry/src/main/ets/demos/ExamplesMenu.ets`

- L26 `const STYLE_COUNT: number = 41;` — The number of placeholder styles shown: the 41 styles the search placeholder had, the first 41 of CYLTableViewPlaceHolder's `CYLPlaceholderStyle`, in the same order.
- L27 `const MESSAGE_KEYS: string[] = ['placeholder.empty', 'placeholder.search', 'placeholder.error', 'placeholder.network'];`
- L31 `const MESSAGES: CYLPlaceholderMessage[] = [CYLPlaceholderMessage.Empty, CYLPlaceholderMessage.NoResults,` — The CYLTableViewPlaceHolder messages of the four rows of a style.
- L33 `const CUSTOM_KEYS: string[] = ['demo.custom.textOnly', 'demo.custom.imageOnly', 'demo.custom.both'];`
- L38 `const SVGA_ICON_SIDE: number = 64;` — The side of the SVGA demo's animated icon in vp (iOS `CYLSVGADemoTagButton.iconSide`).
- L46 `function cylSVGADemoTagButton(title: string, animationURL: string): CYLTagButton` — The SVGA demo above the Examples list (iOS `CYLSVGADemoTagButton`): a `CYLTagButton` (CollectionViewClassifyMenu, the one icon + title + animated icon component) whose `animationURL` is an `.svga` rawfile, drawn by its animation engine, so the example uses no 
- L74 `export struct ExamplesMenuView` — The Examples tab (iOS `CYLSearchDemoMenuViewController`): Search and refresh, Placeholder styles, Search bar, and the other libraries' examples.
- L184 `export function cylPlaceholderForRow(context: common.Context, section: number, row: number): CYLPlaceholderViewModel` — The placeholder of a row of the Placeholder styles page (iOS `-tableView:didSelectRowAtIndexPath:`).
- L206 `export struct PlaceholderGalleryPage` — Placeholder styles (iOS `CYLSearchPlaceholderGalleryViewController`): one section per style, named after its image, with its four messages; then the Custom section (built-in image with custom text, custom image with a built-in message, both custom).
- L290 `export struct PlaceholderDetailPage` — The detail page of a row: one CYLTableViewPlaceHolder placeholder view (`CYLPlaceholderView`) filling the page.

## `harmonyos/entry/src/main/ets/demos/FirstLevel.ets`

A first-level search bar (owner directive 2026-11-26, example-demos rule 10): the core's preset for the tab, the tap pushes the second-level search page. The page only names the preset, the placeholder and the push; the core brings the back button in, narrows the bar and reverses both on the way back.

- L12 `export function cylFirstLevelBar(preset: CYLSearchBarPreset, placeholder: ResourceStr, stack: NavPathStack,` — A first-level search bar (owner directive 2026-11-26, example-demos rule 10): the core's preset for the tab, the tap pushes the second-level search page. The page only names the preset, the placeholder and the push; the core brings the back button in, narrows 
- L34 `export struct SearchSecondLevelPage` — The second-level search page every first-level bar pushes: the same bar look (the tab's preset) with the back button on the left, the keyboard up, and the Recently searched and Popular right now tag lists below. Tapping a tag searches it.

## `harmonyos/entry/src/main/ets/demos/MaterialSearch.ets`

- L29 `export enum CYLMaterialSearchSample` — The sample screens of MiguelCatalan/MaterialSearchView (iOS `CYLMaterialSearchSample`).
- L38 `const SAMPLE_KEYS: string[] = ['demo.port.default', 'demo.port.themed', 'demo.port.voice', 'demo.port.sticky',`
- L44 `export const CYL_MATERIAL_SUGGESTIONS: string[] = [` — `R.array.query_suggestions` of the sample.
- L57 `export struct MaterialMenuView` — Port of MaterialSearchView's sample `MainActivity` (iOS `CYLMaterialSearchMenuViewController`): one row per sample. The Tag style tab shows the same menu with `tags` (suggestions as tags, the keyboard down on show).
- L121 `export struct MaterialMenuPage` — The menu pushed from the ports list.
- L138 `export struct MaterialSamplePage` — One sample screen (iOS `CYLMaterialSearchSampleViewController`): a bar with a search item that opens a `CYLSearchView` over the bar with the sample's suggestions; a submitted query shows "Query: …" in a snackbar and closes the search, as `onQueryTextSubmit` re

## `harmonyos/entry/src/main/ets/demos/Ports.ets`

- L20 `class CYLLapismModel` — The filtered list shown inside the lapism search view (the README's adapter); a global builder draws it as the search view's `contentView`.
- L24 `const lapismModel: CYLLapismModel = new CYLLapismModel();`
- L27 `struct CYLLapismResults`
- L46 `function lapismResults()`
- L56 `export struct LapismPage` — Port of lapism/search's README usage (iOS `CYLLapismSearchViewController`): a `MaterialSearchBar` (magnifier navigation icon, hint, taps open the search) over a list, and a `MaterialSearchView` (arrow navigation icon, a filtered list added as its content, quer
- L130 `export struct YechaoaPage` — Port of yechaoa/MaterialDesign's `SearchViewActivity` (iOS `CYLYechaoaSearchViewController`): an iconified search view in the toolbar with a submit button, the Search return key, a hint and custom colors; a submitted query shows a snackbar and a search result,
- L211 `export struct RevealPage` — Port of android-cjj/MaterialSearchView's sample (iOS `CYLRevealSearchViewController`): on the primary color, a round search button opens a light search card with a one-second circular reveal; the magnifier in the card closes it.
- L273 `export struct MultiSearchDemoPage` — Port of iammert/MultiSearchView's sample `MainActivity` (iOS `CYLMultiSearchDemoViewController`): a search bar in `multiple` mode styled like the README's `SearchTextStyle` (hint "Search", 18 vp text, at most 15 characters, the Search key, gray hint, primary t

## `harmonyos/entry/src/main/ets/demos/SearchBarDemo.ets`

The Search bar page (iOS `CYLSearchBarDemoViewController`), the plus button's page and a row of the Examples menu: a `CYLSearchBarView` with Cancel, a soft shadow and a camera button inside the field; the label shows the text as it is typed and the submitted query.

- L13 `export struct SearchBarDemoView` — The Search bar page (iOS `CYLSearchBarDemoViewController`), the plus button's page and a row of the Examples menu: a `CYLSearchBarView` with Cancel, a soft shadow and a camera button inside the field; the label shows the text as it is typed and the submitted q
- L88 `export struct SearchBarDemoPage` — The Search bar page pushed from the Examples menu.
- L99 `interface CYLPortRow`
- L109 `export struct PortsMenuPage` — The ports of the examples of five search libraries (iOS `CYLSearchPortsViewController`).

## `harmonyos/entry/src/main/ets/demos/SearchController.ets`

- L19 `const CYL_KEYWORDS: string[] = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat',` — The keywords of QMUI's `QDSearchViewController` (iOS `CYLSearchControllerDemoViewController.keywords`).
- L25 `const CYL_LAUNCH_SUGGESTIONS: string[] = ['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy',` — The suggestions of the launch area while there is no history (iOS `CYLSearchControllerDemoViewController.suggestions`).
- L31 `const CYL_RESULT_REPEAT: number = 20;` — Each matching keyword appears this many times in the results (QMUI's demo shows 20 rows per match).
- L36 `class CYLKeywordResults implements CYLSearchViewDataSource` — The results of the Search controller screen: the matching keywords, each repeated 20 times.
- L59 `export struct SearchControllerView` — The Search controller screen (iOS `CYLSearchControllerDemoViewController`, QMUI's `QDSearchViewController`): a list of ten keywords whose first row is the search bar; a tap on it opens the search with the recent searches as the launch view, the history kept wh
- L131 `export struct SearchControllerPage` — The Search controller page pushed from the Examples menu.
- L149 `function cylLeadingAccessory()` — A 30 x 30 rounded square with a 3 vp stroke, the accessory view of the styles screen (iOS `accessoryView()`).
- L159 `function cylTrailingAccessory()`
- L171 `enum CYLStylesRow` — The rows of the Search bar styles screen (iOS `CYLSearchBarStylesViewController.Row`).
- L189 `export struct SearchBarStylesView` — The Search bar styles screen (iOS `CYLSearchBarStylesViewController`, QMUI's `QDSearchBarViewController`): a list with a built-in bar (`CYLSearchTableView`) and the sections Placeholder (center it, change it), Layout (field margins 0 / 32 at rest, Cancel margi
- L347 `export struct SearchBarStylesPage` — The Search bar styles page pushed from the Examples menu.

## `harmonyos/entry/src/main/ets/demos/SearchExample.ets`

- L20 `export class CYLSearchExampleDataSource implements CYLSearchViewDataSource` — Forty localized sample results, filtered by the query; also the example's refresh provider (iOS `CYLSearchExampleDataSource`).
- L63 `export struct SearchExampleView` — The Issue #1317 reproduction (iOS `CYLSearchExampleViewController`): a search bar under the navigation bar over a list with the core's pull to refresh (`CYLSearchView.setRefreshHandler` on the list's scroller, drawn by `CYLSearchRefreshComponent`) and CYLTable
- L228 `export struct SearchExamplePage` — The reproduction pushed from the Examples menu ("Search and refresh").

## `harmonyos/entry/src/main/ets/entryability/EntryAbility.ets`

- L8 `const DOMAIN = 0x0000;`
- L10 `export default class EntryAbility extends UIAbility`

## `harmonyos/entry/src/main/ets/pages/Index.ets`

- L40 `function cylTabImage(name: string): ResourceStr | undefined` — The tab icons of CYLTabBarConfiguration.json ("system:<SF Symbol>"), drawn in the unselected and selected colors of UITabBar; a selected image name carries "#selected" (see `cylMarkSelectedImages`).
- L57 `function cylMarkSelectedImages(configuration: Record<string, Object>): void` — Selected images are tinted on iOS; the resolver only gets a name, so the selected names are marked.
- L75 `struct Index` — The example app (iOS `CYLSearchExampleAppDelegate`): CYLTabBarController (its HarmonyOS library `cyltabbar`, pinned in harmonyos/oh-package.json5) configured by the iOS example's CYLTabBarConfiguration.json, with Search, Examples, the plus button (Search bar p
