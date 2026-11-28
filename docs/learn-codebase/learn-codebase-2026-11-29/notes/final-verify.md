> **UNVERIFIED / 未复核.** Static reading at `ad32984` plus uncommitted changes; nothing was built, run or tested. Working notes from the first read: NOT re-checked, and some were later corrected (see 02-findings.md).

# Final verification note (verbatim)

All 153 chunks read; read-only, git status unchanged (4 modified + 3 untracked, ahead 2). Confirmed: iOS and Flutter Discover entry comments claim auto-open on first appearance but no push at creation, viewDidAppear or initState. RN comment makes no such claim; its entry tag onTagSelect is no-op (bar onOpen still opens). ja search-discover.json recentSearches+discover identical to en while zh-Hans/zh-Hant are translated. ci-checkout-dependencies.sh:5 comment stale (:path vs :commit). RN iOS has no animatesBackButton hit. lapism port: newArray self-recursion MaterialSearchView.kt:404-405; wrong styleable index :108-109. Unrechecked: Flutter README/CHANGELOG staleness, MP history trim/selection differences.
