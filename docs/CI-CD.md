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
