import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

/// One discover topic of search-discover.json.
class CYLDiscoverTopic {
  /// Creates a topic.
  const CYLDiscoverTopic(this.title, {this.hot = false});

  /// The title.
  final String title;

  /// `icon: "hot"`: the localized hot icon follows the title.
  final bool hot;
}

/// The data of the discover demo: the same files as the iOS and Android examples (CYLSearchDiscover.bundle, copied from
/// CollectionViewClassifyMenu), one folder per language under assets/discover/.
class CYLSearchDiscoverData {
  /// Creates the data.
  CYLSearchDiscoverData({
    required this.folder,
    required this.strings,
    required this.discoverCount,
    required this.recentSearches,
    required this.discover,
  });

  /// The asset folder of the language, for example `assets/discover/en`.
  final String folder;

  /// CYLSearchDiscover.strings of the language.
  final Map<String, String> strings;

  /// How many topics show at a time.
  final int discoverCount;

  /// The recent searches to start with.
  final List<String> recentSearches;

  /// The pool of topics.
  final List<CYLDiscoverTopic> discover;

  /// The number of whole pages of [discoverCount] topics in the pool.
  int get pageCount => discoverCount > 0 ? discover.length ~/ discoverCount : 0;

  /// The topics of [page] (the page wraps around the pool): [discoverCount] records, each with its own hot mark.
  List<CYLDiscoverTopic> topicsOnPage(int page) {
    if (pageCount == 0) return <CYLDiscoverTopic>[];
    final start = (page % pageCount) * discoverCount;
    return discover.sublist(start, start + discoverCount);
  }

  /// The page after [page], cyclically: refresh shows the next page, so the hot topic (one per page, at another slot
  /// than on the next page) moves on every refresh.
  int nextPage(int page) => pageCount > 0 ? (page + 1) % pageCount : 0;

  /// The topics shown first: page 0.
  List<CYLDiscoverTopic> get initialTopics => topicsOnPage(0);

  /// The localized string of `key`, with `%@` replaced by `argument`.
  String text(String key, [String? argument]) {
    final value = strings[key] ?? key;
    return argument == null ? value : value.replaceAll('%@', argument);
  }

  /// The language folder of `locale`, as the native examples choose their .lproj.
  static String languageFolder(Locale locale) {
    if (locale.languageCode == 'ja') return 'ja';
    if (locale.languageCode != 'zh') return 'en';
    final traditional = locale.scriptCode == 'Hant' || const <String>{'TW', 'HK', 'MO'}.contains(locale.countryCode);
    return traditional ? 'zh-Hant' : 'zh-Hans';
  }

  /// Parses `"key" = "value";` lines of a .strings file.
  static Map<String, String> parseStrings(String text) => <String, String>{
        for (final match in RegExp(r'^"((?:[^"\\]|\\.)*)"\s*=\s*"((?:[^"\\]|\\.)*)";', multiLine: true).allMatches(text))
          match.group(1)!: match.group(2)!.replaceAll(r'\"', '"').replaceAll(r'\n', '\n'),
      };

  /// Loads the data of the system language.
  static Future<CYLSearchDiscoverData> load([AssetBundle? bundle]) async {
    final assets = bundle ?? rootBundle;
    final folder = 'assets/discover/${languageFolder(PlatformDispatcher.instance.locale)}';
    final json = jsonDecode(await assets.loadString('$folder/search-discover.json')) as Map<String, Object?>;
    return CYLSearchDiscoverData(
      folder: folder,
      strings: parseStrings(await assets.loadString('$folder/CYLSearchDiscover.strings')),
      discoverCount: json['discoverCount'] as int? ?? 6,
      recentSearches: (json['recentSearches'] as List<Object?>? ?? const <Object?>[]).cast<String>(),
      discover: <CYLDiscoverTopic>[
        for (final topic in (json['discover'] as List<Object?>? ?? const <Object?>[]).cast<Map<String, Object?>>())
          CYLDiscoverTopic(topic['title'] as String? ?? '', hot: topic['icon'] == 'hot'),
      ],
    );
  }
}

/// The entry of the Discover tab: a one-row page that opens the Discover page, so the Discover page is always a second-level
/// page and its navigation bar always has a back button on the left (owner's rule for every example). The first time it
/// shows it opens the Discover page at once; the back button returns here (iOS `CYLSearchDiscoverEntryViewController`).
class CYLSearchDiscoverEntryPage extends StatefulWidget {
  /// Creates the page.
  const CYLSearchDiscoverEntryPage({super.key});

