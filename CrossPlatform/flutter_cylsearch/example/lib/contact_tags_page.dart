import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

import 'contact_tags_data.dart';

// The contact tags demo (iOS CYLContactRemarkViewController, CYLContactTagEditorViewController,
// CYLContactListViewController): Edit Remarks, Edit Tags with this library's search bar and CollectionViewClassifyMenu's
// tag lists (ids, selection, Manage with crosses and renaming in the editing bar, Recent's clear button, folding), the
// contacts of a tag, CYLTableViewPlaceHolder's placeholders, and a simulated server (cache B, a delay, a HUD). The
// caches live in memory for the example's run (no storage package in the example).

final Map<String, Object?> _data = jsonDecode(cylContactTagsJSON) as Map<String, Object?>;

const Color _green = Color(0xFF07C160);
const Color _link = Color(0xFF576B95);
const Color _secondary = Color(0x993C3C43);

/// A localized string of the demo; `%@`, `%d` and `%ld` take `args` in order.
String cylContactText(String key, [List<Object> args = const <Object>[]]) {
  var next = 0;
  final format = (_data['strings'] as Map<String, Object?>)[key] as String? ?? 'contactTags.$key';
  return format.replaceAllMapped(RegExp('%(@|ld|d)'), (_) => next < args.length ? '${args[next++]}' : '');
}

/// A tag: a stable id and a title.
class CYLContactTag {
  /// Creates a tag.
  const CYLContactTag(this.id, this.title);

  /// The id, kept by renaming and reordering.
  final String id;

  /// The title.
  final String title;

  @override
  bool operator ==(Object other) => other is CYLContactTag && other.id == id && other.title == title;

  @override
  int get hashCode => Object.hash(id, title);
}

/// A contact and the ids of its tags.
class CYLContact {
  /// Creates a contact.
  const CYLContact(this.name, this.tags);

  /// The name.
  final String name;

  /// The ids of its tags.
  final List<String> tags;
}

/// The user's tags (iOS CYLContactTagStore), keyed by id.
class CYLContactTagStore {
  /// Creates a store with `tags` and the recent ids that exist.
  CYLContactTagStore(List<CYLContactTag> tags, List<String> recent) : tags = List<CYLContactTag>.of(tags) {
    recentIDs = recent.where(contains).take(8).toList();
  }

