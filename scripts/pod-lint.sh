#!/bin/sh
# Adapted from CYLTabBarController/scripts/pod-lint.sh.
set -eu
cd "$(dirname "$0")/.."
export XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"
PODSPEC=CYLSearchViewController.podspec

version() {
  sed -n "s/^[[:space:]]*s\\.version[[:space:]]*=[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p" "$PODSPEC" | head -n 1
}

case "${1:-lib}" in
  version) version ;;
  check-tag)
    test "${2:?usage: pod-lint.sh check-tag <tag>}" = "$(version)" || {
      echo "Tag does not match $PODSPEC" >&2
      exit 1
    }
    ;;
  push) shift; pod trunk push "$PODSPEC" --allow-warnings "$@" ;;
  lib) shift; pod lib lint "$PODSPEC" --allow-warnings "$@" ;;
  *) echo "usage: $0 [lib|version|check-tag|push] [arguments]" >&2; exit 2 ;;
esac
