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
/// is a search bar; a tap on it opens the search page ([CYLSearchView]), configured through the core's API only: its
/// launch area (the eight suggestions as tags, folded, then the recent searches with their header and trash button) while
/// the text is empty, a tapped tag submits, the matching keywords (twenty rows each, the match highlighted),
/// "No matching results" when nothing matches, and swipe to dismiss.
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
  String _query = '';

  @override
  Widget build(BuildContext context) => CYLSearchView(
        placeholder: 'Search',
        // The launch area is the core's: these suggestions while there is no history, the history after submits.
        suggestions: cylQMUISuggestions,
        showsSuggestionsForEmptyQuery: true,
        submitsOnSuggestionSelection: true,
        suggestionCachePolicy: CYLSearchSuggestionCachePolicy.userDefaults,
        suggestionCacheName: 'FlutterQMUISearchController',
        results: cylQMUIResults(_query),
        highlightsResultMatches: true,
        showsEmptyResultsPlaceholder: true,
        noResultsText: cylDemoText('controller.noResults'),
        supportsSwipeToDismissSearch: true,
        onTextChanged: (query) => setState(() => _query = query),
        onSelectResult: (result, index) => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => Scaffold(appBar: AppBar(title: Text(result)), body: Center(child: Text(result, style: Theme.of(context).textTheme.headlineMedium))),
        )),
        onClose: () => Navigator.of(context).pop(),
      );
}
