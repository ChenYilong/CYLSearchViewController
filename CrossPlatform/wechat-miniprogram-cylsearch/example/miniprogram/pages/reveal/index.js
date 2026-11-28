// Port of android-cjj/MaterialSearchView's sample (iOS CYLRevealSearchViewController): on the primary color, a round
// search button opens a light search card with a one-second circular reveal; the magnifier in the card closes it again.
const { cylDemoText } = require('../../utils/cyl_demo_text');

Page({
  data: { closeLabel: '' },
  onLoad() {
    this.setData({ closeLabel: cylDemoText('search.field') });
  },
  // mAnimator.reverse()
  onClose() {
    this.selectComponent('#bar').setIconified(true);
  },
});
