// MaterialSearchView's sample MainActivity (iOS CYLMaterialSearchMenuViewController): one row per sample screen.
// The "Tag style" tab opens every sample with the suggestions as tags and the keyboard down.
const { SAMPLES, cylMaterialSampleTitle } = require('../../utils/cyl_material_samples');

Component({
  properties: {
    suggestionStyle: { type: String, value: 'list' },
    focusesSearchFieldOnShow: { type: Boolean, value: true },
    inTabBar: { type: Boolean, value: false },
  },
  data: { rows: [] },
  lifetimes: {
    attached() {
      this.setData({ rows: SAMPLES.map((sample) => ({ sample, title: cylMaterialSampleTitle(sample) })) });
    },
  },
  methods: {
    onRow(event) {
      const { sample } = event.currentTarget.dataset;
      const { suggestionStyle, focusesSearchFieldOnShow } = this.properties;
      wx.navigateTo({ url: `/pages/materialSample/index?sample=${sample}&style=${suggestionStyle}&focus=${focusesSearchFieldOnShow ? 1 : 0}` });
    },
  },
});
