#!/bin/sh
# Example tag lists use the tail fold control with the icon only (docs/instructions/example-demos.md, rule 3).
# Fails when an example sets a title fold content, or sets a fold (rows > 0) without an explicit icon content.
cd "$(dirname "$0")/.." || exit 1
set -- android/merged/app/src/main harmonyos/entry/src/main CrossPlatform/flutter_cylsearch/example/lib CrossPlatform/react-native-cylsearch/example/src CrossPlatform/wechat-miniprogram-cylsearch/example/miniprogram/pages
bad=0
files=$(grep -rlE "defaultVisibleRows|foldedRowCount|FoldControl" "$@" --include=*.kt --include=*.ets --include=*.dart --include=*.tsx --include=*.wxml --include=*.js 2>/dev/null)
for f in $files; do
  if grep -nE "IconAndTitle|iconAndTitle|titleAndIcon|titleAndIconAlways|FoldControlContent\.title|FoldControlContentTitle|foldControlContent=\"title|foldControlContent: ?'title" "$f"; then
    echo "check-example-fold: $f sets a title fold content"; bad=1
  fi
  if grep -qE "defaultVisibleRows ?= ?[1-9]|defaultVisibleRows=\"\{\{[1-9]|foldedRowCount[:=] ?\{?[1-9]" "$f" &&
     ! grep -qE "ControlContentIcon\b|FoldControlContent\.icon|foldControlContent=\"icon\"|foldControlContent=\"\{\{'icon'" "$f"; then
    echo "check-example-fold: $f folds without an explicit icon content"; bad=1
  fi
done
[ "$bad" = 0 ] && echo "example fold: ok"
exit "$bad"
