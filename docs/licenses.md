# Licenses in every published package

Every piece of code this project publishes to an external registry (CocoaPods, Maven / Gradle, npm, pub.dev, ohpm and
any other) ships its license declaration inside the package, in the package's resource bundle when it has one.

## TODO (2026-11-17): a license declaration in every published package

- **Context**: branch `feat/harmonyos-parity` (PR #11). The packages declared different licenses: the iOS pod
  (`CYLSearchViewController.podspec`) and the Flutter plugin "Copyright (c) 2015 ChenYilong. All rights reserved.",
  the React Native, mini program and HarmonyOS packages MIT; the repository root had no `LICENSE`, and the iOS bundle
  `Resources/CYLSearchViewController.bundle` carried only the third-party notices of its icons. The owner chose
  **MIT everywhere** (Copyright (c) 2015 ChenYilong).
- **Requirements**:
  - write the rule, in English, into the instruction files and the skill files (create files when missing);
  - every package published to an external registry (CocoaPods, Gradle, npm, Maven and the others) contains a license
    declaration;
  - when the package has a built-in resource bundle folder, the license goes into it; when it has none, create one;
  - iOS: the resource `.bundle` contains the license file;
  - every platform.
- **Prompt (verbatim)**: "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：所有需要发布到外部仓库的代码，包括但不限于 cocoapods graddle npm maven等等 必须包含协议声明，如果已经有内置包文件夹就放进去，如果没有就新建，确保写入成功。以iOS为例，内置包bundle文件应包含协议文件。此操作适用于所有平台。"
- **Prompt (English)**: "Find this project's instruction files and skill files (add files when missing, make sure the
  write succeeds) and write, in English: all code published to an external registry, including but not limited to
  CocoaPods, Gradle, npm and Maven, must contain a license declaration; if a built-in package (bundle) folder exists,
  put it there, otherwise create one, and make sure it is written. On iOS, for example, the built-in bundle contains
  the license file. This applies to every platform."
- **Status**: started.
