---
name: cyl-naming
description: Naming rules for every platform of this repository - when the CYL / cyl_ prefixes are required and when static analysis (SonarCloud swift:S100, S101, S115, S116, S117) wins. Use when adding or renaming a type, function, property, constant, extension member or component.
---

# Naming (re-evaluated 2026-11-22 against SonarCloud)

Why the prefixes existed: Objective-C has one global namespace for classes and lets a category method silently replace
another library's method with the same selector (the last loaded image wins). `CYL` on classes and `cyl_` on category
members prevented both. The question for every name is therefore: does it live in a global, runtime-shared namespace?

## Swift

| Kind | Collision mechanism in Swift | Rule |
| --- | --- | --- |
| Public type | Module namespace (`CYLSearchViewController.Foo`); the Objective-C runtime name is global only when exported | Keep `CYL` on public types (shipped API, Objective-C runtime name via `@objc(CYLName)`, the same name on six platforms; passes S101 `^[A-Z][a-zA-Z0-9]*$`). Internal and private types: no prefix. |
| Member of our own type | Scoped by the type | No prefix, lowerCamelCase (S100 `^[a-z][a-zA-Z0-9]*$`). |
| Extension member on a system or third-party type, exported to Objective-C (`@objc`, `dynamic`) | Category semantics: a same selector silently overrides | Objective-C selector keeps the prefix: `@objc(cyl_badgeValue)`; Swift name is lowerCamelCase `cylBadgeValue` (S100 passes). |
| Extension member, Swift only, public | Static dispatch, resolved per module; a clash is a compile-time ambiguity, never a silent override | lowerCamelCase `cyl` prefix (guards against a future Apple member with the same name), no underscore. |
| Extension member, internal or private | Invisible to clients | No prefix. |
| Global function | Module namespace; `@_cdecl` / C symbols are global | No global functions in new code: a static member of a `CYL` type. Kept C-callable names keep the C symbol through `@_cdecl("CYLName")`; the Swift name is lowerCamelCase (`cylName` or a static member). |
| Constant | Module namespace; Objective-C constants are global symbols | `static let` on the owning type, lowerCamelCase (S115). An Objective-C constant name stays through an `@objc` class property with that name only where Objective-C callers need it. |
| Property / local / parameter | Scoped | lowerCamelCase, no underscores (S116, S117). |

Existing public names that break S100 / S115: rename the Swift name, keep the Objective-C name identical
(`@objc(cyl_oldName)`), and add `@available(*, deprecated, renamed: "newName")` forwards for Swift callers for one release.
Only those transitional forwards may stay flagged; list them for the owner to accept in SonarCloud (`// NOSONAR` does not
work in Swift). Tests and examples follow the same rules (test helpers are lowerCamelCase functions, e.g. `runLoop(_:)`
instead of `CYLRunLoop(_:)`).

## Other platforms

| Platform | Mechanism | Rule |
| --- | --- | --- |
| Kotlin (Android) | Packages (`com.cyl.search`); extension functions need an import | Public classes keep `CYL` (parity); functions, properties and extension functions: lowerCamelCase without prefix; constants `UPPER_SNAKE_CASE` in companion objects (Kotlin convention). |
| ArkTS (HarmonyOS), JavaScript, TypeScript | ES modules with explicit imports, no global namespace | Exported classes keep `CYL` (parity); members without prefix, lowerCamelCase. |
| Mini program | Component tag names map per page in `usingComponents` and may meet other libraries' tags | Keep the `cyl-` component names; members without prefix. |
| React Native | Native component and module names register globally (view registry, Objective-C runtime) | Keep the `Cylsearch` / `CYL` prefix on native component and module names; JavaScript members without prefix. |
| Dart (Flutter) | Libraries, `import ... as` prefixes; method channel names are global strings | Classes keep `CYL` (parity); members lowerCamelCase without prefix; channel and view-type ids keep a reverse-domain or `cyl` prefix. |

## Check

`grep -rnE "func [A-Za-z0-9]*_|func [A-Z]" Sources CYLSearchExample CYLSearchExampleTests` must list only kept
Objective-C-compatible forwards. SonarCloud is the reference where a project is analysed (CYLTabBarController,
CYLTableViewPlaceHolder): its S100 / S101 / S115 / S116 / S117 regular expressions are the rules above.
