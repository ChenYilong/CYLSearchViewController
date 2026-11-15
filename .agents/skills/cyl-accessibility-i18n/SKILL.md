---
name: cyl-accessibility-i18n
description: "Screen readers (visual assistance, blind users) and localization across the project's code, HarmonyOS in detail; UI automation finds controls by their accessibility labels and localized texts first, to tap them and to drive complex or continuous flows."
---

# Accessibility, localization and UI automation by label

Rule (user, 2026-11-16): all code of this project supports visual assistance and blind users (screen readers) and
is internationalized and localized, the HarmonyOS code included. When a gap is found, support it first; then, in
automated UI tests, locate controls by those features first: by their accessibility labels and localized texts, to
trigger taps, complex flows and continuous operations. Full rule: `AGENTS.md`, "Accessibility, localization and UI
automation by label".

## 1. Screen readers

- Every tappable element has a label in the language the app shows: an accessibility label (iOS
  `accessibilityLabel`, Android `contentDescription`, HarmonyOS `accessibilityText`) or a visible text child.
- A row or cell that is tapped as a whole is one element with one label (iOS `isAccessibilityElement`, Android
  `importantForAccessibility` on the row, HarmonyOS `accessibilityGroup(true)` plus `accessibilityText`).
- Decorative icons are hidden from screen readers (HarmonyOS `accessibilityLevel('no')`).
- Touch areas are at least 44 vp / pt / dp; when the icon is smaller and the layout must not change, enlarge the
  touch area only (HarmonyOS `responseRegion`).
- List items read their position and selected state (HarmonyOS `accessibilityDescription`,
  `accessibilitySelected`; iOS `multisearch.item`, "Search 2 of 3").
- A state change with nothing new on screen to read is announced (iOS `UIAccessibility.post(.announcement)`,
  Android `announceForAccessibility`, HarmonyOS `accessibility.sendAccessibilityEvent` with
  `announceForAccessibility`).

## 2. Localization

- No user-visible text is written in code: titles, labels and their defaults come from string resources
  (HarmonyOS `$r('app.string.…')`, defaults typed `ResourceStr`).
- en, ja, zh-Hans and zh-Hant come from iOS and match it (`node harmonyos/scripts/check-ios-parity.mjs`).
- Other languages come from CYLTabBarController's string table, filtered to the texts this project uses
  (`node harmonyos/scripts/import-cyltabbar-localizations.mjs`; it never overwrites the four iOS languages).

## 3. UI automation by label

Find a control the way a screen reader finds it, in the language the device shows:

1. by its accessibility label or visible text, read from the app's own string resources (never a hard-coded
   English string), so the test passes in every language;
2. by an id only for what has no label of its own (for example a text field found by type).

When a test cannot find a control by its label, that is a screen-reader gap: add the label in the app (section 1),
then write the test. Taps, typing, submitting and multi-step flows all go through labelled controls.

HarmonyOS (hypium, `@kit.TestKit`), from `harmonyos/entry/src/ohosTest/ets/test/CYLSearchUI.test.ets`:

```ts
async function findByLabel(driver: Driver, label: string): Promise<Component> {
  const byText = await driver.findComponent(ON.text(label));
  if (byText) {
    return byText;
  }
  const byDescription = await driver.findComponent(ON.description(label));
  if (byDescription) {
    return byDescription;
  }
  throw new Error(`No control labelled "${label}"`);
}

await tapLabel(driver, appString('tab_tagStyle'));          // a tab, by its localized title
await tapLabel(driver, libString('demo.port.default'));     // a row, by its group label
await tapLabel(driver, libString('demo.port.open'));        // an icon button, by its accessibility label
```

iOS (XCUITest) uses `app.buttons[label]` / `app.cells[label]` with the label from the bundle's strings; Android
(Espresso / UI Automator) uses `withContentDescription(label)` / `withText(label)` from `R.string`.

## Checks

| Check | Command |
| :--- | :--- |
| HarmonyOS labels, touch areas, no English in UI, keys in the four languages | `node harmonyos/scripts/check-accessibility-i18n.mjs` |
| HarmonyOS strings and images match iOS | `node harmonyos/scripts/check-ios-parity.mjs` |
| HarmonyOS UI tests by label (needs an emulator or a device; no signing) | `hdc shell aa test -b com.cyl.search.harmonyos -m entry_test -s unittest OpenHarmonyTestRunner` |
