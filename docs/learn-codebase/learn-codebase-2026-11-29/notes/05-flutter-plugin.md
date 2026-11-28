> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# Flutter plugin: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

7/7 chunks read. Dart widgets (cyl_search_view.dart, cyl_search_list_view.dart) -> platform views over native cores, channel cyl_search/view_<id>; Kotlin+Swift bridges. Findings (code read, not run): iOS CYLFlutterTagListContainer ignores tagSubtitles and titleMaxLines (Android applies them) - 2026-11-27 finding reconfirmed for Flutter; iOS bar bridge applies text only when non-empty so Dart cannot clear it with "" (Android bridge can); Dart sends no searchButtonImage (only iOS bridge reads it); cylFlutterAssetImage inserted between cylFoldControl doc and func; next=06-rn-library

## Files read (11)

- `CrossPlatform/flutter_cylsearch/analysis_options.yaml` (14)
- `CrossPlatform/flutter_cylsearch/android/build.gradle.kts` (87)
- `CrossPlatform/flutter_cylsearch/android/settings.gradle.kts` (1)
- `CrossPlatform/flutter_cylsearch/android/src/main/AndroidManifest.xml` (3)
- `CrossPlatform/flutter_cylsearch/android/src/main/kotlin/com/cyl/search/flutter_cylsearch/FlutterCylsearchPlugin.kt` (871)
- `CrossPlatform/flutter_cylsearch/ios/flutter_cylsearch.podspec` (27)
- `CrossPlatform/flutter_cylsearch/ios/flutter_cylsearch/Sources/flutter_cylsearch/FlutterCylsearchPlugin.swift` (1114)
- `CrossPlatform/flutter_cylsearch/lib/flutter_cylsearch.dart` (8)
- `CrossPlatform/flutter_cylsearch/lib/src/cyl_search_list_view.dart` (149)
- `CrossPlatform/flutter_cylsearch/lib/src/cyl_search_view.dart` (1588)
- `CrossPlatform/flutter_cylsearch/pubspec.yaml` (72)

Declarations with line numbers: [../reference/05-flutter-plugin.md](../reference/05-flutter-plugin.md)
