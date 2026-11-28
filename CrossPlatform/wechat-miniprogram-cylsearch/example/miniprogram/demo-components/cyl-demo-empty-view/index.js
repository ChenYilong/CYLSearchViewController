// The empty placeholders of the example's search pages, as iOS CYLSearchView draws them: CYLTableViewPlaceHolder's
// CYLPlaceholderStackView for the scenario (cyl-placeholder-miniprogram's <cyl-placeholder>, a sub-repository synced
// by scripts/sync-example.js). Passed to cyl-search as its abstract node: generic:cyl-empty-view="cyl-demo-empty-view".
Component({
  properties: {
    scenario: { type: String, value: 'NoContent' },
    animated: { type: Boolean, value: false },
    loop: { type: Boolean, value: true },
    speed: { type: Number, value: 1 },
  },
  methods: {
    playAll() {
      const placeholder = this.selectComponent('#placeholder');
      if (placeholder && typeof placeholder.playAll === 'function') placeholder.playAll();
    },
  },
});
