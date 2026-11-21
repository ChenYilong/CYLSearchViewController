# Licenses in every published package

Every piece of code this project publishes to an external registry (CocoaPods, Maven / Gradle, npm, pub.dev, ohpm and
any other) ships its license declaration inside the package, in the package's resource bundle when it has one.

## DONE (2026-11-17): a license declaration in every published package

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
- **Status**: done.
  - Rule: `AGENTS.md` and `instructions.md`, "Licenses in published packages (added 2026-11-17)"; new skill
    `.agents/skills/cyl-license/SKILL.md` (listed in the skills table).
  - Root `LICENSE` (MIT), copied byte for byte into every package:

    | Registry | Package | License file |
    |:---|:---|:---|
    | CocoaPods | `CYLSearchViewController.podspec` (`s.license = { :type => 'MIT', :file => 'LICENSE' }`, was "All rights reserved") | `LICENSE`, `Resources/CYLSearchViewController.bundle/LICENSE` |
    | Maven / Gradle | `android/merged/cylsearch` | `src/main/resources/META-INF/cylsearch/` (new: `LICENSE` and the icon notices, inside the AAR) |
    | ohpm | `harmonyos/cylsearch` | `LICENSE`, `src/main/resources/rawfile/CYLSearchViewController.bundle/` (new: `LICENSE` and the icon notices) |
    | npm | `CrossPlatform/react-native-cylsearch` | `LICENSE` (copyright year aligned to 2015) |
    | npm | `CrossPlatform/wechat-miniprogram-cylsearch` | `LICENSE` (already identical) and `src/LICENSE` (component folder) |
    | pub.dev | `CrossPlatform/flutter_cylsearch` | `LICENSE` (was "All rights reserved") |

  - The new Android and HarmonyOS bundles also carry the third-party icon notices (`NOTICE`,
    `LICENSE.material-design-icons`, `LICENSE.placeholder-third-party`, `ICON-SOURCES`) of the icons those libraries ship.
  - Check: `scripts/check-licenses.sh` (shellcheck clean, passes: 8 files), run in CI's "Public API comments" job
    (`actionlint` clean). README has a License section.
  - Maven publishing: DONE (2026-11-21). `android/merged/cylsearch/build.gradle.kts` publishes `com.cyl:cylsearch:0.1.0`
    (the pod's version; the release AAR and a sources jar) with an MIT POM, and Apache-2.0 for the Material Design icons
    it ships. Checked with `./gradlew :cylsearch:publishReleasePublicationToBuildRepository` (Gradle, JDK 17): the POM
    lists both licenses and the AAR holds `META-INF/cylsearch/LICENSE`, `NOTICE`, `LICENSE.material-design-icons`,
    `LICENSE.placeholder-third-party` and `ICON-SOURCES`. Not a license item, but needed before a real release:
    CYLTableViewPlaceHolder's Android modules (`:placeholder`, `:placeholder-refresh`) publish no coordinates yet, so the
    POM names them `CYLSearchAndroid:placeholder:unspecified`. That repository has to publish them first (reported to
    its session, 2026-11-21). Answer (2026-11-21): the owner chose `io.github.chenyilong:cyltableviewplaceholder:0.1.0` and
    `io.github.chenyilong:cyltableviewplaceholder-refresh:0.1.0`, configured on CYLTableViewPlaceHolder's
    `feat/android-refresh-port-followup` (PR #31), not on Maven Central yet. When `cyl.placeholder.commit` moves to that
    commit, Gradle should write them into this POM (a project dependency with one publication is named by it); check the
    POM then. Tried locally at `663c828` (2026-11-21, not committed): configuration fails. Its `android/placeholder` reads
    CYLTabBarController's version only from an included build, and this repository includes `:cylanimateditem` as a
    subproject. Reported to that session; the pin stays at `c84fce9`. Fixed there in `3ae8a3a`: checked here (local pin,
    not committed), it configures, `:cylsearch` 26 of 26 and the example builds. Its publishing lives in its root build,
    which this build does not evaluate, so `cylsearch`'s POM maps the two modules to the chosen coordinates itself
    (`pom.withXml` in `cylsearch/build.gradle.kts`): the POM now names `io.github.chenyilong:cyltableviewplaceholder:0.1.0`
    and `io.github.chenyilong:cyltableviewplaceholder-refresh:0.1.0` (checked with `publishReleasePublicationToBuildRepository`).
    Before a release they must be on Maven Central, as must `io.github.chenyilong:cyltabbarcontroller-animateditem`.
    CYLTableViewPlaceHolder `94c7bbd` moved its publication into the two modules' own build files: checked here (local pin,
    mapping removed, nothing committed), the POM names both coordinates without the mapping. So when
    `cyl.placeholder.commit` moves to `94c7bbd` or later, delete the `withXml` block in `cylsearch/build.gradle.kts`.
