#!/bin/sh
# Usage: scripts/public-api-doc-coverage.sh [built products dir]   (macOS with Xcode)
#        e.g. scripts/public-api-doc-coverage.sh build/DerivedData/Build/Products/Debug-iphonesimulator
#
# Counts the public symbols of the core (Sources/CYLSearchBar) that carry a documentation comment, as the symbol graph
# (the data Xcode Quick Help and DocC read) sees them.
# - Swift (the core today): give the products directory of a simulator build of the example (it holds
#   CYLSearchViewController.framework and the frameworks it imports). The script runs swift-symbolgraph-extract on the
#   module, counts the core's own public symbols per file and lists the ones without a comment. Overrides have none by
#   design: they inherit the documentation of the declaration they override (scripts/check-public-api-comments.sh),
#   and Quick Help shows that one.
# - Objective-C headers (none at the moment): clang -extract-api on each header.
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
OUT=$(mktemp -d)
trap 'rm -rf "$OUT"' EXIT
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)

if [ -n "$(find "$REPO/Sources/CYLSearchBar" -name '*.swift' ! -name '._*')" ]; then
  PRODUCTS="${1:-}"
  if [ -z "$PRODUCTS" ] || [ ! -d "$PRODUCTS/CYLSearchViewController/CYLSearchViewController.framework" ]; then
    echo "Swift core: pass the products directory of a simulator build of CYLSearchExample.xcworkspace" >&2
    exit 2
  fi
  set --
  for dir in "$PRODUCTS"/*/; do
    set -- "$@" -F "$dir"
  done
  xcrun swift-symbolgraph-extract -module-name CYLSearchViewController -target arm64-apple-ios15.0-simulator \
    -sdk "$SDK" "$@" -minimum-access-level public -output-dir "$OUT"
  python3 - "$OUT/CYLSearchViewController.symbols.json" <<'EOF'
import json, sys
symbols = json.load(open(sys.argv[1]))["symbols"]
files = {}
for s in symbols:
    uri = s.get("location", {}).get("uri", "")
    if "Sources/CYLSearchBar/" not in uri:
        continue
    entry = files.setdefault(uri.rsplit("/", 1)[-1], [0, 0, []])
    entry[1] += 1
    if s.get("docComment"):
        entry[0] += 1
    else:
        entry[2].append(".".join(s["pathComponents"]))
documented = sum(e[0] for e in files.values())
total = sum(e[1] for e in files.values())
for name, (done, count, missing) in sorted(files.items()):
    print(f"{name}: {done}/{count} symbols documented; without a comment: {missing}")
print(f"Total: {documented}/{total}")
EOF
fi

HEADERS=$(find "$REPO/Sources/CYLSearchBar" -name '*.h' ! -name '._*')
[ -z "$HEADERS" ] && exit 0
mkdir -p "$OUT/inc/CYLSearchViewController"
cp "$REPO"/Sources/CYLSearchBar/*.h "$OUT/inc/CYLSearchViewController/"
for h in "$OUT"/inc/CYLSearchViewController/*.h; do
  n=$(basename "$h" .h)
  xcrun clang -extract-api -x objective-c-header -isysroot "$SDK" -target arm64-apple-ios15.0-simulator \
    -I "$OUT/inc" --product-name=CYLSearchViewController "$h" -o "$OUT/$n.json"
  python3 - "$OUT/$n.json" "$n" <<'EOF'
import json, sys
symbols = json.load(open(sys.argv[1]))["symbols"]
documented = [s for s in symbols if s.get("docComment")]
missing = [".".join(s["pathComponents"]) for s in symbols if not s.get("docComment")]
print(f"{sys.argv[2]}: {len(documented)}/{len(symbols)} symbols documented; missing: {missing}")
EOF
done
