# Open Issues of the Translated Android Projects

The open issues of the projects translated into `android/` (`AGENTS.md`, "Open pull requests and issues of projects
we translate"). Read on 2026-11-12. lapism/search has no open issues. Status: `TODO` until handled; `DONE` with the
commit when fixed in our code; `N/A` with the reason when it does not apply to our code.

Score = (`DONE` + `N/A`) / all issues × 100.

## Score

| Date | Handled | All | Score |
|:---|---:|---:|---:|
| 2026-11-12 (listed) | 0 | 166 | 0 |
| 2026-11-12 (fixes in `android/`) | 164 (101 DONE, 63 N/A) | 166 | 98 |
| 2026-11-12 (verified in `android/merged`) | 166 (103 DONE, 63 N/A) | 166 | 100 |


## MiguelCatalan/MaterialSearchView (146 open)

| Issue | Description | Status |
|:---|:---|:---|
| [#257](https://github.com/MiguelCatalan/MaterialSearchView/issues/257) | lib not work in new version Gradle? | N/A: about the upstream Maven artifact (jcenter / Gradle versions); our copy is source code built in `android/merged` |
| [#256](https://github.com/MiguelCatalan/MaterialSearchView/issues/256) | Failed to resolve: com.miguelcatalan:materialsearchview:1.4.0 | N/A: about the upstream Maven artifact (jcenter / Gradle versions); our copy is source code built in `android/merged` |
| [#255](https://github.com/MiguelCatalan/MaterialSearchView/issues/255) | The plug in is not supported now | N/A: about the upstream Maven artifact (jcenter / Gradle versions); our copy is source code built in `android/merged` |
| [#253](https://github.com/MiguelCatalan/MaterialSearchView/issues/253) | Bug | N/A: a crash of another app starting a CREATE_SHORTCUT intent, not this library |
| [#252](https://github.com/MiguelCatalan/MaterialSearchView/issues/252) | textAlignment and gravity does not work | DONE: start / end layout for right-to-left text, `setTextGravity`, `setTypeface` |
| [#250](https://github.com/MiguelCatalan/MaterialSearchView/issues/250) | Distinction of accents in searches | DONE: `setIgnoreAccents(true)` |
| [#249](https://github.com/MiguelCatalan/MaterialSearchView/issues/249) | Crash android.content.res.Resources$NotFoundException: Unable to find resource ID #0x7f0800d4 | N/A: a missing resource in some installs of the upstream 1.4.0 artifact; our resources are compiled into the app |
| [#248](https://github.com/MiguelCatalan/MaterialSearchView/issues/248) | App crashing sometimes, findViewById(R.id.search_layout) returning null | DONE: views are looked up in the inflated layout only |
| [#246](https://github.com/MiguelCatalan/MaterialSearchView/issues/246) | Issue while using MaterialSearchView inside a Fragment Activity | N/A: a usage or layout question about the app, no defect in the library |
| [#244](https://github.com/MiguelCatalan/MaterialSearchView/issues/244) | character limit of search text | DONE: `setMaxLength` |
| [#243](https://github.com/MiguelCatalan/MaterialSearchView/issues/243) | Remove left space within toolbar | N/A: the left space is the app Toolbar's content inset |
| [#242](https://github.com/MiguelCatalan/MaterialSearchView/issues/242) | Add support for custom filtering | DONE: `setSuggestionFilter` |
| [#239](https://github.com/MiguelCatalan/MaterialSearchView/issues/239) | How can i hide/remove the menu Item on a specific Fragment or UI ? | N/A: a usage or layout question about the app, no defect in the library |
| [#238](https://github.com/MiguelCatalan/MaterialSearchView/issues/238) | collapsing toolbar not working with ImageView | N/A: a usage or layout question about the app, no defect in the library |
| [#237](https://github.com/MiguelCatalan/MaterialSearchView/issues/237) | SearchViewListener wrong state in the callbacks | DONE: the open state is set before the callbacks |
| [#236](https://github.com/MiguelCatalan/MaterialSearchView/issues/236) | How to change SearchView text size? | DONE: `setTextSize` |
| [#235](https://github.com/MiguelCatalan/MaterialSearchView/issues/235) | AutoComplete Suggestion List | N/A: nested groups need an ExpandableListView; `setAdapter` takes any ListAdapter |
| [#234](https://github.com/MiguelCatalan/MaterialSearchView/issues/234) | Open search when activity opens | DONE: `showSearch()` from code, `setShowKeyboardOnOpen` |
| [#233](https://github.com/MiguelCatalan/MaterialSearchView/issues/233) | Attempt to invoke virtual method 'java.lang.String java.lang.String.toLowerCase()' on a null object reference | DONE: null suggestions are skipped |
| [#232](https://github.com/MiguelCatalan/MaterialSearchView/issues/232) | duplicate value for resources | N/A: our attrs declare no `layout_anchorGravity` |
| [#230](https://github.com/MiguelCatalan/MaterialSearchView/issues/230) | Query : How to add additional menu item when the search view is expanded? | N/A: a usage or layout question about the app, no defect in the library |
| [#227](https://github.com/MiguelCatalan/MaterialSearchView/issues/227) | SearchView not working in Androidx | DONE: the translation uses AndroidX |
| [#226](https://github.com/MiguelCatalan/MaterialSearchView/issues/226) | Return item click in list of suggestions | DONE: `setOnItemClickListener` keeps working with built-in suggestions (fix of #50) |
| [#225](https://github.com/MiguelCatalan/MaterialSearchView/issues/225) | MaterialSearchView on Navigation Drawer Activity | N/A: a usage or layout question about the app, no defect in the library |
| [#224](https://github.com/MiguelCatalan/MaterialSearchView/issues/224) | All com.android.support libraries must use the exact same version specification (mixing versions can lead to runtime crashes). Found versions 27.1.1, 23.1.1. Examples include com.android.support:animated-vector-drawable:27.1.1 and com.android.support:design:23.1.1 less... (Ctrl+F1)  There are some combinations of libraries, or tools and libraries, that are incompatible, or can lead to bugs. One such incompatibility is compiling with a version of the Android support libraries that is not the latest version (or in particular, a version lower than your targetSdkVersion).  Issue id: GradleCompatible | DONE: AndroidX only, no support library |
| [#223](https://github.com/MiguelCatalan/MaterialSearchView/issues/223) | Documentation for Custom Adapter implementation | N/A: documentation of the upstream README; `setAdapter` is listed in `docs/android-and-cross-platform.md` |
| [#221](https://github.com/MiguelCatalan/MaterialSearchView/issues/221) | Show Material Search View Without set menu items | DONE: `showSearch()` works without a menu item |
| [#219](https://github.com/MiguelCatalan/MaterialSearchView/issues/219) | Default open search | DONE: `showSearch()` from code |
| [#217](https://github.com/MiguelCatalan/MaterialSearchView/issues/217) | gray layer not appear | DONE: `setDimBackground(true)` |
| [#216](https://github.com/MiguelCatalan/MaterialSearchView/issues/216) | Left search icon? | N/A: the position of the menu item is the app's toolbar menu |
| [#214](https://github.com/MiguelCatalan/MaterialSearchView/issues/214) | EditText in SearchView loses focus | DONE: focus and keyboard come back after a rotation |
| [#213](https://github.com/MiguelCatalan/MaterialSearchView/issues/213) | voice search not working | DONE: `isVoiceAvailable()` fixed (merged PRs #66 / #105 / #146 / #159) |
| [#212](https://github.com/MiguelCatalan/MaterialSearchView/issues/212) | How to set custom location of the Menu Item? | DONE: the reveal starts from the menu item (fix of #57) |
| [#210](https://github.com/MiguelCatalan/MaterialSearchView/issues/210) | Custom fonts | DONE: `setTypeface` |
| [#208](https://github.com/MiguelCatalan/MaterialSearchView/issues/208) | How can I disable visibility of voice search icon ? | DONE: `setVoiceSearch(false)` / `showVoice(false)` |
| [#207](https://github.com/MiguelCatalan/MaterialSearchView/issues/207) | InflateException | N/A: ClassNotFoundException, the dependency was not packaged in that app |
| [#206](https://github.com/MiguelCatalan/MaterialSearchView/issues/206) | Some problem about this SearchView | DONE: closing uses INVISIBLE, like the initial state |
| [#205](https://github.com/MiguelCatalan/MaterialSearchView/issues/205) | How To Get The Current Text ? | DONE: `getQuery()` |
| [#204](https://github.com/MiguelCatalan/MaterialSearchView/issues/204) | Inflate exception when override background in app theme | DONE: `setBackground` during inflation no longer crashes |
| [#203](https://github.com/MiguelCatalan/MaterialSearchView/issues/203) | adding the searchView as an actionViewClass inside a menu file | N/A: the view is not designed as a menu action view |
| [#202](https://github.com/MiguelCatalan/MaterialSearchView/issues/202) | Gradle not build | N/A: an antivirus false positive |
| [#198](https://github.com/MiguelCatalan/MaterialSearchView/issues/198) | Delay on performFiltering | DONE: `setFilterDelay` |
| [#197](https://github.com/MiguelCatalan/MaterialSearchView/issues/197) | How to show material searchview in actionbar | N/A: a usage or layout question about the app, no defect in the library |
| [#196](https://github.com/MiguelCatalan/MaterialSearchView/issues/196) | show all suggestions list at once | DONE: `setSuggestionFilter { _, _ -> true }` or `setSuggestionsWithDefault` |
| [#194](https://github.com/MiguelCatalan/MaterialSearchView/issues/194) | Suggestions Not Showing | DONE: the suggestion list has a fixed height instead of `wrap_content`, rows carry their own background (`search_view.xml`, `suggest_item.xml`) |
| [#193](https://github.com/MiguelCatalan/MaterialSearchView/issues/193) | Layout flash when closeSearch() ,windowSoftInputMode is adjustPan | N/A: the app's `windowSoftInputMode` |
| [#192](https://github.com/MiguelCatalan/MaterialSearchView/issues/192) | Search Suggestion Limit | DONE: the suggestion list has a fixed height instead of `wrap_content`, rows carry their own background (`search_view.xml`, `suggest_item.xml`) |
| [#191](https://github.com/MiguelCatalan/MaterialSearchView/issues/191) | does no show in my layout | N/A: a usage or layout question about the app, no defect in the library |
| [#189](https://github.com/MiguelCatalan/MaterialSearchView/issues/189) | isVoiceAvailable fix | DONE: `isVoiceAvailable()` fixed (merged PRs #66 / #105 / #146 / #159) |
| [#188](https://github.com/MiguelCatalan/MaterialSearchView/issues/188) | toolbar is not hidden with coordinatorlayout. | N/A: a usage or layout question about the app, no defect in the library |
| [#187](https://github.com/MiguelCatalan/MaterialSearchView/issues/187) | Change suggestion line height | DONE: `setSuggestionMinHeight` |
| [#186](https://github.com/MiguelCatalan/MaterialSearchView/issues/186) | Bacground dim is not set | DONE: `setDimBackground(true)` |
| [#185](https://github.com/MiguelCatalan/MaterialSearchView/issues/185) | How can i detect back icon if pressed? | DONE: `setOnBackIconClickListener` |
| [#183](https://github.com/MiguelCatalan/MaterialSearchView/issues/183) | Broken link from README.MD | N/A: a broken link in the upstream README |
| [#181](https://github.com/MiguelCatalan/MaterialSearchView/issues/181) | searchView.setOnItemClickListener dosen't work | DONE: fix of #50 |
| [#180](https://github.com/MiguelCatalan/MaterialSearchView/issues/180) | Null Pointer Exception:  Attempt to invoke virtual method 'void com.miguelcatalan.materialsearchview.MaterialSearchView.setOnSearchViewListener(com.miguelcatalan.materialsearchview.MaterialSearchView$SearchViewListener)' on a null object reference | N/A: a NullPointerException in the app's own code |
| [#179](https://github.com/MiguelCatalan/MaterialSearchView/issues/179) | when I install google voice search app my voice icon disapear. why? | DONE: `isVoiceAvailable()` fixed (merged PRs #66 / #105 / #146 / #159) |
| [#178](https://github.com/MiguelCatalan/MaterialSearchView/issues/178) | Not showing toolbar | N/A: a usage or layout question about the app, no defect in the library |
| [#175](https://github.com/MiguelCatalan/MaterialSearchView/issues/175) | How i can use in Appbar at NavigationDrawer? | N/A: a usage or layout question about the app, no defect in the library |
| [#174](https://github.com/MiguelCatalan/MaterialSearchView/issues/174) | AppBarLayout usage not working | N/A: a usage or layout question about the app, no defect in the library |
| [#171](https://github.com/MiguelCatalan/MaterialSearchView/issues/171) | searchView.setOnsuggestionListener | DONE: fix of #50 |
| [#170](https://github.com/MiguelCatalan/MaterialSearchView/issues/170) | My app happen with some error it throw this exception, could you tell me how? | DONE: the reveal runs only when the bar is attached and laid out |
| [#168](https://github.com/MiguelCatalan/MaterialSearchView/issues/168) | Suggestions still receives onTouch event when dismissed | DONE: dismissed suggestions are GONE and the empty list area closes the search |
| [#167](https://github.com/MiguelCatalan/MaterialSearchView/issues/167) | OOM loading Drawable | N/A: out of memory on one old device loading a small PNG |
| [#166](https://github.com/MiguelCatalan/MaterialSearchView/issues/166) | Handle long click for items? | DONE: `setOnItemLongClickListener` |
| [#165](https://github.com/MiguelCatalan/MaterialSearchView/issues/165) | Suggestion query comparison and history | DONE: `setSuggestionFilter`, `setSuggestions(…, checkWholeString)` |
| [#164](https://github.com/MiguelCatalan/MaterialSearchView/issues/164) | How to get text query? | DONE: `getQuery()` |
| [#162](https://github.com/MiguelCatalan/MaterialSearchView/issues/162) | onQueryTextSubmit not working correctly | N/A: returning true from `onQueryTextSubmit` keeps the search open (documented behavior) |
| [#160](https://github.com/MiguelCatalan/MaterialSearchView/issues/160) | Suggestion list overrides my layout | N/A: a usage or layout question about the app, no defect in the library |
| [#158](https://github.com/MiguelCatalan/MaterialSearchView/issues/158) | I hope to add a list of search record | DONE: recent searches can be listed for an empty query with `setSuggestionsWithDefault` |
| [#157](https://github.com/MiguelCatalan/MaterialSearchView/issues/157) | Demo on TabActivity does not work | DONE: the TabActivity sample runs in `android/merged` (AndroidX layouts, verified on an Android 15 emulator) |
| [#156](https://github.com/MiguelCatalan/MaterialSearchView/issues/156) | Sample not working when imported to android studio | N/A: importing the upstream sample; our Gradle project is `android/merged` |
| [#155](https://github.com/MiguelCatalan/MaterialSearchView/issues/155) | Can I Filter More than 2 Adapters From Fragment ! | N/A: a usage or layout question about the app, no defect in the library |
| [#154](https://github.com/MiguelCatalan/MaterialSearchView/issues/154) | CoordinatorLayout and Suggestions | DONE: the suggestion list has a fixed height instead of `wrap_content`, rows carry their own background (`search_view.xml`, `suggest_item.xml`) |
| [#152](https://github.com/MiguelCatalan/MaterialSearchView/issues/152) | Mistakes in "Using AppBarLayout" Example | N/A: an example in the upstream README |
| [#151](https://github.com/MiguelCatalan/MaterialSearchView/issues/151) | showSearch method is not documented | N/A: upstream documentation; `showSearch` is listed in our docs |
| [#149](https://github.com/MiguelCatalan/MaterialSearchView/issues/149) | Hint size issue | DONE: `setTextSize` |
| [#148](https://github.com/MiguelCatalan/MaterialSearchView/issues/148) | how to show searchview inside toolbar when searchView.openSearch() is triggered ! | N/A: a usage or layout question about the app, no defect in the library |
| [#145](https://github.com/MiguelCatalan/MaterialSearchView/issues/145) | Please remove text length > 0 into onSubmitQuery | DONE: `setAllowEmptyQuery(true)` |
| [#144](https://github.com/MiguelCatalan/MaterialSearchView/issues/144) | Actionbar/toolbar not displayed | N/A: a usage or layout question about the app, no defect in the library |
| [#142](https://github.com/MiguelCatalan/MaterialSearchView/issues/142) | I don't want close search view after submit | DONE: return true from `onQueryTextSubmit` keeps it open |
| [#141](https://github.com/MiguelCatalan/MaterialSearchView/issues/141) | Why my project only show one suggestion? | DONE: the suggestion list has a fixed height instead of `wrap_content`, rows carry their own background (`search_view.xml`, `suggest_item.xml`) |
| [#140](https://github.com/MiguelCatalan/MaterialSearchView/issues/140) | how to to decrease searchview container | N/A: the bar height follows the theme's `actionBarSize` |
| [#139](https://github.com/MiguelCatalan/MaterialSearchView/issues/139) | How do I get rid of overflow i.e. the settings panel at the top right? | N/A: a usage or layout question about the app, no defect in the library |
| [#138](https://github.com/MiguelCatalan/MaterialSearchView/issues/138) | Question: is it possible to enable animation when closing the search? | DONE: `closeSearch(true)` (merged PR #106) |
| [#137](https://github.com/MiguelCatalan/MaterialSearchView/issues/137) | The voice search icon is not displaying for some reason | DONE: `isVoiceAvailable()` fixed (merged PRs #66 / #105 / #146 / #159) |
| [#136](https://github.com/MiguelCatalan/MaterialSearchView/issues/136) | How can I add MaterialSearchView inside a fragment.. | N/A: a usage or layout question about the app, no defect in the library |
| [#133](https://github.com/MiguelCatalan/MaterialSearchView/issues/133) | SuggestionIcon Customization. | DONE: `setSuggestionIcon`, `SuggestionItem` (merged PR #153) |
| [#132](https://github.com/MiguelCatalan/MaterialSearchView/issues/132) | Adding default buttons on material search view. | N/A: extra buttons in the bar need a custom layout |
| [#131](https://github.com/MiguelCatalan/MaterialSearchView/issues/131) | I am getting crashes in multiple devices | N/A: the stack trace stops before the cause |
| [#129](https://github.com/MiguelCatalan/MaterialSearchView/issues/129) | I would like to contribute | N/A: an offer to contribute |
| [#125](https://github.com/MiguelCatalan/MaterialSearchView/issues/125) | Option to set text inside searchview and option to select all text on searchbar click | DONE: `setQuery`, `selectAll()` |
| [#124](https://github.com/MiguelCatalan/MaterialSearchView/issues/124) | listeners are not called | N/A: a usage or layout question about the app, no defect in the library |
| [#123](https://github.com/MiguelCatalan/MaterialSearchView/issues/123) | Prevent keyboard autoshown | DONE: `setShowKeyboardOnOpen(false)` |
| [#122](https://github.com/MiguelCatalan/MaterialSearchView/issues/122) | Request focus when clicking on clear icon | DONE: clearing keeps the focus and the keyboard |
| [#119](https://github.com/MiguelCatalan/MaterialSearchView/issues/119) | Does this support RTL layout\app? | DONE: start / end layout for right-to-left |
| [#118](https://github.com/MiguelCatalan/MaterialSearchView/issues/118) | How can i set text in search view by default | DONE: `setQuery`, `setClearQueryOnClose(false)` |
| [#116](https://github.com/MiguelCatalan/MaterialSearchView/issues/116) | how to implement onTextChanged event? | DONE: `OnQueryTextListener.onQueryTextChange` |
| [#115](https://github.com/MiguelCatalan/MaterialSearchView/issues/115) | can set the searchIcon at the start of the toolbar | N/A: the position of the menu item is the app's toolbar menu |
| [#113](https://github.com/MiguelCatalan/MaterialSearchView/issues/113) | Input Type | DONE: `setInputType` |
| [#111](https://github.com/MiguelCatalan/MaterialSearchView/issues/111) | support vector is not supported | N/A: vector icons are an app choice with AndroidX; the library icons are PNG as upstream |
| [#110](https://github.com/MiguelCatalan/MaterialSearchView/issues/110) | Setting background color causes runtime exception and crashes app | DONE: `setBackground` during inflation no longer crashes |
| [#109](https://github.com/MiguelCatalan/MaterialSearchView/issues/109) | iconifiedByDefault in serachview | N/A: an iconified bar is a different widget |
| [#108](https://github.com/MiguelCatalan/MaterialSearchView/issues/108) | When I set a custom background to the toolbar the search view is not getting revealed | N/A: a usage or layout question about the app, no defect in the library |
| [#107](https://github.com/MiguelCatalan/MaterialSearchView/issues/107) | Not working with collapsing toolbar layout | N/A: a usage or layout question about the app, no defect in the library |
| [#104](https://github.com/MiguelCatalan/MaterialSearchView/issues/104) | Keyboard doesn't show up automatically | DONE: opening shows the keyboard |
| [#102](https://github.com/MiguelCatalan/MaterialSearchView/issues/102) | I want to hide the searchView and suggestions without clearing query and results . what shall I do? | DONE: `setClearQueryOnClose(false)` |
| [#101](https://github.com/MiguelCatalan/MaterialSearchView/issues/101) | The following classes could not be instantiated: | N/A: a layout editor preview message |
| [#100](https://github.com/MiguelCatalan/MaterialSearchView/issues/100) | Text in searchview is not editable and keyboard don't show | DONE: opening shows the keyboard |
| [#98](https://github.com/MiguelCatalan/MaterialSearchView/issues/98) | draw left to right searchView for rtl phones | DONE: start / end layout for right-to-left |
| [#96](https://github.com/MiguelCatalan/MaterialSearchView/issues/96) | SearchView autofocus | DONE: opening focuses the field and shows the keyboard |
| [#95](https://github.com/MiguelCatalan/MaterialSearchView/issues/95) | Reverse reveal animation | DONE: `closeSearch(true)` |
| [#94](https://github.com/MiguelCatalan/MaterialSearchView/issues/94) | i want dispaly full array without filter | DONE: `setSuggestionFilter { _, _ -> true }` |
| [#90](https://github.com/MiguelCatalan/MaterialSearchView/issues/90) | Suggestion list is not scrollable in Co-ordinator layout | DONE: the suggestion list has a fixed height instead of `wrap_content`, rows carry their own background (`search_view.xml`, `suggest_item.xml`) |
| [#89](https://github.com/MiguelCatalan/MaterialSearchView/issues/89) | suggestion in touch | DONE: fix of #50 |
| [#87](https://github.com/MiguelCatalan/MaterialSearchView/issues/87) | Can't completely Hide the toolbar | N/A: a usage or layout question about the app, no defect in the library |
| [#86](https://github.com/MiguelCatalan/MaterialSearchView/issues/86) | Not show searchview when run in Nexus 5X API 22 | N/A: a usage or layout question about the app, no defect in the library |
| [#84](https://github.com/MiguelCatalan/MaterialSearchView/issues/84) | ListView height="wrap_content" causes big performance overhead | DONE: the suggestion list has a fixed height instead of `wrap_content`, rows carry their own background (`search_view.xml`, `suggest_item.xml`) |
| [#82](https://github.com/MiguelCatalan/MaterialSearchView/issues/82) | Keep searchView open in event onQueryTextSubmit | DONE: return true from `onQueryTextSubmit` keeps it open |
| [#80](https://github.com/MiguelCatalan/MaterialSearchView/issues/80) | TintView will not show when customizing suggestion adapter | DONE: a custom adapter shows the tint |
| [#79](https://github.com/MiguelCatalan/MaterialSearchView/issues/79) | How to use in ViewPager? | N/A: a usage or layout question about the app, no defect in the library |
| [#78](https://github.com/MiguelCatalan/MaterialSearchView/issues/78) | SearchVoice button isn't showing up | DONE: `isVoiceAvailable()` fixed (merged PRs #66 / #105 / #146 / #159) |
| [#77](https://github.com/MiguelCatalan/MaterialSearchView/issues/77) | Customizing suggestion | DONE: `SuggestionItem`, `setAdapter` |
| [#76](https://github.com/MiguelCatalan/MaterialSearchView/issues/76) | NullPointerException on inflating activity | DONE: `setBackground` during inflation no longer crashes |
| [#75](https://github.com/MiguelCatalan/MaterialSearchView/issues/75) | How i can clear suggestion | DONE: an empty result clears the list |
| [#74](https://github.com/MiguelCatalan/MaterialSearchView/issues/74) | java.lang.NullPointerException: Attempt to invoke virtual method 'java.lang.String java.lang.String.toLowerCase() | DONE: null suggestions are skipped |
| [#72](https://github.com/MiguelCatalan/MaterialSearchView/issues/72) | Not hiding the toolbar | N/A: a usage or layout question about the app, no defect in the library |
| [#71](https://github.com/MiguelCatalan/MaterialSearchView/issues/71) | onSearchCancel() required! | DONE: `SearchViewListener.onSearchViewCanceled` |
| [#70](https://github.com/MiguelCatalan/MaterialSearchView/issues/70) | Object[] instead of String[] for suggestions & new event on submit | DONE: `SuggestionItem` objects (merged PR #153); submit is `onQueryTextSubmit` |
| [#63](https://github.com/MiguelCatalan/MaterialSearchView/issues/63) | Not show Search voice | DONE: `isVoiceAvailable()` fixed (merged PRs #66 / #105 / #146 / #159) |
| [#62](https://github.com/MiguelCatalan/MaterialSearchView/issues/62) | Request: ability to change hint textSize | DONE: `setTextSize` |
| [#57](https://github.com/MiguelCatalan/MaterialSearchView/issues/57) | Bug: reveal animation doesn't always start from the search menu item | DONE: the reveal starts from the menu item |
| [#56](https://github.com/MiguelCatalan/MaterialSearchView/issues/56) | Request: allow to enable&disable the SearchView EditText, for ActionMode | DONE: `setSearchEnabled` |
| [#50](https://github.com/MiguelCatalan/MaterialSearchView/issues/50) | Bug at setSuggestions method | DONE: the app's item click listener is kept and called after the query is filled |
| [#47](https://github.com/MiguelCatalan/MaterialSearchView/issues/47) | AppBarLayout with suggestion takes up the whole page | DONE: the suggestion list has a fixed height instead of `wrap_content`, rows carry their own background (`search_view.xml`, `suggest_item.xml`) |
| [#42](https://github.com/MiguelCatalan/MaterialSearchView/issues/42) | Request: add prefix for all resources of the library | N/A: renaming the resources would break apps that override them |
| [#41](https://github.com/MiguelCatalan/MaterialSearchView/issues/41) | Request: add "cursor" as an attribute to the MaterialSearchView | DONE: `searchCursorDrawable` attribute |
| [#40](https://github.com/MiguelCatalan/MaterialSearchView/issues/40) | Request: allow customization of what voice button would do | DONE: `setOnVoiceClickListener` |
| [#39](https://github.com/MiguelCatalan/MaterialSearchView/issues/39) | NullPointerException at MaterialSearchView.java:268 | DONE: Kotlin `isVoiceAvailable()` uses the view's context, never null |
| [#37](https://github.com/MiguelCatalan/MaterialSearchView/issues/37) | Integrate with SearchRecentSuggestionsProvider | N/A: an app can feed SearchRecentSuggestionsProvider results through `setSuggestionsWithDefault` |
| [#34](https://github.com/MiguelCatalan/MaterialSearchView/issues/34) | Line below the search view | DONE: `setDividerColor` |
| [#33](https://github.com/MiguelCatalan/MaterialSearchView/issues/33) | Search isn't opening after it has closed | DONE: the open state and visibility stay consistent between closes and opens |
| [#32](https://github.com/MiguelCatalan/MaterialSearchView/issues/32) | Option for suggestion list TextView like SingleLine and ellipsize | DONE: `setEllipsize(true)` |
| [#26](https://github.com/MiguelCatalan/MaterialSearchView/issues/26) | Include custom values for Animation for SearchView | DONE: `setAnimationDuration` applies to the reveal |
| [#20](https://github.com/MiguelCatalan/MaterialSearchView/issues/20) | Allow empty query string | DONE: `setAllowEmptyQuery(true)` |
| [#14](https://github.com/MiguelCatalan/MaterialSearchView/issues/14) | White line at the bottom of MaterialSearchView if set transparent background. (some devices) | DONE: `setDividerColor(Color.TRANSPARENT)` |

## iammert/MultiSearchView (8 open)

| Issue | Description | Status |
|:---|:---|:---|
| [#19](https://github.com/iammert/MultiSearchView/issues/19) | No longer works with Android 12 | DONE: the keyboard uses `showSoftInput` on the field (works on Android 12+) |
| [#18](https://github.com/iammert/MultiSearchView/issues/18) | Getter method for EditText | DONE: `getEditText()` |
| [#14](https://github.com/iammert/MultiSearchView/issues/14) | How to add programatically search placeholders | DONE: `addSearch(text)` |
| [#13](https://github.com/iammert/MultiSearchView/issues/13) | Search Icon Color | DONE: `setSearchIconColor` (merged PR #16) |
| [#10](https://github.com/iammert/MultiSearchView/issues/10) | Inflating Error | DONE: the app module must enable data binding so DataBinderMapperImpl exists (`android/merged/app/build.gradle.kts`); without it inflating fails with NoClassDefFoundError |
| [#7](https://github.com/iammert/MultiSearchView/issues/7) | Random Error - parameter must be a descendant of this view | DONE: a removed tab clears its focus first |
| [#6](https://github.com/iammert/MultiSearchView/issues/6) | how to set "search text" prorgrammatically in searchbar? | DONE: `setSearchText(text)` |
| [#4](https://github.com/iammert/MultiSearchView/issues/4) | Change Cursor color and drawable color isn't working, | DONE: the text style's `android:textCursorDrawable` is applied |

## yechaoa/MaterialDesign (8 open)

| Issue | Description | Status |
|:---|:---|:---|
| [#11](https://github.com/yechaoa/MaterialDesign/issues/11) | FloatView的点击事件 | N/A: concerns a part of the showcase app outside its search screen, which is the only part copied into `android/yechaoa-MaterialDesign` |
| [#10](https://github.com/yechaoa/MaterialDesign/issues/10) | java activity | N/A: asks for Java; this task translates to Kotlin |
| [#9](https://github.com/yechaoa/MaterialDesign/issues/9) | BottomNavigationView使用BadgeDrawable设置maxCharacterCount无效 | N/A: concerns a part of the showcase app outside its search screen, which is the only part copied into `android/yechaoa-MaterialDesign` |
| [#8](https://github.com/yechaoa/MaterialDesign/issues/8) | 还有以前博客中代码的存档吗 | N/A: asks for an archive of old blog code |
| [#7](https://github.com/yechaoa/MaterialDesign/issues/7) | is:issue is:open bottomsheetdialog，正常横竖屏页面可以去掉背景色，但是开启悬浮小窗背景色还有，而且丑 | N/A: concerns a part of the showcase app outside its search screen, which is the only part copied into `android/yechaoa-MaterialDesign` |
| [#5](https://github.com/yechaoa/MaterialDesign/issues/5) | 通过开关的形式来决策是否使用动态颜色 | N/A: concerns a part of the showcase app outside its search screen, which is the only part copied into `android/yechaoa-MaterialDesign` |
| [#4](https://github.com/yechaoa/MaterialDesign/issues/4) | tabLayout字体没有加粗 | N/A: concerns a part of the showcase app outside its search screen, which is the only part copied into `android/yechaoa-MaterialDesign` |
| [#3](https://github.com/yechaoa/MaterialDesign/issues/3) | setClick方法无响应 | N/A: concerns a part of the showcase app outside its search screen, which is the only part copied into `android/yechaoa-MaterialDesign` |

## android-cjj/MaterialSearchView (4 open)

| Issue | Description | Status |
|:---|:---|:---|
| [#4](https://github.com/android-cjj/MaterialSearchView/issues/4) | 程序运行有问题 | DONE: our reimplementation uses readable text colors and reveals the laid-out card |
| [#3](https://github.com/android-cjj/MaterialSearchView/issues/3) | .idea in gitignore | DONE: `android/.gitignore` ignores `.idea` |
| [#2](https://github.com/android-cjj/MaterialSearchView/issues/2) | marshmallow version issue | DONE: same as #4 |
| [#1](https://github.com/android-cjj/MaterialSearchView/issues/1) | Add information about licensing | DONE: `TRANSCRIPTION.md` records that there is no license and the code is an independent implementation |
