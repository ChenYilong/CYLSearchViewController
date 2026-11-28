> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Summary of the read; treat conclusions as unverified unless 02-findings.md marks them S.

# Project rules and working conventions (summary)

Source of truth: `AGENTS.md`, `docs/instructions/*.md`, `.agents/skills/`. `CLAUDE.md` imports `docs/instructions/behavioral.md` and `AGENTS.md`. This summary can go stale.

- **Behavior:** think before coding, simplest solution, surgical changes, verifiable goals. Name any rule conflict in the reply.
- **Every task:** `git pull`; check other sessions; first reply line `TODO (branch <branch>): <task>`; write a task-log entry in `docs/` with acceptance criteria and commit and push it first; end with `TODO (n points): …` lines.
- **Platforms:** Mac sessions do iOS; Windows sessions do the others.
- **Git:** read `docs/instructions/git.md` in full before any non-read-only git command; `git cz` style, English only, 3-64 characters, project author line; check with `scripts/check-commit-message.sh`.
- **Core:** fix in the core first, example layer last and only after asking. The core owns the content below the bar. Focus alone changes nothing below it. One search field everywhere (`CYLSearchBarView`, navigation-field preset), never a system search bar.
- **Examples:** grouped lists are CollectionViewClassifyMenu tag lists.
- **Dependencies:** sibling projects pinned by commit; missing interfaces are added there first.
- **Quality:** localize everything and support screen readers; every published package ships the MIT LICENSE; `CYL` prefix; three-line public API doc comments.
- **Testing:** build, test and launch before claiming a fix; after a simulator or emulator run, end the app and the simulator; restart a hung emulator without asking.
- **Screenshots:** stitched with header and footer into `docs/assets`; check with `scripts/check-screenshot-labels.sh`.
- **Windows HarmonyOS:** build from the ASCII mirror `C:\cylbuild\harmonyos`; DevEco 6.0.1; x86_64 emulator uses `entry@emulator` and `-p buildMode=emulatorTest`.
