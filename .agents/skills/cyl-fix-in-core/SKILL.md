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

0. Record, then screenshot: write the bug into the related document and capture it (`docs/assets`) before
   fixing. Bugs of the animated components (`CYLAnimatedItem` and its engines) are fixed in CYLTabBarController and
   pinned here; if the example must change, CYLTabBarController first adds the API it calls (`AGENTS.md`, "Bugs of
   the animated components").

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

## The content below the search bar and its scrolling belong to the core (added 2026-11-20)

Full rule: `AGENTS.md`, "The core owns the content below the search bar and its scrolling".

- The search bar and the content page below it are created and owned by the core (mini program: `cyl-search-bar` and the
  content area of `cyl-search`). An example never creates, looks up or holds that scrolling view: no own `<scroll-view>`
  around core content, no `getCurrentPages()`, `selectComponent` or `currentPage` lookup that finds the content page or its scroller, no example flag such as
  `reordering` bound to `scroll-y`. `currentPage()` (miniprogram-automator) is for test scripts only.
- The content page listens by itself to the tag list's editing state and drag gesture (`reorderingchange`,
  `smearingchange`). It turns its own scrolling off only while a drag gesture is active (from the start of the drag until
  it ends or is cancelled); scrolling stays on at every other time, in editing mode too.
- It must be the one view that scrolls (a fixed-height column, not a page that grows with its content) and it holds that
  view's own switch (`scroll-y`, `isScrollEnabled`, ...). In WeChat `catchtouchmove` only stops propagation, and iOS
  ignores a page-level `overflow: hidden` for touch scrolling.
- A tag list in another repository emits the states as bubbling, composed events: fix it there first, then pin it
  (`cyl-sub-repositories`). The example only places the tag list into the content page.
- Question that decides it: does the example toggle scrolling, find a page or a scroller, or own a scroll view around
  core content? Then the behavior is in the wrong layer: move it into the core.
