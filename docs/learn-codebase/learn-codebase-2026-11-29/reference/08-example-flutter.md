> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Script-generated index of declarations, comments and test names; comments are quoted, not verified.

# Flutter example: files and declarations

> **Generated mechanically** (regex extraction) from the source text read in the 2026-11-29 learn-codebase pass: HEAD `ad32984` plus the uncommitted working-tree changes. It is an index, not a review: a regex can miss or mis-pick a declaration, and "doc" is the comment found above it. Every line number was matched against the working tree with `git grep` on 2026-11-29. A declaration the regex missed is simply absent. Check the file before relying on a line.

| File | Lines |
|:---|---:|
| `CrossPlatform/flutter_cylsearch/example/analysis_options.yaml` | 34 |
| `CrossPlatform/flutter_cylsearch/example/android/app/build.gradle.kts` | 86 |
| `CrossPlatform/flutter_cylsearch/example/android/app/src/debug/AndroidManifest.xml` | 7 |
| `CrossPlatform/flutter_cylsearch/example/android/app/src/main/AndroidManifest.xml` | 48 |
| `CrossPlatform/flutter_cylsearch/example/android/app/src/main/kotlin/com/cyl/search/flutter_cylsearch_example/MainActivity.kt` | 8 |
| `CrossPlatform/flutter_cylsearch/example/android/app/src/profile/AndroidManifest.xml` | 7 |
| `CrossPlatform/flutter_cylsearch/example/android/build.gradle.kts` | 26 |
| `CrossPlatform/flutter_cylsearch/example/android/gradle.properties` | 6 |
| `CrossPlatform/flutter_cylsearch/example/android/settings.gradle.kts` | 38 |
| `CrossPlatform/flutter_cylsearch/example/ios/Podfile` | 62 |
| `CrossPlatform/flutter_cylsearch/example/ios/Runner/AppDelegate.swift` | 16 |
| `CrossPlatform/flutter_cylsearch/example/ios/Runner/Runner-Bridging-Header.h` | 1 |
| `CrossPlatform/flutter_cylsearch/example/ios/Runner/SceneDelegate.swift` | 6 |
| `CrossPlatform/flutter_cylsearch/example/lib/contact_tags_data.dart` | 450 |
| `CrossPlatform/flutter_cylsearch/example/lib/contact_tags_page.dart` | 726 |
| `CrossPlatform/flutter_cylsearch/example/lib/discover_page.dart` | 380 |
| `CrossPlatform/flutter_cylsearch/example/lib/example_texts.dart` | 109 |
| `CrossPlatform/flutter_cylsearch/example/lib/main.dart` | 503 |
| `CrossPlatform/flutter_cylsearch/example/lib/qmui_search_bar_styles_page.dart` | 149 |
| `CrossPlatform/flutter_cylsearch/example/lib/qmui_search_controller_page.dart` | 79 |
| `CrossPlatform/flutter_cylsearch/example/lib/qmui_short_list_page.dart` | 19 |
| `CrossPlatform/flutter_cylsearch/example/lib/qmui_strings.dart` | 112 |
| `CrossPlatform/flutter_cylsearch/example/lib/tab_search_bar.dart` | 89 |
| `CrossPlatform/flutter_cylsearch/example/pubspec.yaml` | 102 |
| `CrossPlatform/flutter_cylsearch/example/tool/render_tab_icons.swift` | 35 |

## `CrossPlatform/flutter_cylsearch/example/analysis_options.yaml`

This file configures the analyzer, which statically analyzes Dart code to check for errors, warnings, and lints. The issues identified by the analyzer are surfaced in the UI of Dart-enabled IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be invoked from the command line by running `flutter analyze`. The following line activates a set of recommended lints for Flutter apps, pac

## `CrossPlatform/flutter_cylsearch/example/android/app/src/main/kotlin/com/cyl/search/flutter_cylsearch_example/MainActivity.kt`

A FlutterFragmentActivity: CYLTabBarController's Flutter tab bar needs a FragmentActivity on Android.

- L8 `class MainActivity : FlutterFragmentActivity()` — A FlutterFragmentActivity: CYLTabBarController's Flutter tab bar needs a FragmentActivity on Android.

## `CrossPlatform/flutter_cylsearch/example/ios/Podfile`

The iOS example of flutter_cylsearch. CYLSearchViewController comes from this repository (the local pod), and its sub-repositories are pinned by commit as in the repository's Podfile (AGENTS.md, "Sub-repositories").

## `CrossPlatform/flutter_cylsearch/example/ios/Runner/SceneDelegate.swift`

- L4 `class SceneDelegate: FlutterSceneDelegate`

## `CrossPlatform/flutter_cylsearch/example/lib/contact_tags_data.dart`

Generated from CYLSearchExample/CYLContactTags.bundle/en.lproj (contact-tags.json and CYLContactTags.strings), as the React Native example's contact-tags.json. Do not edit. The contact tags demo's strings and data, as JSON.

## `CrossPlatform/flutter_cylsearch/example/lib/contact_tags_page.dart`

