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
3. Add the feature to the core first, chosen by an enum or a parameter. When the sub-repository lacks an interface,
   add it there, commit and push it there, then update the pinned commit here.
4. Show every style in the example; the example passes only data, style parameters and click handling.
5. Verify on each platform, with labeled screenshots in `docs/` (AGENTS.md, "Screenshots of builds and CI/CD").

## Sub-repositories of this project

| Sub-repository | What it adds | Status |
|:---|:---|:---|
| CollectionViewClassifyMenu | Suggestions under the search bar as tags (`CYLSearchSuggestionStyle`) | Android done; iOS `TODO` (`docs/tag-view-suggestions.md`) |
| CYLTableViewPlaceHolder | When a search has no results, its empty-content placeholder style | `TODO` on every platform: iOS, Android, React Native, Flutter, HarmonyOS, mini programs (`docs/sub-repositories.md`) |
