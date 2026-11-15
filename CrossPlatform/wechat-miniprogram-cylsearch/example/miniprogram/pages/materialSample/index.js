// One MaterialSearchView sample screen (iOS CYLMaterialSearchSampleViewController): a toolbar with a search item that
// opens cyl-search over the toolbar with the sample's suggestions; a submitted query shows "Query: …" in a snackbar and
// closes the search, as onQueryTextSubmit returning false does. Options: sample, style (list | tags), focus (1 | 0).
const { cylDemoText } = require('../../utils/cyl_demo_text');
const { cylMaterialSampleTitle, cylMaterialSampleConfiguration } = require('../../utils/cyl_material_samples');
const { cylAnimationControls } = require('../../utils/cyl_animation_controls');

const { initialData, ...playbackHandlers } = cylAnimationControls('#search');

Page({
  ...playbackHandlers,
  data: Object.assign({
    sample: 'standard', title: '', suggestionStyle: 'list', focusesSearchFieldOnShow: true,
    // Every key set before onLoad, so no property receives null.
    configuration: cylMaterialSampleConfiguration('standard'),
    placeholder: '', items: [], pages: [], selectedPage: 0, openLabel: '', searchOpen: false,
  }, initialData),
  onLoad(options) {
    const sample = options.sample || 'standard';
    this.setData({
      sample,
      title: cylMaterialSampleTitle(sample),
      suggestionStyle: options.style === 'tags' ? 'tags' : 'list',
      focusesSearchFieldOnShow: options.focus !== '0',
      configuration: cylMaterialSampleConfiguration(sample),
      openLabel: cylDemoText('demo.port.open'),
      // StickyActivity: a long list under the sticky toolbar; TabActivity: three pages under tabs.
      items: sample === 'sticky' ? Array.from({ length: 60 }, (_, index) => cylDemoText('demo.port.item', index + 1)) : [],
      pages: sample === 'tabs' ? [1, 2, 3].map((page) => cylDemoText('demo.port.page', page)) : [],
    });
  },
  // The search item: the search bar takes the navigation bar's place.
  openSearch() {
    this.setData({ searchOpen: true });
    this.selectComponent('#search').show();
  },
  onSearchClose() {
    this.setData({ searchOpen: false, placeholder: '' });
  },
  onSubmit(event) {
    this.selectComponent('#snackbar').show(cylDemoText('demo.port.query', event.detail.text));
  },
  // REQUEST_VOICE: the sample listens, and the first result becomes the query without submitting it. A mini program
  // has no speech recognition without a plugin, so it says so, as iOS does when recognition is not available.
  onVoice() {
    this.setData({ placeholder: cylDemoText('demo.port.listening') });
    setTimeout(() => {
      this.setData({ placeholder: '' });
      this.selectComponent('#snackbar').show(cylDemoText('demo.port.voiceUnavailable'));
    }, 0);
  },
  onSelectPage(event) {
    this.setData({ selectedPage: Number(event.currentTarget.dataset.index) });
  },
  onUnload() {
    const search = this.selectComponent('#search');
    if (search) search.close();
  },
});
