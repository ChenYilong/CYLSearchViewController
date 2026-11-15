// A short message at the bottom of the page, like Android's Snackbar (iOS CYLSnackbar in the example): shown for
// 2.75 s above the bottom safe area, then faded out in 0.25 s; screen readers read it (role alert).
Component({
  properties: {
    // Space kept below it (the tab bar's height on a tab page), in px.
    bottomInset: { type: Number, value: 0 },
  },
  data: { text: '', visible: false, fading: false },
  methods: {
    show(text) {
      clearTimeout(this.fadeTimer);
      clearTimeout(this.hideTimer);
      this.setData({ text, visible: true, fading: false });
      this.fadeTimer = setTimeout(() => this.setData({ fading: true }), 2750);
      this.hideTimer = setTimeout(() => this.setData({ visible: false, fading: false }), 3000);
    },
  },
  lifetimes: {
    detached() {
      clearTimeout(this.fadeTimer);
      clearTimeout(this.hideTimer);
    },
  },
});