The contact tags demo (iOS CYLContactRemarkViewController, CYLContactTagEditorViewController, CYLContactListViewController): Edit Remarks, Edit Tags with this library's search bar and CollectionViewClassifyMenu's tag lists (ids, selection, Manage with crosses and renaming in the editing bar, Recent's clear button, folding), the contacts of a tag, CYLTableViewPlaceHolder's placeholders, and a simul

- L30 `class CYLContactTag` — A tag: a stable id and a title.
- L48 `class CYLContact` — A contact and the ids of its tags.
- L60 `class CYLContactTagStore` — The user's tags (iOS CYLContactTagStore), keyed by id.
- L180 `class CYLContactRemarkPage extends StatefulWidget` — Edit Remarks, the first page of the contact tags demo.
- L290 `class CYLContactTagEditorPage extends StatefulWidget` — Edit Tags: the search bar, Recent, My Tags (Manage), the editing bar and the simulated server.
- L680 `class CYLContactListPage extends StatelessWidget` — The contacts of a tag.

## `CrossPlatform/flutter_cylsearch/example/lib/discover_page.dart`

One discover topic of search-discover.json.

- L10 `class CYLDiscoverTopic` — One discover topic of search-discover.json.
- L23 `class CYLSearchDiscoverData` — The data of the discover demo: the same files as the iOS and Android examples (CYLSearchDiscover.bundle, copied from CollectionViewClassifyMenu), one folder per language under assets/discover/.
- L106 `class CYLSearchDiscoverEntryPage extends StatefulWidget` — The entry of the Discover tab: a one-row page that opens the Discover page, so the Discover page is always a second-level page and its navigation bar always has a back button on the left (owner's rule for every example). The first time it shows it opens the Di
- L169 `class CYLSearchDiscoverPage extends StatefulWidget` — The discover demo (iOS `CYLSearchDiscoverViewController`, Android `CYLSearchDiscoverFragment`): the native search bar, the recent searches as CollectionViewClassifyMenu tags, and discover topics in two columns.

## `CrossPlatform/flutter_cylsearch/example/lib/example_texts.dart`

The example's own texts (tab titles, tab descriptions, demo buttons) in en, ja, zh-Hans and zh-Hant: the same values as the React Native example's search-discover.json (docs/instructions/accessibility-i18n.md). Generated by hand from it; keep equal.

## `CrossPlatform/flutter_cylsearch/example/lib/main.dart`

- L59 `class CYLSearchDemo` — One search page demo: how the native search page is configured.
- L104 `class CYLSearchDemoTab` — A tab of search page demos.
- L144 `class CYLSearchExampleApp extends StatelessWidget` — The example app of flutter_cylsearch: CYLTabBarController's Flutter tab bar, a tab per kind of demo (the last one is the discover page), and the search bar demo on the raised plus button's page.
- L211 `class CYLSearchTabs extends StatefulWidget` — The tab bar and the page of the selected tab.
- L268 `class CYLSearchDemoPage extends StatelessWidget` — A tab: its description and one button per demo, each opening the native search page as a full screen route.
- L371 `class CYLSearchResultsDemoPage extends StatefulWidget` — The results demo: the native search page lists the sample suggestions that contain the query as results (iOS and Android `resultsDataSource`), and a pull on the results refreshes them (`refreshHandler`, ended with `endRefreshing()`).
- L420 `class CYLSearchBarDemoPage extends StatefulWidget` — The plus button's page: the native search bar inline, its text and search shown below.

## `CrossPlatform/flutter_cylsearch/example/lib/qmui_search_bar_styles_page.dart`

The "Search bar styles" screen: a replica of QMUI's QDSearchBarViewController. The bar is the list's first item; the sections Placeholder, Layout and AccessoryView drive it.

- L10 `class CYLQMUISearchBarStylesPage extends StatefulWidget` — The "Search bar styles" screen: a replica of QMUI's QDSearchBarViewController. The bar is the list's first item; the sections Placeholder, Layout and AccessoryView drive it.

## `CrossPlatform/flutter_cylsearch/example/lib/qmui_search_controller_page.dart`

The ten keywords of QMUI's QDSearchViewController.

- L24 `class CYLQMUISearchControllerPage extends StatelessWidget` — The "Search controller" screen: a replica of QMUI's QDSearchViewController. A list of ten keywords whose first item is a search bar; a tap on it opens the search page ([CYLSearchView]), configured through the core's API only: its launch area (the eight suggest
- L48 `class CYLQMUISearchPage extends StatefulWidget` — The search page of the "Search controller" screen.

## `CrossPlatform/flutter_cylsearch/example/lib/qmui_short_list_page.dart`

The "Short list" screen (QMUI issue #1160): three rows under a search bar. The bar scrolls out of sight with a drag and settles fully shown or fully hidden, although the list is shorter than the screen.

- L6 `class CYLQMUIShortListPage extends StatelessWidget` — The "Short list" screen (QMUI issue #1160): three rows under a search bar. The bar scrolls out of sight with a drag and settles fully shown or fully hidden, although the list is shorter than the screen.

## `CrossPlatform/flutter_cylsearch/example/lib/qmui_strings.dart`

The texts of the two QMUI replica screens, in the languages the iOS example has (en, ja, zh-Hans, zh-Hant): copied from the core's string table (Resources/CYLSearchViewController.bundle), `%s` is the iOS `%@`.

## `CrossPlatform/flutter_cylsearch/example/lib/tab_search_bar.dart`

The look of the search bar of one tab: every tab root owns its bar, in its own style (CYLTabBarController owns the tabs).

- L8 `class CYLTabBarLook` — The look of the search bar of one tab: every tab root owns its bar, in its own style (CYLTabBarController owns the tabs).

## `CrossPlatform/flutter_cylsearch/example/tool/render_tab_icons.swift`

Renders the example's tab icons from SF Symbols into assets/ as Flutter resolution variants (assets/x.png at 1x, assets/2.0x/x.png, assets/3.0x/x.png), so iOS and Android draw them at their point size: swift tool/render_tab_icons.swift
