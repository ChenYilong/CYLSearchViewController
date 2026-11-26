# Windows-only: HarmonyOS emulator host (tag: `windows`)

Details of the `windows` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16)

- Prompt (verbatim): "全英文写入instructions相关文件以及 skills相关文件： 鸿蒙系统 ide 准备工作，模拟器安装的必要条件， region should be set to china (NZ) in country.region.xml to china make sure The region file now says China: <countryregion name="CN"/>"
- Prompt (English): "Write, in English only, into the instruction files and the skill files: the HarmonyOS IDE
  preparation and the prerequisites for installing the emulator. The region must be set to China in
  `country.region.xml` (the developer is in New Zealand); make sure the region file says China:
  `<countryregion name="CN"/>`."
- Before the first HarmonyOS build or run on a machine, follow the `cyl-harmonyos-setup` skill. In short:
  1. IDE: DevEco Studio 6.0.1 with its bundled SDK (API 21), signed in with a Huawei ID. Command-line builds set
     `DEVECO_SDK_HOME` to DevEco Studio's `sdk` and put its `jbr\bin` and `sdk\default\openharmony\toolchains`
     (`hdc`) on `PATH`. hvigor rejects paths with spaces or non-ASCII characters: build from an ASCII mirror of
     `harmonyos/` (for example `C:\cylbuild\harmonyos`).
  2. Emulator prerequisites: a 64-bit Windows 10 or 11 host (or a Mac with Apple silicon); CPU virtualization
     enabled in the firmware; the Windows features Hyper-V, Windows Hypervisor Platform and Virtual Machine Platform
     on (`HypervisorPresent` is `True`); 16 GB RAM at least and enough free disk; a Huawei ID sign-in; the Device
     Manager privacy statement accepted; and the region set to China.
  3. Region: the developer is in New Zealand (first-launch region `NZ`), but the local emulator is offered only for
     China. With DevEco Studio closed, `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml` (macOS:
     `~/Library/Application Support/Huawei/DevEcoStudio6.0/options/country.region.xml`) must contain
     `<countryregion name="CN"/>`. Check it before creating an emulator and after restarting the IDE; keep the
     original as `country.region.xml.bak-NZ`.
  4. Emulator: Device Manager > Local Emulator > New Emulator > Mate 70 Pro, HarmonyOS 6.0.1 (API 21); check with
     `hdc list targets`; install with `hdc install`.
  5. Signing (user, 2026-11-16: "模拟器 测试 不需要签名 跳过签名", "emulator tests need no signing; skip signing"):
     emulator runs and tests use the unsigned HAPs; keep `signingConfigs` empty and do not ask for a certificate,
     a profile or automatic signing. Signing is needed only for a real device or a release, when the user asks.

## HarmonyOS: IDE preparation and emulator prerequisites (added 2026-11-16) (instructions.md wording)

- Before the first HarmonyOS build or run on a machine, follow the `cyl-harmonyos-setup` skill.
- IDE: DevEco Studio 6.0.1 with its bundled SDK (API 21), signed in with a Huawei ID; for command-line builds set
  `DEVECO_SDK_HOME` and put `jbr\bin` and `sdk\default\openharmony\toolchains` (`hdc`) on `PATH`; build from an
  ASCII path without spaces (hvigor).
- Emulator prerequisites: 64-bit Windows 10 or 11 (or Apple silicon); CPU virtualization on; Hyper-V, Windows
  Hypervisor Platform and Virtual Machine Platform on; 16 GB RAM at least; Huawei ID sign-in; region China.
- Region: the developer is in New Zealand, but the emulator needs the region China. With DevEco Studio closed,
  `%APPDATA%\Huawei\DevEcoStudio6.0\options\country.region.xml` must say `<countryregion name="CN"/>` (not `NZ`);
  check it before creating an emulator. Full rule: `AGENTS.md`, same section.
- Signing: emulator runs and tests need no signing. Install the unsigned HAPs with `hdc install`; do not configure
  `signingConfigs` or ask for a certificate unless the user asks for a device or release build (2026-11-16).

## HarmonyOS: HAPs for the x86_64 emulator leave out the arm64-only Rive and PAG libraries (added 2026-11-22)

- Prompt (verbatim): "到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：    to fix HAP won't install on this x86_64 emulator because its Rive and PAG libraries are arm64-only,"
- Prompt (English): "Write, in English, into this project's instruction files and skill files (add files when missing,
  make sure the write succeeds): how to fix a HAP that won't install on this x86_64 emulator because its Rive and PAG
  libraries are arm64-only."
