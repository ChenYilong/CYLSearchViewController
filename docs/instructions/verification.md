# Verification [`verification`]

Run `pod install`, validate the project with Xcodeproj/CocoaPods, build and
analyze the shared scheme, and run tests when available. Do not claim a visual
reproduction or fix without launching the sample on a simulator.

- **CI/CD**: `.github/workflows/ios.yml`, modeled on CYLTabBarController's
  `ios.yml`. It runs shellcheck, the public API comment check,
  `pod lib lint`, the example build and analyzer (warnings in `Sources/` fail
  it) and the unit tests. The default macOS runner is `macos-26`; the
  `MACOS_RUNNER` variable changes it. Run the same scripts locally before
  pushing; see `docs/CI-CD.md`.
- A script added under `scripts/` must pass `shellcheck`. A workflow change
  must pass `actionlint`.

## Before pushing (moved from `instructions.md`, 2026-11-29)

- Build the shared scheme for an installed simulator. Report simulator behavior as unverified unless the app was
  actually launched and exercised.
- Preserve the existing project's license and third-party notices.
- Run locally: `scripts/ci-checkout-dependencies.sh`, `scripts/check-public-api-comments.sh`,
  `scripts/pod-lint.sh lib`, `scripts/ci-build-example.sh build|analyze` and `scripts/unit-tests.sh`.
