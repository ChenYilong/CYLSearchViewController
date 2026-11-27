# Project rules [`project-rules`]

- New project-owned types and identifiers use the `CYL` prefix. New UIKit
  category files use `+CYL`; category methods and properties use `cyl_`.
- Do not rename existing APIs or vendor symbols in a task that does not require
  it. Keep original copyright and attribution when adapting third-party code.
- The public integration surface of `CYLTableViewPlaceHolder` is its umbrella
  header. The example must not depend on private headers or implementation
  details.
- Keep the sample configurable through protocols or public properties. Avoid
  dependencies on `AppDelegate`, global state, or concrete model types.
- Keep all instructions and skill files in English.
