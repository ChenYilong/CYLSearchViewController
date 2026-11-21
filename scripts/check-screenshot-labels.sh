#!/bin/sh
# Usage: sh scripts/check-screenshot-labels.sh            (the images staged for the next commit)
#        sh scripts/check-screenshot-labels.sh BASE HEAD  (the images added between two commits, as CI runs it)
#
# Fails when a screenshot added under docs/assets breaks AGENTS.md, "Screenshots of builds and CI/CD" (Labels) and
# "Stitched screenshots: layout, header and footer":
#   1. it is a PNG made by scripts/stitch-screenshots.swift (macOS) or scripts/stitch-screenshots.ps1 (Windows), so it
#      has a header and a footer outside the screenshot: the PNG text "CYL header: ..." those tools write;
#   2. a Markdown file shows it, and the line that shows it (its caption or table row) has a date (YYYY-MM-DD) and a
#      commit (7 to 40 hex characters).
# Exempt: docs/assets/screenshot-style-example-* (the user's style examples) and docs/assets/raw/ (originals kept
# only as the input of a stitched image).
set -eu
cd "$(git rev-parse --show-toplevel)"

if [ "$#" -ge 2 ]; then
  added=$(git diff --name-only --diff-filter=A "$1" "$2" -- docs/assets)
else
  added=$(git diff --cached --name-only --diff-filter=A -- docs/assets)
fi

failures=0
fail() {
  echo "screenshot label: $1" >&2
  failures=$((failures + 1))
}

for file in $added; do
  case "$file" in
    docs/assets/screenshot-style-example-*|docs/assets/raw/*) continue ;;
    *.png|*.PNG) ;;
    *.jpg|*.jpeg|*.JPG|*.JPEG|*.gif|*.webp)
      fail "$file: not a PNG; run it through scripts/stitch-screenshots.swift or .ps1 with --header/--footer"
      continue ;;
    *) continue ;;
  esac
  [ -f "$file" ] || continue
  if ! grep -a -q "CYL header:" "$file"; then
    fail "$file: no header and footer; make it with scripts/stitch-screenshots.swift (macOS) or scripts/stitch-screenshots.ps1 (Windows)"
  fi
  name=$(basename "$file")
  lines=$(git grep -h -F "$name" -- '*.md' || true)
  if [ -z "$lines" ]; then
    fail "$file: no Markdown file shows it; link it from the related document in docs/"
    continue
  fi
  if ! printf '%s\n' "$lines" | grep -E '20[0-9]{2}-[0-9]{2}-[0-9]{2}' | grep -q -E '(^|[^0-9a-f])[0-9a-f]{7,40}([^0-9a-f]|$)'; then
    fail "$file: the line that shows it needs its label: platform, device and OS, SDK/IDE, commit, date (YYYY-MM-DD) and time zone"
  fi
done

if [ "$failures" -gt 0 ]; then
  echo "screenshot label: $failures problem(s); see AGENTS.md, \"Screenshots of builds and CI/CD\"" >&2
  exit 1
fi
echo "screenshot labels: ok"
