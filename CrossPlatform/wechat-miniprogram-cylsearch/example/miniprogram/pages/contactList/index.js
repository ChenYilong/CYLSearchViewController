// The contacts that have a tag (iOS CYLContactListViewController): opened from "Manage"; CYLTableViewPlaceHolder's
// placeholder when none has it.
const { cylContactTagsText: t, cylContactTagsSharedStore } = require('../../utils/cyl_contact_tags');

Page({
  data: { title: '', contacts: [], placeholderComponents: [] },

  onLoad(query) {
    const store = cylContactTagsSharedStore();
    const id = decodeURIComponent((query && query.id) || '');
    const name = store.title(id) || id;
    const contacts = store.contactsWithTag(id).map((contact) => ({
      name: contact.name, tags: contact.tags.map((tag) => store.title(tag)).filter(Boolean).join(' · '),
    }));
    this.setData({
      title: t('contactsTitle', name, contacts.length), contacts,
      placeholderComponents: [{ type: 'icon', image: 'person_off', title: t('noContacts', name), side: 96, tinted: true }],
    });
  },
});
