#!/bin/sh
# Usage: scripts/check-public-api-comments.sh
#
# Checks the Objective-C public headers against AGENTS.md, "Comments on public API": every documentation comment is a
# three-line `/*!` / ` * ...` / ` */` block above its declaration. Reports `///` lines, one-line blocks, trailing
# `/**< */`, `/*!< */`, `///<` and trailing `//` after a declaration or an enum value. Exits 1 when it finds any.
set -eu
cd "$(dirname "$0")/.."

PATTERN='///|/\*[*!]<|/\*!.*\*/|;[[:space:]]*//|,[[:space:]]*//'
if grep -nE "$PATTERN" Sources/CYLSearchViewController/*.h; then
  echo "error: public API comments must be three-line /*! ... */ blocks (AGENTS.md, \"Comments on public API\")" >&2
  exit 1
fi
echo "Public API comments: OK"
