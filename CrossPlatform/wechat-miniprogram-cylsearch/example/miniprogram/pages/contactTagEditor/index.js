// "Edit Tags" (iOS CYLContactTagEditorViewController): chooses, creates, renames and deletes a contact's tags, searched
// with this library's cyl-search-bar; the tags are CollectionViewClassifyMenu's cyl-tag-cloud (one per section).
// - "Recent" (the cloud's built-in clear button) and "My Tags" (with "Manage").
// - "Manage" switches "My Tags" into the cloud's editing mode: the pencil and the cross on each tag, dragging; the pencil
//   or a title tap renames in the editing bar (cyl-search-bar editingBar, pinned to the keyboard), which adds otherwise.
// - Typing shows "Search Results" and "+ New tag: <text>"; the confirm key creates the typed tag.
// - CYLTableViewPlaceHolder's cyl-placeholder shows the empty states (no match, no tags).
// - Network sync (CYLContactTagServer): opening shows cache A at once, then downloads B; leaving "Manage" uploads; the
//   sync button pulls an edit simulated on another device.
// Launch options (query): latency=<seconds>.
const { cylContactTagsText: t, cylContactTagsSharedStore, CYLContactTagServer, MINE, RECENT, cylContactTagStyle } = require('../../utils/cyl_contact_tags');

// cyl-tag-cloud's full style with the demo's look.
const STYLE = cylContactTagStyle(require('cyl-tag-list-miniprogram').tagCloud.defaultStyle());

function tagsOf(store, ids) {
  return ids.map((id) => ({ identifier: id, title: store.title(id) || id, isEnabled: true, isDeletable: false }));
}

