# Swift Coding Standard

The rules for Swift code in this repository: the core (`Sources/CYLSearchViewController/`) and the example
(`CYLSearchExample/`). They build on the official [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
and the installed skills `swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`,
`swift-architecture`, `uikit` and `uikit-layouting` (`.agents/skills`, pinned in `.agents/skills.json`). Where a
skill and this document differ, this document wins; where this document and an official Swift rule differ, the
official rule wins.

## Language and platform

- Swift 5 language mode (`SWIFT_VERSION = 5.0`, `ENV['SWIFT_VERSION'] = '5'` in the Podfile), iOS 15.0 and later,
  UIKit only. No third-party dependencies in the core.
- The pod builds with `use_frameworks!`; the module is `CYLSearchViewController`.
- Every UIKit type and every method that touches UIKit is used on the main thread. Mark types that own views
  `@MainActor` only when it does not change the Objective-C interface; UIKit subclasses are already main-actor
  isolated.

## Naming

- Every project-owned type, protocol and global function starts with `CYL` (types) or `cyl` (functions), as in the
  Objective-C code (`AGENTS.md`, "Project rules"). One primary type per file; the file is named after it.
- Follow the API Design Guidelines: clarity at the point of use, argument labels that read as phrases, no needless
  words, Boolean properties that read as assertions (`isIconified`, `showsVoiceButton`).
- Private helpers have no prefix (`private func applyStyle()`); members of an extension on a system type start with
  `cyl_` in Objective-C names and `cyl` in Swift names.

## Objective-C compatibility (the core)

The Objective-C example, the Objective-C tests and existing Objective-C callers must keep compiling unchanged
while the core moves to Swift.

- Public core classes inherit from `NSObject` (through UIKit) and carry `@objc(CYLName)` with the Objective-C
  class name, so `NSClassFromString`, archives and storyboards keep working.
- Every public member keeps its Objective-C selector: `@objc(searchBarView:textDidChange:)`,
  `@objc(setIconified:animated:)`. Properties keep their getter names (`@objc(isIconified)` for `getter=`).
- Delegate protocols are `@objc public protocol CYLNameDelegate: NSObjectProtocol` with `@objc optional`
  requirements and the original selectors.
- Enums exposed to Objective-C are `@objc public enum CYLName: Int` with the cases in the original order, so the
  raw values stay the same.
- Types Objective-C cannot express (generics, Swift-only enums with payloads, structs) stay internal or get an
  `@objc`-compatible wrapper. A declaration that must stay in a header uses `NS_SWIFT_NAME`, `NS_REFINED_FOR_SWIFT`
  or `NS_SWIFT_UNAVAILABLE`; that counts as translated (`docs/swift-migration.md`).
- Nullability is explicit: optional (`T?`) for every `nullable` and `null_resettable` value of the Objective-C
  API; a `null_resettable` property is `T!` with a default in its getter.

## Access control and structure

- `public` for the API, `open` only for classes meant to be subclassed by apps (`CYLSearchResultsViewController`
  is subclassed by the example, so it is `open`, with `open` overridable methods); everything else `private` or
  `internal`. Final by default: `public final class` unless subclassing is part of the API.
- Objective-C cannot subclass a Swift class. When a core class that the example subclasses in Objective-C moves to
  Swift, that example subclass moves to Swift in the same commit (a necessary example change).
- Objective-C callers import the module (`@import CYLSearchViewController;`), not single headers: a Swift class has
  no header of its own, only the generated `CYLSearchViewController-Swift.h`.
- Group code with `// MARK: -` sections: properties, initializers, public API, layout, events, private helpers.
  Protocol conformances go in their own extensions.
- Prefer `let`, value types and small functions. No force unwraps (`!`) or `try!` outside tests; use `guard`.
- Delegates are `weak var delegate: CYLNameDelegate?`. Closures that capture `self` capture it weakly when the
  closure is stored.

## Documentation comments

- Every public declaration has a documentation comment in the three-line block form `/**`, ` * text`, ` */`
  directly above it, one line or several (`AGENTS.md`, "Comments on public API"). No `///` in the core, no
  trailing comments.
- The first sentence summarizes; mention the Android API a member matches when it was added for parity
  (`docs/search-api-comparison.md`).

## Formatting

- 4-space indentation, lines up to 120 columns, one statement per line, trailing commas in multi-line literals.
- Spaces around binary operators, none inside parentheses; `else` on the same line as the closing brace.
- Imports at the top, sorted: system frameworks first.

## UIKit, localization and accessibility

- Layout follows the existing Objective-C behavior (frames where the original used frames); new views prefer Auto
  Layout (`uikit-layouting`). A search bar never covers any view (`AGENTS.md`, "Search bar placement").
- Every user-visible string comes from `CYLSearchResources.localizedString(forKey:)` (core bundle, four
  languages). Every control has an accessibility label; Dynamic Type is supported.

## Tests and verification

- Behavior is covered by the Objective-C tests in `CYLSearchExampleTests` until they are ported; a translation must
  keep every test green. New tests may use XCTest or Swift Testing (`swift-testing`).
- Before a commit: clean build of the example, `scripts/unit-tests.sh`, analyze with 0 warnings in `Sources/`,
  `scripts/check-public-api-comments.sh` (headers and Swift sources), and the score in `docs/swift-migration.md`.

## Examples never shape the core (2026-11-13)

When an Objective-C to Swift change of the core breaks an example's build, fix the example: example code has the lowest weight of all code here. Change any example code as needed; never keep a core API, overload, shim or deprecated alias only because an example uses it, and never lower the Swift core's quality (naming, types, optionality, access control) to fit an example. Compatibility matters only for callers outside the examples (published API users). The Swift coding standard (docs/swift-coding-standard.md) decides.
