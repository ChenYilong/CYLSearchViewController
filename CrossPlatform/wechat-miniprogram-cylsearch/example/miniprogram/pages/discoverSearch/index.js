// The Discover page, pushed from the "Discover" tab's entry page (pages/discover) (iOS CYLSearchDiscoverViewController, copied from CollectionViewClassifyMenu's CYLMenuExample):
// a search app's search page. The search bar takes the navigation bar's place: a bordered capsule without a magnifier,
// the camera, a divider and the Search button appended inside it. "Recent searches" are tags folded to two rows with
// the chevron as the last tag and a trash button; "Discover" is a grid of two titles per row, a hot icon after a hot
// title, and the core's refresh button showing the next page of topics, cyclically. At the bottom: "Hold to ask" over a curved area. The
// data comes from search-discover.json of the iOS example; this page only shows it and handles the taps.
const { cylDemoText, cylDemoLanguage, cylDiscoverData, cylHotIcon } = require('../../utils/cyl_demo_text');
const { cylTopicPage, cylNextTopicPage, cylSearchedRecent } = require('../../utils/cyl_discover_logic');
const { cylFoldTags } = require('../../components/core/CYLSearchView');
const { cylNavigationMetrics } = require('../../components/core/CYLSearchResources');

const TAG_SPACING = 12;
const SIDE_INSET = 16;
// The fold chevron's labels: CollectionViewClassifyMenu's CYLMenuExpand / CYLMenuCollapse (CYLClassifyMenu.strings).
const FOLD_LABELS = { en: ['More', 'Less'], 'zh-Hans': ['更多', '收起'], 'zh-Hant': ['更多', '收合'] };
// The animated bar item (index 1): the SVGA the Examples page plays, as the other platforms' Discover pages do.
const ANIMATION_ITEM_INDEX = 1;
const ANIMATION_URL = '/assets/tab/svga/tab_activity.svga.bin';
const CAMERA_IMAGE = '/assets/discover/camera.viewfinder.svg';

Page({
  data: {
    texts: {}, showsBack: false, fieldHeight: 36,
    query: '', placeholder: '', items: [], loops: false, speed: 1, speedText: '1.00x',
    recent: [], visibleRecent: [], needsFold: false, folded: true,
    topics: [], hotIcon: '', hint: '', announcement: '', foldLabels: FOLD_LABELS.en,
  },
  onLoad() {
    const metrics = cylNavigationMetrics();
    const data = cylDiscoverData();
    this.discover = data;
    this.topicPage = 0;
    this.setData({
      texts: {
        recent: cylDemoText('discover.recent'), title: cylDemoText('discover.title'),
        back: cylDemoText('discover.back'), clear: cylDemoText('discover.clear'), tapToSearch: cylDemoText('discover.tapToSearch'),
        ask: cylDemoText('discover.ask'), askHint: cylDemoText('discover.askAccessibilityHint'), hot: cylDemoText('discover.hot'),
        search: cylDemoText('discover.search'),
        animationLoops: cylDemoText('discover.animationLoops'), animationSpeed: cylDemoText('discover.animationSpeed'),
        animationPlay: cylDemoText('discover.animationPlay'),
      },
      // Always a second-level page: the entry page (pages/discover) opens it with wx.navigateTo, so the back button shows.
      showsBack: true,
      fieldHeight: metrics.fieldHeight,
      items: this.barItems(false, 1),
      recent: data.recentSearches.slice(),
      topics: cylTopicPage(data.discover, data.discoverCount, 0).topics,
      hotIcon: cylHotIcon(),
      foldLabels: FOLD_LABELS[cylDemoLanguage(wx.getAppBaseInfo().language)] || FOLD_LABELS.en,
      hint: cylDemoText('discover.askHint'),
    });
    this.reloadLists();
  },
  // The bar's items: the camera, the animated item (its loop and speed come from the controls below the bar), the
  // divider and the Search button.
  barItems(loops, speed) {
    return [
      { style: 'icon', title: cylDemoText('discover.imageSearch'), image: CAMERA_IMAGE, accessibilityIdentifier: 'camera' },
      {
        style: 'icon', title: cylDemoText('discover.animationItem'), image: CAMERA_IMAGE, accessibilityIdentifier: 'animation',
        animationURL: ANIMATION_URL, animationLoops: loops, animationSpeed: speed,
      },
      { style: 'divider' },
      { style: 'text', title: cylDemoText('discover.search'), accessibilityIdentifier: 'CYLSearchDiscoverSearchButton' },
    ];
  },
  // The loop switch: the animated item loops (or plays once on each tap).
  onLoopsChange(event) {
    const loops = event.detail.value === true;
    this.setData({ loops, items: this.barItems(loops, this.data.speed) });
  },
  // The speed slider (0.25 to 3): the value text follows while dragging, the item takes the speed on release.
  onSpeedChanging(event) {
    this.setData({ speedText: `${event.detail.value.toFixed(2)}x` });
  },
  onSpeedChange(event) {
    const speed = event.detail.value;
    this.setData({ speed, speedText: `${speed.toFixed(2)}x`, items: this.barItems(this.data.loops, speed) });
  },
  // Play again: the bar model's CYLSearchBarItem.restartAnimation().
  onPlayAgain() {
    const bar = this.selectComponent('#bar');
    const item = bar && bar.model && bar.model.items[ANIMATION_ITEM_INDEX];
    if (item) item.restartAnimation();
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
  // The refresh button: the next page of topics, cyclically (no random pick).
  refreshDiscover() {
    const next = cylNextTopicPage(this.discover.discover, this.discover.discoverCount, this.topicPage);
    this.topicPage = next.page;
    this.setData({ topics: next.topics });
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
  // The back button of the core's navigation bar goes back by itself (wx.navigateBack); nothing to do here.
  onBack() {},
});
