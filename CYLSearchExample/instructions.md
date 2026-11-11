# Folder Instructions

- Follow the repository's `instructions.md` and `AGENTS.md`.
- Integrate the search component and the sibling placeholder library as local
  CocoaPods dependencies. Keep reproduction-specific code in the example.
- Example sources and the app Info.plist live in this directory. The Xcode
  project and Podfile remain at the repository root.
- Keep project file references and the test target's header search path in
  sync when moving example sources.

## CYLTabBarController

- Every `CYLTabBarController` here is created from a local configuration file
  in this directory and has a plus button with a plus child view controller,
  unless a task says otherwise. Follow the `cyl-tabbar-integration` skill.
- Register a page provider for every page ID before creating the controller,
  and keep search pages inside a `UINavigationController`.
