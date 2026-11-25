import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cyltabbar/flutter_cyltabbar.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

import 'contact_tags_page.dart';
import 'discover_page.dart';
import 'example_texts.dart';
import 'qmui_search_bar_styles_page.dart';
import 'qmui_search_controller_page.dart';
import 'qmui_short_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The tab bar comes from a local configuration file (the default example integration of CYLTabBarController).
  // The tab icons (`--dart-define=CYL_DEMO_TAB_ICON_SOURCE=<n>`, as the iOS example's `-CYLDemoTabIconSource`):
  // 3 (the default) Rive: the artboards of CYLTabBarController's icons.riv (`CYLTabBarRiveFilePath`), which the iOS and
  // Android builds fetch from the pinned commit (not committed here: the file has no licence of its own);
  // 2 SVGA (`CYLTabBarSVGAFilePath`; ios/Runner/SVGA and the Android assets); 0 the PNG icons.
  const source = int.fromEnvironment('CYL_DEMO_TAB_ICON_SOURCE', defaultValue: 3);
  final file = switch (source) {
    3 => 'assets/cyl_tabbar_configuration_rive.json',
    2 => 'assets/cyl_tabbar_configuration_svga.json',
    _ => 'assets/cyl_tabbar_configuration.json',
  };
  final configuration = jsonDecode(await rootBundle.loadString(file)) as Map<String, Object?>;
  cylLocalizeTabTitles(configuration);
  runApp(CYLSearchExampleApp(tabBarConfiguration: configuration));
}

/// Replaces the tab titles of the configuration (English in the file) with the texts of the app's language.
void cylLocalizeTabTitles(Object? node) {
  if (node is Map<String, Object?>) {
    for (final entry in node.entries.toList()) {
      final value = entry.value;
      if (entry.key == 'CYLTabBarItemTitle' && value is String) {
        node[entry.key] = cylExampleText(value);
      } else {
        cylLocalizeTabTitles(value);
      }
    }
  } else if (node is List<Object?>) {
    node.forEach(cylLocalizeTabTitles);
  }
}

/// The suggestions of MaterialSearchView's Default sample, as in the iOS and Android examples.
const List<String> cylSampleSuggestions = <String>[
  'A very very long suggestion that would span multiple lines.', 'Android', 'iOS', 'SCALA', 'Ruby', 'JavaScript',
  'C#', 'Python', 'C', 'C++', 'PHP', 'Go', 'Perl', 'Bash', 'Lua', 'R', 'TCL', 'Haskell', 'Objective C', 'Swift',
  'Kotlin', 'jQuery', 'Development', 'Web', 'Ajax', 'Test', 'Testing', 'CookBook', 'Beagle', 'VMware', 'Less.js',
  'IDE', 'Arduino', 'Xamarin', 'UI', 'Microsoft', 'Application', 'JUnit', 'SQL',
];

/// One search page demo: how the native search page is configured.
class CYLSearchDemo {
  /// Creates a demo.
  const CYLSearchDemo(this.label,
      {this.style = CYLSearchSuggestionStyle.list,
      this.query,
      this.scenario,
      this.focusesSearchFieldOnShow = true,
      this.showsResults = false,
      this.contactTags = false,
      this.emptyTags = false,
      this.subtitle,
      this.page});

  /// The cell's subtitle: shown in a callout when its tag is long pressed (docs/instructions/example-demos.md).
  final String? subtitle;

  /// Opens a screen of the QMUI search port instead of a search page: `controller`, `styles` or `short`.
  final String? page;

  /// Opens the contact tags demo (iOS CYLContactRemarkViewController) instead of a search page.
  final bool contactTags;

  /// The contact tags demo without tags (the placeholders; iOS `-CYLContactTagsEmpty YES`).
  final bool emptyTags;

  /// Whether the page lists results (the matching sample suggestions) with pull to refresh, instead of suggestions only.
  final bool showsResults;

  /// The label of the button that opens it.
  final String label;

  /// The suggestion style.
  final CYLSearchSuggestionStyle style;

  /// The query the search starts with.
  final String? query;

  /// The empty results placeholder's scenario, or null for the default.
  final CYLPlaceholderScenario? scenario;

  /// Whether the keyboard rises when the page opens (false: the cached queries or the empty placeholder show first).
  final bool focusesSearchFieldOnShow;
}

/// A tab of search page demos.
class CYLSearchDemoTab {
  /// Creates a tab.
  const CYLSearchDemoTab(this.title, this.description, this.demos);

