# Licenses in published packages (tag: `licenses`)

Details of the `licenses` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Licenses in published packages (added 2026-11-17)

- Prompt (verbatim): "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：所有需要发布到外部仓库的代码，包括但不限于 cocoapods graddle npm maven等等 必须包含协议声明，如果已经有内置包文件夹就放进去，如果没有就新建，确保写入成功。以iOS为例，内置包bundle文件应包含协议文件。此操作适用于所有平台。"
- Prompt (English): "Write, in English, into the instruction and skill files (creating them when missing): all code
  published to an external registry, including but not limited to CocoaPods, Gradle, npm and Maven, must contain a
  license declaration; if a built-in package (bundle) folder exists, put it there, otherwise create one. On iOS, the
  built-in bundle contains the license file. This applies to every platform."
- Rules:
  1. Every package published to an external registry (CocoaPods, Maven / Gradle, npm, pub.dev, ohpm and any other)
     ships its license file, not only a manifest field.
  2. The license file goes into the package's built-in resource bundle folder; when the package has none, create
     one. iOS: `Resources/CYLSearchViewController.bundle/LICENSE`; Android: `META-INF/<module>/LICENSE` in the
     library's Java resources (inside the AAR); the mini program: its component folder (`src/`); a JavaScript or Dart
     package: its root, the folder its registry ships. The same layout as CYLTabBarController (`docs/License-Notices.md`).
  3. Every platform, every new package.
  4. The license is MIT, `Copyright (c) 2015 ChenYilong` (owner's choice, 2026-11-17). The root `LICENSE` is the source;
     every copy is identical to it, and each manifest declares MIT.
  5. Third-party files shipped in a package keep their own license and notice files in the same bundle.
- Check: `bash scripts/check-licenses.sh` (CI). Skill: `cyl-license`. Record and file list: `docs/licenses.md`.
