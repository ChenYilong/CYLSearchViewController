#!/bin/sh
# Usage: scripts/fetch-cyltabbar.sh     (run once before `yarn`, and again after the pinned commit changes)
#
# Checks out CYLTabBarController at the pinned commit into vendor/CYLTabBarController (not committed). Its React
# Native tab bar, CrossPlatform/react-native-cyltabbar, lives inside that repository, which is not a yarn workspace, so
# it cannot be a git dependency; the example depends on it by path (package.json, "portal:"), like android/merged
# builds its sub-repositories from a pinned checkout. The commit is the one every platform of this project pins
# (Podfile, android/merged/gradle.properties: `cyl.tabbar.commit`).
set -eu
cd "$(dirname "$0")/.."
COMMIT=$(sed -n 's/^cyl.tabbar.commit=//p' ../../../android/merged/gradle.properties)
[ -n "$COMMIT" ] || { echo "cyl.tabbar.commit not found in android/merged/gradle.properties"; exit 1; }
DIR=vendor/CYLTabBarController
if [ ! -d "$DIR/.git" ]; then
  mkdir -p vendor
  git init -q "$DIR"
  git -C "$DIR" remote add origin https://github.com/ChenYilong/CYLTabBarController.git
fi
if [ "$(git -C "$DIR" rev-parse HEAD 2>/dev/null || true)" != "$COMMIT" ]; then
  git -C "$DIR" fetch -q --depth 1 origin "$COMMIT"
  git -C "$DIR" checkout -q --detach FETCH_HEAD
fi
echo "CYLTabBarController $COMMIT in $DIR"
