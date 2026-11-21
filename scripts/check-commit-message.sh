#!/bin/sh
# Checks a commit message against the commit rule (AGENTS.md, "Commit readiness"; skill cyl-commit): a git cz
# (Commitizen) style subject, `type(scope): emoji subject` or `type: emoji subject`, and the whole message in English,
# with no Chinese (CJK) characters.
#
#   scripts/check-commit-message.sh <message file>     # as a commit-msg hook, or on a saved message
#   git log -1 --format=%B | scripts/check-commit-message.sh -   # the last commit
set -eu

file="${1:--}"
if [ "$file" = "-" ]; then
    message="$(cat)"
else
    message="$(cat "$file")"
fi
# Lines Git ignores (comments) are not part of the message.
message="$(printf '%s\n' "$message" | grep -v '^#' || true)"
subject="$(printf '%s\n' "$message" | sed -n '1p')"
status=0

types='test|feat|fix|chore|docs|refactor|style|ci|perf|release'
if ! printf '%s\n' "$subject" | grep -Eq "^($types)(\([^)]+\))?: .+"; then
    echo "commit message: the subject is not git cz style, '<type>(<scope>): <emoji> <subject>' with type one of $types" >&2
    status=1
fi

# Commitizen's configured message length: 3 to 64 characters (instructions.md, "Commitizen defaults").
length="$(printf '%s' "$subject" | perl -CSD -ne 'print length')"
if [ "$length" -lt 3 ] || [ "$length" -gt 64 ]; then
    echo "commit message: the subject has $length characters; Commitizen allows 3 to 64" >&2
    status=1
fi

# CJK Unified Ideographs, extension A, compatibility ideographs, CJK punctuation and full-width forms.
# perl, not grep -P, so it also works with the BSD grep of macOS.
cjk='[\x{3000}-\x{303F}\x{3400}-\x{4DBF}\x{4E00}-\x{9FFF}\x{F900}-\x{FAFF}\x{FF00}-\x{FFEF}]'
chinese="$(printf '%s\n' "$message" | perl -CSD -ne "print \"\$.: \$_\" if /$cjk/")"
if [ -n "$chinese" ]; then
    echo "commit message: it contains Chinese characters; write the whole message in English" >&2
    printf '%s\n' "$chinese" >&2
    status=1
fi

exit "$status"
