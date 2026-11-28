---
name: cyl-api-parity
description: "Comparing two platforms' (or libraries') APIs and features: a parity table (source API, description, target counterpart, TODO by default), its score (no TODO = 100), and the loop of matching, implementing (core first, then the example) and rescoring until 100, then the reverse table."
---

# API parity tables

Full rule: `AGENTS.md`, "API parity tables" (2026-11-17).

## The table

| Column 1 | Column 2 | Column 3 |
| :--- | :--- | :--- |
| An API or feature of the source platform's core (the published code) | What it does | The target platform's counterpart; `TODO` until one exists |

- Score = (rows whose column 3 is not `TODO`) / rows × 100. Write the score and its date under the table after
  every change (a score log).
- Prefer a script that lists the source's public API (so no row is forgotten) and keeps the table in sync.

## The loop

1. Search the target's existing code for each `TODO` row (names, doc comments, the other table's mapping) and fill
   column 3 with the counterpart's name.
2. Score.
3. Resolve the remaining `TODO` rows one by one: implement the counterpart in the target's core (rule
   `cyl-fix-in-core`; a sub-repository's library is changed in that repository and pinned here), with the same logic
   and API names as the source, then show it in the target's example, copying the source's example.
4. Score again, and repeat from step 1 until 100.
5. At 100, make the reverse table (target → source) the same way.

## Files

- Android core → iOS: `docs/ios-api-alignment.md`.
- iOS → Android: `docs/android-api-alignment.md` (written by `android/merged/scripts/api-alignment.py`).
