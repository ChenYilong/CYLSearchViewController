#!/bin/sh
# Usage: scripts/unit-tests.sh [simulator name]     e.g. scripts/unit-tests.sh "iPhone 17"
#
# Adapted from CYLTabBarController/scripts/unit-tests.sh.
# Runs the test action of the shared CYLSearchExample scheme (CYLSearchExampleTests) on an iOS simulator, on a Mac with
# Xcode. Without a name, the first available iPhone of the newest runtime. Builds into a new, empty derived data folder
# (AGENTS.md, "Clean builds"). Exits with xcodebuild's status; the log is build/unit-tests.log.
set -eu
cd "$(dirname "$0")/.."
DEVICE_NAME="${1:-}"
mkdir -p build

DEVICE_ID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
name = sys.argv[1]
devices = json.load(sys.stdin)["devices"]
for runtime in sorted(devices, reverse=True):
    if "iOS" not in runtime:
        continue
    for device in devices[runtime]:
        if (name and device["name"] == name) or (not name and device["name"].startswith("iPhone")):
            print(device["udid"]); sys.exit(0)
sys.exit(1)' "$DEVICE_NAME") || { echo "No iPhone simulator${DEVICE_NAME:+ named $DEVICE_NAME}"; xcrun simctl list devices available; exit 1; }
echo "Simulator: $DEVICE_ID"
xcodebuild -version

pod install

DERIVED_DATA=$(mktemp -d "${TMPDIR:-/tmp}/cyl-search-unit-tests.XXXXXX")
trap 'rm -rf "$DERIVED_DATA"' EXIT

set +e
xcodebuild test \
  -workspace CYLSearchExample.xcworkspace \
  -scheme CYLSearchExample \
  -destination "id=$DEVICE_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO > build/unit-tests.log 2>&1
STATUS=$?
set -e
grep -E "^Test Case .*(passed|failed)|error: -\[|Executed [0-9]+ tests" build/unit-tests.log || true
if [ "$STATUS" -ne 0 ]; then
  echo "xcodebuild test failed ($STATUS). Last lines:"
  tail -n 40 build/unit-tests.log
fi
exit "$STATUS"
