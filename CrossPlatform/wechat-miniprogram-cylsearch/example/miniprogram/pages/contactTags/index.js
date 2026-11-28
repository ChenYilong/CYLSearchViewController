// "Edit Remarks" (iOS CYLContactRemarkViewController): a remark name and the contact's tags (a display-only
// cyl-tag-cloud); "Tags" opens "Edit Tags". Without tags, CYLTableViewPlaceHolder's placeholder takes the list's place
// and opens the editor too. Launch options (query): editor=1 opens the editor, empty=1 starts without tags, reset=1
// forgets the saved edits, latency=<seconds> is the server's delay (iOS -CYLContactTags* launch arguments).
const { cylContactTagsText: t, cylContactTagsSharedStore, bundledData, cylContactTagStyle } = require('../../utils/cyl_contact_tags');

// cyl-tag-cloud's full style with the demo's look.
const STYLE = cylContactTagStyle(require('cyl-tag-list-miniprogram').tagCloud.defaultStyle());

Page({
  data: { texts: { editRemarks: '', remarkName: '', tags: '', hintEdit: '', done: '', remarkNoTags: '' }, style: STYLE, tags: [], doneEnabled: false, placeholderComponents: [] },

  onLoad(query) {
    const options = query || {};
    this.latency = options.latency;
    this.store = cylContactTagsSharedStore({ reset: options.reset === '1', empty: options.empty === '1' });
    const selected = options.empty === '1' ? [] : bundledData().selectedTags.filter((id) => this.store.contains(id));
    this.setData({
      texts: { editRemarks: t('editRemarks'), remarkName: t('remarkName'), tags: t('tags'), hintEdit: t('hintEdit'), done: t('done'), remarkNoTags: t('remarkNoTags') },
      placeholderComponents: [{ type: 'icon', image: 'empty', title: t('remarkNoTags'), side: 96, tinted: false }],
    });
    this.updateTags(selected, false);
    if (options.editor === '1') setTimeout(() => this.editTags(), 300);
  },

  updateTags(ids, changed) {
    this.selected = ids;
    this.setData({
      tags: ids.map((id) => ({ identifier: id, title: this.store.title(id) || id, isEnabled: true, isDeletable: false })),
      doneEnabled: !!changed || this.data.doneEnabled,
    });
  },

  /** Opens "Edit Tags"; its Done reports the selection back. */
  editTags() {
    const latency = this.latency !== undefined ? `&latency=${this.latency}` : '';
    wx.navigateTo({
      url: `/pages/contactTagEditor/index?selected=${encodeURIComponent(this.selected.join(','))}${latency}`,
      events: { done: (result) => this.updateTags(result.tags || [], true) },
    });
  },
});
