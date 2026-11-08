#!/bin/sh
# Adapted from CYLTabBarController/scripts/ci-build-example.sh.
set -eu
cd "$(dirname "$0")/.."
pod install
xcodebuild build -workspace CYLSearchExample.xcworkspace -scheme CYLSearchExample \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO "$@"
