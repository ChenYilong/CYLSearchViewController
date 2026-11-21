#!/bin/sh
# Usage: scripts/check-public-api-comments.sh
#
# Checks the core's documentation comments against AGENTS.md, "Comments on public API":
# - Objective-C headers (none at the moment): every documentation comment is a three-line `/*!` / ` * ...` / ` */`
#   block above its declaration. Reports `///` lines, one-line blocks, trailing `/**< */`, `/*!< */`, `///<` and
#   trailing `//` after a declaration or an enum value.
# - Swift sources (docs/swift-coding-standard.md): three-line `/**` / ` * ...` / ` */` blocks. Reports `///` lines,
#   one-line `/** ... */` blocks, `/*!` blocks (Swift does not read them as documentation), trailing `///<` or `//`
#   comments after a declaration, and every `public` or `open` declaration (overrides excepted: they inherit the
#   documentation of the declaration they override) that is not preceded by a `/** ... */` block, attributes such as
#   `@objc(...)` or `@discardableResult` in between.
# Exits 1 when it finds any.
set -eu
cd "$(dirname "$0")/.."

CORE=Sources/CYLSearchBar
STATUS=0
HEADERS=$(find "$CORE" -name '*.h' ! -name '._*')
if [ -n "$HEADERS" ]; then
  # shellcheck disable=SC2086
  if grep -nE '///|/\*[*!]<|/\*!.*\*/|;[[:space:]]*//|,[[:space:]]*//' $HEADERS; then
    echo "error: Objective-C public API comments must be three-line /*! ... */ blocks (AGENTS.md, \"Comments on public API\")" >&2
    STATUS=1
  fi
fi
SWIFT=$(find "$CORE" -name '*.swift' ! -name '._*')
if [ -n "$SWIFT" ]; then
  # shellcheck disable=SC2086
  if grep -nE '^[[:space:]]*///|/\*\*.*\*/|/\*!|///<' $SWIFT; then
    echo "error: Swift documentation comments must be three-line /** ... */ blocks (docs/swift-coding-standard.md)" >&2
    STATUS=1
  fi
  # shellcheck disable=SC2086
  if ! awk '
    function report(message) {
      printf "%s:%d: %s\n", FILENAME, FNR, message
      failed = 1
    }
    FNR == 1 { last = "" }
    {
      line = $0
      trimmed = line
      sub(/^[ \t]+/, "", trimmed)
      if (trimmed ~ /^(\*|\/\/|\/\*)/) {
        last = trimmed
        next
      }
      if (trimmed ~ /^(public|open|@[A-Za-z]+(\([^)]*\))?[ \t]+(public|open))[ \t]/ && trimmed !~ /(^|[ \t])override[ \t]/) {
        if (last != "*/") {
          report("public declaration without a /** ... */ documentation block: " trimmed)
        }
        if (trimmed ~ /[;{)][ \t]*\/\/|[A-Za-z0-9_?!\]][ \t]+\/\//) {
          report("trailing comment after a declaration: " trimmed)
        }
      }
      if (trimmed ~ /^@[A-Za-z]+(\([^)]*\))?$/) {
        next
      }
      if (trimmed != "") {
        last = trimmed
      }
    }
    END { exit failed }
  ' $SWIFT; then
    echo "error: every public Swift declaration needs a three-line /** ... */ block right above it (AGENTS.md, \"Comments on public API\")" >&2
    STATUS=1
  fi
fi
[ "$STATUS" -eq 0 ] && echo "Public API comments: OK"
exit "$STATUS"
