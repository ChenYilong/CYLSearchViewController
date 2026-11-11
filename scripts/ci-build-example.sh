#!/bin/bash
# Usage: scripts/ci-build-example.sh [build|analyze] [extra xcodebuild settings...]
#
# Adapted from CYLTabBarController/scripts/ci-build-example.sh.
# Builds (default) or statically analyzes the CYLSearchExample scheme for the iOS Simulator, without code signing.
# - Runs `pod install` first; the Podfile is not changed.
# - Uses build/DerivedData/example; delete build/ for a clean build (AGENTS.md, "Clean builds").
# - Writes build/<action>.log and appends a row to build/summary.md, then exits with xcodebuild's status.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"

ACTION=build
if [[ "${1:-}" == "build" || "${1:-}" == "analyze" ]]; then
  ACTION="$1"
  shift
fi
mkdir -p build

pod install

ANALYZE_SETTINGS=()
if [[ "$ACTION" == "analyze" ]]; then
  ANALYZE_SETTINGS=(CLANG_ANALYZER_OUTPUT=plist-html "CLANG_ANALYZER_OUTPUT_DIR=$ROOT/build/analyzer")
fi

set +e
xcodebuild "$ACTION" \
  -workspace CYLSearchExample.xcworkspace \
  -scheme CYLSearchExample \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$ROOT/build/DerivedData/example" \
  CODE_SIGNING_ALLOWED=NO \
  COMPILER_INDEX_STORE_ENABLE=NO \
  ${ANALYZE_SETTINGS[@]+"${ANALYZE_SETTINGS[@]}"} "$@" 2>&1 | tee "$ROOT/build/$ACTION.log"
STATUS=${PIPESTATUS[0]}
set -e

WARNINGS=$(grep -c ': warning: ' "$ROOT/build/$ACTION.log" || true)
RESULT="❌"
if [[ "$STATUS" -eq 0 ]]; then RESULT="✅"; fi
echo "| $ACTION | \`CYLSearchExample\` | $RESULT | $WARNINGS |" >> "$ROOT/build/summary.md"
exit "$STATUS"
