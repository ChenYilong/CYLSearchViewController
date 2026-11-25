#!/bin/sh
# Example demo menus are glass tag lists (docs/instructions/example-demos.md, rules 1 to 7). Sibling of check-example-fold.sh.
# Fails when a demo menu is still a plain cell list, or a tag list of an example sets no glass style / no explicit tail icon.
cd "$(dirname "$0")/.." || exit 1
bad=0
fail() { echo "check-example-taglist: $1"; bad=1; }
need() { # file pattern message
  grep -qE "$2" "$1" || fail "$1: $3"
}
har=harmonyos/entry/src/main/ets
for f in $har/demos/ExamplesMenu.ets $har/demos/SearchBarDemo.ets $har/demos/MaterialSearch.ets; do
  grep -q "CYLDemoCell" "$f" && fail "$f: a plain cell list (CYLDemoCell) in a demo menu"
  need "$f" "CYLDemoTagMenuView" "demo menu is not the tag list"
done
need $har/common/DemoTagMenu.ets "applyBackgroundStyle\('liquidGlass'" "no glass style"
need $har/common/DemoTagMenu.ets "CYLMenuFoldControlPosition\.tail, CYLMenuFoldControlContent\.icon" "no explicit tail icon"
need $har/common/DemoTagMenu.ets "defaultVisibleRows = 3" "no 3-row fold"
mp=CrossPlatform/wechat-miniprogram-cylsearch/example/miniprogram
for f in $mp/pages/examples/index.wxml $mp/pages/ports/index.wxml $mp/pages/styles/index.wxml $mp/demo-components/cyl-demo-material-menu/index.wxml; do
  grep -q 'class="cell' "$f" && fail "$f: a plain cell list in a demo menu"
  need "$f" "cyl-tag-list" "demo menu is not the tag list"
done
need $mp/utils/cyl_demo_tag_list.js "tagBackgroundStyle = 'liquidGlass'" "no glass style"
need $mp/utils/cyl_demo_tag_list.js "position: 'tail', content: 'icon'" "no explicit tail icon"
rn=CrossPlatform/react-native-cylsearch/example/src/App.tsx
need $rn "CYLTagListView backgroundStyle=\"liquidGlass\"" "no glass tag list"
grep -q "style={styles.button}" $rn && fail "$rn: a button list for demos"
need $rn "foldControlContent=\"icon\"" "no explicit tail icon"
fl=CrossPlatform/flutter_cylsearch/example/lib
for f in $fl/main.dart $fl/discover_page.dart; do
  need "$f" "backgroundStyle: 'liquidGlass'" "no glass style"
  need "$f" "foldControlContent: CYLTagFoldControlContent.icon" "no explicit tail icon"
done
grep -q "ListTile" $fl/discover_page.dart && fail "$fl/discover_page.dart: a ListTile entry list"
an=android/merged/app/src/main/kotlin/com/cyl/search/example
need $an/CYLSearchDemoMenuFragment.kt "applyBackgroundStyle\(\"liquidGlass\"" "no glass style"
need $an/CYLSearchDemoMenuFragment.kt "CYLMenuFoldControlContentIcon" "no explicit tail icon"
[ "$bad" = 0 ] && echo "example taglist: ok"
exit "$bad"
