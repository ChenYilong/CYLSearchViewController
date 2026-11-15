// The default of cyl-search's abstract node cyl-empty-view: draws a CYLTableViewPlaceHolder scenario name with the
// library's own CYLSearchPlaceholderView (cyl-search-placeholder), so cyl-search needs no other package.
// "NoSearchResults" is the no-results kind, the load-failure scenarios the error kind, anything else the empty kind.
// To draw CYLTableViewPlaceHolder's own placeholders, pass a view that renders cyl-placeholder-miniprogram's
// <cyl-placeholder scenario="{{scenario}}"> instead (the example does). `animated`, `loop` and `speed` are for such a
// view; this one is static, as iOS CYLPlaceholderStackView is.
const { cylEmptyViewKind } = require('./cyl_empty_view_kind');

Component({
  properties: {
    scenario: { type: String, value: 'NoContent' },
    animated: { type: Boolean, value: false },
    loop: { type: Boolean, value: true },
    speed: { type: Number, value: 1 },
  },
  data: { kind: 'empty' },
  observers: {
    scenario(scenario) {
      this.setData({ kind: cylEmptyViewKind(scenario) });
    },
  },
  methods: {
    // cyl-search's playAnimationFromStart() calls it; a static placeholder has nothing to play.
    playAll() {},
  },
});