  /// The page title.
  final String title;

  /// What the demos show.
  final String description;

  /// One button per demo.
  final List<CYLSearchDemo> demos;
}

/// The first three tabs, in the order of the configuration file; the fourth tab is the discover page. iOS shows at most
/// five items in a tab bar (more become "More"), so the two empty states share a tab.
const List<CYLSearchDemoTab> cylDemoTabs = <CYLSearchDemoTab>[
  CYLSearchDemoTab('List style', 'Suggestions as a list, filtered as you type; or results with pull to refresh.',
      <CYLSearchDemo>[
        CYLSearchDemo('Open search', subtitle: 'The native search page with suggestions as a list, filtered as you type.'),
        CYLSearchDemo('Results and pull to refresh', showsResults: true, subtitle: 'The matching suggestions as results, with pull to refresh.'),
        CYLSearchDemo('Search controller', page: 'controller', subtitle: 'The QMUI search controller port.'),
        CYLSearchDemo('Search bar styles', page: 'styles', subtitle: 'Every search bar style on one screen.'),
        CYLSearchDemo('Short list', page: 'short', subtitle: 'A short suggestion list without scrolling.'),
      ]),
  CYLSearchDemoTab('Tag style', 'The same suggestions as tags (CollectionViewClassifyMenu).',
      <CYLSearchDemo>[
        // The keyboard stays down until the field is tapped: the cached queries (or the empty placeholder) show first.
        CYLSearchDemo('Open search', style: CYLSearchSuggestionStyle.tags, focusesSearchFieldOnShow: false, subtitle: 'The same suggestions as tags under the search bar.'),
        CYLSearchDemo('Contact tags (CollectionViewClassifyMenu)', contactTags: true, subtitle: 'Edit the tags of a contact: add, rename, reorder, delete.'),
        CYLSearchDemo('Contact tags without tags', contactTags: true, emptyTags: true, subtitle: 'The contact tags page with no tags yet: the placeholders.'),
      ]),
  CYLSearchDemoTab('Empty results', 'A query without a match shows a CYLTableViewPlaceHolder placeholder.', <CYLSearchDemo>[
    CYLSearchDemo('No matching results', query: 'zzz'),
    CYLSearchDemo('No content', query: 'zzz', scenario: CYLPlaceholderScenario.noContent),
  ]),
];

/// The example app of flutter_cylsearch: CYLTabBarController's Flutter tab bar, a tab per kind of demo (the last one is
/// the discover page), and the search bar demo on the raised plus button's page.
class CYLSearchExampleApp extends StatelessWidget {
  /// Creates the app with the tab bar configuration read from assets.
  const CYLSearchExampleApp({super.key, required this.tabBarConfiguration});

  /// The contents of assets/cyl_tabbar_configuration.json.
  final Map<String, Object?> tabBarConfiguration;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CYLSearch',
        theme: ThemeData(colorSchemeSeed: const Color(0xFF007AFF), useMaterial3: true),
        // Follows the system appearance, so the native views (which take the Flutter brightness) show dark mode too.
        darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF007AFF), useMaterial3: true, brightness: Brightness.dark),
        home: CYLSearchTabs(tabBarConfiguration: tabBarConfiguration),
      );
}

/// The tab bar and the page of the selected tab.
class CYLSearchTabs extends StatefulWidget {
  /// Creates the tabs.
  const CYLSearchTabs({super.key, required this.tabBarConfiguration});

  /// The tab bar configuration.
  final Map<String, Object?> tabBarConfiguration;

  @override
  State<CYLSearchTabs> createState() => _CYLSearchTabsState();
}

class _CYLSearchTabsState extends State<CYLSearchTabs> {
  // `--dart-define=CYL_DEMO_TAB=3` builds the example opened on that tab (3: Discover), for screenshots.
  int _selectedIndex = const int.fromEnvironment('CYL_DEMO_TAB');
  bool _plusPageSelected = false;

