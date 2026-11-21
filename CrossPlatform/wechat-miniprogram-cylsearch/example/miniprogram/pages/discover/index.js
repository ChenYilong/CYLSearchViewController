// The "Discover" tab (iOS CYLSearchDiscoverViewController, copied from CollectionViewClassifyMenu's CYLMenuExample):
// a search app's search page. The search bar takes the navigation bar's place: a bordered capsule without a magnifier,
// the camera, a divider and the Search button appended inside it. "Recent searches" are tags folded to two rows with
// the chevron as the last tag and a trash button; "Discover" is a grid of two titles per row, a hot icon after a hot
// title, and the More button refreshing the topics at random. At the bottom: "Hold to ask" over a curved area. The
// data comes from search-discover.json of the iOS example; this page only shows it and handles the taps.
const { cylSelectTab } = require('../../utils/cyl_tab_page');
const { cylDemoText, cylDemoLanguage, cylDiscoverData, cylHotIcon } = require('../../utils/cyl_demo_text');
const { cylRandomTopics, cylSearchedRecent } = require('../../utils/cyl_discover_logic');
const { cylFoldTags } = require('../../components/core/CYLSearchView');
const { cylNavigationMetrics } = require('../../components/core/CYLSearchResources');

const TAG_SPACING = 12;
const SIDE_INSET = 16;
const FIELD_HEIGHT = 46;
// The fold chevron's labels: CollectionViewClassifyMenu's CYLMenuExpand / CYLMenuCollapse (CYLClassifyMenu.strings).
const FOLD_LABELS = { en: ['More', 'Less'], 'zh-Hans': ['更多', '收起'], 'zh-Hant': ['更多', '收合'] };

Page({
  data: {
    texts: {}, showsBack: false, barTop: 0, barRight: 14, contentTop: 0,
    query: '', placeholder: '', items: [],
    recent: [], visibleRecent: [], needsFold: false, folded: true,
    topics: [], hotIcon: '', hint: '', announcement: '', foldLabels: FOLD_LABELS.en,
  },
  onLoad() {
    const metrics = cylNavigationMetrics();
    const data = cylDiscoverData();
    this.discover = data;
    // The bar is centered on WeChat's menu button and ends before it, where iOS puts it 8 pt under the safe area.
    const barTop = Math.max(metrics.statusBarHeight + 4, metrics.statusBarHeight + (metrics.navigationBarHeight - FIELD_HEIGHT) / 2);
    this.setData({
      texts: {
        recent: cylDemoText('discover.recent'), title: cylDemoText('discover.title'), refresh: cylDemoText('discover.refresh'),
        back: cylDemoText('discover.back'), clear: cylDemoText('discover.clear'), tapToSearch: cylDemoText('discover.tapToSearch'),
        ask: cylDemoText('discover.ask'), askHint: cylDemoText('discover.askAccessibilityHint'), hot: cylDemoText('discover.hot'),
        search: cylDemoText('discover.search'),
      },
      showsBack: getCurrentPages().length > 1,
      barTop,
      barRight: metrics.trailingInset || 14,
      contentTop: barTop + FIELD_HEIGHT + 10,
      items: [
        { style: 'icon', title: cylDemoText('discover.imageSearch'), image: '/assets/discover/camera.viewfinder.svg', accessibilityIdentifier: 'camera' },
        { style: 'divider' },
        { style: 'text', title: cylDemoText('discover.search'), accessibilityIdentifier: 'CYLSearchDiscoverSearchButton' },
      ],
      recent: data.recentSearches.slice(),
      topics: data.discover.slice(0, Math.max(0, data.discoverCount)),
      hotIcon: cylHotIcon(),
      foldLabels: FOLD_LABELS[cylDemoLanguage(wx.getAppBaseInfo().language)] || FOLD_LABELS.en,
      hint: cylDemoText('discover.askHint'),
    });
    this.reloadLists();
  },
  onShow() {
    cylSelectTab(this, 'discover');
  },
  onReady() {
    this.measureRecent();
  },
  // The search field's placeholder is the first discover topic.
  reloadLists() {
    const first = this.data.topics[0];
    this.setData({ placeholder: first ? first.title : this.data.texts.search });
    this.measureRecent();
  },
  // Folds the recent searches to two rows: measures every tag, then keeps those of the first rows with the chevron.
  measureRecent() {
    if (!this.data.recent.length) {
      this.setData({ visibleRecent: [], needsFold: false });
      return;
    }
    wx.nextTick(() => {
      const query = this.createSelectorQuery();
      query.selectAll('.measure-tag').boundingClientRect();
      query.select('.measure-chevron').boundingClientRect();
      query.selectViewport().fields({ size: true });
      query.exec(([tags, chevron, viewport]) => {
        if (!tags || !tags.length) return;
        const available = viewport.width - SIDE_INSET * 2;
        const { visibleCount, needsFold } = cylFoldTags(tags.map((tag) => tag.width), available, TAG_SPACING, chevron ? chevron.width : 40, 2);
        const recent = this.data.recent;
        this.setData({ needsFold, visibleRecent: needsFold && this.data.folded ? recent.slice(0, visibleCount) : recent });
      });
    });
  },
  onToggleFold() {
    this.setData({ folded: !this.data.folded });
    this.measureRecent();
  },
  // Searches `text`: shows it in the field and moves it to the front of the recent searches.
  search(text) {
    const query = String(text || '').trim();
    if (!query) return;
    this.setData({ query, recent: cylSearchedRecent(this.data.recent, query), announcement: cylDemoText('discover.searching', query) });
    this.reloadLists();
  },
  onTextChange(event) {
    this.setData({ query: event.detail.text });
  },
  // The Search button and the keyboard's search key: the typed text, else the placeholder topic.
  searchTapped() {
    this.search(this.data.query || this.data.placeholder);
  },
  onSubmit() {
    this.searchTapped();
    this.selectComponent('#bar').hideKeyboard();
  },
  onItemSelect(event) {
    const id = event.detail.item && event.detail.item.accessibilityIdentifier;
    if (id === 'camera') this.searchByImage();
    else if (id === 'CYLSearchDiscoverSearchButton') this.searchTapped();
  },
  onRecentTap(event) {
    this.search(this.data.recent[Number(event.currentTarget.dataset.index)]);
  },
  onTopicTap(event) {
    this.search(this.data.topics[Number(event.currentTarget.dataset.index)].title);
  },
  clearRecentSearches() {
    this.setData({ recent: [], visibleRecent: [], needsFold: false, announcement: cylDemoText('discover.cleared') });
  },
  // The More button: another random selection of topics.
  refreshDiscover() {
    this.setData({ topics: cylRandomTopics(this.discover.discover, this.data.topics, this.discover.discoverCount, Math.random) });
    this.reloadLists();
  },
  // The camera button: not part of this demo, which says so instead of ignoring the tap.
  searchByImage() {
    wx.showModal({
      title: cylDemoText('discover.imageSearch'),
      content: cylDemoText('discover.imageSearchUnavailable'),
      confirmText: cylDemoText('discover.ok'),
      showCancel: false,
    });
  },
  // A tap (a screen reader's double tap) explains how to ask.
  onMicTap() {
    this.setData({ announcement: cylDemoText('discover.holdMic') });
  },
  onHoldStart() {
    this.setData({ hint: cylDemoText('discover.listening'), announcement: cylDemoText('discover.listening') });
  },
  onHoldEnd() {
    this.setData({ hint: cylDemoText('discover.askHint') });
  },
  onBack() {
    wx.navigateBack();
  },
});
