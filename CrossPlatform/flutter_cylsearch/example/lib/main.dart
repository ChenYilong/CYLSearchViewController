import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cyltabbar/flutter_cyltabbar.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

import 'discover_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The tab bar comes from a local configuration file (the default example integration of CYLTabBarController).
  final configuration =
      jsonDecode(await rootBundle.loadString('assets/cyl_tabbar_configuration.json')) as Map<String, Object?>;
  runApp(CYLSearchExampleApp(tabBarConfiguration: configuration));
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
      {this.style = CYLSearchSuggestionStyle.list, this.query, this.scenario, this.focusesSearchFieldOnShow = true});

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
  CYLSearchDemoTab('List style', 'Suggestions as a list, filtered as you type.', <CYLSearchDemo>[CYLSearchDemo('Open search')]),
  CYLSearchDemoTab('Tag style', 'The same suggestions as tags (CollectionViewClassifyMenu).',
      <CYLSearchDemo>[
        // The keyboard stays down until the field is tapped: the cached queries (or the empty placeholder) show first.
        CYLSearchDemo('Open search', style: CYLSearchSuggestionStyle.tags, focusesSearchFieldOnShow: false),
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
  Widget build(BuildContext context) => Scaffold(
        body: _plusPageSelected
            ? const CYLSearchBarDemoPage()
            : _selectedIndex < cylDemoTabs.length
                ? CYLSearchDemoPage(key: ValueKey<int>(_selectedIndex), tab: cylDemoTabs[_selectedIndex])
                : const CYLSearchDiscoverPage(),
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

/// A tab: its description and one button per demo, each opening the native search page as a full screen route.
class CYLSearchDemoPage extends StatelessWidget {
  /// Creates the page of `tab`.
  const CYLSearchDemoPage({super.key, required this.tab});

  /// The demos of the tab.
  final CYLSearchDemoTab tab;

  void _openSearch(BuildContext context, CYLSearchDemo demo) {
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
        appBar: AppBar(title: Text(tab.title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(tab.description, style: Theme.of(context).textTheme.bodyLarge),
              for (final demo in tab.demos) ...<Widget>[
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.search),
                  label: Text(demo.label),
                  onPressed: () => _openSearch(context, demo),
                ),
              ],
            ],
          ),
        ),
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Search bar')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      );
}