  @override
  void initState() {
    super.initState();
    // `--dart-define=CYL_DEMO_PAGE=controller|styles|short` opens that screen at launch, for screenshots.
    const page = String.fromEnvironment('CYL_DEMO_PAGE');
    if (page.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => openCYLQMUIPage(context, page));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _plusPageSelected
            ? const CYLSearchBarDemoPage()
            : _selectedIndex < cylDemoTabs.length
                ? CYLSearchDemoPage(key: ValueKey<int>(_selectedIndex), tab: cylDemoTabs[_selectedIndex])
                : const CYLSearchDiscoverEntryPage(),
        bottomNavigationBar: CYLTabBar(
          configuration: widget.tabBarConfiguration,
          selectedIndex: _plusPageSelected ? null : _selectedIndex,
          tapAnimation: 'scale',
          // index < 0: the plus button's page.
          onTabSelect: (index, identifier) => setState(() {
            _plusPageSelected = index < 0;
            if (index >= 0) _selectedIndex = index;
          }),
        ),
      );
}

/// Opens a screen of the QMUI search port: `controller`, `styles` or `short`.
void openCYLQMUIPage(BuildContext context, String page) {
  final Widget screen = switch (page) {
    'controller' => const CYLQMUISearchControllerPage(),
    'styles' => const CYLQMUISearchBarStylesPage(),
    _ => const CYLQMUIShortListPage(),
  };
  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
}

/// A tab: its description and one button per demo, each opening the native search page as a full screen route.
class CYLSearchDemoPage extends StatelessWidget {
  /// Creates the page of `tab`.
  const CYLSearchDemoPage({super.key, required this.tab});

  /// The demos of the tab.
  final CYLSearchDemoTab tab;

  void _openSearch(BuildContext context, CYLSearchDemo demo) {
    if (demo.page != null) {
      openCYLQMUIPage(context, demo.page!);
      return;
    }
    if (demo.contactTags) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CYLContactRemarkPage(empty: demo.emptyTags)));
      return;
    }
    if (demo.showsResults) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (routeContext) => const Scaffold(body: CYLSearchResultsDemoPage()),
      ));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (routeContext) => Scaffold(
        // The native search page fills the route: its search bar sits where a navigation bar would.
        body: CYLSearchView(
          suggestions: cylSampleSuggestions,
          suggestionStyle: demo.style,
          placeholder: 'Search',
          query: demo.query,
          showsEmptyResultsPlaceholder: true,
          emptyResultsScenario: demo.scenario ?? CYLPlaceholderScenario.noSearchResults,
          // Submitted queries are cached in the core's local database, one cache for these demos.
          suggestionCachePolicy: CYLSearchSuggestionCachePolicy.database,
          suggestionCacheName: 'FlutterExample',
          focusesSearchFieldOnShow: demo.focusesSearchFieldOnShow,
          // The tags end with the fold chevron, two rows while folded, as on the Discover page.
          suggestionsFoldControlPosition: CYLTagFoldControlPosition.inline,
          suggestionsFoldControlContent: CYLTagFoldControlContent.icon,
          suggestionsFoldedRowCount: 2,
          onSubmitted: (text) => ScaffoldMessenger.of(routeContext).showSnackBar(SnackBar(content: Text('Query: $text'))),
          onClose: () => Navigator.of(routeContext).pop(),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(cylExampleText(tab.title))),
        // The demos are tags of the core's tag list with its default initialization: as many tags as fit on a row, then the next row. The list brings
        // its own 16 inset, so only the description is padded.
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(cylExampleText(tab.description), style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(height: 16),
              CYLTagListView(
                tags: <String>[for (final demo in tab.demos) cylExampleText(demo.label)],
                // docs/instructions/example-demos.md: a titled section, a fold after 3 rows with the built-in icon and more / less.
                sectionTitle: cylExampleText(tab.title),
                // The tag list of an example is Liquid Glass (docs/instructions/example-demos.md, rule 6).
                backgroundStyle: 'liquidGlass',
                foldedRowCount: 3,
                // Adaptive width, titles may wrap; a long press shows the cell's subtitle in a callout; a tap opens the demo as the cell did.
                titleMaxLines: cylTagTitleUnlimited,
                tagSubtitles: <String>[for (final demo in tab.demos) cylExampleText(demo.subtitle ?? '')],
                foldControlContent: CYLTagFoldControlContent.iconAndTitle,
                onTagSelected: (index, title) => _openSearch(context, tab.demos[index]),
              ),
            ],
          ),
        ),
      );
}

/// The results demo: the native search page lists the sample suggestions that contain the query as results (iOS and
/// Android `resultsDataSource`), and a pull on the results refreshes them (`refreshHandler`, ended with
/// `endRefreshing()`).
class CYLSearchResultsDemoPage extends StatefulWidget {
  /// Creates the page.
  const CYLSearchResultsDemoPage({super.key});