Page({
  data: {
    texts: { editTags: '', search: '', recent: '', mine: '', results: '', manage: '', doneManaging: '', done: '', sync: '', newTag: '', tagName: '', add: '' }, style: STYLE, query: '', managing: false, doneEnabled: false,
    recentTags: [], mineTags: [], resultTags: [], canCreate: false, createTitle: '',
    emptyState: 'none', placeholderComponents: [],
  },

  onLoad(query) {
    this.store = cylContactTagsSharedStore();
    const channel = this.getOpenerEventChannel ? this.getOpenerEventChannel() : null;
    this.channel = channel;
    // The contact's tags, passed by Edit Remarks as ids (selected=t01,t05).
    const selected = decodeURIComponent(String((query && query.selected) || ''));
    this.initialSelection = (selected ? selected.split(',') : []).filter((id) => this.store.contains(id));
    this.selectedTags = this.initialSelection.slice();
    this.setData({
      texts: {
        editTags: t('editTags'), search: t('search'), recent: t('recent'), mine: t('mine'), results: t('results'), manage: t('manage'),
        doneManaging: t('doneManaging'), done: t('done'), sync: t('sync'), newTag: t('newTag'), tagName: t('tagName'), add: t('add'),
        clearRecent: t('clearRecent'), hintManage: t('hintManage'),
      },
      editingTitle: t('add'),
    });
    this.latency = query && query.latency !== undefined ? Number(query.latency) : 5;
  },

  onReady() {
    this.hud = this.selectComponent('#hud') ? this.selectComponent('#hud').hud : null;
    this.server = new CYLContactTagServer(this.hud, this.latency);
    const mine = this.selectComponent('#mine');
    if (mine) mine.setRenameRequestHandler((position, title) => this.beginRenaming(position, title));
    this.reload();
    // Cache A is what the store already shows; the server's sections, when they arrive, replace them.
    this.server.fetch([MINE, RECENT], (sections) => {
      if (this.store.apply(sections)) this.reload();
    });
  },

  onUnload() {
    if (this.server) this.server.cancel();
  },

  // Content

  reload() {
    const query = this.data.query;
    const store = this.store;
    const resultIDs = query ? store.tagsMatching(query) : [];
    let emptyState = 'none';
    if (query) emptyState = resultIDs.length ? 'none' : 'noMatch';
    else if (!store.tags.length) emptyState = 'noTags';
    const placeholder = emptyState === 'noMatch' ? { type: 'icon', image: 'no_results', title: t('noMatch'), side: 96, tinted: true }
      : emptyState === 'noTags' ? { type: 'icon', image: 'empty', title: t('noTags'), side: 96, tinted: false } : null;
    this.recentIDs = query ? [] : store.recentIDs.slice();
    this.mineIDs = query ? [] : store.tagIDs;
    this.resultIDs = resultIDs;
    this.setData({
      recentTags: tagsOf(store, this.recentIDs), mineTags: tagsOf(store, this.mineIDs), resultTags: tagsOf(store, resultIDs),
      canCreate: !!query && store.canCreate(query), createTitle: query,
      emptyState, placeholderComponents: placeholder ? [placeholder] : [],
    }, () => this.syncSelection());
    this.updateDone();
  },

  /** Shows every occurrence of a selected tag as selected (a tag in both sections). */
  syncSelection() {
    [['#recent', this.recentIDs], ['#mine', this.mineIDs], ['#results', this.resultIDs]].forEach(([selector, ids]) => {
      const cloud = this.selectComponent(selector);
      if (!cloud || !ids) return;
      cloud.deselectAll();
      ids.forEach((id, index) => { if (this.selectedTags.includes(id)) cloud.toggleSelection(index); });
    });
  },

  /** "Done" is green with a selection or a change, and off while searching. */
  updateDone() {
    const changed = this.selectedTags.length !== this.initialSelection.length || this.selectedTags.some((id) => !this.initialSelection.includes(id));
    this.setData({ doneEnabled: !this.data.query && (this.selectedTags.length > 0 || changed) });
  },

  toggle(id) {
    if (this.selectedTags.includes(id)) this.selectedTags = this.selectedTags.filter((selected) => selected !== id);
    else this.selectedTags.push(id);
    this.syncSelection();
    this.updateDone();
  },

  // Search

  onSearchText(event) {
    const query = String(event.detail.text || '').trim();
    if (this.data.managing && query) this.setManaging(false);
    this.setData({ query }, () => this.reload());
  },

  onSearchSubmit() {
    if (this.store.canCreate(this.data.query)) this.createTag(this.data.query);
  },

  createTag(name) {
    const id = this.store.createTag(name);
    if (!id) return;
    if (!this.selectedTags.includes(id)) this.selectedTags.push(id);
    this.setData({ query: '' }, () => this.reload());
  },

  onCreateTap() {
    this.createTag(this.data.createTitle);
  },

  onNewTagTap() {
    wx.showModal({
      title: t('newTag'), editable: true, placeholderText: t('tagName'), cancelText: t('cancel'), confirmText: t('ok'),
      success: (result) => { if (result.confirm && result.content) this.createTag(result.content); },
    });
  },

  // Tags

  onTagTap(event) {
    const tag = event.detail.tag || {};
    const id = tag.identifier;
    if (!id) return;
    if (this.data.managing && event.currentTarget.id === 'mine') {
      // A tap outside the pencil and the title in "Manage": the tag's contacts.
      this.showContacts(id);
      return;
    }
    this.toggle(id);
  },

  onTagDelete(event) {
    const id = (event.detail.tag || {}).identifier;
    if (!id) return;
    this.store.deleteTag(id);
    this.selectedTags = this.selectedTags.filter((selected) => selected !== id);
    this.reload();
  },

  onTagMove(event) {
    this.store.moveTag(event.detail.from, event.detail.to);
    this.mineIDs = this.store.tagIDs;
  },

  onTagRename(event) {
    const id = (event.detail.tag || {}).identifier;
    if (id) this.store.renameTag(id, event.detail.title);
    this.reload();
  },

  onRequestNewItem(event) {
    this.store.createTag(event.detail.name);
    this.reload();
  },

  onClearRecent() {
    this.store.clearRecent();
    this.reload();
  },

  onEditingFinish() {
    // Leaving "Manage" uploads the edited lists (cache A, already saved) to the server.
    if (this.server) this.server.upload(this.store.cacheSections);
  },

  // Manage and the editing bar

  onManageTap() {
    this.setManaging(!this.data.managing);
  },

  setManaging(managing) {
    if (managing) this.setData({ query: '' });
    this.renamingPosition = undefined;
    this.setData({ managing, editingTitle: t('add'), editingText: '' }, () => this.reload());
  },

  beginRenaming(position, title) {
    this.renamingPosition = position;
    // The editing bar takes the keyboard for each new title itself (cyl-search-bar `editingBar`), every rename.
    this.setData({ editingTitle: t('done'), editingText: title });
  },

  onEditingSubmit(event) {
    const text = event.detail.text;
    const mine = this.selectComponent('#mine');
    if (this.renamingPosition !== undefined) {
      this.renamingPosition = undefined;
      if (mine) mine.finishRenaming(text);
    } else if (mine) {
      mine.submitNewItem(text);
    }
    this.setData({ editingTitle: t('add'), editingText: '', editingFocus: false });
  },

  // Sync, contacts, done

  onSyncTap() {
    if (!this.server) return;
    this.server.simulateOtherDeviceEdit(this.store.cacheSections[MINE]);
    this.server.fetch([MINE], (sections) => {
      if (this.store.apply(sections)) this.reload();
    });
  },

  showContacts(id) {
    wx.navigateTo({ url: `/pages/contactList/index?id=${encodeURIComponent(id)}` });
  },

  onDoneTap() {
    if (!this.data.doneEnabled) return;
    this.store.markUsed(this.selectedTags);
    if (this.channel) this.channel.emit('done', { tags: this.selectedTags.slice() });
    wx.navigateBack();
  },
});
