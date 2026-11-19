// The "Examples" tab (iOS CYLSearchDemoMenuViewController): the reproduction, the placeholder styles, the search bar
// and the other libraries' examples.
const { cylSelectTab } = require('../../utils/cyl_tab_page');
const { cylDemoText } = require('../../utils/cyl_demo_text');

const ROWS = [
  { key: 'demo.reproduction', url: '/pages/reproduction/index' },
  { key: 'demo.styles', url: '/pages/styles/index' },
  { key: 'demo.searchBar', url: '/pages/searchBar/index' },
  { key: 'demo.ports', url: '/pages/ports/index' },
  // Row 5 (iOS row 6, -CYLDemoRow 5): CollectionViewClassifyMenu's contact tags example on CYLSearchViewController.
  { key: 'contactTags.row', url: '/pages/contactTags/index' },
];

// The SVGA demo's icon side (iOS CYLSVGADemoTagButton.iconSide) and style: icon before the title, no border, grey 13 pt.
const SVGA_ICON_SIDE = 64;
const SVGA_STYLE = {
  imageSize: SVGA_ICON_SIDE, animationSize: SVGA_ICON_SIDE, imageTitleSpacing: 12, contentAlignment: 'leading',
  itemHeight: SVGA_ICON_SIDE, allowsTransparentBackground: true, font: 13,
  normal: { backgroundColor: 'transparent', textColor: '#8E8E93', borderWidth: 0, cornerRadius: 0, contentInsets: '0,0,0,0' },
};

Page({
  data: { title: '', rows: [], svgaTitle: '', svgaURL: '/assets/tab/svga/tab_activity.svga.bin', svgaStyle: SVGA_STYLE },
  onLoad() {
    this.setData({
      title: cylDemoText('demo.title'), svgaTitle: cylDemoText('svga.demo'),
      rows: ROWS.map((row) => ({ title: cylDemoText(row.key), url: row.url })),
    });
  },
  onReady() {
    // Plays once when shown, as the tab icons do when selected (iOS didMoveToWindow).
    this.playSVGA();
  },
  onSVGATap() {
    this.playSVGA();
  },
  playSVGA() {
    const tag = this.selectComponent('#svga-demo-tag');
    if (tag) tag.playAnimation();
  },
  onShow() {
    cylSelectTab(this, 'examples');
  },
  onRow(event) {
    wx.navigateTo({ url: event.currentTarget.dataset.url });
  },
});
