#!/bin/sh
# Usage: scripts/public-api-doc-coverage.sh   (macOS with Xcode)
#
# Counts the public symbols of each header in Sources/CYLSearchBar that carry a documentation comment, as
# clang's symbol graph (clang -extract-api, the data Xcode Quick Help and DocC read) sees them. The core is Swift now
# and has no header: the script then says so and stops (scripts/check-public-api-comments.sh checks the Swift
# documentation comments).
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
if [ -z "$(find "$REPO/Sources/CYLSearchBar" -name '*.h' ! -name '._*')" ]; then
  echo "No Objective-C header in Sources/CYLSearchBar: nothing to count."
  exit 0
fi
OUT=$(mktemp -d)
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
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
rm -rf "$OUT"
