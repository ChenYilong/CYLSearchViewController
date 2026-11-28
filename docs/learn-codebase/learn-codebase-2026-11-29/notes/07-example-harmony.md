> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# HarmonyOS example: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

8/8 chunks read. Findings (code read): '+ New Tag' outside Manage is a no-op (showAlertDialog has no text input, OK calls createTag('')); Edit Remarks Done has no onRight (inert); SpeechRecognizer hard-codes zh-CN; CORRECTED: EntryAbility.ets has 'testTag' hilog lifecycle lines plus a CYLDebugQuery log (git grep); oh-package.json5 has none; core CYLSearchView.ets:1652,1659 also log 'testTag'. pins: cylTabBarControllerCommit d19e138e, placeholder f4cf978, classifymenu c0b183de (Android tabbar af56db22).

## Files read (28)

- `harmonyos/AppScope/app.json5` (10)
- `harmonyos/build-profile.json5` (70)
- `harmonyos/entry/build-profile.json5` (26)
- `harmonyos/entry/hvigorfile.ts` (6)
- `harmonyos/entry/oh-package.json5` (21)
- `harmonyos/entry/src/main/ets/animation/CYLExampleAnimationViews.ets` (28)
- `harmonyos/entry/src/main/ets/common/DemoCommon.ets` (365)
- `harmonyos/entry/src/main/ets/common/DemoTagMenu.ets` (110)
- `harmonyos/entry/src/main/ets/common/SpeechRecognizer.ets` (67)
- `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagServer.ets` (112)
- `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagsPages.ets` (869)
- `harmonyos/entry/src/main/ets/demos/contacttags/CYLContactTagStore.ets` (334)
- `harmonyos/entry/src/main/ets/demos/CYLGalleryChunks.ets` (36)
- `harmonyos/entry/src/main/ets/demos/Discover.ets` (619)
- `harmonyos/entry/src/main/ets/demos/ExamplesMenu.ets` (312)
- `harmonyos/entry/src/main/ets/demos/FirstLevel.ets` (117)
- `harmonyos/entry/src/main/ets/demos/MaterialSearch.ets` (303)
- `harmonyos/entry/src/main/ets/demos/Ports.ets` (326)
- `harmonyos/entry/src/main/ets/demos/SearchBarDemo.ets` (156)
- `harmonyos/entry/src/main/ets/demos/SearchController.ets` (356)
- `harmonyos/entry/src/main/ets/demos/SearchExample.ets` (237)
- `harmonyos/entry/src/main/ets/entryability/EntryAbility.ets` (100)
- `harmonyos/entry/src/main/ets/pages/Index.ets` (286)
- `harmonyos/entry/src/main/module.json5` (45)
- `harmonyos/entry/src/main/resources/rawfile/CYLTabBarConfiguration.json` (28)
- `harmonyos/hvigor/hvigor-config.json5` (4)
- `harmonyos/hvigorfile.ts` (6)
- `harmonyos/oh-package.json5` (16)

Declarations with line numbers: [../reference/07-example-harmony.md](../reference/07-example-harmony.md)
