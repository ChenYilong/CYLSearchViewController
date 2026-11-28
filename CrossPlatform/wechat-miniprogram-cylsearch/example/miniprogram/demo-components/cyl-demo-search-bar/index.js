// The search bar demo (iOS CYLSearchBarDemoViewController): CYLSearchBarView with Cancel, a soft shadow and a camera
// accessory inside the field; the label under it shows the text, then "Searched: …" after the Search key.
const { cylDemoText } = require('../../utils/cyl_demo_text');

Component({
  properties: {
    inTabBar: { type: Boolean, value: false },
  },
  data: { title: '', placeholder: '', status: '', cameraLabel: '' },
  lifetimes: {
    attached() {
      this.setData({
        title: cylDemoText('demo.searchBar'),
        placeholder: cylDemoText('demo.searchBar.placeholder'),
        cameraLabel: cylDemoText('demo.searchBar.camera'),
        status: cylDemoText('demo.searchBar.text', ''),
      });
    },
  },
  methods: {
    onTextChange(event) {
      this.setData({ status: cylDemoText('demo.searchBar.text', event.detail.text) });
    },
    onSubmit(event) {
      this.setData({ status: cylDemoText('demo.searchBar.searched', event.detail.text) });
    },
    onCancel() {
      const bar = this.selectComponent('#bar');
      bar.setText('', false);
      bar.hideKeyboard();
      this.setData({ status: cylDemoText('demo.searchBar.text', '') });
    },
  },
});
