# Comments on public API [`public-api-comments`]

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