  @override
  State<CYLSearchDiscoverEntryPage> createState() => _CYLSearchDiscoverEntryPageState();
}

class _CYLSearchDiscoverEntryPageState extends State<CYLSearchDiscoverEntryPage> {
  CYLSearchDiscoverData? _data;

  @override
  void initState() {
    super.initState();
    CYLSearchDiscoverData.load().then((data) {
      if (!mounted) return;
      setState(() => _data = data);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _open();
      });
    });
  }

  void _open() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CYLSearchDiscoverPage()));
  }

  @override
  Widget build(BuildContext context) {
    final title = _data?.text('discover.title') ?? '';
    return DecoratedBox(
      // A gradient page (docs/instructions/example-demos.md rule 7): the list draws no background, the glass board and tag sit on it.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? const <Color>[Color(0xFF1B1F5E), Color(0xFF5B2A86), Color(0xFF0F6E7A)]
              : const <Color>[Color(0xFF7FB7FF), Color(0xFFFF9EC7), Color(0xFFFFC27A)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, title: Text(title)),
        // The entry cell as a tag of the tag list: titled section, glass, tail control with the icon only, a tap = the cell's tap.
        body: SingleChildScrollView(
          child: CYLTagListView(
            tags: <String>[title],
            sectionTitle: title,
            backgroundStyle: 'liquidGlass',
            foldedRowCount: 3,
            titleMaxLines: cylTagTitleUnlimited,
            tagSubtitles: <String>[title],
            foldControlPosition: CYLTagFoldControlPosition.inline,
            foldControlContent: CYLTagFoldControlContent.icon,
            onTagSelected: (index, tagTitle) => _open(),
          ),
        ),
      ),
    );
  }
}

/// The discover demo (iOS `CYLSearchDiscoverViewController`, Android `CYLSearchDiscoverFragment`): the native search
/// bar, the recent searches as CollectionViewClassifyMenu tags, and discover topics in two columns.
class CYLSearchDiscoverPage extends StatefulWidget {
  /// Creates the page.
  const CYLSearchDiscoverPage({super.key});

  @override
  State<CYLSearchDiscoverPage> createState() => _CYLSearchDiscoverPageState();
}