- **The problem.** The local HarmonyOS emulator on Windows (Mate 70 Pro, HarmonyOS 6.0.1 API 21, image `phone_all_x86`) is
  x86_64. `@ohos/rive` and `@tencent/libpag`, which CYLTabBarController and CYLTableViewPlaceHolder bring in, ship
  `arm64-v8a` `.so` files only. A HAP that bundles them is rejected by the installer: `hdc install` fails with "install
  parse native so failed" and an "Abi type" message. The app HAP and the ohosTest HAP both carry them.
- **The fix** (already in `harmonyos/entry/build-profile.json5` and `harmonyos/build-profile.json5`):
  1. a build option `emulator` with `"nativeLib": { "filter": { "excludes": ["**/arm64-v8a/*.so"] } }`;
  2. a target `emulator` bound to that option in the `debug` and `release` build modes;
  3. a build mode `emulatorTest` (listed in the root `buildModeSet`) that binds the `ohosTest` target to the same option.
- **Commands** (from the ASCII mirror `C:\cylbuild\harmonyos`):
  - app: `hvigorw --mode module -p module=entry@emulator -p product=default assembleHap`, install
    `entry/build/default/outputs/emulator/entry-emulator-unsigned.hap`;
  - tests: `hvigorw --mode module -p module=entry@ohosTest -p isOhosTest=true -p buildMode=emulatorTest -p product=default
    assembleHap`, install `outputs/ohosTest/entry-ohosTest-unsigned.hap`, then `hdc shell aa test -b
    com.cyl.search.harmonyos -m entry_test -s unittest OpenHarmonyTestRunner -s timeout 40000`.
  - Check: `unzip -l <hap> | grep arm64-v8a` prints nothing for both HAPs.
- **Rules.**
  1. Use the `emulator` target and the `emulatorTest` build mode for every run on an x86_64 emulator; phones, arm64
     emulators and releases keep the `default` target and `-p buildMode=test`, which bundle the arm64 libraries.
  2. Fix it in the build profile only: never remove or replace the Rive or PAG dependencies, never change the
     `overrides` in `oh-package.json5`, never put the filter on the `default` target.
  3. In the emulator HAP the Rive and PAG animations cannot play (the still images show instead). A Rive or PAG check
     needs an arm64 device or an arm64 emulator (a Mac with Apple silicon); say so in the report and in the screenshot
     footer.
  4. A new HarmonyOS app module or test target that depends on a library with arm64-only native code gets the same
     option, target and build mode.
  5. After a sub-repository sync, delete the mirror's `build`, `.hvigor` and `oh_modules` before building
     (robocopy `/XD` keeps them, and a stale incremental build once dropped a new export).
- **Where the fix belongs** (added 2026-11-22, second prompt). Prompt (verbatim): "、到本项目instructions 相关文件以及skills相关文件，如果没有就新增文件保证写入成功，全英文写入：    to fix HAP won't install on this x86_64 emulator because its Rive and PAG libraries are arm64-only, 最好的CYLTabBarController里的CYLAnimatedItemView库中完成该测试方案， 以让依赖该组件的example以及其他库完成完整测试 x86_64 emulator". Prompt (English): "…
  the best place to complete this test plan is CYLTabBarController's CYLAnimatedItemView library, so that the examples
  and the other libraries that depend on the component can run complete tests on the x86_64 emulator."
  1. The x86_64 test plan is owned by CYLTabBarController's HarmonyOS `cylanimateditem` (`CYLAnimatedItemView`), the one
     library that brings in Rive and PAG. It ships, for every dependent: (a) a ready-made way to build an app and its
     ohosTest HAP without the `arm64-v8a` libraries (the `emulator` option, target and `emulatorTest` mode above, or a
     hvigor helper the app applies), documented in its README; (b) a runtime check, so a Rive or PAG item whose native
     library is missing shows its still image and reports the state (no crash, no blank cell); (c) its own hypium
     tests for that path on the x86_64 emulator.
  2. Dependents (this repository, CollectionViewClassifyMenu, CYLTableViewPlaceHolder and their examples) use what
     `cylanimateditem` provides and keep no copy of their own once it is there; until then the build profile above is
     the local stopgap, removed when the pin reaches the CYLTabBarController commit that ships the plan
     (`cyl-sub-repositories`).
  3. Requested from the CYLTabBarController session on 2026-11-22; status in `docs/task-log.md`.
- Skill: `cyl-harmonyos-setup` ("Arm64-only native libraries on the x86_64 emulator"); also `cyl-verify`, "HarmonyOS".
