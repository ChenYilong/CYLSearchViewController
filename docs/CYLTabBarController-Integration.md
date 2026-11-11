# CYLTabBarController Integration

This project integrates CYLTabBarController by default. Its instruction and
skill rules were adapted from CYLTabBarController at its newest commit across
all branches, found by commit timestamp:

| Field | Value |
|:---|:---|
| Commit | `caf3c925966f71edfc87d1dd2ed9f03cbad6aba1` |
| Branch | `feat/cross-platform-components` (not `master`) |
| Commit date | 2026-11-11 15:54:48 +1300 |
| Read on | 2026-11-11 |

## Default integration

Unless a task says otherwise, every `CYLTabBarController` in the example layer:

1. is created from a local configuration file in the app bundle
   (`+tabBarControllerWithConfigurationFile:error:`);
2. has a plus button declared under `CYLTabBarControllerPlusButton`, whose
   `CYLTabBarItemPageIdentifier` resolves to the plus child view controller;
3. resolves its pages through `CYLTabBarPageRegistry` providers;
4. depends on the newest CYLTabBarController commit through CocoaPods
   (`scripts/latest-cyl-commit.sh --podfile`).

Recipe: `.agents/skills/cyl-tabbar-integration/SKILL.md`.

## What was copied and adapted

| Upstream source | Written here | Notes |
|:---|:---|:---|
| `AGENTS.md`: Depending on CYLTabBarController, accessibility, clean builds, bilingual reading, commit author line | `AGENTS.md` "CYLTabBarController", "Skills", "Commit readiness"; `instructions.md` "CYLTabBarController", "Commit readiness" | Library-only rules (public API, localization bundles, Android, React Native, Flutter, docs generators) left out |
| `CLAUDE.md` (`@AGENTS.md`) | `CLAUDE.md` unchanged | Already identical |
| `.claude/skills -> ../.agents/skills` | `.claude/skills` symlink | Same layout as upstream |
| `cyl-plus-button` | `cyl-plus-button` (new) | Rewritten around the configuration-file plus button |
| `cyl-new-project`, `cyl-verify`, `cyl-api-map`, `cyl-docs`, `cyl-xcode-compat` | Same skill names, new "CYLTabBarController" sections | Upstream paths replaced by pinned upstream links |
| `scripts/latest-cyl-commit.sh` | `scripts/latest-cyl-commit.sh` | Copied with attribution |
| — | `cyl-tabbar-integration` (new) | Configuration file + plus child view controller recipe |

Not copied: `cyl-theme`, `cyl-tab-animation`, and third-party vendored skills
(`.agents/skills.json`), which are library-specific or carry their own licenses.

## TODO

- TODO (status: rules written, not implemented in code; score 2/10): the
  example does not yet integrate CYLTabBarController. Remaining work: add the
  pinned `:git`/`:commit` pod line, `CYLSearchExample/CYLTabBarConfiguration.json`
  (in the Resources phase, explicit file reference), page providers for each
  page ID including the plus page, and a scene/app delegate root created from
  the file. Constraint: the search tab must stay inside a
  `UINavigationController` so the Issue #1317 workaround still applies;
  `Sources/` must not import CYLTabBarController.
- TODO (verification): `pod install`, a clean build and analyze of the shared
  scheme, and a simulator run showing tabs and the plus button from the file,
  the plus child view controller opening, and VoiceOver labels. None of this
  was run: this session had Linux only, without Xcode or a simulator.
- TODO (API risk): the example JSON in the skill uses SF Symbol names
  (`system:`) and key names read from upstream `docs/Configuration-File.md` at
  `caf3c92`; confirm them against the commit actually pinned in the Podfile,
  since the newest commit sits on a feature branch and may change.
- TODO (maintenance): when upstream instruction files change, re-run
  `scripts/latest-cyl-commit.sh`, compare its `AGENTS.md` and `cyl-*` skills,
  and update the pinned commit in this document and the skill links.
