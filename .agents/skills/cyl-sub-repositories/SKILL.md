---
name: cyl-sub-repositories
description: "Integrate a sibling project (CollectionViewClassifyMenu, CYLTableViewPlaceHolder) as a sub-repository: commit pin, core option, example, every platform."
---

# Sub-repositories

A sibling project in the same local folder (`../<Name>`) that this library uses is a sub-repository. The
requirements were first set for CollectionViewClassifyMenu (`docs/tag-view-suggestions.md`) and apply to all of
them. Full rule: `AGENTS.md`, "Sub-repositories".

## Steps

1. Find the newest commit on any branch: `git -C ../<Name> fetch` then `git -C ../<Name> log --remotes -1`. It may not
   be on `main` or `master`.
2. Depend on that commit:
   - iOS: the sub-repository's root podspec as a sub-dependency of this pod (`s.dependency` in the podspec; the
     Podfile pins it with `:git` and `:commit`).
   - Android: by commit through Gradle or Maven when possible; otherwise `android/merged/settings.gradle.kts`
     (`pinnedCheckout`) checks the commit out into `.cyl-deps/` and builds the module from source. The commit is in
     `android/merged/gradle.properties`.
   - React Native, Flutter, HarmonyOS, mini programs: the package manager's git-plus-commit form.
   - A local path only while developing; remove it before committing.
   - **CYLTabBarController and CollectionViewClassifyMenu move together** (2026-11-18): CollectionViewClassifyMenu
     vendors CYLTabBarController's animated item by commit, for the mini program
     (`miniprogram_dist/cyl-animated-item/COMMIT`) and for HarmonyOS (`harmony/cylanimateditem/README.md`). Pin the
     CYLTabBarController commit that CollectionViewClassifyMenu's pinned commit bundles in both places. A pin that
     moves only CYLTabBarController breaks the mini program test and, once the tab bar uses new animated-item API, the
     HarmonyOS build (rows 33 and 34 of `docs/animated-icon-component.md`). Check both COMMIT files before pinning; when
     they lag, ask CollectionViewClassifyMenu to re-vendor first.
   - **Podfile.lock needs `pod install`** (2026-11-18): editing a Podfile changes its `PODFILE CHECKSUM`, so the three
     lock files (root, Flutter, React Native example) are refreshed by `pod install` on macOS, never by hand. A
     session on Windows asks a macOS session to run it after a pin.
3. Add the feature to the core first, chosen by an enum or a parameter. When the sub-repository lacks an interface,
   add it there, commit and push it there, then update the pinned commit here.
4. Show every style in the example; the example passes only data, style parameters and click handling.
5. Verify on each platform, with labeled screenshots in `docs/` (AGENTS.md, "Screenshots of builds and CI/CD").

## Sub-repositories of this project

| Sub-repository | What it adds | Status |
|:---|:---|:---|
| CollectionViewClassifyMenu | Suggestions under the search bar as tags (`CYLSearchSuggestionStyle`) | Android done; iOS `TODO` (`docs/tag-view-suggestions.md`) |
| CYLTableViewPlaceHolder | The placeholder sub-dependency: its empty-content placeholder (`CYLPlaceholderView` scenarios) when a search has no results, and the pull-to-refresh header wrapped by `CYLSearchView`'s refresh API; pinned at `62e40c0` (its newest commit, on `CYLAnimatedItem`) on every platform | Done on iOS, Android, HarmonyOS, the mini program, React Native and Flutter (`docs/sub-repositories.md`, `docs/search-core-merge.md`) |
