> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Summary of the read; treat conclusions as unverified unless 02-findings.md marks them S.

# Dependency commit pins

Every line in tracked files (lock files and the task log left out) that mentions one of these pins, found with `git grep` at the working tree of `ad32984`.

- iOS root `Podfile`: PlaceHolder f4cf978, ClassifyMenu c0b183d, TabBar + AnimatedItem 08343e9, DeallocBlockExecutor eab21d1.
- CYLTabBarController is not on one commit across ports (08343e9, af56db2, d19e138), although the rules ask for the same pin.
- Instruction docs still name 62e40c0 for PlaceHolder on every platform.

## CYLTableViewPlaceHolder f4cf978
- `CrossPlatform/flutter_cylsearch/example/ios/Podfile:47`
- `CrossPlatform/react-native-cylsearch/example/ios/Podfile:30`
- `CrossPlatform/wechat-miniprogram-cylsearch/package.json:35`
- `Podfile:15`
- `android/merged/gradle.properties:13`
- `docs/animated-icon-component.md:167`
- `docs/qmui-search-controller.md:446`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:75`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:268`
- `harmonyos/oh-package.json5:6`

## 62e40c0 (older PlaceHolder pin: docs, a skill and one script)
- `.agents/skills/cyl-sub-repositories/SKILL.md:44`
- `CrossPlatform/wechat-miniprogram-cylsearch/scripts/sync-example.js:100`
- `docs/animated-icon-component.md:25`
- `docs/animated-icon-component.md:29`
- `docs/animated-icon-component.md:52`
- `docs/animated-icon-component.md:394`
- `docs/instructions/dependencies.md:120`
- `docs/instructions/dependencies.md:134`
- `docs/sub-repositories.md:9`
- `docs/sub-repositories.md:171`
- `docs/sub-repositories.md:174`

## CollectionViewClassifyMenu c0b183d
- `CrossPlatform/flutter_cylsearch/example/ios/Podfile:46`
- `CrossPlatform/react-native-cylsearch/example/ios/Podfile:29`
- `CrossPlatform/wechat-miniprogram-cylsearch/package.json:36`
- `Podfile:18`
- `android/merged/gradle.properties:11`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:63`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:70`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:71`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:72`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:266`
- `harmonyos/oh-package.json5:7`

## CYLTabBarController/CYLAnimatedItem 08343e9
- `CrossPlatform/flutter_cylsearch/example/ios/Podfile:37`
- `CrossPlatform/flutter_cylsearch/example/ios/Podfile:39`
- `CrossPlatform/flutter_cylsearch/example/pubspec.yaml:23`
- `CrossPlatform/wechat-miniprogram-cylsearch/package.json:34`
- `Podfile:20`
- `Podfile:24`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:33`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:62`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:72`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:73`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:265`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:418`

## CYLTabBarController af56db2
- `android/merged/gradle.properties:8`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:19`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:33`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:38`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:61`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:70`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:112`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:223`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:342`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:397`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:418`

## CYLTabBarController d19e138
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:33`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:71`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:397`
- `harmonyos/oh-package.json5:5`

## CYLDeallocBlockExecutor eab21d1
- `CrossPlatform/flutter_cylsearch/example/ios/Podfile:45`
- `CrossPlatform/react-native-cylsearch/example/ios/Podfile:28`
- `Podfile:26`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:64`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:186`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:202`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:241`
- `docs/todo/20261104/Next-Unify-Pins-Fix-Tab-Tint-And-Dark-Bar-Verify-RN-MiniProgram.md:267`
