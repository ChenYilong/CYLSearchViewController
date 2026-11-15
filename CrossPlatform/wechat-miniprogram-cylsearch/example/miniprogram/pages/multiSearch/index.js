// Port of iammert/MultiSearchView's sample MainActivity (iOS CYLMultiSearchDemoViewController): a multi-search view
// styled like the README's SearchTextStyle (hint "Search", 18 pt text, at most 15 characters, the Search key, gray hint,
// black text), 16 pt from the top, with every event logged (the sample's Log.v), newest first.
const { cylDemoText } = require('../../utils/cyl_demo_text');

Page({
  data: { hint: '', eventsLabel: '', log: '' },
  onLoad() {
    this.setData({ hint: cylDemoText('search.field'), eventsLabel: cylDemoText('demo.port.events') });
  },
  log(line) {
    this.setData({ log: `${line}\n${this.data.log}` });
  },
  onSelect(event) {
    this.log(`onItemSelected: index: ${event.detail.index}, query: ${event.detail.text}`);
  },
  onTextChange(event) {
    this.log(`changed: index: ${event.detail.index}, query: ${event.detail.text}`);
  },
  onComplete(event) {
    this.log(`complete: index: ${event.detail.index}, query: ${event.detail.text}`);
  },
  onRemove(event) {
    this.log(`remove: index: ${event.detail.index}`);
  },
});
