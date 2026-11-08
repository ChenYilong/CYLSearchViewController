# Folder Instructions

This folder contains the search screen, its app-level composition, and scene
entry code. Inherit the application and repository instructions from
`../../instructions.md` and `../../../instructions.md`.

- Keep the search screen dependent on `CYLSearchDataProviding`, not on a
  concrete store, `AppDelegate`, or global state.
- Keep UIKit category additions in separately named `+CYL` files and prefix
  category members with `cyl_`.
- Use `CYL`-prefixed names for all new project-owned types and identifiers.
- Add every source file to the correct Xcode target with explicit references.
