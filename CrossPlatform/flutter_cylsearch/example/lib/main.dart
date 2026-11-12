import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cyltabbar/flutter_cyltabbar.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

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

/// One demo of a tab: how its search page is configured.
class CYLSearchDemo {
  /// Creates a demo.
  const CYLSearchDemo(this.title, this.description, {this.style = CYLSearchSuggestionStyle.list, this.query, this.scenario});

  /// The page title.
  final String title;

  /// What the demo shows.
  final String description;

  /// The suggestion style.
  final CYLSearchSuggestionStyle style;

  /// The query the search starts with.
  final String? query;

  /// The empty results placeholder's scenario, or null for the default.
  final CYLPlaceholderScenario? scenario;
}

/// The demos of the four tabs, in the order of the configuration file.
const List<CYLSearchDemo> cylDemos = <CYLSearchDemo>[
  CYLSearchDemo('List style', 'Suggestions as a list, filtered as you type.'),
  CYLSearchDemo('Tag style', 'The same suggestions as tags (CollectionViewClassifyMenu).', style: CYLSearchSuggestionStyle.tags),
  CYLSearchDemo('No results', 'A query without a match shows CYLTableViewPlaceHolder\'s "No matching results".', query: 'zzz'),
  CYLSearchDemo('No content', 'The same with the plain empty state (CYLPlaceholderScenario.noContent).',
      query: 'zzz', scenario: CYLPlaceholderScenario.noContent),
];

/// The example app of flutter_cylsearch: CYLTabBarController's Flutter tab bar, one tab per demo, and the search bar
/// demo on the raised plus button's page.
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
  int _selectedIndex = 0;
  bool _plusPageSelected = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: _plusPageSelected
            ? const CYLSearchBarDemoPage()
            : CYLSearchDemoPage(key: ValueKey<int>(_selectedIndex), demo: cylDemos[_selectedIndex]),
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

/// A tab: its demo and a button that opens the native search page as a full screen route.
class CYLSearchDemoPage extends StatelessWidget {
  /// Creates the page of `demo`.
  const CYLSearchDemoPage({super.key, required this.demo});

  /// The demo of the tab.
  final CYLSearchDemo demo;

  void _openSearch(BuildContext context) {
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
          onSubmitted: (text) => ScaffoldMessenger.of(routeContext).showSnackBar(SnackBar(content: Text('Query: $text'))),
          onClose: () => Navigator.of(routeContext).pop(),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(demo.title)),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(demo.description, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Open search'),
                onPressed: () => _openSearch(context),
              ),
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