  /// The demo's data, or no tags at all.
  factory CYLContactTagStore.demo({bool empty = false}) {
    if (empty) return CYLContactTagStore(const <CYLContactTag>[], const <String>[]);
    final tags = (_data['tags'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((tag) => CYLContactTag(tag['id']! as String, tag['title']! as String))
        .toList();
    return CYLContactTagStore(tags, (_data['recentTags'] as List<Object?>).cast<String>());
  }

  /// The tags, in order.
  List<CYLContactTag> tags;

  /// The recently used tags' ids, at most 8.
  List<String> recentIDs = <String>[];

  /// The contacts.
  final List<CYLContact> contacts = (_data['contacts'] as List<Object?>)
      .cast<Map<String, Object?>>()
      .map((contact) => CYLContact(contact['name']! as String, (contact['tags']! as List<Object?>).cast<String>()))
      .toList();

  /// Whether a tag has this id.
  bool contains(String id) => tags.any((tag) => tag.id == id);

  /// The title of a tag, or the id.
  String title(String id) => tags.firstWhere((tag) => tag.id == id, orElse: () => CYLContactTag(id, id)).title;

  String? _idOfTitle(String title) => tags.where((tag) => tag.title == title).map((tag) => tag.id).firstOrNull;

  /// The ids of the tags that contain `query`, those that start with it first.
  List<String> matching(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const <String>[];
    final hits = tags.where((tag) => tag.title.toLowerCase().contains(q)).toList();
    final prefixed = hits.where((tag) => tag.title.toLowerCase().startsWith(q)).toList();
    return <CYLContactTag>[...prefixed, ...hits.where((tag) => !prefixed.contains(tag))].map((tag) => tag.id).toList();
  }

  /// Whether `name` would be a new tag.
  bool canCreate(String name) => name.trim().isNotEmpty && _idOfTitle(name.trim()) == null;

  /// Adds a tag (or finds the one with that title); its id.
  String? create(String name) {
    final title = name.trim();
    if (title.isEmpty) return null;
    final existing = _idOfTitle(title);
    if (existing != null) return existing;
    final id = 'u-${Random().nextInt(1 << 32).toRadixString(16)}';
    tags = <CYLContactTag>[...tags, CYLContactTag(id, title)];
    return id;
  }

  /// Renames a tag by id.
  void rename(String id, String title) {
    final name = title.trim();
    if (name.isEmpty) return;
    tags = tags.map((tag) => tag.id == id ? CYLContactTag(id, name) : tag).toList();
  }

  /// Moves a tag.
  void move(int from, int to) {
    final list = List<CYLContactTag>.of(tags);
    list.insert(to, list.removeAt(from));
    tags = list;
  }

  /// Removes a tag (and from the recent ones).
  void remove(String id) {
    tags = tags.where((tag) => tag.id != id).toList();
    recentIDs = recentIDs.where((recent) => recent != id).toList();
  }

  /// Puts `used` first among the recent tags.
  void markUsed(List<String> used) {
    final known = used.where(contains).toList();
    recentIDs = <String>[...known, ...recentIDs.where((id) => !known.contains(id))].take(8).toList();
  }

  /// The sections as the server keeps them.
  Map<String, List<CYLContactTag>> get sections => <String, List<CYLContactTag>>{
        'mine': List<CYLContactTag>.of(tags),
        'recent': recentIDs.map((id) => CYLContactTag(id, title(id))).toList(),
      };

  /// Takes the server's sections; whether anything changed.
  bool apply(Map<String, List<CYLContactTag>> sections) {
    var changed = false;
    final mine = sections['mine'];
    if (mine != null && !_sameTags(mine, tags)) {
      tags = List<CYLContactTag>.of(mine);
      recentIDs = recentIDs.where(contains).toList();
      changed = true;
    }
    final recent = sections['recent'];
    if (recent != null) {
      final ids = recent.map((tag) => tag.id).where(contains).toList();
      if (ids.join(',') != recentIDs.join(',')) {
        recentIDs = ids;
        changed = true;
      }
    }
    return changed;
  }

  static bool _sameTags(List<CYLContactTag> a, List<CYLContactTag> b) =>
      a.length == b.length && Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);
}

/// The simulated server's data (cache B), shared by the demo's pages.
Map<String, List<CYLContactTag>> _serverData = <String, List<CYLContactTag>>{};
CYLContactTagStore? _sharedStore;

/// Edit Remarks, the first page of the contact tags demo.
class CYLContactRemarkPage extends StatefulWidget {
  /// Creates the page; `empty` starts without tags, `latency` is the simulated server's delay in seconds.
  const CYLContactRemarkPage({super.key, this.empty = false, this.latency = 2});

  /// Starts without tags (iOS `-CYLContactTagsEmpty YES`).
  final bool empty;

  /// The simulated server's delay, in seconds.
  final double latency;

  @override
  State<CYLContactRemarkPage> createState() => _CYLContactRemarkPageState();
}

class _CYLContactRemarkPageState extends State<CYLContactRemarkPage> {
  late final CYLContactTagStore _store = widget.empty
      ? CYLContactTagStore.demo(empty: true)
      : (_sharedStore ??= CYLContactTagStore.demo());
  late List<String> _tags = widget.empty
      ? <String>[]
      : (_data['selectedTags'] as List<Object?>).cast<String>().where(_store.contains).toList();
  bool _changed = false;

  Future<void> _edit() async {
    final selected = await Navigator.of(context).push<List<String>>(MaterialPageRoute<List<String>>(
      builder: (_) => CYLContactTagEditorPage(store: _store, initial: _tags, latency: widget.latency),
    ));
    if (selected == null || !mounted) return;
    setState(() {
      _tags = selected;
      _changed = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: _changed ? () => Navigator.of(context).pop() : null,
              child: Text(cylContactText('done'), style: const TextStyle(fontSize: 17)),
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            const SizedBox(height: 16),
            Text(cylContactText('editRemarks'),
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 36, 16, 0),
              // The remark name: the core field with the navigation preset (one input look), not a system TextField.
              child: SizedBox(
                height: 56,
                child: CYLSearchBarView(
                  placeholder: cylContactText('remarkName'),
                  navigationFieldStyle: true,
                  // The one text-style search button of the example (the default is the icon).
                  searchButtonStyle: CYLSearchBarSearchButtonStyle.text,
                ),
              ),
            ),
            Semantics(
              button: true,
              hint: cylContactText('hintEdit'),
              child: InkWell(
                key: const ValueKey<String>('CYLContactRemarkTagsTitle'),
                onTap: _edit,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text('${cylContactText('tags')} ›', style: const TextStyle(fontSize: 15, color: _secondary)),
                ),
              ),
            ),
            if (_tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CYLTagListView(
                  backgroundStyle: 'liquidGlass',
                  key: const ValueKey<String>('CYLContactRemarkTags'),
                  tags: _tags.map(_store.title).toList(),
                  tagIds: _tags,
                  foldedRowCount: 0,
                  foldControlPosition: CYLTagFoldControlPosition.none,
                  onTagSelected: (_, _) => _edit(),
                ),
              )
            else
              GestureDetector(
                key: const ValueKey<String>('CYLContactRemarkEmptyTags'),
                behavior: HitTestBehavior.opaque,
                onTap: _edit,
                child: SizedBox(
                  height: 200,
                  // The platform view takes no taps here: the page opens the editor.
                  child: IgnorePointer(
                    child: CYLPlaceholderView(
                        placeholderStyle: CYLPlaceholderStyle.empty, text: cylContactText('remarkNoTags')),
                  ),
                ),
              ),
          ],
        ),
      );
}

