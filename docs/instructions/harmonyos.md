# HarmonyOS (tag: `harmonyos`)

Details of the `harmonyos` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## HarmonyOS: API and example 1:1 with iOS, internals from the Android Kotlin sources (added 2026-11-16)

- Prompt (verbatim): "写入instructions相关文档，鸿蒙系统版本，原则如下：API对标iOS端，example对标iOS端。需要一比一复刻。内部实现对标android 内的Kotlin 源码实现迁移到鸿蒙端。继续 continue 你未完成的任务"
- Prompt (English): "Write into the instructions documents the HarmonyOS version and these principles: the API matches
  iOS, the example matches iOS, a one-to-one copy; the internal implementation is migrated to HarmonyOS from the
  Kotlin sources in android/. Then continue the unfinished tasks."
- HarmonyOS version: HarmonyOS NEXT, target HarmonyOS 6.0.1 (API 21), compatible from HarmonyOS 6.0.1 (API 21; the minimum of CYLTableViewPlaceHolder's cylplaceholder)
  (`harmonyos/build-profile.json5`); ArkTS with ArkUI state management V2 (`@ComponentV2`); DevEco Studio 6.0.1 with
  its bundled SDK, hvigor and ohpm.
- Rules:
  1. API: every public API of the iOS library has a HarmonyOS counterpart with the iOS name
     (`docs/harmonyos-api-alignment.md`).
  2. Example: `harmonyos/entry` replicates `CYLSearchExample` one to one: the same tabs, pages, texts in
     en/ja/zh-Hans/zh-Hant, data, images and interactions (`harmonyos/scripts/import-ios-resources.py` imports the iOS
     resources). A change to the iOS example changes the HarmonyOS example in the same task.
  3. Internals: migrate the behavior from the Android Kotlin sources (`android/`) to ArkTS (the same state handling,
     filtering, caching and event order); write new code only where Android has none, and note it.
  4. Score both tables of `docs/harmonyos-cross-platform.md` after each feature (`python3 scripts/harmonyos-scorecard.py`)
     until no TODO is left.

## HarmonyOS: API and example 1:1 with iOS, internals from the Android Kotlin sources (added 2026-11-16) (instructions.md wording)

- HarmonyOS version: HarmonyOS NEXT, target HarmonyOS 6.0.1 (API 21), compatible from HarmonyOS 6.0.1 (API 21; the minimum of CYLTableViewPlaceHolder's cylplaceholder);
  ArkTS with ArkUI state management V2; DevEco Studio 6.0.1 and its bundled SDK.
- The API of `harmonyos/cylsearch` matches the iOS public API; the example `harmonyos/entry` replicates
  `CYLSearchExample` one to one (tabs, pages, texts, data, images, interactions; resources imported by
  `harmonyos/scripts/import-ios-resources.py`). The internals are migrated from the Android Kotlin sources
  (`android/`), not written anew. Full rule: `AGENTS.md`, same section; scorecard: `docs/harmonyos-cross-platform.md`.

## HarmonyOS: Rive and PAG tests that need arm64, two plans (added 2026-11-22)

- Prompt (verbatim): "找到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：   Rive; pag 编译问题： 针对需要只能在arm64上才能执行的测试， 有两个方案可供实现， 第一个方案是在CYLTabBarController的CYLAnimatedItemView中进行改造， 从GitHub中引入x86 架构的依赖库， 以完成测试功能。判断guards条件为， 运行系统的版本。 为x86架构， 首先你要保证x86架构能编译通过，且不会crash影响其他功能，其次才是实现功能运行正常。 在该方案未测试通过前使用debug环境编译选项进行guards，因为该方案目前只在运行模拟器时候会触发， 当该方案验证可行时候才再移除debug编译guards，你在移除该guards前需要经过我的同意。如果该方案实现失败， 则选择第二个方案， 将任务转发给正在macOS上的session进行测试， 因为macOS就是arm64架构的。"
- Prompt (English): "Write, in English, into this project's instruction files and skill files (add files when missing, make
  sure the write succeeds): the Rive / PAG build problem. For tests that can only run on arm64 there are two plans. Plan 1:
  change CYLTabBarController's CYLAnimatedItemView to bring in x86 builds of the dependency libraries from GitHub, so the
  tests can run. The guard condition is the running system: an x86 architecture. First make sure the x86 build compiles
  and does not crash or affect other features; only then make the feature work. Until the plan is tested, guard it with
  a debug build option, because it is only triggered on the emulator for now; remove the debug guard only when the plan
  is proven, and ask me for approval before removing it. If the plan fails, use plan 2: forward the task to the session
  running on macOS for testing, because macOS is arm64."
- **Plan 1: x86_64 builds of Rive and PAG in CYLTabBarController's CYLAnimatedItemView** (the HarmonyOS `cylanimateditem`;
  never in this repository or an example: "Bugs of the animated components" and "Fix issues in the core first").
  1. Bring in x86_64 builds of the native libraries from GitHub: built from the projects' own sources (Rive:
     `rive-app/rive-runtime` and the `@ohos/rive` wrapper; PAG: `Tencent/libpag`) or published by them; record each source
     URL, commit or release, and license in the library's notices (the license rule), and never take a binary of unknown
     origin.
  2. Guard: use them only when the device's ABI is x86_64 (`deviceInfo.abiList`, the same check as
     `CYLAnimatedItemEngines.isSupportedOnDevice`); arm64 devices keep the published arm64 packages unchanged.
  3. Order of work: (a) the x86_64 build compiles, (b) nothing crashes and no other feature changes (Lottie, SVGA, GIF,
     the still images, the tab bar, arm64 builds), (c) only then Rive and PAG play correctly on the x86_64 emulator.
  4. Until plan 1 passes its tests, everything it adds sits behind a **debug build guard** as well (a debug-only build
     option or `BuildProfile.DEBUG`, so release builds never contain it): it is meant for emulator runs only.
  5. Removing the debug guard needs the user's explicit approval: ask first, with the test evidence (hypium on the
     x86_64 emulator, labelled screenshots), even when the plan works.
- **Plan 2, when plan 1 fails** (it cannot be built, it crashes, or it changes another feature): forward the Rive / PAG
  test to the session running on macOS (Apple silicon is arm64, so DevEco Studio's arm64 emulator runs the published
  libraries): send it the commit, the HAP build commands and what to check, and record the hand-off and its result in
  `docs/task-log.md`. Until then the x86_64 emulator keeps the still-image path (the section above).
- Owner: the CYLTabBarController session. Skills: `cyl-harmonyos-setup` ("Rive and PAG tests that need arm64"), `cyl-verify`.