class _CYLSearchDiscoverPageState extends State<CYLSearchDiscoverPage> {
  CYLSearchDiscoverData? _data;
  List<String> _recent = <String>[];
  List<CYLDiscoverTopic> _topics = <CYLDiscoverTopic>[];
  int _page = 0;
  String _typed = '';
  String? _barText;
  bool _loops = false;
  // The tag lists' background: Liquid Glass (default) or flat; the toggle under the loop control switches both lists.
  bool _glass = true;
  double _speed = 1.0;
  final CYLSearchBarWidgetController _barController = CYLSearchBarWidgetController();

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    CYLSearchDiscoverData.load().then((data) {
      if (!mounted) return;
      setState(() {
        _data = data;
        _recent = List<String>.of(data.recentSearches);
        _topics = data.initialTopics;
      });
    });
  }

  void _show(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Searches `text`: it moves to the front of the recent searches and shows in the bar.
  /// The search field's placeholder: the first topic shown, else "Search" (iOS `reloadLists`).
  String _placeholder(CYLSearchDiscoverData data) => _topics.isNotEmpty ? _topics.first.title : data.text('discover.search');

  void _search(String text) {
    final query = text.trim();
    final data = _data;
    if (query.isEmpty || data == null) return;
    setState(() {
      _recent = <String>[query, ..._recent.where((item) => item != query)];
      _barText = query;
      _typed = query;
    });
    _show(data.text('discover.searching', query));
  }

  String get _styleName => _glass ? 'liquidGlass' : 'flat';

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final styleText = data.text('discover.styleLabel', data.text(_glass ? 'discover.styleGlass' : 'discover.styleFlat'));
    return Scaffold(
      // The page's search bar is always in a navigation bar: the core's, in the app bar slot. The field stays; the camera, a
      // divider and the Search button are items appended inside its bordered capsule (core `CYLSearchBarItem`).
      appBar: PreferredSize(
        // 44 pt: the Scaffold adds the status bar height to the app bar slot itself, and the SafeArea below keeps the bar
        // under it.
        preferredSize: const Size.fromHeight(44),
        child: SafeArea(
          child: CYLSearchBarView(
                          controller: _barController,
                          text: _barText,
                          // The field's placeholder is the first topic (iOS `reloadLists`); Search uses it when nothing is typed.
                          placeholder: _placeholder(data),
                          searchBarStyle: CYLSearchBarStyle.bordered,
                          showsSearchIcon: false,
                          embedsInNavigationBar: true,
                          // The page is always a second-level page: the back button on the left of the bar (owner's rule).
                          showsBackButton: true,
                          onBackPressed: () => Navigator.of(context).maybePop(),
                          fieldShadowOpacity: 0.06,
                          items: <CYLSearchBarItem>[
                            // The camera button itself plays the animation (the Animation demo rule): a search-related Lottie, the same
                            // search_camera.json on every platform. The static camera stays the fallback; loops, speed and restart below.
                            CYLSearchBarItem.icon(
                              image: 'camera',
                              title: data.text('discover.imageSearch'),
                              animationURL: 'search_camera.json',
                              animationLoops: _loops,
                              animationSpeed: _speed,
                              onTap: (_) => _show(data.text('discover.imageSearchUnavailable')),
                            ),
                            const CYLSearchBarItem.divider(),
                            CYLSearchBarItem.text(
                              title: data.text('discover.search'),
                              accessibilityIdentifier: 'CYLSearchDiscoverSearchButton',
                              onTap: (_) => _search(_typed.isEmpty ? _placeholder(data) : _typed),
                            ),
                          ],
                          onTextChanged: (text) => _typed = text,
                          onSubmitted: (text) => _search(text.isEmpty ? _placeholder(data) : text),
                        ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              // As the iOS example, measured: its first header starts 16 pt under the navigation bar (the scroll view 6 pt
              // under the safe area, plus 10 pt the list keeps above its first header).
              padding: const EdgeInsets.only(top: 16),
              children: <Widget>[
                if (_recent.isNotEmpty) ...<Widget>[
                  // The native tag list brings its own section header (title and trash) and lines up with the bar.
                  // The last tag is the fold chevron, two rows while folded (the iOS and Android Discover pages).
                  CYLTagListView(
                    backgroundStyle: _styleName,
                    tags: _recent,
                    sectionTitle: data.text('discover.recent'),
                    showsClearButton: true,
                    onClearButtonTapped: () {
                      setState(() => _recent = <String>[]);
                      _show(data.text('discover.cleared'));
                    },
                    foldControlPosition: CYLTagFoldControlPosition.inline,
                    foldControlContent: CYLTagFoldControlContent.icon,
                    foldedRowCount: 2,
                    onTagSelected: (index, title) => _search(title),
                  ),
                ],
                // The topics: CollectionViewClassifyMenu's tag list as a two-column grid, the hot icon after a hot topic;
                // its section header brings the title and the refresh icon.
                CYLTagListView(
                  backgroundStyle: _styleName,
                  tags: <String>[for (final topic in _topics) topic.title],
                  columns: 2,
                  foldedRowCount: 0,
                  sectionTitle: data.text('discover.title'),
                  showsRefreshButton: true,
                  onRefreshButtonTapped: () => setState(() {
                    _page = data.nextPage(_page);
                    _topics = data.topicsOnPage(_page);
                  }),
                  tagImages: <String>[for (final topic in _topics) topic.hot ? '${data.folder}/discover-hot.png' : ''],
                  tagImageLabels: <String>[for (final topic in _topics) topic.hot ? data.text('discover.hot') : ''],
                  onTagSelected: (index, title) => _search(title),
                ),
                  // Playback of the camera item (the last block of the page, outside the bar): loop switch, speed slider and Play again.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Semantics(
                          label: data.text('discover.animationLoops'),
                          child: Tooltip(
                            message: data.text('discover.animationLoops'),
                            child: Switch(value: _loops, onChanged: (value) => setState(() => _loops = value)),
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _speed,
                            min: 0.25,
                            max: 3,
                            label: '${data.text('discover.animationSpeed')} ${_speed.toStringAsFixed(2)}x',
                            semanticFormatterCallback: (value) => '${data.text('discover.animationSpeed')} ${value.toStringAsFixed(2)}x',
                            onChanged: (value) => setState(() => _speed = value),
                          ),
                        ),
                        Text('${_speed.toStringAsFixed(2)}x'),
                        TextButton(
                          onPressed: () => _barController.restartItemAnimation(0),
                          child: Text(data.text('discover.animationPlay')),
                        ),
                      ],
                    ),
                  ),
                  // Background style of every tag list on the page: Liquid Glass or flat, the current style as text.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        Semantics(
                          label: styleText,
                          child: Tooltip(
                            message: styleText,
                            child: Switch(value: _glass, onChanged: (value) => setState(() => _glass = value)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(styleText, key: const ValueKey<String>('CYLSearchDiscoverStyleLabel'))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
