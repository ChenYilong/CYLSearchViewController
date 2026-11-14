# WeChat Mini Program API alignment

## TODO (2026-11-15): mini program core aligned with every iOS public API; example with CYLTabBarController's mini program tab bar

- Branch: `feat/swift-core` (PR #8). Package: `CrossPlatform/wechat-miniprogram-cylsearch`.
- Prompt (verbatim): "item1 完善 core核心代码 对标 iOS端所有公开API ，然后完善 example ，并使用CYLTabBarController 微信小程序端的组件用来做tabbar item2 你先帮我创建工程，我再用ide打开，然后再进行下一步使用模拟器打开项目"
- Prompt (English): "Item 1: complete the core code, matching every public iOS API; then complete the example, using
  CYLTabBarController's WeChat Mini Program component as the tab bar. Item 2: first create the project for me; I open
  it in the IDE, then the next step opens the project in the simulator."
- Requirements:
  1. The mini program core (`src/`) has a counterpart for every public declaration of
     `Sources/CYLSearchViewController/*.swift`, or a stated N/A; a generated table here, scored to 100.
  2. The example covers the features like the other platforms' examples (search, examples, search bar, list style,
     tag style, discover), one tab each.
  3. The example's tab bar is CYLTabBarController's mini program component (`cyl-tabbar-miniprogram`), pinned by
     commit.
  4. Item 2 (HarmonyOS): the project in a permanent folder the user opens in DevEco Studio:
     `~/develop/CYLSearchViewController-swift-core/harmonyos` (the `feat/swift-core` worktree, moved there on
     2026-11-15); signing and the emulator run come next.
- Context: the HarmonyOS models (`harmonyos/cylsearch/src/main/ets`) already match the iOS API at 397/397; the mini
  program core is ported from them to JavaScript. The table script follows `scripts/harmonyos-api-alignment.py`.
- Status: TODO.

<!-- miniprogram-api-alignment:begin -->
<!-- miniprogram-api-alignment:end -->
