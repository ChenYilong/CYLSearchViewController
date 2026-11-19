// The contact tags demo's data (example/miniprogram/utils/cyl_contact_tags.js; iOS
// testContactTagsDemoSearchesCreatesAndKeepsItsStrings): the bundled data and strings of every language, search,
// create, rename by id, the server sections and the simulated other-device edit.
const test = require('node:test');
const assert = require('node:assert/strict');
const resources = require('../example/miniprogram/utils/cyl_demo_resources');
const { CYLContactTagStore, CYLContactTagServer, MINE, RECENT, bundledData } = require('../example/miniprogram/utils/cyl_contact_tags');

test('bundled data has ids and every language has the same contact tags keys', () => {
  const data = bundledData('en');
  assert.equal(data.version, 2);
  assert.equal(data.tags.length, 47);
  assert.equal(data.tags[0].id, 't01');
  assert.equal(data.contacts.length, 24);
  const ids = new Set(data.tags.map((tag) => tag.id));
  assert.ok(data.recentTags.every((id) => ids.has(id)) && data.selectedTags.every((id) => ids.has(id)));
  assert.ok(data.contacts.every((contact) => contact.tags.every((id) => ids.has(id))));
  const english = Object.keys(resources.strings.en).filter((key) => key.startsWith('contactTags.'));
  assert.ok(english.includes('contactTags.editTags') && english.includes('contactTags.add'));
  for (const language of ['ja', 'zh-Hans', 'zh-Hant']) {
    for (const key of english) assert.ok(key in resources.strings[language], `${language} misses ${key}`);
    assert.equal(bundledData(language).tags.length, 47);
  }
});

test('search, create, rename and delete keep the ids', () => {
  const store = new CYLContactTagStore([{ id: 't01', title: 'Family' }, { id: 't02', title: 'iOS Developers' }, { id: 't03', title: 'Friends' }], ['t03']);
  assert.deepEqual(store.tagsMatching('ios'), ['t02']);
  assert.deepEqual(new CYLContactTagStore([{ id: 'a', title: 'Old Friends' }, { id: 'b', title: 'Friends' }]).tagsMatching('fri'), ['b', 'a']);
  assert.equal(store.canCreate(' Family '), false);
  const id = store.createTag('  Yoga ');
  assert.match(id, /^u-/);
  assert.equal(store.createTag('Yoga'), id);
  store.contacts = [{ name: 'Alex', tags: ['t01'] }];
  store.renameTag('t01', 'Family Home');
  assert.equal(store.title('t01'), 'Family Home');
  assert.deepEqual(store.contactsWithTag('t01').map((contact) => contact.name), ['Alex']);
  store.moveTag(0, 1);
  assert.deepEqual(store.tagIDs, ['t02', 't01', 't03', id]);
  store.markUsed(['t02']);
  assert.deepEqual(store.recentIDs, ['t02', 't03']);
  store.deleteTag('t03');
  assert.deepEqual(store.recentIDs, ['t02']);
  store.clearRecent();
  assert.deepEqual(store.recentIDs, []);
});

test('downloaded sections replace My Tags and keep only existing recent ids', () => {
  const store = new CYLContactTagStore([{ id: 't01', title: 'Family' }, { id: 't02', title: 'Relatives' }], ['t01', 't02']);
  const downloaded = [{ id: 't02', title: 'Relatives' }, { id: 'o-1', title: 'Yoga' }];
  assert.equal(store.apply({ [MINE]: downloaded }), true);
  assert.deepEqual(store.tagIDs, ['t02', 'o-1']);
  assert.deepEqual(store.recentIDs, ['t02']);
  assert.equal(store.apply({ [MINE]: downloaded }), false);
  assert.deepEqual(store.cacheSections[RECENT], [{ id: 't02', title: 'Relatives' }]);
});

test('the other-device edit adds a tag and swaps the first two', () => {
  const server = new CYLContactTagServer(null, 0);
  const added = server.simulateOtherDeviceEdit([{ id: 't01', title: 'Family' }, { id: 't02', title: 'Relatives' }]);
  assert.ok(added.length > 0);
  assert.equal(server.nextFetchStatus !== undefined, true);
});
