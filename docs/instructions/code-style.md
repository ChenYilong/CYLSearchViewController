# Code style: naming, Swift, API comments (tag: `code-style`)

Details of the `code-style` tag of [AGENTS.md](../../AGENTS.md) and [instructions.md](../../instructions.md). Moved here unchanged on 2026-11-22 (the instruction files keep a short summary per tag); where `AGENTS.md` and `instructions.md` worded a section differently, both wordings are kept. Code wins over the text, as before.

## Swift

The core is Swift (`Sources/CYLSearchBar`; the translation record and its score: `docs/swift-migration.md`). All Swift code
follows `docs/swift-coding-standard.md` and the Swift skills in `.agents/skills` (`swift-api-design-guidelines`,
`swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`, `uikit`, `uikit-layouting`; third-party,
pinned in `.agents/skills.json`, never edited by hand). Public Swift API keeps the Objective-C class names and
selectors (`@objc(...)`), so Objective-C callers keep working; documentation comments are three-line `/** */`
blocks.

## Swift (instructions.md wording)

- Write Swift by `docs/swift-coding-standard.md` and the Swift skills in `.agents/skills` (pinned third-party
  copies listed in `.agents/skills.json`; do not edit them).
- The core (`Sources/CYLSearchBar`) is Swift; record each step and its score in `docs/swift-migration.md`.
- Keep Objective-C class names and selectors with `@objc(...)`; change the example only where Objective-C cannot use
  the Swift class directly (for example an Objective-C subclass of a core class).

## Comments on public API

Callers read a public API's comment through the IDE's documentation (Xcode
Quick Help, the generated Swift interface, Android Studio, editor hovers).
Only a documentation comment gets there whole. The multi-line rule is adapted
from CYLTabBarController's `AGENTS.md`, "Comments on public API" (commit
`63c0edc`). The rules below are this project's own and win over upstream.

- **The official rules decide.** Every comment format follows the official
  documentation rules of its language. The rules below choose among the forms
  an official rule allows. Where a rule below contradicts an official rule,
  the official rule wins.
- **Multi-line comments on public API are one documentation block**, never
  stacked single-line comments, right above the declaration with nothing in
  between.
- **Single-line comments use the block format too.** The format requirements
  for multi-line public API comments also apply to single-line public API
  comments. In a language whose block form is officially allowed, a one-line
  comment is still three lines above the declaration:

  ```objc
  /*!
   * Text.
   */
  - (void)example;
  ```

  - Never put the block on one line (`/*! Text. */`).
  - Never add a trailing comment after a declaration or an enum value:
    no `/**< */`, `/*!< */`, `///<` or `//`.
- **One comment format per public file.** In a file that contains public API,
  every documentation comment uses the same format, long or short.
- **All platforms and all languages.** Use the official documentation form of
  each language:

  | Language | Format | Official source |
  |:---|:---|:---|
  | Objective-C, C, C++ headers | `/*!` … ` * ` … ` */` | Xcode Quick Help / HeaderDoc (Apple) |
  | Swift | `/**` … ` * ` … ` */` (Swift does not read `/*!`) | Swift Markup, DocC (allows `///` and `/** */`) |
  | Kotlin | `/**` … ` * ` … ` */` | KDoc (kotlinlang.org) |
  | Java | `/**` … ` * ` … ` */` | Javadoc (Oracle) |
  | TypeScript | `/**` … ` * ` … ` */` | TSDoc |
  | JavaScript | `/**` … ` * ` … ` */` | JSDoc |
  | Python | Triple double-quoted docstring as PEP 257 says: a one-line docstring keeps its quotes on the same line; a multi-line docstring is a summary line, a blank line, then the closing `"""` on its own line | PEP 257 |
  | Go | `//` line comments right above the declaration, no blank line | Effective Go, go.dev/doc/comment |
  | C# | `///` lines with XML tags (`<summary>`, `<param>`, `<returns>`) | Microsoft Learn, XML documentation comments |
  | Rust | `///` (outer) and `//!` (inner) doc comments | Rust Style Guide, rustdoc book |
  | Dart | `///` lines | Effective Dart, "DO use `///` doc comments" |

  A language with no block documentation form, or whose official guide
  requires line doc comments (Go, C#, Rust, Dart above), uses that one form
  throughout the file. A short comment is then a single doc-comment line, and
  a long one is consecutive lines of the same form.

## Comments on public API (instructions.md wording)

- All comment formats follow the official documentation rules of their
  language. The rules below choose among the officially allowed forms; where
  one contradicts an official rule, the official rule wins.
- A multi-line comment on a public declaration is one documentation block,
  never stacked single-line comments, right above the declaration.
- The format requirements above for multi-line public API comments also apply
  to single-line public API comments. Where the block form is officially
  allowed, a one-line comment is written on three lines above the declaration
  (`/*!`, ` * Text.`, ` */`). Never write it on one line (`/*! Text. */`), and
  never add a trailing `/**< */`, `/*!< */`, `///<` or `//` after a
  declaration or an enum value.
- In a file that contains public API, keep the comment format uniform: one
  format for long and short comments.
- This applies to all platforms and all languages:
  - Objective-C `/*! */`.
  - Swift, Kotlin, Java, TypeScript and JavaScript `/** */`.
  - Python: PEP 257 docstrings.
  - Go `//`, C# `///` with XML tags, Rust `///`, Dart `///`: these are the
    official forms.

  A language with no block form uses its only documentation comment form
  throughout the file. Full rule and sources: `AGENTS.md`, "Comments on
  public API".

## Naming

- Write all instruction and skill files in English.
- Prefix every new project-owned public class, protocol, enum and type with `CYL`. Name a class file after its
  primary type. (Re-evaluated 2026-11-22 against SonarCloud, skill `cyl-naming`: the prefixes exist for the global
  Objective-C namespace and category overrides; Swift, Kotlin, ArkTS, JavaScript and Dart have module namespaces.)
- Functions, methods, properties and constants are lowerCamelCase without underscores (SonarCloud swift:S100, S115,
  S116, S117); no new global functions or global constants: use static members of a `CYL` type.
- Objective-C category files keep `<SystemClass>+CYL<Feature>.h` / `.m` and the `cyl_` prefix. A Swift extension member
  on a system or third-party type keeps `cyl_` only in its Objective-C selector (`@objc(cyl_name)`); its Swift name is
  `cylName` when public and unprefixed when internal or private.
- Renaming a shipped name: keep the Objective-C name, add a deprecated Swift forward for one release.
- Apply these rules to copied or newly introduced code. Remove unrelated
  third-party prefixes from new code and retain source attribution.
- Do not rename existing project APIs or vendor code as part of unrelated
  changes.
