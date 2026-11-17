---
name: cyl-fix-in-core
description: "Where to fix an issue or a bug: in the core (the code published to CocoaPods, Maven/Gradle, npm, pub, ohpm, and the sub-repositories' libraries) first; the example layer only as the last resort, after asking the user, with the reason written in the related document."
---

# Fix issues in the core first

Full rule: `AGENTS.md`, "Fix issues in the core first" (2026-11-17).

## What is the core

| Platform | Core (published) | Example layer (not published) |
| :--- | :--- | :--- |
| iOS | `Sources/CYLSearchBar` (the search core, CYLSearchBar), `CYLSearchViewController.podspec` (CocoaPods) | `CYLSearchExample` |
| Android | `android/merged/cylsearch` (Maven / Gradle) | `android/merged/app` and the samples |
| React Native | `CrossPlatform/react-native-cylsearch/src`, `android/`, `ios/` (npm) | its `example` |
| Flutter | `CrossPlatform/flutter_cylsearch` `lib/`, `android/`, `ios/` (pub) | its `example` |
| Mini program | `CrossPlatform/wechat-miniprogram-cylsearch/src` (npm; components `cyl-search-bar`, `cyl-search`) | its `example` |
| HarmonyOS | `harmonyos/cylsearch` (ohpm) | `harmonyos/entry` |
| Sub-repositories | CYLTabBarController, CYLTableViewPlaceHolder, CollectionViewClassifyMenu libraries | their demos |

The search core is CYLSearchBar on every platform: on iOS three files (`CYLSearchBarView.swift`,
`CYLSearchView.swift`, `CYLSearchResources.swift`) and four public classes (`CYLSearchBarView`, `CYLSearchBarItem`,
`CYLSearchView`, `CYLSearchResources`); the same three files on Android (`.kt`) and HarmonyOS (`.ets`). A fix goes
into the class that owns the feature (a parameter or a mode), never into a new public class. Refresh fixes go into
`CYLSearchView`'s refresh API, the only refresh API of the core.

## Steps

1. Find where the bug really lives. If any app of the library could meet it, it belongs to the core, even when only
   the example showed it.
2. Fix it in the core, so that the same kind of problem cannot happen again (a default, a measured size, an option),
   and add a test there when the platform has tests. A bug in a sub-repository's library is fixed in that repository
   (its own branch and pull request), then the new commit is pinned here (`cyl-sub-repositories`).
3. Only when the core cannot fix it: stop and ask the user, with the reason. Do not fix it in the example layer
   before they answer.
4. When the fix is in the example layer, write in the related document (the issue's row or section) why the core
   could not solve it and why the example layer is the right place. For example-only code (an example page's own
   layout, texts or images) write "example-only: the core has no such code".

## Questions that decide it

- Would another app that uses the library meet the same bug? Then it is core.
- Does the example only pass data, styles or handlers to the core? Then the fix belongs where the behavior lives:
  the core.
- Is it the example's own page (its list, its icons, its window setup) with no counterpart in the core? Then it is
  example-only, and the document says so.
