# CYLSearchBarView

## Summary

`CYLSearchBarView` is a configurable search bar for hosts that need more than
`UISearchBar`: a rounded field with a magnifier, text and clear button, host
views inside the field after the text (a camera, a "Search" button), a view
before the field (a back button), and an optional localized Cancel button.
CollectionViewClassifyMenu's examples use it for every search box.

## Completed

- Public API: text, placeholder, font, colors; field height, insets, corner
  radius (negative is a capsule), border, shadow and magnifier; trailing
  accessory views, a leading view, the Cancel button and its title.
- `CYLSearchBarViewDelegate`: begin and end editing, text changes, the Search
  key and Cancel.
- `search.cancel` in English, Simplified and Traditional Chinese and Japanese.
- `testSearchBarViewLayoutStyleAndEvents`: layout, style and events.
- Accessibility: the field is read as "Search" (`search.field`, four
  languages) even after the placeholder disappears; the magnifier is
  decorative; the default font follows Dynamic Type (hosts pass a
  `UIFontMetrics` font for a custom one); the field grows
  past `fieldHeight` when the scaled text needs it, and the bar remeasures when
  the text size changes. `testSearchBarViewSupportsVoiceOverAndDynamicType`.
- Large text: at the largest sizes the text keeps at least 40% of the bar.
  The Cancel title is drawn smaller (down to half size, at most 30% of the
  bar) and trailing accessory views are scaled as a whole (down to a quarter)
  before the text field shrinks. VoiceOver and the large content viewer
  (long press at accessibility sizes) still read the whole Cancel title.
- Placeholder at large sizes (2026-11-12): UITextField's own placeholder shrank
  to a quarter of the font size (53 pt text, 14 pt placeholder) when it did not
  fit. The bar now draws it in `placeholderLabel` at the text's font size, cut
  off with an ellipsis; the text field keeps the placeholder in a clear color
  for VoiceOver.
- Demo row: "Search bar" (`demo.searchBar`, four languages) in
  `CYLSearchDemoMenuViewController` shows the bar with a camera accessory and
  Cancel, and prints the text and the Search key below it. Launch with
  `-CYLDemoRow 2` to open it directly (used for the screenshots).
- Public header comments are three-line `/*!` blocks
  (`scripts/check-public-api-comments.sh` passes).
- Tests: `testSearchBarDemoRow` (row, localized title in four languages,
  events, camera label) and the large-text case in
  `testSearchBarViewSupportsVoiceOverAndDynamicType`. All 15 example tests
  pass (Xcode 27.2, iPhone 17 Pro simulator, iOS 26.1).

## Screenshots

iPhone 17 Pro simulator, 2026-11-12, top to bottom: the demo menu, the bar in
English, in Simplified Chinese, and in English at the largest accessibility
text size.

<img src="assets/search-bar-demo-menu.png" width="300" alt="Demo menu with the Search bar row">

<img src="assets/search-bar-demo-english.png" width="300" alt="Search bar in English">

<img src="assets/search-bar-demo-chinese.png" width="300" alt="Search bar in Simplified Chinese">

<img src="assets/search-bar-demo-large-text.png" width="300" alt="Search bar at the largest accessibility text size">

## Verification

- Status: 100/100 for the scope above: the bar is shown, localized and
  tested in this repository's example and in CollectionViewClassifyMenu's.
- Constraints: the bar does not manage a results controller; hosts connect
  `searchBarView:textDidChange:` to `CYLSearchResultsViewController` or their
  own list. It is unreleased, so the API has no compatibility promise yet.
- Checked on the simulator by launching the app at the default and the
  largest text size. VoiceOver labels are checked in unit tests; no session
  with VoiceOver running on a device has been recorded.
