> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# Flutter example: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

5/5 chunks read. Example localizes discover/QMUI/tab texts (en, ja, zh-Hans, zh-Hant) but hard-codes English: Search placeholders, "Short list" label and title, "Row N", "Multiple searches", "Category", "New search"/"Complete"/Add, "Streamer, room ID or song", "Camera", "Query:"/"Result" snackbars. Discover entry page passes tagSubtitles (ignored by Flutter iOS bridge). Contact "+ New Tag" opens Manage with editing bar (differs from iOS alert, documented in comment). example pins flutter_cyltabbar 08343e9f. next=08-example-mp

## Files read (25)

- `CrossPlatform/flutter_cylsearch/example/analysis_options.yaml` (34)
- `CrossPlatform/flutter_cylsearch/example/android/app/build.gradle.kts` (86)
- `CrossPlatform/flutter_cylsearch/example/android/app/src/debug/AndroidManifest.xml` (7)
- `CrossPlatform/flutter_cylsearch/example/android/app/src/main/AndroidManifest.xml` (48)
- `CrossPlatform/flutter_cylsearch/example/android/app/src/main/kotlin/com/cyl/search/flutter_cylsearch_example/MainActivity.kt` (8)
- `CrossPlatform/flutter_cylsearch/example/android/app/src/profile/AndroidManifest.xml` (7)
- `CrossPlatform/flutter_cylsearch/example/android/build.gradle.kts` (26)
- `CrossPlatform/flutter_cylsearch/example/android/gradle.properties` (6)
- `CrossPlatform/flutter_cylsearch/example/android/settings.gradle.kts` (38)
- `CrossPlatform/flutter_cylsearch/example/ios/Podfile` (62)
- `CrossPlatform/flutter_cylsearch/example/ios/Runner/AppDelegate.swift` (16)
- `CrossPlatform/flutter_cylsearch/example/ios/Runner/Runner-Bridging-Header.h` (1)
- `CrossPlatform/flutter_cylsearch/example/ios/Runner/SceneDelegate.swift` (6)
- `CrossPlatform/flutter_cylsearch/example/lib/contact_tags_data.dart` (450)
- `CrossPlatform/flutter_cylsearch/example/lib/contact_tags_page.dart` (726)
- `CrossPlatform/flutter_cylsearch/example/lib/discover_page.dart` (380)
- `CrossPlatform/flutter_cylsearch/example/lib/example_texts.dart` (109)
- `CrossPlatform/flutter_cylsearch/example/lib/main.dart` (503)
- `CrossPlatform/flutter_cylsearch/example/lib/qmui_search_bar_styles_page.dart` (149)
- `CrossPlatform/flutter_cylsearch/example/lib/qmui_search_controller_page.dart` (79)
- `CrossPlatform/flutter_cylsearch/example/lib/qmui_short_list_page.dart` (19)
- `CrossPlatform/flutter_cylsearch/example/lib/qmui_strings.dart` (112)
- `CrossPlatform/flutter_cylsearch/example/lib/tab_search_bar.dart` (89)
- `CrossPlatform/flutter_cylsearch/example/pubspec.yaml` (102)
- `CrossPlatform/flutter_cylsearch/example/tool/render_tab_icons.swift` (35)

Declarations with line numbers: [../reference/08-example-flutter.md](../reference/08-example-flutter.md)
