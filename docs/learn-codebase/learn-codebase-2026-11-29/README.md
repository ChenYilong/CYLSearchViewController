> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Summary of the read; treat conclusions as unverified unless 02-findings.md marks them S.

# CYLSearchViewController: what was learned (learn-codebase, 2026-11-29)

Export of the full read of the repository at HEAD `ad32984` plus its uncommitted changes. **Static reading only: nothing was built, run or tested.** The code is the source of truth; this snapshot will go stale.

> **Published with caveats.** Before publication, local user paths and machine-specific wording were removed and the raw claude-mem observation dumps were left out. That was a pattern scan, not a line-by-line review. **Many conclusions are unverified:** read the notice at the top of each file. Files named `-part2` continue the file of the same name.

## Start here
| File | What | How far to trust it |
|:---|:---|:---|
| [01-architecture.md](01-architecture.md) | Platforms, core files, shared tooling, search-button differences | Written from the read |
| [02-findings.md](02-findings.md) | Defects and drift, each marked S (re-checked) or R (first read), plus **corrections** | Code reading; none reproduced |
| [03-dependencies.md](03-dependencies.md) | Sibling-project commit pins and where they appear | `git grep` |
| [04-project-rules.md](04-project-rules.md) | Workflow, git, core, example and testing rules | Summary; the repo's files win |
| [05-scripts-and-ci.md](05-scripts-and-ci.md) | Every script and workflow with its header | Headers only; not run |
| [06-session-record.md](06-session-record.md) | Scope, skipped files, repository state | Record |

## From the documents (added in the second pass)
- [docs-knowledge/](docs-knowledge/README.md): six digests of the project docs, rules, skills and READMEs, written by subagents.
- [data/localization.md](data/localization.md): key coverage across en, ja, zh-Hans, zh-Hant and the other HarmonyOS languages.
- [data/config.md](data/config.md): toolchain versions, Xcode projects, resolved pods, app settings.

## Per area
| Area | Notes | Declarations |
|:---|:---|:---|
| iOS core | [notes](notes/01-ios-core.md) | [index](reference/01-ios-core.md) |
| Android core | [notes](notes/02-android-core.md) | [index](reference/02-android-core.md) |
| HarmonyOS core | [notes](notes/03-harmony-core.md) | [index](reference/03-harmony-core.md) |
| WeChat mini program core | [notes](notes/04-mp-src.md) | [index](reference/04-mp-src.md) |
| Flutter plugin | [notes](notes/05-flutter-plugin.md) | [index](reference/05-flutter-plugin.md) |
| React Native library | [notes](notes/06-rn-library.md) | [index](reference/06-rn-library.md) |
| Android example | [notes](notes/07-example-android.md) | [index](reference/07-example-android.md) |
| HarmonyOS example | [notes](notes/07-example-harmony.md) | [index](reference/07-example-harmony.md) |
| iOS example | [notes](notes/07-example-ios.md) | [index](reference/07-example-ios.md) |
| Flutter example | [notes](notes/08-example-flutter.md) | [index](reference/08-example-flutter.md) |
| Mini program example | [notes](notes/08-example-mp.md) | [index](reference/08-example-mp.md) |
| React Native example | [notes](notes/08-example-rn.md) | [index](reference/08-example-rn.md) |
| Tests | [notes](notes/09-tests.md) | [index](reference/09-tests.md) |
| Scripts and CI | [notes](notes/10-scripts-ci.md) | [index](reference/10-scripts-ci.md) |
| Upstream Android ports | [notes](notes/11-android-ports.md) | [index](reference/11-android-ports.md) |

Also: [final verification](notes/final-verify.md), [2026-11-27 earlier notes](notes/earlier-pass-2026-11-27.md).

## Reference (generated)
- [reference/file-inventory.tsv](reference/file-inventory.tsv): every file read, with group, line count and header comment.
- [reference/test-index.md](reference/test-index.md): test names with line numbers.

## Open next steps
1. Build and test to reproduce the findings; start with iOS default-button history (Mac) and the two HarmonyOS UI tests.
2. Decide which findings to fix, cores first. The lapism items are in vendored upstream port code.
3. Decide what to do with the uncommitted files.
