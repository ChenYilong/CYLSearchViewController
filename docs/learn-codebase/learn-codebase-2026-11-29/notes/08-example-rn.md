> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# React Native example: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

4/4 chunks read. Code-read findings: App.tsx DiscoverEntry tag has onTagSelect={() => undefined} (tap does nothing; iOS/Flutter open Discover); comments on the iOS, Flutter and RN entry pages say the first appearance opens Discover at once but no such code was seen; ContactTagsDemo Edit Remarks Done is a plain Text (inert); many hard-coded English strings (SearchBarStylesDemo, SearchControllerDemo entirely, Search placeholders, Back label, bar demo, "Searching:"); tagSubtitles used (ignored by RN iOS). next=09-tests

## Files read (24)

- `CrossPlatform/react-native-cylsearch/.yarnrc.yml` (4)
- `CrossPlatform/react-native-cylsearch/example/android/app/build.gradle` (132)
- `CrossPlatform/react-native-cylsearch/example/android/app/src/main/AndroidManifest.xml` (30)
- `CrossPlatform/react-native-cylsearch/example/android/app/src/main/java/cylsearch/example/MainActivity.kt` (22)
- `CrossPlatform/react-native-cylsearch/example/android/app/src/main/java/cylsearch/example/MainApplication.kt` (27)
- `CrossPlatform/react-native-cylsearch/example/android/build.gradle` (31)
- `CrossPlatform/react-native-cylsearch/example/android/gradle.properties` (48)
- `CrossPlatform/react-native-cylsearch/example/android/settings.gradle` (23)
- `CrossPlatform/react-native-cylsearch/example/app.json` (4)
- `CrossPlatform/react-native-cylsearch/example/babel.config.js` (12)
- `CrossPlatform/react-native-cylsearch/example/Gemfile` (17)
- `CrossPlatform/react-native-cylsearch/example/index.js` (11)
- `CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample/AppDelegate.swift` (11)
- `CrossPlatform/react-native-cylsearch/example/ios/CylsearchExample/SceneDelegate.swift` (56)
- `CrossPlatform/react-native-cylsearch/example/ios/Podfile` (67)
- `CrossPlatform/react-native-cylsearch/example/jest.config.js` (3)
- `CrossPlatform/react-native-cylsearch/example/metro.config.js` (30)
- `CrossPlatform/react-native-cylsearch/example/package.json` (43)
- `CrossPlatform/react-native-cylsearch/example/react-native.config.js` (21)
- `CrossPlatform/react-native-cylsearch/example/src/App.tsx` (595)
- `CrossPlatform/react-native-cylsearch/example/src/ContactTagsDemo.tsx` (352)
- `CrossPlatform/react-native-cylsearch/example/src/SearchBarStylesDemo.tsx` (201)
- `CrossPlatform/react-native-cylsearch/example/src/SearchControllerDemo.tsx` (123)
- `CrossPlatform/react-native-cylsearch/example/vite.config.mjs` (17)

Declarations with line numbers: [../reference/08-example-rn.md](../reference/08-example-rn.md)
