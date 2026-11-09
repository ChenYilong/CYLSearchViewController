# Commit Readiness Rules

## Summary

Added repository guidance requiring unfinished work to be tracked before each
commit and requiring English Conventional Commit messages compatible with
Commitizen.

## Completed

- Added the policy to repository `instructions.md` and `AGENTS.md`.
- Added `*.base` to `.gitignore`; the new `docs/docs.base` remains local.
- Required TODOs to explain remaining work, known defects, API risks, and
  verification steps.
- Required a linked `docs/` note when a detailed commit description exceeds
  50 characters.

## TODO

- TODO: Apply this review to every future commit. No code or issue status was
  changed by this documentation-only commit; the existing Issue #1317
  reproduction and verification status remain unchanged.
