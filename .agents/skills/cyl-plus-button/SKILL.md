---
name: cyl-plus-button
description: "Rules and limits of the CYLTabBarController plus button as used in the CYLSearchViewController example: configuration-file keys, the plus child view controller, title alignment, Liquid Glass stand-in, images, badges and touches. Use before writing or changing a plus button."
---

# CYLPlusButton in this project

Adapted from CYLTabBarController's `cyl-plus-button` skill at commit `caf3c92`.
Read the upstream
[PlusButton](https://github.com/ChenYilong/CYLTabBarController/blob/caf3c925966f71edfc87d1dd2ed9f03cbad6aba1/docs/PlusButton.md)
and
[Configuration-File](https://github.com/ChenYilong/CYLTabBarController/blob/caf3c925966f71edfc87d1dd2ed9f03cbad6aba1/docs/Configuration-File.md)
documents before changing images, the stand-in or theming.

## Default in this project: from the configuration file

The example registers no `CYLPlusButton` subclass. The plus button comes from
`CYLTabBarControllerPlusButton` in the local configuration file, and always has
a plus child view controller (`cyl-tabbar-integration`).

- Required keys: `CYLTabBarItemTitle`, `CYLTabBarItemImage`, and
  `CYLTabBarItemPageIdentifier` (its own page, which becomes the plus child
  view controller). Optional: `CYLTabBarItemSelectedTitle`,
  `CYLTabBarItemSelectedTitleColor`, `CYLTabBarItemSelectedImage`,
  `CYLTabBarItemIdentifier`, `CYLTabBarItemTitleColor` / `CYLTabBarItemTitleFont`.
- Layout keys: `CYLPlusButtonIndexInTabBar`, `CYLPlusButtonCenterYMultiplier` /
  `CYLPlusButtonCenterYOffset`, `CYLPlusButtonAlignsTitle`,
  `CYLPlusButtonKeepsTitleVisible`, `CYLPlusButtonShowsSelection`,
  `CYLPlusButtonSize`, `CYLPlusButtonImageSize`, `CYLPlusButtonBackgroundImage`.
- One plus button per `CYLTabBarControllerContext`. The plus button is not
  counted in the tab items.
- Taps: `CYLTabBarControllerPlusButtonAction` (code only). The action still
  runs when the button has its own page.
- In code without a file (only when a task asks for it):
  `+[CYLPlusButton cyl_registerPlusButtonWithAttributes:action:context:]`.
  A subclass registers with `+registerPlusButton` before any
  `CYLTabBarController` is created, never in `+load`.

## Title alignment: decide first

| The app wants | Do | Avoid |
|:---|:---|:---|
| The title on the tab titles' line | Align titles **and give the button a title** | Aligning with no title: on Liquid Glass the button covers the whole tab item |
| A title drawn on a background image | Do not align; place it with the center Y keys | Aligning: the title leaves the picture |
| No title | Do not align | |

With alignment on Liquid Glass the title moves into the tab item under the
button, and `currentTitle` is nil: read the plus child view controller's
`tabBarItem.title` instead.

## Liquid Glass (iOS 26+, not FlatDesign) with a plus child view controller

- The real button sits in `CYLTabBar`; a stand-in sits in the selected layer.
  Both draw only the normal image, selected or not.
- Aligned titles line up by icon only.
- `+isLiquidGlassActive` is also YES with FlatDesign on iOS 26: a Liquid Glass
  guard checks both.
- Badges go to both layers through the library; do not add them to one view.

## Other limits

- Late, replaced or removed images must end like the same picture set at
  launch. Plus button images are drawn as original, never tinted.
- A background-image plus button takes no icon from a theme.
- `plusButton.reportsTapsToDelegate` (default YES) controls
  `tabBarController:didSelectControl:`. `cyl_userInteractionDisabled` and
  `cyl_shouldNotSelect` are deprecated.
- Do not override `-touchableRect` to return `frame`.
- Subviews that take touches get them first (#202).
- `CYL_NAVIGATION_TITLE_FOLLOWS_TAB_BAR_ITEM(plusChildViewController)` makes
  the plus page's navigation title follow the plus button's title.
- The plus button and its page need an accessibility label (the title is
  enough when present).

## Task log before every task

Before any task, log it as `TODO` in the most suitable document in `docs/`
(else `docs/task-log.md`): context, the user's requirements, the user's prompt
(verbatim plus English translation) and a status line. Commit and push it,
then start; mark it `DONE (YYYY-MM-DD)` with the result when the task ends.
Full rule: `AGENTS.md`, "Task log before every task".

## Swift

Swift code follows `docs/swift-coding-standard.md` and the third-party Swift skills in `.agents/skills`
(`swift-api-design-guidelines`, `swift-language`, `swift-concurrency`, `swift-testing`, `swift-architecture`,
`uikit`, `uikit-layouting`). The core's translation and its score: `docs/swift-migration.md`.

## Screenshots

Screenshots of builds and CI/CD: committed, shown in `docs/`, clear originals, labeled with platform,
environment, version or commit, and time; README updated at key milestones (`AGENTS.md`, "Screenshots of builds
and CI/CD").

## Open pull requests and issues of projects we translate

When we translate or port another GitHub project's code (for example `android/`), merge its open pull requests
(before translating, or translate and merge them afterwards), list its open issues in a `docs/` table (issue link,
description, fix status `TODO`), fix them in our code and score after every fix until 100; a translation that has not
started begins at 60. Full rule: `AGENTS.md`, same section.

## Raised plus button in examples

When an example demonstrates a plus button, always prefer the raised effect: the top of the plus button rises
above the top edge of the tab bar (`CYLPlusButtonCenterYMultiplier` below 0.5 with a button taller than half the bar,
or `CYLPlusButtonCenterYOffset`). Keep the whole button tappable and never let it cover the page content above the
bar. Example: `android/merged/app/src/main/assets/CYLTabBarConfiguration.json` (56 dp, multiplier 0.3).

## Screenshot stitching order

Stitched screenshots: stacked top to bottom first, then two columns over several rows, then one row of at most
three. Correction (user, 2026-11-12): the original wording, "prefer the horizontal arrangement" and "worst is horizontal stitching", contradicted itself; the rule is to prefer the vertical arrangement, one image per row stacked top to bottom.