/// Edit Tags: the search bar, Recent, My Tags (Manage), the editing bar and the simulated server.
class CYLContactTagEditorPage extends StatefulWidget {
  /// Creates the editor of `store`, with `initial` selected.
  const CYLContactTagEditorPage({super.key, required this.store, required this.initial, this.latency = 2});

  /// The user's tags.
  final CYLContactTagStore store;

  /// The ids selected when the page opens.
  final List<String> initial;

  /// The simulated server's delay, in seconds.
  final double latency;

  @override
  State<CYLContactTagEditorPage> createState() => _CYLContactTagEditorPageState();
}

class _CYLContactTagEditorPageState extends State<CYLContactTagEditorPage> {
  CYLContactTagStore get _store => widget.store;
  late List<String> _selected = List<String>.of(widget.initial);
  String _query = '';
  bool _managing = false;
  String? _renamingID;
  String _editingText = '';
  ({String status, bool done})? _hud;
  final List<Timer> _timers = <Timer>[];
  String? _nextStatus;

  /// Bumped to rebuild the search bar empty after a tag was created from the query.
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    _fetch(<String>['mine', 'recent']);
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  void _later(void Function() action, [double? seconds]) {
    _timers.add(Timer(Duration(milliseconds: ((seconds ?? widget.latency) * 1000).round()), () {
      if (mounted) action();
    }));
  }

  void _showHUD(String status, {bool done = false}) {
    setState(() => _hud = (status: status, done: done));
    if (done) _later(() => setState(() => _hud = null), 1.2);
  }

  void _fetch(List<String> keys) {
    final status = _nextStatus ?? cylContactText('downloading');
    final finished = cylContactText(_nextStatus != null ? 'synced' : 'downloaded');
    _nextStatus = null;
    _showHUD(status);
    _later(() {
      final sections = <String, List<CYLContactTag>>{
        for (final key in keys)
          if (_serverData[key] != null) key: _serverData[key]!,
      };
      if (_store.apply(sections)) setState(() {});
      _showHUD(finished, done: true);
    });
  }

  void _upload() {
    _showHUD(cylContactText('uploading'));
    final sections = _store.sections;
    _later(() {
      _serverData = <String, List<CYLContactTag>>{..._serverData, ...sections};
      _showHUD(cylContactText('uploaded'), done: true);
    });
  }

  void _sync() {
    // Another device edits the server's data (a random new tag, the first two swapped), then this device pulls it.
    final tags = List<CYLContactTag>.of(_serverData['mine'] ?? _store.sections['mine']!);
    final titles = tags.map((tag) => tag.title).toSet();
    final pool = cylContactText('otherDeviceTags').split(',').where((title) => !titles.contains(title)).toList();
    final random = Random();
    tags.add(CYLContactTag('o-${random.nextInt(1 << 32).toRadixString(16)}',
        pool.isEmpty ? 'Tag ${tags.length}' : pool[random.nextInt(pool.length)]));
    if (tags.length > 1) {
      final first = tags[0];
      tags[0] = tags[1];
      tags[1] = first;
    }
    _serverData = <String, List<CYLContactTag>>{..._serverData, 'mine': tags};
    _nextStatus = cylContactText('syncing');
    _fetch(<String>['mine']);
  }

  void _toggle(String id, bool selected) => setState(() {
        _selected = selected ? <String>[..._selected.where((item) => item != id), id] : _selected.where((item) => item != id).toList();
      });

  void _create(String name) {
    final id = _store.create(name);
    if (id == null) return;
    setState(() {
      if (!_selected.contains(id)) _selected = <String>[..._selected, id];
      _query = '';
      _searchGeneration++;
    });
  }

