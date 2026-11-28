> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# React Native library: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

8/8 chunks read. Fabric components (View, Bar, List, TagList, Placeholder): TS specs+index.tsx+CYLSearchProps.ts; Kotlin over cylsearch core; ObjC++ over Swift core. Findings (code read, not run): iOS ignores tagSubtitles, titleMaxLines (tag list) and hidesSearchBarWhenEmptyViewShowing (list) - reconfirmed by git grep, Android handles all three; also check iOS menuDidChangeSmearing etc present; onSelectResult index is first match for duplicate strings on both OSes; Android setColorScheme no-op (documented: DayNight). Empty text/query not applied = documented ("keeps what the person typed"), not a defect. next=07-example-android

## Files read (40)

- `CrossPlatform/react-native-cylsearch/android/build.gradle` (40)
- `CrossPlatform/react-native-cylsearch/android/src/main/AndroidManifest.xml` (2)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchBarView.kt` (365)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchBarViewManager.kt` (199)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchListView.kt` (143)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchListViewManager.kt` (101)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchPlaceholderView.kt` (35)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchPlaceholderViewManager.kt` (44)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchSupport.kt` (171)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchTagListView.kt` (235)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchTagListViewManager.kt` (145)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchView.kt` (156)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchViewManager.kt` (133)
- `CrossPlatform/react-native-cylsearch/android/src/main/java/com/cylsearch/CylsearchViewPackage.kt` (17)
- `CrossPlatform/react-native-cylsearch/babel.config.mjs` (12)
- `CrossPlatform/react-native-cylsearch/Cylsearch.podspec` (26)
- `CrossPlatform/react-native-cylsearch/eslint.config.mjs` (29)
- `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchResults.h` (17)
- `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchResults.mm` (27)
- `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchSupport.h` (131)
- `CrossPlatform/react-native-cylsearch/ios/CYLRNSearchSupport.mm` (36)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchBarView.h` (8)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchBarView.mm` (504)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.h` (8)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchListView.mm` (306)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchPlaceholderView.h` (12)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchPlaceholderView.mm` (133)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchTagListView.h` (8)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchTagListView.mm` (429)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchView.h` (8)
- `CrossPlatform/react-native-cylsearch/ios/CylsearchView.mm` (203)
- `CrossPlatform/react-native-cylsearch/package.json` (203)
- `CrossPlatform/react-native-cylsearch/src/CylsearchBarViewNativeComponent.ts` (268)
- `CrossPlatform/react-native-cylsearch/src/CylsearchListViewNativeComponent.ts` (148)
- `CrossPlatform/react-native-cylsearch/src/CylsearchPlaceholderViewNativeComponent.ts` (22)
- `CrossPlatform/react-native-cylsearch/src/CYLSearchProps.ts` (338)
- `CrossPlatform/react-native-cylsearch/src/CylsearchTagListViewNativeComponent.ts` (177)
- `CrossPlatform/react-native-cylsearch/src/CylsearchViewNativeComponent.ts` (133)
- `CrossPlatform/react-native-cylsearch/src/index.tsx` (443)
- `CrossPlatform/react-native-cylsearch/tsconfig.json` (33)

Declarations with line numbers: [../reference/06-rn-library.md](../reference/06-rn-library.md)
