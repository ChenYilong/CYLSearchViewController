# CI/CD

`.github/workflows/ios.yml` is modeled on CYLTabBarController's
`.github/workflows/ios.yml` at its newest commit across all branches:

| Field | Value |
|:---|:---|
| Commit | `d574501c1af217fb91347845085b46f047644ad9` |
| Branch | `feat/cross-platform-components` |
| Commit date | 2026-11-11 17:40:12 +1300 |

## Triggers

Pull requests, pushes to `master` and to `claude/**` branches, and manual runs
(`workflow_dispatch`). A newer run on the same ref cancels the older one.

## Jobs

| Job | Runner | What it does | Upstream counterpart |
|:---|:---|:---|:---|
| Changes | `ubuntu-latest` | A pull request that changes only `docs/`, `assets/` or `*.md` skips the macOS steps; the jobs still pass | Same |
| shellcheck | `ubuntu-latest` | `shellcheck scripts/*.sh` | Same |
| Public API comments | `ubuntu-latest` | `scripts/check-public-api-comments.sh` (AGENTS.md, "Comments on public API") | New here |
| pod lib lint | macOS | `scripts/pod-lint.sh lib --verbose` | Same |
| Example build and analyze | macOS | Clones the sibling `CYLTableViewPlaceHolder`, warns when the CYLTabBarController pin is stale, then runs `scripts/ci-build-example.sh build` and `analyze`; fails on warnings in `Sources/` | `framework` + `examples` |
| Unit tests | macOS | `scripts/unit-tests.sh` (test action of the shared `CYLSearchExample` scheme) | Same |

Not copied: the Carthage job (this pod ships no XCFramework) and the demo
matrix (this repository has one example).

The macOS runner is `macos-26`. Set the repository variable `MACOS_RUNNER` to
use another one (for example `xcode-27`) without editing the workflow.

## Sibling dependency

The Podfile uses `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`.
`scripts/ci-checkout-dependencies.sh` clones
`https://github.com/ChenYilong/CYLTableViewPlaceHolder` there when the folder is
missing and keeps an existing folder. `CYL_PLACEHOLDER_REF` picks a branch, tag
or commit; the default is the repository's default branch.

## Run locally

```sh
scripts/ci-checkout-dependencies.sh
scripts/check-public-api-comments.sh
scripts/pod-lint.sh lib --verbose
rm -rf build && scripts/ci-build-example.sh build
scripts/ci-build-example.sh analyze
scripts/unit-tests.sh "iPhone 17"
scripts/local-run-environment.sh
```

## Status

- First runs: `master` passed every job on 2026-11-11 (run 43007916007).
  On `feat/search-bar-view` (run 43100220331, 2026-11-12) every job passed
  except "Fail on warnings in Sources/", which found one analyzer warning:
  `-[CYLSearchBarView resignFirstResponder]` did not call super
  (`osx.cocoa.MissingSuperCall`). Fixed; a local analyze of the shared scheme
  reports no warning in `Sources/`.
- Warning count in `Sources/`: 0 (local analyze, Xcode 27.2). The pods have
  analyzer issues of their own; the gate covers `Sources/` only.
- `scripts/local-run-environment.sh` (copied from CYLTabBarController with
  attribution) writes the first line of `ios.yml`:
  `# local-run-environment: macOS 27.3 (26C5035r), Xcode 27.2 (27B52)`.
  Run it before a local build.

## Decisions

- The sibling `CYLTableViewPlaceHolder` follows its default branch, so CI
  finds a breaking change there early. If it breaks this repository, set
  `CYL_PLACEHOLDER_REF` in the workflow to the last good commit.
- The "CYLTabBarController commit" step only warns when the Podfile pin is not
  the newest upstream commit. The newest commit moves several times a day
  (`caf3c92` to `d36c708` on 2026-11-11 and 12), so failing would block
  unrelated changes; the pin is refreshed with `scripts/latest-cyl-commit.sh`.

## Maintenance

- When upstream `ios.yml` changes, compare it and update this workflow and the
  commit recorded above.

## DONE (2026-11-12): screenshot rules in the build and CI/CD sections

- Context: screenshots of this repository so far live in `docs/assets/` (for example the Swift ports in
  `docs/search-api-comparison.md`, taken on the iPhone 17 simulator, iOS 26.1). The rule is asked while the Swift
  migration of the core (`docs/swift-migration.md`) is in progress on `feat/swift-core`; tasks run in the order
  they were given, so this one follows it.
- Requirements:
  1. Find the build / CI/CD sections of the instruction files and the skills; create them where missing; make sure
     the text is written. Everything in English.
  2. Every screenshot, CI/CD screenshots and local build screenshots alike, is saved with the related document in
     `docs/` (create a document when none fits) and committed to the git repository.
  3. When the result looks as expected, update `README.md` with the latest screenshots (find the section, or create
     it).
  4. Label each screenshot with the platform (iOS, Android, Flutter, React Native, HarmonyOS, mini program), the
     environment (OS version, simulator version, platform SDK version), the repository version or commit link, and
     the time it was taken.
  5. Use clear, original-resolution screenshots.
