import 'package:flutter/material.dart';
import 'package:flutter_cylsearch/flutter_cylsearch.dart';

import 'qmui_strings.dart';

/// The ten keywords of QMUI's QDSearchViewController.
const List<String> cylQMUIKeywords = <String>[
  'Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat', 'Metabolism', 'Nuturally',
];

/// The eight suggestions of QMUI's QDRecentSearchView, shown while there is no history.
const List<String> cylQMUISuggestions = <String>['Helps', 'Maintain', 'Liver', 'Health', 'Function', 'Supports', 'Healthy', 'Fat'];

/// The keywords that contain `query` (case sensitive, as QMUI's demo), twenty rows each, in order.
List<String> cylQMUIResults(String query) => query.isEmpty
    ? const <String>[]
    : <String>[for (final keyword in cylQMUIKeywords.where((keyword) => keyword.contains(query))) ...List<String>.filled(20, keyword)];

/// The "Search controller" screen: a replica of QMUI's QDSearchViewController. A list of ten keywords whose first item
/// is a search bar; a tap on it opens the search page ([CYLSearchView]) with a launch view of recent searches while the
/// text is empty, the matching keywords (twenty rows each, the match in the tint color), "No matching results" when
/// nothing matches, and swipe to dismiss.
class CYLQMUISearchControllerPage extends StatelessWidget {
  /// Creates the screen.
  const CYLQMUISearchControllerPage({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (routeContext) => const Scaffold(body: CYLQMUISearchPage()),
    ));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(cylDemoText('demo.searchController'))),
        body: CYLSearchListView(
          searchBar: CYLSearchBarView(placeholder: 'Search'),
          onSearchBarTap: () => _openSearch(context),
          itemCount: cylQMUIKeywords.length,
          itemBuilder: (context, index) => ListTile(title: Text(cylQMUIKeywords[index])),
        ),
      );
}

/// The search page of the "Search controller" screen.
class CYLQMUISearchPage extends StatefulWidget {
  /// Creates the page.
  const CYLQMUISearchPage({super.key});

  @override
  State<CYLQMUISearchPage> createState() => _CYLQMUISearchPageState();
}

class _CYLQMUISearchPageState extends State<CYLQMUISearchPage> {
  final CYLSearchViewWidgetController _controller = CYLSearchViewWidgetController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(String query) {
    setState(() => _query = query);
    // "No matching results" while a query matches no keyword.
    if (query.isNotEmpty && cylQMUIResults(query).isEmpty) {
      _controller.showEmptyView(text: cylDemoText('controller.noResults'));
    } else {
      _controller.hideEmptyView();
    }
  }

  Widget _launchView(BuildContext context, List<String> history) {
    final tags = history.isEmpty ? cylQMUISuggestions : history;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Semantics(header: true, child: Text(cylDemoText('controller.recent'), style: Theme.of(context).textTheme.bodyMedium))),
              if (history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: cylDemoText('search.clearRecent'),
                  onPressed: _controller.clearHistory,
                ),
            ],
          ),
          const Divider(height: 8),
          const SizedBox(height: 20),
          Semantics(label: cylDemoText('controller.launch.label'), child: CYLTagListView(tags: tags, foldControlPosition: CYLTagFoldControlPosition.none)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = cylQMUIResults(_query);
    return CYLSearchView(
      controller: _controller,
      placeholder: 'Search',
      results: results,
      highlightsResultMatches: true,
      showsEmptyResultsPlaceholder: true,
      suggestionCachePolicy: CYLSearchSuggestionCachePolicy.userDefaults,
      suggestionCacheName: 'FlutterQMUISearchController',
      supportsSwipeToDismissSearch: true,
      launchViewBuilder: _launchView,
      onUpdateResults: _update,
      onSelectResult: (result, index) => Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => Scaffold(appBar: AppBar(title: Text(result)), body: Center(child: Text(result, style: Theme.of(context).textTheme.headlineMedium))),
      )),
      onClose: () => Navigator.of(context).pop(),
    );
  }
}
