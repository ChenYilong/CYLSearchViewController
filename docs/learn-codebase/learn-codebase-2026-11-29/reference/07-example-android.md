> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# Android example: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `android/merged/app/build.gradle.kts` | 65 |
| `android/merged/app/src/main/AndroidManifest.xml` | 21 |
| `android/merged/app/src/main/assets/CYLTabBarConfiguration.json` | 48 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagServer.kt` | 103 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagsPages.kt` | 837 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagStore.kt` | 271 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLBackdropPlate.kt` | 50 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLExamplePage.kt` | 155 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchBarDemoFragment.kt` | 66 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchBarStylesFragment.kt` | 197 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchControllerDemoFragment.kt` | 132 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchDemoMenuFragment.kt` | 294 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchDiscoverFragment.kt` | 512 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchExampleFragment.kt` | 192 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchPortsFragment.kt` | 447 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchShortListFragment.kt` | 45 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchTabBars.kt` | 88 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSuggestionStyleFragment.kt` | 91 |
| `android/merged/app/src/main/kotlin/com/cyl/search/example/MainActivity.kt` | 95 |
| `android/merged/build.gradle.kts` | 17 |
| `android/merged/gradle.properties` | 18 |
| `android/merged/sample-materialsearchview/build.gradle.kts` | 37 |
| `android/merged/sample-materialsearchview/src/main/AndroidManifest.xml` | 13 |
| `android/merged/sample-multisearchview/build.gradle.kts` | 40 |
| `android/merged/sample-multisearchview/src/main/AndroidManifest.xml` | 6 |
| `android/merged/sample-reveal/build.gradle.kts` | 35 |
| `android/merged/sample-reveal/src/main/AndroidManifest.xml` | 7 |
| `android/merged/sample-yechaoa/build.gradle.kts` | 39 |
| `android/merged/sample-yechaoa/src/main/AndroidManifest.xml` | 7 |
| `android/merged/search-lapism/build.gradle.kts` | 40 |
| `android/merged/search-lapism/src/main/AndroidManifest.xml` | 4 |
| `android/merged/search-materialsearchview/build.gradle.kts` | 35 |
| `android/merged/search-materialsearchview/src/main/AndroidManifest.xml` | 4 |
| `android/merged/search-multisearchview/build.gradle.kts` | 41 |
| `android/merged/search-multisearchview/src/main/AndroidManifest.xml` | 4 |
| `android/merged/settings.gradle.kts` | 91 |

## `android/merged/app/build.gradle.kts`

The example app: the iOS example ported to Android, with CYLTabBarController's tab bar from a configuration file (pinned commit, settings.gradle.kts).

## `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagServer.kt`

The contact tags demo's simulated server (iOS `CYLContactTagServer`). The local cache, A, is the store's (`CYLContactTagStore.cache`); the server's data, B, is a second file that stands for the server shared by the user's devices. Every request waits `latencySeconds` (5 s) and shows CYLTableViewPlaceHolder's HUD (`CYLPlaceholderHUD`): - uploading copies A's sections to B ("Uploading鈥?, then "Uploa

- L21 `class CYLContactTagServer(private val context: Context, private val container: () -> ViewGroup?)` — The contact tags demo's simulated server (iOS `CYLContactTagServer`). The local cache, A, is the store's (`CYLContactTagStore.cache`); the server's data, B, is a second file that stands for the server shared by the user's devices. Every request waits `latencyS

## `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagsPages.kt`

