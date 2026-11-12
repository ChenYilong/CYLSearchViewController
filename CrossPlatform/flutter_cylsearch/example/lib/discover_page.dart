import 'dart:convert';
import 'dart:math';
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

  /// The topics shown first.
  List<CYLDiscoverTopic> get initialTopics => discover.take(max(0, discoverCount)).toList();

  /// Another random selection of topics, without the ones shown now when the pool allows it (the refresh button).
  List<CYLDiscoverTopic> randomTopics(List<CYLDiscoverTopic> current, [Random? random]) {
    final count = min(max(0, discoverCount), discover.length);
    final picked = discover.where((topic) => !current.contains(topic)).toList()..shuffle(random);
    final result = picked.take(count).toList();
    if (result.length < count) {
      result.addAll((current.toList()..shuffle(random)).take(count - result.length));
    }
    return result;
  }

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
  String _typed = '';
  String? _barText;

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

  Widget _header(BuildContext context, String title, IconData icon, String tooltip, VoidCallback onPressed) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 4, 4),
        child: Row(
          children: <Widget>[
            Expanded(child: Semantics(header: true, child: Text(title, style: Theme.of(context).textTheme.titleMedium))),
            IconButton(icon: Icon(icon), tooltip: tooltip, onPressed: onPressed),
          ],
        ),
      );

  Widget _topic(BuildContext context, CYLSearchDiscoverData data, CYLDiscoverTopic topic) => Semantics(
        button: true,
        hint: data.text('discover.tapToSearch'),
        label: topic.hot ? '${topic.title}, ${data.text('discover.hot')}' : topic.title,
        excludeSemantics: true,
        child: InkWell(
          onTap: () => _search(topic.title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                Flexible(child: Text(topic.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (topic.hot) ...<Widget>[
                  const SizedBox(width: 4),
                  Image.asset('${data.folder}/discover-hot.png', height: 16),
                ],
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final data = _data;
    if (data == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: Text(data.text('discover.title'))),
      body: Column(
        children: <Widget>[
          // The search bar sits under the navigation bar: it covers no view.
          Row(
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: CYLSearchBarView(
                    text: _barText,
                    fieldShadowOpacity: 0.12,
                    onTextChanged: (text) => _typed = text,
                    onSubmitted: _search,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.photo_camera_outlined),
                tooltip: data.text('discover.imageSearch'),
                onPressed: () => _show(data.text('discover.imageSearchUnavailable')),
              ),
              TextButton(onPressed: () => _search(_typed), child: Text(data.text('discover.search'))),
              const SizedBox(width: 8),
            ],
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                if (_recent.isNotEmpty) ...<Widget>[
                  _header(context, data.text('discover.recent'), Icons.delete_outline, data.text('discover.clear'), () {
                    setState(() => _recent = <String>[]);
                    _show(data.text('discover.cleared'));
                  }),
                  CYLTagListView(tags: _recent, onTagSelected: (index, title) => _search(title)),
                ],
                _header(context, data.text('discover.title'), Icons.refresh, data.text('discover.refresh'),
                    () => setState(() => _topics = data.randomTopics(_topics))),
                for (var row = 0; row < _topics.length; row += 2)
                  Row(
                    children: <Widget>[
                      Expanded(child: _topic(context, data, _topics[row])),
                      Expanded(child: row + 1 < _topics.length ? _topic(context, data, _topics[row + 1]) : const SizedBox()),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
