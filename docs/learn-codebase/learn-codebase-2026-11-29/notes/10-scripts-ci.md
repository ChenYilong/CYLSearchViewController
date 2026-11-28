> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# Scripts and CI: reading notes

Saved during the 2026-11-29 full read (work list `learn-codebase-2026-11-29`). The text under "Saved note" is **verbatim**; it was written at that moment, so `next=…` markers are progress bookkeeping. Where it disagrees with [../02-findings.md](../02-findings.md), the findings file is newer.

## Saved note

Read all chunks 133-143. API tables come from android/merged/scripts/api-alignment.py parse_swift, reused by the HarmonyOS and mini program scripts; sync-discover-data.py copies iOS Discover json to all examples; pod-lint.sh checks out Podfile pins; release-ram/*.ps1 stop apps/emulators. Nested RN .github/workflows/ci.yml never runs (only root ios.yml and screenshot-labels.yml are in root .github). Working-tree diff of scripts/harmonyos-api-alignment.py = +2 lines (applyNavigationFieldStyle MANUAL row). No script was run successfully (python not on bash PATH).

## Files read (47)

- `.github/workflows/ios.yml` (241)
- `.github/workflows/screenshot-labels.yml` (37)
- `android/merged/scripts/api-alignment.py` (298)
- `android/merged/scripts/import-ios-resources.py` (51)
- `android/merged/scripts/ios-alignment.mjs` (342)
- `CrossPlatform/react-native-cylsearch/.github/actions/setup/action.yml` (36)
- `CrossPlatform/react-native-cylsearch/.github/ISSUE_TEMPLATE/bug_report.yml` (67)
- `CrossPlatform/react-native-cylsearch/.github/ISSUE_TEMPLATE/config.yml` (8)
- `CrossPlatform/react-native-cylsearch/.github/workflows/ci.yml` (180)
- `CrossPlatform/react-native-cylsearch/example/scripts/fetch-cyltabbar.sh` (26)
- `CrossPlatform/wechat-miniprogram-cylsearch/scripts/devtools-screenshots.js` (128)
- `CrossPlatform/wechat-miniprogram-cylsearch/scripts/import-ios-resources.js` (72)
- `CrossPlatform/wechat-miniprogram-cylsearch/scripts/sync-example.js` (124)
- `harmonyos/scripts/check-accessibility-i18n.mjs` (115)
- `harmonyos/scripts/check-ios-parity.mjs` (88)
- `harmonyos/scripts/host-logic-test.mjs` (892)
- `harmonyos/scripts/import-android-strings.py` (36)
- `harmonyos/scripts/import-cyltabbar-localizations.mjs` (74)
- `harmonyos/scripts/import-ios-resources.py` (100)
- `harmonyos/scripts/sync-sub-repositories.py` (102)
- `harmonyos/scripts/sync-sub-repositories.sh` (76)
- `release-ram.ps1` (68)
- `scripts/check-commit-message.sh` (44)
- `scripts/check-example-fold.sh` (18)
- `scripts/check-example-taglist.sh` (39)
- `scripts/check-licenses.sh` (59)
- `scripts/check-public-api-comments.sh` (71)
- `scripts/check-screenshot-labels.sh` (56)
- `scripts/ci-build-example.sh` (43)
- `scripts/ci-checkout-dependencies.sh` (24)
- `scripts/example-screenshots.sh` (88)
- `scripts/harmonyos-api-alignment.py` (163)
- `scripts/harmonyos-scorecard.py` (105)
- `scripts/latest-cyl-commit.sh` (30)
- `scripts/local-run-environment.sh` (45)
- `scripts/miniprogram-api-alignment.py` (183)
- `scripts/pod-lint.sh` (48)
- `scripts/public-api-doc-coverage.sh` (68)
- `scripts/publish-screenshots.sh` (57)
- `scripts/release-ram/close-explorer-windows.ps1` (54)
- `scripts/release-ram/restart-emulators.ps1` (249)
- `scripts/release-ram/set-brightness.ps1` (55)
- `scripts/release-ram/stop-apps.ps1` (55)
- `scripts/stitch-screenshots.ps1` (133)
- `scripts/stitch-screenshots.swift` (159)
- `scripts/sync-discover-data.py` (129)
- `scripts/unit-tests.sh` (48)

Declarations with line numbers: [../reference/10-scripts-ci.md](../reference/10-scripts-ci.md)
