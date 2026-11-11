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
```

## TODO

- TODO (status: written and linted, never run on GitHub; score 5/10): the
  macOS jobs have not run yet. Verified in this change: `shellcheck` and
  `actionlint` pass; `scripts/check-public-api-comments.sh` passes on the
  headers and fails on each forbidden form (`///`, one-line `/*! */`,
  `///<`, `/**< */`, trailing `//`); `scripts/ci-checkout-dependencies.sh`
  clones the sibling and keeps it on a second run. Not verified (Linux
  session, no Xcode): `pod install`, `pod lib lint`, the build, the analyzer
  and the tests. Check the first runs on GitHub Actions and fix what fails.
- TODO (known risk): "Fail on warnings in Sources/" fails the job on the first
  analyzer or compiler warning in the pod's sources. The current warning count
  is unknown.
- TODO (known risk): the sibling `CYLTableViewPlaceHolder` follows its default
  branch, so a change there can break this CI. Pin `CYL_PLACEHOLDER_REF` in the
  workflow if that happens.
- TODO (not copied): upstream's `# local-run-environment: macOS …, Xcode …`
  first line and `scripts/local-run-environment.sh` need a Mac. Add them when
  the workflow is first run locally.
- TODO (CYLTabBarController): once the Podfile depends on CYLTabBarController,
  the "CYLTabBarController commit" step warns when the pin is not the newest
  commit. It only warns; decide whether it should fail.
- TODO (maintenance): when upstream `ios.yml` changes, compare it and update
  this workflow and the commit recorded above.
