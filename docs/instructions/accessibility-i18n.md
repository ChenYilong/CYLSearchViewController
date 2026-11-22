# Accessibility and localization (tag: `accessibility-i18n`)

Details of the `accessibility-i18n` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## HarmonyOS: screen readers and localization (added 2026-11-16)

- Prompt (verbatim): "适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件可以从CYLTabBarController中复制一份过来。筛选本项目用到的文字。"
- Prompt (English): "Adapt the HarmonyOS code for visual assistance and for blind users. Adapt it for
  internationalization and localization; the localization files can be copied from CYLTabBarController. Keep only
  the texts this project uses."
- Screen readers: every tappable element of `harmonyos/cylsearch` has a label (`accessibilityText`, or a `Text` child)
  in the language the app shows; decorative icons are `accessibilityLevel('no')`; a touch area is at least 44 vp
  (`responseRegion` when the icon is smaller and the layout must not change); a list item reads its position and
  selected state (`accessibilityDescription`, `accessibilitySelected`); a state change with nothing on screen to
  read is announced (`accessibility.sendAccessibilityEvent`, `announceForAccessibility`).
- Localization: no English text written in the library's UI code; titles and labels default to string resources
  (`ResourceStr`). en, ja, zh-Hans and zh-Hant come from iOS (`check-ios-parity.mjs`); the other languages come from
  CYLTabBarController's string table, filtered to the texts this project uses
  (`node harmonyos/scripts/import-cyltabbar-localizations.mjs`, which never overwrites the four iOS languages).
- Check both with `node harmonyos/scripts/check-accessibility-i18n.mjs`; Scorecard 2 rows 15 and 16 in
  `docs/harmonyos-cross-platform.md`.

## HarmonyOS: screen readers and localization (added 2026-11-16) (instructions.md wording)

- Every tappable element of the library has a screen-reader label in the app's language, touch areas are at least
  44 vp, list items read their position and selected state, and state changes are announced.
- No English text in the library's UI code. en, ja, zh-Hans and zh-Hant come from iOS; other languages are copied
  from CYLTabBarController's string table, filtered to the texts this project uses
  (`harmonyos/scripts/import-cyltabbar-localizations.mjs`). Check with `harmonyos/scripts/check-accessibility-i18n.mjs`.
  Full rule: `AGENTS.md`, same section.

## Accessibility, localization and UI automation by label (added 2026-11-16)

- Prompt (verbatim): "并将下面的内容规则写入instructions相关文件并写入skills相关文件，如果相关文件不存在就新建文件确保成功。全英文写入：本项目全部代码已经支持适配视觉辅助 盲人辅助 为鸿蒙代码 。 适配国际化本地化，本地化文件。如果发现不支持请先支持，然后在自动化UI测试过程中，优先使用刚刚提到的功能进行UI控件定位。触发点击事件，或者触发复杂流程，连续操作等。"
- Prompt (English): "Write the following rule, in English, into the instruction files and the skill files, creating
  them when missing: all code of this project supports visual assistance and blind users, the HarmonyOS code
  included, and is internationalized and localized with localization files. When something is not supported,
  support it first; then, in automated UI tests, locate UI controls with these features first, to trigger taps,
  complex flows and continuous operations."
- Rules:
  1. All code of this project (library and examples, every platform, HarmonyOS included) supports screen readers
     and is localized (the two sections above for HarmonyOS; skill `cyl-accessibility-i18n`).
  2. A gap found (a control with no label, a text written in code, a missing language key) is fixed first, before
     the test or the feature that needs it.
  3. UI automation locates controls by their accessibility label or localized visible text first, read from the
     app's string resources in the device language; an id only for a control with no label of its own. Taps,
     typing, submitting, complex flows and continuous operations go through labelled controls. A control a test
     cannot find by label is a screen-reader gap (rule 2).
- HarmonyOS: `harmonyos/entry/src/ohosTest/ets/test/CYLSearchUI.test.ets` (`findByLabel`, `tapLabel`, the flow test
  `searchFlowByLabels`); check `node harmonyos/scripts/check-accessibility-i18n.mjs` (the library and the example).
- Status on the Windows machine (checked 2026-11-16): the region file says `<countryregion name="CN"/>`, a hypervisor
  is present, 64 GB RAM, and the HarmonyOS 6.0.1 `phone_all_x86` image was downloading.

## Accessibility, localization and UI automation by label (added 2026-11-16) (instructions.md wording)

- All code of this project supports visual assistance and blind users (screen readers) and is internationalized
  and localized with localization files, the HarmonyOS code included.
- When something is not supported, support it first.
- In automated UI tests, locate controls by those features first: their accessibility labels and localized texts,
  read from the app's string resources in the device language (an id only when a control has no label). Use them
  to trigger taps, complex flows and continuous operations.
- Skill: `cyl-accessibility-i18n`. Full rule: `AGENTS.md`, same section.

## Accessibility and localization on every platform; UI tests locate controls through them (added 2026-11-16)

- All code of this project (the core, every port and every example, HarmonyOS included) supports visual accessibility
  and screen readers for blind users (VoiceOver, TalkBack, HarmonyOS ScreenReader), and internationalization /
  localization through localization files. Every control a user can tap or read has an accessibility label (and a hint
  where the action is not obvious), tappable rows are one accessibility element, and every user-facing text comes from
  a localization file, never a hard-coded string (HarmonyOS: `$r('app.string.…')` in `resources/<locale>/element/string.json`;
  translations shared with CYLTabBarController are copied from its `CYLTabBarController.bundle/*.lproj`).
- If something turns out not to support them, add the support first, then continue the task.
- In automated UI tests, locate controls through these features first: accessibility identifiers / labels (iOS
  `accessibilityIdentifier` / `accessibilityLabel`, Android `contentDescription`, HarmonyOS `.id()` /
  `accessibilityText`, `ON.id` / `ON.accessibilityText`), then localized text. Use them to trigger taps, complex flows and
  series of actions; coordinates are the last resort.
