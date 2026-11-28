> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Summary of the read; treat conclusions as unverified unless 02-findings.md marks them S.

# CYLSearchViewController: architecture

Learned in the 2026-11-29 learn-codebase pass (branch `feat/harmonyos-parity`, HEAD `ad32984`, plus 4 uncommitted modified files). From reading code; nothing was built or run.

## What it is
A search library with one design on six platforms, plus example apps and an iOS reproduction of Issue #1317. The core is called `CYLSearchBar`. "Core" means everything published to a package registry; project rule: fix bugs in the core first.

| Platform | Core | How it is built | Example |
|:---|:---|:---|:---|
| iOS (reference) | `Sources/CYLSearchBar` (Swift) | CocoaPods, `CYLSearchViewController.podspec` 0.1.0, iOS 15 | `CYLSearchExample` |
| Android | `android/merged/cylsearch` (Kotlin) | minSdk 23; modules include :classifymenu, :placeholder, :placeholder-refresh | `android/merged/app` |
| HarmonyOS | `harmonyos/cylsearch` (ArkTS) | HAR; ArkUI V2 (`@ObservedV2` models, `@ComponentV2` drawers) | `harmonyos/entry` |
| WeChat mini program | `CrossPlatform/wechat-miniprogram-cylsearch/src` | pure JS models in `src/core`, drawn by `cyl-*` components | its `example/` |
| Flutter | `CrossPlatform/flutter_cylsearch` | Dart widgets over platform views on the native cores; channel `cyl_search/view_<id>` | its `example/` |
| React Native | `CrossPlatform/react-native-cylsearch` | Fabric components with Kotlin and ObjC++ bridges | its `example/` |

Upstream Android search libraries are ported under `android/` (lapism/search, MiguelCatalan/MaterialSearchView, iammert/MultiSearchView, an independent android-cjj style reveal, yechaoa sample).

## iOS core files (the shape the ports copy)
- `CYLSearchBarView`: the search field; items, single and "multiple" modes, default search button, iconified state, navigation-field preset, focus-on-appear and outside-touch dismissal.
- `CYLSearchView`: the page below the bar: suggestions as tags or list, history cache (SQLite, defaults or file), results data source, placeholders, refresh API.
- `CYLSearchController`: QMUI-shaped controller that puts its own page over a host. It does **not** wrap `UISearchController`.
- `CYLSearchTableViewController`, `CYLSearchHeaderSnapper`, `CYLSearchNavigationBar` (and presets), `CYLSearchPresentationState` (shared state and edge swipe), `CYLSearchResources`, `CYLSearchResultsComponent`, `CYLSearchSuggestionArea`, `CYLSearchTagListHeader`, `CYLSearchTagListStyle`, `CYLSearchBarAppearance`.

## Port mapping
- Android: same class names. `CYLSearchListView` takes the role of the iOS controller / table view controller.
- HarmonyOS: models mirror iOS names; `CYLSearchController` wraps a `CYLSearchView`; first level is `pageDepth` 1 (iOS 0). Pure-logic blocks are tested on Node by `harmonyos/scripts/host-logic-test.mjs`.
- Mini program: ported from the HarmonyOS models, keeping a `$r` shim. The strings table in `CYLSearchResources.js` is generated: do not edit it by hand.

## Shared tooling that ties platforms together
- API parity: `android/merged/scripts/api-alignment.py` parses the Swift public API; `scripts/harmonyos-api-alignment.py` and `scripts/miniprogram-api-alignment.py` reuse that parser and write tables in `docs/`.
- Demo data: `scripts/sync-discover-data.py` copies the iOS Discover JSON to every example and checks the "one hot item per page, in a different slot" rule. It does not check translation.
- Resources are imported into ports from the iOS bundles by per-platform import scripts.

## Search button behavior (differs by platform)
| | Custom `searchButtonHandler` | Empty text, no handler | Spaces only, no handler |
|:---|:---|:---|:---|
| iOS | replaces default | delegate told | `submit()` returns false; delegate **not** told |
| Android | replaces default | delegate told | delegate told |
| HarmonyOS | runs **after** submit/delegate | not traced separately | listener told (host test) |
| Mini program | runs **after** submit/delegate (test-pinned) | delegate told, before any handler (test-pinned) | `submit()` accepts blank; the search page ignores blank |

Flutter and React Native sit on the native cores; their handler behavior was not traced separately.