  @override
  State<CYLSearchResultsDemoPage> createState() => _CYLSearchResultsDemoPageState();
}

class _CYLSearchResultsDemoPageState extends State<CYLSearchResultsDemoPage> {
  final CYLSearchViewWidgetController _controller = CYLSearchViewWidgetController();
  String _query = '';
  int _refreshCount = 0;

  /// The sample suggestions that contain the query; after a refresh, the newest refresh comes first.
  List<String> get _results {
    final query = _query.trim().toLowerCase();
    final matches = cylSampleSuggestions.where((item) => item.toLowerCase().contains(query)).toList();
    return <String>[if (_refreshCount > 0 && matches.isNotEmpty) 'Refreshed $_refreshCount×: ${matches.first}', ...matches];
  }

  Future<void> _refresh() async {
    try {
      // Stands for a network request.
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _refreshCount += 1);
    } finally {
      // Every completion path ends the refresh.
      await _controller.endRefreshing();
    }
  }

  @override
  Widget build(BuildContext context) => CYLSearchView(
        controller: _controller,
        suggestions: cylSampleSuggestions,
        placeholder: 'Search',
        results: _results,
        refreshEnabled: true,
        onRefresh: _refresh,
        showsEmptyResultsPlaceholder: true,
        suggestionCachePolicy: CYLSearchSuggestionCachePolicy.none,
        onTextChanged: (text) => setState(() => _query = text),
        onSelectResult: (result, index) =>
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Result $index: $result'))),
        onClose: () => Navigator.of(context).pop(),
      );
}

/// The plus button's page: the native search bar inline, its text and search shown below.
class CYLSearchBarDemoPage extends StatefulWidget {
  /// Creates the page.
  const CYLSearchBarDemoPage({super.key});

  @override
  State<CYLSearchBarDemoPage> createState() => _CYLSearchBarDemoPageState();
}

class _CYLSearchBarDemoPageState extends State<CYLSearchBarDemoPage> {
  String _status = 'Text: ';
  final CYLSearchBarWidgetController _multipleController = CYLSearchBarWidgetController();
  // The completed searches of the multiple-search bar, kept in sync through its callbacks.
  List<String> _searches = const <String>['Swift', 'Kotlin'];
  String _multipleStatus = 'Searches: Swift, Kotlin';

  void _showSearches(String event) => setState(() => _multipleStatus = '$event · Searches: ${_searches.join(', ')}');

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(cylExampleText('Search bar'))),
        body: ListView(
          children: <Widget>[
            SizedBox(
              height: 52,
              child: CYLSearchBarView(
                placeholder: 'Streamer, room ID or song',
                showsCancelButton: true,
                fieldShadowOpacity: 0.12,
                onTextChanged: (text) => setState(() => _status = 'Text: $text'),
                onSubmitted: (text) => setState(() => _status = 'Searched: $text'),
                onCancel: () => setState(() => _status = 'Text: '),
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: Text(_status)),
            // Several searches side by side (`mode: multiple`): the magnifier starts a new search, the return key
            // completes it, a tap selects a search and its remove button removes it.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text('Multiple searches', style: Theme.of(context).textTheme.titleMedium),
            ),
            SizedBox(
              height: 56,
              child: CYLSearchBarView(
                controller: _multipleController,
                mode: CYLSearchBarMode.multiple,
                placeholder: 'Category',
                searches: _searches,
                onTextChange: (text, index) => setState(() => _multipleStatus = 'Typing $index: $text'),
                onCompleteSearch: (text, index) {
                  _searches = <String>[..._searches, text];
                  _showSearches('Completed $text');
                },
                onRemoveSearch: (index) {
                  _searches = <String>[..._searches]..removeAt(index);
                  _showSearches('Removed $index');
                },
                onSelectSearch: (text, index) => _showSearches('Selected $text'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  OutlinedButton(onPressed: _multipleController.beginNewSearch, child: const Text('New search')),
                  OutlinedButton(onPressed: _multipleController.completeSearch, child: const Text('Complete')),
                  OutlinedButton(
                    // Added without typing: the bar reports no completion, so the list follows the bar.
                    onPressed: () async {
                      await _multipleController.addSearch('Dart');
                      final searches = await _multipleController.searches();
                      _searches = searches;
                      _showSearches('Added Dart');
                    },
                    child: const Text('Add "Dart"'),
                  ),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: Text(_multipleStatus)),
          ],
        ),
      );
}
