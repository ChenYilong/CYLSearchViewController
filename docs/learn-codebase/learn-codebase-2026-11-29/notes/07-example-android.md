> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# Android example: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

8/8 chunks read (app Kotlin pages, contact tags, gradle). Android pins: cyl.tabbar af56db22, classifymenu c0b183de, placeholder f4cf978. Findings (code read): Edit Remarks "Done" menu item has no click listener (enabled after editor result, does nothing); CYLContactTagServer.kt comments mojibake. next=07-example-harmony

## Files read (36)

- `android/merged/app/build.gradle.kts` (65)
- `android/merged/app/src/main/AndroidManifest.xml` (21)
- `android/merged/app/src/main/assets/CYLTabBarConfiguration.json` (48)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagServer.kt` (103)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagsPages.kt` (837)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/contacttags/CYLContactTagStore.kt` (271)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLBackdropPlate.kt` (50)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLExamplePage.kt` (155)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchBarDemoFragment.kt` (66)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchBarStylesFragment.kt` (197)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchControllerDemoFragment.kt` (132)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchDemoMenuFragment.kt` (294)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchDiscoverFragment.kt` (512)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchExampleFragment.kt` (192)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchPortsFragment.kt` (447)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchShortListFragment.kt` (45)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSearchTabBars.kt` (88)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/CYLSuggestionStyleFragment.kt` (91)
- `android/merged/app/src/main/kotlin/com/cyl/search/example/MainActivity.kt` (95)
- `android/merged/build.gradle.kts` (17)
- `android/merged/gradle.properties` (18)
- `android/merged/sample-materialsearchview/build.gradle.kts` (37)
- `android/merged/sample-materialsearchview/src/main/AndroidManifest.xml` (13)
- `android/merged/sample-multisearchview/build.gradle.kts` (40)
- `android/merged/sample-multisearchview/src/main/AndroidManifest.xml` (6)
- `android/merged/sample-reveal/build.gradle.kts` (35)
- `android/merged/sample-reveal/src/main/AndroidManifest.xml` (7)
- `android/merged/sample-yechaoa/build.gradle.kts` (39)
- `android/merged/sample-yechaoa/src/main/AndroidManifest.xml` (7)
- `android/merged/search-lapism/build.gradle.kts` (40)
- `android/merged/search-lapism/src/main/AndroidManifest.xml` (4)
- `android/merged/search-materialsearchview/build.gradle.kts` (35)
- `android/merged/search-materialsearchview/src/main/AndroidManifest.xml` (4)
- `android/merged/search-multisearchview/build.gradle.kts` (41)
- `android/merged/search-multisearchview/src/main/AndroidManifest.xml` (4)
- `android/merged/settings.gradle.kts` (91)

Declarations with line numbers: [../reference/07-example-android.md](../reference/07-example-android.md)
