# Folder Instructions

This folder contains the iOS application source, resources, and app entry
configuration. Inherit the repository rules from `../instructions.md` and
`../AGENTS.md`.

- New app-owned classes and protocols use the `CYL` prefix.
- Preserve existing app and third-party names unless an intentional migration
  requires changing them.
- Keep user-visible UI text accessible and use public dependency headers only.
- Update the Xcode project explicitly whenever source files are added or moved.
- Keep Info.plist keys and Xcode build settings consistent.
