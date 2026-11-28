# Issue #1317 [`issue-1317`]

The reproduction uses `UISearchController` in `navigationItem.searchController`
and a `CYLRefreshNormalHeader`. Pinning the search bar with
`hidesSearchBarWhenScrolling = NO` is the known workaround for repeated inset
updates on affected iOS versions. Refresh callbacks must not retain their
controller strongly and must always stop the refresh control.

## Reproduction details (moved from `instructions.md`, 2026-11-29)

- Keep `navigationItem.hidesSearchBarWhenScrolling = NO` in the safe default reproduction. Setting it to `YES` is the
  documented trigger to investigate; it may cause repeated inset updates on affected UIKit versions.
- End refresh on every completion path and avoid strong captures of view controllers in refresh blocks.
