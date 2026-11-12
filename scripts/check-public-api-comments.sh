#!/bin/sh
# Usage: scripts/check-public-api-comments.sh
#
# Checks the core's documentation comments against AGENTS.md, "Comments on public API":
# - Objective-C headers: every documentation comment is a three-line `/*!` / ` * ...` / ` */` block above its
#   declaration. Reports `///` lines, one-line blocks, trailing `/**< */`, `/*!< */`, `///<` and trailing `//` after a
#   declaration or an enum value.
# - Swift sources (docs/swift-coding-standard.md): three-line `/**` / ` * ...` / ` */` blocks. Reports `///` lines,
#   one-line `/** ... */` blocks and `/*!` blocks (Swift does not read them as documentation).
# Exits 1 when it finds any.
set -eu
cd "$(dirname "$0")/.."

STATUS=0
HEADERS=$(find Sources/CYLSearchViewController -name '*.h' ! -name '._*')
if [ -n "$HEADERS" ]; then
  # shellcheck disable=SC2086
  if grep -nE '///|/\*[*!]<|/\*!.*\*/|;[[:space:]]*//|,[[:space:]]*//' $HEADERS; then
    echo "error: Objective-C public API comments must be three-line /*! ... */ blocks (AGENTS.md, \"Comments on public API\")" >&2
    STATUS=1
  fi
fi
SWIFT=$(find Sources/CYLSearchViewController -name '*.swift' ! -name '._*')
if [ -n "$SWIFT" ]; then
  # shellcheck disable=SC2086
  if grep -nE '^[[:space:]]*///|/\*\*.*\*/|/\*!' $SWIFT; then
    echo "error: Swift documentation comments must be three-line /** ... */ blocks (docs/swift-coding-standard.md)" >&2
    STATUS=1
  fi
fi
[ "$STATUS" -eq 0 ] && echo "Public API comments: OK"
exit "$STATUS"
