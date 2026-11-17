#!/usr/bin/env bash
# Usage: scripts/example-screenshots.sh [simulator name]
#
# Adapted from CollectionViewClassifyMenu/scripts/example-screenshots.sh.
# Builds CYLSearchExample for an iOS simulator, opens each tab (`-CYLDemoTab <n>`) and each row of the demo menu
# (`-CYLDemoTab 1 -CYLDemoRow <n>`), and saves one screenshot per screen in build/screenshots/<name>.png at the
# simulator's original pixels. Needs a Mac with Xcode. scripts/publish-screenshots.sh publishes them in CI.
set -euo pipefail
cd "$(dirname "$0")/.."
DEVICE_NAME="${1:-}"
OUT="$PWD/build/screenshots"
BUILD="$PWD/build/screenshots-build"
rm -rf "$OUT"
mkdir -p "$OUT"

DEVICE_ID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
name = sys.argv[1]
devices = json.load(sys.stdin)["devices"]
for wanted in ([name] if name else ["iPhone 17", ""]):
    for runtime in sorted(devices, reverse=True):
        if "iOS" not in runtime:
            continue
        for device in devices[runtime]:
            if (wanted and device["name"] == wanted) or (not wanted and device["name"].startswith("iPhone")):
                print(device["udid"]); sys.exit(0)
sys.exit(1)' "$DEVICE_NAME") || { echo "No iPhone simulator${DEVICE_NAME:+ named $DEVICE_NAME}"; exit 1; }
echo "Simulator: $DEVICE_ID"
xcodebuild -version
xcrun simctl boot "$DEVICE_ID" 2> /dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b
xcrun simctl status_bar "$DEVICE_ID" override --time 9:41 --batteryState charged --batteryLevel 100 \
  --cellularBars 4 --wifiBars 3 || true

pod install
rm -rf "$BUILD"
xcodebuild build \
  -workspace CYLSearchExample.xcworkspace \
  -scheme CYLSearchExample \
  -sdk iphonesimulator \
  -destination "id=$DEVICE_ID" \
  -derivedDataPath "$BUILD" \
  CODE_SIGNING_ALLOWED=NO > "$OUT/build.log" 2>&1 || { tail -n 40 "$OUT/build.log"; exit 1; }
APP=$(find "$BUILD/Build/Products" -maxdepth 2 -name 'CYLSearchExample.app' -type d | head -n 1)
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")
xcrun simctl install "$DEVICE_ID" "$APP"
echo "App: $APP ($BUNDLE_ID)"

FIRST=1
FAILED=0
# capture <name> <launch arguments...>
capture() {
  local name="$1"
  shift
  local attempt
  for attempt in 1 2 3; do
    xcrun simctl launch --terminate-running-process "$DEVICE_ID" "$BUNDLE_ID" "$@" > /dev/null
    sleep 8
    if [ "$FIRST" -eq 1 ]; then sleep 10; FIRST=0; fi
    if xcrun simctl spawn "$DEVICE_ID" launchctl list | grep -q "UIKitApplication:$BUNDLE_ID"; then
      xcrun simctl io "$DEVICE_ID" screenshot "$OUT/$name.png" > /dev/null
      echo "Captured $name ($*)"
      xcrun simctl terminate "$DEVICE_ID" "$BUNDLE_ID" || true
      return 0
    fi
    echo "$name: the app is not running (attempt $attempt)"
    find "$HOME/Library/Logs/DiagnosticReports" -name 'CYLSearchExample*' -newer "$OUT/build.log" \
      -exec tail -n 60 {} \; 2> /dev/null || true
  done
  FAILED=$((FAILED + 1))
}

capture tab0-search -CYLDemoTab 0
capture tab1-examples -CYLDemoTab 1
capture tab2-search-bar -CYLDemoTab 2
capture tab3-tag-style -CYLDemoTab 3
capture tab4-discover -CYLDemoTab 4
capture menu0-reproduction -CYLDemoTab 1 -CYLDemoRow 0
capture menu1-styles -CYLDemoTab 1 -CYLDemoRow 1
capture menu2-search-bar -CYLDemoTab 1 -CYLDemoRow 2
capture menu3-ports -CYLDemoTab 1 -CYLDemoRow 3
capture menu4-svga-swiftui -CYLDemoTab 1 -CYLDemoRow 4

echo "$(find "$OUT" -name '*.png' | wc -l | tr -d ' ') screenshots in $OUT, $FAILED failed"
[ "$FAILED" -eq 0 ]
