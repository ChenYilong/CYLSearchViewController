import { useEffect, useMemo, useRef, useState } from 'react';
import {
  ActivityIndicator, KeyboardAvoidingView, Pressable, ScrollView, StyleSheet, Text, TextInput, View,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { CYLPlaceholderView, CYLSearchBarView, CYLTagListView } from 'react-native-cylsearch';
import data from './contact-tags.json';

/**
 * The contact tags demo (iOS CYLContactRemarkViewController, CYLContactTagEditorViewController,
 * CYLContactListViewController): Edit Remarks, Edit Tags with this library's search bar and CollectionViewClassifyMenu's
 * tag lists (ids, selection, Manage with crosses and renaming in the editing bar, Recent's clear button, folding), the
 * contacts of a tag, CYLTableViewPlaceHolder's placeholders, and a simulated server (cache B, a delay, a HUD). The
 * caches live in memory for the example's run (no storage package in the example).
 */
type Tag = { id: string; title: string };
type Contact = { name: string; tags: string[] };

const GREEN = '#07C160';
const LINK = '#576B95';

function text(key: string, ...args: (string | number)[]): string {
  let next = 0;
  const format = (data.strings as Record<string, string>)[key] ?? `contactTags.${key}`;
  return format.replace(/%(@|ld|d)/g, () => String(args[next++] ?? ''));
}

/** The user's tags (iOS CYLContactTagStore), keyed by id. */
class Store {
  tags: Tag[];
  recentIDs: string[];
  contacts: Contact[] = data.contacts as Contact[];

  constructor(tags: Tag[], recent: string[]) {
    this.tags = tags.map((tag) => ({ ...tag }));
    this.recentIDs = recent.filter((id) => this.contains(id)).slice(0, 8);
  }
  contains(id: string) { return this.tags.some((tag) => tag.id === id); }
  title(id: string) { return this.tags.find((tag) => tag.id === id)?.title ?? id; }
  idOfTitle(title: string) { return this.tags.find((tag) => tag.title === title)?.id; }
  matching(query: string) {
    const fold = (value: string) => value.normalize('NFKD').replace(/[̀-ͯ]/g, '').toLowerCase();
    const q = fold(query.trim());
    if (!q) return [];
    const hits = this.tags.filter((tag) => fold(tag.title).includes(q));
    const prefixed = hits.filter((tag) => fold(tag.title).startsWith(q));
    return prefixed.concat(hits.filter((tag) => !prefixed.includes(tag))).map((tag) => tag.id);
  }
  canCreate(name: string) { const title = name.trim(); return !!title && !this.idOfTitle(title); }
  create(name: string) {
    const title = name.trim();
    if (!title) return undefined;
    const existing = this.idOfTitle(title);
    if (existing) return existing;
    const id = `u-${Math.random().toString(16).slice(2, 10)}`;
    this.tags = [...this.tags, { id, title }];
    return id;
  }
  rename(id: string, title: string) { const name = title.trim(); if (name) this.tags = this.tags.map((tag) => (tag.id === id ? { id, title: name } : tag)); }
  move(from: number, to: number) { const tags = [...this.tags]; tags.splice(to, 0, ...tags.splice(from, 1)); this.tags = tags; }
  remove(id: string) { this.tags = this.tags.filter((tag) => tag.id !== id); this.recentIDs = this.recentIDs.filter((recent) => recent !== id); }
  markUsed(used: string[]) { const known = used.filter((id) => this.contains(id)); this.recentIDs = [...known, ...this.recentIDs.filter((id) => !known.includes(id))].slice(0, 8); }
  get sections() { return { mine: this.tags.map((tag) => ({ ...tag })), recent: this.recentIDs.map((id) => ({ id, title: this.title(id) })) }; }
  apply(sections: { mine?: Tag[]; recent?: Tag[] }) {
    let changed = false;
    if (sections.mine && JSON.stringify(sections.mine) !== JSON.stringify(this.tags)) {
      this.tags = sections.mine.map((tag) => ({ ...tag }));
      this.recentIDs = this.recentIDs.filter((id) => this.contains(id));
      changed = true;
    }
    if (sections.recent) {
      const ids = sections.recent.map((tag) => tag.id).filter((id) => this.contains(id));
      if (ids.join() !== this.recentIDs.join()) { this.recentIDs = ids; changed = true; }
    }
    return changed;
  }
}

/** The simulated server's data (cache B), shared by the demo's screens. */
let serverData: { mine?: Tag[]; recent?: Tag[] } = {};
let sharedStore: Store | null = null;

function makeStore(empty: boolean) {
  return empty ? new Store([], []) : new Store(data.tags as Tag[], data.recentTags as string[]);
}

/** A HUD as CYLPlaceholderHUD shows it: a spinner or a check mark above a status. */
function HUD({ hud }: { hud: { status: string; done: boolean } | null }) {
  if (!hud) return null;
  return (
    <View pointerEvents="none" style={styles.hudLayer}>
      <View style={styles.hud} accessibilityLiveRegion="polite">
        {hud.done ? <Text style={styles.hudCheck}>✓</Text> : <ActivityIndicator color="#333" />}
        <Text style={styles.hudText}>{hud.status}</Text>
      </View>
    </View>
  );
}

export function ContactTagsDemo({ onClose, empty = false, latency = 5 }: { onClose: () => void; empty?: boolean; latency?: number }) {
  const store = useMemo(() => (sharedStore = sharedStore && !empty ? sharedStore : makeStore(empty)), [empty]);
  const [screen, setScreen] = useState<'remark' | 'editor' | 'contacts'>('remark');
  const [tags, setTags] = useState<string[]>(() => (empty ? [] : (data.selectedTags as string[]).filter((id) => store.contains(id))));
  const [changed, setChanged] = useState(false);
  const [contactsOf, setContactsOf] = useState('');

  if (screen === 'contacts') {
    const contacts = store.contacts.filter((contact) => contact.tags.includes(contactsOf));
    return (
      <SafeAreaView style={styles.grouped} edges={['top', 'bottom']}>
        <Bar title={text('contactsTitle', store.title(contactsOf), contacts.length)} onBack={() => setScreen('editor')} />
        {contacts.length ? (
          <ScrollView contentContainerStyle={styles.card} testID="CYLContactList">
            {contacts.map((contact) => (
              <View key={contact.name} style={styles.row}>
                <Text style={styles.rowTitle}>{contact.name}</Text>
                <Text style={styles.rowSubtitle}>{contact.tags.map((id) => store.title(id)).join(' · ')}</Text>
              </View>
            ))}
          </ScrollView>
        ) : (
          <CYLPlaceholderView style={styles.fill} placeholderStyle="personOff" text={text('noContacts', store.title(contactsOf))} testID="CYLContactListEmpty" />
        )}
      </SafeAreaView>
    );
  }
  if (screen === 'editor') {
    return (
      <Editor store={store} latency={latency} initial={tags}
        onCancel={() => setScreen('remark')}
        onDone={(selected) => { setTags(selected); setChanged(true); setScreen('remark'); }}
        onContacts={(id) => { setContactsOf(id); setScreen('contacts'); }} />
    );
  }
  return (
    <SafeAreaView style={styles.page} edges={['top', 'bottom']}>
      <Bar title="" onBack={onClose} right={<Text style={[styles.barButton, !changed && styles.disabled]}>{text('done')}</Text>} />
      <ScrollView>
        <Text style={styles.largeTitle} accessibilityRole="header">{text('editRemarks')}</Text>
        <TextInput style={styles.name} placeholder={text('remarkName')} accessibilityLabel={text('remarkName')} />
        <Pressable accessibilityRole="button" accessibilityHint={text('hintEdit')} testID="CYLContactRemarkTagsTitle" onPress={() => setScreen('editor')}>
          <Text style={styles.tagsTitle}>{text('tags')} ›</Text>
        </Pressable>
        {tags.length ? (
          <Pressable onPress={() => setScreen('editor')} testID="CYLContactRemarkTags">
            <CYLTagListView backgroundStyle="liquidGlass" tags={tags.map((id) => store.title(id))} tagIds={tags} foldedRowCount={0} foldControlPosition="none" />
          </Pressable>
        ) : (
          <Pressable accessibilityRole="button" accessibilityHint={text('hintEdit')} testID="CYLContactRemarkEmptyTags" onPress={() => setScreen('editor')}>
            <CYLPlaceholderView style={styles.remarkPlaceholder} placeholderStyle="empty" text={text('remarkNoTags')} />
          </Pressable>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function Bar({ title, onBack, right }: { title: string; onBack: () => void; right?: React.ReactNode }) {
  return (
    <View style={styles.bar}>
      <Pressable accessibilityRole="button" accessibilityLabel="Back" onPress={onBack} style={styles.barSide}><Text style={styles.back}>‹</Text></Pressable>
      <Text style={styles.barTitle} numberOfLines={1}>{title}</Text>
      <View style={[styles.barSide, styles.barRight]}>{right}</View>
    </View>
  );
}

function Editor({ store, latency, initial, onCancel, onDone, onContacts }: {
  store: Store; latency: number; initial: string[]; onCancel: () => void; onDone: (selected: string[]) => void; onContacts: (id: string) => void;
}) {
  const [, setVersion] = useState(0);
  const refresh = () => setVersion((v) => v + 1);
  const [selected, setSelected] = useState<string[]>(initial);
  const [query, setQuery] = useState('');
  const [managing, setManaging] = useState(false);
  const [renamingID, setRenamingID] = useState<string | null>(null);
  const [editingText, setEditingText] = useState('');
  const [hud, setHUD] = useState<{ status: string; done: boolean } | null>(null);
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);
  const nextStatus = useRef<string | null>(null);

  const later = (action: () => void, seconds = latency) => { timers.current.push(setTimeout(action, seconds * 1000)); };
  const showHUD = (status: string, done = false) => { setHUD({ status, done }); if (done) later(() => setHUD(null), 1.2); };
  const fetch = (keys: ('mine' | 'recent')[]) => {
    const status = nextStatus.current ?? text('downloading');
    const finished = text(nextStatus.current ? 'synced' : 'downloaded');
    nextStatus.current = null;
    showHUD(status);
    later(() => {
      const sections: { mine?: Tag[]; recent?: Tag[] } = {};
      keys.forEach((key) => { if (serverData[key]) sections[key] = serverData[key]; });
      if (store.apply(sections)) refresh();
      showHUD(finished, true);
    });
  };
  const upload = () => {
    showHUD(text('uploading'));
    const sections = store.sections;
    later(() => { serverData = { ...serverData, ...sections }; showHUD(text('uploaded'), true); });
  };
  const sync = () => {
    // Another device edits the server's data (a random new tag, the first two swapped), then this device pulls it.
    const tags = [...(serverData.mine ?? store.sections.mine)];
    const titles = new Set(tags.map((tag) => tag.title));
    const pool = text('otherDeviceTags').split(',').filter((title) => !titles.has(title));
    tags.push({ id: `o-${Math.random().toString(16).slice(2, 10)}`, title: pool[Math.floor(Math.random() * pool.length)] ?? `Tag ${tags.length}` });
    if (tags.length > 1) [tags[0], tags[1]] = [tags[1]!, tags[0]!];
    serverData = { ...serverData, mine: tags };
    nextStatus.current = text('syncing');
    fetch(['mine']);
  };

  // eslint-disable-next-line react-hooks/exhaustive-deps
  useEffect(() => { fetch(['mine', 'recent']); return () => timers.current.forEach(clearTimeout); }, []);

  const toggle = (id: string, isSelected: boolean) => setSelected((list) => (isSelected ? [...list.filter((item) => item !== id), id] : list.filter((item) => item !== id)));
  const create = (name: string) => {
    const id = store.create(name);
    if (!id) return;
    setSelected((list) => (list.includes(id) ? list : [...list, id]));
    setQuery('');
    refresh();
  };
  const setManage = (value: boolean) => {
    if (!value && managing) upload();
    setManaging(value);
    setRenamingID(null);
    setEditingText('');
    if (value) setQuery('');
  };
  const doneEnabled = !query && (selected.length > 0 || selected.join() !== initial.join());
  const results = query ? store.matching(query) : [];
  const emptyState = query ? (results.length ? null : 'noMatch') : (store.tags.length ? null : 'noTags');

  return (
    <SafeAreaView style={styles.page} edges={['top', 'bottom']}>
      <Bar title={text('editTags')} onBack={onCancel} right={
        <View style={styles.actions}>
          <Pressable accessibilityRole="button" accessibilityLabel={text('sync')} testID="CYLContactTagsSync" onPress={sync}><Text style={styles.sync}>⟳</Text></Pressable>
          <Pressable accessibilityRole="button" testID="CYLContactTagsDone" disabled={!doneEnabled}
            onPress={() => { store.markUsed(selected); onDone(selected); }}
            style={[styles.done, doneEnabled && styles.doneOn]}>
            <Text style={[styles.doneText, doneEnabled && styles.doneTextOn]}>{text('done')}</Text>
          </Pressable>
        </View>} />
      {/* 'padding' on both: the Android window is not resized for the keyboard (edge to edge), so the editing bar rides on it. */}
      <KeyboardAvoidingView style={styles.fill} behavior="padding">
        {/* The search field is this library's CYLSearchBarView. */}
        <CYLSearchBarView style={styles.search} placeholder={text('search')} text={query}
          onTextChange={(event) => { const value = event.nativeEvent.text.trim(); if (value && managing) setManage(false); setQuery(value); }}
          onSubmit={() => { if (store.canCreate(query)) create(query); }} />
        <ScrollView style={styles.fill} keyboardShouldPersistTaps="handled">
          {query ? (
            <>
              <CYLTagListView backgroundStyle="liquidGlass" sectionTitle={text('results')} tags={results.map((id) => store.title(id))} tagIds={results}
                selectionMode="multiple" selectedIds={selected} foldControlPosition="none"
                onTagSelect={(event) => toggle(event.nativeEvent.id, event.nativeEvent.selected)} />
              {store.canCreate(query) ? (
                <Pressable style={styles.create} testID="CYLContactTagsCreate" onPress={() => create(query)}><Text>＋ {text('newTag')}: {query}</Text></Pressable>
              ) : null}
            </>
          ) : (
            <>
              {store.recentIDs.length ? (
                // Recent: CollectionViewClassifyMenu's built-in clear button in the header.
                <CYLTagListView backgroundStyle="liquidGlass" sectionTitle={text('recent')} showsClearButton tags={store.recentIDs.map((id) => store.title(id))} tagIds={store.recentIDs}
                  selectionMode="multiple" selectedIds={selected} foldControlPosition="none"
                  onTagSelect={(event) => toggle(event.nativeEvent.id, event.nativeEvent.selected)}
                  onClearButtonTap={() => { store.recentIDs = []; refresh(); }} />
              ) : null}
              <View style={styles.header}>
                <Text style={styles.headerTitle} accessibilityRole="header">{text('mine')}</Text>
                <Pressable accessibilityRole="button" accessibilityHint={text('hintManage')} testID="CYLContactTagsManage" onPress={() => setManage(!managing)}>
                  <Text style={styles.manage}>{text(managing ? 'doneManaging' : 'manage')}</Text>
                </Pressable>
              </View>
              {/* "+ New Tag" below opens Manage, whose editing bar adds the typed name (React Native has no cross-platform prompt). */}
              {/* My Tags: folded to three rows, the chevron as its last tag; editing while managing (crosses, dragging, renaming). */}
              <CYLTagListView backgroundStyle="liquidGlass" tags={store.tags.map((tag) => tag.title)} tagIds={store.tags.map((tag) => tag.id)}
                selectionMode={managing ? 'none' : 'multiple'} selectedIds={selected} editing={managing} supportsRenaming
                foldControlPosition="inline" foldControlContent="icon" foldedRowCount={3}
                onTagSelect={(event) => (managing ? onContacts(event.nativeEvent.id) : toggle(event.nativeEvent.id, event.nativeEvent.selected))}
                onTagDelete={(event) => { store.remove(event.nativeEvent.id); setSelected((list) => list.filter((id) => id !== event.nativeEvent.id)); refresh(); }}
                onTagMove={(event) => { store.move(event.nativeEvent.from, event.nativeEvent.to); refresh(); }}
                onRenameRequest={(event) => { setRenamingID(event.nativeEvent.id); setEditingText(event.nativeEvent.title); }} />
              {!managing ? (
                <Pressable style={styles.create} testID="CYLContactTagsNewTag" onPress={() => setManage(true)}><Text>＋ {text('newTag')}</Text></Pressable>
              ) : null}
            </>
          )}
          {emptyState ? (
            <CYLPlaceholderView style={styles.placeholder} placeholderStyle={emptyState === 'noMatch' ? 'noResults' : 'empty'}
              text={text(emptyState)} testID="CYLContactTagsPlaceholder" />
          ) : null}
        </ScrollView>
        {managing ? (
          // The edit field of "Manage": the core's editing bar, above the keyboard (KeyboardAvoidingView).
          <CYLSearchBarView style={styles.editingBar} editingBar actionTitle={text(renamingID ? 'done' : 'add')} placeholder={text('tagName')}
            text={editingText} testID="CYLSearchEditingBar"
            onEditingSubmit={(event) => {
              const name = event.nativeEvent.text;
              if (renamingID) store.rename(renamingID, name); else store.create(name);
              setRenamingID(null);
              setEditingText('');
              refresh();
            }} />
        ) : null}
      </KeyboardAvoidingView>
      <HUD hud={hud} />
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  fill: { flex: 1 },
  page: { flex: 1, backgroundColor: '#fff' },
  grouped: { flex: 1, backgroundColor: '#F2F2F7' },
  bar: { height: 48, flexDirection: 'row', alignItems: 'center', paddingHorizontal: 8 },
  barSide: { minWidth: 72, justifyContent: 'center' },
  barRight: { alignItems: 'flex-end' },
  barTitle: { flex: 1, textAlign: 'center', fontSize: 17, fontWeight: '600', color: '#000' },
  back: { fontSize: 32, color: '#007AFF', paddingHorizontal: 8 },
  barButton: { fontSize: 17, color: '#007AFF', paddingHorizontal: 8 },
  disabled: { color: '#C7C7CC' },
  actions: { flexDirection: 'row', alignItems: 'center' },
  sync: { fontSize: 22, color: LINK, paddingHorizontal: 8 },
  done: { paddingHorizontal: 12, height: 32, borderRadius: 4, justifyContent: 'center', backgroundColor: 'rgba(120,120,128,0.16)' },
  doneOn: { backgroundColor: GREEN },
  doneText: { fontSize: 17, fontWeight: '600', color: 'rgba(60,60,67,0.3)' },
  doneTextOn: { color: '#fff' },
  largeTitle: { marginTop: 32, textAlign: 'center', fontSize: 28, fontWeight: '700', color: '#000' },
  name: { marginTop: 36, marginHorizontal: 16, height: 48, paddingHorizontal: 12, borderRadius: 8, backgroundColor: '#F2F2F7', fontSize: 17 },
  tagsTitle: { paddingHorizontal: 16, paddingTop: 16, paddingBottom: 4, fontSize: 15, color: 'rgba(60,60,67,0.6)' },
  remarkPlaceholder: { height: 200, marginHorizontal: 16 },
  search: { height: 56, marginHorizontal: 8 },
  header: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', paddingHorizontal: 16, paddingTop: 12, paddingBottom: 4 },
  headerTitle: { fontSize: 15, color: 'rgba(60,60,67,0.6)' },
  manage: { fontSize: 15, color: LINK },
  create: { alignSelf: 'flex-start', marginHorizontal: 16, marginVertical: 8, paddingHorizontal: 14, height: 36, justifyContent: 'center', borderRadius: 6, borderWidth: 1, borderColor: '#C6C6C8' },
  placeholder: { height: 240, marginHorizontal: 16 },
  editingBar: { height: 56, backgroundColor: '#fff' },
  card: { margin: 16, borderRadius: 10, backgroundColor: '#fff' },
  row: { paddingHorizontal: 16, paddingVertical: 10, borderBottomWidth: StyleSheet.hairlineWidth, borderBottomColor: '#E5E5EA' },
  rowTitle: { fontSize: 17, color: '#000' },
  rowSubtitle: { fontSize: 13, color: 'rgba(60,60,67,0.6)' },
  // Over the middle of the page, as CYLPlaceholderHUD.
  hudLayer: { position: 'absolute', top: '40%', left: 0, right: 0, alignItems: 'center' },
  hud: { minWidth: 120, maxWidth: 260, padding: 16, borderRadius: 14, backgroundColor: 'rgba(255,255,255,0.96)', alignItems: 'center', elevation: 6, shadowOpacity: 0.15, shadowRadius: 10 },
  hudCheck: { fontSize: 32, color: '#333' },
  hudText: { marginTop: 8, fontSize: 15, color: '#333', textAlign: 'center' },
});
