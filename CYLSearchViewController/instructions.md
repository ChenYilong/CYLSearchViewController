# Folder Instructions

This folder holds the example app's shared resources: `Images.xcassets` (the app icon and `CYLPlusButton`),
`CYLLaunchScreen.storyboard` (the launch screen) and `it_is_effect_show__SearchBar.gif`, the original demo's
screenshot that `CYLSearchExample/CYLOriginalSearchDemoViewController.swift` reproduces. The legacy Objective-C demo
app that lived here was replaced by that Swift page and removed (`docs/swift-migration.md`, step 2). Inherit the
repository rules from `../instructions.md` and `../AGENTS.md`.

- Add no source code here; the example's code lives in `CYLSearchExample/`.
- Keep the asset catalog and the launch screen referenced explicitly by `CYLSearchExample.xcodeproj`.
- Keep user-visible assets accessible and the GIF unchanged: it is the reference for the original demo.
