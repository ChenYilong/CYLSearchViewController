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
- `testSearchBarViewLayoutStyleAndEvents`: layout, style and events. All 10
  example tests pass (Xcode 27.2, iPhone 17 Pro simulator, iOS 26.1).

## TODO

- Status: 90/100. Laid out and verified in unit tests and in the screenshots
  of CollectionViewClassifyMenu's examples; this repository's own example app
  does not show the bar yet.
- Remaining work: a demo row in `CYLSearchDemoMenuViewController` with its
  screenshot.
- Constraints: the bar does not manage a results controller; hosts connect
  `searchBarView:textDidChange:` to `CYLSearchResultsViewController` or their
  own list.
- API risk: unreleased, no compatibility promise yet; the names follow the
  `CYL` prefix rules.
- Verification for completion: launch the demo row on a simulator, check
  VoiceOver reads the field by its placeholder and Cancel by its title, and
  check Dynamic Type at accessibility sizes.
