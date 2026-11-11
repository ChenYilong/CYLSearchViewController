#!/bin/sh
# Usage: scripts/public-api-doc-coverage.sh   (macOS with Xcode)
#
# Counts the public symbols of each header in Sources/CYLSearchViewController that carry a documentation comment, as
# clang's symbol graph (clang -extract-api, the data Xcode Quick Help and DocC read) sees them.
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
OUT=$(mktemp -d)
SDK=$(xcrun --sdk iphonesimulator --show-sdk-path)
mkdir -p "$OUT/inc/CYLSearchViewController"
cp "$REPO"/Sources/CYLSearchViewController/*.h "$OUT/inc/CYLSearchViewController/"
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