  void _setManaging(bool value) {
    if (!value && _managing) _upload();
    setState(() {
      _managing = value;
      _renamingID = null;
      _editingText = '';
      if (value && _query.isNotEmpty) {
        _query = '';
        _searchGeneration++;
      }
    });
  }

  void _openContacts(String id) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => CYLContactListPage(store: _store, tagID: id),
      ));

  @override
  Widget build(BuildContext context) {
    final doneEnabled = _query.isEmpty && (_selected.isNotEmpty || _selected.join(',') != widget.initial.join(','));
    final results = _query.isEmpty ? const <String>[] : _store.matching(_query);
    final String? emptyState = _query.isNotEmpty
        ? (results.isEmpty ? 'noMatch' : null)
        : (_store.tags.isEmpty ? 'noTags' : null);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Text(cylContactText('editTags'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
        actions: <Widget>[
          IconButton(
            key: const ValueKey<String>('CYLContactTagsSync'),
            tooltip: cylContactText('sync'),
            icon: const Icon(Icons.sync, color: _link),
            onPressed: _sync,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              key: const ValueKey<String>('CYLContactTagsDone'),
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: const Color(0x29787880),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: doneEnabled
                  ? () {
                      _store.markUsed(_selected);
                      Navigator.of(context).pop(_selected);
                    }
                  : null,
              child: Text(cylContactText('done'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // The search field is this library's CYLSearchBarView.
              SizedBox(
                height: 56,
                child: CYLSearchBarView(
                  key: ValueKey<String>('CYLContactTagsSearch$_searchGeneration'),
                  placeholder: cylContactText('search'),
                  navigationFieldStyle: true,
                  onTextChanged: (text) {
                    final value = text.trim();
                    if (value.isNotEmpty && _managing) _setManaging(false);
                    setState(() => _query = value);
                  },
                  onSubmitted: (_) {
                    if (_store.canCreate(_query)) _create(_query);
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    if (_query.isNotEmpty) ...<Widget>[
                      CYLTagListView(
                        backgroundStyle: 'liquidGlass',
                        sectionTitle: cylContactText('results'),
                        tags: results.map(_store.title).toList(),
                        tagIds: results,
                        selectionMode: CYLTagSelectionMode.multiple,
                        selectedIds: _selected,
                        foldControlPosition: CYLTagFoldControlPosition.none,
                        onTagToggled: (_, id, selected) => _toggle(id, selected),
                      ),
                      if (_store.canCreate(_query))
                        _CreateButton(
                            key: const ValueKey<String>('CYLContactTagsCreate'),
                            title: '${cylContactText('newTag')}: $_query',
                            onTap: () => _create(_query)),
                    ] else ...<Widget>[
                      if (_store.recentIDs.isNotEmpty)
                        // Recent: CollectionViewClassifyMenu's built-in clear button in the header.
                        CYLTagListView(
                          backgroundStyle: 'liquidGlass',
                          sectionTitle: cylContactText('recent'),
                          showsClearButton: true,
                          tags: _store.recentIDs.map(_store.title).toList(),
                          tagIds: _store.recentIDs,
                          selectionMode: CYLTagSelectionMode.multiple,
                          selectedIds: _selected,
                          foldControlPosition: CYLTagFoldControlPosition.none,
                          onTagToggled: (_, id, selected) => _toggle(id, selected),
                          onClearButtonTapped: () => setState(() => _store.recentIDs = <String>[]),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Semantics(
                                container: true,
                                header: true,
                                child: Text(cylContactText('mine'), style: const TextStyle(fontSize: 15, color: _secondary))),
                            Semantics(
                              // Its own node: the title and the button are separate for TalkBack and VoiceOver.
                              container: true,
                              button: true,
                              hint: cylContactText('hintManage'),
                              child: GestureDetector(
                                key: const ValueKey<String>('CYLContactTagsManage'),
                                onTap: () => _setManaging(!_managing),
                                child: Text(cylContactText(_managing ? 'doneManaging' : 'manage'),
                                    style: const TextStyle(fontSize: 15, color: _link)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // My Tags: folded to three rows, the chevron as its last tag; editing while managing (crosses,
                      // dragging, renaming).
                      CYLTagListView(
                        backgroundStyle: 'liquidGlass',
                        tags: _store.tags.map((tag) => tag.title).toList(),
                        tagIds: _store.tags.map((tag) => tag.id).toList(),
                        selectionMode: _managing ? CYLTagSelectionMode.none : CYLTagSelectionMode.multiple,
                        selectedIds: _selected,
                        editing: _managing,
                        supportsRenaming: true,
                        foldControlPosition: CYLTagFoldControlPosition.inline,
                        foldControlContent: CYLTagFoldControlContent.icon,
                        foldedRowCount: 3,
                        onTagToggled: (_, id, selected) => _managing ? _openContacts(id) : _toggle(id, selected),
                        onTagDeleted: (_, id) => setState(() {
                          _store.remove(id);
                          _selected = _selected.where((item) => item != id).toList();
                        }),
                        onTagMoved: (from, to) => setState(() => _store.move(from, to)),
                        onRenameRequested: (_, id, title) => setState(() {
                          _renamingID = id;
                          _editingText = title;
                        }),
                      ),
                      // "+ New Tag" opens Manage, whose editing bar adds the typed name.
                      if (!_managing)
                        _CreateButton(
                            key: const ValueKey<String>('CYLContactTagsNewTag'),
                            title: cylContactText('newTag'),
                            onTap: () => _setManaging(true)),
                    ],
                    if (emptyState != null)
                      SizedBox(
                        key: const ValueKey<String>('CYLContactTagsPlaceholder'),
                        height: 240,
                        child: CYLPlaceholderView(
                          placeholderStyle: emptyState == 'noMatch' ? CYLPlaceholderStyle.noResults : CYLPlaceholderStyle.empty,
                          text: cylContactText(emptyState),
                        ),
                      ),
                  ],
                ),
              ),
              if (_managing)
                // The edit field of "Manage": the core's editing bar, above the keyboard (the Scaffold resizes).
                Container(
                  color: Colors.white,
                  height: 56,
                  child: CYLSearchBarView(
                    key: const ValueKey<String>('CYLSearchEditingBar'),
                    editingBar: true,
                    actionTitle: cylContactText(_renamingID != null ? 'done' : 'add'),
                    placeholder: cylContactText('tagName'),
                    navigationFieldStyle: true,
                    text: _editingText,
                    onEditingSubmitted: (name) => setState(() {
                      final id = _renamingID;
                      if (id != null) {
                        _store.rename(id, name);
                      } else {
                        _store.create(name);
                      }
                      _renamingID = null;
                      _editingText = '';
                    }),
                  ),
                ),
            ],
          ),
          if (_hud != null) _HUD(status: _hud!.status, done: _hud!.done),
        ],
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const _CreateButton({super.key, required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Color(0xFFC6C6C8)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: onTap,
            child: Text('＋ $title'),
          ),
        ),
      );
}

/// A HUD as CYLPlaceholderHUD shows it: a spinner or a check mark above a status, over the middle of the page.
class _HUD extends StatelessWidget {
  const _HUD({required this.status, required this.done});

  final String status;
  final bool done;

  @override
  Widget build(BuildContext context) => Positioned.fill(
        child: IgnorePointer(
          child: Align(
            alignment: const Alignment(0, -0.2),
            child: Semantics(
              liveRegion: true,
              child: Container(
                constraints: const BoxConstraints(minWidth: 120, maxWidth: 260),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xF5FFFFFF),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x26000000), blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (done)
                      const Icon(Icons.check, size: 32, color: Color(0xFF333333))
                    else
                      const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF333333))),
                    const SizedBox(height: 8),
                    Text(status, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Color(0xFF333333))),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

/// The contacts of a tag.
class CYLContactListPage extends StatelessWidget {
  /// Creates the list of the contacts with `tagID`.
  const CYLContactListPage({super.key, required this.store, required this.tagID});

  /// The user's tags and contacts.
  final CYLContactTagStore store;

  /// The tag.
  final String tagID;

  @override
  Widget build(BuildContext context) {
    final contacts = store.contacts.where((contact) => contact.tags.contains(tagID)).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(cylContactText('contactsTitle', <Object>[store.title(tagID), contacts.length]),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      body: contacts.isEmpty
          ? CYLPlaceholderView(
              key: const ValueKey<String>('CYLContactListEmpty'),
              placeholderStyle: CYLPlaceholderStyle.personOff,
              text: cylContactText('noContacts', <Object>[store.title(tagID)]))
          : ListView(
              key: const ValueKey<String>('CYLContactList'),
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                for (final contact in contacts)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(contact.name, style: const TextStyle(fontSize: 17)),
                        Text(contact.tags.map(store.title).join(' · '), style: const TextStyle(fontSize: 13, color: _secondary)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
