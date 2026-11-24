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

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(data.text('discover.title'))),
      body: Column(
        children: <Widget>[
          // The search bar sits under the navigation bar: it covers no view. The field stays; the camera, a divider
          // and the Search button are items appended inside its bordered capsule (core `CYLSearchBarItem`).
          SizedBox(
              height: 56,
              child: CYLSearchBarView(
                controller: _barController,
                text: _barText,
                searchBarStyle: CYLSearchBarStyle.bordered,
                showsSearchIcon: false,
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
                    onTap: (_) => _search(_typed),
                  ),
                ],
                onTextChanged: (text) => _typed = text,
                onSubmitted: _search,
              ),
            ),
          Expanded(
            child: ListView(
              children: <Widget>[
                if (_recent.isNotEmpty) ...<Widget>[
                  // The native tag list brings its own section header (title and trash) and lines up with the bar.
                  // The last tag is the fold chevron, two rows while folded (the iOS and Android Discover pages).
                  CYLTagListView(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
