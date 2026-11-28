# Animated components (tag: `animation`)

Details of the `animation` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Bugs of the animated components: record, screenshot, fix in CYLTabBarController (added 2026-11-17)

- Prompt (verbatim): "遇到bug，第一步记录， 第二截图， 所有修复，都应在CYLTabBarController仓库内修复动效相关组件完成，避免修改example 完成修复， 如果必须改动example也应，让CYLTabBarController 修改接口供demo使用。"
- Prompt (English): "When you meet a bug: first record it, second take a screenshot. Every fix of the animated components
  is made in the CYLTabBarController repository; do not fix it by changing the example. If the example must change,
  CYLTabBarController changes its API for the demo to use."
- Rules:
  1. Record every bug first (the related document's issue table or TODO entry: what, where, platform, device), then
     take a screenshot of it (`docs/assets`, labelled with platform, device and OS, commit, date) before fixing.
  2. Bugs of the animated components (`CYLAnimatedItem`, `CYLAnimatedItemView`, its engines and players, the tab
     bar animations) are fixed in CYLTabBarController, which owns them (its own branch and pull request, or its
     session), then pinned here. Never work around them in the example.
  3. If the example has to change, CYLTabBarController first adds or changes the API the example needs, and the example
     only calls it.

## Animation examples: playback controls (added 2026-11-13)

- Any example page that shows animations, on every platform (iOS, Android, React Native, Flutter, mini programs,
  HarmonyOS), offers "Play all" (each animation restarts from progress 0), a speed slider and a loop switch, combined
  into one playback strategy applied live, with accessibility labels and values; change the core when an example
  needs it. This repository has no animation example yet; the rule and its status live in CollectionViewClassifyMenu
  `docs/example-animation-controls.md` and CYLTabBarController `docs/Tab-Icon-Animation-Quick-Start.md`.
