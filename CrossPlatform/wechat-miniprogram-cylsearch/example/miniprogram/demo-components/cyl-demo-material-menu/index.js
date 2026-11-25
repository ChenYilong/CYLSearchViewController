// MaterialSearchView's sample MainActivity (iOS CYLMaterialSearchMenuViewController): one row per sample screen.
// The "Tag style" tab opens every sample with the suggestions as tags and the keyboard down.
const { cylDemoTagConfiguration } = require('../../utils/cyl_demo_tag_list');
const { SAMPLES, cylMaterialSampleTitle } = require('../../utils/cyl_material_samples');
const { cylDemoText } = require('../../utils/cyl_demo_text');

Component({
  properties: {
    suggestionStyle: { type: String, value: 'list' },
    focusesSearchFieldOnShow: { type: Boolean, value: true },
    inTabBar: { type: Boolean, value: false },
  },
  data: { rows: [], tagConfiguration: {}, placeholder: cylDemoText('search.placeholder') },
  lifetimes: {
    attached() {
      const rows = SAMPLES.map((sample) => ({ sample, title: cylMaterialSampleTitle(sample) }));
      this.setData({ rows, tagConfiguration: cylDemoTagConfiguration([{ title: 'MaterialSearchView', items: rows.map((row) => ({ title: row.title, subtitle: '' })) }]) });
    },
  },
  methods: {
    onTag(event) {
      const row = this.data.rows[event.detail.item];
      if (!row) return;
      const { sample } = row;
      const { suggestionStyle, focusesSearchFieldOnShow } = this.properties;
      wx.navigateTo({ url: `/pages/materialSample/index?sample=${sample}&style=${suggestionStyle}&focus=${focusesSearchFieldOnShow ? 1 : 0}` });
    },
  },
});
