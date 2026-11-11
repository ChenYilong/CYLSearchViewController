#!/bin/sh
# Usage: scripts/ci-checkout-dependencies.sh
#
# Clones the sibling repositories the Podfile reaches through local paths, so CI (and a fresh machine) can run
# `pod install`. The Podfile uses `pod 'CYLTableViewPlaceHolder', :path => '../CYLTableViewPlaceHolder'`.
# - An existing sibling folder is kept as it is (local development).
# - CYL_PLACEHOLDER_REF picks a branch, tag or commit; without it, the default branch.
# - CYL_PLACEHOLDER_URL overrides the repository URL.
set -eu
cd "$(dirname "$0")/.."

URL="${CYL_PLACEHOLDER_URL:-https://github.com/ChenYilong/CYLTableViewPlaceHolder.git}"
DEST="../CYLTableViewPlaceHolder"
REF="${CYL_PLACEHOLDER_REF:-}"

if [ -e "$DEST/CYLTableViewPlaceHolder.podspec" ]; then
  echo "Keeping existing $DEST"
else
  git clone --quiet "$URL" "$DEST"
  if [ -n "$REF" ]; then
    git -C "$DEST" checkout --quiet "$REF"
  fi
fi
echo "CYLTableViewPlaceHolder: $(git -C "$DEST" log -1 --format='%h %cd %s' 2>/dev/null || echo 'not a git checkout')"