- L49 `object CYLContactTagsStyle` — The look of the contact tags demo (iOS `CYLContactTagEditorViewController.tagStyle()`, the chat app's colors).
- L87 `object CYLContactTagsOptions` — The launch options of the contact tags demo (iOS launch arguments), read from the activity's intent extras.
- L107 `class CYLContactRemarkPage : CYLExamplePage(), CYLMenuDataSource, CYLMenuDelegate` — "Edit Remarks" (iOS `CYLContactRemarkViewController`): a remark name and the contact's tags (a display-only `CYLTagListView`); "Tags" opens "Edit Tags". Without tags, CYLTableViewPlaceHolder's `CYLPlaceholderView` takes the list's place; tapping it opens the e
- L249 `class CYLContactTagEditorPage : CYLExamplePage(), CYLMenuDataSource, CYLMenuDelegate, CYLSearchBarViewDelegate` — "Edit Tags" (iOS `CYLContactTagEditorViewController`): chooses, creates and deletes a contact's tags, searched with this library's `CYLSearchBarView`; the tags are CollectionViewClassifyMenu's `CYLTagListView`. - "Recent" (with a trash button) and "My Tags" (w
- L787 `class CYLContactListPage : CYLExamplePage()` — The contacts that have a tag (iOS `CYLContactListViewController`): the page a tap on a tag opens in "Manage" mode; CYLTableViewPlaceHolder's placeholder when none has it.

## `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagStore.kt`

The example-level bundle of the contact tags demo (iOS `CYLContactTagsLocalization`): a verbatim copy of `CYLSearchExample/CYLContactTags.bundle` in the assets, one `<language>.lproj` per language, each with `CYLContactTags.strings` and `contact-tags.json`.

- L16 `object CYLContactTagsLocalization` — The example-level bundle of the contact tags demo (iOS `CYLContactTagsLocalization`): a verbatim copy of `CYLSearchExample/CYLContactTags.bundle` in the assets, one `<language>.lproj` per language, each with `CYLContactTags.strings` and `contact-tags.json`.
- L52 `fun cylContactTagsText(context: Context, key: String, vararg arguments: Any): String` — A text of the contact tags demo (iOS `cylContactTagsText`): `contactTags.<key>`, formatted with `arguments` (`%@` and `%ld` as on iOS).
- L63 `data class CYLContactTag(val id: String, val title: String)` — A tag (iOS `CYLContactTag`): its id is its primary key (a reorder or a rename keeps it, and contacts are bound to it); its title is what the lists show.
- L68 `data class CYLContactTagContact(val name: String, val tags: List<String>)` — A demo contact (iOS `CYLContactTagData.Contact`): a name and the ids of its tags.
- L74 `data class CYLContactTagData(` — The contents of contact-tags.json (iOS `CYLContactTagData`): the demo tags (id and title), the ids of the recently used ones and of the tags the remark screen starts with, and the contacts.
- L106 `object CYLContactTagSections` — Sections of tags as JSON (`{"mine": [{"id", "title"}], "recent": [...]}`): cache A and the server's cache B keep ids with the titles, as iOS's `CYLTagListCacheItem`. (CollectionViewClassifyMenu's Android `CYLTagListStore` keeps titles only, so the demo stores 
- L125 `class CYLContactTagStore(tags: List<CYLContactTag>, recentIDs: List<String> = emptyList(), val recentLimit: Int = 8)` — The user's tags (iOS `CYLContactTagStore`), keyed by id: every tag in the user's order, and the recently used ones. Changes are saved to `cache` (cache A) with their ids.

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLBackdropPlate.kt`

Debug switch (off by default; `adb shell am start --ez CYLDebugStripes true`): the plate draws 8 hard-edged saturated horizontal stripes instead of the gradient, so the glass blur (API 31+) and refraction (API 33+) show on hard edges.

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLExamplePage.kt`

A text of the example (the `demo.*` keys of the library's strings, imported from the iOS bundle).

- L21 `fun Context.cylDemoText(key: String): String = CYLSearchResources.localizedString(this, key)` — A text of the example (the `demo.*` keys of the library's strings, imported from the iOS bundle).
- L27 `abstract class CYLExamplePage : Fragment()` — A page of the example: a toolbar (the iOS navigation bar: title, back button when pushed, actions) above the page's content. The content starts below the toolbar, so no bar covers it.

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchBarDemoFragment.kt`

The search bar example, the plus button's page (iOS `CYLSearchBarDemoViewController`): a bar with Cancel, a shadow and a camera button inside the field; the text below follows typing and searching.

- L17 `class CYLSearchBarDemoFragment : CYLExamplePage(), CYLSearchBarViewDelegate` — The search bar example, the plus button's page (iOS `CYLSearchBarDemoViewController`): a bar with Cancel, a shadow and a camera button inside the field; the text below follows typing and searching.

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchBarStylesFragment.kt`

A 30 x 30 stroked rounded square, the accessory view of QMUI's `QDSearchBarViewController`.

- L24 `class CYLStrokedSquareView(context: Context, color: Int) : View(context)` — A 30 x 30 stroked rounded square, the accessory view of QMUI's `QDSearchBarViewController`.
- L50 `class CYLSearchBarStylesFragment : CYLExamplePage()` — The "Search bar styles" screen: a replica of QMUI's `QDSearchBarViewController` (QMUIDemo_iOS; iOS `CYLSearchBarStylesViewController`). Sections Placeholder, Layout and AccessoryView drive the bar that is the first item of the list (`CYLSearchListView`, edited

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchControllerDemoFragment.kt`

The "Search controller" screen: a replica of QMUI's `QDSearchViewController` (QMUIDemo_iOS; iOS `CYLSearchControllerDemoViewController`). Ten keywords in a list whose first item is the search bar (`CYLSearchListView`); the search shows the core's suggestion area while the text is empty (the history, or QMUI's eight suggestions, as tags), the matching keywords (twenty rows each) with the match high

- L29 `class CYLSearchControllerDemoFragment : CYLExamplePage(), CYLSearchViewDelegate, CYLSearchViewDataSource` — The "Search controller" screen: a replica of QMUI's `QDSearchViewController` (QMUIDemo_iOS; iOS `CYLSearchControllerDemoViewController`). Ten keywords in a list whose first item is the search bar (`CYLSearchListView`); the search shows the core's suggestion ar

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchDemoMenuFragment.kt`

A grouped list of rows as CollectionViewClassifyMenu's tag list (docs/instructions/example-demos.md): one section per header (the rows before the first header form a section titled `defaultHeader`), each row a Liquid Glass tag with its main title and icon, the width adaptive, titles allowed to wrap, folded after 3 rows behind the tail control (the last tag, chevron icon only). A tap runs the row's

- L94 `class CYLSearchDemoMenuFragment : CYLExamplePage()` — The examples menu (iOS `CYLSearchDemoMenuViewController`): the search example, the placeholder styles, the search bar, the ports of the other libraries' examples, and their original samples.
- L203 `class CYLSearchPlaceholderGalleryFragment : CYLExamplePage()` — Every placeholder image with each built-in message, and the custom forms (iOS `CYLSearchPlaceholderGalleryViewController`), drawn by CYLTableViewPlaceHolder's `CYLPlaceholderView`: the search core has no placeholder view of its own.
- L251 `class CYLViewPage : CYLExamplePage()` — A page that shows one view under a title (the iOS detail view controllers of the menus).
- L273 `class CYLOriginalSamplesFragment : CYLExamplePage()` — The upstream samples, unchanged, from the projects translated in android/ (step 3).

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchDiscoverFragment.kt`

- L51 `data class CYLDiscoverTopic(val title: String, val icon: String?)` — One discover topic: a title and an optional icon after it ("hot" for the localized hot icon).
- L57 `class CYLSearchDiscoverData(val discoverCount: Int, val recentSearches: List<String>, val discover: List<CYLDiscoverTopic>)` — The data of the discover demo, from `assets/CYLSearchDiscover.bundle/<language>.lproj/search-discover.json` (the same files as iOS): recent searches, and a pool of topics from which the More button picks another selection.
- L131 `class CYLSearchDiscoverFragment : Fragment(), CYLMenuDelegate, CYLSearchBarViewDelegate, CYLInteractiveBack` — The search history and discover page (iOS `CYLSearchDiscoverViewController`, copied from CollectionViewClassifyMenu): "Recent searches" is a `CYLTagListView` folded to two rows with the chevron as the last tag and a trash button; "Discover" is a grid of two ti

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchExampleFragment.kt`

Reloads the example's data for pull to refresh (iOS `CYLSearchExampleRefreshing`).

- L26 `interface CYLSearchExampleRefreshing` — Reloads the example's data for pull to refresh (iOS `CYLSearchExampleRefreshing`).
- L38 `class CYLSearchExampleDataSource(private val items: List<String>) : CYLSearchViewDataSource, CYLSearchExampleRefreshing` — Forty localized sample results, filtered by the query; the results of the overlay's `CYLSearchView` and the example's refresh provider (iOS `CYLSearchExampleDataSource`).
- L73 `class CYLSearchExampleFragment : CYLExamplePage()` — The search example (iOS `CYLSearchExampleViewController`, the Issue #1317 page): a search bar above a list with pull to refresh (`CYLSearchView.setRefreshHandler`) and an empty state (CYLTableViewPlaceHolder's no-results scenario); "Overlay" opens a `CYLSearch

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchPortsFragment.kt`

The ports of the examples of five search libraries (iOS `CYLSearchPortsViewController`). Each port only passes

- L43 `class CYLSearchPortsFragment : CYLExamplePage()` — The ports of the examples of five search libraries (iOS `CYLSearchPortsViewController`). Each port only passes data and style parameters to `cylsearch` and handles taps.
- L61 `class CYLLapismPortFragment : CYLExamplePage(), CYLSearchBarViewDelegate, CYLSearchViewDelegate` — lapism/search (iOS `CYLLapismSearchViewController`): a search bar that opens a search view with a results list.
- L121 `class CYLMaterialSearchMenuFragment : CYLExamplePage()` — MiguelCatalan/MaterialSearchView's six samples (iOS `CYLMaterialSearchMenuViewController`).
- L133 `enum class CYLMaterialSearchSample(val titleKey: String)` — The samples of MaterialSearchView.
- L146 `class CYLMaterialSearchSampleFragment : CYLExamplePage(), CYLSearchViewDelegate` — One MaterialSearchView sample (iOS `CYLMaterialSearchSampleViewController`): a toolbar search action that opens a `CYLSearchView` with the sample's suggestions and style.
- L298 `class CYLYechaoaPortFragment : CYLExamplePage(), CYLSearchBarViewDelegate` — yechaoa/MaterialDesign's SearchViewActivity (iOS `CYLYechaoaSearchViewController`): an iconified search bar in the toolbar that opens over the title; a submitted query shows a pretend result.
- L349 `class CYLRevealPortFragment : CYLExamplePage()` — android-cjj/MaterialSearchView (iOS `CYLRevealSearchViewController`): a floating search button that reveals a search card with a circular reveal.
- L398 `class CYLMultiSearchPortFragment : CYLExamplePage(), CYLSearchBarViewDelegate` — iammert/MultiSearchView (iOS `CYLMultiSearchDemoViewController`): a `CYLSearchBarView` in `Multiple` mode, several searches side by side, with an event log.

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchShortListFragment.kt`

The "Short list" screen (the issue scenario I4, QMUI #1160, iOS `CYLSearchShortListDemoViewController`): three rows under the search bar, which scrolls out at first and settles fully shown or hidden (`snapsHeaderSearchBar`).

- L17 `class CYLSearchShortListFragment : CYLExamplePage()` — The "Short list" screen (the issue scenario I4, QMUI #1160, iOS `CYLSearchShortListDemoViewController`): three rows under the search bar, which scrolls out at first and settles fully shown or hidden (`snapsHeaderSearchBar`).

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchTabBars.kt`

The key of the fragment result a second-level search page sends to the first-level page below it (the query).

- L13 `const val CYL_SEARCH_RESULT = "cylSearchQuery"` — The key of the fragment result a second-level search page sends to the first-level page below it (the query).
- L19 `interface CYLInteractiveBack` — A second-level page the back gesture drives (predictive back): the first-level bar's back button and width follow the gesture, `MainActivity` forwards it. `progress` runs 0 to 1.
- L32 `fun cylTabSearchBar(context: Context, key: String, onCamera: () -> Unit, onSearch: () -> Unit): CYLSearchBarView` — The search bar of the tab `key`, one style per tab (the tab bar controller owns the tabs, each tab root owns its bar): the same bar is the whole bar of the first-level page and, after the push, of the second-level page, so the transition is continuous. Keys: `
- L77 `class CYLSearchDiscoverHomeFragment : CYLExamplePage()` — The Discover tab's first-level page: the whole Discover bar in the navigation bar (the reference recording); a tap pushes `CYLSearchDiscoverFragment` (recent and popular tag lists) with the back button sliding in.

## `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSuggestionStyleFragment.kt`

The suggestion demo of MaterialSearchView's Default sample in one suggestion style (docs/tag-view-suggestions.md): the "List style" tab shows the suggestions as a list, the "Tag style" tab the same suggestions as tags (CollectionViewClassifyMenu's `CYLTagListView`). The page only passes the data and the style to `CYLSearchView`.

- L23 `class CYLSuggestionStyleFragment : CYLExamplePage(), CYLSearchViewDelegate` — The suggestion demo of MaterialSearchView's Default sample in one suggestion style (docs/tag-view-suggestions.md): the "List style" tab shows the suggestions as a list, the "Tag style" tab the same suggestions as tags (CollectionViewClassifyMenu's `CYLTagListV

## `android/merged/app/src/main/kotlin/com/cyl/search/example/MainActivity.kt`

The example app (iOS `CYLSearchExampleAppDelegate`): a `CYLTabBarController` created from `assets/CYLTabBarConfiguration.json`, with a raised plus button, and pages found by page ID in `CYLTabBarPageRegistry`.

- L15 `class MainActivity : AppCompatActivity()` — The example app (iOS `CYLSearchExampleAppDelegate`): a `CYLTabBarController` created from `assets/CYLTabBarConfiguration.json`, with a raised plus button, and pages found by page ID in `CYLTabBarPageRegistry`.

## `android/merged/sample-materialsearchview/build.gradle.kts`

The MaterialSearchView sample translated to Kotlin: its activities, opened from the example's MaterialSearchView tab.

## `android/merged/sample-materialsearchview/src/main/AndroidManifest.xml`

Merged module manifest (the upstream manifest sets a package attribute, which AGP 8 rejects).

## `android/merged/sample-multisearchview/build.gradle.kts`

The MultiSearchView sample (Kotlin, Apache 2.0): android/iammert-MultiSearchView/app.

## `android/merged/sample-reveal/build.gradle.kts`

An independent implementation of android-cjj/MaterialSearchView's sample behavior (that project has no license).

## `android/merged/sample-reveal/src/main/AndroidManifest.xml`

Merged module manifest (the upstream manifest sets a package attribute, which AGP 8 rejects).

## `android/merged/sample-yechaoa/build.gradle.kts`

The search screen of yechaoa/MaterialDesign (Kotlin, Apache 2.0).

## `android/merged/sample-yechaoa/src/main/AndroidManifest.xml`

Merged module manifest (the upstream manifest sets a package attribute, which AGP 8 rejects).

## `android/merged/search-lapism/build.gradle.kts`

lapism/search (Kotlin, Apache 2.0): the sources in android/lapism-search, built as a library module.

## `android/merged/search-lapism/src/main/AndroidManifest.xml`

Merged module manifest (the upstream manifest sets a package attribute, which AGP 8 rejects).

## `android/merged/search-materialsearchview/build.gradle.kts`

MiguelCatalan/MaterialSearchView translated to Kotlin (Apache 2.0): the sources in android/MiguelCatalan-MaterialSearchView/library.

## `android/merged/search-materialsearchview/src/main/AndroidManifest.xml`

Merged module manifest (the upstream manifest sets a package attribute, which AGP 8 rejects).

## `android/merged/search-multisearchview/build.gradle.kts`

iammert/MultiSearchView (Kotlin, Apache 2.0): the sources in android/iammert-MultiSearchView/multisearchviewlib.

## `android/merged/search-multisearchview/src/main/AndroidManifest.xml`

Merged module manifest (the upstream manifest sets a package attribute, which AGP 8 rejects).

## `android/merged/settings.gradle.kts`

The merged Android project of CYLSearchViewController (docs/android-and-cross-platform.md): the five search projects translated in ../, the CYL search API that matches iOS, and one example app with CYLTabBarController's tab bar.
