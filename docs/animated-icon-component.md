# Animated Icon Component (CYLTagButton)

## TODO (2026-11-17): one icon + title / animated icon component everywhere

- **Context**: branch `feat/harmonyos-parity` (PR #11). The packaged icon + title component that also plays animated
  icons is CollectionViewClassifyMenu's `CYLTagButton`
  (`CollectionViewClassifyMenu/Class/TagList/CYLTagButton.swift`, branch `feat/harmony`): an icon (`imageView`), a
  title (`titleLabel`), a delete indicator, and `animationURL` / `playAnimation()`, which hand every file format to
  CYLTabBarController's animation engine (`CYLTabBarItemAnimationFactory`, found at runtime) with no per-format code.
  Found in this project: `CYLSearchBarView`'s item control (`CYLSearchBarItemControl`, icon + title + badge, its own
  view), the empty-result placeholders (CYLTableViewPlaceHolder's `CYLPlaceholderView`, whose animated icons use that
  library's own engine, `CYLPlaceholderItemAnimationEngine`, without SVGA), and the example's SVGA demo header
  (`SVGAPlayer` directly). `CYLTagButton` lacks a badge and an icon-above-title layout.
- **Requirements**:
  1. Every component of the project that shows an icon with a title, or plays an animated icon, uses the same
     component, `CYLTagButton`; where it does not, change its implementation so that it does.
  2. A new animation type is then added in that one component only; every component that shows animations supports
     it with no second change.
  3. All platforms: iOS, Android, HarmonyOS and the mini program (CollectionViewClassifyMenu has a `CYLTagButton`
     counterpart on each); React Native and Flutter follow through the native cores.
- **Decisions (user, 2026-11-17)**: everything goes through `CYLTagButton`. CYLTableViewPlaceHolder: layered — its own
  session (task "Every icon + title and animation display goes through CYLPlaceholderView", branch
  `feat/android-refresh-port-followup`, PR #31) first makes everything there go through `CYLPlaceholderView`; then
  `CYLPlaceholderView` draws its animated icon with `CYLTagButton` (CYLTableViewPlaceHolder gains a dependency on
  CollectionViewClassifyMenu and drops its own engine). That step waits for that session, to avoid editing
  `CYLPlaceholderView` in parallel.
- **Plan**:
  1. CollectionViewClassifyMenu (every platform): `CYLTagButton` gains what the other uses need: a badge, an icon
     above the title (a `CYLTagImagePlacement` case), icon-only use; pushed to `feat/harmony` and pinned here.
  2. This repository (every platform): `CYLSearchBarView`'s items are drawn by `CYLTagButton`; the example's SVGA demo
     is a `CYLTagButton` with an `.svga` `animationURL`.
  3. CYLTableViewPlaceHolder: `CYLPlaceholderView`'s animated icon becomes a `CYLTagButton` (after its session).
- **Prompt (verbatim)**: "请确保本项目中所有具有如下特征的组件使用的是同一个组件，如果不是相关代码修改内部实现，以保证使用的是同一个组件，方便我重构该组件就可以把修改应用到所有组件上。我的需求是以后新增动效类型，仅需需要修改这个组件，所有需要使用动效展示的组件都可以支持新增动效，无须在第二个地方修改代码。" (followed by the link to `CYLTagButton.swift` on `feat/harmony`, line 94, and its description)
- **Prompt (English)**: "Make sure every component of this project with the following traits uses the same component;
  where one does not, change its internal implementation so that it does, so that refactoring that component applies
  the change to all of them. My requirement: in the future, adding a new animation type only needs a change to this
  component, and every component that shows animations supports the new type with no change in a second place."
- **Status**: logged; step 1 next.