- Prompt (verbatim): "continue in order. 找到instructions相关文件，以及skills相关文件，找到构建build ci cd章节。如果没有就新建，确保写入成功，全英文写入如下内容：所有截图，包括CI CD截图以及本地构建截图，全部保存在docs文件夹相关文档中，如果无相关文档就新建文档，保存图片到git仓库。并在合适的时机，你认为效果符合预期就更新最新图片到readme，找到相关章节如果没有就新建，并标注运行平台iOS android flutter reactnative 鸿蒙 小程序。运行环境 操作系统版本，模拟器版本，对应平台版本sdk版本（iOS android flutter reactnative 鸿蒙 小程序）本仓库版本号或commit地址。当前时间。截图使用清晰原图。"
- Prompt (English): "Continue in order. Find the instruction files and the skill files, and their build / CI/CD
  section; create it if missing, make sure it is written, and write the following, all in English: all screenshots,
  including CI/CD screenshots and local build screenshots, are saved in the related document in the docs folder
  (create one if there is none) and the images are saved to the git repository. At a suitable time, when you judge
  the result as expected, update README with the latest images (find the related section or create it), and label
  the platform (iOS, Android, Flutter, React Native, HarmonyOS, mini program), the environment (OS version,
  simulator version, the platform's SDK version), this repository's version number or commit link, and the current
  time. Use clear original screenshots."
- Additional requirements (second prompt, same day):
  6. Take and publish screenshots at key milestones: when a `TODO` or `Linux` note can be removed, when a PR can be
     merged, or when the result is judged as expected with no bug and no open issue.
  7. README screenshots show the key details, cropped; not full screen unless needed. Combine several key details
     into one stitched image.
  8. Stitching layout, in order of preference: one image per row stacked top to bottom (easiest on a phone; the
     prompt says "横向排布", read here as the vertical arrangement because the last choice is horizontal), then two
     columns over several rows, and last a horizontal row of at most three images.
  9. The rules go into the build / CI/CD sections of the instruction files and the skills (created when missing),
     in English, with the requirements above.
- Prompt 2 (verbatim): "追加截图细节，全英文：关键节点指的是比如可以删除todo关键词，或者Linux关键词，或者可以merge pr。或者你评估已经符合预期效果无bug 无issue。readme中展示的截取关键细节，如无必要不要全屏截取。最好是采用凭借格式展示多个关键细节。拼接截图，优先采用横向排布，方便手机端查看。其次是双列 多行拼接。最差是横向拼接。横向拼接一行最多三列。找到instructions相关文件，以及skills相关文件，找到构建build ci cd章节。如果没有就新建，确保写入成功，全英文写入如下内容：所有截图，包括CI CD截图以及本地构建截图，全部保存在docs文件夹相关文档中，如果无相关文档就新建文档，保存图片到git仓库。并在合适的时机，你认为效果符合预期就更新最新图片到readme，找到相关章节如果没有就新建，并标注运行平台iOS android flutter reactnative 鸿蒙 小程序。运行环境 操作系统版本，模拟器版本，对应平台版本sdk版本（iOS android flutter reactnative 鸿蒙 小程序）本仓库版本号或commit地址。当前时间。截图使用清晰原图。"
- Prompt 2 (English): "Add screenshot details, all in English: key milestones are, for example, when the TODO
  keyword or the Linux keyword can be deleted, when a PR can be merged, or when you judge the result as expected with
  no bug and no issue. README shows cropped key details; do not capture the full screen unless necessary. Preferably
  show several key details in a stitched format. Stitched screenshots: prefer the horizontal arrangement, easy to
  view on a phone; next, two columns over several rows; worst, horizontal stitching, at most three columns in a row.
  (Then the first prompt's rules again: build / CI/CD sections, screenshots in docs, README update with platform,
  environment, version or commit, time, clear original images.)"
- Result: the rules are in `AGENTS.md` (Verification → "Screenshots of builds and CI/CD"), `instructions.md`
  ("Screenshots of builds and CI/CD", next to Verification), `docs/instructions.md`, the `cyl-verify` skill (CI/CD →
  "Screenshots"), the `cyl-docs` skill ("Screenshots in docs and README") and a pointer in every other `cyl-*`
  skill. New tool: `scripts/stitch-screenshots.swift` (one column = top to bottom, two columns, or a row of three).
  First use: `README.md` has a new "Screenshots" section with four cropped key details of the all-Swift build,
  stacked top to bottom and labeled with platform, host, simulator, SDK, commit and time; the same image and labels
  are in `docs/swift-migration.md`, and the port screenshots in `docs/search-api-comparison.md` got their labels.
- Interpretation recorded: the first layout preference ("横向排布") is read as stacking top to bottom, because
  the last preference is the horizontal row; to be confirmed by the user.
