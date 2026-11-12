# Android and Cross-Platform Support

This document tracks support for Android, HarmonyOS NEXT and the cross-platform frameworks (Flutter, then React
Native) for the CYLSearchViewController components.

## TODO (2026-11-12): Android, HarmonyOS NEXT, Flutter, then React Native

- Context: CYLSearchViewController is iOS only today (Objective-C core in `Sources/CYLSearchViewController/`:
  `CYLSearchResultsViewController`, `CYLSearchController`, `CYLSearchBarView`, `CYLSearchView`,
  `CYLMultiSearchView`, `CYLSearchPlaceholderView`, `CYLSearchResources`). The search API parity task
  (`docs/search-api-comparison.md`, compared with five Android libraries) and the Swift migration of the core
  (`docs/swift-migration.md`) were asked earlier and come first, in the order the tasks were given. The repository
  had no Android document, so this one was created. CYLTabBarController (a sibling folder in the vault) already
  ships Android, React Native and Flutter components (`CrossPlatform/`, `Example-Android`) and can serve as the
  reference layout.
- Requirements:
  1. Support Android for the search components.
  2. Support the cross-platform frameworks: Flutter first; adapt React Native only after the Flutter version
     passes its tests.
  3. Adapt to the Android side of HarmonyOS NEXT (HarmonyOS NEXT compatibility for the Android and cross-platform
     builds).
  4. Written in English.
- Prompt (verbatim): "找到docs android相关文档写一个英文TODO：android 与跨端平台（REactNative flutter，先flutter，flutter测试通过后再适配 REactNative）支持适配 android 鸿蒙 NEXT系统。"
- Prompt (English): "Find the Android-related document in docs and write an English TODO: Android and
  cross-platform (React Native, Flutter; Flutter first, adapt React Native after Flutter passes its tests)
  support, adapted for Android and the HarmonyOS NEXT system."
- Status: logged, not started; waits for the search API parity task and the Swift migration.
- Order of work: Android → HarmonyOS NEXT compatibility → Flutter (tests pass) → React Native.
