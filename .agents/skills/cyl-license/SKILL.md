---
name: cyl-license
description: "A license declaration in every package published to an external registry (CocoaPods, Maven/Gradle, npm, pub, ohpm and others): the MIT LICENSE inside the package's resource bundle (created when missing), the manifest's license field, third-party notices next to it, and the check."
---

# Licenses in published packages

Full rule: `AGENTS.md`, "Licenses in published packages (added 2026-11-17)". Record: `docs/licenses.md`.

## The rule

1. Every piece of code published to an external registry, including but not limited to CocoaPods, Gradle, Maven,
   npm, pub.dev and ohpm, contains a license declaration: the license file itself, not only a manifest field.
2. When the package has a built-in resource bundle folder, the license file goes into it. When it has none, create
   one and put the license there. On iOS the resource `.bundle` contains the license file.
3. Every platform: iOS, Android, React Native, Flutter, HarmonyOS, mini programs, and any new one.
4. The license is MIT, `Copyright (c) 2015 ChenYilong` (the owner's choice, 2026-11-17). The repository root `LICENSE`
   is the source; every copy is byte-identical to it.
5. The manifest declares the same license: podspec `s.license = { :type => 'MIT', :file => 'LICENSE' }`,
   `"license": "MIT"` in `package.json` and `oh-package.json5`, a Maven POM `licenses` block (MIT) when the Android
   library gets its publishing configuration, the `LICENSE` file at the root of a pub.dev package.
6. Third-party files shipped in a package (icons, animations, images) keep their own license and notice files next
   to the project license in the same bundle (`NOTICE`, `LICENSE.<source>`, `ICON-SOURCES`).

## Where the files are

| Registry | Package | License file (bundle) |
|:---|:---|:---|
| CocoaPods | `CYLSearchViewController.podspec` | `LICENSE` (podspec `:file`) and `Resources/CYLSearchViewController.bundle/LICENSE` |
| Maven / Gradle | `android/merged/cylsearch` | `src/main/resources/META-INF/cylsearch/LICENSE` (Java resources, packaged into the AAR's `classes.jar`; created for this rule) |
| ohpm | `harmonyos/cylsearch` | `LICENSE` (package root) and `src/main/resources/rawfile/CYLSearchViewController.bundle/LICENSE` |
| npm | `CrossPlatform/react-native-cylsearch` | `LICENSE` (package root; the native parts use the iOS bundle) |
| npm | `CrossPlatform/wechat-miniprogram-cylsearch` | `LICENSE` (package root) and `src/LICENSE` (the component folder) |
| pub.dev | `CrossPlatform/flutter_cylsearch` | `LICENSE` (package root; its iOS podspec points at it) |

The layout follows CYLTabBarController's rule (`docs/License-Notices.md`, commit `ee106e8`): the iOS resource bundle,
`META-INF/<module>/` Java resources on Android, the component folder for the mini program, otherwise the package root.
A JavaScript or Dart package has no resource bundle of its own: its package root is the folder the registry ships,
so the license file sits there.

## Check

`bash scripts/check-licenses.sh` (CI: the "Public API comments" job): every file above exists and equals `LICENSE`,
and each manifest declares MIT. A new published package adds its line to the script and a row to the table above,
in the same change.
