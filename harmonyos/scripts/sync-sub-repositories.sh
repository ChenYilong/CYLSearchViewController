#!/bin/sh
# Copies the HarmonyOS libraries of the sub-repositories into harmonyos/vendor at their pinned commits: the shell
# version of sync-sub-repositories.py (same pins, same folders), for machines without Python.
#
# - CYLTabBarController CrossPlatform/harmonyos-cyltabbar/cyltabbar (+ LICENSE)        -> vendor/cyltabbar
# - CYLTableViewPlaceHolder CrossPlatform/harmonyos-cylplaceholder/cylplaceholder (+ LICENSE) -> vendor/cylplaceholder
# - CollectionViewClassifyMenu harmony/classifymenu                                    -> vendor/classifymenu
# - CollectionViewClassifyMenu harmony/cylanimateditem                                 -> vendor/cylanimateditem
#
# The commits are read from harmonyos/oh-package.json5 (cylTabBarControllerCommit, cylTableViewPlaceHolderCommit,
# collectionViewClassifyMenuCommit). A local clone is used when CYL_TABBAR_DIR, CYL_PLACEHOLDER_DIR or
# CYL_CLASSIFYMENU_DIR points at one that has the commit; otherwise the commit is fetched into a bare cache in $TMPDIR.
#
# Usage: sh harmonyos/scripts/sync-sub-repositories.sh
set -eu
HARMONY=$(cd "$(dirname "$0")/.." && pwd)
VENDOR="$HARMONY/vendor"
PINS="$HARMONY/oh-package.json5"

pin() {
  sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([0-9a-f]*\)\".*/\1/p" "$PINS" | head -n 1
}

# sync <name> <url> <pin key> <path in repo> <local clone env var> [extra files...]
sync() {
  name=$1 url=$2 key=$3 path=$4 envvar=$5
  shift 5
  commit=$(pin "$key")
  [ -n "$commit" ] || { echo "$key not found in $PINS" >&2; exit 1; }
  eval "local_dir=\${$envvar:-}"
  if [ -n "$local_dir" ] && git -C "$local_dir" cat-file -e "$commit^{commit}" 2>/dev/null; then
    repo=$local_dir
  else
    repo="${TMPDIR:-/tmp}/cyl-harmony-$(basename "$url" .git | tr 'A-Z' 'a-z').git"
    # A cache that is no longer a repository (a temp-folder cleanup can remove its objects and refs) is made again.
    if [ -d "$repo" ] && ! git -C "$repo" rev-parse --git-dir >/dev/null 2>&1; then rm -rf "$repo"; fi
    [ -d "$repo" ] || git init --bare -q "$repo"
    git -C "$repo" cat-file -e "$commit^{commit}" 2>/dev/null || git -C "$repo" fetch -q --filter=blob:none "$url" "$commit"
  fi
  target="$VENDOR/$name"
  rm -rf "$target"
  mkdir -p "$target"
  depth=$(printf '%s' "$path" | awk -F/ '{print NF}')
  git -C "$repo" archive --format=tar "$commit" "$path" | tar -x -C "$target" --strip-components="$depth"
  for extra in "$@"; do
    git -C "$repo" show "$commit:$extra" > "$target/$extra"
  done
  echo "$name $(printf '%s' "$commit" | cut -c1-9) -> vendor/$name"
}

sync cyltabbar https://github.com/ChenYilong/CYLTabBarController.git cylTabBarControllerCommit \
  CrossPlatform/harmonyos-cyltabbar/cyltabbar CYL_TABBAR_DIR LICENSE
sync cylplaceholder https://github.com/ChenYilong/CYLTableViewPlaceHolder.git cylTableViewPlaceHolderCommit \
  CrossPlatform/harmonyos-cylplaceholder/cylplaceholder CYL_PLACEHOLDER_DIR LICENSE
sync classifymenu https://github.com/ChenYilong/CollectionViewClassifyMenu.git collectionViewClassifyMenuCommit \
  harmony/classifymenu CYL_CLASSIFYMENU_DIR
sync cylanimateditem https://github.com/ChenYilong/CollectionViewClassifyMenu.git collectionViewClassifyMenuCommit \
  harmony/cylanimateditem CYL_CLASSIFYMENU_DIR
