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
