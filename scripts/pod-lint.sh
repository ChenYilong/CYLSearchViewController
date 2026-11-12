#!/bin/sh
# Adapted from CYLTabBarController/scripts/pod-lint.sh.
set -eu
cd "$(dirname "$0")/.."
export XCODE_XCCONFIG_FILE="$PWD/scripts/pod-lint.xcconfig"
PODSPEC=CYLSearchViewController.podspec

version() {
  sed -n "s/^[[:space:]]*s\\.version[[:space:]]*=[[:space:]]*['\"]\\([^'\"]*\\)['\"].*/\\1/p" "$PODSPEC" | head -n 1
}

# Sub-repositories (AGENTS.md, "Sub-repositories") are not on CocoaPods trunk. `--include-podspecs` treats a podspec
# as a local pod rooted at its folder, so each one is checked out at the commit the Podfile pins (its whole tree) into
# build/lint-specs/<name>/, and lint uses the podspec there. Static frameworks, as CollectionViewClassifyMenu is one.
sub_repository_specs() {
  mkdir -p build/lint-specs
  # One name per sub-repository the podspec depends on.
  set -- CollectionViewClassifyMenu
  for name in "$@"; do
    url=$(sed -n "s/.*pod '$name', :git => '\([^']*\)'.*/\1/p" Podfile | head -n 1)
    commit=$(sed -n "s/.*pod '$name', :git => '[^']*', :commit => '\([0-9a-f]*\)'.*/\1/p" Podfile | head -n 1)
    test -n "$url" && test -n "$commit" || { echo "Podfile does not pin $name by :git and :commit" >&2; exit 1; }
    dir="build/lint-specs/$name"
    if [ ! -d "$dir/.git" ]; then
      git init --quiet "$dir"
      git -C "$dir" remote add origin "$url"
    fi
    git -C "$dir" fetch --quiet --depth 1 origin "$commit"
    git -C "$dir" checkout --quiet --force FETCH_HEAD
    echo "$name: $(git -C "$dir" log -1 --format='%h %s')"
  done
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
  lib) shift; (sub_repository_specs); pod lib lint "$PODSPEC" --allow-warnings --use-static-frameworks --include-podspecs='build/lint-specs/*/*.podspec' "$@" ;;
  *) echo "usage: $0 [lib|version|check-tag|push] [arguments]" >&2; exit 2 ;;
esac
